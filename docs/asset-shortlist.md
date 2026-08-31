# 《异世界漫游记》序章素材候选清单

版本：0.1<br>
核验日期：2026-08-31<br>
对应场景：异界石环 → 雾池 → 雾谷村 → 炉火广场 → 浓雾山口<br>
美术基准：[《异世界漫游记》美术风格规范](art-direction.md)

## 1. 结论

序章不应混入大量不同品牌的资产。当前最稳妥的素材路线是：

> **Quaternius 新一代环境生态作为主体，玩家角色用 Quaternius 与 KayKit 各做一个免费原型对比，异界石环、主角标志和核心特效保持原创。**

推荐组合：

- 环境与建筑：Quaternius。
- NPC 与通用动画：Quaternius。
- 玩家候选 A：Quaternius Universal Base Characters + Modular Character Outfits。
- 玩家候选 B：KayKit Adventurers，经重新配色和配件改造。
- 地形补充：优先 Quaternius；需要模块化悬崖时再考虑 KayKit Forest Extra。
- 传送门：Quaternius Ruins 只提供石构零件，门体、符文、青色特效和整体轮廓自行设计。
- 雾、水、火、风和后期：继续使用 Godot 原生能力与自定义 Shader，不购买整套特效包。

## 2. 当前场景与候选素材对应

| 当前内容 | 当前实现 | 推荐候选 | 使用方式 | 优先级 |
| --- | --- | --- | --- | --- |
| 边界树木、花草、岩石 | Quaternius 旧自然模型 | Stylized Nature MegaKit | 替换主景植被与地标树，统一为鼠尾草绿色板 | P0 |
| 三栋村屋 | 旧村庄零件 + 运行时拼装 | Medieval Village MegaKit | 重新搭建三栋轮廓不同的模块化房屋 | P0 |
| 玩家 Ranger | RPG Character Pack Ranger | 两套免费玩家候选 | 同镜头并排测试剪影、比例与动画 | P0 |
| 三名村民 | Cleric、Warrior、Monk | Universal Base Characters + Fantasy Outfits | 按药草师、守门人、织工组合职业轮廓 | P0 |
| 马车、木箱、药草圃、炉火道具 | 少量旧道具和 CSG | Fantasy Props MegaKit | 只挑有叙事作用的道具，重新调色 | P1 |
| 异界石环石构 | CSG 与简单岩石组合 | Ultimate Modular Ruins Pack | 只取柱、断墙和石块，重新组合原创轮廓 | P1 |
| 角色动作 | RPG Character Pack 自带动作 | Universal Animation Library 2 | 补充交谈、采集、观察、坐下等行为 | P1 |
| 山口、悬崖和地形过渡 | CSG 边界与岩石群 | KayKit Forest Extra（可选） | 仅在 Quaternius 无法满足模块化高差时使用 | P2 |
| 传送门表面 | 发光材质、微粒和灯光 | 自定义 Godot Shader | 保留为原创核心资产，不直接套成品门 | P0 |
| 漂雾、雾池、炉火 | Godot 原生网格、音频和动画 | 继续自制 | 优化层次与材质，无需新增模型包 | P1 |

## 3. P0：建议优先下载并测试

### 3.1 [Quaternius — Stylized Nature MegaKit](https://quaternius.com/packs/stylizednaturemegakit.html)

用途：序章树木、灌木、草丛、花、蘑菇、岩石和边界景观。

官方信息：

- 116 个自然模型，包括 40 棵树、35 种植物与花、27 种岩石等。
- 树叶可切换 7 种变化。
- 提供 FBX、OBJ、glTF；官方说明兼容 Godot。
- Source 版包含 Godot 工程、草与树叶风动 Shader。
- CC0，可用于商业项目并允许修改。
- 标准版约 60%～70% 内容免费。

匹配评价：**A**。

为什么适合：同作者、同纹理语言、轮廓清楚，比当前旧自然包丰富，适合制作《Death's Door》式“少量大形 + 有节奏植被”。

使用限制：

- 默认演示色彩偏鲜艳，需要整体压低饱和度并统一成鼠尾草绿。
- 不使用所有树种；序章控制为 3 种主树、2 种灌木和少量花草。
- 紫色、粉色或过亮树叶只保留给异界异常区域。

### 3.2 [Quaternius — Medieval Village MegaKit](https://quaternius.com/packs/medievalvillagemegakit.html)

用途：雾谷村三栋房屋、门窗、屋顶、楼梯、外墙、藤蔓和局部院落。

官方信息：

- 300 多个模块化环境零件，按网格吸附设计。
- 墙体同时包含外部和内部结构。
- 提供 FBX、OBJ、glTF。
- Source 版提供 Godot 工程、自定义磨损颜色 Shader 和优化碰撞。
- CC0，可用于商业项目并允许修改。
- 标准版约 60%～70% 内容免费。

