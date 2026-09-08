"""Reopen v08 and independent libraries; verify preservation and reusable geometry."""
import hashlib
import json
import math
import struct
from pathlib import Path
import bpy
from mathutils import Vector
from mathutils.bvhtree import BVHTree

ROOT=Path(__file__).resolve().parents[1]
report_path=ROOT/'assets/prologue_terrain/polish_v08.json'
report=json.loads(report_path.read_text())
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'art/prologue_terrain/prologue_terrain_v08.blend'))
scene=bpy.context.scene
assert hashlib.sha256((ROOT/'art/prologue_terrain/prologue_terrain_v07.blend').read_bytes()).hexdigest()==report['source_v07_sha256']
for name,digest in report['terrain_hashes'].items():
    obj=scene.objects[name]
    assert hashlib.sha256(b''.join(struct.pack('fff',*v.co) for v in obj.data.vertices)).hexdigest()==digest,name
for lib in bpy.data.libraries:
    assert Path(bpy.path.abspath(lib.filepath)).is_file(),lib.filepath
placements=bpy.data.collections['Settlement_Architecture_v08']
assert len(placements.objects)==5
assert sum(o.instance_collection.name=='Ancient_Earth_House' for o in placements.objects)==3
assert not any(o.get('module_source')=='House_Platform_600' for o in scene.objects)
bridge=next(o for o in placements.objects if o.instance_collection.name=='Ancient_Timber_Bridge')
deck=sorted([o for o in bridge.instance_collection.objects if o.name.startswith('Deck_Plank_')],key=lambda o:o.location.x)
assert len(deck)==32
for plank,endpoint in zip((deck[0],deck[-1]),report['bridge_endpoints_blender']):
    assert abs(plank.location.x+bridge.location.x-endpoint[0])<1e-4
    assert abs(plank.location.z+bridge.location.z+.09-(endpoint[2]+.18))<1e-4

verts,faces=[],[]
for name in report['terrain_hashes']:
    obj=scene.objects[name];offset=len(verts)
    verts.extend(obj.matrix_world@v.co for v in obj.data.vertices)
    faces.extend(tuple(offset+i for i in p.vertices) for p in obj.data.polygons)
surface=BVHTree.FromPolygons(verts,faces)
bpy.context.view_layer.update()
piles=[o for o in bridge.instance_collection.objects if o.name.startswith('Support_Pile')]
assert len(piles)==6
for pile in piles:
    bottom=pile.matrix_world@Vector((0,0,min(v.co.z for v in pile.data.vertices)))+bridge.location
    hit,_,_,_=surface.ray_cast(Vector((bottom.x,bottom.y,150)),Vector((0,0,-1)))
    assert hit is not None and abs(hit.z-bottom.z-.35)<1e-4,(pile.name,bottom,hit)

asset_checks={}
for name in report['independent_assets']:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    path=ROOT/'art/settlement_modules/v1'/(name+'_library.blend')
    with bpy.data.libraries.load(str(path),link=False) as (src,dst):
        assert name in src.collections
        dst.collections=[name]
    col=dst.collections[0]
    bpy.context.scene.collection.children.link(col)
    assert col.objects
    polygons=0
    for obj in col.all_objects:
        if obj.type=='MESH':
            assert len(obj.data.polygons)>0,obj.name
            assert all(math.isfinite(c) for v in obj.data.vertices for c in v.co),obj.name
            assert obj.data.materials and all(m and m.use_nodes for m in obj.data.materials)
            polygons+=len(obj.data.polygons)
    asset_checks[name]={'objects':len(col.all_objects),'base_polygons':polygons,'standalone_append':True}
report['reopen_verified']=True
report['six_bridge_piles_embedded_035m']=True
report['independent_library_checks']=asset_checks
report_path.write_text(json.dumps(report,indent=2),encoding='utf-8')
print('V08_REOPEN_AND_LIBRARIES_OK',json.dumps(asset_checks))
