# 异世界树木资产包

参考用户提供的树木插画制作的六种独立风格化 3D 树木。主树和伞冠树采用黄绿受光面、深绿阴影；其余变体采用青绿、金叶和灰紫，适配不同区域。

| 文件名 | 树形 | 高度（米） | 三角面 |
| --- | --- | ---: | ---: |
| 01_Elder_Sage | 舒展古树，鲜绿主款 | 8.13 | 19,992 |
| 02_Silver_Spire | 细高林木 | 9.01 | 17,616 |
| 03_Umbrella_Grove | 低矮伞冠树 | 6.63 | 17,616 |
| 04_Windward_Tree | 迎风斜树 | 7.01 | 19,992 |
| 05_Amber_Sapling | 金叶幼树 | 4.98 | 12,864 |
| 06_Dusk_Warden | 灰紫异界树 | 7.63 | 19,992 |

## 独立复用

- 本目录每个同名 `.glb` 都是一棵完整树木，内含树干、树冠、顶点色材质及风动画，不含底座、地面或标签。
- 同名 `.tscn` 可直接拖入 Godot 场景，带静态树干碰撞，自动播放风动画。
- 每棵树的独立 Blender 源文件位于 `art/fantasy_trees/individual/`，可单独打开编辑。
- 根部中心为原点，单位为米；Blender Z 向上，GLB/Godot 自动转换为 Y 向上。
- `tree_wind.gd` 的 `wind_speed` 控制播放速度，`wind_offset` 控制起始相位。位置也参与相位，减少重复种植时的同步感。
- 每棵树默认带 7 片缓慢旋转飘落的叶片和 10 片稀疏地面落叶。`falling_leaves`、`ground_leaves` 可独立关闭。叶片使用本树配色。
- `import_tree.gd` 负责启用 Godot 顶点颜色和动画循环。跨项目复制时保留本目录及 `.glb.import`，路径保持 `res://assets/fantasy_trees/`。

## 动画和材质

每棵树包含 4 秒、30 FPS 的循环风动画，使用两个树冠形态键：整体轻摆与叶片错相起伏。树干和根部不参与动画。Blender 源文件范围为 1-121 帧；GLB 动画已对齐至 0-4 秒。

采用真实双面叶片几何和顶点色，无外部纹理依赖、无透明排序。UV 为逐面投影，允许重叠，不是专用烘焙图集。每棵树两个网格、两个材质。Godot 导入启用自动网格 LOD；大规模森林仍需结合目标硬件测量形态键动画与实例数量的开销。当前提供的是近中景资产，未做远景 billboard。

树干碰撞为低成本胶囊近似，未覆盖外伸根部和高处枝条。

落叶是 Godot 预制场景内的原生粒子效果；独立 GLB/Blender 文件包含树冠风动画，不包含游戏引擎粒子。飘落叶片在根部平面附近缩小消失，地面落叶按平面分布；倾斜地形上建议关闭 `ground_leaves` 或按地形另行摆放，不包含物理堆积。

## 预览与验证

- `showcase.tscn`：独立可运行展示场景，左键拖动旋转，滚轮缩放。
- `art/fantasy_trees/tree_collection0001.png`：Blender 展示渲染。
- `art/fantasy_trees/wind_preview.mp4`：Godot Compatibility 实机 4 秒循环预览。
- `art/fantasy_trees/falling_leaves_preview.mp4`：主树风摆和落叶近景；同名 GIF 可直接预览。
- `art/fantasy_trees/godot_reverse.png`：背面检查视角。

验证命令：`godot --headless --path . --script res://tools/prepare_fantasy_trees.gd`

验证范围：六个模型均为两个网格；顶点颜色启用；树冠含两个形态键；动画首尾一致且实际驱动形态键；树干不动；六个预制场景自动循环播放。独立 Blender 文件也逐一重新读取验证。

资产由 Blender 原生程序化网格生成，参考图只用于造型与色彩方向，没有嵌入模型。现有游戏地图尚未替换为这些树木。
