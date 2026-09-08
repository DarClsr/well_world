"""Final chest visual pass and saved-source/animation checks."""
import bpy,json,hashlib,math
from pathlib import Path
from mathutils import Vector
R=Path(__file__).resolve().parents[1];D=R/'art/exploration_props/v1';A=R/'art/prologue_terrain'
def glow(s):
 t=bpy.data.node_groups.new('Chest_Subtle_Glow','CompositorNodeTree');t.interface.new_socket(name='Image',in_out='OUTPUT',socket_type='NodeSocketColor')
 a=t.nodes.new('CompositorNodeRLayers');g=t.nodes.new('CompositorNodeGlare');g.inputs['Type'].default_value='Fog Glow';g.inputs['Threshold'].default_value=1;g.inputs['Strength'].default_value=.35;g.inputs['Size'].default_value=.2;o=t.nodes.new('NodeGroupOutput');t.links.new(a.outputs['Image'],g.inputs['Image']);t.links.new(g.outputs['Image'],o.inputs['Image']);s.compositing_node_group=t
bpy.ops.wm.open_mainfile(filepath=str(D/'Ancient_Wood_Jade_Chest.blend'));s=bpy.context.scene;glow(s)
lid=bpy.data.objects['Chest_Lid_Hinge'];fx=bpy.data.objects['Chest_Opening_FX']
s.frame_set(1);assert abs(lid.rotation_euler.x)<1e-6 and fx.scale.x==0
s.frame_set(55);assert abs(lid.rotation_euler.x-math.radians(-105))<1e-5 and fx.scale.x>.99
assert bpy.data.objects['Chest_Interior_Glow'].data.energy>10
s.frame_set(110);assert fx.scale.x==0 and abs(lid.rotation_euler.x)<1e-6
s.frame_set(1);bpy.ops.wm.save_as_mainfile(filepath=str(D/'Ancient_Wood_Jade_Chest.blend'))
for frame,label in [(1,'chest_closed'),(55,'chest_open')]:
 s.frame_set(frame);s.camera.data.ortho_scale=2.05 if frame==1 else 2.65;s.camera.rotation_euler=(Vector((0,0,.46 if frame==1 else .73))-s.camera.location).to_track_quat('-Z','Y').to_euler();s.render.filepath=str(D/(label+'.png'));bpy.ops.render.render(write_still=True)
s.render.resolution_x=640;s.render.resolution_y=500;s.cycles.samples=16
for frame in (1,20,30,40,55,75,85,98,110):
 s.frame_set(frame);s.render.filepath=str(D/'motion'/('%03d.png'%frame));bpy.ops.render.render(write_still=True)
report=json.loads((R/'assets/prologue_terrain/chests_v12.json').read_text())
assert hashlib.sha256((A/'prologue_terrain_v11.blend').read_bytes()).hexdigest()==report['source_v11_sha256']
bpy.ops.wm.open_mainfile(filepath=str(A/'prologue_terrain_v12.blend'));s=bpy.context.scene;glow(s)
for item,yaw in zip(report['placements'],(.4,-.5,.6)):
 o=bpy.data.objects[item['name']];o.rotation_euler=Vector((0,0,1)).rotation_difference(Vector(item['normal'])).to_euler();o.rotation_euler.rotate_axis('Z',yaw);item['rotation_euler']=list(o.rotation_euler)
 assert o.instance_collection.library and o.instance_collection.name=='Ancient_Wood_Jade_Chest'
assert all(Path(bpy.path.abspath(l.filepath)).exists() for l in bpy.data.libraries)
s.frame_set(1);target=Vector(report['placements'][0]['position']);s.camera.location=target+Vector((5,-7,4.8));s.camera.rotation_euler=(target+Vector((0,0,.5))-s.camera.location).to_track_quat('-Z','Y').to_euler();bpy.ops.wm.save_as_mainfile(filepath=str(A/'prologue_terrain_v12.blend'))
s.render.resolution_x=1200;s.render.resolution_y=850;s.cycles.samples=24
for item in report['placements']:
 target=Vector(item['position']);s.camera.location=target+Vector((5,-7,4.8));s.camera.rotation_euler=(target+Vector((0,0,.5))-s.camera.location).to_track_quat('-Z','Y').to_euler();s.render.filepath=str(A/(item['name'].lower()+'_v12.png'));bpy.ops.render.render(write_still=True)
s.frame_set(55);s.render.filepath=str(A/'chest_magic_ridge_v12.png');bpy.ops.render.render(write_still=True)
report['verified']={'source_v11_unchanged':True,'three_linked_chests':True,'closed_open_closed_animation':True,'magic_off_on_off':True,'linked_paths_resolve':True};report['motifs']='Original white-eared beast face, mountains and river waves';report['effects']='Jade emission, opening glyphs and wisps, 24 animated gold motes, timed interior point light, subtle compositor glow'
(R/'assets/prologue_terrain/chests_v12.json').write_text(json.dumps(report,indent=2));print('CHESTS_CHECK_OK',flush=True)
