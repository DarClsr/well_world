"""Expand gaps between landmarks while retaining reusable asset dimensions."""
import hashlib
import json
import math
import random
from pathlib import Path

import bpy
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'art/prologue_terrain'
OUT = ROOT / 'assets/prologue_terrain'
SOURCE = ART / 'prologue_terrain_v05.blend'
source_hash = hashlib.sha256(SOURCE.read_bytes()).hexdigest()
bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
scene = bpy.context.scene
scene.name = 'Prologue_Expanded_v06'
rng = random.Random(906)


def remap(value, old, new):
    return float(np.interp(value, old, new))


def expand(x, z):
    return (remap(x, [-90, -72, -48, -26, 26, 44, 70, 90],
                     [-160, -132, -108, -26, 26, 114, 140, 160]),
            remap(z, [-80, -57, -20, -10, 30, 55, 80],
                     [-140, -107, -70, -10, 30, 90, 140]))


old_routes = json.loads((OUT / 'terrain_manifest.json').read_text())['route_points']
# Sample before warping so bend points at expansion boundaries are retained.
routes = []
for route in old_routes:
    points = []
    for a, b in zip(route, route[1:]):
        count = math.ceil(math.hypot(b[0]-a[0], b[2]-a[2]))
        for i in range(count):
            t = i / count
            points.append(expand(a[0]*(1-t)+b[0]*t, a[2]*(1-t)+b[2]*t))
    points.append(expand(route[-1][0], route[-1][2]))
    routes.append(points)
branches = [[expand(-58.5, -17.5), (-137, -43), (-146, -61), (-143, -79)],
            [(127, -85), (146, -64), (143, -38), (121, -20), (95, -5), expand(38, 8)],
            [expand(-50,-3), (-91,-18), (-77,-29)]]
main_segments = [(a, b) for r in routes for a, b in zip(r, r[1:])]


def distances(xs, zs, segments):
    result = np.full(len(xs), 1e6)
    for (ax, az), (bx, bz) in segments:
        dx, dz = bx-ax, bz-az
        t = np.clip(((xs-ax)*dx+(zs-az)*dz)/max(dx*dx+dz*dz, 1e-9), 0, 1)
        result = np.minimum(result, np.hypot(xs-ax-t*dx, zs-az-t*dz))
    return result


terrain = [o for o in scene.objects if o.type == 'MESH' and o.name.startswith('Terrain_0')]
original_transforms = {o.name: (tuple(o.scale), tuple(o.rotation_euler)) for o in scene.objects
                       if o.instance_type == 'COLLECTION'}
for obj in list(scene.objects):
    if obj.type == 'MESH' and (obj.name.startswith('Terrain_') or obj.name == 'Water_Creek'):
        for v in obj.data.vertices:
            p = obj.matrix_world @ v.co
            x, z = expand(p.x, -p.y)
            v.co = obj.matrix_world.inverted() @ Vector((x, -z, p.z))
        obj.data.update()
    elif obj.type not in ('CAMERA', 'LIGHT'):
        old_x, old_z = obj.location.x, -obj.location.y
        x, z = expand(old_x, old_z)
        if abs(old_x-29) < 6 and abs(old_z-42) < 6:
            cx, cz = expand(29,42)
            x, z = cx+old_x-29, cz+old_z-42
        obj.location.x, obj.location.y = x, -z

# The broad ridge occupies newly opened space and tapers away from existing paths.
for obj in terrain:
    xs = np.array([v.co.x for v in obj.data.vertices])
    zs = np.array([-v.co.y for v in obj.data.vertices])
    d = distances(xs, zs, main_segments)
    ridge = 11*np.exp(-((xs+88)/17)**2-((zs+48)/39)**2)
    ridge += 8*np.exp(-((xs-92)/16)**2-((zs+57)/30)**2)
    ridge *= np.clip((d-6)/12, 0, 1)
    colors = obj.data.color_attributes.get('TerrainColor')
    for i, v in enumerate(obj.data.vertices):
        v.co.z += float(ridge[i])
        if colors:
            variation = .012*math.sin(xs[i]*.43)*math.cos(zs[i]*.31)
            blend = max(0,min(1,(2.5-d[i])/1.1))
            colors.data[i].color = tuple(c*(1-blend)+p*blend+variation
                for c,p in zip((.245,.31,.17),(.43,.36,.25)))+(1,)
    obj.data.update()


def surface_tree():
    vertices, faces = [], []
    for obj in terrain:
        offset = len(vertices)
        vertices.extend([obj.matrix_world @ v.co for v in obj.data.vertices])
        faces.extend([tuple(offset+i for i in p.vertices) for p in obj.data.polygons])
    return BVHTree.FromPolygons(vertices, faces)


