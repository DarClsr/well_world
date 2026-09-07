"""Author and export small fantasy props in a dedicated live Blender scene."""
import bpy
import math
import random
import json
import sys
from pathlib import Path
from mathutils import Vector, Matrix

ROOT = Path('C:/Users/AAA/Documents/ChatGPT/well world')
OUT = ROOT / 'assets/fantasy_props'
ART = ROOT / 'art/fantasy_props'
OUT.mkdir(parents=True, exist_ok=True)
SELECTED = 'Woodland_Plants'
TRAVEL = '--travel' in sys.argv
VILLAGE = '--village' in sys.argv
if TRAVEL:
    SELECTED = 'Travel_Items'
elif VILLAGE:
    SELECTED = 'Village_Items'
(ART / 'individual').mkdir(parents=True, exist_ok=True)
scene = bpy.data.scenes.get('FantasyPropsAtelier')
if scene:
    for obj in list(scene.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
else:
    scene = bpy.data.scenes.new('FantasyPropsAtelier')
bpy.context.window.scene = scene
scene.render.fps = 30
scene.frame_start = 1
scene.frame_end = 121
rng = random.Random(9207)
parts = []


def mat(name, color, metal=0, glow=0):
    m = bpy.data.materials.get('FP_' + name) or bpy.data.materials.new('FP_' + name)
    m.use_nodes = True
    shader = m.node_tree.nodes.get('Principled BSDF')
    shader.inputs['Base Color'].default_value = (*color, 1)
    shader.inputs['Roughness'].default_value = .77 if metal == 0 else .43
    shader.inputs['Metallic'].default_value = metal
    shader.inputs['Emission Color'].default_value = (*color, 1)
    shader.inputs['Emission Strength'].default_value = glow
    m.diffuse_color = (*color, 1)
    return m


WOOD = mat('CutWood', (.39,.23,.10))
BARK = mat('Bark', (.13,.095,.055))
GRAIN = mat('WoodGrain', (.24,.14,.065))
LEAF = mat('Leaf', (.20,.43,.075))
TIP = mat('LeafLight', (.40,.61,.12))
JADE = mat('Jade', (.045,.27,.20))
MOSS = mat('Moss', (.20,.32,.06))
STONE = mat('Stone', (.24,.29,.29))
STONE_LIGHT = mat('StoneCut', (.39,.43,.40))
RED = mat('MushroomRed', (.56,.12,.085))
CREAM = mat('GillsAndSpots', (.66,.54,.30))
BLUE = mat('MushroomBlue', (.06,.36,.40))
GOLD = mat('OldBrass', (.49,.32,.095), .65)
IRON = mat('Iron', (.075,.10,.11), .65)
ROPE = mat('Hemp', (.48,.38,.20))
LEATHER = mat('Leather', (.23,.115,.055))
CLOTH = mat('TealCanvas', (.065,.24,.21))
TERRA = mat('Terracotta', (.48,.18,.09))
CERAMIC = mat('BlueGlaze', (.055,.28,.33))
CYAN = mat('RuneLight', (.06,.61,.57), glow=1.1)
AMBER = mat('LanternLight', (.95,.40,.06), glow=1.8)
PETAL = mat('VioletPetal', (.43,.20,.47))
if VILLAGE:
    WOOD = mat('WeatheredOak', (.205,.155,.098))
    GRAIN = mat('DarkOak', (.105,.075,.041))
    ROPE = mat('DryWillow', (.26,.205,.133))
    TERRA = mat('FiredClay', (.265,.135,.079))
    CERAMIC = mat('AshGlaze', (.085,.145,.125))
    CERAMIC.node_tree.nodes.get('Principled BSDF').inputs['Roughness'].default_value=.29
if TRAVEL:
    CLOTH = mat('WeatheredCanvas', (.09,.17,.145))
    JADE = mat('BlanketSeam', (.085,.125,.10))
    LEATHER = mat('WornLeather', (.18,.085,.035))
    AMBER = mat('LanternLight', (.52,.26,.075), glow=.55)


def add(obj, name, material):
    obj.name = name
    obj.data.materials.clear()
    obj.data.materials.append(material)
    parts.append(obj)
    return obj


def mesh(name, vertices, faces, material):
    data = bpy.data.meshes.new(name)
    data.from_pydata(vertices, [], faces)
    data.update()
    uv = data.uv_layers.new(name='UVMap')
    for face in data.polygons:
        axes = [a for a in range(3) if a != max(range(3),key=lambda i:abs(face.normal[i]))]
        for loop in face.loop_indices:
            p = data.vertices[data.loops[loop].vertex_index].co
            uv.data[loop].uv = (p[axes[0]], p[axes[1]])
    obj = bpy.data.objects.new(name, data)
    scene.collection.objects.link(obj)
    return add(obj,name,material)


def box(name, pos, scale, material, bevel=.025):
    bpy.ops.mesh.primitive_cube_add(size=1, location=pos)
    obj = add(bpy.context.object, name, material)
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        modifier = obj.modifiers.new('WornEdges','BEVEL')
        modifier.width = bevel
        modifier.segments = 4 if TRAVEL or VILLAGE else 1
        bpy.ops.object.modifier_apply(modifier=modifier.name)
    return obj


def lathe(name, profile, material, pos=(0,0,0), sides=16):
    verts = [(pos[0]+r*math.cos(i*math.tau/sides),pos[1]+r*math.sin(i*math.tau/sides),pos[2]+z)
             for r,z in profile for i in range(sides)]
    faces=[]
    for j in range(len(profile)-1):
        for i in range(sides):
            a=j*sides+i; b=j*sides+(i+1)%sides
            faces.append((a,b,b+sides,a+sides))
    return mesh(name,verts,faces,material)


def tube(name, points, radius, material, sides=8):
    points = [Vector(p) for p in points]
    verts=[]; faces=[]
    for j,p in enumerate(points):
        tangent=(points[min(j+1,len(points)-1)]-points[max(0,j-1)]).normalized()
        axis=tangent.cross(Vector((0,1,.13))).normalized()
        other=tangent.cross(axis).normalized()
        rad = radius[j] if isinstance(radius,list) else radius
        for i in range(sides):
            a=i*math.tau/sides
            verts.append(p+(axis*math.cos(a)+other*math.sin(a))*rad)
        if j:
            for i in range(sides):
                a=(j-1)*sides+i; b=(j-1)*sides+(i+1)%sides
                faces.append((a,b,b+sides,a+sides))
    faces.extend([tuple(reversed(range(sides))),tuple((len(points)-1)*sides+i for i in range(sides))])
    return mesh(name,verts,faces,material)


def sphere(name, pos, scale, material, subdivisions=1):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivisions,radius=1,location=pos)
    obj=add(bpy.context.object,name,material); obj.scale=scale
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    return obj


