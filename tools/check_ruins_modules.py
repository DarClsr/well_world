"""Reopen v05 and validate weathered ruin sources and preserved existing art."""
import hashlib
import json
import struct
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
manifest = json.loads((ROOT / 'assets/ruins_modules/v2/manifest.json').read_text())
assert len(manifest) == 8
for entry in manifest:
    name = entry['name']
    source = ROOT / 'art/ruins_modules/v2/individual' / (name + '.blend')
    bpy.ops.wm.open_mainfile(filepath=str(source))
    meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
    assert len(meshes) == 1, (name, len(meshes))
    obj = meshes[0]
    assert obj.name == name and obj.location.length < 1e-6
    assert obj.data.uv_layers and obj.asset_data
    assert obj.data.color_attributes.get('Weathering')
    assert all(abs(a - b) < .001 for a, b in zip(obj.dimensions, entry['size_m']))
    assert min(v.co.z for v in obj.data.vertices) >= -.001
    for mat in obj.data.materials:
        for node in mat.node_tree.nodes:
            if node.type == 'TEX_IMAGE':
                assert node.image and node.image.packed_file
    blob = (ROOT / 'assets/ruins_modules/v2' / (name + '.glb')).read_bytes()
    magic, version, length = struct.unpack_from('<4sII', blob)
    assert magic == b'glTF' and version == 2 and length == len(blob)
    json_length, chunk_type = struct.unpack_from('<II', blob, 12)
    assert chunk_type == 0x4E4F534A
    gltf = json.loads(blob[20:20 + json_length])
    assert len(gltf['meshes']) == 1 and len(gltf['images']) == 3
    for primitive in gltf['meshes'][0]['primitives']:
        assert 'COLOR_0' in primitive['attributes'], name
    assert 'baseColorTexture' in gltf['materials'][0]['pbrMetallicRoughness'], name

bpy.ops.wm.open_mainfile(filepath=str(ROOT / 'art/prologue_terrain/prologue_terrain_v05.blend'))
scene = bpy.context.scene
instances = [o for o in scene.objects if o.get('ruins_source')]
assert len(instances) == 28
assert len([o for o in scene.objects if o.get('dressing_source')]) == 10
assert len({o['ruins_source'] for o in instances}) == 8
for obj in instances:
    assert obj.instance_collection.objects[0].library
for lib in bpy.data.libraries:
    assert Path(bpy.path.abspath(lib.filepath)).is_file(), lib.filepath
old = json.loads((ROOT / 'assets/prologue_terrain/existing_asset_placements_v03.json').read_text())
assert len([o for o in scene.objects if o.get('source_asset')]) == old['instance_count']
for entry in old['sources'].values():
    assert hashlib.sha256((ROOT / entry['blend']).read_bytes()).hexdigest() == entry['sha256']

terrain = [o for o in scene.objects if o.type == 'MESH' and o.name.startswith('Terrain_0')]
ground = []
for x, y in [(-60, 38.45), (-60, 39.35), (-60, 40.1), (-60, 45)]:
    heights = []
    for obj in terrain:
        inv = obj.matrix_world.inverted()
        hit, point, _, _ = obj.ray_cast(inv @ Vector((x, y, 100)), Vector((0, 0, -1)))
        if hit:
            heights.append((obj.matrix_world @ point).z)
    ground.append({'xy': [x, y], 'terrain_z': max(heights) if heights else None})
print('RUINS_CHECK_OK', json.dumps({'modules': 8, 'instances': len(instances),
    'existing_sources': 'unchanged', 'ground_samples': ground}))
