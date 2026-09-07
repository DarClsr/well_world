"""Build the independent Shanhai prologue terrain in Blender (meters)."""
import json
import math
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'art/prologue_terrain'
OUT = ROOT / 'assets/prologue_terrain'
ART.mkdir(parents=True, exist_ok=True)
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.name = 'Shanhai_Prologue_Terrain'
scene.unit_settings.system = 'METRIC'
scene.unit_settings.scale_length = 1.0


def smooth(a, b, v):
    t = max(0.0, min(1.0, (v - a) / (b - a)))
    return t * t * (3.0 - 2.0 * t)


def river_x(z):
    return 11 + 5 * math.sin(z / 22) + 2 * math.sin(z / 9)


def water_h(z):
    return .6 + .022 * (80 - z)


def base_h(x, z):
    h = 3.5 + 19 * math.exp(-((x + 62) / 35) ** 2 - ((z + 48) / 33) ** 2)
    h += 15 * math.exp(-((x - 61) / 31) ** 2 - ((z + 38) / 47) ** 2)
    h += 13 * smooth(55, 80, -z) + 5 * smooth(70, 90, abs(x))
    h += 1.0 * math.sin(x / 12) * math.cos(z / 15)
    h += .24 * math.sin(x / 3.8 + z / 5.7)
    for cx, cz, rx, rz, level in [(-60, -45, 16, 12, 20), (-11, 9, 20, 17, 4.4), (57, -35, 13, 12, 16)]:
        distance = math.hypot((x - cx) / rx, (z - cz) / rz)
        h = h * smooth(.75, 1.5, distance) + level * (1 - smooth(.75, 1.5, distance))
    distance = abs(x - river_x(z))
    bank = smooth(2.0, 7.0, distance)
    return (water_h(z) - .65) * (1 - bank) + h * bank


# Routes are continuous graded paths, not disconnected raised ribbons.
ROUTES = [
    [(-60, -45), (-60, -25), (-57, -10), (-43, 4), (-28, 10), (-10, 10)],
    [(-10, 10), (0, 10), (23, 10), (38, 8), (47, -8), (57, -35)],
    [(57, -35), (69, -18), (66, 7), (48, 28), (29, 42)],
    [(29, 42), (25, 58), (12, 65), (-2, 55), (-12, 31), (-10, 10)],
]
SEGMENTS = [(a, b, base_h(*a), base_h(*b)) for route in ROUTES for a, b in zip(route, route[1:])]


def path_info(x, z):
    best = (1e9, 0.0)
    for (ax, az), (bx, bz), ah, bh in SEGMENTS:
        dx, dz = bx - ax, bz - az
        t = max(0, min(1, ((x - ax) * dx + (z - az) * dz) / (dx * dx + dz * dz)))
        d = math.hypot(x - ax - t * dx, z - az - t * dz)
        if d < best[0]:
            best = (d, ah + t * (bh - ah))
    return best


def height(x, z):
    h = base_h(x, z)
    d, road_h = path_info(x, z)
    # The channel stays open below the two crossing decks.
    if abs(x - river_x(z)) > 4.0:
        blend = 1 - smooth(1.8, 5.5, d)
        h = h * (1 - blend) + road_h * blend
    return h


def material(name, color, vertex=False, roughness=.93):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1)
    bsdf.inputs['Roughness'].default_value = roughness
    if vertex:
        attr = mat.node_tree.nodes.new('ShaderNodeVertexColor')
        attr.layer_name = 'TerrainColor'
        mat.node_tree.links.new(attr.outputs['Color'], bsdf.inputs['Base Color'])
    return mat


GROUND = material('Terrain_Vertex_Base', (.3, .34, .23), True)
STONE = material('Foundation_Stone', (.37, .39, .38))
EARTH = material('Compacted_Earth', (.34, .29, .20))
WOOD = material('Crossing_Timber', (.24, .20, .15))
WATER = material('Creek_Water_Blockout', (.095, .25, .28), roughness=.3)


def mesh(name, vertices, faces, mat):
    data = bpy.data.meshes.new(name)
    # Author in Godot X/Y/Z and convert to Blender's Z-up coordinates.
    data.from_pydata([(x, -z, y) for x, y, z in vertices], [], faces)
    data.update()
    obj = bpy.data.objects.new(name, data)
    scene.collection.objects.link(obj)
    obj.data.materials.append(mat)
    return obj


def ground_color(x, z):
    slope = math.hypot(height(x + .25, z) - height(x - .25, z), height(x, z + .25) - height(x, z - .25)) * 2
    variation = .025 * math.sin(x / 2.8) * math.sin(z / 4.1) + .016 * math.cos(x * 1.7 + z)
    grass = (.25 + variation, .32 + variation, .18 + variation)
    rock = (.36 + variation, .37 + variation, .34 + variation)
    amount = smooth(.35, 1.0, slope)
    color = tuple(a * (1 - amount) + b * amount for a, b in zip(grass, rock))
    d, _ = path_info(x, z)
    path = (1 - smooth(1.3, 2.4, d)) * .9
    color = tuple(a * (1 - path) + b * path for a, b in zip(color, (.43, .36, .25)))
    if abs(x - river_x(z)) < 5:
        color = (.27 + variation, .29 + variation, .27 + variation)
    return (*color, 1)


