"""Weathered reusable ruin kit v2 and an independently saved v05 map."""
import json
import math
import random
import subprocess
from pathlib import Path

import bpy
import numpy as np
from mathutils import Vector
from mathutils.noise import noise_vector

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'art/ruins_modules/v2'
OUT = ROOT / 'assets/ruins_modules/v2'
for path in (ART / 'individual', OUT / 'textures'):
    path.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.name = 'Ruins_Kit_Showcase'
scene.unit_settings.system = 'METRIC'
rng = random.Random(909)


def texture(name, pixels, noncolor=False):
    image = bpy.data.images.new(name, width=512, height=512)
    if noncolor:
        image.colorspace_settings.name = 'Non-Color'
    image.pixels.foreach_set(pixels.astype(np.float32).ravel())
    image.filepath_raw = str(OUT / 'textures' / (name + '.png'))
    image.file_format = 'PNG'
    image.save()
    image.pack()
    return image


# Periodic spectral noise yields tileable maps shared by all eight modules.
nrng = np.random.default_rng(908)
freq = np.fft.fftfreq(512)
radius = np.hypot(freq[:, None], freq[None, :])
spectrum = np.fft.fft2(nrng.normal(size=(512, 512)))
height = np.fft.ifft2(spectrum / np.maximum(radius, .007) ** 1.25).real
height = (height - height.mean()) / height.std()
fine = nrng.normal(size=(512, 512))
rgba = np.ones((512, 512, 4))
for c, base in enumerate((.49, .48, .445)):
    rgba[:, :, c] = np.clip(base + height * .038 + fine * .012, .18, .72)
base_image = texture('Ruins_Stone_BaseColor', rgba)
rough = np.ones_like(rgba)
rough[:, :, :3] = np.clip(.85 + height[:, :, None] * .045, .65, .98)
rough_image = texture('Ruins_Stone_Roughness', rough, True)
dx = (np.roll(height, -1, axis=1) - np.roll(height, 1, axis=1)) * .24
dy = (np.roll(height, -1, axis=0) - np.roll(height, 1, axis=0)) * .24
normals = np.stack((-dx, -dy, np.ones_like(dx)), axis=2)
normals /= np.linalg.norm(normals, axis=2)[:, :, None]
normal = np.ones_like(rgba)
normal[:, :, :3] = normals * .5 + .5
normal_image = texture('Ruins_Stone_Normal', normal, True)


def material(name, tint):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*tint, 1)
    mat.use_nodes = True
    nodes, links = mat.node_tree.nodes, mat.node_tree.links
    bsdf = nodes.get('Principled BSDF')
    for image, input_name in [(base_image, 'Base Color'), (rough_image, 'Roughness')]:
        tex = nodes.new('ShaderNodeTexImage')
        tex.image = image
        links.new(tex.outputs['Color'], bsdf.inputs[input_name])
        if input_name == 'Base Color':
            color = nodes.new('ShaderNodeVertexColor')
            color.layer_name = 'Weathering'
            multiply = nodes.new('ShaderNodeMixRGB')
            multiply.blend_type = 'MULTIPLY'
            multiply.inputs[0].default_value = 1
            links.new(tex.outputs['Color'], multiply.inputs[1])
            links.new(color.outputs['Color'], multiply.inputs[2])
            links.new(multiply.outputs[0], bsdf.inputs[input_name])
    tex = nodes.new('ShaderNodeTexImage')
    tex.image = normal_image
    normal_node = nodes.new('ShaderNodeNormalMap')
    normal_node.inputs['Strength'].default_value = .35
    links.new(tex.outputs['Color'], normal_node.inputs['Color'])
    links.new(normal_node.outputs['Normal'], bsdf.inputs['Normal'])
    return mat


stone = material('Ruins_Weathered_Stone', (.39, .395, .37))
pieces = []
assets = {}


