# 异世界小模型：分类验收版

林间植物、自然杂物第二版与旅途用品已验收，村落生活用品等待本轮分类验收；后续分类尚未制作。所有模型独立保存，展示底座与编号不包含在模型中。

## 林间植物

| 编号 | 模型 | 三角面 | 动画 |
| --- | --- | ---: | --- |
| 01 | 舒展蕨类 | 1,120 | 4 秒微风循环 |
| 02 | 卷叶蕨 | 1,580 | 4 秒微风循环 |
| 03 | 赤褐蘑菇簇 | 1,224 | 静态 |
| 04 | 青蓝蘑菇簇 | 1,224 | 静态 |
| 05 | 树桩层生菌 | 1,260 | 静态 |
| 06 | 星光小花 | 370 | 4 秒微风循环 |
| 07 | 暮色小花 | 370 | 4 秒微风循环 |

每个同名 `.glb` 是独立模型，`.tscn` 是可拖入 Godot 的预制场景。植物使用 `plant_idle.gd` 自动播放风动画，可通过 `wind_speed` 调整速度；植物没有碰触回弹、刚体或阻挡碰撞。小花的发光花心属于材质效果，不会自动生成照亮周围的点光源。

独立 Blender 源文件位于 `art/fantasy_props/individual/`；原点位于植物根部高度，单位为米。材质为独立 PBR 色块，无外部贴图依赖。Blender 展示光照不作为游戏效果保证，游戏画面以 Godot 的灯光和环境设置为准。

## 验收文件

- `art/fantasy_props/woodland_blender0001.png`：Blender 展示渲染。
- `art/fantasy_props/woodland_godot.png`：Godot Compatibility 正面实机。
- `art/fantasy_props/woodland_reverse.png`：Godot 背面检查。
- `art/fantasy_props/woodland_wind.mp4`：4 秒实机动画预览。

验证：`godot --headless --path . --script res://tests/woodland_plants_check.gd`

测试检查七个模型、独立网格、四段实际驱动的首尾闭合动画，以及预制场景自动播放。当前组没有替换游戏地图中的任何植物。

## 自然杂物

| 编号 | 模型 | 三角面 | Godot 碰撞 |
| --- | --- | ---: | --- |
| 08 | 宽面苔藓石 | 1,280 | 静态凸包 |
| 09 | 裂隙苔藓石 | 6,154 | 静态凸包 |
| 10 | 苔藓碎石簇 | 6,400 | 无，通行装饰 |
| 11 | 分叉断枝 | 438 | 无，通行装饰 |
| 12 | 空心枯木 | 5,974 | 静态凸包 |

第二版采用不规则石面、融合苔藓、弯曲枝干与破损木质断口。每件烘焙 1024×1024 BaseColor、Normal、Roughness 贴图并嵌入 GLB；贴图原件位于 `art/fantasy_props/textures/`。本节材质有别于前面的植物色块材质。

本组全部为静态模型，不包含动画或可推动刚体。三个带碰撞的预制场景引用同名 `_collision.tres`，复用时一起保留。裂缝及枯木空洞属于可见几何，碰撞按整体凸包近似，不支持钻入或从内部穿行。

每件都提供独立 `.glb`、`.tscn` 和 `art/fantasy_props/individual/` 下的同名 `.blend`。

- `art/fantasy_props/nature_godot.png`：分类正面实机截图。
- `art/fantasy_props/nature_reverse.png`：背面检查。
- `art/fantasy_props/nature_v2_blender0001.png`：第二版 Blender 渲染对照。
- `art/fantasy_props/Natural_Debris_v2_atelier.blend`：第二版整体展示源文件。

验证命令：`godot --headless --path . --script res://tests/natural_debris_check.gd`

检查五个独立静态模型、地面原点、无意外动画，以及五件物体的物理射线命中或穿透行为。原林间植物七件的测试也已重新通过。

## 旅途用品

- 13：旅行背包，布面、皮革翻盖、肩带、口袋缝线与搭扣。
- 14：卷铺盖，起伏卷面、卷层端面、皮革束带与搭扣。
- 15：旧提灯，金属框架、发光灯罩与独立暖色点光源。
- 16：皮革水壶，弯曲肩带、缝边、瓶塞与黄铜饰圈。

每件有独立 `.glb`、`.tscn`、同名 `.blend`，以及内嵌的 1024px 颜色、法线和粗糙度贴图。完整源场景是 `art/fantasy_props/Travel_Items_atelier.blend`。本组无阻挡碰撞、刚体、拾取或角色装备逻辑。

提灯 `.tscn` 默认亮灯且静置。放在悬挂位置后，将 `hanging` 设为 true 可自动播放 4 秒摆动循环；`lit` 控制实例创建时的亮灯状态，`light_energy` 调整点光源强度。灯光有轻微明暗变化，摆动是预制动画而非物理绳索。其余三件为静态模型。

验收图为 `art/fantasy_props/travel_godot.png` 和 `travel_reverse.png`，动画预览为 `travel_sway.mp4`。动画预览展示摆动范围；实际落地实例默认关闭摆动。验证命令：`godot --headless --path . --script res://tests/travel_props_check.gd`。

## 村落生活用品

17 木桶、18 藤篮、19 柴火堆、20 陶罐、21 釉陶双耳瓶。按本轮要求提高写实程度：独立桶板及贴合铁箍、交错藤编、劈开木段、树皮裂纹、陶器拉坯起伏及克制的釉面色差。每件提供独立 GLB、Godot 场景、Blender 源文件和内嵌 1024px PBR 贴图。

木桶、柴火堆、双耳瓶具有静态凸包碰撞；藤篮、小陶罐不挡路。容器空口是视觉几何，凸包不模拟内部空间。本组无动画、可推动刚体、碎裂、拾取或开盖行为。

源场景：`art/fantasy_props/Village_Items_atelier.blend`；独立源文件仍在 `art/fantasy_props/individual/`。实机截图：`village_godot.png`、`village_reverse.png` 和 `village_detail_17.png` 至 `village_detail_21.png`，均位于 `art/fantasy_props/`。

验证：`godot --headless --path . --script res://tests/natural_debris_check.gd -- --village`，检查五件模型、全部材质贴图、地面原点、静态状态和实际物理射线命中情况。尚未替换游戏地图中的物件。
