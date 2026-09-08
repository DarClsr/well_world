"""Read-only map survey: render plan and 1.75m reference without saving the map."""
import ast
import json
import math
import sys
from pathlib import Path
import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'art/prologue_terrain/scale_review'
OUT.mkdir(exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(ROOT / 'art/prologue_terrain/prologue_terrain_v05.blend'))
scene = bpy.context.scene
terrain = [o for o in scene.objects if o.type == 'MESH' and o.name.startswith('Terrain_0')]
points = [o.matrix_world @ v.co for o in terrain for v in o.data.vertices]
bounds = [[min(p[i] for p in points), max(p[i] for p in points)] for i in range(3)]
tree = ast.parse((ROOT / 'tools/build_prologue_terrain.py').read_text(encoding='utf-8'))
routes = next(ast.literal_eval(n.value) for n in tree.body if isinstance(n, ast.Assign)
              and any(isinstance(t, ast.Name) and t.id == 'ROUTES' for t in n.targets))
lengths = [sum(math.dist(a, b) for a, b in zip(r, r[1:])) for r in routes]
report = {'bounds_blender_m': bounds, 'routes_godot_xz': routes,
          'route_plan_lengths_m': lengths, 'reference_height_m': 1.75,
          'note': 'Plan lengths exclude elevation; time estimates exclude gameplay.'}
(OUT / 'measurements.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
camera = scene.camera
camera.location = (0, 0, 300)
camera.rotation_euler = (0, 0, 0)
camera.data.type = 'ORTHO'
camera.data.ortho_scale = 220
scene.render.resolution_x, scene.render.resolution_y = 1600, 1500
scene.render.resolution_percentage = 100
scene.cycles.samples = 32
scene.render.filepath = str(OUT / 'map_top_raw.png')
if '--closeup-only' not in sys.argv:
    bpy.ops.render.render(write_still=True)

mat = bpy.data.materials.new('Scale_Reference_Red')
mat.diffuse_color = (.65, .07, .045, 1)
mat.use_nodes = True
mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = mat.diffuse_color
origin = Vector((-58.2, 44.0, 20.39))
parts = []
def ellipsoid(name, center, size):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, location=origin + Vector(center))
    obj = bpy.context.object
    obj.name = name
    obj.scale = size
    obj.data.materials.append(mat)
    parts.append(obj)
ellipsoid('Reference_Head', (0, 0, 1.61), (.115, .11, .14))
ellipsoid('Reference_Torso', (0, 0, 1.15), (.23, .13, .33))
ellipsoid('Reference_Hips', (0, 0, .84), (.18, .12, .15))
for side in (-1, 1):
    ellipsoid('Reference_Leg', (side * .105, 0, .42), (.085, .09, .42))
    ellipsoid('Reference_Arm', (side * .285, 0, 1.10), (.065, .07, .31))
bpy.context.view_layer.update()
bottom = min((o.matrix_world @ Vector(c)).z for o in parts for c in o.bound_box)
top = max((o.matrix_world @ Vector(c)).z for o in parts for c in o.bound_box)
assert abs(top - bottom - 1.75) < .001
camera.location = (-43, 24, 37)
camera.rotation_euler = (Vector((-60, 44.5, 21)) - camera.location).to_track_quat('-Z', 'Y').to_euler()
camera.data.ortho_scale = 19
scene.render.resolution_x, scene.render.resolution_y = 1400, 1000
scene.render.filepath = str(OUT / 'ruins_human_scale.png')
bpy.ops.render.render(write_still=True)
print('SCALE_SURVEY_OK', json.dumps(report))
