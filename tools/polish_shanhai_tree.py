"""Second visual pass: fine branch ramification and sparse copper foliage."""
import bpy,random,math
from pathlib import Path
from mathutils import Vector
R=Path(__file__).resolve().parents[1];A=R/'art/prologue_terrain';L=R/'art/shanhai_ecology/v1'
bpy.ops.wm.open_mainfile(filepath=str(A/'prologue_terrain_v11.blend'));s=bpy.context.scene;c=bpy.data.collections['Ancient_Hollow_Tree'];rng=random.Random(112)
for o in list(c.objects):
 if o.name.startswith('Bare_Twig'):bpy.data.objects.remove(o,do_unlink=True)
bark=bpy.data.materials.new('V11_Fissured_Dark_Bark');bark.use_nodes=True;n=bark.node_tree.nodes;l=bark.node_tree.links;p=n.get('Principled BSDF');p.inputs['Roughness'].default_value=.94
tex=n.new('ShaderNodeTexNoise');tex.inputs['Scale'].default_value=3;tex.inputs['Detail'].default_value=6
r=n.new('ShaderNodeValToRGB');r.color_ramp.elements[0].color=(.014,.009,.006,1);r.color_ramp.elements[1].color=(.15,.09,.045,1);l.new(tex.outputs['Fac'],r.inputs[0]);l.new(r.outputs[0],p.inputs['Base Color'])
b=n.new('ShaderNodeBump');b.inputs['Strength'].default_value=.6;b.inputs['Distance'].default_value=.15;l.new(tex.outputs['Fac'],b.inputs['Height']);l.new(b.outputs[0],p.inputs['Normal'])
for o in c.objects:
 if o.type=='MESH':o.data.materials.clear();o.data.materials.append(bark)
leaf=bpy.data.materials.new('V11_Copper_Ochre_Leaves');leaf.diffuse_color=(.26,.095,.026,1);leaf.use_nodes=True;lp=leaf.node_tree.nodes.get('Principled BSDF');lp.inputs['Base Color'].default_value=(.26,.095,.026,1);lp.inputs['Roughness'].default_value=.73
v=[];f=[]
def branch(points,radius):
 cu=bpy.data.curves.new('Fine_Wind_Branch','CURVE');cu.dimensions='3D';cu.resolution_u=8;cu.bevel_depth=radius;cu.bevel_resolution=2;sp=cu.splines.new('BEZIER');sp.bezier_points.add(len(points)-1)
 for i,(p,co) in enumerate(zip(sp.bezier_points,points)):
  p.co=co;p.handle_left_type='AUTO';p.handle_right_type='AUTO';p.radius=max(.025,1-i/(len(points)-1))
 cu.materials.append(bark);o=bpy.data.objects.new('Fine_Wind_Branch',cu);c.objects.link(o)
for j in range(11):
 a=j*2.4;h=9+j*1.45;end=Vector((math.cos(a)*(10-j*.35),math.sin(a)*(8-j*.25),h+5))
 for k in range(8):
  start=end* (.64+k*.04);start.z=h+2+k*.45
  angle=a+rng.uniform(-1.3,1.3);length=rng.uniform(2,4)
  tip=start+Vector((math.cos(angle)*length,math.sin(angle)*length,rng.uniform(.7,2.4)))
  middle=(start+tip)*.5+Vector((0,0,-.55));branch([start,middle,tip],rng.uniform(.035,.095))
  for q in range(30):
   t=rng.uniform(.35,1);pos=start.lerp(tip,t)+Vector((rng.uniform(-.4,.4),rng.uniform(-.4,.4),rng.uniform(-.2,.25)));ang=rng.uniform(0,math.tau);ln=rng.uniform(.12,.27);u=Vector((math.cos(ang),math.sin(ang),rng.uniform(-.4,.4)))*ln;w=Vector((-math.sin(ang),math.cos(ang),.1))*ln*.35
   idx=len(v);v.extend([pos-u,pos-w,pos+u,pos+w,pos+Vector((0,0,.045))]);f.extend([(idx,idx+1,idx+4),(idx+1,idx+2,idx+4),(idx+2,idx+3,idx+4),(idx+3,idx,idx+4)])
me=bpy.data.meshes.new('Sparse_Copper_Leaf_Crown');me.from_pydata(v,[],f);me.materials.append(leaf);o=bpy.data.objects.new('Sparse_Copper_Leaf_Crown',me);c.objects.link(o)
bpy.data.libraries.write(str(L/'Ancient_Hollow_Tree.blend'),{c},fake_user=True,compress=True)
s.frame_set(35);bpy.ops.wm.save_as_mainfile(filepath=str(A/'prologue_terrain_v11.blend'))
for label,target,pos,typ,scale in [('sanctuary_v11',(-121,112,35),(-76,56,49),'ORTHO',64),('village_landmark_v11',(-121,112,36),(-8,-26,10),'PERSP',42)]:
 s.camera.location=pos;s.camera.rotation_euler=(Vector(target)-s.camera.location).to_track_quat('-Z','Y').to_euler();s.camera.data.type=typ;s.camera.data.ortho_scale=scale;s.camera.data.lens=scale;s.render.filepath=str(A/(label+'.png'));bpy.ops.render.render(write_still=True)
print('V11_POLISH_OK')