patches = [
    ('Terrain_01_Ruins_Highland', -90, -26, -80, -15),
    ('Terrain_02_Descending_Slope', -90, -26, -15, 80),
    ('Terrain_03_Settlement_Terrace', -26, 24, -80, 28),
    ('Terrain_04_Creek_Bed', -26, 24, 28, 80),
    ('Terrain_05_Eastern_Hills', 24, 90, -80, 80),
]
border_heights = {}
for name, xmin, xmax, zmin, zmax in patches:
    vertices = [(x, height(x, z), z) for z in range(zmin, zmax + 1) for x in range(xmin, xmax + 1)]
    stride = xmax - xmin + 1
    faces = []
    for row in range(zmax - zmin):
        for col in range(xmax - xmin):
            i = row * stride + col
            faces.append((i, i + stride, i + stride + 1, i + 1))
    obj = mesh(name, vertices, faces, GROUND)
    colors = obj.data.color_attributes.new(name='TerrainColor', type='FLOAT_COLOR', domain='POINT')
    for i, (x, y, z) in enumerate(vertices):
        colors.data[i].color = ground_color(x, z)
        if x in (xmin, xmax) or z in (zmin, zmax):
            if (x, z) in border_heights:
                assert abs(border_heights[(x, z)] - y) < 1e-8
            border_heights[(x, z)] = y
    for polygon in obj.data.polygons:
        polygon.use_smooth = True

water_vertices = []
for z in range(-80, 81):
    water_vertices.extend([(river_x(z) - 2.65, water_h(z), z), (river_x(z) + 2.65, water_h(z), z)])
mesh('Water_Creek', water_vertices, [(i, i + 2, i + 3, i + 1) for i in range(0, 320, 2)], WATER)


def box(name, x, z, width, depth, tall, mat, y=None):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, -z, (height(x, z) if y is None else y) + tall / 2))
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = (width, depth, tall)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    return obj


# Sparse footprints communicate scale; these are not finished buildings.
box('Ruin_Foundation', -60, -45, 13, 9, .35, STONE, 20)
for x, z, w, d, h in [(-66, -45, .7, 9, 2.8), (-60, -49, 12, .7, 2), (-54, -47, .7, 4, 1.4)]:
    box('Ruin_Wall', x, z, w, d, h, STONE, 20.35)
box('Book_Niche_Placeholder', -64.8, -47, 1.3, .8, 1, EARTH, 20.35)
for i, (x, z) in enumerate([(-18, 0), (-7, -2), (-19, 17), (-3, 20)]):
    box('Settlement_Footprint_%02d' % i, x, z, 6, 5, .25, EARTH)
box('Trial_Ground_Marker', 57, -35, 9, 8, .08, EARTH, 16)
box('Herb_Shelter_Footprint', 29, 42, 5, 4, .2, EARTH)
for crossing_z in (10, 65):
    center = river_x(crossing_z)
    # Match the graded route level and span the entire bank transition.
    _, deck = path_info(center, crossing_z)
    box('Crossing_Deck_%d' % crossing_z, center, crossing_z, 15, 3.6, .3, WOOD, deck - .3)

# Close only the outer terrain edges, leaving shared patch seams untouched.
perimeter = [(x, -80) for x in range(-90, 91)] + [(90, z) for z in range(-79, 81)]
perimeter += [(x, 80) for x in range(89, -91, -1)] + [(-90, z) for z in range(79, -80, -1)]
verts = []
for x, z in perimeter:
    verts.extend([(x, height(x, z), z), (x, -4, z)])
mesh('Terrain_Outer_Skirt', verts, [(2*i, 2*i+1, (2*i+3) % len(verts), (2*i+2) % len(verts)) for i in range(len(perimeter))], STONE)

landmarks = [{'name': label, 'position': [x, height(x, z), z]} for label, x, z in [
    ('Ruins', -60, -45), ('Descent', -52, -4), ('Settlement', -11, 10), ('Creek', 5, 42), ('Trial', 57, -35)]]
max_grade = max(abs(bh - ah) / math.dist(a, b) for a, b, ah, bh in SEGMENTS)
assert max_grade < .48, max_grade
report = {'units': 'meters', 'bounds': [180, 160], 'terrain_sections': [p[0] for p in patches],
          'landmarks': landmarks, 'route_max_center_grade': max_grade,
          'route_points': [[[x, height(x, z), z] for x, z in route] for route in ROUTES],
          'shared_border_check': 'passed', 'stage': 'terrain blockout, not final environment art'}
(OUT / 'terrain_manifest.json').write_text(json.dumps(report, indent=2), encoding='utf-8')

bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=str(OUT / 'prologue_terrain.glb'), export_format='GLB',
                          use_selection=True, export_yup=True, export_cameras=False, export_lights=False)

world = bpy.data.worlds.new('Daylight')
world.use_nodes = True
world.node_tree.nodes['Background'].inputs[0].default_value = (.53, .65, .73, 1)
world.node_tree.nodes['Background'].inputs[1].default_value = .45
scene.world = world
bpy.ops.object.light_add(type='SUN', location=(0, 0, 100))
bpy.context.object.rotation_euler = (math.radians(28), math.radians(-25), math.radians(-30))
bpy.context.object.data.energy = 2.0
bpy.context.object.data.angle = .12
bpy.ops.object.camera_add(location=(150, -205, 185))
camera = bpy.context.object
camera.rotation_euler = (Vector((0, 0, 5)) - camera.location).to_track_quat('-Z', 'Y').to_euler()
camera.data.type = 'ORTHO'
camera.data.ortho_scale = 240
scene.camera = camera
scene.render.engine = 'CYCLES'
scene.cycles.samples = 24
scene.render.resolution_x = 1600
scene.render.resolution_y = 1100
scene.render.resolution_percentage = 100
scene.view_settings.view_transform = 'AgX'
scene.render.filepath = str(ART / 'blender_overview.png')
bpy.ops.wm.save_as_mainfile(filepath=str(ART / 'prologue_terrain.blend'))
bpy.ops.render.render(write_still=True)
print('TERRAIN_BUILD_OK', json.dumps(report))
