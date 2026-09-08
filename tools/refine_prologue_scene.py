"""Non-destructive v06 -> v07 ground, stream and natural dressing pass."""
import hashlib
import json
import math
import random
from pathlib import Path

import bpy
from mathutils import Vector
from mathutils.bvhtree import BVHTree

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'art/prologue_terrain'
SOURCE = ART / 'prologue_terrain_v06.blend'
digest = hashlib.sha256(SOURCE.read_bytes()).hexdigest()
bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
scene = bpy.context.scene
scene.name = 'Prologue_Surface_Study_v07'
terrain = [o for o in scene.objects if o.name.startswith('Terrain_0') and o.type == 'MESH']
vertices, faces = [], []
for obj in terrain:
    offset = len(vertices)
    vertices.extend(obj.matrix_world @ v.co for v in obj.data.vertices)
    faces.extend(tuple(offset + i for i in p.vertices) for p in obj.data.polygons)
surface = BVHTree.FromPolygons(vertices, faces)
linked_hashes = {bpy.path.abspath(lib.filepath): hashlib.sha256(Path(bpy.path.abspath(lib.filepath)).read_bytes()).hexdigest()
                 for lib in bpy.data.libraries}

# World-space variation keeps detail scale consistent across terrain chunks.
mat = bpy.data.materials['Terrain_Vertex_Base']
nodes, links = mat.node_tree.nodes, mat.node_tree.links
bsdf = nodes.get('Principled BSDF')
color = next(n for n in nodes if n.type == 'VERTEX_COLOR')
geo = nodes.new('ShaderNodeNewGeometry')
noise = nodes.new('ShaderNodeTexNoise')
noise.inputs['Scale'].default_value = .38
noise.inputs['Detail'].default_value = 4
links.new(geo.outputs['Position'], noise.inputs['Vector'])
ramp = nodes.new('ShaderNodeValToRGB')
ramp.color_ramp.elements[0].position = .23
ramp.color_ramp.elements[0].color = (.24, .21, .15, 1)
ramp.color_ramp.elements[1].position = .8
ramp.color_ramp.elements[1].color = (.92, .85, .66, 1)
links.new(noise.outputs['Fac'], ramp.inputs[0])
mix = nodes.new('ShaderNodeMixRGB')
mix.blend_type = 'MULTIPLY'
mix.inputs[0].default_value = .65
links.new(color.outputs['Color'], mix.inputs[1])
links.new(ramp.outputs[0], mix.inputs[2])
links.new(mix.outputs[0], bsdf.inputs['Base Color'])
fine = nodes.new('ShaderNodeTexNoise')
fine.inputs['Scale'].default_value = 7
fine.inputs['Detail'].default_value = 3
links.new(geo.outputs['Position'], fine.inputs['Vector'])
bump = nodes.new('ShaderNodeBump')
bump.inputs['Strength'].default_value = .32
bump.inputs['Distance'].default_value = .045
links.new(fine.outputs['Fac'], bump.inputs['Height'])
links.new(bump.outputs['Normal'], bsdf.inputs['Normal'])
bsdf.inputs['Roughness'].default_value = .92

water = bpy.data.objects['Water_Creek']
# Extend the water sheet into the banks until its edge is hidden by terrain.
# The original fixed-width ribbon exposed its underside above the creek bed.
water_edge_fixes = 0
for i, vertex in enumerate(water.data.vertices):
    p = water.matrix_world @ vertex.co
    direction = -1 if i % 2 == 0 else 1
    for step in range(81):
        x = p.x + direction * step * .15
        hit, _, _, _ = surface.ray_cast(Vector((x,p.y,150)), Vector((0,0,-1)))
        if hit is not None and hit.z >= p.z + .06:
            vertex.co.x = x
            water_edge_fixes += 1
            break
water.data.update()
wm = water.data.materials[0]
wn, wl = wm.node_tree.nodes, wm.node_tree.links
wbsdf = wn.get('Principled BSDF')
wbsdf.inputs['Base Color'].default_value = (.045,.13,.12,1)
wbsdf.inputs['Roughness'].default_value = .16
wbsdf.inputs['IOR'].default_value = 1.333
wg = wn.new('ShaderNodeNewGeometry')
wave = wn.new('ShaderNodeTexNoise')
wave.inputs['Scale'].default_value = 2.6
wave.inputs['Detail'].default_value = 2
wl.new(wg.outputs['Position'], wave.inputs['Vector'])
wb = wn.new('ShaderNodeBump')
wb.inputs['Strength'].default_value = .25
wb.inputs['Distance'].default_value = .12
wl.new(wave.outputs['Fac'], wb.inputs['Height'])
wl.new(wb.outputs[0], wbsdf.inputs['Normal'])

