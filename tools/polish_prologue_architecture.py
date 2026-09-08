"""v08 reusable ancient vernacular architecture and matched lighting review."""
import hashlib
import json
import math
import random
import struct
import sys
from pathlib import Path

import bpy
from mathutils import Vector
from mathutils.bvhtree import BVHTree

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'art/prologue_terrain'
LIB = ROOT / 'art/settlement_modules/v1'
LIB.mkdir(parents=True, exist_ok=True)
SOURCE = ART / 'prologue_terrain_v07.blend'
source_hash = hashlib.sha256(SOURCE.read_bytes()).hexdigest()
bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
scene = bpy.context.scene
scene.name = 'Prologue_Architecture_Light_v08'
rng = random.Random(908)
linked_hashes = {bpy.path.abspath(lib.filepath): hashlib.sha256(Path(bpy.path.abspath(lib.filepath)).read_bytes()).hexdigest()
                 for lib in bpy.data.libraries}

def terrain_hashes():
    return {o.name: hashlib.sha256(b''.join(struct.pack('fff', *v.co) for v in o.data.vertices)).hexdigest()
            for o in scene.objects if o.type == 'MESH' and o.name.startswith('Terrain_0')}

terrain_before = terrain_hashes()
ground_vertices,ground_faces=[],[]
for o in scene.objects:
    if o.type=='MESH' and o.name.startswith('Terrain_0'):
        offset=len(ground_vertices)
        ground_vertices.extend(o.matrix_world@v.co for v in o.data.vertices)
        ground_faces.extend(tuple(offset+i for i in p.vertices) for p in o.data.polygons)
ground_surface=BVHTree.FromPolygons(ground_vertices,ground_faces)
views = [('settlement', (-8,-7,5), (31,-42,29), 44),
         ('bridge', (15,-10,5), (18,-24,15), 23),
         ('house', (-7,2,6), (10,-14,8), 12)]

def render_views(suffix, samples=48):
    scene.cycles.samples = samples
    scene.cycles.use_denoising = True
    scene.render.resolution_x, scene.render.resolution_y = 1600, 1100
    scene.render.resolution_percentage = 100
    for label, target, offset, scale in views:
        scene.camera.location = Vector(target) + Vector(offset)
        scene.camera.rotation_euler = (Vector(target)-scene.camera.location).to_track_quat('-Z','Y').to_euler()
        scene.camera.data.type = 'ORTHO'
        scene.camera.data.ortho_scale = scale
        scene.render.filepath = str(ART / (label+'_'+suffix+'.png'))
        bpy.ops.render.render(write_still=True)

if '--skip-before' not in sys.argv:
    render_views('before_v08', 24)

def material(name, dark, light, scale, roughness, bump_distance):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    n, l = m.node_tree.nodes, m.node_tree.links
    bs = n.get('Principled BSDF')
    bs.inputs['Roughness'].default_value = roughness
    tex = n.new('ShaderNodeTexCoord')
    stretch = n.new('ShaderNodeVectorMath'); stretch.operation = 'MULTIPLY'
    stretch.inputs[1].default_value = scale
    l.new(tex.outputs['Generated'], stretch.inputs[0])
    noise = n.new('ShaderNodeTexNoise'); noise.inputs['Scale'].default_value = 5
    noise.inputs['Detail'].default_value = 4
    l.new(stretch.outputs[0], noise.inputs['Vector'])
    ramp = n.new('ShaderNodeValToRGB')
    ramp.color_ramp.elements[0].position = .18
    ramp.color_ramp.elements[0].color = (*dark,1)
    ramp.color_ramp.elements[1].position = .82
    ramp.color_ramp.elements[1].color = (*light,1)
    l.new(noise.outputs['Fac'], ramp.inputs[0]); l.new(ramp.outputs[0],bs.inputs['Base Color'])
    bump = n.new('ShaderNodeBump'); bump.inputs['Strength'].default_value = .35
    bump.inputs['Distance'].default_value = bump_distance
    l.new(noise.outputs['Fac'],bump.inputs['Height']); l.new(bump.outputs['Normal'],bs.inputs['Normal'])
    m.diffuse_color=(*light,1)
    return m

