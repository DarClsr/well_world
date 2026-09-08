"""v10: compose reusable props into lived-in yards, bank pockets and ruin edges."""
import hashlib
import json
import math
import random
import struct
from collections import Counter
from pathlib import Path

import bpy
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree

ROOT=Path(__file__).resolve().parents[1]
ART=ROOT/'art/prologue_terrain'
SOURCE=ART/'prologue_terrain_v09.blend'
source_hash=hashlib.sha256(SOURCE.read_bytes()).hexdigest()
bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
scene=bpy.context.scene;scene.name='Prologue_Lived_Spaces_v10'
hashes={bpy.path.abspath(lib.filepath):hashlib.sha256(Path(bpy.path.abspath(lib.filepath)).read_bytes()).hexdigest() for lib in bpy.data.libraries}
terrain=[o for o in scene.objects if o.type=='MESH' and o.name.startswith('Terrain_0')]
geometry_hashes={o.name:hashlib.sha256(b''.join(struct.pack('fff',*v.co) for v in o.data.vertices)).hexdigest()
                 for o in terrain+[scene.objects['Water_Creek']]}
vertices,faces=[],[]
for obj in terrain:
    start=len(vertices);vertices.extend(obj.matrix_world@v.co for v in obj.data.vertices)
    faces.extend(tuple(start+i for i in p.vertices) for p in obj.data.polygons)
surface=BVHTree.FromPolygons(vertices,faces)
routes=json.loads((ROOT/'assets/prologue_terrain/expansion_v06.json').read_text())['routes_godot_xz']
starts=np.array([(a[0],-a[1]) for r in routes for a,b in zip(r,r[1:])])
ends=np.array([(b[0],-b[1]) for r in routes for a,b in zip(r,r[1:])])
delta=ends-starts;lengths=np.maximum(np.sum(delta*delta,axis=1),1e-8)
houses=[o for o in scene.objects if o.instance_collection and o.instance_collection.name=='Ancient_Earth_House']
groups={}
for label in ('Yard_Storage','Yard_Fuel','Yard_Rest','Workshop','Creek_Deadwood','Ruins_Wall_Footings'):
    group=bpy.data.collections.new('V10_'+label);scene.collection.children.link(group);groups[label]=group
bounds={}
for col in bpy.data.collections:
    if not col.name.startswith('Source_'):continue
    pts=[o.matrix_world@Vector(v) for o in col.all_objects if o.type=='MESH' for v in o.bound_box]
    if pts:bounds[col.name[7:]]=(min(p.z for p in pts),max(math.hypot(p.x,p.y) for p in pts))
rng=random.Random(910);entries=[];skipped=Counter()

def road_distance(x,y):
    t=np.clip(np.sum((np.array([x,y])-starts)*delta,axis=1)/lengths,0,1)
    return float(np.min(np.linalg.norm(np.array([x,y])-starts-t[:,None]*delta,axis=1)))

def ground(x,y):
    hit,normal,_,_=surface.ray_cast(Vector((x,y,150)),Vector((0,0,-1)))
    assert hit is not None,(x,y)
    return hit.z,normal

def allowed(x,y,radius):
    if road_distance(x,y)<2.1+radius:
        skipped['route_clearance']+=1;return False
    for house in houses:
        hx,hy=house.location.x,house.location.y
        if abs(x-hx)<1.25+radius and hy-5.0-radius<y<hy-1.7+radius:
            skipped['door_clearance']+=1;return False
        if abs(x-hx)<2.8+radius and abs(y-hy)<2.25+radius:
            skipped['house_footprint']+=1;return False
    if math.hypot(x+120,y-90.6)<2.5+radius or math.hypot(x+124.1,y-98.1)<1.3+radius:
        skipped['ruin_access']+=1;return False
    return True

