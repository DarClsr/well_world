"""Refine the Blender blockout using shared, separately exportable modules."""
import json
import math
import random
from pathlib import Path

import bpy
from mathutils import Vector
from mathutils.bvhtree import BVHTree

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'art/prologue_terrain'
OUT = ROOT / 'assets/prologue_terrain'
MODULES = OUT / 'modules'
MODULES.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(ART / 'prologue_terrain.blend'))
scene = bpy.context.scene
scene.name = 'Prologue_Map_Modular_v02'
library = bpy.data.scenes.new('Reusable_Module_Library')
placed = bpy.data.collections.new('Reusable_Module_Instances')
scene.collection.children.link(placed)
terrain = [o for o in scene.objects if o.name.startswith('Terrain_0') and o.type == 'MESH']

# Widen the northern channel banks without changing the shared border positions.
for obj in terrain:
    for v in obj.data.vertices:
        x, z = v.co.x, -v.co.y
        cx = 11 + 5 * math.sin(z / 22) + 2 * math.sin(z / 9)
        d = abs(x - cx)
        if z < -25 and d < 15:
            t = max(0.0, min(1.0, (d - 2) / 13))
            factor = t * t * (3 - 2 * t)
            wh = .6 + .022 * (80 - z)
            v.co.z = min(v.co.z, wh - .65 + factor * 16)
        plateau = math.hypot((x + 60) / 11, (z + 45) / 9)
        t = max(0.0, min(1.0, (plateau - .8) / .6))
        blend = t * t * (3 - 2 * t)
        v.co.z = 20 * (1 - blend) + v.co.z * blend
    obj.data.update()

verts, faces = [], []
for obj in terrain:
    offset = len(verts)
    verts.extend([obj.matrix_world @ v.co for v in obj.data.vertices])
    faces.extend([tuple(offset + i for i in p.vertices) for p in obj.data.polygons])
surface = BVHTree.FromPolygons(verts, faces)


def ground(x, z):
    hit = surface.ray_cast(Vector((x, -z, 150)), Vector((0, 0, -1)))[0]
    assert hit is not None, (x, z)
    return hit.z


def mat(name, color):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    m.use_nodes = True
    shader = m.node_tree.nodes.get('Principled BSDF')
    shader.inputs['Base Color'].default_value = (*color, 1)
    shader.inputs['Roughness'].default_value = .9
    return m


stone = mat('Module_Stone', (.31, .33, .32))
wood = mat('Module_Timber', (.25, .19, .12))
earth = mat('Module_PackedEarth', (.39, .32, .23))
prototypes = {}


def module(name, size, material, rock=False):
    if rock:
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1)
        obj = bpy.context.object
        rng = random.Random(name)
        for v in obj.data.vertices:
            v.co *= rng.uniform(.82, 1.12)
    else:
        bpy.ops.mesh.primitive_cube_add(size=1)
        obj = bpy.context.object
    obj.name = name
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bottom = min(v.co.z for v in obj.data.vertices)
    for v in obj.data.vertices:
        v.co.z -= bottom
    obj.data.materials.append(material)
    if not rock:
        bevel = obj.modifiers.new('Soft_Edges', 'BEVEL')
        bevel.width = min(size) * .075
        bevel.segments = 2
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=bevel.name)
    obj.asset_mark()
    obj.asset_data.description = 'Prologue reusable blockout module. Meters; origin at bottom center.'
    for c in list(obj.users_collection):
        c.objects.unlink(obj)
    library.collection.objects.link(obj)
    prototypes[name] = obj
    return obj


module('Stone_Block_150', (1.5, .7, .55), stone)
module('Wall_Section_300', (3, .7, 1.65), stone)
module('Stone_Step_200', (2, .6, .18), stone)
module('Timber_Plank_360', (.48, 3.6, .18), wood)
module('Timber_Post_200', (.22, .22, 2), wood)
module('House_Platform_600', (6, 5, .3), earth)
module('Boulder_A', (3.4, 2.4, 2), stone, True)
module('Boulder_B', (2.1, 1.7, 1.15), stone, True)
usage = {name: 0 for name in prototypes}


def instance(name, x, z, h=None, yaw=0, scale=1):
    source = prototypes[name]
    obj = bpy.data.objects.new(name + '_Instance', source.data)
    placed.objects.link(obj)
    obj.location = (x, -z, ground(x, z) if h is None else h)
    obj.rotation_euler.z = yaw
    obj.scale = (scale, scale, scale)
    usage[name] += 1
    obj['module_source'] = name
    return obj


for obj in list(scene.objects):
    if obj.name.startswith(('Ruin_Wall', 'Settlement_Footprint', 'Crossing_Deck')):
        bpy.data.objects.remove(obj, do_unlink=True)
