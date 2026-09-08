"""Verify saved Blender river, source preservation, water depth and motion."""
import hashlib
import json
from pathlib import Path
import bpy
from mathutils import Vector
from mathutils.bvhtree import BVHTree

ROOT=Path(__file__).resolve().parents[1]
ART=ROOT/'art/prologue_terrain'
report_path=ROOT/'assets/prologue_terrain/river_v09/river_report.json'
report=json.loads(report_path.read_text())
bpy.ops.wm.open_mainfile(filepath=str(ART/'prologue_terrain_v08.blend'))
hashes={bpy.path.abspath(lib.filepath):hashlib.sha256(Path(bpy.path.abspath(lib.filepath)).read_bytes()).hexdigest() for lib in bpy.data.libraries}
bridge=bpy.data.objects['Ancient_Timber_Bridge_Placed']
old_deck={o.name:[tuple(v.co) for v in o.data.vertices] for o in bridge.instance_collection.objects if o.name.startswith('Deck_Plank')}
bpy.ops.wm.open_mainfile(filepath=str(ART/'prologue_terrain_v09.blend'))
assert hashlib.sha256((ART/'prologue_terrain_v08.blend').read_bytes()).hexdigest()==report['source_v08_sha256']
assert all(Path(p).is_file() and hashlib.sha256(Path(p).read_bytes()).hexdigest()==h for p,h in hashes.items())
scene=bpy.context.scene
terrain=[o for o in scene.objects if o.type=='MESH' and o.name.startswith('Terrain_0')]
assert len(terrain)==5
verts,faces=[],[]
for obj in terrain:
    offset=len(verts);verts.extend(obj.matrix_world@v.co for v in obj.data.vertices)
    faces.extend(tuple(offset+i for i in p.vertices) for p in obj.data.polygons)
surface=BVHTree.FromPolygons(verts,faces)
water=scene.objects['Water_Creek'];assert len(water.data.vertices)==18513
assert all(p.area>1e-8 for p in water.data.polygons)
depths=[d.color[0]*2 for d in water.data.color_attributes['RiverDepth'].data]
assert min(depths)<.05 and max(depths)>1
water_mat=water.data.materials[0]
mapping=next(n for n in water_mat.node_tree.nodes if n.type=='MAPPING')
scene.frame_set(35);a=mapping.inputs['Location'].default_value[1]
scene.frame_set(75);b=mapping.inputs['Location'].default_value[1]
assert abs(b-a-1)<1e-5,(a,b)
assert water_mat.node_tree.animation_data.drivers[0].driver.is_valid
bridge=scene.objects['Ancient_Timber_Bridge_Placed']
assert old_deck=={o.name:[tuple(v.co) for v in o.data.vertices] for o in bridge.instance_collection.objects if o.name.startswith('Deck_Plank')}
bpy.context.view_layer.update()
piles=[o for o in bridge.instance_collection.objects if o.name.startswith('Support_Pile')]
assert len(piles)==6
for pile in piles:
    low=min(v.co.z for v in pile.data.vertices)
    bottom=pile.matrix_world@Vector((0,0,low))+bridge.location
    hit,_,_,_=surface.ray_cast(Vector((bottom.x,bottom.y,150)),Vector((0,0,-1)))
    assert hit is not None and abs(hit.z-bottom.z-.35)<.001,(pile.name,bottom,hit)
report.update({'reopen_verified':True,'linked_sources_unchanged':len(hashes),'deck_geometry_unchanged':True,
               'six_piles_reseated':True,'flow_driver_shift_frames_35_75':b-a,'depth_range_m':[min(depths),max(depths)]})
report_path.write_text(json.dumps(report,indent=2),encoding='utf-8')
print('RIVER_REOPEN_VERIFIED',json.dumps(report))
