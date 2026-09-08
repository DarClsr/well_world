"""Blender-only v09 riverbed, shallow banks and water material refinement."""
import hashlib
import json
import math
import random
from pathlib import Path
import bpy
import bmesh
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree

ROOT=Path(__file__).resolve().parents[1]
ART=ROOT/'art/prologue_terrain'
OUT=ROOT/'assets/prologue_terrain/river_v09'
OUT.mkdir(parents=True,exist_ok=True)
source=ART/'prologue_terrain_v08.blend'
source_hash=hashlib.sha256(source.read_bytes()).hexdigest()
bpy.ops.wm.open_mainfile(filepath=str(source))
scene=bpy.context.scene
scene.name='Prologue_River_v09'
water=bpy.data.objects['Water_Creek']
old=np.array([water.matrix_world@v.co for v in water.data.vertices])
rows=(old[::2]+old[1::2])*.5
rows=rows[np.argsort(rows[:,1])]
ys=rows[:,1]
centers=rows[:,0]+.45*np.sin(ys*.075)+.22*np.sin(ys*.19)
levels=rows[:,2]
widths=3.0+.42*np.sin(ys*.055)+.25*np.sin(ys*.17)

def channel(y):
    return tuple(float(np.interp(y,ys,values)) for values in (centers,levels,widths))

terrain=[o for o in scene.objects if o.type=='MESH' and o.name.startswith('Terrain_0')]
# Only subdivide the river corridor; interpolation preserves existing vertex colors.
for obj in terrain:
    bm=bmesh.new();bm.from_mesh(obj.data)
    edges=[]
    for edge in bm.edges:
        if all(abs(v.co.x-channel(v.co.y)[0])<channel(v.co.y)[2]*2.6 for v in edge.verts):
            edges.append(edge)
    if edges:bmesh.ops.subdivide_edges(bm,edges=edges,cuts=2,use_grid_fill=True)
    bm.to_mesh(obj.data);bm.free();obj.data.update()
modified=0
for obj in terrain:
    colors=obj.data.color_attributes.get('TerrainColor')
    for v in obj.data.vertices:
        x,y,z=v.co
        cx,level,width=channel(y)
        t=abs(x-cx)/width
        if t>2.1:continue
        depth=1.15+.25*math.sin(y*.09)
        bed=level+.04-depth*max(0,1-t*t)**1.25
        if t<=1:
            v.co.z=bed; blend=1
        else:
            blend=(max(0,1-(t-1)/1.1))**2
            v.co.z=z*(1-blend)+bed*blend
        modified+=1
        if colors:
            soil=(.19,.165,.115) if t<.8 else (.39,.33,.225)
            original=colors.data[v.index].color
            colors.data[v.index].color=tuple(original[j]*(1-blend)+soil[j]*blend for j in range(3))+(1,)
    obj.data.update()

def surface_tree():
    vertices,faces=[],[]
    for o in terrain:
        offset=len(vertices);vertices.extend(o.matrix_world@v.co for v in o.data.vertices)
        faces.extend(tuple(offset+i for i in p.vertices) for p in o.data.polygons)
    return BVHTree.FromPolygons(vertices,faces)

surface=surface_tree()
def ground(x,y):
    hit,normal,_,_=surface.ray_cast(Vector((x,y,150)),Vector((0,0,-1)))
    assert hit is not None,(x,y)
    return hit.z,normal

# Move only natural dressing within the reshaped corridor; keep the bridge deck untouched.
relocated=0
for obj in scene.objects:
    if obj.instance_type!='COLLECTION':continue
    name=obj.get('source_asset',obj.get('expansion_source',obj.get('reused_source','')))
    if not name or name.startswith(('Ruins','14_','16_','18_','19_','20_')):continue
    x,y=obj.location.x,obj.location.y
    cx,level,width=channel(y)
    if abs(x-cx)>width*2.15:continue
    is_rock=name.startswith(('08_','09_','10_'))
    if not is_rock and abs(x-cx)<width*1.2:
        x=cx+(-1 if x<cx else 1)*width*1.28
    obj.location=(x,y,ground(x,y)[0]-.025);relocated+=1

