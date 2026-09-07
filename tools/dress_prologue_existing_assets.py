"""Dress v02 with linked collections from the existing independent asset files."""
import hashlib
import json
import math
import random
from pathlib import Path

import bpy
from mathutils import Vector, noise
from mathutils.bvhtree import BVHTree

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'art/prologue_terrain'
OUT = ROOT / 'assets/prologue_terrain'
bpy.ops.wm.open_mainfile(filepath=str(ART / 'prologue_terrain_v02.blend'))
scene = bpy.context.scene
scene.name = 'Prologue_Existing_Assets_v03'
rng = random.Random(20260908)
terrain = [o for o in scene.objects if o.type == 'MESH' and o.name.startswith('Terrain_0')]
vertices, faces = [], []
for obj in terrain:
    start = len(vertices)
    vertices.extend([obj.matrix_world @ v.co for v in obj.data.vertices])
    faces.extend([tuple(start + i for i in p.vertices) for p in obj.data.polygons])
surface = BVHTree.FromPolygons(vertices, faces)
routes = json.loads((OUT / 'terrain_manifest.json').read_text())['route_points']
segments = [(a, b) for route in routes for a, b in zip(route, route[1:])]
groups = {}
for name in ('Trees_Existing', 'Understory_Existing', 'Stone_And_Deadwood_Existing', 'Settlement_Props_Existing'):
    col = bpy.data.collections.new(name)
    scene.collection.children.link(col)
    groups[name] = col


def ground(x, z):
    hit, normal, _, _ = surface.ray_cast(Vector((x, -z, 130)), Vector((0, 0, -1)))
    assert hit is not None, (x, z)
    return hit.z, normal


def road_distance(x, z):
    best = 999.0
    for a, b in segments:
        dx, dz = b[0] - a[0], b[2] - a[2]
        t = max(0, min(1, ((x - a[0]) * dx + (z - a[2]) * dz) / (dx * dx + dz * dz)))
        best = min(best, math.hypot(x - a[0] - t * dx, z - a[2] - t * dz))
    return best


def allowed(x, z, clearance=3):
    if not (-84 < x < 84 and -73 < z < 73):
        return False
    if road_distance(x, z) < clearance:
        return False
    if abs(x + 60) < 11 and abs(z + 45) < 10:
        return False
    if math.hypot(x - 57, z + 35) < 13:
        return False
    if -25 < x < 2 and -7 < z < 27:
        return False
    if abs(x - 29) < 5 and abs(z - 42) < 5:
        return False
    cx = 11 + 5 * math.sin(z / 22) + 2 * math.sin(z / 9)
    if abs(x - cx) < 4.4:
        return False
    return ground(x, z)[1].z > .83


sources = {}
placements = []


def source(name, tree=False):
    folder = 'fantasy_trees' if tree else 'fantasy_props'
    path = ROOT / 'art' / folder / 'individual' / (name + '.blend')
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    # Link the original datablocks; no geometry/texture copy is manufactured.
    with bpy.data.libraries.load(str(path), link=True) as (available, loaded):
        loaded.objects = available.objects
    collection = bpy.data.collections.new('Source_' + name)
    for obj in loaded.objects:
        assert obj.type in ('MESH', 'EMPTY'), (name, obj.name)
        collection.objects.link(obj)
    collection.asset_mark()
    collection.asset_data.description = 'Linked from existing independently authored asset: ' + name
    sources[name] = {'collection': collection, 'path': path, 'sha256': digest, 'folder': folder}


tree_names = ['01_Elder_Sage', '02_Silver_Spire', '04_Windward_Tree', '05_Amber_Sapling']
prop_names = ['01_Fern_Spread', '02_Fern_Fiddlehead', '03_Mushrooms_Russet',
              '08_MossRock_Broad', '09_MossRock_Split', '10_MossRock_Pebbles',
              '11_Fallen_Branch', '12_Hollow_Log', '14_Rolled_Bedroll',
              '16_Leather_Flask', '18_Wicker_Basket', '19_Firewood_Stack', '20_Terracotta_Jar']
for name in tree_names:
    source(name, True)
for name in prop_names:
    source(name)


