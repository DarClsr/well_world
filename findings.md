# 调研记录

- Phase 53 补证时确认 `grass_sweep_capture.gd` 中旧 `14-herb-yard` 机位实际主要拍到房屋切顶，并未覆盖完整药圃；天气专项改为依据药圃中心 `(-14.8, -10.0)` 从南侧正向取景，避免沿用错误标签。

- Phase 32 恢复核对确认：计划仍为 `in_progress`，四个村庄软边磨损节点及对应冒烟断言均已落盘；工作区仍为整库未跟踪状态，没有可归因于外部改动的冲突。
- 现有 MovieWriter 脚本都直接实例化主场景、移动玩家并调整既有镜头，不需要新增录制基类；Phase 32 可用同一模式从广场中心附近拉远镜头检查四处磨损、NPC 与道路关系。
- Phase 32 视觉验证继续使用项目既有的 1280x720 Compatibility 渲染与本机 FFmpeg；无需变更项目设置或安装工具。
- Godot 4.7.1 的最小化 GUI MovieWriter 虽生成含 97 帧的 AVI，但两张稳定段抽帧均为全黑；视觉证据确认最小化冻结了渲染表面，后续录制必须使用隐藏非激活状态而不是最小化状态。
- 隐藏非激活录制得到正常画面，两张动态稳定帧无闪烁、矩形边或地标遮挡；但四处磨损在村庄全景中几乎不可辨，低对比度已弱到无法形成有效生活痕迹，需要只调整现有材质可见度。
- 四块磨损位于广场顶面约 0.01 米之上，动态帧未见闪烁；不可读性的直接原因是共享地面贴片中心透明度固定为 0.24。给现有 helper 增加可选透明度并仅对生活磨损使用 0.34，可保持其他草地色块不变。
- 透明度提高到 0.34 后，18 米村庄全景仍保持克制且无脏块抢视线；该高度高于默认探索尺度，不能据此继续加深，需在约 10 米的中央广场镜头验证实际游玩可读性。
- 用户指出浅绿草地和路面都有白膜感。当前基础色本身已是中深色（草地 `#6f8f65`、道路 `#9a8466`），但场景同时使用灰青全局雾、0.42 环境光与 0.72 暖日光；应先隔离雾和填充光贡献，而不是直接把材质盲目调黑。
- 用户进一步澄清：核心不是曝光白膜，而是纯色地表没有“草地”和“道路”的材质语义。应保留当前光照，优先增加可重复的细小色差与道路压实层次。
- `game-assets` 对地表材质的最小合同是连续、俯视、边到边、双向无缝的 64x64 纹理；当前导入目录只有人物、建筑和植被模型贴图，没有可直接平铺的草地/泥路材质。
- 本机未配置 Meowa 认证，临时目录也没有环境包原始压缩档；仅尝试无需认证的公开 64x64 材质库查询，失败时采用 Godot 原生噪声纹理，不向用户索要密钥。
- 无认证的公开目录查询可用；与当前风格最接近的参考是 `minimal_grass`（`texture-76cf01df5834ea98`）和 `terrain_dirt_trampled_path`（`texture-cc8ac61481c26a5b`）。只下载到临时目录做颗粒度参考，正式地表采用本地程序化材质。
- 两张 64x64 参考都属于明显像素风，不适合直接混入当前低多边形 3D 画面；可借用的材质语义是草地的稀疏短草簇，以及泥路的压实斑点、碎石和细裂纹。
- 自动测试未锁死基础材质颜色或纹理类型。最小正式方案是在现有共享 `StandardMaterial3D` 上挂两张确定性生成的 64x64 灰度调制纹理，并保留现有草绿/泥棕底色、地图几何与碰撞。
- 同镜头 A/B 证明程序化纹理能立即建立草地和压实泥地语义，但首版 UV 平铺过密、深色短划线数量过多，广场出现规则撒点感；下一版应放大纹理世界尺度、细节减半并降低对比。
- 第二版放大平铺尺度并降低颗粒密度后，地表已自然且重复图案基本消失；广场可读为压实泥地，但主路仍缺少结构线索。最小补强是在广场外的南北主路增加两条浅车辙，与现有马车呼应。
- 道路专项的两张动态帧确认：草地与泥路具有不同微结构，主路出现自然纵向压实感和两条浅车辙，支路仍保持泥地语义；车辙无凸起障碍、无闪烁，人物与传送门层级不受影响。
- 用户要求停止继续开发并推送当前版本。当前本地仓库尚无提交，分支为 `master`；目标 `git@github.com:DarClsr/well_world.git` SSH 可访问且远程为空，适合首次提交。
- 待提交范围为 243 个文件、约 109 MB，最大单文件约 5.7 MB；Quaternius 资源与全部音频均有许可/来源记录，敏感字样扫描无命中。60 张阶段截图约 23 MB，作为视觉验证证据保留；`temp/`、`.godot/` 与录制音轨已忽略。

- 工作区初始为空。
- 已安装 Godot 4.7.1，命令入口位于 WinGet 安装目录。
- Stylized Nature MegaKit：CC0，免费标准版含部分模型，glTF/FBX/OBJ。
- Medieval Village MegaKit：CC0，免费标准版含部分模块化建筑，glTF/FBX/OBJ。
- 第一张地图规模较小，不需要先引入 Terrain3D；原生静态网格更容易验证玩法。
- 自然包下载文件为 104,088,529 字节，包含独立 glTF、bin 与共享 PNG 贴图。
- 村庄包下载文件为 161,003,471 字节，包含大量逐部件 glTF；首轮应选择性导入，避免无用资源拖慢 Godot。
- 自然包可直接使用 CommonTree、Pine、TwistedTree、Bush、Grass、Mushroom、Rock 等模型。
- 村庄包提供 Wall、Roof、Door、Window、Floor、Stairs 等细粒度模块，没有一键完成的整栋房屋；原型可保留简单碰撞体房屋，并将真实部件用于可见外观。
- 首轮自然模型选择 CommonTree、Pine、TwistedTree、Bush、Fern、Grass、Mushroom 与 Rock，已经覆盖森林可读性。
- 所选 glTF 均通过相对路径引用同目录 `.bin` 和共享 PNG；可以安全地只复制选中模型及其依赖。
- 村庄首轮只需墙体、门、窗、屋顶和木箱七类模型；碰撞继续由现有简单房屋体积承担。
- 第一张 1280x720 实机帧确认所有 glTF 与贴图正常显示，房屋尺寸和树木比例可用。
- 第一帧光照偏白、出生点能看到地图南侧边界、遗迹仍像灰盒；需要在最终验证前调整。
- 最终帧已修正光照、地图边界和传送门过曝；角色、村庄、森林与探索目标均清晰可读。
- 选择性导入后的资源目录约 70.7 MB，没有把两个完整压缩包加入项目资源目录。
- 当前 DEBUG 游戏窗口正常响应，基础移动场景可以继续迭代。
- 初始场景仍缺少开场淡入和地点识别；传送门为静态模型，画面缺少环境动态。
- 60 帧实机序列确认：首帧近黑，约 1.5 秒时场景和地点标题清晰显现，标题未遮挡角色或传送门。
- 传送门呼吸动画保持幅度克制，没有改变碰撞或场景布局。
- 当前 PID 4008 的 DEBUG 窗口正常响应，可以在本轮完成后直接替换试玩实例。
- 传送门遗迹视觉仍由四根可见方柱和一根横梁组成，是开场画面中最明显的灰盒痕迹。
- 现有自然包已包含两种中型岩石，可直接组成石阵，不需要新增资源或依赖。
- 阶段 6 实机帧确认：九块岩石形成完整拱门，旧方柱和横梁不再可见。
- 圆形石台、发光地面环和横向支路在俯视镜头下连接清楚，传送门成为明确的探索地标。
- 六组道路碎石能打破硬直边缘，同时没有阻挡主路通行。
- 阶段 6 新试玩 PID 35148 正常响应。
- VillagePath、VillageSquare、PortalPath 仍是三个矩形 CSGBox，是当前道路原型感的直接来源。
- CSGPolygon3D 可用单个不规则轮廓替代每段矩形路面，不需要新增贴图或地形插件。
- 阶段 7 实机帧确认三个道路多边形朝向和高度正确，没有翻面或埋入地面。
- 主路边缘已有宽窄变化，入口岩石与低矮植被形成视觉门槛，同时中央通行空间保持完整。
- 主路、广场和支路的连接关系未改变，传送门仍是出生画面中的主要探索目标。
- 阶段 7 新试玩 PID 15408 正常响应。
- Medieval Village 标准包没有木桶或长椅，但提供 Prop_Wagon、木栅栏扩展件和多种墙面藤蔓。
- 当前项目只导入一类木箱；马车、栅栏和藤蔓能以很少的新模型补足村庄生活痕迹。
- 马车尺寸约 1.95×1.53×4.02m，栅栏每段约 2m，藤蔓约 1.54×2.60m，比例可直接用于当前房屋。
- 四个新增模型共复制 12 个文件；木材贴图完全复用，新增贴图只有 T_VineLeaf_png.png。
- Godot 导入日志显示 captures 目录中的验证 PNG 也被扫描，应使用 `.gdignore` 排除该目录。
- 阶段 8 首轮实机帧确认马车、栅栏和藤蔓模型正常，但 CSG 圆形草地色块边界过硬，不可保留。
- Compatibility 渲染器可用透明 StandardMaterial3D 配合 GradientTexture2D，在 PlaneMesh 上实现软边色块。
- 阶段 8 第二轮实机帧确认软边渐变消除了圆形轮廓，地面只保留轻微明暗过渡。
- 马车、木箱、栅栏和藤蔓均正常显示，新增碰撞体没有侵占主路。
- 房屋生活道具主要位于开场画面上缘，保持了“村庄在前方”的视觉暗示，没有抢过传送门地标。
- 阶段 8 新试玩 PID 41328 正常响应。
- 当前仅有 NorthCliff、WestCliff、EastCliff 三条规则长方体边界，南侧没有碰撞边界。
- 现有 Rock_Medium_1/2 可沿边界放大复用，由底层长方体负责连续碰撞，岩石负责打散视觉轮廓。
- 传送门已有共享自发光材质和 `_process` 动画，可用少量 SphereMesh 微光扩展，不需要粒子系统。
- 阶段 9 两个动态实机帧确认微光位置发生变化，亮点尺寸克制且没有遮挡传送门轮廓。
- 新增南侧边界和边界布景没有进入或遮挡开场镜头。
- 四条底层 CSGBox 提供连续碰撞，BoundaryScenery 的 22 块岩石和 8 棵树只负责视觉轮廓，职责保持分离。
- 阶段 9 新试玩 PID 37912 正常响应。
- 玩家、Camera3D 和开场 Tween 都在 `_build_player` 中创建，可以直接加入一次性镜头拉开和落点光环。
- 所有自然模型经 `_add_nature` 进入场景；让 `_add_model` 返回实例后，可只登记草、蕨类和灌木做风摆。
- 阶段 10 首轮动态帧确认镜头拉远和落点环时序有效，但中段光环偏白、偏厚，视觉上接近角色选中框并抢过传送门地标。
- 落点环应保持一次性环境反馈：降低透明度与自发光，并缩窄圆环厚度，不延长持续时间。
- 阶段 10 第二轮动态序列确认：第 30 帧光环已变为克制的细环，第 74 帧完全消失；镜头拉开后的角色、道路和传送门构图稳定。
- 风摆使用现有实例的小幅 x/z 旋转，不改资源文件、碰撞体或场景路径；冒烟测试确认登记数量和旋转变化。
- 当前玩家和传送门都由 `main.gd` 直接构建，传送门接近互动可复用现有 `_process`、材质和灯光，不需要新增 Area3D、状态机或脚本。
- 初始场景已有清晰地标但没有探索回报；一次性的“靠近提示 + 调查文字”是最小的 RPG 互动闭环，同时不扩展到任务或对话系统。
- 阶段 11 动态帧确认：`F 调查` 位于屏幕下缘且不遮挡角色，调查文字保持单行居中，没有形成厚重对话框。
- 玩家进入石台范围后，现有传送门自发光与灯光同步增强；离开时由同一距离值自然回落，无额外状态动画。
- 交互预览中的旧出生点落点环由测试脚本瞬移玩家造成，正式运行中玩家不会瞬移，因此不是游戏画面缺陷。
- 阶段 11 正式开场第 30、74 帧与阶段 10 构图一致；玩家不在交互范围时提示完全隐藏。
- Medieval Village MegaKit 免费标准版没有井、路牌、灯笼、长椅或市场摊位；可用的新增生活化部件只有烟囱，继续搜索独立道具没有收益。
- 当前村屋有马车、木箱、栅栏和藤蔓，但缺少“正在被使用”的动态迹象；烟囱、炊烟和克制窗光能用很小范围补上这一层。
- 完整村庄包已有解压缓存；`Prop_Chimney.gltf` 只引用当前项目已有的 Brick/RockTrim 贴图，新增文件仅为自身 glTF 与 bin。
- `Prop_Chimney` 顶点 y 范围约 2.84–3.18m，资源已按屋顶高度建模，可直接作为房屋子节点放置，不需要额外抬高整个模型。
- 阶段 12 首轮正式开场没有布局回归，但左上房屋窗边光呈现为偏亮黄白色块，当前 0.32 能量过强。
- 出生镜头中炊烟几乎不可见，尚不能证明烟囱和烟雾的近景观感；需要移动镜头到村庄中心做实际复核。
- 阶段 12 村庄近景确认首版烟囱与烟源均被高坡屋顶完全遮挡；必须依据屋顶包围盒整体抬高，当前位置不能保留。
- 当前屋顶模型经 0.82 缩放并放置后屋脊最高约 y=7.06；烟囱需相对房屋抬高约 3.1m，烟源需从 y≈6.45 开始。
- 第二轮村庄近景仍无法辨认烟囱和炊烟；继续凭截图调位置证据不足，需要检查 glTF 节点变换与运行时全局边界。
- 运行时诊断确认烟囱网格实际从模型根 y=0 延伸到 3.18；首屋烟囱顶端约 y=6.28，低于约 y=7.06 的屋脊，并位于相机背侧坡面。
- 烟囱应移向朝相机的外侧坡面（局部 x=-2.45、z=0.8），让屋面自然遮住下段而保留顶部；烟源随其移动，不需要悬空抬高模型。
- 第三轮村庄近景已能辨认左右屋顶烟囱，但烟囱顶端位于固定俯视镜头上沿，炊烟随之出画；仅靠屋顶烟雾无法形成稳定可见的生活动态。
- 广场边缘的小型公共炉火可以复用现有岩石、原生网格、暖光和同一烟雾数组，在常规探索视角提供稳定的生活焦点。
- 公共炉火首轮近景的位置、通行空间和火焰尺度通过，但 SphereMesh 烟雾呈现为三颗边缘清晰的灰球，必须改为软边面片。
- GradientTexture2D + Billboard QuadMesh 的烟雾近景通过：边缘渐隐、灰度克制，连续帧能看出上升位移，不再呈现硬球轮廓。
- 公共炉火位于广场右侧生活区，与马车、木箱和栅栏形成一组，同时保留中央道路完整通行宽度。
- 阶段 12 正式出生开场确认：炉火仅在画面上缘形成小型暖色信号，烟囱可辨认，窗光不再过曝，传送门仍是主地标。
- 当前出生点左侧、道路与树林之间存在约 7×4.5m 的连续空草地，与右侧传送门形成天然构图平衡，且不侵占村屋、主路或边界。
- 浅水洼应采用低饱和蓝绿色，与高亮青色传送门区分；动态只需少量共享水纹，避免形成第二个强地标。
- 阶段 13 首轮动态开场确认水洼位置、岸景和软边融合有效，但水面偏亮青且最大水纹偏强，与传送门色相过近。
- 阶段 13 第二轮动态开场确认：灰绿色水面、水纹强度和岸景融合通过；传送门保持更高亮度与更强轮廓，主次关系明确。
- 当前角色视觉仅由黄色 CapsuleMesh 和红色 TorusMesh 组成，是完善场景中最明显的原型占位符。
- `Player` 的碰撞、CameraRig 与 `Visual` 相互独立；可只替换 `Visual` 子节点并在 `player.gd` 内做步态，不改变移动、碰撞或镜头契约。
- 阶段 14 静态开场确认宽檐旅帽、蓝绿斗篷和红围巾在俯视镜头中形成清楚三层轮廓，尺寸仍落在原碰撞体内。
- 阶段 14 自动行走序列确认角色沿主路正确朝向，帽檐、斗篷、围巾和背包在移动镜头下保持可辨认，CameraRig 没有随 Visual 起伏。
- 双靴和身体起伏幅度保持克制；自动断言覆盖实际节点变化，画面中没有夸张抖动或穿出碰撞轮廓。
- 当前项目没有任何 AudioStream、音频节点或 wav/ogg/mp3 资源，视觉动态全部处于无声状态。
- 阶段 15 音频合同为两条 Godot 可导入循环：全局雾谷自然环境声，以及靠近传送门时更明显的空间低鸣；不加入音乐或配音。
- Meowa CLI 可用但本机未配置认证，按 game-assets 约束不能通过命令行传递凭据或替代服务；应转用许可可核验的 CC0 成品资源。
- OpenGameArt 的 `Park ambiences` 来源页明确标注 CC0；选取林边鸟鸣原录音的 32 秒片段，交叉淡化为 30 秒循环并编码后约 415 KB。
- OpenGameArt 的 `Loopable Dungeon Ambience` 来源页明确标注 CC0 且原文件即为循环；限制为 45-900 Hz 并降低 7 dB 后更适合作为空间低鸣。
- 两个来源、原文件、许可链接和项目内处理方式均写入 `assets/audio/LICENSES.md`。
- 雾谷环境声使用全局 AudioStreamPlayer；传送门使用位于石环中心上方的 AudioStreamPlayer3D，并复用现有距离值从 -24 dB 平滑提升到 -11 dB。
- Godot 4.7.1 已成功导入两段 48 kHz Ogg Vorbis；冒烟测试验证循环、播放、空间位置及近远响度变化。
- 村庄现有三处屋外空位可容纳 NPC：两名前排屋侧与水洼旁均不侵占主路、房屋碰撞或传送门支路。
- 三名村民共享稳定的低多边形人体比例，通过服装色、帽型和挎包/手杖/篮筐区分身份；不需要新增角色资源包。
- 正式出生帧只露出最近的织工，村庄中心近景可看见另外两名村民，形成由外向内发现居民的探索节奏。
- NPC 只动画 Visual 子节点，StaticBody3D 碰撞保持不动；轻微呼吸和转身不会引入移动 AI 或物理抖动。
- 现有传送门提示和单行信息区可直接承载 NPC 交谈；只需增加最近目标判定与文案选择，不需要对话管理器。
- 交互范围采用 3 米并只选择最近村民，避免多个 NPC 靠近时提示抖动；村民目标优先于传送门地标。
- 阶段 17 实机帧确认尼娅对白完整落在底部安全区，单行文本未遮挡人物或道路；玩家与村民并肩时轮廓仍清楚。
- 自动录帧中的出生光环来自测试脚本在场景就绪后瞬移玩家，正式运行靠步行接近 NPC 时不会出现该光环。
- 阶段 18 开场画面复核确认：水洼两岸与南北林缘仍有可用空草地，四组低矮发光植物可增加异世界生态层次且不侵占主路。
- 雾灯菇应明显低于传送门的发光能量和体量，只作为近地细节；共享网格、材质和每组一盏弱点光即可。
- 阶段 18 正式开场帧确认：靠路菌菇清晰但体量很小，未抢过传送门；其余菌群藏于岸边和林缘，需移动探索后发现。
- 当前 0.42 基础发光和 0.12 点光能量在日景中仍可辨认，无需为可见性提高到地标级亮度。
- 阶段 19 复核正式开场图确认：全局高度雾只统一了远景色调，左右林缘和地面仍缺少可见的雾层运动。
- 六片低透明 Billboard 软雾分布在边界即可形成近远层次；中心道路、NPC 和传送门平台不应放置雾片。
- 阶段 19 两帧动态对比确认：左侧水洼与林缘雾层位置发生可见变化，径向渐变没有暴露矩形边缘。
- 当前透明度让雾层可见但不压低道路、NPC 或传送门对比度；继续加浓会损害首屏可读性，因此保留克制数值。
- 当前开场 Tween 只改变 Camera3D 的 FOV，CameraRig 旋转只改变父节点 yaw；滚轮缩放可独立调整摄像机局部位置而不冲突。
- 沿 `(0, height, height * 14/15)` 缩放能保持现有俯角，10-20 的高度范围覆盖近看人物与远看村庄且不改变旋转逻辑。
- 阶段 20 首轮近远景均无穿模、黑边或地标丢失，但近景帧发生在开场 FOV Tween 尚未结束时，不能作为纯滚轮缩放的最终对比证据。
- 延后到开场 FOV 稳定后的受控对比确认：高度 10 的近景保留人物与周边地标关系，高度 20 的远景未露出地图外部且人物仍可辨认。
- 近远两端保持相同俯角，滚轮缩放不改变 CameraRig yaw；当前范围无需进一步扩大。
- 阶段 21 在内部浏览器重新核实 OpenGameArt `Portal sound`：作者 IgnasD，下载为 `PortalSFX.zip`，来源页明确标注 CC0。
- 本地解压候选 `porta.ogg` 为短促单声道传送音，适合作为调查时的一次性空间反馈，不需要生成新音效。
- 阶段 21 首轮 MovieWriter 音轨中触发段未高于环境底噪；根因是默认监听点位于高空 Camera3D，距传送门超过一次性音效的最大衰减距离。
- 俯视游戏的空间音频应以 Player 根节点的 AudioListener3D 为监听点，才能让低鸣和交互音按角色的实际探索距离变化。
- 修正监听点后，实际录音触发前峰值约 -44.4 dB，调查段约 -24.1 dB，反馈提升约 20 dB 且无削波风险。
- 阶段 21 峰值画面中白青闪光仅限石环内部与地面符文，石拱、玩家、道路和底部对白保持清晰；约 0.7 秒回落避免持续过曝。
- 阶段 22 在 OpenGameArt 高级搜索中限定 `Sound Effect`、`CC0` 与 `footsteps grass` 后，仅返回 `Fantozzi's Footsteps (Grass/Sand & Stone)`，适合作为首选候选继续核验。
- 候选来源页标注作者 `Fantozzi`、许可证 `CC0`，下载文件为 `Fantozzi-footsteps.7z`；页面说明归档含 12 个独立脚步，提供 44.1 kHz 16-bit FLAC 与 Ogg，并注明 `Sand` 听感也接近草地。
- 阶段 22 隔离实录确认：玩家脚步源与 Player 根节点监听器同位时，3D 近场增益会触及默认 `max_db`，仅设 `volume_db` 无法约束最终峰值；需同时设置负值 `max_db` 作为绝对上限。
- 最终隔离录音中，脚步行走峰值约 `-34.6 dB`、静止底噪约 `-64.3 dB`；完整混音中静止峰值约 `-46.5 dB`、行走峰值约 `-34.3 dB`，提升约 12 dB 且无削波。
- 最终脚步峰值比阶段 21 传送门调查反馈约低 10 dB，保持了“行走可辨、地标反馈更突出”的层级。
- 阶段 23 首轮近景中 NPC 数值朝向准确、对白布局安全，但圆形头部缺少正面轮廓，导致转身视觉辨识偏弱；增加一个低面数小鼻部即可解决，不需要面部贴图或表情系统。
- Quaternius 官方 `Universal Base Characters`（2025-08）明确为 CC0，含 6 个男女基础体型、20 种发型、约 13k 三角面、人形骨骼、glTF/FBX/Blend，并提供 Godot 4.3 工程实现；与当前 Quaternius 场景风格和许可最匹配。
- Quaternius 官方 `Universal Animation Library 2`（2026-01）为 CC0，含 130+ 人形动画、GLB/FBX/Blend，并明确测试支持 Godot；它与基础人物共用可重定向人形骨骼，但对当前初始场景而言完整库可能过大。
- Quaternius 官方 `RPG Character Pack`（2020-11）为 CC0，含 6 个已经完成骨骼、动画和贴图的奇幻人物，提供 glTF/FBX/OBJ/Blend；它与现有环境同源，且无需先做动画重定向，是当前替换几何人物的最小完整方案。
- 内部浏览器点击官方 RPG 人物包下载弹窗后未生成本地文件，弹窗仍保持打开；后续只解析该官方页面公开下载控件，不使用第三方镜像。
- 官方下载控件公开指向 Quaternius 的 Google Drive 共享目录；目录包含 `glTF`、FBX、Blend、OBJ、Textures 与独立 `License.txt`，可只取当前 Godot 需要的 glTF 路径。
- 官方 `glTF` 子目录包含 `Cleric`、`Monk`、`Ranger`、`Rogue`、`Warrior`、`Wizard` 六个独立文件，约 2.4–3.1 MB；Drive 明确显示知道链接的任何人无需登录即可下载。
- 已通过内部浏览器下载事件取得官方 `Ranger.gltf`、`Cleric.gltf` 与 `Warrior.gltf`，浏览器实际保存到用户 Downloads；下一步需解析 glTF 的 buffer、image 与 animation 引用，确认是否自包含。
- 四个 RPG 人物均已在 Godot 中以约 0.62–0.64 缩放接入；正式开场与交谈近景确认玩家和 NPC 脚底落地、比例合理，没有倒向或被镜头裁切。
- Ranger 的深色披风与弓箭在俯视镜头中轮廓清楚；Cleric、Warrior、Monk 自带服装与装备，比原生几何 NPC 更容易区分身份。
- 村民近景录制中转身误差约 `0.00000019`，真实骨骼模型没有改变现有 Visual 根节点的注视与复位逻辑。
- 三栋村屋都由独立 `Roof_RoundTiles_6x8.gltf` 根节点构成，墙体、碰撞、烟囱与烟雾是同级节点；因此可以只调屋顶网格的 `transparency`，不会削弱房屋边界或生活化细节。
- 房屋碰撞体约 6×6 米，俯视镜头会让屋顶遮住靠近背侧墙面的角色；按玩家到房屋中心约 6 米范围淡化屋顶，是当前小地图的直接解决方案。
- 首轮实机近景证明 `GeometryInstance3D.transparency = 0.72` 仍保留过强的瓦片视觉密度，玩家完全不可见；需要约 `0.92` 才能让屋顶退为位置提示，同时保留房屋轮廓。
- glTF 屋顶使用两个未开启透明模式的 `StandardMaterial3D`，节点级透明度在 Compatibility 渲染器下没有改变画面；复制表面材质并开启 Alpha 后淡出才实际生效。
- 屋顶淡出后，下方可见的 `HouseCollision` CSG 外壳仍会挡住玩家；完整的角色可见性需要淡化房屋可见外壳，同时保持 `use_collision = true`。
- 最终实机近景确认房屋外壳 Alpha 降至约 `0.08` 后，Ranger 与旁边 NPC 均清晰可见，屋顶和墙体仍以轻量轮廓提示建筑占地；该强度适合当前固定俯视镜头。
- 当前村民只有进入 3 米交谈范围后，底部提示才显示姓名；场景内没有 `Label3D`，因此从中距离无法辨认三名真实人物的身份。
- NPC 根节点位置稳定、模型高度约 1.8 米，可直接把固定尺寸的镜头朝向 Label3D 放在局部 y≈2.25，无需改人物模型或增加独立 UI 管理层。
- 首轮实机证明 `Label3D.fixed_size = true` 在当前 10 米近景相机下会放大成数百像素，不适合俯视探索；改用世界空间文字和约 `0.012` 的 pixel_size 才能保持人物优先。
- 最终村民近景中“尼娅 · 织工”约一行紧凑文字，位于人物头顶且不遮挡脸、玩家或底部对白；世界空间尺寸随镜头缩放自然变化，视觉层级通过。
- 米拉、托伦、尼娅当前位置分别位于三栋房屋外侧的开放走廊，沿单轴约 1.2 米往返不会进入房屋碰撞、主路中央或水洼。
- 现有 RPG 人物均包含循环 Walk 与 Idle；把 NPC 根节点改为 CharacterBody3D 并用 `move_and_slide` 移动，可让显示、碰撞、身份标识和交互位置保持一致。
- 阶段 27 动态近景中米拉 2.4 秒实际移动约 `0.715` 米，Walk 步态、朝向和身份标识同步跟随；托伦也保持在东屋外侧走廊，未侵入炉火或主路中央。
- 三条 1.2 米单轴巡游无需导航系统即可在当前静态小地图稳定工作；交谈时立即停步并切回 Idle，离开后恢复 Walk 与巡游方向。
- 当前巡游在 `abs(offset) >= 1.2` 时立即翻转方向，视觉上没有驻足；增加一个与村民数组同序的剩余暂停时间即可改善节奏，不需要行为树或状态机。
- 端点检测应使用 `offset * direction >= range`，这样方向在进入暂停时翻转后，暂停结束不会在同一位置再次触发端点。
- 无窗口测试中连续手动调用 `_physics_process` 时，CharacterBody3D 的 `move_and_slide` 使用引擎内部物理步长，不等同于传入脚本的 `_delta`；行走和端点状态应分别用单步与直接定位验证。
- 阶段 28 实机录制确认米拉在端点进入 Idle 后 0.8 秒位置漂移为 `0.0`；Walk/Idle 过渡、人物朝向和身份标识均保持正常。
- 三名村民使用 1.2、1.5、1.8 秒错开停留，能打破同步往返，同时不需要新增节点或行为状态类。
# 2026-08-31 Phase 29 resume

