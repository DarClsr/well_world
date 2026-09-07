"""Revised natural props with irregular geometry and baked portable PBR maps."""
import bpy
import bmesh
import math
import random
import json
from pathlib import Path
from mathutils import Vector, Matrix, noise

ROOT = Path('C:/Users/AAA/Documents/ChatGPT/well world')
OUT = ROOT / 'assets/fantasy_props'
ART = ROOT / 'art/fantasy_props'
TEXTURES = ART / 'textures'
TEXTURES.mkdir(parents=True, exist_ok=True)
scene = bpy.data.scenes.new('NatureRevision')
bpy.context.window.scene = scene
rng = random.Random(41973)
parts = []


def ramp(nodes, stops):
    node = nodes.new('ShaderNodeValToRGB')
    for element in list(node.color_ramp.elements)[2:]:
        node.color_ramp.elements.remove(element)
    node.color_ramp.elements[0].position = stops[0][0]
    node.color_ramp.elements[0].color = (*stops[0][1], 1)
    node.color_ramp.elements[1].position = stops[-1][0]
    node.color_ramp.elements[1].color = (*stops[-1][1], 1)
    for position, color in stops[1:-1]:
        node.color_ramp.elements.new(position).color = (*color, 1)
    return node


def material(name, wood=False, interior=False, endgrain=False):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes, links = mat.node_tree.nodes, mat.node_tree.links
    bsdf = nodes.get('Principled BSDF')
    bsdf.inputs['Roughness'].default_value = .86
    coord = nodes.new('ShaderNodeTexCoord')
    mapping = nodes.new('ShaderNodeVectorMath'); mapping.operation = 'MULTIPLY'
    mapping.inputs[1].default_value = (1.4, 36, 36) if wood and not endgrain else (4,4,4)
    links.new(coord.outputs['Object'], mapping.inputs[0])
    grain = nodes.new('ShaderNodeTexNoise')
    grain.inputs['Scale'].default_value = 1.8 if wood else 2.7
    grain.inputs['Detail'].default_value = 3.2
    grain.inputs['Roughness'].default_value = .66
    links.new(mapping.outputs[0], grain.inputs['Vector'])
    if endgrain:
        palette = [(0.18,(.16,.115,.067)),(.43,(.30,.235,.15)),(.70,(.44,.36,.25)),(.88,(.27,.19,.11))]
    elif interior:
        palette = [(0.15,(.038,.033,.025)),(.43,(.065,.053,.038)),(.70,(.12,.093,.057)),(.9,(.16,.13,.09))]
    elif wood:
        palette = [(0.16,(.075,.059,.043)),(.38,(.15,.12,.082)),(.57,(.235,.20,.145)),(.77,(.29,.265,.205)),(.90,(.12,.096,.067))]
    else:
        palette = [(0.17,(.095,.12,.127)),(.36,(.20,.225,.223)),(.58,(.285,.302,.28)),(.76,(.37,.365,.315)),(.90,(.23,.25,.255))]
    stone_color = ramp(nodes, palette)
    links.new(grain.outputs['Fac'], stone_color.inputs[0])
    color_output = stone_color.outputs['Color']
    if not interior and not endgrain:
        # World-facing Z is Blender up; coverage is mottled, not separate floating pads.
        geo = nodes.new('ShaderNodeNewGeometry')
        sep = nodes.new('ShaderNodeSeparateXYZ'); links.new(geo.outputs['Normal'], sep.inputs[0])
        coverage_noise = nodes.new('ShaderNodeTexNoise')
        coverage_noise.inputs['Scale'].default_value = 6.8
        coverage_noise.inputs['Detail'].default_value = 4.0
        coverage_noise.inputs['Roughness'].default_value = .8
        links.new(coord.outputs['Object'], coverage_noise.inputs['Vector'])
        multiply = nodes.new('ShaderNodeMath'); multiply.operation = 'MULTIPLY'
        links.new(sep.outputs['Z'],multiply.inputs[0]); links.new(coverage_noise.outputs['Fac'],multiply.inputs[1])
        mask = nodes.new('ShaderNodeMapRange')
        mask.inputs['From Min'].default_value = .30 if wood else .27
        mask.inputs['From Max'].default_value = .53 if wood else .46
        links.new(multiply.outputs[0],mask.inputs['Value'])
        moss_color = ramp(nodes,[(.18,(.055,.10,.035)),(.42,(.11,.19,.048)),(.65,(.21,.29,.082)),(.85,(.27,.325,.13))])
        links.new(coverage_noise.outputs['Fac'],moss_color.inputs[0])
        mix=nodes.new('ShaderNodeMixRGB'); mix.blend_type='MIX'
        links.new(mask.outputs['Result'],mix.inputs[0]); links.new(color_output,mix.inputs[1]); links.new(moss_color.outputs[0],mix.inputs[2])
        color_output=mix.outputs[0]
    links.new(color_output,bsdf.inputs['Base Color'])
    fine=nodes.new('ShaderNodeTexNoise'); fine.inputs['Scale'].default_value=75 if not wood else 3.6
    fine.inputs['Detail'].default_value=2.5
    links.new(mapping.outputs[0],fine.inputs['Vector'])
    bump=nodes.new('ShaderNodeBump'); bump.inputs['Strength'].default_value=.27
    bump.inputs['Distance'].default_value=.018 if wood else .009
    links.new(fine.outputs['Fac'],bump.inputs['Height']); links.new(bump.outputs[0],bsdf.inputs['Normal'])
    rough=nodes.new('ShaderNodeMapRange'); rough.inputs['To Min'].default_value=.72; rough.inputs['To Max'].default_value=.97
    links.new(grain.outputs['Fac'],rough.inputs['Value']); links.new(rough.outputs[0],bsdf.inputs['Roughness'])
    return mat


