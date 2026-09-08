"""Blender-only v11: modular original giant-bone sanctuary and observing fauna."""
import bpy, math, random, json, hashlib
from pathlib import Path
from mathutils import Vector
from mathutils.bvhtree import BVHTree
R=Path(__file__).resolve().parents[1]; A=R/'art/prologue_terrain'; L=R/'art/shanhai_ecology/v1';L.mkdir(parents=True,exist_ok=True)
source=A/'prologue_terrain_v10.blend'; before=hashlib.sha256(source.read_bytes()).hexdigest()
bpy.ops.wm.open_mainfile(filepath=str(source));s=bpy.context.scene;s.name='Prologue_Shanhai_v11'
vs=[];fs=[]
for o in s.objects:
 if o.type=='MESH' and o.name.startswith('Terrain_0'):
  n=len(vs);vs.extend(o.matrix_world@p.co for p in o.data.vertices);fs.extend(tuple(n+i for i in p.vertices) for p in o.data.polygons)
bvh=BVHTree.FromPolygons(vs,fs)
def ground(x,y):
 h=bvh.ray_cast(Vector((x,y,150)),Vector((0,0,-1)))[0];assert h is not None;return h.z
rng=random.Random(111)
def col(n,visible=False):
 c=bpy.data.collections.new(n)
 if visible:s.collection.children.link(c)
 return c
site=col('V11_Sanctuary',True)
def mat(n,a,b,rough=.8):
 m=bpy.data.materials.new(n);m.diffuse_color=(*b,1);m.use_nodes=True;ns=m.node_tree.nodes;ls=m.node_tree.links;p=ns.get('Principled BSDF');p.inputs['Roughness'].default_value=rough
 noise=ns.new('ShaderNodeTexNoise');noise.inputs['Scale'].default_value=5;noise.inputs['Detail'].default_value=5
 ramp=ns.new('ShaderNodeValToRGB');ramp.color_ramp.elements[0].color=(*a,1);ramp.color_ramp.elements[1].color=(*b,1);ls.new(noise.outputs['Fac'],ramp.inputs[0]);ls.new(ramp.outputs[0],p.inputs['Base Color'])
 bump=ns.new('ShaderNodeBump');bump.inputs['Strength'].default_value=.36;bump.inputs['Distance'].default_value=.07;ls.new(noise.outputs['Fac'],bump.inputs['Height']);ls.new(bump.outputs[0],p.inputs['Normal']);return m
bone=mat('V11_Mineralized_Ivory',(.12,.095,.062),(.58,.49,.33));bark=bpy.data.materials.get('V08_Weathered_Timber') or bone
jade=mat('V11_Deep_Jade',(.012,.049,.037),(.15,.27,.17),.34)
fur=mat('V11_Simian_Brown_Fur',(.018,.009,.005),(.16,.08,.031));skin=mat('V11_Simian_Skin',(.012,.008,.006),(.058,.032,.017));white=mat('V11_White_Ears',(.24,.22,.16),(.76,.70,.52));eye=mat('V11_Amber_Eyes',(.045,.018,.001),(.36,.13,.006),.18)
def tube(c,n,pts,radii,m,sides=12):
 pts=[Vector(p) for p in pts];v=[];f=[]
 for i,p in enumerate(pts):
  t=(pts[min(i+1,len(pts)-1)]-pts[max(0,i-1)]).normalized();u=t.cross(Vector((0,1,0))).normalized()
  if u.length<.1:u=t.cross(Vector((1,0,0))).normalized()
  w=t.cross(u)
  for j in range(sides):
   a=j*math.tau/sides;r=radii[i]*(1+.045*math.sin(j*5+i*1.7));v.append(p+r*(math.cos(a)*u+math.sin(a)*w))
 for i in range(len(pts)-1):
  for j in range(sides):a=i*sides+j;b=i*sides+(j+1)%sides;f.append((a,b,b+sides,a+sides))
 f.extend([tuple(reversed(range(sides))),tuple((len(pts)-1)*sides+j for j in range(sides))]);me=bpy.data.meshes.new(n);me.from_pydata(v,[],f);me.materials.append(m);o=bpy.data.objects.new(n,me);c.objects.link(o)
 for p in me.polygons:p.use_smooth=True
 mod=o.modifiers.new('Organic surface','SUBSURF');mod.levels=2;return o
def ball(c,n,p,scale,m):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=24,ring_count=16,location=p);o=bpy.context.object;o.name=n;o.scale=scale
 for cc in list(o.users_collection):cc.objects.unlink(o)
 c.objects.link(o);o.data.materials.append(m)
 for f in o.data.polygons:f.use_smooth=True
 return o