def ring(name, pos, radius, thickness, material, rotation=None):
    bpy.ops.mesh.primitive_torus_add(major_radius=radius,minor_radius=thickness,
                                   major_segments=24,minor_segments=6,location=pos)
    obj=add(bpy.context.object,name,material)
    if rotation: obj.rotation_euler=rotation
    return obj


def blade(start, end, width, material):
    a=Vector(start); b=Vector(end); axis=(b-a).normalized()
    side=axis.cross(Vector((0,0,1))).normalized()*width
    middle=a.lerp(b,.53)
    return mesh('LeafBlade',[a,middle+side,b,middle-side,middle+Vector((0,0,width*.32))],
                [(0,1,4),(1,2,4),(2,3,4),(3,0,4)],material)


def rock(pos, scale, moss=True):
    obj=sphere('FacetedStone',pos,scale,STONE,2)
    for v in obj.data.vertices:
        v.co *= rng.uniform(.90,1.08)
    obj.data.update()
    if moss:
        obj.data.materials.append(MOSS)
        for face in obj.data.polygons:
            if face.normal.z > .36 and face.center.x < scale[0]*.24 and face.center.y > -scale[1]*.43:
                face.material_index = 1
        upper = [p for p in obj.data.polygons if p.normal.z > .55]
        for face in rng.sample(upper, min(3, len(upper))):
            patch=sphere('MossPatch',obj.location+face.center+face.normal*.008,
                         (scale[0]*rng.uniform(.16,.28),scale[1]*.18,.023),MOSS,1)
            patch.rotation_euler=face.normal.to_track_quat('Z','Y').to_euler()


def mushroom(pos, height, radius, capmat):
    x,y,z=pos
    tube('CurvedStem',[(x,y,z),(x+.025,y,z+height*.45),(x-.035,y,z+height*.80)],
         [radius*.15,radius*.12,radius*.10],CREAM)
    profile=[(.01,0),(radius*.65,-.035),(radius,-.005),(radius*.94,.08*height),
             (radius*.7,.26*height),(radius*.28,.40*height),(0,.43*height)]
    lathe('MushroomCap',profile,capmat,(x-.035,y,z+height*.76))
    lathe('Gills',[(0,0),(radius*.85,0)],CREAM,(x-.035,y,z+height*.735))
    for k in range(7):
        angle=k*2.39996; dist=radius*(.22+.52*(k%3)/2)
        sphere('CapSpeckle',(x-.035+math.cos(angle)*dist,y+math.sin(angle)*dist,
                             z+height*(1.12-.22*dist/radius)),(.032,.026,.012),CREAM)


def fern(curl=False):
    count=7 if not curl else 5
    for i in range(count):
        angle=i*math.tau/count+.19
        axis=Vector((math.cos(angle),math.sin(angle),0))
        length=.78 if not curl else .62
        pts=[axis*(length*t)+Vector((0,0,.03+math.sin(t*math.pi*.70)*(.46 if curl else .35))) for t in [j/9 for j in range(10)]]
        tube('FrondStem',pts,.012,JADE,5)
        for j in range(1,9):
            p=pts[j]; width=.18*math.sin(j/10*math.pi)
            cross=Vector((-axis.y,axis.x,.12))
            for side in (-1,1):
                blade(p,p+cross*side*width+axis*.085,width*.28,TIP if j%3==0 else LEAF)
    if curl:
        for angle in (0,2.2,4.5):
            points=[]
            for j in range(21):
                t=j/20; r=.13*(1-t)+.025
                points.append((math.cos(angle)*.16+r*math.cos(t*math.tau*1.25),
                               math.sin(angle)*.16,.40+t*.25+r*math.sin(t*math.tau*1.25)))
            tube('Fiddlehead',[(points[0][0],points[0][1],.01)]+points,.018,TIP,6)


def flower(violet=False):
    for k in range(5):
        angle=k*2.4; x=.20*math.cos(angle); y=.20*math.sin(angle); h=.37+(k%3)*.12
        tube('FlowerStem',[(x,y,0),(x+.04,y,h*.6),(x,y,h)],.012,JADE,5)
        for side in (-1,1): blade((x,y,h*.35),(x+side*.15,y+.045,h*.55),.055,LEAF)
        for p in range(5):
            a=p*math.tau/5
            blade((x,y,h),(x+math.cos(a)*.105,y+math.sin(a)*.105,h+.055),.048,PETAL if violet else BLUE)
        sphere('FlowerHeart',(x,y,h+.045),(.04,.04,.045),CYAN,1)


