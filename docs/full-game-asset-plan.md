# 《异世界漫游记》完整版资产选型与制作计划

版本：0.1  
核验日期：2026-09-02  
适用范围：约 20 小时 PC 单机版

## 1. 选型结论

推荐继续以 **Quaternius 环境体系 + KayKit 角色骨架体系 + Godot 原生 Shader/VFX + 原创核心资产** 为主，不再引入第三套近景美术生态。

现成资产负责产量，原创资产负责辨识度：

- 通用自然、建筑、道具：Quaternius。
- 玩家、主要 NPC 与人形动画：现有 KayKit 体系。
- 普通怪物原型：Quaternius，统一材质并重做关键轮廓。
- 主角、古龙、主要 Boss、界环、区域地标：原创或深度定制。
- UI：Kenney 只做结构原型和输入图标，正式界面原创。
- 音频：通用 UI/SFX 可用 CC0 打底；主题音乐、Boss 音乐和标志音效原创。

## 2. 已核验的官方候选

| 类别 | 候选 | 官方信息与许可 | 结论 |
| --- | --- | --- | --- |
| 自然环境 | [Quaternius Stylized Nature MegaKit](https://quaternius.com/packs/stylizednaturemegakit.html) | 116 个自然模型，含 40 棵树、35 种植物/花和 27 种岩石；FBX/OBJ/glTF；CC0；官方提供 Godot 版本说明 | **主环境库**，需统一色板、LOD、碰撞和纹理导入 |
| 村庄建筑 | [Quaternius Medieval Village MegaKit](https://quaternius.com/packs/medievalvillagemegakit.html) | 300+ 模块，内外墙、屋顶、楼梯、门窗；FBX/OBJ/glTF；CC0；Source 版含 Godot 实现与碰撞 | **主建筑库**，只重新组合，不复制官方演示房屋 |
| 道具 | [Quaternius Fantasy Props MegaKit](https://quaternius.com/packs/fantasypropsmegakit.html) | 200+ 家具、工具、武器、书、药水等，4 组共享纹理；FBX/OBJ/glTF；CC0 | **主道具库**，每个生活节点限制数量 |
| 遗迹 | [Quaternius Ultimate Modular Ruins](https://quaternius.com/packs/ultimatemodularruins.html) | 90 个遗迹、地牢和道具模型；CC0 | **结构零件库**，核心界环轮廓仍原创 |
| 地牢 | [Quaternius Modular Dungeons](https://quaternius.com/packs/modulardungeon.html) | 48 个模块化地牢资产；CC0 | **地下空间补充**，必须重做材质和构图 |
| 普通怪物 | [Quaternius Ultimate Monsters](https://quaternius.com/packs/ultimatemonsters.html) | 50 个完整动画怪物；FBX/OBJ/Blend/glTF；CC0 | **战斗原型首选**，正式版每区只选少量并深改 |
| 早期怪物补充 | [Quaternius Cute Animated Monsters](https://quaternius.com/packs/cutemonsters.html) | 21 个动画怪物；glTF 等格式；CC0 | 仅用于低威胁生态与原型，避免整体过度可爱 |
| 玩家/NPC | [KayKit Adventurers](https://kaylousberg.itch.io/kaykit) | 免费版 5 个绑定角色、25+ 配件；FBX/glTF；单图集；CC0 | **现有角色体系继续使用**，重要人物需改色、改配件、改轮廓 |
| 人形动画 | [KayKit Character Animations](https://kaylousberg.itch.io/kaykit-character-animations) | 150+ 免费动作，覆盖移动、战斗、工具和模拟动作；FBX/glTF；CC0；面向 Godot | **近期最快路径**，与当前 23 骨骼角色体系匹配 |
| 动画补充 | [Quaternius Universal Animation Library 2](https://quaternius.com/packs/universalanimationlibrary2.html) | 130+ 动画，含近战、远程、农作等；GLB/FBX；CC0；官方测试 Godot | 只在 KayKit 缺动作时重定向，不同时维护两套重复动作 |
| 角色服装 | [Quaternius Modular Character Outfits — Fantasy](https://quaternius.com/packs/modularcharacteroutfitsfantasy.html) | 12 套、62 个模块、3 套纹理；Humanoid；CC0 | 用于远景和次要 NPC 候选；与 KayKit 混用前必须做比例试验 |
| UI 输入图标 | [Kenney Input Prompts](https://kenney.nl/assets/input-prompts) | 1500 个键鼠、主机、掌机和通用输入图标；64×64；CC0 | **直接采用并二次着色** |
| UI 结构原型 | [Kenney Fantasy UI Borders](https://kenney.nl/assets/fantasy-ui-borders) | 140 个幻想 UI 边框；CC0 | 仅作线框和九宫格原型，正式旅行手记 UI 原创 |
| UI 音效 | [Kenney UI Audio](https://kenney.nl/assets/ui-audio) | 50 个 UI 音频；CC0 | 可作占位并筛选，正式关键音效需统一重制 |

许可结论仅针对核验日期与上述官方页面。下载时保存原始压缩包、页面快照/许可证文本、作者、版本和下载日期；发布前再次复核。

## 3. 不建议直接采用的资产

### 3.1 现成古龙作为最终 Boss

[OpenGameArt 的 Cethiel's Dragon 3D](https://opengameart.org/content/cethiels-dragon-3d) 是 CC0、低多边形、带绑定与动画，可用于碰撞盒、镜头、战斗距离和阶段切换灰盒验证。但其造型不足以承担本项目最重要的商业识别资产。

最终古龙应采用以下任一路线：

1. 委托角色美术从概念、低模、绑定到核心动画完整制作；推荐。
2. 购买可提供源文件的高质量基础龙，取得商业改造许可后重做头部、翼骨、背部界锚和材质。
3. 以 CC0 龙为拓扑/绑定学习参考，从 Blender 中大幅重塑；适合预算有限但周期更长的方案。

古龙必须具有“身体承担世界缝合”的原创特征：背部嵌入破碎地貌、翼膜像世界裂隙、胸腔存在界环光，不做普通西方喷火龙。

### 3.2 大量混用 Synty、Kenney 3D 与不同商店包

这些包可以做白盒，但近景混用会暴露不同的头身、倒角、纹理密度与材质模型。正式区域中，同一视觉层级最多使用一个主资产家族；其他来源只能作为经过统一改造的结构补洞。

### 3.3 成品传送门、完整村庄和整套关卡

不得直接放入可识别来源的完整地标或演示场景。它们会让项目呈现“素材拼装游戏”观感，并削弱界环、雾谷和古龙的原创记忆点。

## 4. 各区域资产分配

| 区域 | 通用资产 | 必须改造 | 必须原创 |
| --- | --- | --- | --- |
| 雾谷 | 现有 Quaternius 自然/村庄/KayKit 角色 | 房屋职业差异、区域道具、NPC 配色 | 石环符文、雾池语言、序章 UI 图章 |
| 赤叶边境 | Nature MegaKit、Ruins、Props | 叶色、枯树、誓团要塞、敌人护甲 | 龙息巨树、区域 Boss、誓团纹章 |
| 沉钟水城 | Village/Ruins/Dungeon 模块 | 铜绿、湿面、倾斜建筑和水下版本 | 沉钟、记忆水面 Shader、档案守卫 Boss |
| 铁雨遗都 | 少量可统一的结构模块与 Props | 金属材质、构装敌人、工业道具 | 倒悬车站、断环核心、机械 Boss 轮廓 |
| 灰烬圣城 | Village/Ruins 模块 | 圣城墙体、誓团 NPC、仪式道具 | 总环大殿、教廷标志、披甲者首阶段 |
| 龙背雪原 | Nature/Ruins/Monster | 雪材质、风化寺院、守鳞者服装 | 巨型龙骨、守鳞寺主景、雪原 Boss |
| 世界伤口 | 已有区域资产的低密度残片 | 跨世界材质融合、崩解版本 | 古龙、界锚核心、结局 VFX 与最终场景 |

## 5. 角色资产合同

### 主角

- KayKit Hooded Rogue 可继续作为可玩骨架和动画基底。
- 正式纵切片前必须完成原创头部/帽兜轮廓、短斗篷、背包、武器和青色印记。
- 目标视觉高度约 1.70m，4～5 头身，俯视剪影能区分头、披风、背包和持物。
- 至少需要 Idle、Walk、Run、Dodge、Light 1～3、Heavy、Hit、Death、Heal、Interact、Echo 共 13 类动作。

### 主要 NPC

- 允许与主角共享骨架，但不能只通过换色区分。
- 每名核心 NPC 至少拥有 1 个职业轮廓件、1 个生活动作、1 个剧情动作。
- 重要角色脸部可保持极简，情绪主要由姿态、停顿和镜头表达。

### 普通敌人

- Ultimate Monsters 先选 6～8 个最匹配的骨架做原型。
- 通过共同 Shader、有限色板、界潮侵蚀部件和区域配件统一。
- 同骨架变体必须至少改变轮廓或动作机制，不能只换颜色充数量。

### Boss

- 区域 Boss 与古龙全部需要定制轮廓；允许复用通用骨架或局部动画，但最终画面不能识别出原包。
- 每个 Boss 先完成灰盒、镜头、碰撞、招式节拍，再投入高成本模型。

## 6. 环境资产合同

- glTF/GLB 为主格式；静态补件可用 OBJ，Blend 仅作为源文件。
- 3D 纹理启用 mipmap，远景避免闪烁；UI 纹理不生成 mipmap。
- 近景主材质控制在 1K～2K；共享图集优先；不直接保留无必要 4K 贴图。
- 建筑必须拆分屋顶遮挡组、墙体、室内暗面和碰撞。
- 大石、建筑和树木准备 LOD 或可见距离；重复草、碎石和小物使用 MultiMesh。
- 资产导入后生成项目自己的 `.tscn` 包装层，生产代码不直接依赖第三方节点名和动画名。

## 7. VFX 与 Shader 计划

建议自制而非购买整包：

- 界环表面、世界裂隙、回响印记、区域界锚。
- 炉火、薄雾、雨、雪、落叶、水纹和天气过渡。
- 攻击弧、破防、命中、治疗、异常状态和 Boss 危险提示。
- 结局中的世界分离、重构与归航效果。

VFX 先用 Godot `GPUParticles3D`、自定义 Shader 和简化网格实现。每种效果需要兼容正常/低特效档，不依赖全屏 Bloom 掩盖造型。

## 8. UI 资产计划

- 输入图标：直接使用 Kenney Input Prompts，再统一成墨线与青/金双色。
- 通用控件：Kenney 边框只用于功能原型。
- 正式原创：Logo、手记外框、任务图章、地图笔刷、阵营印记、武器图标、状态图标和结局图卡。
- 图标总量预估：武器 4、能力 24、物品 30～40、状态 12、地图 20、阵营/任务 20，总计约 110～130 个。
- 优先建立矢量或高分辨率母版，再统一导出到 Godot；禁止逐页面临时画不同线宽图标。

## 9. 音频资产计划

| 类型 | 数量建议 | 资产策略 |
| --- | ---: | --- |
| 环境循环 | 18～24 层 | CC0/自录打底，按区域和天气重新混合 |
| UI 音效 | 20～30 | Kenney CC0 占位，正式版统一响度与材质 |
| 玩家动作 | 35～45 | 通用 Foley + 原创回响层 |
| 敌人与 Boss | 80～120 | 通用素材打底，Boss 标志声音原创 |
| 交互与机关 | 40～60 | 建立木、石、金属、界潮四套声学语言 |
| 音乐 | 35～45 分钟母素材 | 原创作曲，按探索/战斗/剧情分层重组 |
| 配音 | 关键句 100～180 句或完全无配音 | 不建议低预算全程配音 |

音频来源必须保存许可证和原始文件；3D 定位声音导入为单声道，音乐与长环境层使用 OGG。

## 10. 采购与预算优先级

### 零预算阶段

使用现有 Quaternius/KayKit、上述 CC0 包和 Godot 自制 VFX，完成战斗灰盒与 60～90 分钟序章。

### 第一笔预算

1. 主角定制轮廓与战斗动画。  
2. 古龙概念设计和灰盒模型。  
3. Logo、手记 UI 与商店页主视觉。  
4. 序章主题音乐与关键音效。

### 第二笔预算

区域 Boss、核心地标、关键 NPC 配件和音乐扩充。只有纵切片外部测试通过后才投入。

## 11. 下载与准入流程

1. 只从官方作者页面下载并登记版本、日期、许可、URL 和哈希。
2. 放入隔离评估目录，不直接进入生产 `assets/`。
3. 在统一灯光、镜头、比例下制作对比场景。
4. 检查网格、骨骼、动画、材质、碰撞、LOD、纹理和性能。
5. 通过后复制到正式目录，并建立项目包装场景和统一材质。
6. 保存 `LICENSE`、来源清单和修改记录。
7. 每个版本发布前重新运行资产清单与许可审计。

## 12. 近期资产行动建议

不应一次性下载全部候选。下一步仅准备纵切片需要的内容：

1. 从 Quaternius Ultimate Monsters 选择 3 个敌人和 1 个精英候选。
2. 从 KayKit Character Animations 接入轻击、重击、闪避、受击、死亡和治疗动作。
3. 用现有主角制作武器与动作灰盒，不先购买角色源文件。
4. 为山口小 Boss 先做程序化/组合灰盒。
5. UI 只接入 Kenney 输入图标；手记界面先完成线框。
6. 古龙只做概念与尺寸灰盒，暂不采购最终模型。

