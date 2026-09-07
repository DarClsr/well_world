# 序章地形与复用模块

当前 Blender 文件：`prologue_terrain_v03.blend`，加入既有素材的布景版。
`prologue_terrain_v02.blend` 保留为模块骨架版本。
独立素材库：`prologue_module_library.blend`，场景 `Reusable_Module_Library`。

本轮为地形和模块骨架，不是最终环境美术；未验证 Godot 碰撞或角色行走。
首版 `prologue_terrain.blend` 保留，不覆盖。

## 素材复用

地图中 `Reusable_Module_Instances` 集合使用关联网格副本。
素材库中的源对象已标记为 Blender Asset，底部中心为模型原点，米制单位。
编辑源网格会同步关联实例；实例的位移、旋转和缩放可以分别调整。
需要独特破损形态时，明确创建独立网格变体，不直接改变所有实例。

8 种源模块：石块、3 米墙段、石阶、桥板、木柱、房屋基座、两种岩石。
这些是可替换的占位模块，后续可沿用摆放关系升级模型与材质。
v03 已筛选使用原有树木与杂物，详细来源见下节。建筑仍为占位，
本次树木布景不能替代整体写实程度和 Godot 镜头下的最终验收。

`assets/prologue_terrain/modules/` 每个模块单独导出 GLB，导出时位于原点。
`assets/prologue_terrain/prologue_terrain_v02.glb` 是组合地图导出。
`assets/prologue_terrain/module_manifest.json` 记录源模块与关联实例数量。

## 重建与边界

先运行 `tools/build_prologue_terrain.py` 生成首版，再运行
`tools/refine_prologue_modules.py` 生成 v02；二者均通过 Blender 后台 Python 执行。
脚本重建会覆盖各自指定的输出文件，手工修改请另存版本后再重建。

普通桥已改为复用桥板。原下游水下桥占位已移除；跨沟起落点仅为预留，
不表示轻足技能已实现。地形分块保持独立，水面无真实流体模拟。

## v03 既有素材复用

`tools/dress_prologue_existing_assets.py` 从 v02 另存 v03，直接链接
`art/fantasy_trees/individual/` 和 `art/fantasy_props/individual/` 中的独立源文件。
原源文件内容保持不变；所有摆放使用共享集合实例，模型、材质、贴图和动画
由链接来源提供。原素材在之后更新时，重新加载链接即可更新场景引用。
移动地图文件时需保留仓库相对路径，不能只单独搬走 v03 文件。

| 分类 | 原有素材 | 摆放数量 |
| --- | --- | ---: |
| 树木 | 舒展古树、细高林木、迎风斜树、金叶幼树 | 93 |
| 林下植物 | 舒展蕨、卷叶蕨、赤褐蘑菇 | 709 |
| 自然杂物 | 宽面苔石、裂隙苔石、碎石簇、断枝、空心枯木 | 130 |
| 生活与旅途物件 | 铺盖、水壶、藤篮、柴火堆、陶罐 | 27 |
| 合计 | 17 种既有素材 | 959 |

原临时多面体岩石替换为已有自然杂物第二版。树群避开主路和试炼空地，
蕨类集中在林下与溪岸，生活用品置于现有建筑基座和采药棚占位处。
灰紫树、青蓝蘑菇、西式提灯未纳入本轮布景。

`assets/prologue_terrain/existing_asset_placements_v03.json` 保存来源路径、
源文件 SHA256、摆放变换和分类，供后续在 Godot 复用已有 `.tscn`。
v03 未合并导出一个庞大的静态 GLB，避免烘死原有动画与资产引用关系；
完整引擎组装、碰撞及性能验证仍待后续实施。

四种树木与两种蕨类的原风动画已验证在重新打开 v03 后随帧变化。
同源集合实例当前共享动画时相；Godot 阶段再按既有预制体设置错峰。
落叶属于 Godot 粒子功能，当前 Blender 场景没有新增落叶粒子。

验证脚本：打开 v03 后以 Blender 执行 `tools/check_prologue_existing_assets.py`，
检查 17 个来源、959 个实例、外部链接与贴图、源文件哈希和六种动画来源。
预览：`blender_overview_v03.png`、`blender_woodland_v03.png`、
`blender_settlement_v03.png`、`blender_ruins_v03.png`。
