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

## v04 废墟独立模块

`prologue_terrain_v04.blend` 替换废墟旧占位，新增 8 类石砌模块的 25 个关联实例。
保留 v03 全部 959 个既有素材实例，源文件哈希检查未改变。
源文件、GLB、预览和使用说明见 [废墟模块](../ruins_modules/README.md)。
本版为废墟初版美术验收，聚落仍为占位，Godot 碰撞与实际行走待验收。

## v05 废墟优化

`prologue_terrain_v05.blend` 使用 [废墟模块 v2](../ruins_modules/v2/README.md)，
保留 v04。调整石料、残墙轮廓、铺石与坍塌区域，新增墙根自然布景。
8 类模块通过 28 个实例复用，另有 10 个复用旧素材的边缘实例。
独立文件、GLB 贴图/顶点色、链接及旧素材哈希验证通过；美术验收待用户审阅。

## v06 扩图与内容空间

`prologue_terrain_v06.blend` 扩至320×280米，保留v05及原素材尺寸。
新增三条支路、四处内容空间，复用自然素材、生活物件与旧木构/废墟模块。
路线、素材复用、验证结果及玩法边界见 [扩图与内容落位](../../docs/prologue-v06-content-layout.md)。

## v07 地表与水岸优化

`prologue_terrain_v07.blend` 在 v06 基础上增加世界坐标地表色差、细节凹凸、
水面细波纹和暖色日照。水面横向延伸至岸坡内部，修复近景可见的悬空黑缝；
322 个边缘顶点中 320 个找到岸坡交界，地图边界两点未延伸。
复用已有链接素材增加 766 个岸石与林下实例，实例锚点避开路线中心 4 米。
此锚点间距不等同完整碰撞包围盒检查。

五块地形坐标不变，v06 与 25 个链接源文件哈希不变。
生成脚本：`tools/refine_prologue_scene.py`；记录：
`assets/prologue_terrain/refinement_v07.json`。
预览：`overview_v07.png`、`creek_v07.png`。

这是 Blender 场景美术迭代；聚落和桥仍需替换占位。
程序化材质需要烘焙或在 Godot 重建，水纹尚未动画化，
Godot 碰撞、导航、帧时间尚未验证。

## v08 聚落、木桥与光影

`prologue_terrain_v08.blend` 将四处聚落占位替换为 3 座复用夯土茅屋与 1 座工作棚，
木桥增加独立桥板、纵梁、桥桩、栏杆与麻绳绑扎；桥板两端坐标与原版一致。
住宅补充石基、台阶、真实侧窗开口，保留并调整既有陶罐、藤篮和柴火堆摆放。
地形顶点坐标保持不变，门前顶点色增加踩踏土色。

光照采用暖色方向光、大气天空补光与 AgX；降低天空饱和度和强度后，
避免第一版过蓝、发白。水面保留天空反射与微小波纹。
这是静态 Blender 美术预览，不表示引擎性能、动画或碰撞已经完成。

同机位前后对照：`settlement_before_v08.png` / `settlement_v08.png`，
`bridge_before_v08.png` / `bridge_v08.png`，`house_before_v08.png` / `house_v08.png`。
独立复用源见 [聚落模块](../settlement_modules/v1/README.md)。
验证记录：`assets/prologue_terrain/polish_v08.json`。

## v09 河道与浅滩（仅 Blender）

`prologue_terrain_v09.blend` 保留 v08，局部细分并重塑河道附近地形，
形成宽窄变化、浅岸与最深约 1.36 米的河床。水面有深度驱动的颜色和透明度，
叠加 1.8 厘米以内的静态细起伏、法线波纹及少量石群附近的泡沫色斑。
水纹映射随 Blender 时间轴移动；这不是流体模拟，也不是物理交互。

重新贴地 157 个既有自然实例，增加 56 个复用石块实例。
桥面几何保留，六根桥桩重新适配河床。原素材文件保留。
近景：`river_v09.png`、`river_shallows_v09.png`。

生成：`tools/refine_prologue_river.py`；重开验证：`tools/check_prologue_river.py`。
记录：`assets/prologue_terrain/river_v09/river_report.json`。
按本轮用户要求，没有导出或接入 Godot。

## v10 既有小模型场景组合（仅 Blender）

`prologue_terrain_v10.blend` 复用 16 种既有素材与木构模块，新增 187 个摆放对象：
储物院 18、备柴院 18、歇脚院 15、工作棚周边 25、溪岸枯木群落 47、废墟墙脚 64。
木构分隔栏共享原模块网格，以对象材质覆盖使用既有旧木材质。
蘑菇缩小到更适合近景的尺寸，枯木下增加局部腐殖土顶点色。

预览：`courtyards_v10.png`、`creek_pocket_v10.png`、`ruin_edges_v10.png`。
生成：`tools/dress_prologue_lived_spaces.py`；重开验证：`tools/check_prologue_dressing.py`。
复用与摆放记录：`assets/prologue_terrain/dressing_v10.json`。

验证通过：v09 与 25 个链接源文件哈希保留；地形和水面顶点坐标不变；
新增落地物件包围半径距道路中心线最小约 3.13 米，包围盒底部与取样地面吻合。
这不是全部物件之间的碰撞检查，也不是 Godot 导航验证；本轮未接入引擎。

## v11 神异地标与生物原型

`prologue_terrain_v11.blend` 增加遗骨古树祭场、玉质异草与三只白耳猿形异兽。五类独立 Collection 素材库位于 `art/shanhai_ecology/v1/`；异兽含转头、呼吸原型动画。

说明与限制见 [v11 制作记录](../../docs/prologue-shanhai-v11.md)。本轮仅 Blender 优化；写实精模、完整运动和游戏行为仍待完成。

## v12 山海探索宝箱

`prologue_terrain_v12.blend` 在三处探索点新增链接宝箱，带白耳兽面、山形水纹和开盖神异特效。初始关闭；在 Blender 时间线帧 55 查看打开与光纹效果。独立资源与使用边界见 [宝箱说明](../exploration_props/README.md)。