STONE = material('NR_WeatheredStone')
BARK = material('NR_FibrousBark',wood=True)
INNER = material('NR_RottenInterior',wood=True,interior=True)
CUT = material('NR_BrokenHeartwood',wood=True,endgrain=True)


def mesh(name, verts, faces, mat, smooth=True):
    data=bpy.data.meshes.new(name); data.from_pydata(verts,[],faces); data.update()
    obj=bpy.data.objects.new(name,data); scene.collection.objects.link(obj)
    data.materials.append(mat)
    for p in data.polygons: p.use_smooth=smooth
    parts.append(obj)
    return obj


def stone(pos, scale, seed):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=4,radius=1,location=pos)
    obj=bpy.context.object; obj.name='WeatheredBoulder'
    for vertex in obj.data.vertices:
        p=vertex.co.copy()
        n=noise.noise_vector(p*2.2+Vector((seed,4,1)))
        coarse=noise.noise(p*1.7+Vector((2,seed,5)))
        p *= 1 + coarse*.19
        p += n*.065
        # Sloped, worn planes interrupt the sphere without making regular wedges.
        p.z=min(p.z,.77+.17*p.x-.09*p.y)
        p.x=min(p.x,.91+.14*p.z)
        p.y=max(p.y,-.83+.18*p.x)
        p.z=max(p.z,-.64)
        vertex.co=Vector((p.x*scale[0],p.y*scale[1],p.z*scale[2]))
    obj.data.materials.append(STONE)
    for face in obj.data.polygons: face.use_smooth=True
    parts.append(obj)
    return obj