def place(name, x, z, group, scale=1, yaw=None, height=None, sink=0):
    rotation = rng.uniform(0, math.tau) if yaw is None else yaw
    y = ground(x, z)[0] - sink if height is None else height
    obj = bpy.data.objects.new(name + '_Placed', None)
    obj.instance_type = 'COLLECTION'
    obj.instance_collection = sources[name]['collection']
    obj.location = (x, -z, y)
    obj.rotation_euler.z = rotation
    obj.scale = (scale,) * 3
    obj['source_asset'] = name
    groups[group].objects.link(obj)
    placements.append({'asset': name, 'position': [x, y, z], 'yaw': rotation, 'scale': scale, 'group': group})
    return obj


# Replace the temporary faceted rocks with our existing textured rock models.
for obj in list(bpy.data.collections['Reusable_Module_Instances'].objects):
    if obj.get('module_source') in ('Boulder_A', 'Boulder_B'):
        x, z = obj.location.x, -obj.location.y
        large = obj.get('module_source') == 'Boulder_A'
        name = '09_MossRock_Split' if large else '08_MossRock_Broad'
        place(name, x, z, 'Stone_And_Deadwood_Existing', scale=obj.scale.x * (2.1 if large else 1.25),
              yaw=obj.rotation_euler.z, sink=.12)
        bpy.data.objects.remove(obj, do_unlink=True)

centers = [(-77, -55), (-41, -43), (-77, -13), (-67, 25), (-39, 43),
           (-50, 65), (-3, -39), (33, -57), (75, -56), (76, 2), (51, 43), (46, 65)]
tree_points = []
for cx, cz in centers:
    added = 0
    for _ in range(160):
        x, z = cx + rng.uniform(-15, 15), cz + rng.uniform(-13, 13)
        if not allowed(x, z, 7) or any(math.hypot(x - px, z - pz) < 7 for px, pz in tree_points):
            continue
        kind = rng.choices(tree_names, weights=[3, 3, 4, 1])[0]
        scale = rng.uniform(.82, 1.25)
        place(kind, x, z, 'Trees_Existing', scale=scale, sink=.10)
        tree_points.append((x, z))
        added += 1
        if added == 8:
            break

# Understory follows trees and moist banks; never distribute it as a uniform carpet.
for x, z in tree_points:
    for _ in range(7):
        px, pz = x + rng.uniform(-3.3, 3.3), z + rng.uniform(-3.3, 3.3)
        if allowed(px, pz, 2.8):
            place(rng.choice(['01_Fern_Spread', '02_Fern_Fiddlehead']), px, pz,
                  'Understory_Existing', scale=rng.uniform(.7, 1.25), sink=.035)
    if rng.random() < .32:
        px, pz = x + 1.8, z + 1.2
        if allowed(px, pz):
            place('03_Mushrooms_Russet', px, pz, 'Understory_Existing', scale=rng.uniform(.6, .9))
    if rng.random() < .40:
        px, pz = x - 2.3, z + 2
        if allowed(px, pz):
            place(rng.choice(['11_Fallen_Branch', '12_Hollow_Log']), px, pz,
                  'Stone_And_Deadwood_Existing', scale=rng.uniform(.8, 1.25), sink=.08)
for _ in range(140):
    z = rng.uniform(-67, 69)
    cx = 11 + 5 * math.sin(z / 22) + 2 * math.sin(z / 9)
    x = cx + rng.choice([-1, 1]) * rng.uniform(5, 11)
    if allowed(x, z, 3):
        place(rng.choice(['01_Fern_Spread', '02_Fern_Fiddlehead', '10_MossRock_Pebbles']),
              x, z, 'Understory_Existing', scale=rng.uniform(.75, 1.2), sink=.025)

# Pots, baskets and firewood belong to working spaces around house platforms.
platforms = [o for o in bpy.data.collections['Reusable_Module_Instances'].objects
             if o.get('module_source') == 'House_Platform_600']
for platform in platforms:
    x, z, y = platform.location.x, -platform.location.y, platform.location.z + .3
    for name, dx, dz, angle in [('18_Wicker_Basket', -1.7, 1.25, 0),
                                ('20_Terracotta_Jar', -2.25, .1, .3),
                                ('19_Firewood_Stack', 1.6, -1.6, 0),
                                ('14_Rolled_Bedroll', -.2, -1.6, 1.57),
                                ('16_Leather_Flask', -1.7, -.8, 0)]:
        place(name, x + dx, z + dz, 'Settlement_Props_Existing', height=y, yaw=angle)