def log_segment(a,b,r=.13):
    if VILLAGE:
        a=Vector(a); b=Vector(b)
        sides=20; rings=17; verts=[]; faces=[]
        seed=rng.random()*8
        for j in range(rings):
            t=j/(rings-1); center=a.lerp(b,t)
            for k in range(sides):
                angle=k*math.tau/sides
                radius=r*(1+.10*math.sin(k*2.4+seed)+.035*math.sin(t*12+k))
                z=min(math.sin(angle)*radius,r*.42)
                q=center+Vector((.009*math.sin(k*2+seed) if j in (0,rings-1) else 0,math.cos(angle)*radius,z))
                verts.append(q)
        for j in range(rings-1):
            for k in range(sides):
                n=(k+1)%sides
                faces.append((j*sides+k,j*sides+n,(j+1)*sides+n,(j+1)*sides+k))
        faces.extend([tuple(reversed(range(sides))),tuple((rings-1)*sides+k for k in range(sides))])
        obj=mesh('SplitSeasonedFirewood',verts,faces,BARK); obj.data.materials.append(WOOD)
        for face in obj.data.polygons:
            if face.normal.z>.85 or abs(face.normal.x)>.85: face.material_index=1
        for k in range(9):
            angle=math.pi+k*math.pi/8
            points=[a.lerp(b,j/12)+Vector((0,math.cos(angle)*(r+.004),math.sin(angle)*(r+.004))) for j in range(13)]
            tube('BarkFissure',points,.0025,GRAIN,5)
        return
    tube('SplitBark',[a,b],r,BARK,10)
    axis=(Vector(b)-Vector(a)).normalized()
    for p in (Vector(a)-axis*.004,Vector(b)+axis*.004):
        end=tube('CutEnd',[p,p+axis*.006],r*.84,WOOD,12)


def hollow_log():
    obj=lathe('HollowLog',[(.32,0),(.36,.15),(.34,1.45),(.30,1.65),(.21,1.65),(.23,.12),(.32,0)],BARK,sides=14)
    obj.rotation_euler.y=math.pi/2; obj.location=(-.825,0,.36)
    for x in (-.835,.825):
        ring('ExposedRim',(x,0,.36),.267,.042,WOOD,(0,math.pi/2,0))
    for k in range(7):
        a=k*math.pi/7
        tube('BarkRidge',[(-.66,math.cos(a)*.34,.36+math.sin(a)*.34),(.70,math.cos(a)*.34,.36+math.sin(a)*.34)],.018,GRAIN,5)
    tube('BrokenStub',[(.1,.0,.57),(.18,.08,.93)], [.14,.055],BARK)
    for x in (-.4,.12,.45): sphere('Moss', (x,-.03,.70),(.23,.14,.035),MOSS)


def flask():
    sphere('FlaskBody',(0,0,.28),(.25,.115,.27),LEATHER,4 if TRAVEL else 2)
    lathe('Neck',[(.07,0),(.07,.15),(.085,.16),(.085,.20),(.045,.20)],GOLD,(0,0,.46),12)
    lathe('Cork',[(0,0),(.045,0),(.043,.08),(0,.08)],WOOD,(0,0,.64),10)
    strap=[(-.20,0,.35),(-.28,.02,.74),(.15,.02,.85),(.23,0,.38)]
    if TRAVEL:
        strap=[(-.23*math.cos(i*math.pi/24),.018*math.sin(i*.3),.36+.43*math.sin(i*math.pi/24)) for i in range(25)]
    tube('ShoulderStrap',strap,.012 if TRAVEL else .019,LEATHER)
    ring('FlaskSeal',(0,-.113,.30),.072,.012,GOLD,(math.pi/2,0,0))
    if TRAVEL:
        for i in range(36):
            a=i*math.tau/36
            tube('HandStitch',[(.236*math.cos(a),-.04,.28+.251*math.sin(a)),(.242*math.cos(a),-.052,.28+.257*math.sin(a))],.0025,ROPE,5)


def backpack():
    box('CanvasPack',(0,0,.38),(.58,.30,.67),CLOTH,.09)
    box('OverhangingFlap',(0,-.03,.69),(.60,.35,.15),LEATHER,.05)
    for x in (-.18,.18):
        box('FrontStrap',(x,-.171,.39),(.045,.025,.54),LEATHER,.006)
        box('BrassBuckle',(x,-.195,.43),(.085,.025,.085),GOLD,.01)
        box('BuckleInset',(x,-.212,.43),(.045,.012,.045),LEATHER,.001)
        tube('ShoulderLoop',[(x,.15,.62),(x,.27,.48),(x,.24,.13),(x,.15,.12)],.025,LEATHER)
    box('FrontPocket',(0,-.21,.22),(.25,.12,.22),CLOTH,.03)
    tube('GrabHandle',[(-.09,0,.76),(-.07,0,.84),(.07,0,.84),(.09,0,.76)],.026,LEATHER)
    if TRAVEL:
        for x in (-.115,.115):
            for j in range(12):
                z=.135+j*.014
                tube('PocketStitch',[(x,-.273,z),(x,-.273,z+.006)],.0018,ROPE,5)
        for x in (-.18,.18):
            for z in (.25,.29,.33):
                sphere('StrapHole',(x,-.186,z),(.006,.002,.006),IRON,2)
            box('BuckleTongue',(x,-.23,.43),(.007,.008,.061),GOLD,.002)