匹配评价：**A**。

为什么适合：可用统一零件搭出不同房屋轮廓，解决当前三栋房子形态过近的问题，同时继续保持现有 Quaternius 生态。

使用限制：

- 不按演示场景整套复制房屋。
- 三栋房屋分别突出药草、守门和织造生活痕迹。
- 屋顶高度、墙体宽度和门窗比例需为俯视镜头重新调整。
- 保留现有屋顶淡化机制，但改成独立屋顶模块或遮挡组。

### 3.3 [Quaternius — Universal Base Characters](https://quaternius.com/packs/universalbasecharacters.html)

用途：NPC 基础身体，也可作为玩家候选 A。

官方信息：

- 男、女各有 Superhero、Regular、Teen 三种比例，共 6 个基础身体。
- 20 种发型，可调整眼睛和肤色。
- 约 13k 三角面，Humanoid Rig，可动画重定向。
- 与 Universal Animation Library 兼容。
- FBX、glTF；Source 版提供 Godot 工程和 Blend 源文件。
- CC0，可用于商业项目并允许修改。

免费包实测修正：2026-08-31 下载的 Standard 压缩包仅包含 Superhero 男、女两个完整基础身体和部分发型；Regular、Teen 并不在本次免费内容中。官方网站描述的是完整套件范围，不能据此假定免费包含全部六种身体。

匹配评价：完整套件 NPC **A**；本次免费 Superhero 身体 **C**；玩家 **不采用**。

使用建议：

- 免费验证不再使用 Superhero 身体作为正式候选；完整 Ranger/Peasant 服装 glTF 已自带 Regular 身体，可直接用于 NPC 静态比例测试。
- 若后续确实需要 Teen 或其他基础身体，再评估完整版本，不提前购买。
- 不直接使用默认面孔和配色作为重要角色成品。

### 3.4 [Quaternius — Modular Character Outfits: Fantasy](https://quaternius.com/packs/modularcharacteroutfitsfantasy.html)

用途：主角帽兜、披风、旅行服和 NPC 职业服装。

官方信息：

- 12 套服装、62 个独立模块。
- 每套有 3 种纹理颜色。
- 与 Universal Base Characters 和 Universal Animation Library 兼容。
- Humanoid Rig，提供 FBX、glTF；Source 版提供 Blend 与 Godot 实现。
- CC0，可用于商业项目并允许修改。

匹配评价：**A-**。

使用建议：

- 不使用完整预设套装；从不同套装中组合帽兜、短斗篷、腰包和靴子。
- 玩家固定为深森林绿、旧皮革棕和一处青色异界标记。
- 米拉强调药草包、布裙或轻型披肩；托伦强调厚肩与短武器；尼娅强调围巾、布卷或腰间工具。

### 3.5 [KayKit — Character Pack: Adventurers](https://kaylousberg.itch.io/kaykit-adventurers)

用途：玩家候选 B，用于验证更接近《Death's Door》的大头小身和强剪影。

官方信息：

- 免费版包含 5 个完整绑定、带动画的角色和 25 种以上配件。
- 提供 FBX、glTF，官方列出 Godot 兼容。
- 使用单张渐变图集，适合重新配色。
- 免费版 CC0；Extra 版当前为 7.95 美元，Source 版为 11.95 美元。

匹配评价：比例 **A**；与环境直接混用 **B**。

使用建议：

- 只用于主角原型，不把整套角色混入 NPC 队伍。
- 优先测试 Hooded Rogue、Ranger 或 Druid 类轮廓。
- 必须压低默认鲜艳色彩，并增加原创短斗篷、背包和青色标记。
- 若免费 glTF 的轮廓已经成立，再决定是否需要 Source 版做深度改造。

## 4. P1：主体确定后补充

### 4.1 [Quaternius — Fantasy Props MegaKit](https://quaternius.com/packs/fantasypropsmegakit.html)

用途：炉火广场、药草圃、村屋外部和道路节点的生活道具。

官方信息：

- 200 多个家具、工具、武器、书、药水、市场、蔬菜和可破坏道具。
- 全套模型仅使用 4 组纹理，适合性能和统一材质。
- 提供 FBX、OBJ、glTF；Source 版提供 Godot 工程、碰撞和磨损变化。
- CC0，可用于商业项目并允许修改。

匹配评价：**A-**。

使用限制：每个生活区只选 3～7 个能说明职业或行为的道具，不能把素材库全部摆出来。

### 4.2 [Quaternius — Universal Animation Library 2](https://quaternius.com/packs/universalanimationlibrary2.html)

用途：主角和 NPC 的观察、交谈、采集、农作、坐下、战斗预留动作。

官方信息：

- 130 种以上 Humanoid 动画。
- 提供 FBX、GLB、Blend。
- 官方说明已针对 Godot、Unity 和 Unreal 导出并测试。
- CC0，可用于商业项目并允许修改。