for name, x, z in [('18_Wicker_Basket', 28, 42), ('20_Terracotta_Jar', 30, 42),
                    ('19_Firewood_Stack', 30, 43), ('16_Leather_Flask', 28, 43)]:
    shelter = scene.objects['Herb_Shelter_Footprint']
    place(name, x, z, 'Settlement_Props_Existing', height=shelter.location.z + shelter.dimensions.z / 2)
for name, x, z in [('18_Wicker_Basket', -64, -46), ('20_Terracotta_Jar', -64, -44),
                   ('14_Rolled_Bedroll', -62, -47)]:
    place(name, x, z, 'Settlement_Props_Existing', height=20.35)

# Break up the draft's regular sinusoidal color bands without altering the source assets.
for obj in terrain:
    colors = obj.data.color_attributes.get('TerrainColor')
    for i, v in enumerate(obj.data.vertices):
        x, z = v.co.x, -v.co.y
        variation = noise.noise_vector(Vector((x * .12, z * .12, 1.3))).x * .035
        color = (.245 + variation, .31 + variation, .17 + variation)
        blend = max(0, min(1, (2.6 - road_distance(x, z)) / 1.3))
        color = tuple(c * (1 - blend) + p * blend for c, p in zip(color, (.43, .36, .25)))
        cx = 11 + 5 * math.sin(z / 22) + 2 * math.sin(z / 9)
        if abs(x - cx) < 5:
            color = (.28 + variation, .29 + variation, .25 + variation)
        colors.data[i].color = (*color, 1)
    obj.data.update()

counts = {name: sum(p['asset'] == name for p in placements) for name in sources}
assert all(counts.values()), counts
assert all(hashlib.sha256(info['path'].read_bytes()).hexdigest() == info['sha256'] for info in sources.values())
for col in groups.values():
    for obj in col.objects:
        assert obj.instance_collection is sources[obj['source_asset']]['collection']
        assert all(o.library is not None for o in obj.instance_collection.objects)
animated = []
for name, info in sources.items():
    for obj in info['collection'].objects:
        if obj.type == 'MESH' and obj.data.shape_keys and obj.data.shape_keys.animation_data:
            animated.append(name)
            break
report = {'stage': 'Blender dressing preview, not Godot gameplay', 'source_count': len(sources),
          'instance_count': len(placements), 'counts': counts, 'animated_sources': animated,
          'source_hashes_unchanged': True, 'linked_collection_check': 'passed',
          'sources': {name: {'blend': info['path'].relative_to(ROOT).as_posix(),
                             'godot_scene': 'assets/' + info['folder'] + '/' + name + '.tscn',
                             'sha256': info['sha256']} for name, info in sources.items()},
          'placements': placements}
(OUT / 'existing_asset_placements_v03.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
for lib in bpy.data.libraries:
    lib.filepath = bpy.path.relpath(lib.filepath, start=str(ART))
scene.frame_set(20)
scene.render.resolution_x = 1600
scene.render.resolution_y = 1100
scene.cycles.samples = 32
scene.cycles.use_denoising = True
scene.camera.data.ortho_scale = 275
scene.render.filepath = str(ART / 'blender_overview_v03.png')
bpy.ops.wm.save_as_mainfile(filepath=str(ART / 'prologue_terrain_v03.blend'))
bpy.ops.render.render(write_still=True)
camera = scene.camera
for name, target, offset, scale in [
    ('settlement', (-11, -8, 5), (25, -32, 29), 39),
    ('woodland', (-40, -43, 6), (26, -32, 26), 36),
    ('ruins', (-60, 45, 20), (25, -32, 28), 35),
]:
    camera.location = Vector(target) + Vector(offset)
    camera.rotation_euler = (Vector(target) - camera.location).to_track_quat('-Z', 'Y').to_euler()
    camera.data.ortho_scale = scale
    scene.render.filepath = str(ART / ('blender_' + name + '_v03.png'))
    bpy.ops.render.render(write_still=True)
print('EXISTING_ASSETS_OK', json.dumps({k: report[k] for k in ['source_count', 'instance_count', 'counts', 'animated_sources']}))