def inst(c,n,p,scale=1,yaw=0):
 o=bpy.data.objects.new(n,None);site.objects.link(o);o.instance_type='COLLECTION';o.instance_collection=c;o.location=p;o.scale=(scale,)*3;o.rotation_euler.z=yaw;return o
rib=col('Ancient_Mineralized_Rib')
tube(rib,'Curved_Rib',[(0,0,0),(-2,.1,3),(-3,.25,7),(-2.6,.2,11),(-1.1,0,14),(1,0,16),(3,0,16.8)],[1.1,1,.85,.68,.5,.3,.045],bone)
# Raised weathering seams break the pristine silhouette without fluorescent decoration.
for j in range(4):tube(rib,'Mineral_Seam',[(.1+j*.14,-.7,.3),(-1.7+j*.1,-.55,3),(-2.65+j*.08,-.4,7)],[.045,.06,.012],jade,6)
root=col('Ancient_Root_Module');tube(root,'Heavy_Twisting_Root',[(0,0,0),(2,.8,.2),(4,.4,.05),(6,-.4,0),(8,-.9,-.1)],[.95,.7,.43,.24,.025],bark)
flora=col('Jade_Fern_Original')
for j in range(7):
 a=j*math.tau/7;tube(flora,'Stone_Leaf',[(0,0,0),(.35*math.cos(a),.35*math.sin(a),.6),(.85*math.cos(a),.85*math.sin(a),1.1),(1.1*math.cos(a),1.1*math.sin(a),.8)],[.08,.16,.12,.003],jade,6)
base=Vector((-121,113,ground(-121,113)))
ancient=col('Ancient_Hollow_Tree')
tube(ancient,'Twisted_Trunk',[(0,0,0),(-1,0,6),(0,1,12),(1,0,18),(-1,0,24),(0,1,29)],[2.6,2.3,1.7,1.1,.6,.06],bark)
for j in range(11):
 a=j*2.4;h=9+j*1.45;end=Vector((math.cos(a)*(10-j*.35),math.sin(a)*(8-j*.25),h+5))
 tube(ancient,'Ancient_Bough',[(0,0,h),(end.x*.38,end.y*.38,h+1),tuple(end),(end.x*1.2,end.y*1.2,h+7)],[.85-j*.045,.55,.24,.015],bark)
 for q in (-1,1):tube(ancient,'Bare_Twig',[tuple(end*.9+Vector((0,0,1))),tuple(end+Vector((q*2,1,2))),tuple(end+Vector((q*3,2,3)))],[.16,.09,.005],bark,8)
inst(ancient,'V11_Ancient_Tree',base)
bpy.data.libraries.write(str(L/'Ancient_Hollow_Tree.blend'),{ancient},fake_user=True,compress=True)
for k,dy in enumerate((-5,0,5)):
 for sign in (-1,1):
  x=base.x+sign*(7.5-k*.4);y=base.y+dy;o=inst(rib,'V11_Rib', (x,y,ground(x,y)-.4),1-k*.08,0 if sign<0 else math.pi)
  o.scale.z*=1 if k!=2 or sign!=1 else .57
  o.rotation_euler.y=sign*.08*(k-1)
for j in range(9):
 a=j*math.tau/9;x=base.x+math.cos(a)*1.5;y=base.y+math.sin(a)*1.5;inst(root,'V11_Root',(x,y,ground(x,y)-.25),1,a)
for j in range(22):
 a=rng.uniform(0,math.tau);r=rng.uniform(5,12);x=base.x+math.cos(a)*r;y=base.y+math.sin(a)*r
 if y<102:continue
 inst(flora,'V11_Jade_Flora',(x,y,ground(x,y)),rng.uniform(.3,.85),a)