wood = material('V08_Weathered_Timber',(.055,.033,.017),(.24,.16,.085),(7,7,.3),.82,.018)
deck_wood = wood.copy(); deck_wood.name = 'V08_Deck_Long_Grain'
next(n for n in deck_wood.node_tree.nodes if n.type=='VECT_MATH').inputs[1].default_value=(7,.3,7)
plaster = material('V08_Straw_Earth_Plaster',(.22,.15,.085),(.52,.40,.25),(2,2,2),.95,.035)
stone = material('V08_Rough_Footing',(.10,.105,.09),(.30,.28,.23),(2,2,2),.9,.035)
reed = material('V08_Reed_Thatch',(.14,.10,.035),(.40,.30,.115),(9,.3,3),.92,.022)
rope = material('V08_Hemp_Lashing',(.18,.11,.045),(.44,.32,.15),(3,3,3),.9,.008)
reeds = [reed]
for i,factor in enumerate((.75,.9,1.08,1.2)):
    m=reed.copy(); m.name='V08_Reed_Variation_'+str(i)
    for e in next(n for n in m.node_tree.nodes if n.type=='VALTORGB').color_ramp.elements:
        e.color=tuple(c*factor for c in e.color[:3])+(1,)
    reeds.append(m)

def mesh(name, verts, faces, mat, collection):
    data=bpy.data.meshes.new(name); data.from_pydata(verts,[],faces); data.update()
    obj=bpy.data.objects.new(name,data); collection.objects.link(obj); data.materials.append(mat)
    return obj

def box(name, center, size, mat, collection, bevel=.025):
    x,y,z=(s/2 for s in size)
    obj=mesh(name,[(-x,-y,-z),(-x,-y,z),(-x,y,-z),(-x,y,z),(x,-y,-z),(x,-y,z),(x,y,-z),(x,y,z)],
             [(0,4,6,2),(1,3,7,5),(0,1,5,4),(2,6,7,3),(0,2,3,1),(4,5,7,6)],mat,collection)
    obj.location=center
    if bevel:
        mod=obj.modifiers.new('Worn_Edges','BEVEL');mod.width=bevel;mod.segments=2
        mod=obj.modifiers.new('Face_Normals','WEIGHTED_NORMAL')
    return obj

def beam(name, a, b, width, mat, collection):
    a,b=Vector(a),Vector(b)
    obj=box(name,(a+b)/2,(width,width,(b-a).length),mat,collection,min(.02,width*.12))
    obj.rotation_euler=(b-a).to_track_quat('Z','Y').to_euler()
    return obj

def cord(name, points, radius, collection):
    curve=bpy.data.curves.new(name,'CURVE');curve.dimensions='3D';curve.bevel_depth=radius;curve.bevel_resolution=2
    spline=curve.splines.new('POLY');spline.points.add(len(points)-1)
    for p,co in zip(spline.points,points):p.co=(*co,1)
    obj=bpy.data.objects.new(name,curve);collection.objects.link(obj);curve.materials.append(rope)
    return obj

def round_bundle(name,a,b,radius,collection):
    a,b=Vector(a),Vector(b)
    verts=[(radius*math.cos(i*math.tau/12),radius*math.sin(i*math.tau/12),z)
           for z in (0,(b-a).length) for i in range(12)]
    faces=[(i,(i+1)%12,(i+1)%12+12,i+12) for i in range(12)]
    faces.extend([tuple(reversed(range(12))),tuple(range(12,24))])
    obj=mesh(name,verts,faces,reed,collection);obj.location=a
    obj.rotation_euler=(b-a).to_track_quat('Z','Y').to_euler()
    return obj