- Session catch-up reported no unsynced context.
- The whole Godot prototype remains untracked; preserve it in place and do not commit or clean files.
- `CameraRig` is already a child of `Player`; moving the rig in player-local XZ space can add lead without changing camera pitch or zoom.
- `AudioListener3D` is a separate child of the player root, so camera lead must not move it.
- Camera lead should use `CharacterBody3D.get_real_velocity()` after `move_and_slide()`, so collisions and sliding affect the lead direction instead of raw input continuing to pull the view into a wall.
- `CameraRig.position` starts at zero and can be interpolated directly in player-local XZ space because only the visual child rotates with movement; the player root stays unrotated.
- The full headless smoke test passes with the new lead contract.
- Existing capture scripts cover villagers and roof fade but not player movement, so Phase 29 needs one focused movement recording rather than modifying unrelated captures.
- Phase 29 MovieWriter measurements: forward lead `(0, 0, -1.597671)`, right lead `(1.597671, 0, -0.000025)`, and 0.9-second stop residual `0.017234 m`.
- The recording completed at 1280x720/30 fps with exit code 0; only the same pre-existing Godot ObjectDB/resource exit warnings remain.
- Visual frame 55 shows the moving player held below center with more road and village visible ahead; framing remains readable and UI-safe.
- Visual frame 85 shows the stopped player returned to the center composition without a visible jump or scenery boundary entering frame.
- Visual frame 115 shows rightward movement placing the player left of center and opening useful view space to the right; the nearby portal remains coherently framed.
- Visual frame 150 confirms the second recenter completes without UI overlap, character clipping, or incoherent scenery shifts.
- Final full smoke test passes after the MovieWriter capture; remaining ObjectDB/resource exit warnings are unchanged and pre-existing.
- Simplification review found the Phase 29 implementation is already the minimum local change: two constants, one focused method, and one call after `move_and_slide()`.
# 2026-08-31 Phase 30 audit

- Session catch-up found no unsynced context; the project remains wholly untracked and must be preserved in place.
- The current playable process PID 42036 is responsive. No TODO/FIXME/placeholder markers were found in the active player or world logic.
- Phase 30 should be selected from current visual and exploration evidence rather than adding a speculative subsystem.
- The latest village-square frame still has a broad, flat central ground plane. NPCs, hearth, bench, and crates are present, but their movement lacks a strong lived-in activity anchor.
- Phase 30 should improve visible village life while preserving the open road and avoiding a new gameplay subsystem.
- All four current character assets include a `PickUp` animation; the Cleric used by herbalist Mira can support a gathering activity without another character pack.
- The imported village prop subset is limited, but current grass, fern, flower-bush, and mushroom assets are sufficient for a small herb plot at one Mira patrol endpoint.
- Proposed Phase 30: place a restrained herb plot beside Mira's route and play her existing `PickUp` clip during the matching endpoint pause.
- Mira patrols along X from origin `(-4.8, 0, -9.3)` to endpoints `(-6.0, -9.3)` and `(-3.6, -9.3)`; the positive endpoint is the natural candidate for a gathering stop.
- The current patrol update is one direct branch, so a Mira-only endpoint activity can remain local without introducing a behavior framework.
- Mira's positive endpoint sits between the west house and the main road. A narrow X-aligned herb bed around `(-3.6, 0, -10.7)` leaves the north-south road open and gives her a clear negative-Z facing target.
- The gathering pause should derive from the imported `PickUp` animation length rather than guess a duration, preventing the activity from being truncated.
- The imported Cleric scene is already available as a Godot `.scn`, so animation metadata can be queried at runtime without another asset conversion step.
- Existing `_add_box` and `_add_model` helpers can build a non-colliding soil bed, low wooden edging, and reused plants; no new scene, material system, or asset is needed.
- The complete smoke suite passes on the first Phase 30 run, including plot structure, endpoint selection, animation duration, facing, opposite-end idle, and conversation interruption.
- Phase 30 MovieWriter measured a 1.25-second `PickUp`, gather drift of `0.00488 m`, facing error of `0.01695 rad`, and correct transition back to `Walk`.
- The minimized 1280x720 recording completed with exit code 0; only the same pre-existing Godot exit warnings remain.
- Visual keyframes 43 and 57 show a readable upright-to-bending gathering motion; Mira and her staff do not intersect the bed.
- The herb plot stays outside the main road, remains secondary to the character/hearth, and reads as a small house-side work area rather than a new landmark.
- Visual keyframe 82 confirms a natural return from `PickUp` to patrol movement with no pose snap, bed intersection, or label overlap regression.
- Simplification review: this should remain one authored herbalist activity, not become a generic NPC job/state framework until another concrete activity requires it.
- Final full smoke regression passed. The latest playable PID 51692 is responsive and confirmed minimized.
# 2026-08-31 Phase 31

- Asset contract: one loopable Ogg Vorbis hearth crackle, spatialized at the village fire, audible nearby but subordinate to portal feedback and footsteps.
- No purpose-built CC0 audio connector or resource is available, so the previously selected in-app browser is the appropriate surface for focused source-page and license verification.
- Existing audio sources use a consistent CC0 entry format in `assets/audio/LICENSES.md`; the hearth sound should follow it.
- `VillageHearth` is at `(4.8, 0, -3.8)`, and `_build_audio()` already creates direct `AudioStreamPlayer3D` nodes for spatial sources.
- Focused search found one strong candidate: OpenGameArt `Fireplace Sound loop` by PagDev, published 2021-03-13.
- The authoritative source page labels it `CC0`, describes it as a wood-burning fireplace loop, and exposes `fire.wav` (10.3 MB) at `https://opengameart.org/sites/default/files/fire.wav`.
- Attribution is explicitly optional; retain author/source/license in the project license ledger anyway.
- The candidate WAV HEAD request returned HTTP 200 but `Content-Type: application/octet-stream`; it cannot be downloaded under the required `audio/*` media contract.
- Alternative focused search located Wikimedia Commons file `Bones breaking wood fire ice crackling.ogg` through its exact category link; its per-file page and media response still need license/type verification.
- A full DOM snapshot of the Wikimedia file page timed out and reset the browser session; switch to the site's lightweight structured metadata path rather than retry the same page read.
- The reconnected in-app browser is client-blocked from Wikimedia `/w/api.php`; use the official read-only MediaWiki API outside the browser for this exact file's metadata.
- MediaWiki metadata confirms `Bones breaking wood fire ice crackling.ogg` is public domain by stephan, but both metadata and the original media HEAD response report `application/ogg`; reject it without downloading.
- SoundBible's known public-domain fire page is DNS-unreachable in the in-app browser. Further source hopping has diminishing value; use official generation if locally authenticated, otherwise create and validate a local procedural loop.
- Meowa authentication is not configured, so no remote or billable generation will be attempted. Local FFmpeg 8.1.1 is available.
- Final procedural contract: 8.5-second mono 48 kHz Ogg Vorbis; filtered brown/pink noise for combustion, sparse deterministic crackle impulses, and a 0.5-second tail-to-head crossfade for looping.
- First candidate meets the media contract: Vorbis, mono, 48 kHz, 8.5 seconds, 83,068 bytes.
- Two-cycle decode reports `-28.8 LUFS` integrated loudness and `-14.9 dBFS` true peak, leaving ample gain headroom for spatial mixing.
- Decoded loop seam jump is `0.004528`, below the overall 99.9th-percentile sample derivative `0.007951`; no anomalous seam click is indicated.
- Two complete cycles contain no silence longer than 0.1 seconds at -50 dB, and the decoded peak/RMS are `0.174242` / `0.041755`.
- Spectrogram review confirms a continuous low-frequency combustion bed plus distributed high-frequency transient crackles, without bright broadband overload or visible silent bands.
- The first smoke attempt failed before scene load because the new Ogg had not yet been imported by the Godot editor; run the asset import pass before testing script preloads.
- The headless editor import created `assets/audio/hearth_fire.ogg.import`; the validation directory needs `.gdignore` because the first scan also noticed candidate/spectrum artifacts.
- After import, the complete smoke suite passes with the new loop, player state, position, attenuation, and playback assertions.
- Mix validation should compare a stationary player 16.8 m from the hearth with the same player 3 m south of it, avoiding footstep contamination.
- Both minimized MovieWriter captures completed at 1280x720/30 fps with exit code 0; measured listener distances were 16.83 m and 3.16 m.
- Full mix changes from `-61.8 dB` mean / `-47.0 dB` peak far away to `-52.2 dB` mean / `-40.2 dB` peak near the hearth.
- Isolated hearth changes from approximately `-91 dB` far away to `-52.7 dB` mean / `-40.5 dB` peak nearby, proving spatial attenuation.
- Nearby hearth remains below the previously validated footsteps (~`-34 dB` peak) and portal investigation (~`-24 dB` peak), preserving the feedback hierarchy.
- Post-interruption process audit found no surviving game window: the previous replacement closed PID 51692, but the newly launched process exited before verification.
- Console retry PID 42748 survives and its console is minimized, but visible-window enumeration finds no `异世界漫游记 (DEBUG)` render window; this is not yet a verified playable.
- The console parent PID 42748 spawned GUI child PID 39048. The child game window is responsive but `minimized=False`; parent-window state is not valid evidence for the playable.
- GUI child PID 39048 exited before the follow-up minimize call. The parent-console launch shape is not reliable enough for the persistent playable; use the GUI executable directly with immediate exact-window handling.
- Direct GUI launch with exact-title window polling succeeded as PID 55440; both immediate and independent delayed checks report responsive and `Minimized=True`.
- Simplification review: the final implementation is one generated Ogg, one direct `AudioStreamPlayer3D`, and existing smoke/capture paths; no audio manager or mixer abstraction is warranted.
# 2026-08-31 Phase 32

