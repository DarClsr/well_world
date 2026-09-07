"""Blender source for six reusable storybook trees; run through Blender MCP."""
import bpy
import math
import random
import json
from pathlib import Path
from mathutils import Vector
from mathutils.geometry import interpolate_bezier

ROOT = Path('C:/Users/AAA/Documents/ChatGPT/well world')
OUT = ROOT / 'assets/fantasy_trees'
SOURCE = ROOT / 'art/fantasy_trees'
OUT.mkdir(parents=True, exist_ok=True)
SOURCE.mkdir(parents=True, exist_ok=True)

# A dedicated scene preserves any scene the user already has open.
scene = bpy.data.scenes.get('FantasyTreeAtelier')
if scene:
    for obj in list(scene.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
else:
    scene = bpy.data.scenes.new('FantasyTreeAtelier')
bpy.context.window.scene = scene


def material(name, color=None):
    mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Roughness'].default_value = .88
    if color:
        bsdf.inputs['Base Color'].default_value = (*color, 1)
    else:
        attr = mat.node_tree.nodes.new('ShaderNodeVertexColor')
        attr.layer_name = 'Color'
        mat.node_tree.links.new(attr.outputs['Color'], bsdf.inputs['Base Color'])
    mat.diffuse_color = (*(color or (.25, .39, .18)), 1)
    return mat


bark_mat = material('FT_Bark_VertexColor')
leaf_mat = material('FT_Foliage_VertexColor')


def mesh_object(name, vertices, faces, colors, mat, parent):
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    uv = mesh.uv_layers.new(name='UVMap')
    for polygon in mesh.polygons:
        drop = max(range(3), key=lambda a: abs(polygon.normal[a]))
        axes = [a for a in range(3) if a != drop]
        for loop_index in polygon.loop_indices:
            co = mesh.vertices[mesh.loops[loop_index].vertex_index].co
            uv.data[loop_index].uv = (co[axes[0]], co[axes[1]])
    attr = mesh.color_attributes.new(name='Color', type='FLOAT_COLOR', domain='POINT')
    for i, color in enumerate(colors):
        attr.data[i].color = (*color, 1)
    obj = bpy.data.objects.new(name, mesh)
    scene.collection.objects.link(obj)
    obj.data.materials.append(mat)
    obj.parent = parent
    return obj


def tube(vertices, faces, colors, points, radii, rng, sides=9):
    offset = len(vertices)
    for j, point in enumerate(points):
        tangent = (points[min(j+1, len(points)-1)] - points[max(0,j-1)]).normalized()
        axis = tangent.cross(Vector((0, 1, 0))).normalized()
        other = tangent.cross(axis).normalized()
        for k in range(sides):
            angle = k * math.tau / sides
            radial = axis * math.cos(angle) + other * math.sin(angle)
            vertices.append(point + radial * radii[j] * (1 + .07 * math.sin(k*4+j)))
            moss = max(0, radial.z * .5 + radial.x * .4)
            shade = .8 + .28 * rng.random() + .16 * math.cos(angle*3)
            colors.append(((.16 + moss*.10)*shade, (.135+moss*.15)*shade, (.085+moss*.045)*shade))
        if j:
            for k in range(sides):
                a = offset + (j-1)*sides+k
                b = offset + (j-1)*sides+(k+1)%sides
                faces.append((a,b,b+sides,a+sides))
    faces.append(tuple(offset+k for k in reversed(range(sides))))
    end = offset+(len(points)-1)*sides
    faces.append(tuple(end+k for k in range(sides)))


def curve(start, end, lift, count=9):
    delta = end-start
    return interpolate_bezier(start, start+delta*.27+Vector((0,0,lift)),
                              start+delta*.72+Vector((0,0,lift*.5)), end, count)


SPECS = [
    ('01_Elder_Sage', 7.8, 1.0, 'elder', (.29,.52,.065)),
    ('02_Silver_Spire', 9.0, .68, 'spire', (.22,.38,.25)),
    ('03_Umbrella_Grove', 6.1, 1.06, 'umbrella', (.35,.53,.10)),
    ('04_Windward_Tree', 6.5, .95, 'wind', (.20,.36,.29)),
    ('05_Amber_Sapling', 4.4, .63, 'sapling', (.48,.34,.12)),
    ('06_Dusk_Warden', 7.2, .91, 'dusk', (.32,.24,.36)),
]
trees = []
stats = []
for index, (name, height, spread, kind, palette) in enumerate(SPECS):
    rng = random.Random(1873+index*391)
    root = bpy.data.objects.new(name, None)
    scene.collection.objects.link(root)
    root['asset_role'] = 'Reusable fantasy tree; meters; origin at ground'
    verts, faces, colors = [], [], []
    lean = 1.45 if kind=='wind' else .25
    trunk_points = [Vector((math.sin(t*5)*.18 + lean*t*t,
                            math.sin(t*4)*.12, height*.75*t)) for t in [i/14 for i in range(15)]]
    radius = height * (.061 if kind in ('elder','dusk') else .043)
    radii = [radius*((1-i/16)**1.15)+(.17 if i==0 else 0) for i in range(15)]
    tube(verts,faces,colors,trunk_points,radii,rng,11)
    for k in range(7):
        angle = k*math.tau/7+rng.uniform(-.2,.2)
        end = Vector((math.cos(angle)*radius*3.3,math.sin(angle)*radius*3.3,.035))
        points = curve(Vector((0,0,.5)),end,-.25,7)
        tube(verts,faces,colors,points,[radius*.46*(1-i/7)+.018 for i in range(7)],rng,7)
    clusters = []
    # Staggered crown tiers retain air gaps and readable lateral branch gestures.
    tiers = [(0.49,3.0,5),(.65,2.4,5),(.80,1.5,4),(.93,.5,2)]
    if kind=='spire': tiers=[(.43,1.8,4),(.61,1.6,4),(.77,1.15,4),(.92,.40,2)]
    if kind=='umbrella': tiers=[(.72,3.1,7),(.86,1.9,5),(.95,.45,2)]
    if kind=='sapling': tiers=[(.54,1.8,4),(.75,1.3,4),(.93,.35,2)]
    for tier, (zratio, width, count) in enumerate(tiers):
        for k in range(count):
            angle = k*math.tau/count + tier*.88 + rng.uniform(-.23,.23)
            dist = width*spread*rng.uniform(.80,1.13)
            wind = (zratio*1.8 if kind=='wind' else 0)
            center = Vector((math.cos(angle)*dist+wind, math.sin(angle)*dist*.80,
                             height*zratio+rng.uniform(-.26,.20)))
            attach = trunk_points[min(12, int(zratio*11))].copy()
            attach.z -= .55 if kind!='umbrella' else .9
            branch = curve(attach, center-Vector((0,0,.20)), -.28, 10)
            rad = radius*(.50 if tier==0 else .35)
            tube(verts,faces,colors,branch,[rad*(1-i/10)**1.2+.009 for i in range(10)],rng,7)
            sx = (1.15 if tier<2 else .95)*spread*rng.uniform(.9,1.15)
            sz = .61 if kind=='umbrella' else .76
            clusters.append((center, Vector((sx,sx*.83,sz))))
            for side in (-1,1):
                tip = center+Vector((math.cos(angle+side*.7)*sx*.67,
                                    math.sin(angle+side*.7)*sx*.67,.12))
                twig=curve(branch[6],tip,.15,6)
                tube(verts,faces,colors,twig,[rad*.40*(1-i/6)+.006 for i in range(6)],rng,5)
    trunk=mesh_object('Trunk',verts,faces,colors,bark_mat,root)
    lv,lf,lc=[],[],[]
    for center, scale in clusters:
        for leaf in range(235):
            az = rng.random()*math.tau
            nz = rng.uniform(-1,1)
            radial = math.sqrt(1-nz*nz)
            direction=Vector((radial*math.cos(az),radial*math.sin(az),nz))
            p=center+Vector((direction.x*scale.x,direction.y*scale.y,direction.z*scale.z))*rng.uniform(.68,1.05)
            # Folded diamond leaves create painterly facets without alpha sorting.
            yaw=rng.random()*math.tau
            axis=Vector((math.cos(yaw),math.sin(yaw),rng.uniform(-.35,.45))).normalized()
            cross=Vector((-math.sin(yaw),math.cos(yaw),rng.uniform(-.15,.15))).normalized()
            length=rng.uniform(.22,.39)*(0.80 if kind=='sapling' else 1)
            breadth=length*rng.uniform(.42,.70)
            base=len(lv)
            lv.extend([p-axis*length,p-cross*breadth,p+axis*length,
                       p+cross*breadth,p+Vector((0,0,length*.16))])
            lf.extend([(base,base+1,base+4),(base+1,base+2,base+4),
                       (base+2,base+3,base+4),(base+3,base,base+4)])
            light = .57 + .42*(nz+1)/2 + rng.uniform(-.12,.19)
            c=tuple(min(1,v*light) for v in palette)
            if kind in ('elder', 'umbrella'):
                top=(nz+1)/2
                c=(c[0]*(.58+.65*top), c[1]*(.65+.45*top), c[2]+.055*(1-top))
            for v in range(5):
                lc.append(tuple(min(1,x*(1.12 if v==4 else 1)) for x in c))
    canopy=mesh_object('Canopy',lv,lf,lc,leaf_mat,root)
    canopy.shape_key_add(name='Basis')
    scene.render.fps=30
    scene.frame_start=1
    scene.frame_end=121
    for channel in range(2):
        key=canopy.shape_key_add(name=('WindBend' if channel==0 else 'LeafRipple'))
        key.slider_min=-1
        for vi, vert in enumerate(key.data):
            p=canopy.data.vertices[vi].co
            weight=max(0,min(1,(p.z-height*.32)/(height*.68)))
            if channel==0:
                vert.co.x += .16*weight*weight
                vert.co.y += .065*weight*weight
            else:
                phase=(vi//5)*2.39996
                vert.co.x += .035*math.sin(phase)*weight
                vert.co.z += .04*math.cos(phase)*weight
        for frame in range(1,122,5):
            key.value=math.sin((frame-1)/120*math.tau + channel*math.pi/2)
            key.keyframe_insert(data_path='value',frame=frame)
    canopy.data.shape_keys.animation_data.action.name='Wind_Sway'
    scene.frame_set(1)
    for obj in (trunk,canopy):
        # Root-space coordinates also give the Godot wind shader stable heights.
        obj['part']='canopy' if obj==canopy else 'trunk'
    bpy.ops.object.select_all(action='DESELECT')
    root.select_set(True)
    trunk.select_set(True)
    canopy.select_set(True)
    bpy.context.view_layer.objects.active=root
    bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',
                             use_selection=True,use_active_scene=True,export_materials='EXPORT',export_extras=True,
                             export_animations=True,export_frame_range=True,
                             export_force_sampling=True,export_morph=True,
                             export_anim_slide_to_zero=True)
    points=[v.co for obj in (trunk,canopy) for v in obj.data.vertices]
    bounds=[max(p[a] for p in points)-min(p[a] for p in points) for a in range(3)]
    triangles=sum(len(p.vertices)-2 for obj in (trunk,canopy) for p in obj.data.polygons)
    stats.append(dict(name=name,triangles=triangles,height=round(bounds[2],2),
                      width=round(bounds[0],2),depth=round(bounds[1],2),trunk_radius=round(radius,3)))
    trees.append(root)

(OUT/'manifest.json').write_text(json.dumps(stats,indent=2),encoding='utf-8')

# Neutral atelier presentation, excluded from each exported tree.
floor_mat=material('FT_AtelierFloor',(.105,.135,.145))
stone_mat=material('FT_BaseStone',(.20,.255,.245))
for i,root in enumerate(trees):
    root.location=((i%3-1)*10.5, (i//3)*12.5, 0)
    bpy.ops.mesh.primitive_cylinder_add(vertices=64,radius=4.55,depth=.18,
                                      location=(root.location.x,root.location.y,-.14))
    plinth=bpy.context.object
    plinth.name='DisplayBase_'+root.name
    plinth.data.materials.append(stone_mat)
    bevel=plinth.modifiers.new('SoftEdge','BEVEL'); bevel.width=.12; bevel.segments=2
    bpy.ops.object.text_add(location=(root.location.x-3.6,root.location.y-4.1,.01))
    text=bpy.context.object
    text.name='Label_'+root.name
    text.data.body=root.name.replace('_',' ')
    text.data.size=.40
    text.data.extrude=.001
    text.data.materials.append(material('FT_Label',(.64,.73,.68)))
bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.26))
bpy.context.object.name='AtelierGround'
bpy.context.object.data.materials.append(floor_mat)
world=bpy.data.worlds.new('FT_AtelierWorld')
world.use_nodes=True
world.node_tree.nodes['Background'].inputs[0].default_value=(.40,.47,.52,1)
world.node_tree.nodes['Background'].inputs[1].default_value=.45
scene.world=world


def area(name, location, energy, size, color):
    data=bpy.data.lights.new(name,'AREA'); data.energy=energy; data.shape='DISK'; data.size=size; data.color=color
    obj=bpy.data.objects.new(name,data); scene.collection.objects.link(obj); obj.location=location
    obj.rotation_euler=(Vector((0,6,2))-obj.location).to_track_quat('-Z','Y').to_euler()


area('Key',(-10,-6,22),4200,14,(1,.91,.77))
area('Fill',(16,4,17),2800,12,(.72,.84,1))
sun_data=bpy.data.lights.new('SoftSun','SUN'); sun_data.energy=1.7; sun_data.angle=.18
sun=bpy.data.objects.new('SoftSun',sun_data); scene.collection.objects.link(sun)
sun.rotation_euler=(.4,-.55,-.5)
cam_data=bpy.data.cameras.new('FT_Camera')
cam=bpy.data.objects.new('FT_Camera',cam_data); scene.collection.objects.link(cam)
cam.location=(18,-31,28)
cam.rotation_euler=(Vector((0,6,3))-cam.location).to_track_quat('-Z','Y').to_euler()
cam_data.type='ORTHO'; cam_data.ortho_scale=37
scene.camera=cam
scene.render.engine='CYCLES'; scene.cycles.samples=32
scene.cycles.use_denoising=True
scene.render.resolution_x=1800; scene.render.resolution_y=1300; scene.render.resolution_percentage=100
scene.view_settings.view_transform='AgX'
scene.render.image_settings.file_format='PNG'
scene.render.filepath=str(SOURCE/'tree_collection.png')
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'fantasy_tree_collection.blend'))
print('TREE_PACK_READY',json.dumps(stats))