def build_hut(name, open_sides=False):
    col=bpy.data.collections.new(name)
    # Collection remains unlinked: all placements reference one reusable source.
    box('Packed_Floor',(0,0,-.12),(5.7,4.5,.24),plaster,col,.06)
    for side in (-1,1):
        for i in range(9):
            box('Footing_Stone',(i*.64-2.56,side*2.18,-.12+rng.uniform(-.02,.02)),
                (.60,.40,.30),stone,col,.055)
        for i in range(6):
            box('Footing_Stone',(side*2.68,i*.67-1.67,-.12),(.4,.62,.32),stone,col,.045)
    for x in (-2.55,0,2.55):
        for y in (-1.95,1.95):
            if not open_sides and x == 0 and y < 0:
                continue
            beam('Structural_Post',(x,y,-.16),(x,y,2.8),.20,wood,col)
    for y in (-1.95,1.95):
        beam('Eave_Beam',(-2.9,y,2.65),(2.9,y,2.65),.22,wood,col)
    for x in (-2.55,2.55):
        beam('Cross_Beam',(x,-2.25,2.63),(x,2.25,2.63),.20,wood,col)
        beam('King_Post',(x,0,2.6),(x,0,4),.16,wood,col)
        for side in (-1,1):
            beam('Diagonal_Brace',(x,side*1.95,2.05),(x,side*1.25,2.65),.12,wood,col)
    if not open_sides:
        # Front doorway remains a real opening; side windows use separate wall segments.
        for side in (-1,1):
            box('Front_Wall',(side*1.62,-1.98,1.27),(1.84,.24,2.54),plaster,col,.04)
            box('Side_Wall_Lower',(side*2.55,0,.57),(.25,4,1.14),plaster,col,.035)
            box('Side_Wall_Upper',(side*2.55,0,2.28),(.25,4,.52),plaster,col,.035)
            for y in (-1.35,1.35):
                box('Side_Window_Pier',(side*2.55,y,1.58),(.25,1.3,.92),plaster,col,.035)
            for y in (-.55,0,.55):
                beam('Window_Bar',(side*2.55,y,1.12),(side*2.55,y,2.02),.05,wood,col)
            beam('Door_Jamb',(side*.66,-2.12,0),(side*.66,-2.12,2.13),.16,wood,col)
        box('Door_Lintel',(0,-2.05,2.35),(1.45,.28,.4),wood,col)
        box('Rear_Wall',(0,1.98,1.27),(5.1,.24,2.54),plaster,col,.04)
        for x in (-2.55,2.55):
            obj=mesh('Gable_Earth',[(x,-2,2.54),(x,2,2.54),(x,0,3.9)],[(0,1,2)],plaster,col)
            mod=obj.modifiers.new('Wall_Thickness','SOLIDIFY');mod.thickness=.22
        # Slightly open plank door reveals the dark interior and gives useful contact shadows.
        for i in range(6):
            obj=box('Door_Plank',(-.56+i*.18,-1.93,1.0),(.17,.065,1.94),wood,col,.012)
        for z in (.35,1.58):box('Door_Crosspiece',(-.1,-2,z),(1.04,.10,.11),wood,col)
        box('Door_Threshold',(0,-2.27,.06),(1.55,.65,.12),stone,col,.04)
        box('Entrance_Step',(0,-2.65,-.10),(1.75,.48,.16),stone,col,.045)
    for x in (-2.75,-1.38,0,1.38,2.75):
        for side in (-1,1):beam('Roof_Rafter',(x,0,4),(x,side*2.6,2.48),.14,wood,col)
    beam('Ridge_Beam',(-3.03,0,4),(3.03,0,4),.24,wood,col)
    # Thick base roof plus layered reed strips, shared in one mesh rather than thousands of objects.
    for side in (-1,1):
        obj=mesh('Thatch_Mass',[(-3.03,0,4.07),(3.03,0,4.07),(3.03,side*2.64,2.52),(-3.03,side*2.64,2.52)],
                 [(0,1,2,3) if side>0 else (3,2,1,0)],reed,col)
        mod=obj.modifiers.new('Thatch_Thickness','SOLIDIFY');mod.thickness=.20
    verts,faces,indices=[],[],[]
    for side in (-1,1):
        for row in range(7):
            start=row*.37
            for i in range(360):
                x=-3.02+i*.017+rng.uniform(-.004,.004); width=rng.uniform(.012,.020)
                end=min(2.80,start+rng.uniform(.53,.72))
                height=.008+rng.uniform(0,.018)
                coords=[(x,side*start,4.12-.58*start+height),(x+width,side*start,4.12-.58*start+height),
                        (x+width,side*end,4.12-.58*end+height-.025),(x,side*end,4.12-.58*end+height-.025)]
                offset=len(verts);verts.extend(coords)
                faces.append(tuple(offset+j for j in (range(4) if side>0 else reversed(range(4)))))
                indices.append(rng.randrange(len(reeds)))
    obj=mesh('Layered_Reed_Surface',verts,faces,reeds[0],col)
    for m in reeds[1:]:obj.data.materials.append(m)
    for p,index in zip(obj.data.polygons,indices):p.material_index=index
    for x in (-2.5,-1.25,0,1.25,2.5):
        cord('Roof_Tie',[(x,-2.65,2.66),(x,0,4.23),(x,2.65,2.66)],.023,col)
    # A heavy ridge cap covers the joint; no ornate historical roof motifs.
    for i in range(52):
        x=-3+i*.117
        round_bundle('Reed_Ridge_Cap',(x,-.22,4.13),(x,.22,4.13),.085,col)
    col.asset_mark();col.asset_data.description='Reusable ancient northern timber and earthen architecture, meters, origin at floor.'
    return col