- The latest village view still shows a broad uniform tan square despite added props and NPC activity; soft wear at four activity anchors is the highest-value next visual pass.
- Existing `_add_ground_patch()` already produces radial transparent planes but fixes them at y=0.025 below the village square; one optional elevation argument can safely reuse it at y=0.12.
- Selected anchors: hearth `(4.8,-3.8)`, herb/work area `(-4.3,-10.3)`, wagon `(-5.3,-2.0)`, and east house approach `(6.3,-7.2)`.
- Current playable PID 55440 remains responsive before Phase 32 edits.

# 2026-08-31 Phase 34

- 新下载 Quaternius MegaKit 的同名自然与村庄资产，其 `.bin` 网格与 PNG 贴图和项目现有版本哈希一致；替换同名模型不会带来画质增量。
- Universal Base Characters Standard 免费包实测只含 Superhero 男女完整身体，并不含官方网站完整套件描述中的 Teen/Regular；不能作为免费玩家方案。
- Quaternius Standard Ranger/Peasant 服装为 65 骨骼且不带动画，比例偏修长，更适合 NPC 或静态对照。
- KayKit Hooded Rogue 与免费动画库均为 23 骨骼，骨骼路径一致为 `Rig_Medium/Skeleton3D`；可直接合并动画，无需首轮重定向。
- KayKit 角色使用单张渐变图集和单一材质，无法靠局部 `albedo_color` 精细换装；全局低饱和 Toon Shader 可作为原型，最终辨识色需要专属调色贴图。
- 动画包装必须让 AnimationPlayer 的 `root_node` 指向 `../RiggedModel`；在节点入树前调用 `get_path_to()` 会得到空路径并产生缓存警告。
- 漂泊者在 1280×720 开场、前进和横移录制中落地稳定，帽兜剪影和方向可读；与旧 NPC 的比例差异留待后续 NPC 风格统一阶段处理。

# 2026-08-31 Phase 35

- KayKit Mage、Knight、Rogue 与 Hooded Rogue 使用相同 `Rig_Medium` 23 骨骼，可复用同一个 General/Movement 动画适配器。
- 固定 `Label3D.position.y = 2.25` 不适用于大帽檐角色；角色视觉高度加 `0.28m` 的动态偏移在当前镜头下避免遮挡，同时保留世界空间尺寸。
- 同家族角色的统一基础缩放通过视觉高度比例断言：NPC 必须处于玩家可见高度的 0.8～1.3 倍。
- Mage 帽子、Knight 盔甲和 Rogue 披风形成三种清楚职业剪影，比依赖文字标签更符合新的美术规范。

# 2026-08-31 Phase 36

- 玩家旧出生点 `(0, 1, 14)` 位于主路中央，与“从异界石环苏醒”的叙事不一致；传送门中心约为 `(10, 0, 11)`，适合把出生点改到其南侧约 3 米。
- `NorthCliff` 当前是一整块宽 60 米的碰撞 CSG，虽然道路多边形延伸到 `z=-28`，实际北侧不可形成山口。
- 拆成左右两块悬崖并保留中央 8 米缺口，可在不改变谷地整体边界的情况下建立清楚出口。
- 雾池位于 `(-10, 0, 12)`，传送门支路与主路交汇在 `z≈11`；从交汇点增加短支路即可形成“主线前进 / 可选调查雾池”的序章选择。
- 玩家位于传送门南侧 3 米时会被附近碰撞轻推约 0.15 米，测试应约束 XZ 距目标小于 0.25 米，而不是要求等待一帧后变换完全相等。
- 北侧旧边界景观在 `(0, 0, -24.7)` 放置了一块约 1.9 倍大岩石；即使拆分悬崖，它仍会在实际镜头中封死中央缺口，必须移除。
- 三层无碰撞薄石阶足以提供上升节奏，不会让 CharacterBody3D 在出口前发生物理抖动。
- Compatibility 渲染器下的低透明径向渐变雾幕与背景接近，远景辨识不足；专用 `spatial` Shader 以动态双波形和约 0.6 中心密度提供更稳定的雾墙读性。
- 山口路径直接使用纯色材质会像灰盒；复制现有压实土材质并改为灰褐色，可保留同一世界的表面语言。

# 2026-08-31 Phase 37

- 四向 CSG 碰撞盒可以全部 `visible=false`；现有边界碰撞与视觉山脊不必由同一节点承担。
- 单层 39 个 Rock_Medium 实例加上原有 BoundaryScenery 足以遮蔽当前小地图边缘，无需引入 Terrain3D。
- 北侧山口附近的岩石需要独立尺度上限；全局统一大缩放会再次形成“岩石堵门”。
- CameraRig 的旋转由 Player `camera_yaw` 每物理帧覆盖，测试捕获若要检查固定多视角必须先暂停玩家物理。
- `ValleyBoundary` 场景只暴露一次性 `build(stone_material)`，将碰撞和可见山体封装在同一责任内；主场景不再知道每块岩石的位置。
- 新 `class_name` 在未运行编辑器扫描的无头进程中不可依赖；通过 Node3D 场景接口调用可避免本地缓存耦合。

# 2026-08-31 Phase 38

- 山口已有 `MistPassBoundary`、`MistCurtain`、两枚符石和局部灯光，具备低成本交互反馈所需的全部视觉节点，不需要新增素材。
- 当前 `PortalInteraction/PromptStack` 已统一承载传送门和村民交互；山口应接入同一提示链，避免再建一套 UI。
- 山口中心约为 `(0, 0, -26.5)`，玩家可通行区与村民、传送门交互范围不重叠，可以使用局部距离判断保持优先级明确。
- `mist_curtain.gdshader` 已公开 `density` 与 `flow_speed`，调查反馈可直接短时提高这两个参数，并联动符石发光和缩放，无需替换 Shader。

# 2026-09-01 Phase 39

- 初始传送门石拱轮廓与青色门面已经是清楚焦点，不需要替换主体资产。
- 现有 `PortalPlatform` 是半径 4.1 米、32 边的完整石质圆柱，截图中形成与草地硬切的大块灰色圆盘，是出生区域人工底座感的主要来源。
- `PortalGroundRing` 是连续的规则青色 Torus，俯视下更像 UI 描边；应改为有缺口、大小错落的地面符痕。
- 玩家出生在石环南侧约 3 米，地面改造必须保留南侧站立空间以及西侧 `PortalPath` 的连接关系。
- 全图已有带碰撞的 `ValleyFloor`，因此 `PortalPlatform` 不承担唯一承重职责；可以缩薄并隐藏其大面积外观，仅保留稳定局部碰撞。
- 当前素材库已有 `Fern_1`、`Grass_Common_Tall`、`Bush_Common` 与两种中型岩石，足够在落地点边缘做克制的不对称植被和碎石，不需要新增资源。
- 现有 `_add_ground_patch()` 可以生成软边椭圆色层，适合把遗迹区域压入草地；连续魔法圆环则应改为少量发光短痕，保留青色叙事焦点但降低规则 UI 感。
- 隐藏后的薄 `PortalPlatform` 继续提供局部稳定碰撞，玩家出生与传送门调查测试均通过；地表呈现不再依赖碰撞节点的几何外观。
- Phase 39 首轮实机画面确认灰色圆盘已消失，软边旧土层能够自然接入 `PortalPath`，石拱仍保持主焦点。
- 首轮断裂符痕复用了高亮 `portal_material` 且按径向旋转，俯视下表现为白色短棒；应改用独立低亮青绿材质并沿圆弧切向排列。
- 最终实机画面中符痕退为低亮残缺圆弧，石拱和主角重新成为唯一主焦点；软边旧土层与西侧道路连续，边缘碎石和植被没有侵占出生空间。

# 2026-09-01 Phase 40

- `PortalSurface` 当前与石环共用 `portal_material`，调查反馈只能同时提高整体 emission，无法让门内产生独立深度或流动。
- 门面不承担碰撞，适合从有厚度的 `CSGCylinder3D` 改为面向镜头两侧可见的 `QuadMesh`；径向 Alpha 可保持圆形轮廓并避免硬圆盖。
- 现有 `portal_reaction_time` 已提供调查响应强度，不需要新增 Tween 或状态类；独立 Shader 只需暴露一个 `reaction_strength` 参数。
- Phase 40 两个真实渲染时间点显示门内纹理形态持续变化，中心深青、边缘柔亮，已经形成空间层次且没有压过石拱和主角。
- 录制早期画面中的大白色地面圆环来自既有 `_build_arrival()` 开场反馈，后续帧正常消退，与新门面 Shader 无关。

# 2026-09-01 Phase 41

- “主角出生点的一整个场景”不能继续解释为出生点附近空地；下一阶段必须按整张序章首图评估传送门、道路、雾池、村庄、建筑、NPC 活动和地图边界。
# Phase 41 整图构图审计（2026-09-01）

- 审计范围按完整序章路线处理：南侧异界石环出生点、雾池岔路、中央村庄、北侧浓雾山口与四周边界；不再把任务缩成传送门局部。
- 当前主要问题来自地面大形而非道具数量：南北主路过宽、过直，横向支路形成机械十字；道路边缘缺少疏密节奏和自然收束。
- 村庄广场是一整块低变化的赭色平面，建筑、炉火、马车与 NPC 像散放在空地上，缺少可读的小型活动区和草地回切。
- 山口入口存在道路材质/明度接缝，石阶前后的地表语言不连续；高墙与岩石已建立边界，但入口地面仍像临时拼接。
- 下一步优先重塑道路和广场多边形轮廓、加入低对比软边土色层与少量草地回切；复用现有 `_add_path`、`_add_ground_patch` 和资产，不新增地形框架。
- 门模型局部包围盒中心 `x ≈ 0.514`，证明其枢轴位于铰链侧；共享房屋构造把门放在 `x = 0` 会让门扇整体右偏，应补偿约 `-0.515m`。
- 窗模型局部包围盒底部 `y ≈ 1.016`，模型自身已包含窗台高度；原代码再加 `y = 0.8` 会把窗框整体抬高。墙面外沿约为局部 `z = 0.092`，窗框需向墙内收，使其外表面只凸出约 `0.03m`。
- 独立只读美术审核将房屋门窗和药草圃列为 P0：药圃应至少 `12m²`、能读出两排结构，并位于房屋侧院而非公共广场中央。
- 用户确认旧道路仍像几何块；根因是主路和所有支路均由低点数 `CSGPolygon3D` 直接拼面，材质调整无法消除直切边和楔形岔口。
- Phase 41 将道路改为 Catmull-Rom 采样的可变宽 `ArrayMesh` 路带，并增加透明衰减土肩；主路、支路、侧院步道和车辙共享同一曲线语义，保留原生 Godot 网格且不引入地形插件。
- 移除 `VillageSquare` 后首轮四支路方案仍未过关：支路从主路中心出发且使用不同高度，实机形成星形叠面；正确的连接应从主路边缘起步，并用低于路面的软边纹理地块填充生活核心，而不是让多条路面互相覆盖。
- 软边公共地面仍会在俯视画面中形成一整块浅土区域；最终方案删除公共铺地，只保留炉火、板车、门前等局部踩踏斑，并让草地重新分隔生活节点。
- 窄支路若沿用主路 `0.65m` 土肩，即使中心线弯曲也会重新读成矩形贴片；生活小径土肩收窄至 `0.25-0.32m`，核心与肩部同时在端点渐隐。
- 南侧住宅小径的渐隐起点原本暴露在主路边缘，仍能看见直切横截面；把起点延伸到主路内部后，端头由主路覆盖，独立美术复审确认该 P1 关闭。
- 新增生活气息与场景动效两个独立审核角色。生活审核确认道路层级通过，后续 P1 是炉火公共活动配置、职业工作链和药圃入口拥挤；动效审核确认传送门通过，村庄风摆、炉火烟气和 NPC 日常节奏仍需增强可感度。
- Phase 41 下一轮继续遵守 `docs/art-direction.md` 的克制原则：炉火保持唯一暖色主焦点，每个生活节点只补一种可读痕迹；环境动效增强可感度但不能遮挡道路、角色或打破有限色板。
- 当前初筛能直接匹配生活用途的村庄资产主要是木箱与木栅栏；在未完成完整资产盘点前不引入新下载或新系统，优先复用现有模型和简单场景几何。
- 完整盘点确认村庄包只有房屋模块、板车、木箱、木栅栏和藤蔓，没有现成长凳、锅具、织布架或篮筐；自然包也只有树、岩石、草、蕨和灌木。为避免混入新资产风格，生活节点使用现有木箱/栅栏配少量简单 CSG 木板。
- 当前炉火中心正落在 `VillageHearthLane` 上，既像道路装饰也干扰生活动线；应把炉火向东侧住宅侧退约 1m，保留道路一侧开放，再以两组座位形成半围合。
- 现有三栋房屋烟与炉火烟共用三枚烟团和同一漂移公式；炉火烟需要更强近源可见度，但不必新建粒子系统，只需在现有烟团数组中记录尺寸/漂移倍率。
- 当前三朵炉火共享 `5.2Hz` 主频，灯光也复用同频正弦；用每朵不同频率的双波形与更慢灯光组合即可解除同步球状闪烁。
- 权威代码确认托伦当前出生点为 `(5, -7)`，紧邻东侧住宅而非山口来路；移动到村庄北缘主路旁并延长初始守望停顿，能直接修正“守门人身份靠标签”的问题。
- 炉火音频位置直接跟随 `VillageHearth.position`，因此移动炉火不会破坏音频绑定；现有冒烟测试已覆盖该相对关系。
- Phase 41 生活节点首轮实机图确认炉火已退出主路中心，托伦在炉火远景中位于北侧主路边，身份关系成立。
- 首轮两组 CSG 木板长凳在俯视下仍像方正几何块，与刚解决的道路问题使用同一种不良视觉语言；应直接改为八边低模原木座面与木桩支脚，不再用长方体座板。
- 药草晾晒架首轮被房屋遮挡，只剩细立柱和木箱；织物晾晒线也落在南屋机位边缘。两者必须移到各自工作区可见一侧，否则新增节点不产生职业辨识价值。
- 炉火时间对比帧已能看到三朵火焰形态和托伦朝向发生不同步变化，但烟团只形成很淡的灰斑；需要为炉火三枚烟团增加节点级可见度倍率，继续共用现有材质即可。
- 药圃风摆对比帧受屋顶淡出和 NPC 移动干扰，不能仅凭两张静帧证明阵风可感度；最终动效审核应直接检查同一 AVI 的连续帧或更短间隔序列。
- 生活气息复审确认炉火公共停留、米拉采摘-晾晒-收纳链、尼娅职业痕迹和托伦守门身份均已关闭；药圃入口由 P1 降为 P2。
- 织物线当前横跨南侧门前小径，即使没有碰撞也会让玩家视觉穿模；必须移到小径一侧并与道路大致平行，保留连续净通道。
- 美术复审指出三块织物仍是等厚矩形色卡，晒药架的草束在俯视距离下只剩小黑绿点。下一版保留色板和节点数量，但让布片下垂、不等长、不齐底，并放大、降低、错开三至四束草药。
- 动效最终复审确认植被阵风、三焰异步、炉火慢速灯光和近源烟全部通过；唯一 P1 是基础 `SphereMesh` 轮廓仍稳定读成三颗橙色椭圆球。
- 火焰 P1 不需要粒子系统或新 Shader；保留现有位置/缩放/灯光公式，只把基础几何改为底宽顶尖、轻微偏斜的低面数挤出火舌即可。
- 托伦已具备开场守望位置，但后续仍是等速短直线往返；动效审核将其降为 P2，后续通过不对称长停顿和更短巡逻距离处理，不需要行为树。
- 第三轮静态复审确认晒药架和织物线两项 P1 全部关闭：横绳与四束错落草药在实际俯视距离可读，三块布的下垂与不齐底边消除了色卡感；织物线移出小径后通行关系通过。
- 炉火基础改为七点挤出低模火舌后，最终 1280x720 连续录像确认三焰均为底宽顶尖、轻微偏斜的异步剪影；动效审核关闭球状火焰 P1。
- 托伦采用唯一的职业节奏特例即可表达守门：`0.65m` 巡逻半径、`0.45m/s` 速度和 `4.2s/6.0s` 两端不对称守望；无需把全体 NPC 巡游改造成配置系统。
- 托伦最终 4.45 秒专项录像经动效复审通过：Idle 面向山口、慢速两三步巡视、另一端平滑转回守望，完整周期中停顿显著长于移动且没有倒退滑行或停步播 Walk。
- `Window_Wide_Round1.gltf` 的玻璃是独立 `MI_WindowGlass` 表面，原始基色接近白色且 Alpha 仅约 `0.095`；无需改模型或加灯，只需在现有房屋材质覆写循环中给该表面设置低强度暖黄自发光即可保留木窗格并消除纯白洞口感。
- 首轮暖色覆盖仍形成整块橙色填充，根因不是窗格模型缺失，而是房屋遮挡逻辑把所有材质的恢复 Alpha 硬写为 `1.0`；记录每个材质自己的基础 Alpha 后，普通墙体恢复到 `1.0`、暖棕玻璃恢复到 `0.66`，中心与炉火机位都重新读出深色横竖窗格。
- 窗面最终使用低饱和暖棕、`0.18` 自发光和现有 `0.14` 能量 `WindowGlow`；未增加灯光或窗户动画，炉火继续保持更亮、更饱和且唯一动态的暖色主焦点。
- 下一轮整图审计发现 `phase41-village-final.png` 仍包含后来已删除的大块广场，属于过期证据；当前状态必须以 `phase41-window-final-*` 与 `phase41-road-final-*` 机位为准。最新画面中三角山墙接近纯白、屋瓦偏高饱和，是建筑材质统一的首要候选问题，等待独立复审和导入材质核对后再定 P1。
- 独立整体美术复审把优先级改判为“整栋房屋透明避让造成幽灵叠层”：多层屋瓦、木梁、墙面和道具以低 Alpha 同时覆盖角色，影响药圃、织工与南屋三个核心机位。现有房屋组合中真正跨过玩家视线的是 `Roof`，因此只让屋顶木构和瓦面淡出到零，墙体、门窗、烟囱、碰撞壳与生活道具保持实体，是比调低整栋 Alpha 更直接的根因修正。
- 首轮仅淡屋顶的隐藏录制关闭了透明条纹，却暴露 `HouseCollision` 兼任可见实体的结构问题：屋顶消失后出现完整亮色箱体顶面，烟囱悬在箱体上方。正确结构应把碰撞盒设为不可见，复用同一灰泥材质补三面无顶墙壳，并让烟囱归入屋顶淡出层。
- 第二轮无顶墙壳录制已消除亮色顶板、悬空烟囱和多层透明纹路；药圃与炉火机位的立面/门窗保持实体。当前剩余审美判断是开顶后直接看到绿色室外地面是否仍像临时切片；织工旧捕获点位于碰撞体内部，属于脚本直传产生的不可能站位，不能作为运行时验收证据。
- 美术复审确认原幽灵叠层 P1 已关闭，并把绿色室外地面穿入开顶房屋列为唯一新 P1；使用内缩于墙体的低饱和暗暖棕哑光地面即可建立安静室内暗面，不应扩展为完整室内或家具制作。
- 第三版进入/离开各 12 帧接触表显示屋顶瓦面与木构连续淡出/恢复，烟囱同步，没有透明排序跳变、悬空亮块或单帧闪烁；画面中的大幅构图跳变来自捕获脚本切换固定机位，不属于游戏内镜头行为。
- 三类最终复审一致通过：屋顶切顶形成实体墙+暗色地面的绘本舞台剖面，门窗/炉火/职业节点和通行关系不变，屋顶与烟囱动态过渡无闪烁或排序异常。生活审核保留的下一项独立 P1 是板车车辕背离板车支路和主路，属于局部朝向/卸货关系问题，不与本轮遮挡结构混改。
- `Prop_Wagon.gltf` 的局部包围盒沿 `-Z` 延伸到约 `-3.15m`，但首轮真实录制证明可见车辕实际沿局部 `+Z`；仅凭整体 AABB 无法区分车身和车辕。`VillageWagonLane` 末段朝主路方向为约 `(+2.0,+0.4)`，因此应以实机几何为准，将局部 `+Z` 旋到该方向（约 `+1.37rad`）。
- 第二版板车画面已证明车辕转向支路与主路，但总览机位把板车裁在画面下缘，无法同时核对车轮、卸货箱和绕行空间；最终验收必须使用以板车为中心、玩家仍位于真实可达位置的近景机位。
- 最终候选近景 `phase41-wagon-final.png` 为 1280×720 实机帧：板车完整入镜，车辕沿支路朝主路且尖端未伸入主路，两个卸货箱落在车身后侧，玩家位于板车左侧可达草地；车身周围仍保留可绕行空间，等待美术与生活关系独立复审。
- 板车最终双复审通过且无 P0/P1：车辕、支路与主路形成可驶入/驶出的连续关系，车辕不侵入主路，车轮落在停车磨损区，核心碰撞不覆盖车辕且不封支路；两个箱子在车尾卸货区。美术仅保留小箱辨识稍弱的可选 P2，不值得扩大本轮改动。
- 排除山口和北侧雾幕后，Phase 41 最终三类总验收均无 P0/P1：整体美术确认道路、建筑、职业节点、切顶和板车的材质/构图层级一致；生活审核确认职业链、公共停留、住宅入口与通行净空成立；动效审核确认板车静态调整不进入任何动画链，既有屋顶、炉火、植被、传送门和 NPC 动效结论保持有效。米拉靠房交谈位略紧与小箱辨识稍弱均为不值得扩大改动的 P2。

