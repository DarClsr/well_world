"""Validate saved expansion and render its reused exploration pockets."""
import hashlib
import json
import math
from pathlib import Path
import bpy
from mathutils import Vector
from mathutils.bvhtree import BVHTree

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT/'art/prologue_terrain'
report = json.loads((ROOT/'assets/prologue_terrain/expansion_v06.json').read_text())
assert hashlib.sha256((ART/'prologue_terrain_v05.blend').read_bytes()).hexdigest() == report['source_v05_sha256']
bpy.ops.wm.open_mainfile(filepath=str(ART/'prologue_terrain_v06.blend'))
scene = bpy.context.scene
for lib in bpy.data.libraries:
    assert Path(bpy.path.abspath(lib.filepath)).is_file()
old = json.loads((ROOT/'assets/prologue_terrain/existing_asset_placements_v03.json').read_text())
for entry in old['sources'].values():
    assert hashlib.sha256((ROOT/entry['blend']).read_bytes()).hexdigest() == entry['sha256']
assert len([o for o in scene.objects if o.get('source_asset')]) == 959
assert len([o for o in scene.objects if o.get('ruins_source')]) == 28
assert len([o for o in scene.objects if o.get('expansion_source')]) == len(report['added_instances'])
assert len([o for o in scene.objects if o.get('content_site')]) == report['content_prop_count']
terrain = [o for o in scene.objects if o.name.startswith('Terrain_0') and o.type=='MESH']
vertices,faces,shared = [],[],{}
for obj in terrain:
    offset=len(vertices)
    for v in obj.data.vertices:
        p=obj.matrix_world@v.co
        key=(round(p.x,4),round(p.y,4))
        if key in shared:
            assert abs(shared[key]-p.z)<.001, key
        shared[key]=p.z
        vertices.append(p)
    faces.extend([tuple(offset+i for i in p.vertices) for p in obj.data.polygons])
assert abs(max(v.x for v in vertices)-min(v.x for v in vertices)-320)<.001
assert abs(max(v.y for v in vertices)-min(v.y for v in vertices)-280)<.001
surface=BVHTree.FromPolygons(vertices,faces)
walk_vertices=list(vertices)
walk_faces=list(faces)
for obj in scene.objects:
    if obj.get('module_source')=='Timber_Plank_360':
        offset=len(walk_vertices)
        walk_vertices.extend([obj.matrix_world@v.co for v in obj.data.vertices])
        walk_faces.extend([tuple(offset+i for i in p.vertices) for p in obj.data.polygons])
walk_surface=BVHTree.FromPolygons(walk_vertices,walk_faces)
grades=[]
steep=[]
for route in report['routes_godot_xz']:
    for a,b in zip(route,route[1:]):
        previous=None
        count=max(1,math.ceil(math.dist(a,b)/2))
        for i in range(count+1):
            t=i/count
            x,z=a[0]*(1-t)+b[0]*t,a[1]*(1-t)+b[1]*t
            hit=walk_surface.ray_cast(Vector((x,-z,150)),Vector((0,0,-1)))[0]
            assert hit is not None
            if previous is not None:
                distance=math.hypot(hit.x-previous.x,hit.y-previous.y)
                if distance>.01:
                    grade=abs(hit.z-previous.z)/distance
                    grades.append(grade)
                    if grade>.48:
                        steep.append({'x':x,'z':z,'grade':grade})
            previous=hit
summary={'terrain_seams':'passed','old_sources':'unchanged','v05':'unchanged',
         'route_max_terrain_grade':max(grades),'extra_nature_instances':len(report['added_instances']),
         'content_sites':len(report['content_sites']),'content_props':report['content_prop_count'],
         'steep_samples':steep,
         'note':'Route surface samples include bridge planks; not Godot navigation validation'}
(ROOT/'assets/prologue_terrain/expansion_v06_checks.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
for site in report['content_sites'][:2]:
    x,z=site['xz']
    target=Vector((x,-z,site['height']+1))
    scene.camera.location=target+Vector((14,-18,17))
    scene.camera.rotation_euler=(target-scene.camera.location).to_track_quat('-Z','Y').to_euler()
    scene.camera.data.ortho_scale=20
    scene.render.resolution_x,scene.render.resolution_y=1300,950
    scene.render.filepath=str(ART/('expanded_'+site['id']+'_v06.png'))
    bpy.ops.render.render(write_still=True)
print('EXPANSION_CHECK_OK',json.dumps(summary))