def split_boulder():
    left=stone((0,0,0),(.64,.46,.66),11)
    right=left.copy(); right.data=left.data.copy(); scene.collection.objects.link(right); parts.append(right)
    for obj,outer in [(left,True),(right,False)]:
        bm=bmesh.new(); bm.from_mesh(obj.data)
        result=bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),
            plane_co=(0,0,0),plane_no=(1,.21,-.13),dist=.0001,clear_outer=outer,clear_inner=not outer)
        boundary=[e for e in bm.edges if e.is_boundary]
        caps=bmesh.ops.holes_fill(bm,edges=boundary,sides=0)['faces']
        cap_edges=list({edge for face in caps for edge in face.edges})
        bmesh.ops.triangulate(bm,faces=caps)
        bmesh.ops.subdivide_edges(bm,edges=cap_edges,cuts=2,use_grid_fill=True)
        normal=Vector((1,.21,-.13)).normalized()
        for vertex in bm.verts:
            if abs(vertex.co.dot(normal))<.001:
                vertex.co+=normal*(noise.noise(vertex.co*13+Vector((7,2,1)))*.025)
        bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
        bm.to_mesh(obj.data); bm.free()
        modifier=obj.modifiers.new('WornFractureEdges','BEVEL'); modifier.width=.015; modifier.segments=2
        bpy.context.view_layer.objects.active=obj
        bpy.ops.object.modifier_apply(modifier=modifier.name)
        side=-1 if outer else 1
        obj.location.x=side*.065
        obj.rotation_euler.y=side*.085
        obj.rotation_euler.z=side*.045


def branch(points, radii, seed=0):
    points=[Vector(p) for p in points]
    verts=[]; faces=[]; sides=15
    for j,p in enumerate(points):
        tangent=(points[min(j+1,len(points)-1)]-points[max(0,j-1)]).normalized()
        axis=tangent.cross(Vector((0,1,.1))).normalized(); other=tangent.cross(axis).normalized()
        for k in range(sides):
            a=k*math.tau/sides
            r=radii[j]*(1+.12*math.sin(k*2.1+j*.7)+.035*math.sin(j*2.2))
            q=p+(axis*math.cos(a)+other*math.sin(a))*r
            if j in (0,len(points)-1): q+=tangent*(.025*math.sin(k*4+seed))
            verts.append(q)
        if j:
            for k in range(sides):
                a=(j-1)*sides+k; b=(j-1)*sides+(k+1)%sides
                faces.append((a,b,b+sides,a+sides))
    faces.extend([tuple(reversed(range(sides))),tuple((len(points)-1)*sides+k for k in range(sides))])
    obj=mesh('TwistedBranch',verts,faces,BARK)
    obj.data.materials.append(CUT)
    for p in list(obj.data.polygons)[-2:]: p.material_index=1; p.use_smooth=False
    return obj


def log():
    length=2.0; sides=56; rings=25
    verts=[]; faces=[]; mats=[]
    def center(t): return Vector(((t-.5)*length,.075*math.sin(t*4),.43+.07*math.sin(t*3.5)))
    for inner in (False,True):
        for j in range(rings):
            t=j/(rings-1); c=center(t)
            for k in range(sides):
                a=k*math.tau/sides
                radial=(.36+.035*math.sin(t*6+.3))*(1+.10*math.sin(a*3+t*4)+.055*math.sin(a*11-t*6))
                radial-=.104 if inner else 0
                if not inner: radial+=.01*noise.noise(Vector((t*9,a*7,3)))
                q=c+Vector((0,math.cos(a)*radial,math.sin(a)*radial))
                if j==0: q.x+=.017*math.sin(k*2.3)+.08*math.sin(a*3)
                if j==rings-1: q.x+=.025*math.sin(k*1.73)+.14*math.cos(a*3)+.045*math.sin(a*7)
                verts.append(q)
    block=rings*sides
    for inner in (0,1):
        for j in range(rings-1):
            for k in range(sides):
                a=inner*block+j*sides+k; b=inner*block+j*sides+(k+1)%sides
                f=(a,b,b+sides,a+sides)
                faces.append(tuple(reversed(f)) if inner else f); mats.append(1 if inner else 0)
    for j in (0,rings-1):
        for k in range(sides):
            a=j*sides+k; b=j*sides+(k+1)%sides
            faces.append((a,a+block,b+block,b) if j==0 else (a,b,b+block,a+block)); mats.append(2)
    obj=mesh('TornHollowTrunk',verts,faces,BARK)
    obj.data.materials.append(INNER); obj.data.materials.append(CUT)
    for p,idx in zip(obj.data.polygons,mats):
        p.material_index=idx
        if idx==2: p.use_smooth=False
    branch([(.02,.04,.71),(.06,.08,.88),(.16,.16,1.0),(.19,.20,1.05)],[.13,.11,.055,.032],7)
    # Exposed splinters continue the torn edge rather than forming a uniform rim.
    for k in (7,23,43):
        a=k*math.tau/sides; p=center(1)+Vector((0,math.cos(a)*.33,math.sin(a)*.33))
        tip=p+Vector((.18+rng.random()*.15,.012,.02))
        branch([p,p.lerp(tip,.55),tip],[.032,.021,.002],k)