def bedroll():
    profile=[(0,0),(.22,0),(.24,.12),(.24,.65),(.22,.78),(0,.78)]
    if TRAVEL:
        profile=[(0,0)]+[(.223+.012*math.sin(j*.8),j*.78/24) for j in range(25)]+[(0,.78)]
    obj=lathe('RolledBlanket',profile,CLOTH,sides=48 if TRAVEL else 16)
    obj.rotation_euler.y=math.pi/2; obj.location=(-.39,0,.24)
    for x in (-.22,.22): ring('BindingStrap',(x,0,.24),.247,.025,LEATHER,(0,math.pi/2,0))
    for x in ((-.408,.408) if TRAVEL else (-.395,.395)):
        pts=[]
        for j in range(45):
            t=j/44; a=t*math.tau*2.6; r=.025+.185*t
            pts.append((x,math.cos(a)*r,.24+math.sin(a)*r))
        tube('BlanketSpiral',pts,.012,JADE,5)
    if TRAVEL:
        for x in (-.22,.22):
            box('RollBuckle',(x,-.248,.24),(.075,.025,.10),GOLD,.009)
            box('RollBuckleInset',(x,-.264,.24),(.042,.005,.065),LEATHER,.005)


def lantern():
    lathe('LanternBase',[(0,0),(.22,0),(.24,.04),(.18,.10),(.17,.13),(0,.13)],IRON,sides=8)
    lathe('AmberPane',[(.135,.12),(.15,.20),(.15,.46),(.12,.53)],AMBER,sides=8)
    for i in range(4):
        a=math.pi/4+i*math.pi/2
        tube('LanternFrame',[(math.cos(a)*.17,math.sin(a)*.17,.10),(math.cos(a)*.17,math.sin(a)*.17,.51)],.025,IRON)
    lathe('LanternRoof',[(0,.50),(.23,.50),(.23,.55),(.10,.68),(0,.68)],IRON,sides=8)
    ring('Handle',(0,0,.79),.115,.018,GOLD,(math.pi/2,0,0))
    for z in (.15,.47): ring('FrameBand',(0,0,z),.175,.016,GOLD)


def barrel():
    for i in range(14):
        a=i*math.tau/14; delta=math.tau/14*.47
        profile=[(.29,0),(.35,.17),(.38,.44),(.34,.72),(.29,.84)]
        if VILLAGE:
            profile=[(.29+.083*math.sin(j*math.pi/16)+.003*math.sin(i*4+j*1.3),j*.84/16) for j in range(17)]
        verts=[(r*math.cos(t),r*math.sin(t),z) for r,z in profile for t in (a-delta,a+delta)]
        faces=[(j*2,j*2+1,j*2+3,j*2+2) for j in range(len(profile)-1)]
        obj=mesh('BarrelStave',verts,faces,WOOD if i%3 else GRAIN)
        if VILLAGE:
            bpy.context.view_layer.objects.active=obj
            mod=obj.modifiers.new('StaveThickness','SOLIDIFY'); mod.thickness=.024
            bpy.ops.object.modifier_apply(modifier=mod.name)
    for z,r in ((.10,.33),(.26,.38),(.66,.37),(.78,.32)):
        if VILLAGE: r=.29+.083*math.sin(z/.84*math.pi)+.005
        profile=[(r,z-.025),(r,z+.025)]
        if VILLAGE:
            outer=[(.29+.083*math.sin(h/.84*math.pi)+.011,h) for h in [z-.025+j*.01 for j in range(6)]]
            profile=outer+[(radius-.012,h) for radius,h in reversed(outer)]+[outer[0]]
        lathe('IronHoop',profile,IRON,sides=28)
        if VILLAGE:
            for a in (0,1.8,3.5,5): sphere('HoopRivet',(r*math.cos(a),r*math.sin(a),z),(.009,.009,.009),IRON,2)
    lathe('Lid',[(0,.83),(.29,.83)],GRAIN,sides=14)
    for x in (-.18,-.06,.06,.18):
        length=2*math.sqrt(.28**2-x*x)
        box('LidPlank',(x,0,.843),(.105,length,.022),WOOD,.006)
    lathe('WoodTap',[(0,0),(.047,0),(.047,.07),(0,.07)],GRAIN,(.11,.08,.86),10)


def basket():
    if VILLAGE:
        lathe('BasketFloor',[(0,0),(.26,0),(.26,.035),(0,.035)],GRAIN,sides=40)
        for j in range(18):
            z=.04+j*.022
            points=[]
            for k in range(129):
                a=k*math.tau/128; r=.27+z*.23+.009*math.cos(a*20+j*math.pi)+.006*math.sin(a*3+z*4)
                points.append((r*math.cos(a),r*math.sin(a),z+.003*math.sin(a*3+j*.3)))
            tube('WovenWillow',points,.010,ROPE if j%3 else WOOD,5)
        for k in range(20):
            a=k*math.tau/20
            tube('BasketRib',[(r*math.cos(a),r*math.sin(a),z) for r,z in ((.27,.025),(.31,.20),(.364,.45))],.009,GRAIN,5)
        ring('BoundRim',(0,0,.45),.367,.021,ROPE)
        tube('BentHandle',[(.363*math.cos(j*math.pi/32),.008*math.sin(j),.45+.36*math.sin(j*math.pi/32)) for j in range(33)],.021,WOOD,8)
        return
    lathe('BasketInside',[(0,0),(.28,0),(.37,.43),(.34,.45),(.25,.03),(0,.03)],GRAIN,sides=20)
    for j in range(9):
        z=.045+j*.048; radius=.28+z*.21
        ring('WickerRing',(0,0,z),radius,.014,ROPE)
    for k in range(16):
        a=k*math.tau/16
        tube('WickerUpright',[(.28*math.cos(a),.28*math.sin(a),.025),(.37*math.cos(a),.37*math.sin(a),.45)],.014,WOOD,5)
    ring('BasketRim',(0,0,.46),.37,.024,ROPE)
    pts=[(.36*math.cos(t),0,.46+.39*math.sin(t)) for t in [j*math.pi/16 for j in range(17)]]
    tube('BasketHandle',pts,.029,ROPE)