hut=build_hut('Ancient_Earth_House')
shelter=build_hut('Ancient_Open_Work_Shelter',True)
placements=bpy.data.collections.new('Settlement_Architecture_v08');scene.collection.children.link(placements)
platforms=sorted([o for o in scene.objects if o.get('module_source')=='House_Platform_600'],key=lambda o:o.name)
assert len(platforms)==4
house_centers=[tuple(o.location) for o in platforms]
for i,platform in enumerate(platforms):
    col=shelter if i==3 else hut
    obj=bpy.data.objects.new(col.name+'_'+str(i+1),None);obj.instance_type='COLLECTION';obj.instance_collection=col
    obj.location=platform.location+Vector((0,0,.3));obj['reusable_asset']=col.name
    placements.objects.link(obj)
    if i<3:
        offsets={'20_Terracotta_Jar':(-2.2,-2.8),'18_Wicker_Basket':(-1.6,-2.85),
                 '19_Firewood_Stack':(3.1,.7),'16_Leather_Flask':(-2.2,-2.4)}
        for prop in list(scene.objects):
            source=prop.get('source_asset','')
            if source in offsets and abs(prop.location.x-platform.location.x)<3 and abs(prop.location.y-platform.location.y)<2.6:
                dx,dy=offsets[source]
                prop.location=(platform.location.x+dx,platform.location.y+dy,platform.location.z+.1)
    for old in list(scene.objects):
        if old.get('module_source')=='Timber_Post_200' and abs(old.location.x-platform.location.x)<3 and abs(old.location.y-platform.location.y)<2.6:
            bpy.data.objects.remove(old,do_unlink=True)
    bpy.data.objects.remove(platform,do_unlink=True)

# Foot traffic exposes earth around doors without modifying the walkable terrain geometry.
for terrain_obj in [o for o in scene.objects if o.type=='MESH' and o.name.startswith('Terrain_0')]:
    colors=terrain_obj.data.color_attributes.get('TerrainColor')
    if not colors:continue
    for v in terrain_obj.data.vertices:
        p=terrain_obj.matrix_world @ v.co
        amount=0
        for cx,cy,cz in house_centers:
            d=math.hypot((p.x-cx)/4.5,(p.y-cy+2)/4)
            amount=max(amount,max(0,min(1,(1.5-d)/.65)))
        if amount:
            old=colors.data[v.index].color
            colors.data[v.index].color=tuple(old[j]*(1-amount*.8)+(.34,.265,.17)[j]*amount*.8 for j in range(3))+(1,)

# Bridge deck endpoint elevations remain identical to the authored crossing.
planks=sorted([o for o in scene.objects if o.get('module_source')=='Timber_Plank_360'],key=lambda o:o.location.x)
assert len(planks)==32
left,right=planks[0].location.copy(),planks[-1].location.copy()
bridge=bpy.data.collections.new('Ancient_Timber_Bridge')
center=Vector(((left.x+right.x)/2,-10,(left.z+right.z)/2))
length=right.x-left.x
slope=(right.z-left.z)/length
def deck(x):return slope*x+.18
for i,p in enumerate(planks):
    x=p.location.x-center.x
    obj=box('Deck_Plank_%02d'%i,(x,0,deck(x)-.09),(.448,3.58+rng.uniform(-.045,.045),.18),deck_wood,bridge,.018)
    for y in (-1.2,1.2):
        # Square hardwood pegs keep the construction appropriate to the setting.
        box('Deck_Peg',(x,y,deck(x)+.002),(.045,.045,.008),wood,bridge,.006)
    bpy.data.objects.remove(p,do_unlink=True)
for old in list(scene.objects):
    if old.get('module_source')=='Timber_Post_200' and 6<old.location.x<24 and -12<old.location.y<-8:
        bpy.data.objects.remove(old,do_unlink=True)
for y in (-1.3,0,1.3):
    beam('Longitudinal_Beam',(-7.75,y,deck(-7.75)-.4),(7.75,y,deck(7.75)-.4),.30,wood,bridge)
