"""Run in a separate background Blender process after loading the atelier file."""
import bpy
import sys
from pathlib import Path

scene = bpy.data.scenes.get('NatureRevision') or bpy.data.scenes['FantasyPropsAtelier']
bpy.context.window.scene = scene
name = sys.argv[sys.argv.index('--')+1] if '--' in sys.argv else '01_Fern_Spread'
root = next(o for o in scene.objects if o.name == name)
keep = {root, *root.children}
for other in list(bpy.data.scenes):
    if other != scene:
        bpy.data.scenes.remove(other)
for obj in list(bpy.data.objects):
    if obj not in keep:
        bpy.data.objects.remove(obj, do_unlink=True)
root.location = (0, 0, 0)
scene.camera = None
scene.frame_set(1)
assert len(scene.objects) == 2
if root.children[0].data.shape_keys:
    assert len(root.children[0].data.shape_keys.key_blocks) == 2
out = Path('C:/Users/AAA/Documents/ChatGPT/well world/art/fantasy_props/individual')
bpy.ops.wm.save_as_mainfile(filepath=str(out / (root.name + '.blend')), compress=True)
print('INDEPENDENT_PROP_SOURCE_SAVED', root.name)