bank_group=bpy.data.collections.new('River_Shallows_Stone_Groups_v09')
scene.collection.children.link(bank_group)
rng=random.Random(909)
stone_positions=[]
for y0 in (-103,-72,-42,-21,16,43,76,107):
    cx,level,width=channel(y0)
    side=-1 if rng.random()<.5 else 1
    for k in range(7):
        y=y0+rng.uniform(-2,2);cx,level,width=channel(y)
        x=cx+side*width*rng.uniform(.72,1.23)
        name=rng.choice(['08_MossRock_Broad','09_MossRock_Split','10_MossRock_Pebbles'])
        obj=bpy.data.objects.new('RiverStone_'+name,None);obj.instance_type='COLLECTION'
        obj.instance_collection=bpy.data.collections['Source_'+name]
        obj.location=(x,y,ground(x,y)[0]-.06)
        size=rng.uniform(.3,.68);obj.scale=(size,)*3;obj.rotation_euler.z=rng.uniform(0,math.tau)
        obj['source_asset']=name;bank_group.objects.link(obj)
        stone_positions.append((x,y,size))

# Water carries depth and obstruction masks, avoiding renderer-specific screen-depth tricks.
verts,faces,uvs,colors=[],[],[],[]
sample_y=np.linspace(float(ys[0])+.01,float(ys[-1])-.01,561)
depths=[]
for y in sample_y:
    cx,level,width=channel(y)
    for j in range(33):
        across=(j/32*2-1);x=cx+width*across
        h,_=ground(x,float(y));depth=max(0,level-h)
        obstruction=max((max(0,1-math.hypot(x-sx,(y-sy+1)*.6)/(size*2+1)) for sx,sy,size in stone_positions),default=0)
        wave=.018*math.sin(x*1.4+y*3)*min(depth/.25,1)
        verts.append((x,float(y),level+wave));uvs.append((across*width,float(y)))
        colors.append((min(depth/2,1),max(0,1-depth/.22),obstruction,1));depths.append(depth)
for i in range(len(sample_y)-1):
    for j in range(32):
        a=i*33+j;faces.append((a,a+1,a+34,a+33))