# 2026-09-01 Phase 42

- `portal-phase40-final.png` 早于 Phase 41 平滑道路，`phase41-road-final-south.png` 又早于最终屋顶切顶结构；两张画面都不能代表当前连续路线。下一步必须从同一当前构建重录石环、岔路和村庄入口，再决定真正的最高价值缺口。
- 当前统一实机帧显示：异界石环本体仍是清楚的冷青主焦点，但其下方与右侧前景大面积空绿地缺少画框层次；主路岔口则由宽土路占据大部分画面，传送门、雾池和村庄方向都只出现在边缘，缺少一个负责组织三向视线的中间记忆点。是否需要补功能性路标而非纯装饰，等待村庄入口帧和独立复审共同确认。
- 默认第三张 `(-6.7, 5.0)` 机位位于南屋侧院并触发屋顶避让，不是沿主路进入村庄的合法路线证据；Phase 42 捕获改用 `x≈0` 的三个主路站位，不以侧院切顶画面判断入口构图。
- 合法主路站位显示炉火已在村庄远端形成微小但明确的暖色目标，主路也能连续引导北行；薄弱处是岔口到村口之间仍像宽土路穿过均匀草地，缺少连接“陌生冷青遗迹”和“有人生活的暖村庄”的中间层。候选解法应是单个有方向功能的低矮路标/界石节点加克制框景，而不是新增大地块或道具堆。
- 双代理审计确认路线功能与生活逻辑本身已经成立；生活审核把村界标记视为可选 P2，美术审核则把“岔口到村口缺少明确构图转换”列为 P1。Phase 42 采用两者交集：只在村口一侧增加低于玩家肩部的单个界石/旧木方向件，借用对侧现有红灌木与岩石形成不对称框景，不新增第二门柱、发光、文字或成片植被。
- 村界标记首轮位置与对比度合适，但木质横臂在俯视投影中与竖杆重叠，轮廓更像弯木桩而非方向件；第二版只在原横臂末端补一个低面数木质三角箭头并略加粗木件，不扩展节点范围。
- 第二版箭头从岔口和村口两个玩法站位均可读，位于主路肩外且弱于玩家、传送门和远端炉火；现阶段唯一审美风险是轮廓可能过于直白、像嵌入世界的 UI 箭头，需由美术代理判断是否应改回更含蓄的界石语言。
- 第二版双复审一致把标准向上箭头列为 P1：位置、净空与阈值功能通过，但三帧中持续读成导航 waypoint。第三版保留位置与岩石落脚，删除长直箭杆和三角尖，改为约 0.72 米高的六边不对称旧界石与朝村庄侧短木楔。
- 第三版岔口与入口实机帧已不再出现标准箭头或 UI 轮廓；界石比普通碎石更竖直，能与后方红灌木/大岩石形成一前一后的不对称村口门槛，同时对比度明显低于玩家、传送门与炉火。等待越过站位和独立终审确认。
- 第三版最终三类复审全部通过且无 P0/P1：美术确认旧界石关闭村口阈值缺口并消除 UI 化，生活审核确认它像长期风化的人为边界设施且不影响主路/切角，动效审核确认静态节点未进入任何更新链。远处可能先读成特殊立石属于可接受 P2，不应再加大、加亮、加箭头或增加第二标记。

# 2026-09-01 Phase 43

- 雾池当前已有 `8×5.2m` 径向软边水面、椭圆不可见碰撞、八块岸石、五株风摆植物和两枚循环涟漪；节点数量本身不能证明调查舞台成立，必须从支路终点的真实可达站位检查岸线、停留空间和焦点层级。
- 接近与东岸停留两张当前实机帧显示，支路虽能把玩家送到水边，但水面主体被左侧织工屋和红树冠大面积遮住；画面首先读成“织工屋侧院与主路岔口”，雾池仅剩阴影中的一角和单枚涟漪。
- 东岸停留空间没有朝水面形成清晰开口，岸石与植物更像散落边饰，尚未组织出“站到这里调查”的弱焦点。需用东北岸侧看帧区分这是单一机位遮挡，还是雾池空间与住宅边界发生根本冲突。
- 东北岸侧看帧仍把水面压在住宅与大树阴影下，前景由均匀草地和灌木占据；三处合法站位结论一致，根因是雾池、织工屋和红树的空间重叠，而非单一机位失效。
- 三类独立复审中，动效审核通过且只有双涟漪节拍对称的 P2；美术与生活审核均判定调查舞台不通过。共同 P1 是水体轮廓、临路岸线和支路终点被住宅/树冠遮压，空间先被读成织工屋侧院。
- Phase 43 先采用美术审核的单一构图级修正：将整套雾池向东移动 `2.2m`，并保持水面东缘与主路西缘约 `2.2m` 的通行间隔；支路末段与三个验证站位同步平移。暂不叠加生活审核建议的半月岸台，待移动后的实机画面确认是否仍有必要。
- 东移后的接近与东岸帧能连续看见约三分之二水体，完整椭圆轮廓、岸石和涟漪已从住宅/树影中分离，原先“青色地面斑块”的构图 P1 基本关闭。剩余问题集中为支路末端直接摊进水边、缺少明确停留边界，生活审核提出的紧凑岸台因此成为独立候选，而不是与移动同时混改。
- 东北岸改后帧同样能连续读出水体与临路岸线，确认东移无需继续放大。支路终点采用现有软边地面能力增加 `2.04×2.85m` 的低对比磨损岸台，长边沿岸线展开，并将道路端点收回岸台中心；两侧既有岸石已自然形成开口，不新增或搬动道具。
- 最终接近与东岸帧中，`PondLookout` 没有形成新的硬边几何块，而是把道路渐隐端补成沿岸展开的轻微踩踏面；主路分岔、岸边停留和正前方水面已能在同一画面连续读取。岸台中央保留玩家站立与转身净空，需由生活审核确认其克制程度是否足够表达终点。
- Phase 43 三类终审全部通过且 P0/P1 清零：美术确认三视角约 60%～75% 水体可读、岸线连续、住宅和树冠退为框景；生活审核确认岸台、两侧岸石、玩家 `0.45m` 半径净空与独立探索归属成立；动效审核确认静态移动未改变涟漪/风摆层级。唯一保留 P2 是双涟漪固定半周期错相略规则，不值得扩大本轮改动。

# 2026-09-01 Phase 44

- Phase 43 改变了雾池与主路岔口的构图关系，因此 Phase 42 的路线截图不再足以代表当前完整出生路线；下一处改动必须从同一当前构建的连续实机帧重新判断。
- 当前岔口帧中左侧雾池、右侧异界石环和北向村庄主路已经能同时作为三向选择读取；代价是岔口中心仍由宽且明亮、接近十字展开的土路大形占据，玩家、水池、石环和织工屋在同屏互相争夺层级。
- 村口接近帧会把视觉重新收束到北向主路与远端炉火，说明焦点接力没有整体失效；现阶段候选缺口集中在岔口地面大形，而不是再增加区域地标。
- 越过村口后，房屋、板车、职业节点和炉火均能建立生活层级，但约 `4m` 宽的浅土主路继续贯穿画面中央且几乎不收窄；它与岔口的大块亮路面属于同一尺度问题，可能让小村读成道路两侧摆放资产，而不是道路嵌入村庄。
- 三类审核的唯一交集是主路比例：美术与动效将其列为 P1，生活审核虽判为 P2，也认为这是当前最高价值优化。Phase 44 只把村庄核心段半宽收至 `1.6-1.65m`，路口约 `1.75m`，南北入口以 `1.85-2.0m` 渐变，远端保持原宽；不增强传送门、雾池、NPC 或炉火。
- 收窄后的岔口与入村实机帧保持三向选择和所有支路接口连续，纵向主路不再吞掉中央大部分画面；道路两侧重新出现连续草地边界，织工屋、红灌木与远端炉火的相对权重上升，且没有产生瓶颈、尖角或新的星形铺地。
- 用户指出角色资产偏大；运行时实际渲染包围盒确认主角约 `2.17m`、尼娅约 `2.18m`、米拉约 `2.65m`、托伦约 `2.54m`。由于源资产高度差异明显，统一乘同一个缩放值会保留 NPC 尺度失衡；应按资产原始高度归一到统一目标视觉高度，并同步校准胶囊碰撞，标签仍按 `_visual_height()` 自动定位。
- 进一步脚底探针确认 NPC 模型脚底与地面一致，但玩家视觉脚底跟随胶囊中心停在世界 `y≈0.96`，存在近 `1m` 悬高。角色比例修正因此统一到约 `1.70m` 实际视觉高度：玩家/尼娅 `0.78`、米拉 `0.64`、托伦 `0.67`；玩家与 NPC 都改为根节点落地、胶囊中心 `y=0.8` 的结构，玩家胶囊 `0.38×1.6m`，NPC 胶囊 `0.32×1.6m`。

# 2026-09-01 Phase 45

- Phase 44 道路修正经三类终审通过，角色尺度按用户新增反馈独立进入 Phase 45，不以道路验收掩盖新的比例问题。
- 修改后运行时高度为玩家 `1.695m`、米拉 `1.699m`、托伦 `1.704m`、尼娅 `1.701m`；玩家出生于石台顶面时脚底 `y≈0.058m`，与石台表面一致，NPC 脚底均在地面 `y≈0`。
- 尼娅与米拉两处最终实机帧确认角色已回到环境比例：主角在同景深约占门洞高度 70%～75%，织物线、药圃和板车重新读成可供人物使用的生活设施。当前唯一新候选是姓名标签保持原字号后相对缩小的 NPC 略宽，需结合托伦与总览帧判断是否影响场景层级。
- 托伦与村内总览继续确认角色实体比例成立：托伦不再堵住主路，主角也不再压过板车、房屋和炉火。姓名标签相对角色过宽的问题在托伦帧最明显，标签已成为比身体更强的视觉块并出现边缘读不完整，需由专项审核判断是否应只收敛 `pixel_size`。
- 三类 Phase 45 首轮终审一致认可角色实体比例；美术将 `IdentityLabel.pixel_size = 0.012` 列为唯一 P1，生活与动效分别列为 P2，差异只在建议值 `0.009/0.010/0.0105`。按美术可读性标准采用最严格的 `0.009`，其余标签与角色参数不变。
- 重新隐藏录制的四站位 60fps 画面确认：尼娅与米拉标签近景仍可辨认，宽度已收回到人物轮廓附近；托伦与玩家相邻时标签不再压住角色；村内总览中职业节点和角色实体继续优先于文字。
- 最终三类复判均通过，P0/P1/P2 清零。`pixel_size = 0.009` 下标签淡入淡出连续，Idle、Walk、PickUp 轮廓保持可读；无需再改字体、描边、动态高度、显示距离、角色比例或交互参数。

# 2026-09-01 Phase 46

- 当前构建六站位基线为 1280x720、60fps、7.2 秒；同一录像依次覆盖传送门、雾池、药草师侧院、炉火住宅、织工住宅和北侧道路，环境与角色均来自 Phase 45 后的现状。
- 初步视觉审计确认传送门冷青、炉火暖色、道路和三处职业节点仍可读；跨多个站位的候选缺口是树冠、房屋和岩体产生的深色大面积投影，在药草师/织工画面中切断中景并局部吞没角色或生活设施。需由三类代理区分这是合理绘本框景，还是应收敛的全局光影 P1。
- 用户提供新的“画面与活世界优化任务”后暂停场景 P1 审计，转为只读评审执行说明。现有 `temp/grass-demo` 证明 MultiMesh、昼夜和生态机制可运行，但视觉不可原样移植：9000 株草形成均匀高饱和地毯，午夜仍明显压黑，道路提案复用了地皮纹理而非独立土路纹理。
- 生产代码当前以 `_surface_texture(true/false)` 共用生成器、主路两横向顶点、固定午间光照和逐帧独立写入传送门/炉火/灯菇能量；修订方案必须拆分地皮与道路纹理、为中道磨损增加第三横向顶点，并把昼夜倍率组合进既有动态公式，不能让两个系统互相覆盖。
- 当前共有 15 个实例化主场景的捕获脚本；时间系统落地时必须统一锁定 `time_hour`，且生态运动不能继续使用 demo 的 `Time.get_ticks_msec()`，否则同一机位证据不可复现。
- 自然资产库只有 `Rock_Medium_1/2`，没有 `Rock_Small` 或 Pebble 资产；道路碎石若实施，应复用这两种模型的小比例实例并限制总数，不能引入 demo 的光滑 `SphereMesh` 视觉语言。

# 2026-09-01 Phase 47

- 当前 21 机位实机扫查确认绿色地皮旧斜向正弦带已经消失；10 米近景能读出低对比短草痕，20 米远景和四角斜视没有摩尔纹、鱼骨纹、UV 接缝或方形重复块。
- 地皮暖冷变化保持在鼠尾草绿灰范围，传送门青光、炉火暖光、雾池水纹、玩家与 NPC 轮廓仍高于地皮视觉权重；道路旧斜纹属于任务 3，未混入本项修正。
- 美术与动效复审均为 P0/P1/P2 清零；生活气息复审无 P0/P1，仅保留短草痕密度在大片空地略一致的 P2。该项不值得为静态地皮新增遮罩系统，转交任务 2 的草甸分簇密度验收共同观察。
- `tests/grass_sweep_capture.gd` 当前不含时间或天气状态，因为生产时间系统尚未落地；任务 5 后必须统一显式锁定 `time_hour`，随机天气也必须可锁定种子和状态。

