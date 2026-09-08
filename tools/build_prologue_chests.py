"""Build a reusable hinged chest and link three instances into Blender v12."""
import bpy, math, json, hashlib, random
from pathlib import Path
from mathutils import Vector
from mathutils.bvhtree import BVHTree
R=Path(__file__).resolve().parents[1];A=R/'art/prologue_terrain';D=R/'art/exploration_props/v1';D.mkdir(parents=True,exist_ok=True)
source=A/'prologue_terrain_v11.blend';source_hash=hashlib.sha256(source.read_bytes()).hexdigest()
bpy.ops.wm.read_factory_settings(use_empty=True);s=bpy.context.scene
chest=bpy.data.collections.new('Ancient_Wood_Jade_Chest');s.collection.children.link(chest)
def material(name,dark,light,stretch,rough=.75,metal=0):
 m=bpy.data.materials.new(name);m.use_nodes=True;m.diffuse_color=(*light,1);n=m.node_tree.nodes;l=m.node_tree.links;p=n.get('Principled BSDF');p.inputs['Roughness'].default_value=rough;p.inputs['Metallic'].default_value=metal
 tc=n.new('ShaderNodeTexCoord');mul=n.new('ShaderNodeVectorMath');mul.operation='MULTIPLY';mul.inputs[1].default_value=stretch;l.new(tc.outputs['Generated'],mul.inputs[0])
 noise=n.new('ShaderNodeTexNoise');noise.inputs['Scale'].default_value=6;noise.inputs['Detail'].default_value=4;l.new(mul.outputs[0],noise.inputs['Vector'])
 ramp=n.new('ShaderNodeValToRGB');ramp.color_ramp.elements[0].color=(*dark,1);ramp.color_ramp.elements[1].color=(*light,1);l.new(noise.outputs['Fac'],ramp.inputs[0]);l.new(ramp.outputs[0],p.inputs['Base Color'])
 bump=n.new('ShaderNodeBump');bump.inputs['Distance'].default_value=.006;bump.inputs['Strength'].default_value=.32;l.new(noise.outputs['Fac'],bump.inputs['Height']);l.new(bump.outputs[0],p.inputs['Normal']);return m
wood=material('Chest_Long_Weathered_Grain',(.037,.018,.008),(.20,.095,.031),(.22,7,7))
sidewood=material('Chest_Side_Grain',(.031,.014,.006),(.17,.074,.025),(7,.22,7))
bronze=material('Chest_Aged_Bronze',(.036,.033,.016),(.21,.17,.071),(2,2,2),.48,.72)
jade=material('Chest_Mottled_Jade',(.014,.055,.032),(.16,.30,.17),(2,2,2),.28)
inside=material('Chest_Interior_Wood',(.025,.011,.005),(.10,.045,.014),(.3,7,7),.88)
lid=bpy.data.objects.new('Chest_Lid_Hinge',None);chest.objects.link(lid);lid.location=(0,.397,.708);lid['animation']='Open: frames 20-55; hold to 85; close by 110'
def box(name,center,size,mat,parent=None,bevel=.012):
 bpy.ops.mesh.primitive_cube_add(size=1,location=center);o=bpy.context.object;o.name=name;o.scale=size;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 for c in list(o.users_collection):c.objects.unlink(o)
 chest.objects.link(o);o.data.materials.append(mat)
 if bevel:mod=o.modifiers.new('Worn edge bevel','BEVEL');mod.width=bevel;mod.segments=3;o.modifiers.new('Weighted normals','WEIGHTED_NORMAL')
 if parent:o.parent=parent;o.location=Vector(center)-parent.location
 return o
# Separate wall boards, floor and feet leave a genuine empty interior.
for x in (-.48,.48):box('Low_Foot',(x,0,.045),(.14,.65,.09),wood)
for i in range(4):box('Interior_Floor',(-.45+i*.30,0,.127),(.296,.69,.085),inside)
for z in (.24,.42,.60):
 for y in (-.35,.35):box('Long_Wall_Plank',(0,y,z),(1.20,.085,.175),wood)
 for x in (-.56,.56):box('End_Wall_Plank',(x,0,z),(.085,.61,.175),sidewood)
for x in (-.575,.575):
 for y in (-.365,.365):box('Corner_Bronze_Post',(x,y,.416),(.068,.065,.58),bronze,bevel=.006)
for z in (.165,.678):
 for y in (-.399,.399):box('Bronze_Edge_Band',(0,y,z),(1.22,.018,.043),bronze,bevel=.005)
for i in range(4):box('Lid_Plank',(0,-.294+i*.196,.751),(1.28,.192,.086),wood,lid)
for x in (-.51,.51):
 box('Lid_Cross_Band',(x,0,.799),(.065,.805,.021),bronze,lid,.005)
 box('Underside_Batten',(x,0,.699),(.07,.65,.023),wood,lid,.004)