def place(name,x,y,label,scale=1,yaw=None,sink=0):
    if name=='03_Mushrooms_Russet':scale*=.48
    bottom,radius=bounds[name];radius*=scale
    if not allowed(x,y,radius):return None
    h,normal=ground(x,y)
    if normal.z<.86:skipped['steep_surface']+=1;return None
    # Keep the new river water clear; bank vegetation starts outside its visible edge.
    if label=='Creek_Deadwood':
        water_points=[v.co for v in scene.objects['Water_Creek'].data.vertices if abs(v.co.y-y)<.3]
        if water_points and min(p.x for p in water_points)-radius<x<max(p.x for p in water_points)+radius:
            skipped['water_clearance']+=1;return None
    obj=bpy.data.objects.new('V10_'+name,None);obj.instance_type='COLLECTION'
    obj.instance_collection=bpy.data.collections['Source_'+name]
    obj.location=(x,y,h-bottom*scale-sink);obj.scale=(scale,)*3
    obj.rotation_euler.z=rng.uniform(0,math.tau) if yaw is None else yaw
    obj['source_asset']=name;obj['dressing_group']=label;groups[label].objects.link(obj)
    entries.append({'object':obj.name,'source':name,'group':label,'position':list(obj.location),
                    'scale':scale,'yaw':obj.rotation_euler.z,'grounded':True,'sink':sink,
                    'radius':radius,'route_clearance':road_distance(x,y)-radius,'source_bottom':bottom})
    return obj

def timber(name,x,y,height,scale,label,yaw=0):
    original=bpy.data.objects[name]
    obj=bpy.data.objects.new('V10_'+name,original.data);groups[label].objects.link(obj)
    obj.location=(x,y,height);obj.scale=scale;obj.rotation_euler.z=yaw
    for slot in obj.material_slots:
        slot.link='OBJECT';slot.material=bpy.data.materials['V08_Weathered_Timber']
    obj['module_source']=name;obj['dressing_group']=label
    entries.append({'object':obj.name,'source':name,'group':label,'position':list(obj.location),'grounded':False})
    return obj

def divider(x,y,label):
    # One short, open-ended screen; no perimeter enclosure or blocked gate.
    if not all(allowed(x,y+dy,.2) for dy in (-1.5,0,1.5)):return
    for dy in (-1.5,0,1.5):
        h,_=ground(x,y+dy);timber('Timber_Post_200',x,y+dy,h,(.8,.8,.58),label)
    h,_=ground(x,y)
    for up in (.4,.9):timber('Timber_Plank_360',x,y,h+up,(.25,3/3.6,.65),label)

# Three different household activities; retain existing door-side vessels.
for name,dx,dy,scale in [
    ('20_Terracotta_Jar',3.7,-1.0,1),('20_Terracotta_Jar',4.35,-.5,.75),
    ('18_Wicker_Basket',3.8,.05,.85),('16_Leather_Flask',4.2,-1.35,.9),
    ('10_MossRock_Pebbles',4.6,1,.55)]:
    place(name,-18+dx,dy,'Yard_Storage',scale)
divider(-13.3,1,'Yard_Storage')
for name,dx,dy,scale in [
    ('19_Firewood_Stack',3.8,0,1),('19_Firewood_Stack',3.9,1.0,.85),
    ('11_Fallen_Branch',4.3,-1,.7),('12_Hollow_Log',4.2,2.65,.65),
    ('18_Wicker_Basket',3.8,-1.9,.75)]:
    place(name,-7+dx,2+dy,'Yard_Fuel',scale,yaw=math.pi/2)
divider(-2.0,3,'Yard_Fuel')
for name,dx,dy,scale,yaw in [
    ('14_Rolled_Bedroll',-3.8,-1.2,1,math.pi/2),('16_Leather_Flask',-4.2,-.5,1,0),
    ('18_Wicker_Basket',-3.6,.2,.8,.3),('12_Hollow_Log',-4,1.9,.7,math.pi/2),
    ('03_Mushrooms_Russet',-4.3,2.5,.6,0)]:
    place(name,-19+dx,-17+dy,'Yard_Rest',scale,yaw)

# Work shelter: piles outside the roof and a clear approach.
for name,x,y,scale in [('19_Firewood_Stack',1,-19,1),('19_Firewood_Stack',1.2,-18,.9),
    ('12_Hollow_Log',1.5,-16.5,.8),('18_Wicker_Basket',.8,-21,.85),
    ('20_Terracotta_Jar',-6.7,-20.5,.8),('16_Leather_Flask',-6.5,-21,1)]:
    place(name,x,y,'Workshop',scale,yaw=math.pi/2)
for i in range(8):
    place('08_MossRock_Broad',-6.8+rng.uniform(-.55,.55),-23+rng.uniform(-.45,.45),'Workshop',rng.uniform(.16,.24),sink=.015)
for i in range(3):place('11_Fallen_Branch',-6.8+i*.13,-23,'Workshop',.35,yaw=i*1.1)