def jar(tall=False):
    s=1.3 if tall else 1
    profile=[(0,0),(.16,0),(.22,.05),(.31,.25),(.29,.43),(.16,.55),(.14,.65),(.17,.68),(.17,.72),(.125,.72),(.12,.63),(.15,.58),(.25,.42),(.26,.22),(.14,.05),(0,.05)]
    obj=lathe('HollowPot',[(r*(.82 if tall else 1),z*s) for r,z in profile],CERAMIC if tall else TERRA,sides=48 if VILLAGE else 20)
    if VILLAGE:
        bpy.context.view_layer.objects.active=obj
        mod=obj.modifiers.new('WheelThrownSurface','SUBSURF'); mod.levels=1
        bpy.ops.object.modifier_apply(modifier=mod.name)
    for side in (-1,1):
        if VILLAGE:
            points=[(side*((.105 if tall else .135)+.05*j/20+.18*math.sin(j*math.pi/20)),0,(.58-.28*j/20)*s) for j in range(21)]
            tube('CeramicHandle',points,.029,CERAMIC if tall else TERRA,10)
            continue
        tube('PotHandle',[(side*.16,0,.58*s),(side*.34,0,.55*s),(side*.38,0,.36*s),(side*.27,0,.30*s)],.033,ROPE if tall else TERRA)
    if not VILLAGE:
        lathe('PaintedBand',[(.303*(.82 if tall else 1),.26*s),(.304*(.82 if tall else 1),.30*s)],CREAM,sides=20)


def signpost():
    tube('CrookedPost',[(0,0,0),(-.06,0,.75),(.03,0,1.60)], [.10,.08,.065],WOOD)
    for z,side in ((1.27,1),(1.02,-1)):
        verts=[(-.47,-.04,z-.10),(.39,-.04,z-.10),(.55,-.04,z),(.39,-.04,z+.10),(-.47,-.04,z+.10)]
        if side<0: verts=[(-x,y,z) for x,y,z in verts]
        obj=mesh('ArrowBoard',verts,[(0,1,2,3,4)],GRAIN)
        sol=obj.modifiers.new('BoardThickness','SOLIDIFY'); sol.thickness=.07
        bpy.context.view_layer.objects.active=obj; bpy.ops.object.modifier_apply(modifier=sol.name)
        for x in (-.08,.08): sphere('IronNail',(x,-.06,z),(.017,.017,.017),IRON)
        for x in (-.28,-.16,.17): box('CarvedWaymark',(x,-.061,z),(.05,.008,.075),CREAM,.002)
    rock((.05,.02,.09),(.24,.21,.12),False)


def bellpost():
    tube('BellPost',[(0,0,0),(.025,0,1.35)],.065,WOOD)
    tube('CrossBeam',[(-.13,0,1.31),(.47,0,1.31)],.048,GRAIN)
    tube('BellCord',[(.35,0,1.3),(.35,0,1.08)],.009,ROPE,5)
    moving_start=len(parts)
    lathe('BrassBell',[(.16,0),(.17,.035),(.12,.07),(.095,.22),(.05,.28),(0,.29)],GOLD,(.35,0,.77),16)
    sphere('BellClapper',(.35,0,.78),(.042,.042,.055),IRON)
    ring('BellRim',(.35,0,.80),.17,.012,GOLD)
    moving=list(parts[moving_start:])
    tube('HangingRibbon',[(.36,0,.78),(.36,.04,.55),(.43,0,.42)],.012,CLOTH,5)
    moving.append(parts[-1])
    return moving,Vector((.35,0,1.08))


def rune(pos, scale=1):
    x,y,z=pos
    for coords in [[(-.09,0),(.0,.16),(.09,0),(.0,-.12),(-.09,0)],[(0,.16),(0,.28)],[(-.12,-.19),(.12,-.19)]]:
        tube('RuneInlay',[(x+a*scale,y,z+b*scale) for a,b in coords],.012*scale,CYAN,5)


def relic(kind):
    if kind=='shard':
        rock((0,0,.22),(.42,.28,.30),True)
        shard=mesh('BrokenRuneStone',[(-.28,-.17,0),(.27,-.17,0),(.24,.15,0),(-.27,.15,0),(-.22,-.13,.95),(.06,-.13,1.24),(.26,.11,.80),(-.20,.14,.96)],
                   [(0,3,2,1),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(4,5,6,7)],STONE_LIGHT)
        rune((0,-.175,.61),1)
    elif kind=='stele':
        box('BuriedPedestal',(0,0,.10),(.88,.52,.20),STONE,.055)
        obj=box('AncientStele',(0,.02,.67),(.63,.27,1.18),STONE_LIGHT,.085)
        obj.rotation_euler.y=-.08
        rune((0,-.13,.83),1.4)
        for x in (-.35,.28): rock((x,-.04,.10),(.23,.23,.14),True)
        tube('StoneFracture',[(-.24,-.145,1.07),(-.12,-.145,.94),(-.15,-.145,.81)],.008,STONE)
    else:
        lathe('AltarBase',[(0,0),(.67,0),(.69,.12),(.57,.19),(0,.19)],STONE,sides=8)
        for a in (0,math.pi/2,math.pi,math.pi*1.5):
            box('BrokenColumn',(.37*math.cos(a),.37*math.sin(a),.36),(.16,.16,.38),STONE_LIGHT,.025)
        lathe('OfferingBowl',[(0,.54),(.40,.54),(.50,.65),(.47,.75),(.40,.75),(.35,.63),(0,.60)],STONE_LIGHT,sides=12)
        lathe('StillPool',[(0,.622),(.345,.622)],JADE,sides=20)
        for a in (0,2.1,4.2):
            sphere('RunePebble',(.18*math.cos(a),.18*math.sin(a),.65),(.048,.04,.02),CYAN)
        rune((0,-.56,.30),.65)