support_roots=[]
for x in (-7.3,-3.65,0,3.65,7.3):
    for side in (-1,1):
        y=side*1.58;z=deck(x)
        beam('Rail_Post',(x,y,z-.38),(x,y,z+1.04),.15,wood,bridge)
        for dz in (.44,.88):
            points=[]
            for k in range(41):
                t=k/40;angle=t*math.tau*3
                points.append((x+.115*math.cos(angle),y+.115*math.sin(angle),z+dz+t*.09))
            cord('Hemp_Joint',points,.014,bridge)
    if abs(x)<7:
        bottoms=[]
        for y in (-1.25,1.25):
            hit,_,_,_=ground_surface.ray_cast(Vector((center.x+x,center.y+y,150)),Vector((0,0,-1)))
            assert hit is not None
            bottom=hit.z-center.z-.35;bottoms.append(bottom)
            beam('Support_Pile',(x,y,bottom),(x,y,deck(x)-.26),.25,wood,bridge)
            support_roots.append([center.x+x,center.y+y,hit.z-.35])
        beam('Pier_Brace',(x,-1.25,bottoms[0]+.6),(x,1.25,deck(x)-.38),.16,wood,bridge)
for side in (-1,1):
    for dz in (.5,.96):
        beam('Handrail',(-7.4,side*1.58,deck(-7.4)+dz),(7.4,side*1.58,deck(7.4)+dz),.105,wood,bridge)
obj=bpy.data.objects.new('Ancient_Timber_Bridge_Placed',None);obj.instance_type='COLLECTION';obj.instance_collection=bridge
obj.location=center;placements.objects.link(obj);bridge.asset_mark()

# Collection libraries avoid Blender 5.2's partial-write crash on newly created scenes.
for col in (hut,shelter,bridge):
    bpy.data.libraries.write(str(LIB/(col.name+'_library.blend')),{col},fake_user=True,compress=True)

# A directional sun plus atmospheric sky gives cool fill and broad water reflections.
world=scene.world.copy();world.name='V08_Clear_Afternoon_Sky';scene.world=world
n,l=world.node_tree.nodes,world.node_tree.links
bg=n.get('Background')
sky=n.new('ShaderNodeTexSky');sky.sky_type='MULTIPLE_SCATTERING';sky.sun_disc=False
sky.sun_elevation=math.radians(31);sky.sun_rotation=math.radians(130);sky.altitude=.2;sky.air_density=1;sky.aerosol_density=.6
sky_color=n.new('ShaderNodeHueSaturation');sky_color.inputs['Saturation'].default_value=.45
l.new(sky.outputs['Color'],sky_color.inputs['Color']);l.new(sky_color.outputs['Color'],bg.inputs[0])
bg.inputs[1].default_value=.075
sun=bpy.data.objects['Sun'];sun.data.energy=2.4;sun.data.color=(1,.89,.74);sun.data.angle=math.radians(2.5)
sun.rotation_euler=(math.radians(59),0,math.radians(130))
scene.view_settings.exposure=.35
scene.view_settings.look='AgX - Medium High Contrast'
scene.cycles.max_bounces=8
water=bpy.data.objects['Water_Creek'].data.materials[0]
bs=water.node_tree.nodes.get('Principled BSDF');bs.inputs['Base Color'].default_value=(.025,.07,.062,1)
bs.inputs['Roughness'].default_value=.12

render_views('v08',64)
# Save in an intentional inspection camera instead of the map-wide survey view.
label,target,offset,scale=views[0]
scene.camera.location=Vector(target)+Vector(offset)
scene.camera.rotation_euler=(Vector(target)-scene.camera.location).to_track_quat('-Z','Y').to_euler()
scene.camera.data.ortho_scale=scale
scene.render.filepath=str(ART/'settlement_v08.png')
bpy.ops.wm.save_as_mainfile(filepath=str(ART/'prologue_terrain_v08.blend'))
assert terrain_hashes()==terrain_before
assert hashlib.sha256(SOURCE.read_bytes()).hexdigest()==source_hash
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==h for p,h in linked_hashes.items())
report={'source_v07_sha256':source_hash,'linked_sources_unchanged':len(linked_hashes),
        'terrain_hashes':terrain_before,'architecture_instances':len(placements.objects),
        'independent_assets':[c.name for c in (hut,shelter,bridge)],
        'bridge_endpoints_blender':[list(left),list(right)],'bridge_clear_width_m':3.0,
        'bridge_support_roots':support_roots,
        'limitations':'Blender-only visual iteration. Materials procedural, not yet baked. No Godot collision/navigation/performance verification.'}
(ROOT/'assets/prologue_terrain/polish_v08.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print('V08_POLISH_OK',json.dumps(report))