# 2026-09-01 Phase 48

- 已验证 demo 的 9000 株全场均匀随机只证明 MultiMesh 和风摆可运行，不能直接移植；当前地图需要按多条曲线道路和生活节点做固定种子筛选。
- `Grass_Common_Tall.gltf` 为单网格单材质，303 顶点、978 索引，原始高度约 `1.84m`；生产实例应缩放到约 `0.28-0.46`，避免草叶接近角色高度。
- 当前硬排除中心与范围可直接来自生产布局：传送门 `portal_center` 周围、雾池 `(-7.8, 12)` 的 `8.0x5.2m` 水面、药圃 `HERB_PLOT_POSITION` 的 `4.6x2.8m`、炉火 `(4.3, -5.5)` 活动区，以及三栋房屋周边。
- 道路由八条中心线构成，不能沿用 demo 的 `abs(x)` 直带排除；用候选点到中心线线段的最近距离和对应安全半宽进行筛选，既能保持路肩贴草，也无需新增导航或地形系统。
- 首轮 21 机位确认 MultiMesh 与全部硬排除生效，但 `0.28-0.44` 缩放和整个村庄 `1.2-8.2株/m²` 的连续密度形成深色地毯，远景压过炉火、角色与道路，不符合“植被按簇、地面最安静”。
- 第二轮应把单株高度收至约 `0.37-0.63m`，只让 `VillagePath` 主路肩持续保持 `6-9株/m²`；村庄其他区域通过固定种子低频阈值形成高密草簇与明显空地，而不是给所有支路套连续密带。
- 原 Grass.png 带黄绿橙色条，直接乘色仍保留过深、过杂的源色；Shader 应先压缩为稳定明度，再乘 `vec3(0.72, 0.95, 0.70)` 鼠尾草重映射，只保留约 5% 原始色相差。
- 第二轮分簇与尺度已明显改善，但近景草叶仍近黑；根因是导入网格自带 `COLOR_0` 顶点色，Shader 的 `COLOR` 无法只表示实例亮度。实例 ±6% 明度改走 `INSTANCE_CUSTOM.r`，从源顶点色中解耦。
- 第三轮绕开顶点色后草叶仍偏暗，说明当前太阳角度下双面草片的侧向/背向漫反射是主要剩余因素；用同色 `20%` emission 只抬高白天最低可读亮度，仍保留主光和实例明度变化。
- 第四轮 21 机位经三类独立审核一致判定不通过：草片在日照区仍读成近黑墨线，阴影内又因 `20%` emission 偏亮；主路肩强制密度形成连续程序刷带，远景有高频点线，晾衣区与托伦巡逻区也缺少踩踏留白。
- glTF 明确设置 `doubleSided: true` 且提供单向法线；关闭背面剔除后必须在 Shader 中按 `FRONT_FACING` 翻转背面法线。继续提高 emission 只会扩大阴影内自发光，因此第五轮改为法线根因修正并把环境提亮收至 `4%`。
- 路肩间歇分簇无需新增遮罩或第二套系统：复用同一个固定种子 `FastNoiseLite`，用偏移后的低频采样门控 `6-8株/m²` 路肩簇，保留明确断口；村庄普通草簇同步降低覆盖率，但高密簇仍满足原密度范围。
- 第五轮 21 机位证明背面法线修复有效：旧近黑墨线和阴影内异常亮线消失，路肩硬刷带与活动区穿插也已关闭。但 `20-34m` 使用完整三维相机距离，默认俯视相机仅到玩家地面就约 `20m`，使远景草甸过早缩没；同时 `0.48-0.62` 线性明度与浅绿地皮过近，近景草叶辨识不足。
- 第六轮应保持法线翻转、低 emission、固定种子路肩门控和活动留白，只把几何缩退延后至 `26-42m`、草色压深至约比地皮低 `10-20%`，并小幅恢复簇覆盖率；不能回到第四轮的连续草毯。
- 第六轮首次扫查的 `03-21` SHA-256 完全相同，截图实际都停在 `03-portal-west`，不能作为视觉证据。场景脚本仍逐项输出 `SAVED`，同机存在多组断言失败后未退出的 headless smoke 进程；应先精确清理这些测试进程并重录，不能把文件名数量当作 21 机位完成。
- 用户明确指出不应以减少草量解决画面问题。正确目标是保留丰富草甸，用低频簇群、功能区留白、间歇路肩和远景缩退控制噪声；因此第六轮扩大簇门控覆盖，并以全图 `>1600`、村庄 `>1100` 的固定布局下限防止再次过度稀疏。
- 清理遗留失败测试进程后重录成功，21 张截图有 21 个唯一 SHA-256。代表机位显示草量已恢复为可读草甸，灰绿草叶不再是黑线；主路肩形成有断口的簇群，炉火、传送门、角色和生活设施继续优先，晾衣区与托伦巡逻区留白有效。
- 20 米传送门远景与四角机位中，草株退为低对比短线而非黑色单像素网纹，未见摩尔纹；山口仍明显比村庄稀疏。静态证据达到进入动态补证的门槛。
- 固定站位近/远镜头 A/B 四帧均为不同哈希；近景草叶发生克制、不同步的轮廓位移，远景摆幅被距离曲线压低，没有整片同相倒伏或明显闪烁。NPC、水纹和传送门也在同帧运动，因此最终动效结论仍交由专项代理结合 Shader 数学复核。
- 第六轮三类终审通过：生活气息与动效 P0/P1/P2 清零，美术 P0/P1 清零且只保留远景偶见单一草模型重复的 P2。该 P2 后续应通过形态变体处理，明确不能通过减少草量处理；当前 Phase 48 达到验收门槛。

# 2026-09-01 Phase 49

- 当前道路表面仍由 64px 双正弦灰度纹理和 `uv1_scale = 4.0` 构成，沿全图产生规则波纹；主路网格只有左右两列顶点，无法表达中道压实磨损。
- 最小改法是在共享 `_road_mesh()` 仅对正式路面增加中心列和 `0.93` 顶点色，土肩与车辙继续走原有几何分支；中心线、半宽数组、渐隐端点和碰撞均无需改动。
- Phase 48 已用固定种子低频门控形成间歇路肩草，并将道路外 `0.24m` 设为硬排除。Phase 49 保持该逻辑和草量不变，碎石只在土肩内外缘克制散布，避免重新形成连续边带。
- 路缘石应复用现有 `Rock_Medium_1/2.gltf` 而非 demo 的球体；每条道路建立固定种子子组，使用采样路段切线法线计算位置，既贴合曲线又不引入新框架。
- Phase 48 基线道路帧确认旧问题：主路整体近乎同一浅黄色，纵向规则波纹连续贯穿画面；中央仅靠两条很浅车辙表达通行，缺少压实土的横向层次，路缘已有草但道路本身仍像铺开的几何色带。
- Phase 49 当前 21 机位全部为唯一帧。村庄主路、雾池岔口和支路代表帧显示正弦条纹已消失，纵向短痕随道路方向连续，中央压实带与加深车辙形成可读层级，路肩碎石保持小体量且未组成规则边框。
- 草甸分布与 Phase 48 一致：主路外缘仍有贴近土肩的高密簇和明显断口，生活活动区留白未被碎石或新路面侵占。当前视觉风险是近景短痕密度是否略显程序化，交由美术代理结合全套机位判定，不能通过减草处理。
- 远景补查中，纹理短痕随 mipmap 退为均匀低对比颗粒，没有形成正弦带或摩尔纹；主路中心磨损和双车辙在传送门远景仍可辨，但弱于传送门青光与村庄炉火。支路碎石没有排成边线，NPC 与道路交叉位置也保持净空。
- 首轮三类终审中生活气息与动效通过，美术以两项 P1 判定失败：`260` 条/3m 的短痕仍形成均匀砂纸噪声；两条车辙固定宽度、透明度且全程连续，在路口和远景读成程序贴条。共同通过项是道路色调、中心磨损、路线关系、碎石克制和动态稳定性。
- 第二轮保持车辙规范要求的 `0.14m` 宽与材质最大 `0.42 Alpha`，只启用顶点色并加入三处固定、左右错开的平滑缺口与端点淡出；道路短痕降至 `96` 条，让压实土软斑重新成为主体。道路曲线、草量和碎石分布均不动。
- 第二轮 21 机位再次全部唯一。04/06/08/16 代表帧中道路出现成段车辙与安静间隔，左右缺口不再完全同步；短痕退为稀疏的纵向笔触，软土斑和中心压实层重新成为大面积主体，原“连续贴条”和“砂纸噪声”两项视觉 P1 从画面上已关闭，等待三类终审确认。
- 第二轮三类终审全部通过且 P0/P1 清零：美术确认首轮连续车辙与砂纸噪声两项 P1 关闭；生活气息确认设施连接和 NPC 净空不变；动效确认透明 Alpha 连续插值、层间高度和远景频率稳定。保留的 P2 为短痕形态变体、部分长路缘偏顺、少量碎石近等距和缺少移动镜头录像，均不阻断 Phase 49。

# 2026-09-01 Phase 50

- 建筑材质统一必须沿用 `_add_house()` 已有逐表面材质副本和 `house_fade_alphas` 基础 Alpha 记录，不能替换为节点级透明或共享材质，否则会回归 Phase 41 已修复的屋顶遮挡问题。
- `T_RoundTiles_BaseColor.png` 为 2048x2048 手绘瓦片贴图，运行时逐像素转换成本不合理；生成同尺寸派生 `T_RoundTiles_BaseColor_Muted.png`，只做 `0.68` 饱和度倍率和 `-0.04` 亮度校正，原贴图保留且纹理结构、Alpha 与尺寸不变。
- 山墙使用与 `plaster_material` 相同的 `#c6b99a` 暖灰米乘色；屋瓦只替换 BaseColor 贴图，原法线、粗糙度、双面与 `StandardMaterial3D` 类型全部保留，因此可继续直接参与现有逐材质 Alpha 淡出。
- 首个 FFmpeg `hue=s=0.68, brightness=-0.04` 候选在 Godot HSV 中只把平均饱和度从 `0.7334` 降至 `0.6222`，未达到约 50%；`.45/-0.04` 候选降至 `0.4626`，但平均明度也从 `0.6989` 降至 `0.4973`，过暗。需对饱和度与亮度补偿分别校准。
- 最终 `.70/+0.06` 派生贴图的 Godot HSV 采样为平均 `S=0.5341`、`V=0.6714`，相对原图 `0.7334/0.6989` 达到接近 50% 的饱和度与约 4% 明度下降；人工对比确认瓦片破损、青苔和手绘结构均保持，只收敛橙红视觉权重。
- Phase 50 21 机位全部唯一。村庄远近景中三角山墙已从近白色退入墙体暖灰米族，瓦面保持陶土识别但橙红权重下降；炉火仍是更亮、更饱和且唯一动态的暖色焦点。13/14/15 的玩家近屋机位中屋顶切顶、烟囱同步隐藏、实体墙和暗色室内地面均保持原行为。
- 与 Phase 49 同机位 A/B 对比表明改动幅度克制：建筑轮廓和纹理细节完全一致，瓦面只降低橙红视觉权重，山墙与灰泥墙色族更接近；不是统一涂成单色，也未形成比炉火更强的新暖色焦点。
- Phase 50 三类终审全部通过且 P0/P1 清零。生活审核确认暖灰山墙、陶土瓦、炉火、药圃与板车仍有清楚的居住层级；动效审核确认逐材质 Alpha、烟囱联动淡出、窗光独立性和完整/切顶端态均无回归。
- 两个非阻断 P2 不应扩大本轮材质修改：原/派生屋瓦均未生成 mipmap，移动镜头有轻微远景闪烁风险；当前截图未覆盖 `1.0↔0.0` 中间 Alpha，后续统一动态补证时录制 4-6 秒进出阈值录像。

# 2026-09-01 Phase 51

- 生产场景当前只有固定午间 `WorldEnvironment` 和匿名 `DirectionalLight3D`；最小落地方式是保存这两个节点引用，并把 demo 已验证的关键帧采样直接移入 `main.gd`，不新建时间管理器或资源格式。
- 现有 `_process()` 会直接写入传送门、炉火和雾灯菇能量。昼夜倍率必须在同一表达式中组合，不能另设第二段覆盖，否则动态闪烁或时间权重会互相失效。
- 当前捕获目录共有多个主场景实例化脚本；Phase 51 起所有这类证据脚本必须在场景入树后显式设置 `time_hour` 并应用一次固定时间，生态与天气也必须继续使用可锁定状态。
- 最终昼夜实现使用 11 个连续关键帧，现实 `1800s` 对应游戏 24 小时，默认 `9.5` 时；太阳/月光、环境光、雾、背景、阴影与各叙事光源均在现有 `_process()` 内组合，没有引入第二套时间管理器。
- 晨昏硬影通过关键帧阴影不透明度和中间调收敛；夜间玩家可读性用只照额外渲染层的相机同向窄角补光解决，不照地面且白天能量为零。
- 21 机位和 8 个定点时刻证据均可复现；三类终审 P0/P1 清零。静帧未完整证明跨午夜连续播放属于非阻断 P2，可在统一动态补证时录制加速周期。

# 2026-09-01 Phase 52

- 首轮生产契约全部通过，但代表帧暴露两个视觉问题：`0.20x0.14m` 蝴蝶在实际俯视距离下几乎不可读；西侧萤火虫捕获中心落在大树冠下，只看到单个偏亮光点。
- 生态数量和分区不应增加。下一轮只提高蝴蝶小尺寸剪影可读性、把萤火虫颜色压回与雾灯菇同族的冷绿，并把专项证据机位移到无遮挡的林缘空地。
- 最终 10 米镜头中，蝴蝶以 `0.32x0.22m` 浅米双翼出现，同簇 2-3 只且一秒内位置/翼展均变化；萤火虫以 `0.12m` 冷绿微点出现，同簇 3-4 只且不与既有雾灯菇坐标重叠。
- 夜间东侧机位仍保留更亮的传送门青光，西侧保留更大的雾灯菇冷绿帽面；萤火虫只作为低空次级节奏，没有取代叙事光源或形成粒子喷泉。
- 最终 21 机位均为唯一哈希。村庄全景中蝴蝶退为零散浅米细节，不遮挡道路、炉火、角色或生活节点；近景证据仍能辨认双翼和错相运动，满足“远景不抢、近景可读”的层级。
- 首轮三类终审中生活气息与动效通过，美术以 1 个 P1 阻断：蝴蝶虽能看到双翼移动，但中央身体和翼缝在实际尺度下消失，静帧仍像石子、脚印或花瓣。修正只调整程序纹理内部的明暗与轮廓，不增加数量、尺寸、饱和度或发光。
- 最终纹理关闭蝴蝶 mipmap，并用上下翼缺口、收窄翼形和深棕中央身体保留实际游玩尺度轮廓；美术复审关闭原 P1。萤火虫只保留远景昆虫语义依赖动态的 P2，不影响亮度与焦点层级。
- Phase 52 最终 21 机位再次得到 `IMAGE_COUNT=21`、`UNIQUE_HASHES=21`；三类终审 P0/P1 清零，进入固定种子随机天气系统。

# 2026-09-01 Phase 53

- 天气系统复用 `_sample_day()` 的基础结果做乘色/倍率调制，不能在第二段覆盖叙事光源；默认固定日程首段为 `clear`，因此原 09:30 开场画面保持不变。
- 固定种子 `20260902` 生成 13 段日程，四类天气各至少出现三次、相邻和首尾状态不同；晴天最短 5 小时，阴天 4 小时，薄雾/小雨 3 小时，末尾 `0.75` 游戏小时使用 smoothstep 过渡。
- 首轮晴/阴同机位确认天气变化克制：阴天降低直射与阴影权重、略抬灰绿空气感，但没有全屏滤镜或明显改色；道路、玩家、房屋和炉火层级保持。
- 薄雾状态使用约 2 倍基础雾密度，实机只加强中远景空气层，不覆盖道路纹理和角色轮廓；小雨画面约十余条雨线同时可见，A/B 位置不同且没有静态栅栏感。
- 夜雨中道路、房门和角色仍可读，炉火保持唯一高饱和暖色主焦点；雨线比白天更清楚但分布稀疏，没有覆盖炉火、玩家或整屏形成白丝幕。
- Phase 53 三类终审均通过：美术 `PASS 0/0/1`、生活气息 `PASS 0/0/1`、动效 `PASS 0/0/1`；P2 分别是阴/雾辨识略弱、药圃天气证据缺口和缺少天气过渡录像，均不要求修改当前表现参数。
- 新增药圃昼雨机位后，完整药圃、米拉、房门、道路与稀疏雨线同时可读；天气专项证据增至 7 张且 `UNIQUE_HASHES=7`，生活气息证据缺口关闭。

# 2026-09-01 Phase 54

- 新一轮三类审查各提出一个 P1：美术指出旋转镜头和切顶状态下侧后墙/室内仍像空盒；动效指出雨线未按房屋遮蔽；生活气息指出炉火长凳始终无人使用。
- 美术与雨天问题共享房屋边界和切顶表现，合并为 Phase 54；尼娅傍晚作息独立排入 Phase 55，避免同阶段同时修改建筑与 NPC 状态。
- 最小实现复用现有房屋节点和标准材质：侧后墙只增加大块木梁、石基与每栋少量道具；雨线用 `GeometryInstance3D.transparency` 逐实例遮蔽，无需复制 28 份材质或引入室内系统。
- 首轮 21 机位为 `21/21` 唯一哈希；东西南向实图确认三栋侧后墙已有清楚的大块石基、竖梁、顶梁和背窗，近距切顶能读出地毯、长凳与木箱，`0.22` 屋顶淡影仍保留房屋轮廓且未压住玩家。
- 首轮日/夜雨切顶证据显示屋内主体区已无雨线且屋外仍有 24 条完全可见；遮蔽半宽随后由 `2.8m` 校准至覆盖屋檐的 `3.15m`，使用 `0.55m` 平滑边缘，关闭外墙与屋檐边缘的窄穿透风险。
- Phase 54 三类终审通过：美术 `PASS 0/0/1`、生活气息 `PASS 0/0/0`、动效 `PASS 0/0/0`。原侧后墙空盒、切顶空盒和室内穿雨 P1 全部关闭；仅保留透明瓦片近景略有叠线的 P2，不继续调参。

# 2026-09-01 Phase 55

