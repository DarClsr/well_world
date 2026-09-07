"""Run with Blender after opening prologue_terrain_v03.blend."""
import hashlib
import json
from pathlib import Path

import bpy

ROOT = Path(__file__).resolve().parents[1]
report = json.loads((ROOT / 'assets/prologue_terrain/existing_asset_placements_v03.json').read_text())
scene = bpy.data.scenes['Prologue_Existing_Assets_v03']
bpy.context.window.scene = scene
instances = [o for o in scene.objects if o.get('source_asset')]
assert len(instances) == report['instance_count']
assert len(report['sources']) == 17
for name, entry in report['sources'].items():
    source = ROOT / entry['blend']
    assert hashlib.sha256(source.read_bytes()).hexdigest() == entry['sha256'], name
    assert (ROOT / entry['godot_scene']).is_file(), name
    collection = bpy.data.collections['Source_' + name]
    matching = [o for o in instances if o.get('source_asset') == name]
    assert len(matching) == report['counts'][name]
    assert all(o.instance_collection is collection for o in matching), name
    assert all(o.library is not None for o in collection.objects), name
for library in bpy.data.libraries:
    assert Path(bpy.path.abspath(library.filepath)).is_file(), library.filepath
for obj in instances:
    for part in obj.instance_collection.objects:
        if part.type != 'MESH':
            continue
        for material in part.data.materials:
            if material and material.use_nodes:
                for node in material.node_tree.nodes:
                    if node.type == 'TEX_IMAGE':
                        image = node.image
                        assert image is not None, (part.name, node.name)
                        assert image.packed_file or Path(bpy.path.abspath(image.filepath, library=image.library)).is_file(), image.name
samples = {}
for frame in (1, 13, 25, 37, 49):
    scene.frame_set(frame)
    bpy.context.view_layer.update()
    for name in report['animated_sources']:
        values = tuple(key.value for obj in bpy.data.collections['Source_' + name].objects
                       if obj.type == 'MESH' and obj.data.shape_keys
                       for key in obj.data.shape_keys.key_blocks)
        samples.setdefault(name, []).append(values)
for name, values in samples.items():
    assert len(set(values)) > 1, ('Animation does not change', name, values)
print('EXISTING_ASSET_CHECK_OK', json.dumps({
    'sources': len(report['sources']), 'instances': len(instances),
    'animated_sources_verified': list(samples), 'source_hashes': 'unchanged',
    'linked_files_and_textures': 'resolved',
}))