# Small foundation-edge growth, not vegetation in the central walking area.
for cx,cy,label in [(-18,0,'Yard_Storage'),(-7,2,'Yard_Fuel'),(-19,-17,'Yard_Rest'),(-3,-20,'Workshop')]:
    for dx,dy in [(-3.7,2.8),(-3.3,3.4),(3.3,3.3),(3.8,2.9)]:
        place('01_Fern_Spread',cx+dx,cy+dy,label,.4)
        place('10_MossRock_Pebbles',cx+dx+.45,cy+dy+.2,label,.38)
for x,y in [(-25,4),(-24,-13),(1,8)]:place('05_Amber_Sapling',x,y,'Yard_Rest',.8)

# Creek-bank habitat: deadwood with a fan of ferns and mushrooms in its shelter.
for center in [(21,15),(20,-29)]:
    cx,cy=center
    place('12_Hollow_Log',cx,cy,'Creek_Deadwood',.95,yaw=1.15)
    place('11_Fallen_Branch',cx+1.7,cy-1.3,'Creek_Deadwood',.75,yaw=-.7)
    for k in range(28):
        angle=rng.uniform(0,math.tau);radius=rng.uniform(1.0,3.7)
        name=rng.choices(['01_Fern_Spread','02_Fern_Fiddlehead','03_Mushrooms_Russet','10_MossRock_Pebbles'],[4,3,2,2])[0]
        place(name,cx+math.cos(angle)*radius,cy+math.sin(angle)*radius,'Creek_Deadwood',rng.uniform(.35,.75))

# Outside the ruined walls: weathering debris and plants leave doorway/niche clear.
for cx,cy in [(-127.4,94),(-127.2,98),(-123.8,101.2),(-118.4,101.3),(-113.1,96.3)]:
    place('09_MossRock_Split',cx,cy,'Ruins_Wall_Footings',.65,sink=.035)
    for k in range(12):
        name=rng.choice(['10_MossRock_Pebbles','01_Fern_Spread','02_Fern_Fiddlehead','03_Mushrooms_Russet'])
        place(name,cx+rng.uniform(-1.8,1.8),cy+rng.uniform(-1.35,1.35),'Ruins_Wall_Footings',rng.uniform(.35,.8),sink=.01)
place('12_Hollow_Log',-128.5,96,'Ruins_Wall_Footings',.8,yaw=1.7)

# Local humus beneath deadwood connects props to the terrain without adding mesh patches.
for obj in terrain:
    colors=obj.data.color_attributes.get('TerrainColor')
    if not colors:continue
    for v in obj.data.vertices:
        x,y=v.co.x,v.co.y
        factor=0
        for cx,cy in [(21,15),(20,-29),(-128.5,96)]:
            d=((x-cx)/3.2)**2+((y-cy)/2.7)**2
            factor=max(factor,max(0,1-d)*.60)
        if factor:
            old=colors.data[v.index].color
            colors.data[v.index].color=tuple(old[j]*(1-factor)+(.18,.18,.105)[j]*factor for j in range(3))+(1,)

views=[('courtyards',(-10,-6,5),(28,-36,25),44),
       ('creek_pocket',(21,15,ground(21,15)[0]+.5),(12,-17,11),10),
       ('ruin_edges',(-121,96,21),(20,-27,20),25)]
scene.cycles.samples=48;scene.render.resolution_x,scene.render.resolution_y=1600,1100
scene.frame_set(35)
for i,(label,target,offset,scale) in enumerate(views):
    camera=scene.camera;camera.location=Vector(target)+Vector(offset)
    camera.rotation_euler=(Vector(target)-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.ortho_scale=scale
    scene.render.filepath=str(ART/(label+'_v10.png'))
    if i==0:bpy.ops.wm.save_as_mainfile(filepath=str(ART/'prologue_terrain_v10.blend'))
    bpy.ops.render.render(write_still=True)
assert hashlib.sha256(SOURCE.read_bytes()).hexdigest()==source_hash
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==h for p,h in hashes.items())
report={'source_v09_sha256':source_hash,'linked_source_hashes':hashes,'terrain_water_hashes':geometry_hashes,
        'new_objects':len(entries),'source_counts':dict(Counter(e['source'] for e in entries)),
        'group_counts':dict(Counter(e['group'] for e in entries)),'skipped':dict(skipped),'placements':entries,
        'scope':'Blender only. Anchor and footprint clearance checks do not replace engine collision/navigation tests.'}
(ROOT/'assets/prologue_terrain/dressing_v10.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print('DRESSING_V10_OK',len(entries),report['group_counts'])