- 生活气息审查确认当前最高收益不是继续加静态道具，而是让昼夜/天气影响已有居民活动；最小范围只为尼娅增加白天织工、傍晚炉火、雨天屋檐与夜深回屋四段固定行为。
- 不建立通用日程资源或寻路系统；沿用尼娅现有 `CharacterBody3D`、`Idle/Walk` 动画和明确安全路点，米拉与托伦逻辑保持原样。
- 首轮四状态定点图确认白天织工点、黄昏路上、夜间炉火和雨天门廊的画面语义清楚；正式证据改为让尼娅从织工点真实行走至炉火并在天气变化后真实转向门廊，避免只用传送端点证明状态。
- 最终真实路线日志为：白天 `work/Walk`，黄昏中途 `hearth/Walk`，夜间终点 `hearth/Idle`，下雨后终点 `rain_shelter/Idle`；尼娅没有被房屋、岩石或道路边缘卡住。
- 四张最终图中炉火仍是夜间唯一高饱和暖色焦点，尼娅位于炉火/门廊的次级层；白天织布区、黄昏主路、夜间门口和雨天道路均保持可读，未新增道具或特效噪声。
- Phase 55 首轮终审中生活气息与动效通过，美术以 1 个 P1 阻断：雨天终点与深色门洞重叠，角色轮廓依赖标签。只将雨天终点从 `(7.8,-4.2)` 横移 `0.8m` 到 `(8.6,-4.2)` 的浅色墙面前，不改路线结构、角色材质或灯光。
- 横移后美术复审确认尼娅头发、肩部和下摆分别落在浅墙与灰绿地面前，不再依赖标签辨认；生活气息复审确认门扇、炉火、长凳和中央道路均未被阻断。
- 炉火与门廊之间改为约 3 米短线直接互切后，动效复审确认 Walk、到达吸附、Idle 和交谈暂停/恢复均正确；仅缺完整 `22:30` 回屋与 `06:30` 恢复录像，作为非阻断 P2 保留。
- Phase 55 最终审核：美术 `PASS 0/0/0`、生活气息 `PASS 0/0/0`、动效 `PASS 0/0/1`。P0/P1 清零，不继续为录像缺口修改生产代码。
- Phase 55 后的下一阶段门禁复审中，三类代理均确认当前出生点场景无 P0/P1：道路、功能分区、角色轮廓、叙事焦点及动效层级已经稳定。
- Phase 55 结束时，透明屋顶局部叠线、局部红叶强度、天气间细微差异、远景草形重复和完整周期录像均属于可选 P2；在当时没有继续迭代指令的前提下暂停扩展。该结论只关闭 Phase 55，不永久禁止后续阶段。

# 2026-09-02 Phase 56

- 用户明确继续迭代后，门禁改为“每阶段 P0/P1 清零即通过，后续按用户目标从 P2 中选择单一高收益精修项”，避免把阶段验收误写成永久停止规则。
- 旧规范把高饱和对象写成固定白名单，和后文“局部使用红叶、火光、魔法或角色色作为焦点”自相矛盾。规范升级为按面积、发光、明度对比和实际注意力顺序管理，允许季节性环境暖色作为次级点缀。
- 重新审视当前成片后，村庄入口及炉火前景的红叶灌木需要按新层级规则重新判断，而不是因为颜色属于红色就自动判定违规。
- 红叶来自 `Bush_Common.gltf` 的单一 `Leaves_TwistedTree` 表面及 `Leaves_TwistedTree_C.png`，不是任务标记；开花灌木使用独立 `Bush_Common_Flowers` 和 `Leaves_NormalTree/Flowers` 表面。
- 若实际构图审核仍判定红叶争焦，最小修正是在 `_add_nature()` 实例化 `Bush_Common` 后复制现有材质并做轻量暖灰乘色；不覆盖源纹理、不改变植被位置、尺度、碰撞或 CPU 风摆。
- 三类审核均确认红叶仍是最高收益的 P2 精修：美术与生活气息指出其在多处白天机位抢过炉火、NPC 和板车，动效指出雨夜仍会形成第二个强暖色块；三方都要求保留红色色相与季节性，而非移除或全面灰化。
- 源图几乎是单一正红色，StandardMaterial3D 乘色只能压暗红通道，无法自然增加灰度；因此使用固定 FFmpeg HSV 变换生成独立 `1024x1024 RGBA` 派生纹理，只绑定 3 个普通灌木实例。
- 首个低饱和候选在 Godot HSV 契约中平均明度低于源图 85%，雨夜可能压成黑紫；保留色度方向并提高中间调后，完整冒烟通过。
- 同一村庄机位的晴天 A/B、日落与夜雨四张实图均有效且哈希唯一。红叶仍可辨识，但从鲜红主色块退为陶土红三级环境点缀；炉火、主角和道路恢复为更早被读取的层级，夜雨中红叶未发亮也未吞黑。
- 21 机位复核为 `21/21` 唯一哈希：3 个普通灌木在各方向一致调色，共用源纹理的红叶乔木保持原样。乔木作为大轮廓季节锚点，灌木以同色族低饱和小色块呼应，没有产生资产割裂。
- 三类最终审核全部 `PASS 0/0/0`。美术确认主次焦点、色族关系和传送门冷青层级通过；生活气息确认 NPC、板车、炉火与道路先于灌木被读取；动效确认风摆、日落和雨夜过渡无回归。

# 2026-09-02 Phase 57

- 当前 `light_rain` 已通过 `weather_rain_amount` 连续调制环境与雨线，但露天村庄炉火的火焰、烟雾与点光仍与晴天完全相同，天气和生活节点之间缺少最小物理联系。
- 最小修正点位于现有 `_process()`：只对三团炉火烟、三片火焰和 `hearth_light` / 炉火发光材质乘以温和雨量系数；房屋烟、天气日程、尼娅作息和场景布局保持不变。
- 夜雨仍须保留炉火为唯一强暖色焦点，因此响应上限是“减弱而不熄灭”，不能把光能或自发光压到窗光、传送门之下。
- 动效审核给出 `GO`，并把晴雨完全一致列为 P1；建议火焰高度约降 `12%-18%`、点光约降 `8%-12%`、火焰发光约降 `6%-10%`、余烬约降 `3%-6%`，炉火烟可见度约降 `18%-28%`，全部直接使用连续雨量倍率。
- 三类审核最终均为 `GO`；美术和生活气息将其视为 P2 精修，动效将完全无响应视为 P1。共同边界是不熄火、不增加蒸汽/爆燃、不改变色相和照明范围，并保证夜雨仍由炉火承担唯一强暖色焦点。
- 首版生产参数取保守交集：满小雨火焰高度与位移幅度为 `0.88`，点光为 `0.92`，火焰发光为 `0.94`，余烬发光为 `0.96`，炉火烟可见量为 `0.80` 且横向漂移为 `1.10`；三栋房屋烟不受影响。
- 隐藏 Compatibility 捕获的夜间晴/雨同相位对照中，炉火仍是唯一明确强暖色焦点，地面暖光范围和色相没有改变；雨天火焰略矮、烟更淡，差异克制但可读，没有出现熄火或窗光抢焦。
- 首轮昼间对照的第一张仍显示开场地点标题，虽然不影响炉火结论，但不满足严格同条件 A/B；正式捕获脚本显式隐藏 `Opening` CanvasLayer 后重录，不沿用该首轮图。
- 重录后昼间晴/雨两图不再含开场 UI；同相位可见雨天火焰略矮、炉火烟更轻，但仍清楚读为持续燃烧。夜间晴/雨对照保持炉火暖色地面受光，夜雨 A/B 的三片火焰轮廓不同，证明异步动态没有被倍率压成静态。
- Phase 57 后的晴天 21 机位扫查为 `21/21` 唯一哈希；炉火近景和村庄远景未见额外布局、草甸、道路、建筑遮挡或焦点层级回归。
- Phase 57 三类终审全部 `PASS 0/0/0`：美术确认昼雨可读且夜雨暖色主焦点稳定；生活气息确认炉火响应与尼娅避雨构成一致因果；动效确认同相位晴雨差异、夜雨 A/B 异步火焰、天气连续过渡和房屋烟不受影响。

# 2026-09-02 Phase 58 候选复审

- 基于提交 `02f5fc7` 的最新 21 机位重新审阅，而不是沿用 Phase 55 的旧优先级结论。
- `temp/grass-sweep/14-herb-yard.png` 的近距离屋顶避让中间态出现大面积透明瓦片叠线、三角面和深浅条带；玩家与室内仍可读，但材质观感明显偏离哑光绘本风格。
- 该缺口只涉及现有屋顶淡出链，可能比新增生活道具、减少草量或扩展天气系统更适合作为单一小范围 Phase 58；仍需三类代理独立确认优先级与最小边界。
- 三类提名结果：美术将屋顶叠层定为 `P1`；动效将雾池水波跨循环跳亮定为另一个 `P1`；生活气息把三户室内同模定为 `P2`。
- Phase 58 先处理屋顶：它在 `13-hearth-close` 与 `14-herb-yard` 多机位直接遮挡角色和活动区，违反规范的俯视可读性要求，而且只需收敛现有 `target_alpha = 0.22` 的端态。雾池水波作为下一阶段独立候选保留。
- 现有淡出链已逐材质保存原始 Alpha，并以 `delta * 5.0` 平滑插值；不需要新 Shader、遮罩、材质系统或节点结构。近距离端态改为 `0.0` 即可消除稳定状态的多层 Alpha 鬼影，进入/离开过渡继续沿用现有插值。
- 三栋房屋中心为 `(-9,-10)`、`(9,-8)`、`(-10,5)`；现有淡出列表只包含屋顶及其烟囱表面材质，墙壳、室内地面、家具、门窗与碰撞均不受端态调整影响。
- 首轮四张 Compatibility 实图为 `4/4` 唯一哈希：三栋屋顶稳定端态完全退场，透明网格鬼影消失，村庄远景三屋顶均完整恢复；炉火、墙壳、室内、门窗与家具没有随屋顶消失。
- 首轮药圃屋和西屋证据站位位于侧墙后，玩家被实体墙遮挡，无法隔离证明屋顶可读性；正式证据把玩家移到两栋正门前真实可达位置后重录，不修改生产场景。
- 第二轮正门站位正确，但沿用旧反向 yaw 后相机从房屋背侧观察，玩家仍落在背墙之后；最终只把两张证据 yaw 归零，从正门外朝屋内观察，不再改变站位或生产参数。
- `docs/art-direction.md` 已升级为 0.4：最新版规范高于历史阶段参数；植被疏密不得被误解为任意减少总草量；多层屋顶近屋端态必须完全隐藏，墙壳、室内、门窗和碰撞保留。
- 最终四张固定证据为 `4/4` 唯一哈希；三栋切顶图未见瓦片、梁架、三角面或烟囱叠层鬼影，远景图三栋屋顶完整恢复。
- 动效 P2 已用真实 `1/60s` 连续帧测试清零：覆盖进入中间态、途中离开反向恢复、120 帧淡出及 120 帧恢复。
- 三类终审：生活气息与动效 `PASS 0/0/0`；美术 `PASS 0/0/1`。唯一 P2 是 6 米中心距离触发不等于真实镜头遮挡，需另做遮挡判定，不阻断本阶段端态修复。

# 2026-09-02 Phase 59 雾池水波连续性

- 根因是旧透明度 `0.35 + phase * 0.63` 在 `fmod` 回绕前接近完全透明、回绕后立即恢复到 65% 可见，缩放重置因此表现为亮环跳现。
- 最小修复保留原缩放、位置、网格和半周期错相，只把可见度改为 `sin(PI * phase)` 包络；相位 0/1 均完全透明，中段透明度约 `0.38`。
- 冒烟契约固定 `portal_time=4.95/5.05`，验证边界两侧透明度均大于 `0.97` 且差异小于 `0.001`；中点保持 `0.35-0.45`，覆盖连续性和有效可见范围。
- 三张专项图与 21 机位均使用固定时刻、固定晴天和固定镜头；专项 `3/3`、全景 `21/21` 唯一哈希。回绕前后没有跳亮，另一个错相波纹在边界期间维持水面呼吸感。
- 三类终审均 `PASS`，P0/P1 清零；生活气息与动效 `0/0/0`，美术 `0/0/1`。唯一 P2 是峰值环仍略有多边形交互标记感，后续可单独评估更细、更圆的网格。

# 2026-09-02 Phase 60 屋顶遮挡语义

- 最新三类提名中，美术与生活气息均把三户室内同模列为最高 P2；动效以门前和炉火旁截图证明当前 6 米径向触发会在房屋不遮挡玩家时仍切顶，并按 0.4 规范判为 P1。
- 该 P1 是更基础的建筑轮廓问题：修正后无意义切顶减少，室内暴露频率也会降低，因此先于室内职业差异处理。
- 最小实现不使用射线、状态机或新节点；保留 6 米初筛，只要求房屋中心投影落在相机到玩家的 XZ 线段内，且距线段小于约 3.2 米屋顶半宽。
- 首轮 `7/7` 专项图确认：炉火旁、药师屋正门和织工屋正门均保留完整屋顶；相机旋到房屋背侧后同一近距站位才切顶，远景三栋屋顶完整恢复。
- 真实反向遮挡帧中实体墙仍会挡住玩家下半身；这是 0.4 规范“保留墙壳与碰撞”的直接结果。本阶段只修屋顶无意义消失，不扩大为墙体透明或角色透视系统，最终是否通过交由三类终审。
- 最新 21 机位中 `13-hearth-close` 恢复完整屋顶但炉火与玩家仍完全可读；`14-herb-yard` 的斜向镜头确实由房屋横跨相机到玩家，因而继续切顶且无透明鬼影；`15-west-house` 的近景前景屋顶保持完整，未再按距离误切。
- `12-village-far` 三栋屋顶与烟囱完整，说明新增判断没有破坏远景村庄轮廓。当前剩余边界仍是实体侧墙造成的局部角色遮挡，而不是屋顶触发错误。
- 用户确认旧“近距离即可切顶”的表述本身不合理；`docs/art-direction.md` 已升级为 0.5，将唯一触发语义收紧为建筑实际进入相机到玩家或室内活动主体的视线遮挡带，门前、炉火旁和房屋侧面仅因距离接近不得切顶。
- 三类终审均 `PASS`：美术与动效 `P0/P1/P2=0/0/0`，生活气息 `0/0/1`。唯一 P2 是特殊反向机位下实体墙遮住玩家下半身，但墙壳和空间边界可信，不阻断 Phase 60。

# 2026-09-02 Phase 61 候选复审

- 当前权威状态为提交 `ff065a6` 与 `docs/art-direction.md` 0.5；工作树干净，后台试玩 PID `50400` 正常运行。
- 最新 `13-hearth-close` 与 `14-herb-yard` 实图表明屋顶触发语义已稳定，但切顶后的药师屋仍主要由通用地毯、长凳和木箱组成，与其他房屋共享同一室内语言，职业归属较弱。
- 暂不预设实现；已要求美术、生活气息和动效三类代理分别只提名一个最高收益缺口，再决定 Phase 61 的单一范围。
- 三栋房屋均由同一 `_add_house()` 依次创建，当前每栋固定生成同位置、同材质的 `InteriorRug`、`InteriorBench*` 和 `InteriorCrate`；同模不是截图偶然，而是生产构造的直接结果。
- 已导入的 Quaternius 村庄包只有通用木箱、藤蔓、烟囱、栅栏和马车，没有药瓶、织机或锻造台等室内职业模型。若选择室内差异化，应复用现有材质、箱体和少量原生低多边形几何按 `house_count` 添加职业线索，不新增素材包或抽象框架。
- 三类提名后，美术与生活气息均将三户室内同模定为下一处 P2；动效审核在最新 `04-pond-fork` 峰值帧中确认主环周向分段不足造成的直边和拐角仍像调试范围圈，定为 P1。
- Phase 61 按严重度先处理波纹几何，只提升共享 `TorusMesh` 主环周向分段到 `32`；不修改 Phase 59 已验证的连续正弦包络、错相、半径、材质或运动。三户室内职业差异保留为下一阶段。
- 首轮沿用 Phase 59 的 `mid-cycle` 中景 A/B 时，波纹体量过小且被红叶树遮挡，新旧画面肉眼差异不足；唯一哈希只能证明渲染发生变化，不能证明轮廓达标。Phase 61 必须补真正的峰值近景和岔口机位，不沿用弱证据下结论。
- 强化后的首轮专项近景看似改善，但随后 21 机位 `04-pond-fork` 在更大波纹相位下仍清楚呈十二边形，证明该证据没有覆盖最差相位，不能通过。
- 根因是首轮把 TorusMesh 参数语义判断反了：`ring_segments` 细分管截面，主环周向轮廓由 `rings` 控制。正确最小修正应将 `rings` 从 `12` 提升到 `32`，并把无关的 `ring_segments` 保持原值 `16`。
- 第二轮 `fork-large` 与 `detail-large` 覆盖 `portal_time = 4.0` 的大尺寸相位；正常 12 米和细节 7 米镜头中主环均为连续椭圆，不再出现十二边形折角，32 个 `rings` 已足够。
- 另一枚错相波纹仍以更低透明度保留，玩家、雾灯菇和道路继续高于水波的视觉权重；无需改变材质或透明曲线。
- 第二轮 21 机位 `21/21` 唯一哈希；原失败帧 `04-pond-fork` 的大环已变为平滑椭圆，`05-pond-close` 保持克制，没有新亮边、闪烁或焦点抢占。
- 三类终审全部 `PASS 0/0/0`：主环圆度、周期连续性、焦点层级、共享网格和局部几何成本均通过。首轮错误的截面增量没有保留在最终实现中。
- Phase 61 完成后，三户室内同模仍是美术与生活气息共同提名的下一处 P2，作为后续单独阶段处理。

# 2026-09-02 Phase 62 三户室内职业归属