# A stepped bronze faceplate and small jade disk, without luminous effects.
box('Latch_Plate',(0,-.409,.609),(.16,.027,.18),bronze,bevel=.018)
box('Lid_Clasp',(0,-.411,.734),(.12,.035,.12),bronze,lid,.009)
bpy.ops.mesh.primitive_torus_add(major_radius=.058,minor_radius=.012,major_segments=32,minor_segments=8,location=(0,-.436,.627),rotation=(math.pi/2,0,0));o=bpy.context.object;o.name='Jade_Bi_Clasp'
for c in list(o.users_collection):c.objects.unlink(o)
chest.objects.link(o);o.data.materials.append(jade)
# Two visible rear hinge pins. Hinge lies above the back wall so the lid clears it.
for x in (-.43,.43):
 bpy.ops.mesh.primitive_cylinder_add(vertices=20,radius=.022,depth=.17,location=(x,.397,.708),rotation=(0,math.pi/2,0));o=bpy.context.object;o.name='Rear_Hinge_Pin'
 for c in list(o.users_collection):c.objects.unlink(o)
 chest.objects.link(o);o.data.materials.append(bronze)
for x in (-.51,.51):
 for y in (-.28,0,.28):box('Bronze_Lid_Rivet',(x,y,.818),(.024,.024,.016),bronze,lid,.007)
# Original Shan Hai beast-face lid relief: white ears echo the observing simian.
whitejade=material('Chest_White_Ear_Jade',(.23,.24,.18),(.68,.66,.49),(3,3,3),.38)
def relief(name,outline,z,thickness,mat):
 n=len(outline);verts=[(x,y,h) for h in (z,z+thickness) for x,y in outline];faces=[tuple(reversed(range(n))),tuple(range(n,2*n))]
 faces.extend((i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n))
 me=bpy.data.meshes.new(name);me.from_pydata(verts,[],faces);me.materials.append(mat);o=bpy.data.objects.new(name,me);chest.objects.link(o);o.parent=lid;o.location=-lid.location
 mod=o.modifiers.new('Relief edge wear','BEVEL');mod.width=.005;mod.segments=3;o.modifiers.new('Relief normals','WEIGHTED_NORMAL');return o
def ornament_line(name,points,mat,parent=None,radius=.007):
 cu=bpy.data.curves.new(name,'CURVE');cu.dimensions='3D';cu.bevel_depth=radius;cu.bevel_resolution=3;sp=cu.splines.new('POLY');sp.points.add(len(points)-1)
 for pt,co in zip(sp.points,points):pt.co=(*co,1)
 cu.materials.append(mat);o=bpy.data.objects.new(name,cu);chest.objects.link(o)
 if parent:o.parent=parent;o.location=-parent.location
 return o
relief('White_Eared_Beast_Bronze_Mask',[(-.18,.13),(-.14,-.12),(0,-.22),(.14,-.12),(.18,.13),(.10,.21),(-.10,.21)],.798,.018,bronze)
relief('Beast_Forehead_Jade',[(-.09,.10),(0,-.035),(.09,.10),(0,.17)],.82,.012,jade)
for sign in (-1,1):
 relief('White_Ear_Inlay',[(sign*x,y) for x,y in [(.195,.12),(.255,.17),(.278,.08),(.254,-.08),(.207,-.14),(.19,-.055)]][::sign],.801,.022,whitejade)
 relief('Beast_Eye_Inlay',[(sign*x,y) for x,y in [(.025,.005),(.105,.015),(.117,-.025),(.055,-.049)]][::sign],.818,.014,whitejade)
 ornament_line('Beast_Brow',[(sign*.018,.052,.837),(sign*.08,.062,.837),(sign*.145,.039,.837)],bronze,lid,.009)
ornament_line('Beast_Muzzle', [(-.085,-.113,.835),(0,-.154,.842),(.085,-.113,.835)],jade,lid,.01)
# Mountain silhouettes and water curls flank the central jade clasp.
for sign in (-1,1):
 ornament_line('Mountain_Ridge_Inlay',[(sign*x,-.400,z) for x,z in [(.18,.47),(.26,.55),(.32,.49),(.38,.59),(.46,.49),(.5,.52)]],bronze,radius=.006)
 for row in range(2):
  ornament_line('River_Wave_Inlay',[(sign*(.18+i*.018),-.401,.32+row*.055+.012*math.sin(i*.65)) for i in range(19)],bronze,radius=.004)