def travel_finish(obj, name):
    """Bake surface wear while retaining metal and emissive material identities."""
    from mathutils import noise
    if name.startswith('13_'):
        bpy.context.view_layer.objects.active=obj
        subdiv=obj.modifiers.new('CanvasFolds','SUBSURF'); subdiv.subdivision_type='SIMPLE'; subdiv.levels=1
        bpy.ops.object.modifier_apply(modifier=subdiv.name)
    for vertex in obj.data.vertices:
        p=vertex.co
        if name.startswith('13_'):
            p.y += .008*noise.noise(Vector((p.x*24,p.y*5,p.z*36)))
            p.x += .004*math.sin(p.z*23+p.y*7)
        if VILLAGE and name.startswith(('20_','21_')):
            amount=.0028*noise.noise(Vector((p.x*12,p.y*12,p.z*8)))+.0015*math.sin(p.z*130)
            p.x*=1+amount*4; p.y*=1+amount*4
            p.x+=.004*math.sin(p.z*5)
    for face in obj.data.polygons:
        face.use_smooth=True
    bpy.context.view_layer.objects.active=obj
    tri=obj.modifiers.new('ExportTriangles','TRIANGULATE')
    bpy.ops.object.modifier_apply(modifier=tri.name)
    bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=1.1,island_margin=.012)
    bpy.ops.object.mode_set(mode='OBJECT')
    originals=list(obj.data.materials)
    for idx,original in enumerate(originals):
        material=original.copy(); obj.data.materials[idx]=material
        nodes=material.node_tree.nodes; links=material.node_tree.links
        shader=nodes.get('Principled BSDF'); base=tuple(shader.inputs['Base Color'].default_value)
        tex=nodes.new('ShaderNodeTexNoise'); tex.inputs['Scale'].default_value=85 if original==CLOTH else 35
        if VILLAGE and original in (WOOD,GRAIN,BARK,ROPE):
            coords=nodes.new('ShaderNodeTexCoord'); scale=nodes.new('ShaderNodeVectorMath'); scale.operation='MULTIPLY'
            scale.inputs[1].default_value=(.065,3,3) if name.startswith('19_') else (3,3,.065)
            links.new(coords.outputs['Generated'],scale.inputs[0]); links.new(scale.outputs[0],tex.inputs['Vector'])
        tex.inputs['Detail'].default_value=3
        ramp=nodes.new('ShaderNodeValToRGB')
        ramp.color_ramp.elements[0].color=tuple(c*.64 for c in base[:3])+(1,)
        ramp.color_ramp.elements[1].color=tuple(min(1,c*1.24) for c in base[:3])+(1,)
        links.new(tex.outputs['Fac'],ramp.inputs[0]); links.new(ramp.outputs[0],shader.inputs['Base Color'])
        bump=nodes.new('ShaderNodeBump'); bump.inputs['Strength'].default_value=.24; bump.inputs['Distance'].default_value=.008
        links.new(tex.outputs['Fac'],bump.inputs['Height']); links.new(bump.outputs[0],shader.inputs['Normal'])
        if VILLAGE:
            ramp.color_ramp.elements[0].position=.28
            ramp.color_ramp.elements[1].position=.72
            ramp.color_ramp.elements[0].color=tuple(c*.33 for c in base[:3])+(1,)
            ramp.color_ramp.elements[1].color=tuple(min(1,c*1.5) for c in base[:3])+(1,)
            bump.inputs['Strength'].default_value=.55 if original in (WOOD,GRAIN,BARK) else .22
            bump.inputs['Distance'].default_value=.017 if original==BARK else .006
            rough=nodes.new('ShaderNodeMapRange')
            rough.inputs['To Min'].default_value=.18 if original==CERAMIC else .61
            rough.inputs['To Max'].default_value=.46 if original==CERAMIC else .95
            links.new(tex.outputs['Fac'],rough.inputs['Value']); links.new(rough.outputs[0],shader.inputs['Roughness'])
            if original in (CERAMIC,TERRA,IRON):
                tex.inputs['Scale'].default_value=7
                fine=nodes.new('ShaderNodeTexNoise'); fine.inputs['Scale'].default_value=180
                links.new(fine.outputs['Fac'],bump.inputs['Height'])
            if original in (CERAMIC,TERRA):
                ramp.color_ramp.elements[0].color=tuple(c*.78 for c in base[:3])+(1,)
                ramp.color_ramp.elements[1].color=tuple(c*1.15 for c in base[:3])+(1,)
                bump.inputs['Distance'].default_value=.002
            if original==IRON:
                ramp.color_ramp.elements[0].color=(.032,.038,.039,1)
                ramp.color_ramp.elements[1].color=(.15,.085,.039,1)
    scene.render.engine='CYCLES'; scene.cycles.samples=8; scene.render.bake.margin=8
    texture_dir=ART/'textures'; texture_dir.mkdir(exist_ok=True)
    images={}
    for kind in ('BaseColor','Normal','Roughness'):
        image=bpy.data.images.new(name+'_'+kind,width=1024,height=1024,alpha=False)
        image.colorspace_settings.name='sRGB' if kind=='BaseColor' else 'Non-Color'
        for material in obj.data.materials:
            target=material.node_tree.nodes.new('ShaderNodeTexImage'); target.image=image; material.node_tree.nodes.active=target
        if kind=='BaseColor': bpy.ops.object.bake(type='DIFFUSE',pass_filter={'COLOR'})
        else: bpy.ops.object.bake(type='NORMAL' if kind=='Normal' else 'ROUGHNESS')
        image.filepath_raw=str(texture_dir/(name+'_'+kind+'.png')); image.file_format='PNG'; image.save(); image.pack(); images[kind]=image
    for idx,original in enumerate(originals):
        material=original.copy(); material.name=name+'_'+original.name; obj.data.materials[idx]=material
        nodes=material.node_tree.nodes; links=material.node_tree.links; shader=nodes.get('Principled BSDF')
        for kind,image in images.items():
            tex=nodes.new('ShaderNodeTexImage'); tex.image=image
            if kind=='Normal':
                normal=nodes.new('ShaderNodeNormalMap'); normal.inputs['Strength'].default_value=.65
                links.new(tex.outputs[0],normal.inputs[1]); links.new(normal.outputs[0],shader.inputs['Normal'])
            else: links.new(tex.outputs[0],shader.inputs['Base Color' if kind=='BaseColor' else 'Roughness'])