def block(center, size, damage=.06, rotation=0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=center)
    obj = bpy.context.object
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    # Keep each course's lower face level so irregular stone still stacks coherently.
    for v in obj.data.vertices:
        v.co.x += rng.uniform(-damage, damage)
        v.co.y += rng.uniform(-damage, damage)
        if v.co.z > 0:
            v.co.z += rng.uniform(-damage, damage)
    bevel = obj.modifiers.new('Chipped_Edges', 'BEVEL')
    bevel.width = min(size) * rng.uniform(.055, .105)
    bevel.segments = 2
    bpy.ops.object.modifier_apply(modifier=bevel.name)
    obj.rotation_euler.z = rotation
    obj.data.materials.append(stone)
    colors = obj.data.color_attributes.new(name='Weathering', type='FLOAT_COLOR', domain='CORNER')
    shade = rng.uniform(.72, 1.12)
    for loop in obj.data.loops:
        co = obj.data.vertices[loop.vertex_index].co + Vector(center)
        n = noise_vector(co * 2.7).x
        low = max(0, 1 - co.z / .9)
        moss = max(0, n + .15) * low * .55
        colors.data[loop.index].color = (shade * (1 - moss * .45),
                                       shade * (1 - moss * .2),
                                       shade * (1 - moss * .65), 1)
    pieces.append(obj)


def wall(length=3, rows=6, broken=False, along_y=False, origin=(0, 0)):
    for row in range(rows):
        # Staggered joints with continuous, level course spacing.
        boundaries = [-length / 2]
        p = -length / 2 + (.37 if row % 2 else .97)
        while p < length / 2 - .20:
            boundaries.append(p)
            p += rng.uniform(.42, 1.18)
        boundaries.append(length / 2)
        for left, right in zip(boundaries, boundaries[1:]):
            x = (left + right) / 2
            limit = 1 + int(3 * abs(math.sin(x * .85 + .35)))
            if broken and row > limit:
                continue
            offset = rng.uniform(-.02, .02)
            center = (origin[0] + (offset if along_y else x), origin[1] + (x if along_y else offset), row * .34 + .165)
            thickness = rng.uniform(.64, .71)
            size = (thickness, right - left - .025, .35) if along_y else (right - left - .025, thickness, .35)
            block(center, size, .04, rng.uniform(-.015, .015))


def finish(name):
    bpy.ops.object.select_all(action='DESELECT')
    for obj in pieces:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = pieces[0]
    bpy.ops.object.join()
    obj = bpy.context.object
    obj.name = name
    scene.cursor.location = (0, 0, 0)
    bpy.ops.object.origin_set(type='ORIGIN_CURSOR')
    bottom = min(v.co.z for v in obj.data.vertices)
    for vertex in obj.data.vertices:
        vertex.co.z -= bottom
    # UVs preserve world-scale grain without requiring a texture per stone.
    uv = obj.data.uv_layers.new(name='StoneUV')
    for polygon in obj.data.polygons:
        axis = max(range(3), key=lambda a: abs(polygon.normal[a]))
        u, v = [(1, 2), (0, 2), (0, 1)][axis]
        for li in polygon.loop_indices:
            co = obj.data.vertices[obj.data.loops[li].vertex_index].co
            uv.data[li].uv = (co[u] * 1.2, co[v] * 1.2)
    obj.asset_mark()
    obj.asset_data.description = 'Reusable northern mountain ruin module; meters, base-centered origin.'
    assets[name] = obj
    pieces.clear()
    bpy.ops.export_scene.gltf(filepath=str(OUT / (name + '.glb')), export_format='GLB',
                             use_selection=True, export_vertex_color='NAME',
                             export_vertex_color_name='Weathering', export_all_vertex_colors=False)
    bpy.data.libraries.write(str(ART / 'individual' / (name + '.blend')), {obj}, fake_user=True)
    obj.select_set(False)


wall()
finish('01_Wall_Intact_300')
wall(broken=True)
finish('02_Wall_Broken_300')
wall(length=1.8, rows=5, origin=(.55, -.55))
wall(length=1.2, rows=5, along_y=True, origin=(-.7, .35))
finish('03_Wall_Corner')
for x in (-1.14, 1.14):
    for row in range(3):
        block((x, 0, .34 + row * .68), (.72, .9, .69), .04)
block((0, 0, 2.22), (3.16, 1.02, .4), .055)
finish('04_Stone_Doorway')
for i in range(3):
    block((0, -.6 + i * .6, (.18 * (i + 1)) / 2), (2.4, .62, .18 * (i + 1)), .025)
finish('05_Stair_Three_Treads')
for row in range(4):
    bounds = [-1.5, -.80 + rng.uniform(-.2, .2), .20 + rng.uniform(-.25, .25), 1.5]
    for left, right in zip(bounds, bounds[1:]):
        block(((left + right) / 2, -1.125 + row * .75, .175),
              (right - left - .025, .74, .35), .028)
