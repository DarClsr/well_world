"""Reopen saved map; verify reusable libraries, animation and old-source integrity."""
import bpy, json, hashlib
from pathlib import Path
from mathutils import Vector
from mathutils.bvhtree import BVHTree
R=Path(__file__).resolve().parents[1];A=R/'art/prologue_terrain';L=R/'art/shanhai_ecology/v1'
bpy.ops.wm.open_mainfile(filepath=str(A/'prologue_terrain_v11.blend'));s=bpy.context.scene
report=json.loads((R/'assets/prologue_terrain/shanhai_v11.json').read_text())
assert hashlib.sha256((A/'prologue_terrain_v10.blend').read_bytes()).hexdigest()==report['source_v10_sha256']
assert all(Path(bpy.path.abspath(lib.filepath)).exists() for lib in bpy.data.libraries)
for path in L.glob('*.blend'):
 with bpy.data.libraries.load(str(path),link=False) as (src,dst):assert len(src.collections)>0
head=bpy.data.objects['Simian_Head'];body=bpy.data.objects['Simian_Chest'];poses=[]
for f in (1,90):s.frame_set(f);poses.append(list(head.rotation_euler))
assert abs(poses[0][2]-poses[1][2])>.2
s.frame_set(1);a=body.scale.z;s.frame_set(45);assert body.scale.z>a
# Seat feet on the terrain after remesh; original scene and source libraries untouched.
v=[];f=[]
for o in s.objects:
 if o.type=='MESH' and o.name.startswith('Terrain_0'):
  n=len(v);v.extend(o.matrix_world@p.co for p in o.data.vertices);f.extend(tuple(n+i for i in p.vertices) for p in o.data.polygons)
bvh=BVHTree.FromPolygons(v,f);s.frame_set(1)
low=min((body.matrix_basis@v.co).z for v in body.data.vertices)
for o in s.objects:
 if o.name.startswith('V11_Observing_Simian'):
  h=bvh.ray_cast(Vector((o.location.x,o.location.y,150)),Vector((0,0,-1)))[0].z;o.location.z=h-low*o.scale.z-.015
s.frame_set(35);bpy.ops.wm.save_as_mainfile(filepath=str(A/'prologue_terrain_v11.blend'))
h=bvh.ray_cast(Vector((-114,104,150)),Vector((0,0,-1)))[0].z
s.camera.location=(-110,98,h+2.3);s.camera.rotation_euler=(Vector((-114,104,h+1))-s.camera.location).to_track_quat('-Z','Y').to_euler();s.camera.data.type='ORTHO';s.camera.data.ortho_scale=4.4
s.cycles.samples=24;s.render.filepath=str(A/'simian_v11.png');bpy.ops.render.render(write_still=True)
s.render.resolution_x=640;s.render.resolution_y=460;s.cycles.samples=12
out=A/'motion_v11';out.mkdir(exist_ok=True)
for frame in (1,35,70,105,140,180):
 s.frame_set(frame);s.render.filepath=str(out/('%03d.png'%frame));bpy.ops.render.render(write_still=True)
report['verified']={'source_v10_unchanged':True,'linked_paths_resolve':True,'library_headers_readable':True,'head_angle_change':poses[1][2]-poses[0][2],'breathing_changes':True,'motion_render_frames':[1,35,70,105,140,180]}
(R/'assets/prologue_terrain/shanhai_v11.json').write_text(json.dumps(report,indent=2))
print('V11_CHECK_OK',flush=True)