- Phase 60 三张切顶图确认当前室内中央大面积空置，通用地毯、长凳和木箱常落在画面边缘或被近侧墙截断；只换颜色不足以建立身份，必须让每户有一个清楚的活动大形。
- 房屋顺序与屋外归属为：`VillageHouse1` 药师屋（邻近药圃）、`VillageHouse2` 炉火住户（邻近公共炉火）、`VillageHouse3` 织工屋（邻近晾织架和尼娅）。
- 活动中心应放在中央或后侧、避开前门直通带；不增加碰撞或交互，保持室内仍是绘本舞台式可读背景。
- 现有 `_add_box()` 已能创建无碰撞 CSGBox3D 并挂到房屋节点；三类职业大形可以完全复用该 helper 和现有哑光材质语言，不需要新增几何工厂、资源或依赖。
- 为避免中央空盒与边缘家具不可见，职业大形放在室内中后段，但前门局部 X 约 `-0.5` 到中央的直通带继续留空；新增几何统一 `use_collision = false`。
- 首轮 7 张切顶 A/B 暴露活动中心位置仍不符合真实遮挡机位：药师工作台完全落在近侧墙后，炉火低桌只露出下缘。代码存在与无碰撞不足以验收，职业大形必须移到实际切顶可见的前半区侧边。
- 新位置仍避开门口 X 约 `-0.5` 的直通带；按实际镜头可见性调整局部 Z，不改变屋顶触发或为了截图手动隐藏墙壳。
- 第二轮 `herb-cutaway` 已完整显示灰绿工作垫、低工作台和三束干燥物；`hearth-cutaway` 显示暖赭地垫、低桌与坐凳。两者门道仍保持空白，且大形、色相和家具方向已明显不同。
- 药草束使用三个小型哑光色块保持低多边形概括，没有增加高频叶片或高饱和点色；是否足够读成职业线索交由三类实图终审，不提前扩充道具。
- 第二轮 `west-cutaway` 中立式织架与三块旧布色完整可见，并与屋外晾织架形成方向呼应；其竖向框架大形明显区别于药师横桌和炉火低桌。
- 三张切顶图均保持一个活动中心和大片空地，没有出现卡片式道具堆积、纯白高光或高饱和抢焦；进入全图扫查验证完整屋顶状态。
- 21 机位 `21/21` 唯一哈希；`14-herb-yard` 的真实斜向遮挡视角也能完整读出药师工作台，证明身份不是只在专项相机成立。
- `13-hearth-close` 的完整屋顶与炉火焦点保持，但既有开放山墙仍会透见少量室内色块；是否因新布局而泄露过多作为终审重点，不在缺少三方证据时扩改建筑壳体。
- 三类终审全部 `PASS 0/0/0`：横桌、低桌、竖架形成清楚的大形差异，配色与材质仍属于同一村落；门道、通行、室外焦点和完整屋顶轮廓均未回归。
- 完整屋顶状态下看到的少量室内剪影来自既有开放山墙，不是新增几何穿模；无需为此扩大到建筑壳体重做。

# 2026-09-02 Phase 63 屋顶移动稳定性

- 当前屋顶 Alpha 每帧按单一硬阈值重新决定目标：玩家中心距 `<6.0m`、投影视线横距 `<3.2m`；没有保存按房屋共享的遮挡状态，也没有进入/退出迟滞，边界移动会让目标 Alpha 在 `0/1` 间反复翻转。
- 当前镜头提前量对任意平面速度平方大于 `0.01` 的输入直接 `.normalized() * 1.6`；贴墙或停步附近的微小 `get_real_velocity()` 会被放大为满额偏移，进一步摆动相机到玩家的遮挡检测线。
- 透明排序只会放大半透明过渡中的局部瓦片跳面，不是整片屋顶反复显隐的首要原因；应先稳定逻辑，再判断是否仍需改变 Compatibility 透明模式。
- 最小边界为每栋房屋一个布尔遮挡状态、逐材质到房屋的索引映射，以及速度比例镜头提前量；无需 Shader、射线、状态节点或新框架。
- 首轮真实 Compatibility 录像为 `1280x720`、`60fps`、571 帧，脚本报告整段只有两次状态切换；抽取的完整、切顶、恢复三帧均非黑帧，联系表中未见迟滞带内整片屋顶反复闪现。
- 唯一证据问题是初始化等待把约一秒出生点画面录入片头；生产逻辑无需调整，只将捕获站位和隐藏开场提前到等待之前后重录。
- 去掉片头后的正式联系表暴露了剩余 P1：在遮挡状态仍为 `false`、Alpha 仍为 `1.0` 的阈值外移动段，镜头提前量一改变，完整屋顶会从橙色瓦面跳成深色叠层。这个时间点早于唯一一次进入切顶，证明 Compatibility 对始终处于 `TRANSPARENCY_ALPHA` 的重叠瓦片/梁架发生排序跳面。
- 最小渲染修正只将屋顶和挂在屋顶下的烟囱材质改为 `TRANSPARENCY_ALPHA_HASH`；窗玻璃仍使用普通 Alpha，现有连续 Alpha 值、完全隐藏端态和逐帧迟滞状态全部不变。
- Alpha Hash 实机候选失败：511 帧联系表中完整瓦面排序保持稳定，但进入切顶后的整段屋顶仍完全可见；在本项目 Compatibility 路径下不能沿用现有 `albedo_color.a` 淡出语义，因此不保留该方案。
- 下一候选改为 `TRANSPARENCY_ALPHA_DEPTH_PRE_PASS`：继续使用连续 Alpha，同时通过深度预通过稳定重叠瓦片；若实机仍失败，将停止继续切换枚举并采用完整端态回到不透明材质的显式模式切换。
- Depth Pre-Pass 实机候选能稳定初始完整瓦面并正常完全切顶，但恢复末段因 Alpha 插值渐近 `1.0` 而长期显示深色叠层；直接切回不透明会在末端制造一次明显跳面，因此该候选也不保留。
- 结构化解析 `Roof_RoundTiles_6x8.gltf` 后确认只有一个 `Cube.015` 网格，两个重叠 primitive 依次使用 `MI_WoodTrim` 与 `MI_RoundTiles`。普通 Alpha 的根因是两个表面同优先级随镜头排序互换；更精确的修复是保持 Alpha 淡出，只将外层瓦片 `render_priority` 固定为 `1`，木梁维持 `0`。
- 固定绘制顺序候选通过同一条 511 帧、60fps Compatibility 路径：阈值外移动的全部采样帧均保持橙色外层瓦面，进入后完全切顶，迟滞带内不回闪，退出后恢复为同一瓦面；脚本仍只记录进入/退出两次状态切换。
- 该结果同时清除了两类根因：按房屋迟滞阻止目标 Alpha 翻转，瓦片固定优先级阻止同网格两个透明表面随镜头互换；无需改变窗玻璃、Alpha 插值速度或屋顶最终材质语言。
- 改后七机位屋顶 A/B 为 `7/7` 唯一哈希，三栋完整屋顶均保持同一橙色外层瓦面，三处切顶均完全隐藏；窗玻璃、墙壳、室内和烟囱归属未回归。
- 21 机位为 `21/21` 唯一哈希；`12-village-far` 三屋轮廓稳定，`13-hearth-close` 炉火焦点不受影响，`14-herb-yard` 正常切顶并保持药师工作台可读，`15-west-house` 的近景前景瓦面没有再跳成深色叠层。
- 三类终审首轮全部 `PASS 0/0/0`。动效逐帧差分同时指出旧证据脚本在两个分段点存在人工位置不连续；这不是屋顶状态回闪，但会制造无关镜头差分峰值，因此最终证据路径改为缓入缓出和首尾零速度的正弦平方往返，生产代码不变。
- 最终平滑 AVI 仍为 `1280x720`、60fps、511 帧，状态只切换两次；同一屋顶区域相邻帧平均差分从 `4.3999` 降至 `3.2039`、最大值从 `18.9695` 降至 `6.9268`，旧 4.0s/4.7s 人工峰值分别收敛约 78%/77%。
- 美术、生活气息与动效最终均为 `PASS 0/0/0`；屋顶材质、建筑轮廓、三户职业归属、室外生活节点、门口通行和镜头连续性全部通过 0.6 规范。

# 2026-09-02 Phase 64 村庄核心道路尺度

- 当前板车车辕已经沿 `VillageWagonLane` 朝向主路，卸货箱也位于车尾；旧方向问题没有复现，不应再次旋转板车。
- 美术复审在 `08-village-north`、`12-village-far` 和 `16-north-road` 中确认住宅核心段主路仍是贯穿画面的大块浅色带，平滑 T 形接头把三户生活区切成左右两排，判定为当前静态画面的 P1。
- 生活气息复审只保留板车停靠面 P2：支路主要落在车辕和车体中心，车轮、车斗后段和两只卸货箱仍视觉上落在草地。
- Phase 64 只调整既有控制点、半宽和板车磨损面，不改道路生成器、纹理、车辙、草量、房屋、NPC、传送门或山口；托伦多锚点巡守作为下一独立动效阶段。
- 改前/改后并排图确认住宅核心段从连续等宽浅色带变为渐进收窄并轻微摆动的村路；西屋、炉火和板车支路从新路缘散开，交叠处没有硬缝、草地断口或矩形 T 接头。
- 板车近景 97 帧、`1280x720` Compatibility 录像确认车辕仍朝主路，停靠土色从车辕连续覆盖车轮、车尾和卸货箱，同时保留软边、残留草地和绕行空间。
- 三类终审全部 `PASS 0/0/0`；透明肩部、磨损面与道路保持明确高度差，未新增 z-fighting，草地排除、炉火、雨幕和 NPC 路线均未回归。

# 2026-09-02 Phase 65 托伦村口巡守

- 旧托伦逻辑只在单轴约 `1.3m` 范围内往返，端点固定停顿后原路折返，与守门人的职责空间缺少联系。
- 新路线使用三个非共线锚点，停留时分别观察横向道路、北路和村内；速度 `0.52m/s`，停留 `4.8/6.1/3.7s`。
- 实现复用现有村民数组、Walk/Idle 和交谈优先级，不引入导航或日程框架；交谈结束后继续当前巡守段。
- 树木动效复核确认大树尚未加入风摆；Phase 66 将只动树冠、保持树干稳定，并在少数阔叶树下加固定种子的稀疏落叶。落叶必须通过非现实叶形、灰紫/旧金色与轻微冷青反光维持异世界语义，不做普通秋景。
- 实机 Compatibility 完整循环为 `1280x720`、30fps、1107 帧、36.9 秒，脚本再次输出 `TOREN WATCH TEST PASSED transitions=3`。
- 三处停留帧确认托伦分别位于北路口、村内侧与横向路肩，路线不穿房、不切路缘、不和玩家重叠；角色面向与三个职责目标一致。
- 首份联系表选了第 0 帧，因场景初始化而出现黑格；录像本身正常，最终联系表将从 1 秒后取样。
- 最终联系表已改从第 1 秒取样，九格全部为有效场景帧；行走段连续，三次停留之间没有位置跳变。
- 改后 21 机位为 `IMAGE_COUNT=21`、`UNIQUE_HASHES=21`；村庄远景、北路、炉火近景和房屋机位确认托伦未穿模、未阻塞主路、未抢炉火焦点，道路与屋顶无回归。
- 美术、生活气息与动效终审全部 `PASS 0/0/0`；三锚点已建立外路、侧翼、村内的职责关系，循环无瞬移、脚滑、硬折返、堵路或侵入其他 NPC 生活空间。
- 托伦已在 `_physics_process()` 中由专用分支完全接管；通用单轴巡游内的旧 `index == 1` 范围、停留和速度条件不可达，提交前已删除这组死分支。

# 2026-09-02 Phase 66 树冠风摆与异界落叶

- Phase 65 已提交推送为 `a5400bd`，本地 `HEAD`、`origin/main` 与 `git ls-remote` 一致；工作区干净后开始 Phase 66。
- 最新试玩已以 PID `55288` 隐藏后台运行，不抢焦点。
- `CommonTree_1`、`CommonTree_3`、`TwistedTree_1` 与 `Pine_2` 均是单个网格、树皮/叶片两个独立 surface；叶片材质名统一以 `Leaves_` 开头。
- 叶片 surface 局部最低高约 `1.1-2.6m`，树皮从地面延伸到树冠；只覆写叶片 surface 可以从结构上保证树干不动。
- 叶片使用现有 `Leaves_NormalTree_C.png`、`Leaves_TwistedTree_C.png` 和 `Leaf_Pine_C.png` 的 Alpha Mask；不需要外部生成新贴图，避免风格与透明边缘漂移。
- 村庄内八棵树通过 `_add_nature()` 创建，边界八棵树直接调用 `_add_model()`；两处应共享一个叶片覆写助手，不能只修村内或把整棵树加入 CPU `wind_nodes`。
- 现有 `meadow_grass.gdshader` 已验证世界坐标错相、双波形和镜头距离衰减；树冠 Shader 可沿用这三个语义，但幅度必须低于草甸且不缩放/剪除远处树。
- 落叶最小资产合同为少量小型菱形 `ArrayMesh`；现有蝴蝶/萤火虫已使用固定种子的 CPU 网格动画，落叶复用同一模式比新增 GPU 粒子更可复现、更易于专项捕获。
- 天气 profile 已通过 `_blend_weather_profiles()` 对数值字段做连续插值；只需增加一个 `wind` 字段即可连续驱动树冠和落叶，不创建第二套天气状态。
- 首轮 7.03 秒 Compatibility 连续录像确认树冠轻摆、树干稳定，但原 `0.20x0.095m` 平面叶片在最低玩法镜头仍几乎不可读；应保持稀疏数量，改叶片轮廓与非共面形态，而不是堆数量制造落叶雨。
- 第二轮动态采样发现第一树簇三片叶的位置和透明度都有效，但原方形随机出生点距树心不超过约 `1.35m`，始终处在树冠投影下；落叶必须从 `1.8-3.0m` 冠缘环带被风带出，才能在俯视相机中出现。
- 冠缘环带第三版在连续联系表与原尺寸定点帧中可读：每帧仅约 1-2 片灰紫、旧金或冷青叶片出现在冠缘/低空，树干稳定且没有落叶雨、普通秋园感或高饱和魔法喷泉感。
- 最终 21 机位为 `IMAGE_COUNT=21`、`UNIQUE_HASHES=21`；抽查村庄、炉火、药圃和四角树群，落叶未侵入主路或活动区，未遮挡 NPC，树冠未造成屋顶与道路回归。
- 美术、生活气息与动效三类终审全部 `PASS 0/0/0`；共同确认异界语义、村庄生活空间、树干稳定、天气连续插值与落叶透明回绕均成立。

# 2026-09-02 Phase 67 当前场景缺口提名

- 最新 21 机位复核中，传送门、雾池、主路、炉火和村庄总览没有出现新的 P1；现阶段不应以新增魔法装饰替代具体可读性修复。
- 美术提名 P1：西北 `CommonTree_1 (-17,-17)` 位于可绕行空间内，玩家走到其镜头远侧时身体、斗篷与头部会被树干和低树冠吞没，直接违反角色轮廓规范。最小边界是将该树和对应落叶簇一同内收到西北岩壁边界，不建立全场树木透明系统。
- 生活气息提名 P2：米拉仍沿约 2.4m 单轴短摆，尚未把门前、药圃和晾药架串成职责路线；该项应在更高等级角色遮挡修复后作为独立阶段，不能与树位改动混合。
- 动效提名 P1：随机雨天已有雨幕、避雨、火烟与树冠联动，但地面、道路和雾池仍保持晴天状态；该项证据明确，若树遮挡在合法站位无法复现则应成为 Phase 67 实施项。
- 原西北树证据的玩家被脚本直接设在树心；玩家胶囊半径 `0.38m`，树干碰撞半径约 `0.47m`，正常玩法不能占据该位置。必须在两碰撞体外侧的环形站位复拍，不能把测试夹具穿模误判为生产 P1。
- 西北边界内缘为 `x=-24.5`、`z=-24.5`；附近边界树位于 `(-22,-17)` 与 `(-15,-22)`。若合法站位确有遮挡，任何移动方案都必须先证明不会把问题转移到相机旋转后的另一侧。
- `CommonTree_1` 叶片 AABB 局部横向半径约 `2.22m`，当前 `1.05` 缩放后约 `2.33m`；碰撞外仍可能产生明显视觉遮挡。专项使用距树心 `1.05m` 的四方向合法站位，严格大于玩家 `0.38m` 与树干约 `0.47m` 的碰撞半径之和。
- `tree_occlusion_capture.gd` 的北、东、南、西四个合法站位均在 Compatibility 实图中复现整名玩家被树干/低树冠完全遮住，确认这是实际可达空间的 P1，不是旧捕获穿进树心造成的假象。
- 动效复核建议整体外移而非运行时透明：现有树冠使用 alpha scissor，若引入多层叶片连续透明会重新带来 Compatibility 排序闪烁、鬼影以及树冠/树干/阴影/落叶显隐不同步；外移可保留异界树的实体感和风摆轮廓。
- 改后首轮专项把玩家放在北墙内缘 `(-21,-23.6)`，四个旋转方向都被边界岩石占满，无法判断角色可读性；该批图作废。最终专项必须回到旧树心所在的真实可玩草地 `(-17,-17)`，直接证明原问题点在四向镜头下恢复。
- 回到旧问题点后的四向 Compatibility 实图中，`yaw-000/090/180` 玩家完整可读，但 `yaw-270` 被西侧边界 `Pine_2 (-22,-17)` 完全遮住。单移阔叶树未解决同一西北角在镜头旋转后的遮挡根因，Phase 67 必须把该松树一并收进不可达林缘后再验。
- 美术复核将松树首选位定为 `(-24.8,-12.5)`：树根进入 `WestCliff`，并与旧问题点的东西向视线错开约 `4.5m`；它嵌入现有西侧岩石 `(-24.2,-12)`，仍保留药师屋西北林缘，同时与北侧新阔叶树相距约 `12.8m`，不会合成连续实心树墙。
- 最终旧问题点 `(-17,-17)` 的 `yaw-000/090/180/270` 四张 Compatibility 实图全部显示主角头部、披风、手脚轮廓完整；松树和阔叶树只形成边缘框景，药圃、房屋与浅绿草甸保持可读，异界稀疏落叶仍有明确树冠来源。
- 最终 21 机位为 `IMAGE_COUNT=21`、`UNIQUE_HASHES=21`；重点复核 `19-corner-nw` 及四角，西北场景没有空洞、连续深绿墙或新的角色遮挡。美术、生活气息与动效三类终审均为 `PASS`。

## 2026-09-03 基础重构回归修复

- 已确认并修复：`GameState.start_new_game()` 发出状态替换后，`GameRoot` 只注册序章而不启动，导致 `arrival` 从 `active` 变为 `not_started`。
- 已确认并修复：存档 JSON 字段为 `null` 或错误容器类型时，`WorldState` 的强制 cast 抛出运行时错误，无法可靠触发备份回退。
- 已确认并修复：`DialogueRunner` 发出 `line_started` 但当前场景未订阅，玩家看到的仍是重复硬编码文本；现在资源文本优先、无运行时控制器时才使用兜底。
- 残余：Godot 启动和冒烟仍打印既有 glTF 外部资源 UID 警告及 Dummy 渲染器退出清理告警；不影响退出码或测试结果，本轮未改资源导入元数据。