finish('06_Foundation_Tile_300')
block((0, .28, .78), (1.6, .25, 1.56), .035)
for x in (-.68, .68):
    for row in range(4):
        block((x, -.08, .18 + row * .36), (.28, .72, .35), .02)
block((0, -.08, .18), (1.35, .8, .35), .025)
block((0, -.08, 1.52), (1.75, .91, .23), .04)
finish('07_Book_Niche')
for i in range(19):
    sx, sy, sz = rng.uniform(.15, .85), rng.uniform(.15, .65), rng.uniform(.1, .45)
    block((rng.uniform(-1, 1), rng.uniform(-.65, .65), sz / 2), (sx, sy, sz), min(sz * .4, .095), rng.uniform(0, 6))
finish('08_Rubble_Cluster')

# Scene-library writes crash Blender 5.2; save usable standalone scenes in a clean process.
subprocess.run([bpy.app.binary_path, '--background', '--factory-startup',
                '--python-exit-code', '1', '--python-expr',
                "import bpy\nfrom pathlib import Path\n"
                f"for path in sorted(Path({str(ART / 'individual')!r}).glob('*.blend')):\n"
                "    bpy.ops.wm.open_mainfile(filepath=str(path))\n"
                "    for obj in bpy.data.objects:\n"
                "        bpy.context.scene.collection.objects.link(obj)\n"
                "    bpy.context.scene.unit_settings.system = 'METRIC'\n"
                "    bpy.context.preferences.filepaths.save_version = 0\n"
                "    bpy.ops.wm.save_as_mainfile(filepath=str(path))\n"], check=True)