SPECS=[
('01_Fern_Spread','plants','fern'),('02_Fern_Fiddlehead','plants','curl'),
('03_Mushrooms_Russet','plants','mush_red'),('04_Mushrooms_Azure','plants','mush_blue'),
('05_Mushrooms_Shelf','plants','mush_shelf'),('06_Flowers_Starlight','plants','flower'),
('07_Flowers_Dusk','plants','violet'),('08_MossRock_Broad','nature','rock_broad'),
('09_MossRock_Split','nature','rock_split'),('10_MossRock_Pebbles','nature','pebbles'),
('11_Fallen_Branch','nature','branch'),('12_Hollow_Log','nature','log'),
('13_Traveler_Backpack','travel','backpack'),('14_Rolled_Bedroll','travel','bedroll'),
('15_Old_Lantern','travel','lantern'),('16_Leather_Flask','travel','flask'),
('17_Staved_Barrel','village','barrel'),('18_Wicker_Basket','village','basket'),
('19_Firewood_Stack','village','woodpile'),('20_Terracotta_Jar','village','jar'),
('21_Glazed_Amphora','village','amphora'),('22_Crooked_Signpost','wayfinding','sign'),
('23_Trail_Cairn','wayfinding','cairn'),('24_Hanging_Bellpost','wayfinding','bell'),
('25_Rune_Shard','relics','shard'),('26_Buried_Stele','relics','stele'),
('27_Offering_Altar','relics','altar')]
manifest=[]; roots=[]
for name,category,kind in SPECS:
    if category != ('village' if VILLAGE else ('travel' if TRAVEL else 'plants')):
        continue
    parts=[]; moving=[]; pivot=None
    if kind in ('fern','curl'): fern(kind=='curl')
    elif kind.startswith('mush_'):
        if kind=='mush_shelf':
            tube('OldStump',[(0,0,0),(.02,0,.56)],[.18,.13],BARK,10)
            for x,y,z,r in [(-.10,0,.14,.24),(.1,-.02,.28,.22),(-.07,.03,.42,.19)]:
                mushroom((x,y,z),.12,r,RED if z<.2 else WOOD)
        else:
            for x,y,h,r in [(-.18,0,.46,.21),(.14,.06,.65,.28),(.08,-.19,.28,.14)]:
                mushroom((x,y,0),h,r,RED if kind=='mush_red' else BLUE)
    elif kind in ('flower','violet'): flower(kind=='violet')
    elif kind=='rock_broad': rock((0,0,.20),(.55,.43,.25))
    elif kind=='rock_split':
        for side in (-1,1):
            verts=[(side*x,y,z) for x,y,z in [(.035,-.30,0),(.40,-.27,.02),(.45,.24,0),(.035,.31,0),
                    (.04,-.24,.56),(.31,-.20,.44),(.34,.20,.40),(.04,.24,.53)]]
            faces=[(0,3,2,1),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(4,5,6,7)]
            if side<0: faces=[tuple(reversed(f)) for f in faces]
            mesh('SplitStone',verts,faces,STONE if side==1 else STONE_LIGHT)
            for y in (-.13,.09):
                sphere('MossLip',(side*.22,y,.48),(.14,.12,.025),MOSS,1)
    elif kind=='pebbles':
        for x,y,s in [(-.25,0,.22),(.12,.13,.27),(.22,-.16,.16),(-.05,-.25,.12)]: rock((x,y,s*.45),(s,s*.8,s*.5))
    elif kind=='branch':
        tube('ForkedBranch',[(-.66,0,.10),(-.17,.06,.10),(.34,.02,.13),(.69,.1,.15)],[.09,.08,.05,.025],BARK)
        tube('SideTwig',[(-.05,.05,.11),(.11,.30,.17),(.36,.48,.20)],[.055,.03,.012],BARK)
        tube('PaleBreak',[(-.67,0,.10),(-.68,0,.10)],.075,WOOD)
    elif kind=='log': hollow_log()
    elif kind=='backpack': backpack()
    elif kind=='bedroll': bedroll()
    elif kind=='lantern': lantern(); moving=list(parts); pivot=Vector((0,0,.90))
    elif kind=='flask': flask()
    elif kind=='barrel': barrel()
    elif kind=='basket': basket()
    elif kind=='woodpile':
        for y,z in [(-.24,.14),(0,.14),(.24,.14),(-.12,.36),(.12,.36),(0,.56)]: log_segment((-.48,y,z),(.48+rng.uniform(-.08,.08),y,z),.125)
    elif kind in ('jar','amphora'): jar(kind=='amphora')
    elif kind=='sign': signpost()
    elif kind=='cairn':
        for x,z,s in [(0,.10,.31),(.035,.28,.25),(-.045,.44,.18),(.005,.58,.11)]: rock((x,0,z),(s,s*.75,s*.50),False)
    elif kind=='bell': moving,pivot=bellpost()
    else: relic(kind)
    root=bpy.data.objects.new(name,None); scene.collection.objects.link(root)
    root['asset_role']='Independent fantasy prop'
    root['category']=category
    # Join authored details into a static mesh and an optional moving mesh.
    groups=[('Body',[p for p in parts if p not in moving]),('Moving',moving)]
    children=[]
    for group_name,objects in groups:
        if not objects: continue
        bpy.ops.object.select_all(action='DESELECT')
        for obj in objects: obj.select_set(True)
        bpy.context.view_layer.objects.active=objects[0]
        bpy.ops.object.join()
        obj=bpy.context.object; obj.name=name+'_'+group_name
        bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
        obj.parent=root; children.append(obj)
        if TRAVEL or VILLAGE:
            travel_finish(obj,name)
    animated=kind in ('fern','curl','flower','violet','lantern','bell')
    if kind in ('fern','curl','flower','violet'):
        obj=children[0]; obj.shape_key_add(name='Basis'); key=obj.shape_key_add(name='Breeze')
        for i,vertex in enumerate(key.data):
            p=obj.data.vertices[i].co; weight=max(0,p.z)**1.6
            vertex.co.x+=.06*weight; vertex.co.y+=.025*weight
        key.slider_min=-1
        for frame in range(1,122,5):
            key.value=math.sin((frame-1)*math.tau/120); key.keyframe_insert(data_path='value',frame=frame)
        obj.data.shape_keys.animation_data.action.name=name+'_Breeze'
    elif animated:
        obj=next(o for o in children if o.name.endswith('_Moving'))
        obj.data.transform(Matrix.Translation(-pivot)); obj.location=pivot
        for frame in range(1,122,5):
            obj.rotation_euler.y=math.sin((frame-1)*math.tau/120)*(.06 if kind=='lantern' else .10)
            obj.keyframe_insert(data_path='rotation_euler',frame=frame)
        obj.animation_data.action.name=name+'_Sway'
    scene.frame_set(1)
    bpy.context.view_layer.update()
    all_points=[obj.matrix_world@v.co for obj in children for v in obj.data.vertices]
    low=[min(p[a] for p in all_points) for a in range(3)]
    high=[max(p[a] for p in all_points) for a in range(3)]
    # Keep the root at ground level while preserving any moving pivot.
    for obj in children:
        if animated and obj.name.endswith('_Moving'): obj.location.z-=low[2]
        else: obj.data.transform(Matrix.Translation((0,0,-low[2])), shape_keys=True)
    bpy.ops.object.select_all(action='DESELECT'); root.select_set(True)
    for obj in children: obj.select_set(True)
    bpy.context.view_layer.objects.active=root
    bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',
        use_selection=True,use_active_scene=True,export_extras=True,
        export_animations=animated,export_animation_mode='ACTIVE_ACTIONS',
        export_frame_range=True,export_force_sampling=True,export_anim_slide_to_zero=True)
    root.asset_mark(); root.asset_data.description='Reusable fantasy '+category+' prop'
    triangles=sum(len(poly.vertices)-2 for obj in children for poly in obj.data.polygons)
    manifest.append(dict(name=name,category=category,animated=animated,triangles=triangles,
        size=[round(high[a]-low[a],3) for a in range(3)],
        center=[round((low[0]+high[0])/2,3),round((low[1]+high[1])/2,3),round((high[2]-low[2])/2,3)]))
    roots.append(root)