## 2026-09-03 Phase 69 米拉职责空间验证

- 米拉原路线只在房门附近做约 `2.4m` 单轴短摆，无法把角色职责与药圃、晾药架建立空间联系；固定四点路线可在不引入导航的前提下补齐门前、入口、采集和晾晒四个语义节点。
- 路线点分别为 `(-12,-7)`、`(-13.2,-7.7)`、`(-14.8,-9.2)`、`(-15.6,-12)`；第三点靠近扩大后的药圃，第四点距 `HerbDryingRack` 小于 `1m`，停留朝向分别面向入口、药圃和晾药架。
- `5.2 x 3.2m` 药圃在 `14-herb-yard` 与 `12-village-far` 机位下保持主路连续；药圃周边草甸排除带扩大后仍保留土肩、草簇和绕行空间，没有形成硬边广场。
- Compatibility 扫查 21 张图全部唯一；药圃、炉火、村庄总览和西屋机位未见新遮挡。米拉专项报告 `PickUp`、`Gather drift: 0.0`、朝向误差约 `0.016rad`，退出码为 0。
- 旧首帧动画断言与新路线初始停留语义冲突，已改为精确区分米拉/托伦 `Idle` 与妮娅 `Walk`；其余原有巡游、交谈和动画断言保留。

## 2026-09-03 Phase 70 天气地表反馈验证

- 原天气系统只改变太阳、环境雾、雨丝、炉火烟和树冠风力；地面与道路材质在晴天和小雨下保持同一颜色/粗糙度，雾池只有与天气无关的常态涟漪，雨天叙事不完整。
- 新增 `surface_wetness` 作为 profile 数值并走已有 `blend_weather_profiles()`，避免另建天气开关；湿润度顺序固定为 `clear < cloudy < mist < light_rain`，所有捕获仍固定 `time_hour=9.5` 或 `22.0`。
- 小雨草地从鼠尾草绿向更冷、更暗的中间调收敛，道路从土黄向湿土色收敛；颜色变化小于炉火暖光权重，没有把场景压成灰膜。
- 雾池水面粗糙度由 `0.25` 连续到 `0.4`，涟漪强度由 `0.62` 连续到 `0.9`；仍只保留两道共享涟漪，避免粒子喷泉感。
- 实机 Compatibility 对比显示白天小雨能读出雨丝、湿地与路面差异，药圃机位保持药圃/米拉身份可读；夜雨地面可读且炉火仍为唯一高饱和暖色焦点。
- 小雨 21 机位扫查固定 `time_hour=9.5`，输出 `RAIN_IMAGE_COUNT=21`、`RAIN_UNIQUE_HASHES=21`；村庄总览、药圃、炉火、传送门和四角机位均无新遮挡或过度变暗。
- 已知残余仍为 glTF 外部资源 UID 警告及退出时渲染资源泄漏告警；不影响退出码，本阶段未修改导入元数据。

## 2026-09-03 Phase 71 候选缺口

- 生活气息审核发现 `HerbDryingRack` 在小雨中完全露天，雨线穿过药草束，与“采集后晾晒”的职责表达冲突；最小修正是复用现有木材材质增加窄檐，不引入新资产或天气框架。
- 美术审核发现 `phase70-weather-night-rain.png` 中房屋墙体、板车、北侧 NPC 和支路接头接近深蓝剪影，影响探索节点可读性；修正边界仅限夜雨环境底光/雾色对比，不增加新的高亮光源。

## 2026-09-03 Phase 71 验证

- 夜雨只增加冷色环境底光约 `0.08`、轻微回提环境色并降低雾密度约 `8%`，最终截图中职责节点恢复轮廓，炉火焦点未被稀释。
- `RainAwning` 使用现有木材材质与 `1.9 x 0.72m` 窄檐；`_animate_weather()` 对檐下局部雨线设置完全遮蔽，避免视觉与职责冲突。
- 21 机位小雨扫查最终为 `RAIN_IMAGE_COUNT=21`、`RAIN_UNIQUE_HASHES=21`；三类终审 `PASS`。残余仍为既有 glTF UID 与 Compatibility/Dummy 退出资源告警。

## 2026-09-03 序章下一阶段视觉审计

- 最新白天出生点截图中，中央主路与浅绿草地的明度和饱和度接近，远景层级偏平；这只是候选问题，需三类代理确认后再决定是否调整。
- 房屋切顶截图中室内已有职业家具，但大面积空地仍较安静；是否值得加入叙事性小物，需与道路/地表层级候选竞争，不能同时扩张。

## 2026-09-03 Phase 72 决策

- 美术审核将“离开传送门后村庄缺少异世界记忆点”定为 P1：`08-village-north`、`12-village-far`、`13-hearth-close` 主要只读到草地、土路、陶瓦房屋和炉火，传送门的冷青叙事没有回声。
- 生活气息审核的最高项为 P2 米拉雨天继续穿行露天药圃；动效审核的最高项为 P2 草甸风强未接入天气。两项暂不与本阶段混改。
- 采用最小 P1 边界：板车支路草肩旁一个小石基和三段断裂冷青痕，使用低强度材质脉动表达“传送门余痕”，不增加第二个传送门或全屏特效。
- 首版远景被板车投影压缩成小亮点，已沿同一支路移到主路侧草肩 `(-3.35,-1.22)`；尺寸、材质、碰撞和动画保持不变。

## 2026-09-03 Phase 72 验证

- `OtherworldTrace` 在主路西侧草肩以小石基和三段断裂冷青痕形成异世界回声；晴天可发现，远景退为环境线索，未改变道路通行判断。
- 夜雨中痕迹保持低亮度和小幅脉动，炉火橙光与传送门冷青光的视觉权重都明显更高；未出现第二主焦点、闪烁或粒子泛滥。
- `phase72-village-core-clear.png`、`phase72-herb-yard-rain.png`、`phase72-village-core-night-rain.png` 与小雨 21 机位复核均无道路、房屋、药圃、NPC 或天气回归。
- 三类终审均为 `PASS 0/0/0`。下一阶段候选仍为 P2：米拉雨天避雨，以及草甸风强接入天气。

## 2026-09-03 Phase 73 验证

- `VillageHouse1/MiraRainShelter` 复用药草师住宅门面，非碰撞木檐和两根支柱与房屋梁架、板车箱体材质统一，未形成悬浮或穿墙。
- 米拉小雨行为采用两段路线：先离开房屋碰撞边，再进入门外檐下；10 秒真实运行后到达目标，`Idle` 且无卡墙或瞬移。
- `_animate_weather()` 只对檐下局部坐标内雨线设置遮蔽；药圃、道路、炉火、NPC 和房屋其余区域没有天气层级回归。
- 固定小雨 21 机位与 `phase73-mira-rain-shelter.png` 复核通过；美术、生活气息和动效终审均 `PASS 0/0/0`。
- 下一候选保留为 P2：草甸 Shader 接入 `weather_wind_amount`，解决树冠/落叶增强而草甸摆幅固定的动效层级差异。

## 2026-09-03 Phase 74 决策

- 当前天气 profile 已有稳定风强：晴 `0.62`、阴 `0.86`、薄雾 `0.48`、小雨 `1.12`；树冠和落叶读取该值，草甸 Shader 仍固定 `sway_strength=0.11` 并使用内置 `TIME`。
- 最小修正是给草甸增加 `wind_strength` 与 `motion_time` uniform，在现有 `_animate_tree_canopies()` 统一写入 `weather_wind_amount` 和 `portal_time`；不改变实例数量、排除带、道路或材质色板。

## 2026-09-03 Phase 74 验证

- `shaders/meadow_grass.gdshader` 新增 `wind_strength` 与 `motion_time`；草叶弯曲仍受高度平方和镜头距离衰减约束，实例分布、道路排除带与鼠尾草绿材质不变。
- `scripts/main.gd` 在初始化和 `_animate_tree_canopies()` 同步写入 `weather_wind_amount` 与 `portal_time`，晴/阴/雾/小雨风强连续且固定种子可复现。
- 自动门禁通过：`SMOKE TEST PASSED`、`TREE MOTION TEST PASSED canopies=16 leaves=12`、`git diff --check`。
- 小雨 21 机位扫查输出 `RAIN_IMAGE_COUNT=21`、`RAIN_UNIQUE_HASHES=21`；村庄总览、药圃、炉火和四角机位确认道路、NPC、房屋与职责空间无回归。
- 美术、生活气息、场景动效三类终审均为 `PASS 0/0/0`；未发现草地过密、风摆同步抖动、遮挡或透明排序问题。

## 2026-09-03 Phase 75 验证

- 在 `VillageProps/VillageEntryBoundary` 增加低矮不对称村口框景：左侧短木栏与两根桩，右侧单桩和石基，东侧保留通行缺口；全部非碰撞、无灯光、无新发光材质。
- 入口位置固定在住宅核心北端主路边缘，三处基准点通过 `VillagePath` 边缘净空断言；主路最窄宽度、板车支路、房门和 NPC 路线均未改变。
- 晴天与小雨 Compatibility 扫查均输出 `IMAGE_COUNT=21`、`UNIQUE_HASHES=21`；`08-village-north`、`12-village-far`、`13-hearth-close` 中住宅和炉火自然成为入口后的目的地。
- 三类审核均通过：美术 `P0/P1/P2=0/0/0`，生活气息无阻断问题，场景动效无闪烁/排序/阴影回归。后续保持右侧单桩不向路心内移。

## 2026-09-03 Phase 76 验证

- 直接给倒挂药草模型写风摆会覆盖其 `rotation.z = PI + offset` 姿态；采用 `HerbBundleN` 外层锚点承载风摆、内层 `Mesh` 保留姿态，避免新增全局风摆状态。
- 四个锚点都在 `wind_nodes`，时间推进后锚点产生错相低幅旋转；雨棚局部坐标判定仍命中，雨线遮蔽契约保持通过。
- 代表图和 21 机位扫查未见药草束越出架体、道路遮挡、透明排序或闪烁；未改变药圃和米拉职责动线。
- 既有 Godot glTF UID fallback 与 Compatibility/Dummy 资源泄漏警告仍存在，但不影响退出码和测试结论。

## 2026-09-03 Phase 77 织工公共事务生活流

- Nia 的白天事务窗口为 `10.5-12.25`，固定路线共 9 点，起点 `(-5.5, 6.5)`，经过主路/异世界余痕，终点 `(-7.25, -0.75)`；终点面向卸货目标 `(-7.4, -2.1)`。
- 冒烟契约覆盖路线节点、11:00 状态切换、实际位移与 Walk、终点 Idle/朝向、12:30 回到织工工作点；最终输出 `SMOKE TEST PASSED`。
- 树木动效回归输出 `TREE MOTION TEST PASSED canopies=16 leaves=12`；晴天和小雨 21 机位均为 21 张且 SHA-256 全部唯一。
- 固定生活流捕获 `day-errand.png` 确认 11:00 时 Nia 已离开工作点沿主路事务行走；其余黄昏、夜间炉火和小雨避雨截图保持既有行为。
- 已知 glTF 外部资源 UID fallback 与 Compatibility/Dummy 退出清理告警仍存在，不影响退出码和图像计数。
- 三类专项终审：美术确认 Nia 新机位完整可读且 P0/P1/P2=0/0/0；生活气息确认路线职责成立、主路净空且与 Mira/Toren 不冲突；场景动效确认 Walk/Idle 连续、无瞬移抖动或透明排序回归。

## 2026-09-03 Phase 78 织工事务回程连续性

- 动效审计发现 `12.25` 后旧逻辑在 `_update_nia_routine()` 直接写入 `villager_patrol_origins[2]`，静态作息断言无法覆盖这次瞬移。
- 新逻辑在事务结束后复用 `NIA_PUBLIC_ROUTE` 反向路线，使用 `returning` 状态保持 `Walk`；最终节点才切回 `work` 并保持 `Idle`。
- 冒烟覆盖返回状态、速度/位移连续性和到达复位；捕获脚本固定 `time_hour=12.3`，回程图确认 Nia 位于主路并播放 Walk。

- 最终捕获机位移出交谈范围后，`day-return.png` 保持回程 Walk 且完整显示 Nia；黄昏、夜间炉火和雨天避雨捕获仍通过。
- 三类终审均为 `PASS 0/0/0`：美术确认构图与角色轮廓稳定，生活气息确认回程职责连贯且不阻塞其他 NPC，动效确认状态切换无瞬移/抖动/透明排序回归。

## 2026-09-03 Phase 79 板车卸货动作

- Nia 的卸货终点复用现有 `PickUp` 非循环动画；暂停由动画长度加 `0.15s` 余量驱动，完成标记避免重复重播。
- 冒烟覆盖首次触发、完整停留、收尾 Idle、非重复播放和 12:25 后回程连续性；固定捕获覆盖卸货动作与回程 Walk。
- 东侧卸货机位解决了前景屋顶遮挡，角色躯干、双臂和腿部轮廓均可读；板车、卸货箱和道路净空保持不变。
- 实机晴天/小雨 21 机位均保持唯一画面；三类专项终审均 `PASS 0/0/0`。

## 2026-09-03 Phase 80 候选审计

- 当前美术规范要求用连续的小地标和职责物件建立区域记忆，同时避免无叙事作用的装饰堆积。
- 美术专项复审提名 P2：板车卸货节点目前主要是空木板/车架，Nia 的 `PickUp` 虽可读，但手边缺少明确货物对象。
- 候选最小边界：在车斗卸货区增加 1~2 个低矮、低饱和布包或木箱，复用现有材质，保持低于车帮，不发光、不改车位/道路/NPC 路线；等待生活气息与动效专项确认后实施。

## 2026-09-03 Phase 80 实机验证

- 两个 `Prop_Crate` 作为 `VillageWagon` 子节点使用固定局部坐标和 0.34/0.28 缩放，实机确认落在车斗内部且低于车帮。
- `day-unload` 中货箱与车外卸货箱形成“车内待卸 -> 车外已卸”的连续语义，Nia 的头部、躯干、双臂和腿部仍完整可读。
- 晴天与小雨 `09-village-east` 中货箱退为车斗内部细节，不改变主路、支路、角色、炉火或屋顶的视觉层级；雨天没有新增透明排序或异常阴影。
- 美术、生活气息与场景动效终审均 `PASS 0/0/0`：货箱数量克制、低于车帮、无碰撞，并明确“车内待卸 -> Nia 取放 -> 车外已卸”的生活叙事。

## 2026-09-03 Phase 81 初步画面审计

- 最新村庄近景/远景已经同时包含炉火、板车货物、晾晒线、药圃、村口和三个 NPC 职责点，继续增加静态道具容易违背“少量高质量焦点”和避免装饰堆积的规范。
- 石环和雾池焦点仍清楚；山口不是当前迭代范围，不从该区域扩张新内容。
- 下一候选应优先增强现有职责节点的时间、动作或环境反馈，让生活叙事更连贯，而不是扩大建筑、道路或新增无职责装饰。
- 生活气息审查确认当前最高优先级是 Nia 的常态织工职责：`work` 状态会落入通用约 1.2 米单轴巡游，白天大部分时段没有面向布料或织工作业动作；这比短时板车事务更常见，也直接违反职责节点和有意义朝向规范。
- Phase 81 采用最小职责循环：复用现有晾织架与 `Interact`，只增加院内路线和一次性动作状态；公共事务、回程、晚间、雨天与交谈优先级必须保持连续。
- 美术后续候选为只对雾池西南 `TwistedTree_1` 使用已有 `Leaves_TwistedTree_C_Muted.png`，保留酒红异世界记忆点但降低普通环境树的焦点权重。
- 动效后续候选为让白天蝴蝶 Alpha 乘以 `1.0 - weather_rain_amount`，复用天气平滑过渡，使小雨时自然淡出，不改数量、轨迹或萤火虫。
- 织工住宅使用完整 `6 x 6m` 碰撞，真正门洞不可通行；现有回屋终点 `(-6.5, 6.4)` 本就是住宅东侧代理点。因此工作路线保持在 `x=-6.15..-4.7`、`z=6.35..6.95`，连接该代理区与晾织架北侧，不尝试穿门。
- 晾织架操作点固定在 `(-4.7, 6.35)`，朝向架体中心 `(-4.7, 5.25)`；路线为三点非直线循环，避免重新形成单轴钟摆。
- 旧 `day-work.png` 画面确认织工住宅东侧、晾织架北侧与主路之间仍有完整步行净空；原问题确实是 Nia 只站立/巡游而没有与三块布料发生动作关系，不需要移动房屋或晾织架。
- 冒烟诊断确认手工 `_physics_process()` 中 `move_and_slide()` 的内部步长可产生约 `0.108m` 首步，但方向和速度仍严格匹配公共路线；用小于 `0.15m` 的 XZ 上限可排除旧数米瞬移，同时避免把测试调用参数误当引擎物理步长。
- 新 `day-work` 实机帧中 Nia 完整位于晾织架北侧，身体朝向三块布料并播放 `Interact`；住宅屋顶只作为左侧框景，未遮挡角色、布料或主路，职责关系不再依赖头顶职业标签。
- `day-errand` 与 `day-return` 显示 Nia 分别从院内连续离岗、沿公共路线回程；三点工作区没有侵入右侧主路，也没有与玩家、板车或炉火职责区重叠。
- 晴天 Movie Writer 重录与小雨常规捕获均达到 `21/21` 唯一哈希；织工住宅、主路交叉口和村庄远景抽查没有出现屋顶透明闪烁、道路占用、角色穿模或天气层级回归。
- 小雨 `15-west-house` 中 Nia 仍可在晾织架节点被识别，雨线、草甸和低饱和环境没有遮蔽角色；本阶段不扩张为“白天雨天避雨”行为，保持既定作息边界。
- 动效终审发现交谈会把 `Interact` 切为 `Idle` 并冻结剩余停留，但离开交谈后动画从头重播，旧剩余时间可能短于完整 `1.3s` 动作，造成可见截断；恢复重播时必须将停留补足为完整动作长度加收尾余量。
- 动效复核确认修复只作用于交谈后重新启动的 `Interact`，完整动作、`Idle` 收尾和随后离点均由冒烟契约覆盖；最终 `PASS 0/0/0`。
- Phase 81 三类最终审核均为 `PASS 0/0/0`：织工职责、住宅框景、主路净空、晴雨轮廓和动作连续性全部成立；雾池红树饱和度与雨天蝴蝶响应保留为后续独立候选。