mesh=bpy.data.meshes.new('River_Continuous_Shallow_Surface');mesh.from_pydata(verts,[],faces);mesh.update()
uv=mesh.uv_layers.new(name='RiverFlowUV')
for loop in mesh.loops:uv.data[loop.index].uv=uvs[loop.vertex_index]
attr=mesh.color_attributes.new(name='RiverDepth',type='FLOAT_COLOR',domain='POINT')
mesh.color_attributes.active_color=attr
for d,c in zip(attr.data,colors):d.color=c
for p in mesh.polygons:p.use_smooth=True
water.data=mesh
mat=bpy.data.materials.new('River_Depth_And_Shallow_Water_v09');mat.use_nodes=True
n,l=mat.node_tree.nodes,mat.node_tree.links
bs=n.get('Principled BSDF');bs.inputs['Roughness'].default_value=.11;bs.inputs['IOR'].default_value=1.333
bs.inputs['Coat Weight'].default_value=.3;bs.inputs['Coat Roughness'].default_value=.09
col=n.new('ShaderNodeVertexColor');col.layer_name='RiverDepth'
split=n.new('ShaderNodeSeparateColor');l.new(col.outputs['Color'],split.inputs['Color'])
ramp=n.new('ShaderNodeValToRGB');ramp.color_ramp.elements[0].color=(.18,.26,.19,1);ramp.color_ramp.elements[1].position=.65;ramp.color_ramp.elements[1].color=(.025,.075,.065,1)
l.new(split.outputs[0],ramp.inputs[0]);l.new(ramp.outputs[0],bs.inputs['Base Color'])
alpha=n.new('ShaderNodeMapRange');alpha.inputs['From Max'].default_value=.6;alpha.inputs['To Min'].default_value=.12;alpha.inputs['To Max'].default_value=.96
l.new(split.outputs[0],alpha.inputs['Value']);l.new(alpha.outputs[0],bs.inputs['Alpha'])
tex=n.new('ShaderNodeTexCoord');mapping=n.new('ShaderNodeMapping');l.new(tex.outputs['UV'],mapping.inputs['Vector'])
flow=mapping.inputs['Location'].driver_add('default_value',1)
flow.driver.expression='frame * 0.025'
noise=n.new('ShaderNodeTexNoise');noise.inputs['Scale'].default_value=4;noise.inputs['Detail'].default_value=3;l.new(mapping.outputs[0],noise.inputs['Vector'])
bump=n.new('ShaderNodeBump');bump.inputs['Strength'].default_value=.40;bump.inputs['Distance'].default_value=.12
l.new(noise.outputs['Fac'],bump.inputs['Height']);l.new(bump.outputs[0],bs.inputs['Normal'])
flecks=n.new('ShaderNodeMapRange');flecks.inputs['From Min'].default_value=.64;flecks.inputs['From Max'].default_value=.75
l.new(noise.outputs['Fac'],flecks.inputs['Value'])
foam_mask=n.new('ShaderNodeMath');foam_mask.operation='MULTIPLY'
l.new(flecks.outputs[0],foam_mask.inputs[0]);l.new(split.outputs[2],foam_mask.inputs[1])
foam=n.new('ShaderNodeMixRGB');foam.inputs[2].default_value=(.5,.54,.44,1)
l.new(foam_mask.outputs[0],foam.inputs[0]);l.new(ramp.outputs[0],foam.inputs[1]);l.new(foam.outputs[0],bs.inputs['Base Color'])
water.data.materials.append(mat)

# Refit existing bridge piles to the changed bed; their deck and rails are unchanged.
bridge=scene.objects['Ancient_Timber_Bridge_Placed']
for pile in [o for o in bridge.instance_collection.objects if o.name.startswith('Support_Pile')]:
    low=min(v.co.z for v in pile.data.vertices)
    old_bottom=pile.matrix_world@Vector((0,0,low))+bridge.location
    h,_=ground(old_bottom.x,old_bottom.y)
    delta=h-.35-old_bottom.z
    for v in pile.data.vertices:
        if abs(v.co.z-low)<1e-4:v.co.z+=delta
    pile.data.update()
scene.frame_set(35)
scene.camera.location=(33,-34,20)
scene.camera.rotation_euler=(Vector((15,-10,4))-scene.camera.location).to_track_quat('-Z','Y').to_euler()
scene.camera.data.ortho_scale=28
scene.render.resolution_x,scene.render.resolution_y=1600,1100
scene.cycles.samples=48;scene.render.filepath=str(ART/'river_v09.png')
bpy.ops.wm.save_as_mainfile(filepath=str(ART/'prologue_terrain_v09.blend'))
bpy.ops.render.render(write_still=True)
cx,level,width=channel(16)
target=Vector((cx,16,level))
scene.camera.location=target+Vector((12,-16,11))
scene.camera.rotation_euler=(target-scene.camera.location).to_track_quat('-Z','Y').to_euler()
scene.camera.data.ortho_scale=17
scene.render.filepath=str(ART/'river_shallows_v09.png')
bpy.ops.render.render(write_still=True)

assert hashlib.sha256(source.read_bytes()).hexdigest()==source_hash
report={'source_v08_sha256':source_hash,'terrain_vertices_modified':modified,'natural_instances_reseated':relocated,
        'new_stones':len(stone_positions),'water_vertices':len(verts),'maximum_depth_m':max(depths),
        'water_faces':len(faces),'stage':'Blender-only river refinement; no Godot integration'}
(OUT/'river_report.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print('RIVER_V09_OK',json.dumps(report))