for frame,angle in [(1,0),(20,0),(55,-105),(85,-105),(110,0)]:lid.rotation_euler.x=math.radians(angle);lid.keyframe_insert(data_path='rotation_euler',frame=frame)
# Localized opening magic: jade glyphs, curved wisps, gold motes and interior light.
jp=jade.node_tree.nodes.get('Principled BSDF');jp.inputs['Emission Color'].default_value=(.08,.40,.24,1)
for frame,strength in [(1,.12),(20,.12),(40,1.2),(55,2.2),(85,1.2),(110,.12)]:
 jp.inputs['Emission Strength'].default_value=strength;jp.inputs['Emission Strength'].keyframe_insert(data_path='default_value',frame=frame)
def glow_material(name,color,strength):
 m=bpy.data.materials.new(name);m.use_nodes=True;n=m.node_tree.nodes;n.clear();out=n.new('ShaderNodeOutputMaterial');em=n.new('ShaderNodeEmission');em.inputs['Color'].default_value=(*color,1);em.inputs['Strength'].default_value=strength;m.node_tree.links.new(em.outputs[0],out.inputs['Surface']);return m
magic=glow_material('Chest_Jade_Magic',(.11,.75,.42),3)
gold=glow_material('Chest_Gold_Motes',(.95,.40,.075),5)
fx=bpy.data.objects.new('Chest_Opening_FX',None);chest.objects.link(fx);fx['scope']='Blender opening preview effects; rebuild in Godot when integrating'
for frame,scale in [(1,0),(23,0),(42,.75),(55,1),(75,.8),(95,0),(110,0)]:fx.scale=(scale,)*3;fx.keyframe_insert(data_path='scale',frame=frame)
for k in range(2):
 points=[]
 for i in range(65):
  t=i/64;angle=t*math.tau*1.15+k*math.pi;r=.14+.11*t;points.append((math.cos(angle)*r,math.sin(angle)*r-.03,.49+t*.98))
 ornament_line('Rising_Jade_Wisp',points,magic,fx,.0025)
for k in range(3):
 x=(k-1)*.22;z=.94+k*.11
 ornament_line('Floating_Mountain_Sigil',[(x-.10,-.12,z),(x-.045,-.12,z+.09),(x,-.12,z+.035),(x+.045,-.12,z+.14),(x+.10,-.12,z)],magic,fx,.004)
rng=random.Random(1212)
for k in range(24):
 a=rng.uniform(0,math.tau);r=rng.uniform(.07,.38);z=rng.uniform(.45,1.55)
 bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1,radius=rng.uniform(.006,.013),location=(math.cos(a)*r,math.sin(a)*r,z));o=bpy.context.object;o.name='Opening_Gold_Mote'
 for c in list(o.users_collection):c.objects.unlink(o)
 chest.objects.link(o);o.data.materials.append(gold);o.parent=fx
 for frame,angle,up in [(23,a,0),(55,a+.8,.16),(95,a+1.8,.4)]:
  o.location=(math.cos(angle)*r,math.sin(angle)*r,z+up);o.keyframe_insert(data_path='location',frame=frame)
bpy.ops.object.light_add(type='POINT',location=(0,0,.53));o=bpy.context.object;o.name='Chest_Interior_Glow'
for c in list(o.users_collection):c.objects.unlink(o)
chest.objects.link(o);o.data.color=(1,.57,.23);o.data.shadow_soft_size=.22
for frame,power in [(1,0),(23,0),(45,10),(55,15),(80,10),(98,0),(110,0)]:o.data.energy=power;o.data.keyframe_insert(data_path='energy',frame=frame)
s.frame_start=1;s.frame_end=110;s.frame_set(1)
# Preview stage is separate from the reusable collection.
preview=bpy.data.collections.new('Preview_Stage');s.collection.children.link(preview)
def stage_object(o):
 for c in list(o.users_collection):c.objects.unlink(o)
 preview.objects.link(o)
bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.005));stage_object(bpy.context.object);bpy.context.object.data.materials.append(material('Preview_Earth',(.07,.065,.05),(.12,.105,.082),(1,1,1),.95))
bpy.ops.object.camera_add(location=(2.05,-2.6,1.8));cam=bpy.context.object;stage_object(cam);cam.rotation_euler=(Vector((0,0,.46))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=2.05;s.camera=cam
for loc,power,size in [((1,-2,4),420,3),((-3,-1,2),180,3),((0,3,3),300,2)]:
 bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;stage_object(o);o.data.energy=power;o.data.shape='DISK';o.data.size=size;o.rotation_euler=(-o.location).to_track_quat('-Z','Y').to_euler()
s.world=bpy.data.worlds.new('Chest_Studio_World');s.world.use_nodes=True;s.world.node_tree.nodes['Background'].inputs[0].default_value=(.3,.34,.38,1);s.world.node_tree.nodes['Background'].inputs[1].default_value=.3
s.render.engine='CYCLES';s.cycles.samples=32;s.cycles.use_denoising=True;s.render.resolution_x=1100;s.render.resolution_y=850;s.render.resolution_percentage=100;s.view_settings.view_transform='AgX'
def subtle_glow(scene):
 tree=bpy.data.node_groups.new('Chest_Subtle_Glow','CompositorNodeTree');tree.interface.new_socket(name='Image',in_out='OUTPUT',socket_type='NodeSocketColor')
 layers=tree.nodes.new('CompositorNodeRLayers');glare=tree.nodes.new('CompositorNodeGlare');glare.inputs['Type'].default_value='Fog Glow';glare.inputs['Threshold'].default_value=1;glare.inputs['Strength'].default_value=.35;glare.inputs['Size'].default_value=.2
 out=tree.nodes.new('NodeGroupOutput');tree.links.new(layers.outputs['Image'],glare.inputs['Image']);tree.links.new(glare.outputs['Image'],out.inputs['Image']);scene.compositing_node_group=tree
subtle_glow(s)
asset=D/'Ancient_Wood_Jade_Chest.blend';bpy.ops.wm.save_as_mainfile(filepath=str(asset))
for frame,label in [(1,'chest_closed'),(55,'chest_open')]:
 s.frame_set(frame)
 cam.data.ortho_scale=2.05 if frame==1 else 2.65
 cam.rotation_euler=(Vector((0,0,.46 if frame==1 else .73))-cam.location).to_track_quat('-Z','Y').to_euler()
 s.render.filepath=str(D/(label+'.png'));bpy.ops.render.render(write_still=True)
# Low-resolution motion evidence, with an identical camera across all frames.
s.render.resolution_x=640;s.render.resolution_y=500;s.cycles.samples=16
motion=D/'motion';motion.mkdir(exist_ok=True)
for frame in (1,20,30,40,55,75,85,98,110):
 s.frame_set(frame);s.render.filepath=str(motion/('%03d.png'%frame));bpy.ops.render.render(write_still=True)
# Link only the asset collection, preserving the standalone source and its animation.
bpy.ops.wm.open_mainfile(filepath=str(source));s=bpy.context.scene;s.name='Prologue_Exploration_Chests_v12'
with bpy.data.libraries.load(str(asset),link=True) as (src,dst):dst.collections=['Ancient_Wood_Jade_Chest']
chest=dst.collections[0];group=bpy.data.collections.new('V12_Exploration_Chests');s.collection.children.link(group)
v=[];f=[]
for o in s.objects:
 if o.type=='MESH' and o.name.startswith('Terrain_0'):
  n=len(v);v.extend(o.matrix_world@p.co for p in o.data.vertices);f.extend(tuple(n+i for i in p.vertices) for p in o.data.polygons)
bvh=BVHTree.FromPolygons(v,f);placements=[]
for label,x,y,yaw in [('Hidden_Ruins',-145,75,.4),('Forest_Rest',-73,32,-.5),('Ridge_Forage',143,67,.6)]:
 hit,normal,_,_=bvh.ray_cast(Vector((x,y,150)),Vector((0,0,-1)));assert hit is not None
 o=bpy.data.objects.new('Chest_'+label,None);group.objects.link(o);o.instance_type='COLLECTION';o.instance_collection=chest;o.location=(x,y,hit.z)
 # Seat the asset on the local slope, keeping the hinge and all pieces together.
 o.rotation_euler=Vector((0,0,1)).rotation_difference(normal).to_euler();o.rotation_euler.rotate_axis('Z',yaw)
 o['chest_id']='prologue_'+label.lower();o['interaction_status']='visual placement only; no rewards or game logic'
 placements.append({'name':o.name,'position':list(o.location),'normal':list(normal),'id':o['chest_id']})
subtle_glow(s)
s.frame_set(1);s.camera.data.type='ORTHO';s.camera.data.ortho_scale=8
first=Vector(placements[0]['position']);s.camera.location=first+Vector((5,-7,4.8));s.camera.rotation_euler=(first+Vector((0,0,.6))-s.camera.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.wm.save_as_mainfile(filepath=str(A/'prologue_terrain_v12.blend'),relative_remap=True)
s.render.resolution_x=1200;s.render.resolution_y=850;s.cycles.samples=32
for item in placements:
 target=Vector(item['position']);s.camera.location=target+Vector((5,-7,4.8));s.camera.rotation_euler=(target+Vector((0,0,.5))-s.camera.location).to_track_quat('-Z','Y').to_euler();s.render.filepath=str(A/(item['name'].lower()+'_v12.png'));bpy.ops.render.render(write_still=True)
assert hashlib.sha256(source.read_bytes()).hexdigest()==source_hash
(R/'assets/prologue_terrain/chests_v12.json').write_text(json.dumps({'source_v11_sha256':source_hash,'asset':'art/exploration_props/v1/Ancient_Wood_Jade_Chest.blend','placements':placements,'animation':{'closed':1,'open':55,'close_end':110},'scope':'Blender visual asset and animation only'},indent=2))
print('CHESTS_V12_OK',flush=True)