def bake(obj,name):
    bpy.context.view_layer.objects.active=obj
    bpy.ops.object.select_all(action='DESELECT'); obj.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=1.15,island_margin=.018,correct_aspect=True)
    bpy.ops.object.mode_set(mode='OBJECT')
    images={}
    scene.render.engine='CYCLES'; scene.cycles.samples=8
    scene.render.bake.margin=10
    for kind,space in [('BaseColor','sRGB'),('Normal','Non-Color'),('Roughness','Non-Color')]:
        image=bpy.data.images.new(name+'_'+kind,width=1024,height=1024,alpha=False)
        image.colorspace_settings.name=space
        for mat in obj.data.materials:
            target=mat.node_tree.nodes.new('ShaderNodeTexImage'); target.image=image
            mat.node_tree.nodes.active=target
        if kind=='BaseColor': bpy.ops.object.bake(type='DIFFUSE',pass_filter={'COLOR'})
        else: bpy.ops.object.bake(type='NORMAL' if kind=='Normal' else 'ROUGHNESS')
        image.filepath_raw=str(TEXTURES/(name+'_'+kind+'.png')); image.file_format='PNG'; image.save(); image.pack()
        images[kind]=image
    final=bpy.data.materials.new(name+'_BakedPBR'); final.use_nodes=True
    nodes=final.node_tree.nodes; links=final.node_tree.links; bsdf=nodes.get('Principled BSDF')
    for kind in images:
        tex=nodes.new('ShaderNodeTexImage'); tex.image=images[kind]
        if kind=='Normal':
            normal=nodes.new('ShaderNodeNormalMap'); normal.inputs['Strength'].default_value=.65
            links.new(tex.outputs['Color'],normal.inputs['Color']); links.new(normal.outputs[0],bsdf.inputs['Normal'])
        else: links.new(tex.outputs['Color'],bsdf.inputs['Base Color' if kind=='BaseColor' else 'Roughness'])
    obj.data.materials.clear(); obj.data.materials.append(final)
    for p in obj.data.polygons: p.material_index=0