surface = surface_tree()
def ground(x, z):
    hit, normal, _, _ = surface.ray_cast(Vector((x, -z, 150)), Vector((0, 0, -1)))
    assert hit is not None, (x, z)
    return hit.z, normal.z


branch_heights = [[ground(x, z)[0] for x, z in r] for r in branches]
ramp_end = ground(-120,-70)[0]
sites = [
    {'id':'Hidden_Ruin','xz':[-143,-79],'radius':5,'purpose':'Optional old shrine and lore clue'},
    {'id':'Forest_Rest','xz':[-77,-29],'radius':5,'purpose':'Abandoned rest camp and gathering pocket'},
    {'id':'Beast_Clearing','xz':[143,-38],'radius':8,'purpose':'Reserved optional beast encounter clearing'},
    {'id':'Ridge_Forage','xz':[146,-64],'radius':4,'purpose':'Rare flora observation along east detour'},
]
for site in sites:
    site['height'] = ground(*site['xz'])[0]
for obj in terrain:
    colors = obj.data.color_attributes.get('TerrainColor')
    for i, v in enumerate(obj.data.vertices):
        x, z = v.co.x, -v.co.y
        nearest, target = 1e6, v.co.z
        for route, heights in zip(branches, branch_heights):
            for k, ((ax, az), (bx, bz)) in enumerate(zip(route, route[1:])):
                dx, dz = bx-ax, bz-az
                t = max(0, min(1, ((x-ax)*dx+(z-az)*dz)/(dx*dx+dz*dz)))
                distance = math.hypot(x-ax-t*dx, z-az-t*dz)
                if distance < nearest:
                    nearest, target = distance, heights[k]*(1-t)+heights[k+1]*t
        blend = max(0, min(1, (5-nearest)/3))
        v.co.z = v.co.z*(1-blend)+target*blend
        if colors and nearest < 2:
            colors.data[i].color = (.38, .32, .23, 1)
        for site in sites:
            distance = math.hypot(x-site['xz'][0],z-site['xz'][1])
            blend = max(0,min(1,(site['radius']+8-distance)/8))
            v.co.z = v.co.z*(1-blend)+site['height']*blend
        if -93 <= z <= -70 and abs(x+120) < 6:
            t=(z+93)/23
            blend=max(0,min(1,(6-abs(x+120))/3))
            v.co.z=v.co.z*(1-blend)+(20*(1-t)+ramp_end*t)*blend
    obj.data.update()
surface = surface_tree()

# Terrain moved under natural props; retain source scale and sink offsets approximately.
for obj in scene.objects:
    name = obj.get('source_asset', '')
    if name and name not in ('14_Rolled_Bedroll', '16_Leather_Flask', '18_Wicker_Basket',
                            '19_Firewood_Stack', '20_Terracotta_Jar'):
        obj.location.z = ground(obj.location.x, -obj.location.y)[0] - .025
        for site in sites:
            if math.hypot(obj.location.x-site['xz'][0], -obj.location.y-site['xz'][1]) < site['radius']+2:
                obj.location.x = site['xz'][0]+site['radius']+3
                obj.location.z = ground(obj.location.x,-obj.location.y)[0]-.025

group = bpy.data.collections.new('Expanded_Wilderness_Existing_Assets')
scene.collection.children.link(group)
segments = main_segments + [(a,b) for r in branches for a,b in zip(r,r[1:])]
added = []
for i in range(1700):
    x, z = rng.uniform(-153,153), rng.uniform(-131,131)
    # Concentrate on the two new transition corridors, not the established buildings.
    if not (-107 < x < -34 or 37 < x < 110):
        continue
    if distances(np.array([x]), np.array([z]), segments)[0] < 5.5:
        continue
    if any(math.hypot(x-s['xz'][0],z-s['xz'][1]) < s['radius']+3 for s in sites):
        continue
    h, normal_z = ground(x,z)
    if normal_z < .84:
        continue
    name = rng.choice(['01_Elder_Sage','02_Silver_Spire','04_Windward_Tree',
                       '01_Fern_Spread','02_Fern_Fiddlehead','08_MossRock_Broad','10_MossRock_Pebbles'])
    obj = bpy.data.objects.new('Expansion_' + name, None)
    obj.instance_type = 'COLLECTION'
    obj.instance_collection = bpy.data.collections['Source_'+name]
    obj.location = (x,-z,h-.025)
    size = rng.uniform(.65,1.15)
    obj.scale = (size,)*3
    obj.rotation_euler.z = rng.uniform(0, math.tau)
    obj['expansion_source'] = name
    group.objects.link(obj)
    added.append({'source':name,'position_blender':list(obj.location),'scale':size,'yaw':obj.rotation_euler.z})

