import bpy
from pathlib import Path
from mathutils import Vector
from mathutils.bvhtree import BVHTree
R=Path(__file__).resolve().parents[1]
bpy.ops.wm.open_mainfile(filepath=str(R/'art/prologue_terrain/prologue_terrain_v10.blend'))
v=[];f=[]
for o in bpy.context.scene.objects:
 if o.type=='MESH' and o.name.startswith('Terrain_0'):
  n=len(v);v.extend(o.matrix_world@p.co for p in o.data.vertices);f.extend(tuple(n+i for i in p.vertices) for p in o.data.polygons)
b=BVHTree.FromPolygons(v,f)
for x,y in [(-121,112),(-132,112),(-110,112),(-121,125),(-121,103)]:print('GROUND',x,y,b.ray_cast(Vector((x,y,150)),Vector((0,0,-1)))[0])
c=bpy.data.collections.get('Source_01_Elder_Sage')
p=[o.matrix_world@Vector(v) for o in c.all_objects if o.type=='MESH' for v in o.bound_box]
print('TREE', [min(v[i] for v in p) for i in range(3)],[max(v[i] for v in p) for i in range(3)])
