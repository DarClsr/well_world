"""Reopen v10: verify actual instances, ground contact, road margin and source preservation."""
import hashlib
import json
import math
import struct
from pathlib import Path
import bpy
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree

ROOT=Path(__file__).resolve().parents[1]
path=ROOT/'assets/prologue_terrain/dressing_v10.json'
report=json.loads(path.read_text())
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'art/prologue_terrain/prologue_terrain_v10.blend'))
scene=bpy.context.scene
assert hashlib.sha256((ROOT/'art/prologue_terrain/prologue_terrain_v09.blend').read_bytes()).hexdigest()==report['source_v09_sha256']
for file,digest in report['linked_source_hashes'].items():
    assert hashlib.sha256(Path(file).read_bytes()).hexdigest()==digest,file
for name,digest in report['terrain_water_hashes'].items():
    assert hashlib.sha256(b''.join(struct.pack('fff',*v.co) for v in scene.objects[name].data.vertices)).hexdigest()==digest,name
for lib in bpy.data.libraries:assert Path(bpy.path.abspath(lib.filepath)).is_file()
vertices,faces=[],[]
for obj in scene.objects:
    if obj.type!='MESH' or not obj.name.startswith('Terrain_0'):continue
    offset=len(vertices);vertices.extend(obj.matrix_world@v.co for v in obj.data.vertices)
    faces.extend(tuple(offset+i for i in p.vertices) for p in obj.data.polygons)
surface=BVHTree.FromPolygons(vertices,faces)
routes=json.loads((ROOT/'assets/prologue_terrain/expansion_v06.json').read_text())['routes_godot_xz']
starts=np.array([(a[0],-a[1]) for r in routes for a,b in zip(r,r[1:])])
ends=np.array([(b[0],-b[1]) for r in routes for a,b in zip(r,r[1:])])
delta=ends-starts;lengths=np.maximum(np.sum(delta*delta,axis=1),1e-8)
max_contact_error=0;min_clearance=1000
assert len(report['group_counts'])==6
bpy.context.view_layer.update()
for record in report['placements']:
    obj=scene.objects[record['object']]
    if record['grounded']:
        assert obj.instance_type=='COLLECTION'
        assert obj.instance_collection==bpy.data.collections['Source_'+record['source']]
        points=[obj.matrix_world@child.matrix_world@Vector(corner) for child in obj.instance_collection.all_objects
                if child.type=='MESH' for corner in child.bound_box]
        assert points
        radius=max(math.hypot(p.x-obj.location.x,p.y-obj.location.y) for p in points)
        location=np.array([obj.location.x,obj.location.y])
        t=np.clip(np.sum((location-starts)*delta,axis=1)/lengths,0,1)
        clearance=float(np.min(np.linalg.norm(location-starts-t[:,None]*delta,axis=1)))-radius
        assert clearance>=2.099,(obj.name,clearance)
        min_clearance=min(min_clearance,clearance)
        hit,_,_,_=surface.ray_cast(Vector((obj.location.x,obj.location.y,150)),Vector((0,0,-1)))
        assert hit is not None
        error=abs(min(p.z for p in points)-hit.z+record['sink'])
        assert error<.005,(obj.name,error)
        max_contact_error=max(max_contact_error,error)
    else:
        assert obj.data==bpy.data.objects[record['source']].data
        assert obj.material_slots[0].link=='OBJECT'
for group,count in report['group_counts'].items():assert len(bpy.data.collections['V10_'+group].objects)==count
report['verification']={'reopen_passed':True,'max_ground_contact_error_m':max_contact_error,
                        'minimum_new_prop_road_margin_m':min_clearance,'terrain_water_unchanged':True,
                        'linked_sources_unchanged':len(report['linked_source_hashes'])}
path.write_text(json.dumps(report,indent=2),encoding='utf-8')
print('V10_DRESSING_VERIFIED',json.dumps(report['verification']))
