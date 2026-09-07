"""Write each tree as a separate, editable Blender file without display props."""
import bpy
from pathlib import Path

out = Path('C:/Users/AAA/Documents/ChatGPT/well world/art/fantasy_trees/individual')
out.mkdir(parents=True, exist_ok=True)
atelier = bpy.data.scenes['FantasyTreeAtelier']
roots = [o for o in atelier.objects if o.type == 'EMPTY' and o.get('asset_role')]
assert len(roots) == 6
for root in roots:
    single = bpy.data.scenes.new(root.name + '_Asset')
    single.render.fps = 30
    single.frame_start = 1
    single.frame_end = 121
    copy = root.copy()
    copy.location = (0, 0, 0)
    copy.asset_mark()
    copy.asset_data.description = 'Storybook fantasy tree with a four-second canopy wind loop.'
    single.collection.objects.link(copy)
    for child in root.children:
        obj = child.copy()
        obj.parent = copy
        single.collection.objects.link(obj)
    assert len(single.objects) == 3
    single.frame_set(1)
    bpy.data.libraries.write(str(out / (root.name + '.blend')), {single}, fake_user=True, compress=True)
    for obj in list(single.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
    bpy.data.scenes.remove(single)
    with bpy.data.libraries.load(str(out / (root.name + '.blend')), link=False) as (available, loaded):
        assert len(available.scenes) == 1
        loaded.scenes = available.scenes
    reopened = loaded.scenes[0]
    assert len(reopened.objects) == 3
    standalone_root = next(o for o in reopened.objects if o.type == 'EMPTY')
    assert standalone_root.location.length < 0.00001
    moving = [o for o in reopened.objects if o.type == 'MESH' and o.data.shape_keys]
    assert len(moving) == 1 and len(moving[0].data.shape_keys.key_blocks) == 3
    assert reopened.frame_end - reopened.frame_start == 120
    for obj in list(reopened.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
    bpy.data.scenes.remove(reopened)
print('INDIVIDUAL_BLEND_FILES_READY', len(roots))
