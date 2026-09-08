# 上古聚落模块 v1

本轮用于序章 v08 的 Blender 美术资产，采用米制。

| 集合库 | 用途 | 原点 |
| --- | --- | --- |
| Ancient_Earth_House_library.blend | 夯土墙、木构、芦苇屋顶住宅 | 室内地坪中心 |
| Ancient_Open_Work_Shelter_library.blend | 开敞工作棚 | 地坪中心 |
| Ancient_Timber_Bridge_library.blend | 32 块桥板、纵梁、桥桩、栏杆、绑绳 | 桥中点，桥板顶面下 0.18 米 |

Blender 中使用 File > Link 或 Append，进入文件的 Collection 目录选择同名集合。
这些文件是集合资产库，不含可直接渲染的场景。场景示例在
`art/prologue_terrain/prologue_terrain_v08.blend`。
住宅复用 3 次，工作棚、桥各 1 次；模型保持独立可修改。

屋顶使用实体基层与分层芦苇面片，土墙有厚度、门框和侧窗开口。
桥宽约 3.6 米，栏杆间约 3 米；坡度按当前序章两岸高差建模，复用到其他地形须调整。
六根桥桩按序章河床高度向下嵌入 0.35 米，复用时也需重新适配河床。
木纹、土墙、石基为 Blender 程序化材质，转 Godot 需烘焙贴图或重建材质。
本轮没有提供建筑室内玩法、门动画、破坏效果或引擎碰撞。

生成：`tools/polish_prologue_architecture.py`。
验证：`tools/check_prologue_polish.py`（Blender 后台运行）。