for x in (-64.5, -61.5, -58.5, -55.5):
    instance('Wall_Section_300', x, -49, 20.35)
for z in (-47, -44, -41):
    instance('Wall_Section_300', -66, z, 20.35, math.pi / 2)
for x in (-64, -61, -57):
    instance('Stone_Block_150', x, -49, 22)
for x, z in [(-18, 0), (-7, -2), (-19, 17), (-3, 20)]:
    top = max(ground(x + dx, z + dz) for dx in (-3, 3) for dz in (-2.5, 2.5))
    instance('House_Platform_600', x, z, top - .1)
    for dx, dz in [(-2.6, -2.1), (2.6, -2.1), (-2.6, 2.1), (2.6, 2.1)]:
        instance('Timber_Post_200', x + dx, z + dz, top + .2)
for i in range(3):
    instance('Stone_Step_200', -60, -39.8 + i * .55, 20.20 - i * .13)

# One ordinary crossing; the former submerged downstream deck becomes a gap site.
crossing_z = 10
center = 11 + 5 * math.sin(crossing_z / 22) + 2 * math.sin(crossing_z / 9)
left, right = center - 7.5, center + 7.5
lh, rh = ground(left, crossing_z), ground(right, crossing_z)
for i in range(32):
    t = i / 31
    instance('Timber_Plank_360', left + 15 * t, crossing_z, lh + (rh - lh) * t - .08)
for x in (left, right):
    for z in (8.5, 11.5):
        instance('Timber_Post_200', x, z, ground(x, crossing_z) - .7)
for x, z in [(5, 43), (20, 43)]:
    instance('Stone_Step_200', x, z, yaw=math.pi / 2)

rng = random.Random(709)
for i in range(54):
    z = rng.uniform(-68, 72)
    center = 11 + 5 * math.sin(z / 22) + 2 * math.sin(z / 9)
    x = center + rng.choice((-1, 1)) * rng.uniform(4.4, 7.3)
    if abs(z - 10) > 5:
        instance('Boulder_A' if i % 3 == 0 else 'Boulder_B', x, z, h=ground(x, z) - .3,
                 yaw=rng.uniform(0, 6.28), scale=rng.uniform(.6, 1.15))
for x, z in [(-75, -51), (-70, -38), (-49, -53), (-72, -22), (67, -49), (72, -40), (43, -47), (73, -20)]:
    instance('Boulder_A', x, z, h=ground(x, z) - .4, yaw=rng.uniform(0, 6.28), scale=1.7)

# Export prototypes at their origin; linked duplicates in the map share these meshes.
bpy.context.window.scene = library
for source in prototypes.values():
    bpy.ops.object.select_all(action='DESELECT')
    source.select_set(True)
    bpy.context.view_layer.objects.active = source
    bpy.ops.export_scene.gltf(filepath=str(MODULES / (source.name + '.glb')), export_format='GLB', use_selection=True)
for i, source in enumerate(prototypes.values()):
    source.location = ((i % 4) * 8, (i // 4) * 8, 0)
bpy.data.libraries.write(str(ART / 'prologue_module_library.blend'), {library})
bpy.context.window.scene = scene
for obj in placed.objects:
    assert obj.data is prototypes[obj['module_source']].data
assert all(count > 0 for count in usage.values()), usage
bpy.ops.object.select_all(action='DESELECT')
for obj in scene.objects:
    if obj.type == 'MESH':
        obj.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(OUT / 'prologue_terrain_v02.glb'), export_format='GLB', use_selection=True)
report = {'module_instances': usage, 'shared_mesh_check': 'passed', 'modules': len(prototypes),
          'terrain_sections': len(terrain), 'stage': 'Blender modular blockout; Godot pending'}
(OUT / 'module_manifest.json').write_text(json.dumps(report, indent=2), encoding='utf-8')

camera = scene.camera
camera.data.ortho_scale = 285
scene.render.filepath = str(ART / 'blender_overview_v02.png')
scene.cycles.samples = 24
scene.render.resolution_percentage = 100
# Open the saved file in a useful camera view.
for screen in bpy.data.screens:
    for area in screen.areas:
        if area.type == 'VIEW_3D':
            area.spaces.active.region_3d.view_perspective = 'CAMERA'
bpy.ops.wm.save_as_mainfile(filepath=str(ART / 'prologue_terrain_v02.blend'))
bpy.ops.render.render(write_still=True)
camera.location = (-26, 8, 49)
camera.rotation_euler = (Vector((-60, 45, 20)) - camera.location).to_track_quat('-Z', 'Y').to_euler()
camera.data.ortho_scale = 33
scene.render.filepath = str(ART / 'blender_ruins_v02.png')
bpy.ops.render.render(write_still=True)
print('MODULAR_BUILD_OK', json.dumps(report))