poi_group = bpy.data.collections.new('Exploration_Pockets_v06')
scene.collection.children.link(poi_group)
bundles = [
    [('Ruins_02_Wall_Broken_300',-2,-3),('Ruins_07_Book_Niche',0,-3),
     ('Ruins_08_Rubble_Cluster',3,-2),('08_MossRock_Broad',-3,1),('01_Fern_Spread',2,2)],
    [('14_Rolled_Bedroll',-1,0),('18_Wicker_Basket',1,0),('20_Terracotta_Jar',1,1),
     ('19_Firewood_Stack',-2,1),('12_Hollow_Log',-3,-2),('03_Mushrooms_Russet',2,-2)],
    [('08_MossRock_Broad',-7,-3),('09_MossRock_Split',6,-4),('12_Hollow_Log',5,5),
     ('11_Fallen_Branch',-5,5),('02_Fern_Fiddlehead',-7,2)],
    [('01_Fern_Spread',-2,0),('02_Fern_Fiddlehead',0,1),('03_Mushrooms_Russet',1,-1),
     ('10_MossRock_Pebbles',2,2)],
]
for site, bundle in zip(sites,bundles):
    for name, dx, dz in bundle:
        x,z = site['xz'][0]+dx, site['xz'][1]+dz
        obj = bpy.data.objects.new(site['id']+'_'+name,None)
        obj.instance_type = 'COLLECTION'
        obj.instance_collection = bpy.data.collections['Source_'+name]
        obj.location = (x,-z,ground(x,z)[0])
        obj['content_site'] = site['id']
        obj['reused_source'] = name
        poi_group.objects.link(obj)

# Assemble a small rest shelter from the already-authored shared timber modules.
camp=sites[1]
for name,dx,dz,up in [('Timber_Post_200',x,z,0) for x in (-1.5,1.5) for z in (-1.3,1.3)] + [
        ('Timber_Plank_360',x,0,2.0) for x in (-1.2,-.72,-.24,.24,.72,1.2)]:
    obj=bpy.data.objects.new('Forest_Rest_'+name,bpy.data.objects[name].data)
    obj.location=(camp['xz'][0]+dx,-camp['xz'][1]-dz,camp['height']+up)
    obj['content_site']='Forest_Rest'
    obj['reused_source']=name
    poi_group.objects.link(obj)

for name, (scale, rotation) in original_transforms.items():
    assert tuple(scene.objects[name].scale) == scale
    assert tuple(scene.objects[name].rotation_euler) == rotation
for lib in bpy.data.libraries:
    assert Path(bpy.path.abspath(lib.filepath)).is_file()
    lib.filepath = bpy.path.relpath(lib.filepath, start=str(ART))
lengths = [sum(math.dist(a,b) for a,b in zip(r,r[1:])) for r in routes+branches]
report = {'bounds_m':[320,280], 'routes_godot_xz':routes+branches,
          'route_lengths_m':lengths, 'added_instances':added,
          'content_sites':sites,'content_prop_count':len(poi_group.objects),
          'old_instance_count':len(original_transforms), 'source_v05_sha256':source_hash,
          'stage':'Expanded Blender draft; Godot navigation/collision not validated'}
(OUT/'expansion_v06.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
camera = scene.camera
camera.location = (255,-335,285)
camera.rotation_euler = (Vector((0,0,5))-camera.location).to_track_quat('-Z','Y').to_euler()
camera.data.ortho_scale = 455
scene.render.resolution_x, scene.render.resolution_y = 1700,1300
scene.cycles.samples = 24
scene.render.filepath = str(ART/'expanded_overview_v06.png')
bpy.ops.wm.save_as_mainfile(filepath=str(ART/'prologue_terrain_v06.blend'))
bpy.ops.render.render(write_still=True)
camera.location = (0,0,400)
camera.rotation_euler = (0,0,0)
camera.data.ortho_scale = 370
scene.render.resolution_x, scene.render.resolution_y = 1600,1500
scene.render.filepath = str(ART/'expanded_top_v06.png')
bpy.ops.render.render(write_still=True)
assert hashlib.sha256(SOURCE.read_bytes()).hexdigest() == source_hash
print('EXPANSION_OK', json.dumps({'bounds':[320,280],'route_lengths':lengths,'added':len(added)}))