previous = json.loads((OUT/'manifest.json').read_text(encoding='utf-8')) if (OUT/'manifest.json').exists() else []
entries = {item['name']: item for item in previous}
entries.update({item['name']: item for item in manifest})
(OUT/'manifest.json').write_text(json.dumps(sorted(entries.values(),key=lambda item:item['name']),indent=2),encoding='utf-8')
# Contact sheet staging only; all reusable files above remain full-size standalone assets.
display_mat=mat('DisplayTile',(.16,.21,.22))
columns = 3 if VILLAGE or SELECTED == 'Natural_Debris' else 4
for i,root in enumerate(roots):
    root.location=((i%columns-(columns-1)*.5)*2.6,(i//columns)*2.8,0)
    parts=[]
    base=box('Display_'+root.name,(root.location.x,root.location.y,-.08),(2.35,2.20,.10),display_mat,.04)
world=bpy.data.worlds.new('FantasyPropsWorld'); world.use_nodes=True
world.node_tree.nodes['Background'].inputs[0].default_value=(.35,.44,.50,1)
world.node_tree.nodes['Background'].inputs[1].default_value=.45; scene.world=world
data=bpy.data.lights.new('PropSun','SUN'); data.energy=1.8; data.angle=.12
sun=bpy.data.objects.new('PropSun',data); scene.collection.objects.link(sun); sun.rotation_euler=(.35,-.50,-.5)
data=bpy.data.lights.new('PropSoftbox','AREA'); data.energy=1600; data.size=12
light=bpy.data.objects.new('PropSoftbox',data); scene.collection.objects.link(light); light.location=(-4,-4,12)
cam_data=bpy.data.cameras.new('PropsCamera'); camera=bpy.data.objects.new('PropsCamera',cam_data)
scene.collection.objects.link(camera); camera.location=(4,-10,10)
camera.rotation_euler=(Vector((0,1.2,.15))-camera.location).to_track_quat('-Z','Y').to_euler()
cam_data.type='ORTHO'; cam_data.ortho_scale=9.5 if columns==3 else 11.5; scene.camera=camera
scene.render.engine='CYCLES'; scene.cycles.samples=32; scene.cycles.use_denoising=True
scene.render.resolution_x=1800; scene.render.resolution_y=1200; scene.render.resolution_percentage=100
scene.view_settings.view_transform='AgX'; scene.render.image_settings.file_format='PNG'
scene.render.filepath=str(ART/(SELECTED+'_blender.png'))
bpy.ops.wm.save_as_mainfile(filepath=str(ART/(SELECTED+'_atelier.blend')))
print('FANTASY_PROPS_READY',len(manifest),'animated',sum(p['animated'] for p in manifest),'triangles',sum(p['triangles'] for p in manifest))
