import bpy,hashlib,struct,json
from pathlib import Path
R=Path(__file__).resolve().parents[1];A=R/'art/prologue_terrain'
def hashes():
 return {o.name:hashlib.sha256(b''.join(struct.pack('fff',*v.co) for v in o.data.vertices)).hexdigest() for o in bpy.context.scene.objects if o.type=='MESH' and (o.name.startswith('Terrain_0') or o.name=='Water_Creek')}
bpy.ops.wm.open_mainfile(filepath=str(A/'prologue_terrain_v10.blend'));old=hashes()
bpy.ops.wm.open_mainfile(filepath=str(A/'prologue_terrain_v11.blend'));assert hashes()==old
assert len([o for o in bpy.context.scene.objects if o.name.startswith('V11_Observing_Simian')])==3
bpy.ops.wm.read_factory_settings(use_empty=True)
counts={}
for p in (R/'art/shanhai_ecology/v1').glob('*.blend'):
 with bpy.data.libraries.load(str(p),link=False) as (src,dst):dst.collections=list(src.collections)
 for c in dst.collections:
  assert c and len(c.all_objects)>0;bpy.context.scene.collection.children.link(c);counts[p.name]=len(c.all_objects)
bpy.context.scene.frame_set(90);bpy.context.view_layer.update()
assert bpy.data.objects['Simian_Head'].rotation_euler.z>.15
print('FINAL_REOPEN_OK',counts)
p=R/'assets/prologue_terrain/shanhai_v11.json';d=json.loads(p.read_text());d['verified']['terrain_water_meshes_unchanged']=True;d['verified']['libraries_appended_in_clean_scene']=counts;p.write_text(json.dumps(d,indent=2))