rng = random.Random(907)
group = bpy.data.collections.new('V07_Banks_And_Undergrowth')
scene.collection.children.link(group)
routes = json.loads((ROOT/'assets/prologue_terrain/expansion_v06.json').read_text())['routes_godot_xz']
segments = [(Vector((a[0],-a[1])),Vector((b[0],-b[1]))) for r in routes for a,b in zip(r,r[1:])]
placements = []

def place(name, x, y, size):
    pt = Vector((x,y))
    for a,b in segments:
        delta=b-a
        t=max(0,min(1,(pt-a).dot(delta)/max(delta.length_squared,1e-8)))
        if (pt-a-t*delta).length < 4:
            return
    hit, normal, _, _ = surface.ray_cast(Vector((x,y,150)),Vector((0,0,-1)))
    if hit is None or normal.z < .72:
        return
    obj=bpy.data.objects.new('V07_'+name,None)
    obj.instance_type='COLLECTION'
    obj.instance_collection=bpy.data.collections['Source_'+name]
    obj.location=(x,y,hit.z-.035)
    obj.scale=(size,)*3
    obj.rotation_euler.z=rng.uniform(0,math.tau)
    obj['source_asset']=name
    group.objects.link(obj)
    placements.append({'name':obj.name,'source':name,'position':list(obj.location),'scale':size})

# Paired water-edge vertices provide bank anchors, avoiding uniform scatter.
for i in range(0,len(water.data.vertices),8):
    for side in (0,1):
        p=water.matrix_world @ water.data.vertices[min(i+side,len(water.data.vertices)-1)].co
        x=p.x+(-1 if side==0 else 1)*rng.uniform(1.2,3.8)
        y=p.y+rng.uniform(-1,1)
        place(rng.choice(['08_MossRock_Broad','09_MossRock_Split','10_MossRock_Pebbles']),x,y,rng.uniform(.6,1.4))
        for k in range(3):
            place(rng.choice(['01_Fern_Spread','02_Fern_Fiddlehead']),x+rng.uniform(-2,2),y+rng.uniform(-2,2),rng.uniform(.55,1))

# Local understory pockets retain open ground between woodland clusters.
trees=[o for o in scene.objects if o.instance_type=='COLLECTION' and o.instance_collection and
       o.instance_collection.name in ('Source_01_Elder_Sage','Source_02_Silver_Spire','Source_04_Windward_Tree')]
for tree in trees[::3]:
    for k in range(4):
        angle=rng.uniform(0,math.tau); radius=rng.uniform(1,3.4)
        place(rng.choice(['01_Fern_Spread','02_Fern_Fiddlehead','10_MossRock_Pebbles','11_Fallen_Branch']),
              tree.location.x+math.cos(angle)*radius,tree.location.y+math.sin(angle)*radius,rng.uniform(.55,1.05))

sun=bpy.data.objects['Sun']
sun.rotation_euler=(math.radians(42),math.radians(-25),math.radians(-35))
sun.data.energy=2.5
sun.data.angle=math.radians(8)
sun.data.color=(1,.88,.72)
if scene.world and scene.world.use_nodes:
    bg=scene.world.node_tree.nodes.get('Background')
    if bg:
        bg.inputs[0].default_value=(.43,.53,.64,1)
        bg.inputs[1].default_value=.45
scene.cycles.samples=32
scene.cycles.use_denoising=True
scene.render.resolution_x,scene.render.resolution_y=1500,1100
scene.render.resolution_percentage=100
scene.render.filepath=str(ART/'overview_v07.png')
bpy.ops.wm.save_as_mainfile(filepath=str(ART/'prologue_terrain_v07.blend'))
bpy.ops.render.render(write_still=True)
cam=scene.camera
cam.location=(42,-48,40)
cam.rotation_euler=(Vector((8,-12,3))-cam.location).to_track_quat('-Z','Y').to_euler()
cam.data.ortho_scale=65
scene.render.filepath=str(ART/'creek_v07.png')
bpy.ops.render.render(write_still=True)
assert hashlib.sha256(SOURCE.read_bytes()).hexdigest()==digest
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==h for p,h in linked_hashes.items())
assert len(terrain)==5
report={'source_v06_sha256':digest,'linked_sources_unchanged':len(linked_hashes),'terrain_geometry_unchanged':True,
        'water_edges_fitted':water_edge_fixes,'water_edge_vertices':len(water.data.vertices),
        'added_instances':len(placements),'placements':placements,
        'limitations':'Blender material study; procedural shaders require baking or recreation in Godot. No runtime performance or navigation validation.'}
(ROOT/'assets/prologue_terrain/refinement_v07.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print('V07_OK',len(placements))