匹配评价：**A**。

序章只引入确实使用的动作，避免一次性导入整库。

### 4.3 [Quaternius — Ultimate Modular Ruins Pack](https://quaternius.com/packs/ultimatemodularruins.html)

用途：异界石环周围的断柱、石台、遗迹碎片和山口旧建筑。

官方信息：

- 90 个模块化遗迹、地牢和道具模型。
- 提供 FBX、OBJ、Blend。
- CC0，可用于商业项目并允许修改。

匹配评价：**B+**。

使用限制：只取结构零件，必须重新组合；传送门圆环、符文图案和发光门体不能直接来自现成完整地标。

### 4.4 [Godot Shaders — Portal Shader](https://godotshaders.com/shader/portal-shader/)

用途：作为传送门噪声、边缘和流动逻辑的代码参考。

- 页面明确说明 Shader 代码片段为 CC0。
- 示例视觉偏旧且偏像素化，不直接照搬颜色和最终效果。
- 应当把思路转成 3D 空间 Shader，并与现有石环、微粒和光照结合。

匹配评价：技术参考 **B**；成品视觉 **不直接采用**。

## 5. P2：备选与补洞

### 5.1 [KayKit — Forest Nature Pack](https://kaylousberg.itch.io/kaykit-forest)

用途：Quaternius 无法提供足够地形高差时，补充模块化悬崖、地块和少量岩石。

官方信息：

- 免费版包含 100 多个树木、岩石、灌木和草模型。
- Extra 版包含模块化地形和 8 种配色，当前为 9.99 美元。
- Source 版包含 Blend 源文件，当前为 14.99 美元。
- FBX、glTF、OBJ；CC0，官方列出 Godot 兼容。

匹配评价：**B**。

风险：单图集渐变与 Quaternius 手绘纹理不同。只允许用于重新配色后的地形大形，不把两套树木混在同一区域。

### 5.2 [Kenney — Fantasy Town Kit](https://kenney.nl/assets/fantasy-town-kit)

用途：白盒、远景建筑或缺失的小型结构件。

- 160 个 3D 文件。
- CC0，可免费下载。

匹配评价：**C+**。

风险：造型更接近通用低多边形积木，直接用于近景会降低精品感；仅作为结构参考或远景备选。

## 6. 暂不建议购买或采用

### Synty POLYGON 系列

优点是内容量大、配套完善，但暂不作为序章主线：

- 品牌视觉辨识度很强，容易出现典型“POLYGON 素材游戏”观感。
- 与现有 Quaternius 人物、建筑和纹理语言差异明显。
- 若只为一张小地图引入整套生态，统一改造成本高于收益。

只有未来完全更换环境生态时，才重新评估整套迁移，不做零散混用。

### 成品传送门与完整地标

异界石环是序章最重要的原创识别点，不采用可直接辨认来源的完整成品传送门。允许使用通用断柱、石块、粒子思路和 Shader 技术，但最终轮廓、符文与色彩必须属于本项目。

## 7. 免费验证顺序

第一轮不购买素材，按以下顺序验证：

1. 下载 Stylized Nature MegaKit 免费版，替换一组树、岩石和草丛。
2. 下载 Medieval Village MegaKit 免费版，只搭一栋药草师房屋。
3. 下载 Universal Base Characters 与 Fantasy Outfits 免费版；实测后排除 Superhero 玩家方案，使用完整 Ranger/Peasant 服装做 NPC 与修长人形对照。
4. 下载 KayKit Adventurers 免费版，制作第二个漂泊者候选。
5. 在当前固定俯视镜头下做四格对比：剪影、比例、材质、动画。
6. 只有免费验证确定方向后，再考虑 Source/Extra 版本。

## 8. 第一轮通过标准

- 角色在 1280×720 当前镜头下，不看姓名也能分辨玩家、米拉和托伦。
- 新房屋在不增加标签的情况下能读出药草师职业区域。
- 新植被在不增加密度的情况下，比当前场景拥有更清楚的前中远景层次。
- 所有候选能够统一到鼠尾草绿、赭石、木棕、暖橙和魔法青色板。
- 资源导入后无材质丢失、骨骼错误、动画名称冲突和碰撞异常。
- 不出现明显的 KayKit、Kenney、Synty 或 Quaternius 官方演示场景复刻感。
- 异界石环、主角轮廓和序章路线仍是画面中最有辨识度的原创内容。

## 9. 当前决定

- **现在可免费下载测试：** Quaternius Nature、Village、Base Characters、Fantasy Outfits，以及 KayKit Adventurers。
- **暂不购买：** 所有 Pro、Source、Extra 与整套合集。
- **暂不直接导入：** Synty、Kenney 近景建筑、完整成品传送门。
- **下一步：** 用户确认后建立隔离的素材评估目录，下载免费版并制作不影响正式场景的对比测试。