# White-eared simian study: articulated object hierarchy, not a production deformation rig.
creature=col('White_Eared_Simian_Prototype')
body=ball(creature,'Simian_Chest',(0,0,1.15),(.4,.34,.61),fur)
ball(creature,'Simian_Haunch',(0,.15,.7),(.39,.35,.36),fur)
head=ball(creature,'Simian_Head',(0,-.18,1.77),(.31,.28,.33),fur)
features=[]
features.append(ball(creature,'Dark_Face',(0,-.406,1.76),(.23,.085,.23),skin))
features.append(ball(creature,'Muzzle',(0,-.47,1.64),(.16,.095,.085),skin))
for sign in (-1,1):
 features.append(ball(creature,'White_Ear',(sign*.3,-.12,1.79),(.115,.065,.19),white))
 features.append(ball(creature,'Ear_Inner',(sign*.325,-.17,1.79),(.061,.027,.11),skin))
 features.append(ball(creature,'Amber_Eye',(sign*.103,-.484,1.81),(.026,.014,.022),eye))
 features.append(tube(creature,'Brow',[(sign*.02,-.465,1.865),(sign*.1,-.49,1.867),(sign*.2,-.43,1.845)],[.027,.04,.015],fur))
 tube(creature,'Long_Forelimb',[(sign*.31,-.02,1.42),(sign*.48,-.13,1.03),(sign*.5,-.35,.62),(sign*.49,-.48,.22)],[.20,.16,.115,.095],fur)
 ball(creature,'Knuckle',(sign*.49,-.49,.16),(.12,.15,.095),skin)
 tube(creature,'Bent_Hindlimb',[(sign*.22,.17,.75),(sign*.34,.29,.46),(sign*.26,.02,.2)],[.23,.18,.085],fur)
 ball(creature,'Foot',(sign*.26,-.07,.12),(.13,.24,.09),skin)
 for j in range(4):tube(creature,'Finger',[(sign*(.425+j*.043),-.52,.15),(sign*(.425+j*.043),-.65,.09)],[.026,.019],skin,6)
for o in features:o.parent=head;o.matrix_parent_inverse=head.matrix_basis.inverted()
# Merge overlapping torso/limbs into a continuous organic mass for the prototype.
s.collection.children.link(creature)
bpy.ops.object.select_all(action='DESELECT')
parts=[o for o in creature.objects if o not in features and o!=head]
for o in parts:o.select_set(True)
bpy.context.view_layer.objects.active=body
bpy.ops.object.convert(target='MESH');bpy.ops.object.join();bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
rem=body.modifiers.new('Continuous anatomy','REMESH');rem.mode='VOXEL';rem.voxel_size=.035;bpy.ops.object.modifier_apply(modifier=rem.name)
sm=body.modifiers.new('Surface relaxation','SMOOTH');sm.factor=.9;sm.iterations=4;bpy.ops.object.modifier_apply(modifier=sm.name)
for poly in body.data.polygons:poly.use_smooth=True
s.collection.children.unlink(creature)
for frame,angle in [(1,-.13),(45,-.13),(90,.2),(140,.2),(180,-.13)]:head.rotation_euler.z=angle;head.keyframe_insert(data_path='rotation_euler',frame=frame)
for frame,z in [(1,1),(45,1.012),(90,1),(135,1.012),(180,1)]:body.scale.z=z;body.keyframe_insert(data_path='scale',frame=frame)
for c in (rib,root,flora,creature):
 bpy.data.libraries.write(str(L/(c.name+'.blend')),{c},fake_user=True,compress=True)
for x,y,sc,ang in [(-114,104,1.15,.25),(-109,109,.9,-.5),(-130,106,1.05,-.4)]:inst(creature,'V11_Observing_Simian',(x,y,ground(x,y)+.02),sc,ang)
s.frame_start=1;s.frame_end=180;s.frame_set(35)
s.render.engine='CYCLES';s.cycles.samples=32;s.cycles.use_denoising=True;s.render.resolution_x=1400;s.render.resolution_y=1000;s.render.resolution_percentage=100
views=[('sanctuary_v11',(-121,112,35),(-76,56,49),'ORTHO',64),('village_landmark_v11',(-121,112,36),(-8,-26,10),'PERSP',42),('simian_v11',(-114,104,ground(-114,104)+1.1),(-110,98,ground(-114,104)+2.3),'ORTHO',4.4)]
for label,target,pos,typ,scale in views:
 s.camera.location=pos;s.camera.rotation_euler=(Vector(target)-s.camera.location).to_track_quat('-Z','Y').to_euler();s.camera.data.type=typ;s.camera.data.ortho_scale=scale;s.camera.data.lens=scale;s.render.filepath=str(A/(label+'.png'))
 if label=='sanctuary_v11':bpy.ops.wm.save_as_mainfile(filepath=str(A/'prologue_terrain_v11.blend'))
 bpy.ops.render.render(write_still=True)
assert hashlib.sha256(source.read_bytes()).hexdigest()==before
(R/'assets/prologue_terrain/shanhai_v11.json').write_text(json.dumps({'source_v10_sha256':before,'site':list(base),'libraries':[c.name for c in (rib,root,flora,creature)],'creatures':3,'animation_frames':[1,180],'animation_scope':'object hierarchy head observation and breathing; no AI or production skin rig','original_design':'mineralized bones and jade flora; simian inspired by white-eared xingxing'},indent=2))
print('V11_BUILD_OK',flush=True)