SPECS=['08_MossRock_Broad','09_MossRock_Split','10_MossRock_Pebbles','11_Fallen_Branch','12_Hollow_Log']
manifest=[]; roots=[]
for index,name in enumerate(SPECS):
    parts=[]
    if index==0: stone((0,0,0),(.77,.55,.42),3)
    elif index==1: split_boulder()
    elif index==2:
        for i,(x,y,s) in enumerate([(-.27,-.05,.27),(.12,.17,.34),(.24,-.23,.18),(-.05,-.34,.14),(-.36,.22,.14)]):
            stone((x,y,s*.36),(s,s*.79,s*.60),13+i)
    elif index==3:
        branch([(-.86,.02,.17),(-.64,-.025,.145),(-.31,.04,.13),(-.02,.01,.16),(.31,.10,.18),(.58,.13,.15),(.84,.08,.12)],
               [.10,.115,.095,.082,.052,.030,.010],2)
        branch([(-.07,.02,.16),(.07,.20,.18),(.20,.33,.27),(.24,.51,.28),(.41,.64,.25)],[.068,.06,.034,.02,.003],8)
        branch([(-.43,.015,.13),(-.46,-.12,.14),(-.56,-.27,.12)],[.05,.032,.003],6)
    else: log()
    bpy.ops.object.select_all(action='DESELECT')
    for p in parts: p.select_set(True)
    bpy.context.view_layer.objects.active=parts[0]
    if len(parts)>1: bpy.ops.object.join()
    obj=bpy.context.object; obj.name=name+'_Body'
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    low=min(v.co.z for v in obj.data.vertices)
    obj.data.transform(Matrix.Translation((0,0,-low)))
    triangulate=obj.modifiers.new('ExportTriangles','TRIANGULATE')
    bpy.ops.object.modifier_apply(modifier=triangulate.name)
    root=bpy.data.objects.new(name,None); scene.collection.objects.link(root); obj.parent=root
    root['asset_role']='Independent fantasy prop'; root['category']='nature'; root.asset_mark()
    # Own each procedural material before selecting a unique atlas as bake target.
    for i,mat in enumerate(obj.data.materials): obj.data.materials[i]=mat.copy()
    bake(obj,name)
    bpy.ops.object.select_all(action='DESELECT'); root.select_set(True); obj.select_set(True)
    bpy.context.view_layer.objects.active=root
    bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True,
        use_active_scene=True,export_animations=False,export_extras=True,export_tangents=True)
    points=[v.co for v in obj.data.vertices]
    lo=[min(p[a] for p in points) for a in range(3)]; hi=[max(p[a] for p in points) for a in range(3)]
    triangles=sum(len(p.vertices)-2 for p in obj.data.polygons)
    manifest.append(dict(name=name,category='nature',animated=False,triangles=triangles,
        size=[round(hi[a]-lo[a],3) for a in range(3)],center=[round((lo[a]+hi[a])/2,3) for a in range(3)],
        revision=2,textures='1024px embedded BaseColor, Normal and Roughness'))
    roots.append(root)
    print('REVISED_PROP_EXPORTED',name,triangles,flush=True)
previous=json.loads((OUT/'manifest.json').read_text(encoding='utf-8'))
entries={e['name']:e for e in previous}; entries.update({e['name']:e for e in manifest})
(OUT/'manifest.json').write_text(json.dumps(sorted(entries.values(),key=lambda e:e['name']),indent=2),encoding='utf-8')

display=bpy.data.materials.new('NaturalDisplay'); display.use_nodes=True
display.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(.16,.19,.18,1)
display.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.9
for i,root in enumerate(roots):
    root.location=((i%3-1)*3.0,(i//3)*3.0,0)
    bpy.ops.mesh.primitive_cube_add(size=1,location=(root.location.x,root.location.y,-.075))
    base=bpy.context.object; base.name='Display_'+root.name; base.scale=(2.65,2.6,.1); base.data.materials.append(display)
world=bpy.data.worlds.new('NaturalAtelierWorld'); world.use_nodes=True
world.node_tree.nodes['Background'].inputs[0].default_value=(.34,.40,.44,1)
world.node_tree.nodes['Background'].inputs[1].default_value=.45; scene.world=world
data=bpy.data.lights.new('NaturalKey','AREA'); data.energy=1500; data.size=9
key=bpy.data.objects.new('NaturalKey',data); scene.collection.objects.link(key); key.location=(-3,-4,9)
data=bpy.data.lights.new('NaturalSun','SUN'); data.energy=1.5; data.angle=.12
sun=bpy.data.objects.new('NaturalSun',data); scene.collection.objects.link(sun); sun.rotation_euler=(.35,-.5,-.5)
data=bpy.data.cameras.new('NaturalCamera'); cam=bpy.data.objects.new('NaturalCamera',data); scene.collection.objects.link(cam)
cam.location=(5,-11,10); cam.rotation_euler=(Vector((0,1.3,.2))-cam.location).to_track_quat('-Z','Y').to_euler()
data.type='ORTHO'; data.ortho_scale=10.4; scene.camera=cam
scene.render.engine='CYCLES'; scene.cycles.samples=32; scene.cycles.use_denoising=True
scene.render.resolution_x=1800; scene.render.resolution_y=1300; scene.render.resolution_percentage=100
scene.view_settings.view_transform='AgX'
bpy.ops.wm.save_as_mainfile(filepath=str(ART/'Natural_Debris_v2_atelier.blend'),compress=True)
print('NATURE_REVISION_READY',flush=True)