manifest = []
for i, (name, obj) in enumerate(assets.items()):
    obj.hide_set(False)
    obj.location = ((i % 4) * 5.5 - 8.25, (i // 4) * 5.5 - 2.75, 0)
    bpy.context.view_layer.update()
    obj.data.calc_loop_triangles()
    manifest.append({'name': name, 'triangles': len(obj.data.loop_triangles),
                     'size_m': list(obj.dimensions), 'origin': 'bottom center', 'animated': False})
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
world = bpy.data.worlds.new('Ruins_Daylight')
world.use_nodes = True
world.node_tree.nodes['Background'].inputs[0].default_value = (.56, .65, .7, 1)
world.node_tree.nodes['Background'].inputs[1].default_value = .6
scene.world = world
bpy.ops.object.light_add(type='SUN')
sun = bpy.context.object
sun.rotation_euler = (.55, -.4, -.5)
sun.data.energy = 2
sun.data.angle = .12
bpy.ops.object.camera_add(location=(12, -20, 19))
camera = bpy.context.object
camera.rotation_euler = (Vector((0, 0, .7)) - camera.location).to_track_quat('-Z', 'Y').to_euler()
camera.data.type = 'ORTHO'
camera.data.ortho_scale = 27
scene.camera = camera
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.cycles.use_denoising = True
scene.render.resolution_x, scene.render.resolution_y = 1600, 1100
scene.render.resolution_percentage = 100
scene.render.film_transparent = False
scene.render.filepath = str(ART / 'ruins_kit.png')
bpy.ops.wm.save_as_mainfile(filepath=str(ART / 'ruins_module_library.blend'))
bpy.ops.render.render(write_still=True)

# Assemble from the saved individual sources; preserve v03 and all existing linked art.
bpy.ops.wm.open_mainfile(filepath=str(ROOT / 'art/prologue_terrain/prologue_terrain_v03.blend'))
scene = bpy.context.scene
scene.name = 'Prologue_Ruins_v05'
group = bpy.data.collections.new('Ruins_Modules_v05')
scene.collection.children.link(group)
sources = {}
for entry in manifest:
    name = entry['name']
    with bpy.data.libraries.load(str(ART / 'individual' / (name + '.blend')), link=True) as (src, dst):
        dst.objects = [name]
    collection = bpy.data.collections.new('Source_Ruins_' + name)
    collection.objects.link(dst.objects[0])
    sources[name] = collection
for obj in list(scene.objects):
    if obj.name in ('Ruin_Foundation', 'Book_Niche_Placeholder') or (
        obj.get('module_source') in ('Wall_Section_300', 'Stone_Block_150', 'Stone_Step_200')
        and obj.location.x < -45 and obj.location.y > 30):
        bpy.data.objects.remove(obj, do_unlink=True)
placed = []


def place(name, x, y, h=20.35, yaw=0, scale_z=1):
    obj = bpy.data.objects.new(name + '_Instance', None)
    obj.instance_type = 'COLLECTION'
    obj.instance_collection = sources[name]
    obj.location = (x, y, h)
    obj.rotation_euler.z = yaw
    obj.scale.z = scale_z
    group.objects.link(obj)
    obj['ruins_source'] = name
    placed.append({'asset': name, 'position_blender': [x, y, h], 'yaw': yaw,
                   'scale': [1, 1, scale_z]})


for x in (-64.5, -61.5, -58.5, -55.5):
    for y in (42, 45, 48):
        if (x, y) == (-55.5, 42):
            continue
        place('06_Foundation_Tile_300', x, y, 20, yaw=rng.choice((0, math.pi)))
for i, x in enumerate((-64.5, -61.5, -58.5, -55.5)):
    place('01_Wall_Intact_300' if i == 0 else '02_Wall_Broken_300', x, 49.15,
          yaw=math.pi if i == 2 else 0, scale_z=(1, .75, 1.15, .55)[i])
for y in (43, 46):
    place('02_Wall_Broken_300', -65.8, y, yaw=math.pi / 2, scale_z=.65 if y == 43 else 1)
place('03_Wall_Corner', -65.1, 48.4, yaw=math.pi)
place('04_Stone_Doorway', -60, 40.6)
place('05_Stair_Three_Treads', -60, 39.65, 20, scale_z=.65)
place('07_Book_Niche', -64.1, 48.1)
for x, y, angle in [(-55.7, 46.7, .5), (-56, 42.8, 1.3), (-65, 43, 2.1)]:
    place('08_Rubble_Cluster', x, y, h=20 if y == 42.8 else 20.35, yaw=angle)
for x, y, angle in [(-56, 48.9, 2), (-59, 48.4, .7), (-66.4, 45, 1.1), (-54.4, 45, 2.7)]:
    place('08_Rubble_Cluster', x, y, h=20 if x < -66 or x > -54.5 else 20.35, yaw=angle, scale_z=.65)

# Reuse existing plants and pebbles around broken edges, leaving the entrance clear.
dressing = bpy.data.collections.new('Ruins_Edge_Dressing_v05')
scene.collection.children.link(dressing)
for i, (x, y, h) in enumerate([(-65.4, 47.5, 20.36), (-64.8, 49, 20.36),
        (-62.7, 48.6, 20.36), (-58, 49, 20.36), (-55.4, 45.8, 20.36),
        (-55.6, 42.9, 20), (-54.6, 43.4, 20), (-66.3, 43.5, 20),
        (-65.3, 41.1, 20.36), (-56.4, 40.4, 20)]):
    name = '01_Fern_Spread' if i % 3 == 0 else '10_MossRock_Pebbles'
    obj = bpy.data.objects.new('Ruin_Edge_' + str(i), None)
    obj.instance_type = 'COLLECTION'
    obj.instance_collection = bpy.data.collections['Source_' + name]
    obj.location = (x, y, h)
    obj.rotation_euler.z = rng.uniform(0, math.tau)
    obj.scale = (.4, .4, .4) if i % 3 == 0 else (.75, .75, .45)
    obj['dressing_source'] = name
    dressing.objects.link(obj)
assert len(sources) == 8 and len(group.objects) == len(placed)
assert {p['asset'] for p in placed} == set(sources)
for obj in group.objects:
    assert obj.instance_collection.objects[0].library is not None
for lib in bpy.data.libraries:
    lib.filepath = bpy.path.relpath(lib.filepath, start=str(ROOT / 'art/prologue_terrain'))
(OUT / 'map_placements_v05.json').write_text(json.dumps(placed, indent=2), encoding='utf-8')
scene.camera.location = (-33, 10, 49)
scene.camera.rotation_euler = (Vector((-60, 45, 21)) - scene.camera.location).to_track_quat('-Z', 'Y').to_euler()
scene.camera.data.ortho_scale = 29
scene.render.filepath = str(ART / 'ruins_in_map.png')
scene.cycles.samples = 32
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT / 'art/prologue_terrain/prologue_terrain_v05.blend'))
bpy.ops.render.render(write_still=True)
print('RUINS_KIT_OK', json.dumps({'modules': len(manifest), 'map_instances': len(placed)}))
