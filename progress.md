# 开发进度

## 2026-08-31

- 确认工作区为空，无旧项目恢复内容。
- 确认本机已安装 Godot 4.7.1。
- 确认采用 CC0 自然与村庄资源组合。
- 开始阶段 1：建立最小可运行项目。
- 创建 `project.godot`、主场景、地图脚本与玩家控制脚本。
- Godot 4.7.1 编辑器导入检查通过。
- Godot 无窗口运行 3 帧通过，无脚本错误。
- 完成阶段 1，开始下载并整理自然与村庄资源。
- 下载 Stylized Nature MegaKit 标准版（104 MB）。
- 下载 Medieval Village MegaKit 标准版（161 MB）。
- 验证两个 ZIP 可读取，并确认 glTF 资源结构完整。
- 列出可用自然模型和村庄建筑模块，确定选择性导入范围。
- 解析所选 glTF 的 buffer 与贴图依赖，准备精确复制。
- 精确复制 63 个模型/依赖文件并由 Godot 成功导入。
- 接入真实自然与村庄模型，运行检查通过。
- 输出并检查第一张实际游戏画面，记录构图与光照问题。
- 调整光照、地图边界、出生点和异界传送门，第二张画面构图通过。
- 首次冒烟测试发现动态摄像机名称不稳定，已修正节点命名。
- Godot 冒烟测试通过：`SMOKE TEST PASSED`。
- 最终 1280x720 实机画面复核通过。
- 删除两个被真实模型替代的未使用材质变量。
- 四个原型阶段全部完成。
- 开始阶段 5：完善初始场景的淡入、地点标题与传送门动态。
- 使用原生 Tween 加入黑场淡入和地点标题，无新增 UI 框架。
- 加入传送门缩放、自发光和灯光呼吸动画。
- 阶段 5 代码冒烟测试通过，开始实机画面验证。
- 录制并检查 60 帧开场序列，淡入、标题和传送门动态表现正常。
- 扩展冒烟测试以覆盖 Opening、portal_ring 和 portal_light，测试通过。
- 保存阶段基准图 `captures/initial-scene-opening.png`。
- 完成阶段 5。
- 清理旧试玩与遗留无窗口测试进程，启动新的 DEBUG 试玩窗口（PID 4008）。
- 开始阶段 6：重做传送门遗迹、支路和道路边缘。
- 用九块真实岩石替换可见灰盒拱门，并保留两个不可见碰撞体。
- 增加圆形石台、发光地面环、主路支路和六组道路边缘碎石。
- 阶段 6 首轮冒烟测试通过，开始实机画面验证。
- 录制并检查阶段 6 开场帧，石阵、平台、支路和道路碎石构图通过。
- 冒烟测试新增 PortalPath、PortalPlatform、PortalRuin 和旧灰盒缺失断言，测试通过。
- 保存阶段基准图 `captures/initial-scene-phase6.png`。
- 完成阶段 6。
- 关闭旧试玩 PID 4008，启动阶段 6 新试玩窗口（PID 35148）。
- 开始阶段 7：重塑道路轮廓并增加村庄入口层次。
- 用三个 CSGPolygon3D 替换主路、广场和传送门支路的矩形路面。
- 在村庄入口两侧增加岩石、花灌木、蕨类与蘑菇六组低矮细节。
- 阶段 7 首轮冒烟测试通过，开始实机画面验证。
- 录制并检查阶段 7 开场帧，道路轮廓、入口层次和通行构图通过。
- 冒烟测试新增三个 CSGPolygon3D 类型断言，测试通过。
- 保存阶段基准图 `captures/initial-scene-phase7.png`。
- 完成阶段 7。
- 关闭阶段 6 试玩 PID 35148，启动阶段 7 新试玩窗口（PID 15408）。
- 开始阶段 8：增加村庄生活道具和草地色块。
- 精确导入马车、两种木栅栏和墙面藤蔓，Godot 资源导入通过。
- 增加五块低对比度草地色块、广场马车与木箱、三段小院栅栏和房屋藤蔓。
- 为马车和栅栏增加不可见碰撞体；阶段 8 首轮冒烟测试通过。
- 首轮实机画面否决 CSG 圆形草地色块，开始改为径向透明渐变。
- 改用 GradientTexture2D + PlaneMesh 后再次录制，软边地面层次和生活道具构图通过。
- 冒烟测试新增 VillageProps、草地 MeshInstance3D 和道具资源存在性断言，测试通过。
- 保存阶段基准图 `captures/initial-scene-phase8.png`。
- 完成阶段 8。
- 关闭阶段 7 试玩 PID 15408，启动阶段 8 新试玩窗口（PID 41328）。
- 开始阶段 9：补齐场景边界并增加传送门漂浮微光。
- 补齐 SouthCliff，并延长北、西、东边界以封闭四角。
- 在 BoundaryScenery 中沿四向边界布置 22 块放大岩石与 8 棵树。
- 为传送门增加 8 个共享网格的漂浮微光，随现有 `_process` 动画更新。
- 阶段 9 基础冒烟测试通过，开始动态画面验证。
- 录制并对比阶段 9 两个时间点，微光位移和开场构图通过。
- 冒烟测试新增四向边界、30 个边界布景子节点、8 个微光及位移断言，测试通过。
- 保存阶段基准图 `captures/initial-scene-phase9.png`。
- 完成阶段 9。
- 关闭阶段 8 试玩 PID 41328，启动阶段 9 新试玩窗口（PID 37912）。
- 开始阶段 10：完善镜头落点、扩散光环和低矮植被风摆。
- 相机 FOV 从 36.5 缓动到 42，玩家落点增加 1.5 秒扩散光环。
- `_add_model` 改为返回实例，仅登记草、蕨类和灌木进行轻微风摆。
- 修正落点环为世界地面 y=0.04；阶段 10 基础冒烟测试通过。
- 检查阶段 10 首轮动态序列，中段落点环亮度和厚度过强，未作为最终画面接受。
- 将落点环透明度降至 0.45、自发光强度降至 0.8，并将环宽由 0.14 缩至 0.10。
- 冒烟测试增加落点环、初始镜头 FOV、风摆节点数量与植被旋转变化断言。
- 阶段 10 扩展冒烟测试通过：`SMOKE TEST PASSED`。
- 无窗口 Movie Maker 因 Godot 4.7.1 Dummy 渲染器空纹理崩溃；已记录并切换为实际渲染窗口录帧。
- 使用实际 Compatibility 渲染器录制 80 帧阶段 10 开场序列成功。
- 检查第 10、30、74 帧：淡入、细化后的落点环、镜头拉开和最终构图均通过。
- 完成阶段 10。
- 保存阶段基准图 `captures/initial-scene-phase10.png`，规划检查通过 `10/10`。
- 关闭旧阶段 9 试玩 PID 37912，启动阶段 10 试玩 PID 37980；窗口标题正确且响应正常。
- 开始阶段 11：为传送门增加接近反馈和一次调查互动。
- 在现有 `main.gd` 内加入传送门距离反馈、`F` 调查提示和短暂世界信息，没有引入通用交互框架或新脚本。
- 增加 `interact` 输入动作，使用物理键 F，避免与现有 Q/E 镜头旋转冲突。
- 阶段 11 基础冒烟测试通过，开始扩展交互状态验证。
- 扩展测试首次因动态 VBox 默认节点名不稳定而失败；已改为显式 `PromptStack` 节点名。
- 阶段 11 扩展冒烟测试通过：接近范围、提示可见、灯光增强和调查文本状态均有覆盖。
- 录制并检查交互动态帧，提示、调查文字和传送门接近反馈的画面层级通过。
- 删除仅用于自动摆位和触发调查的临时录帧脚本。
- 重新录制正式开场并检查第 30、74 帧，确认新增交互 UI 在远距离完全隐藏且首屏构图无回归。
- 完成阶段 11。
- 保存交互基准图 `captures/initial-scene-phase11.png`，规划检查通过 `11/11`。
- 关闭阶段 10 试玩 PID 37980，启动阶段 11 试玩 PID 19360；窗口标题正确且响应正常。
- 开始阶段 12：为村屋增加烟囱、炊烟和暖色窗光。
- 检查完整标准版 glTF 列表，确认没有井、路牌、灯笼、长椅或市场摊位，阶段范围收敛到现有烟囱资源。
- Windows `tar -xOf` 因归档根目录含方括号未能直接读取烟囱 glTF，转为检查已有解压缓存或使用 ZIP API。
- 找到完整村庄包解压缓存，确认烟囱一型只需复制 glTF/bin 且复用现有砖石贴图。
- 检查烟囱模型包围范围，确认其坐标已适配约 3m 屋顶高度。
- 选择性复制 `Prop_Chimney.gltf/bin`，Godot 资产导入成功。
- 三栋村屋加入真实烟囱、暖色窗边 OmniLight 和共九团共享网格炊烟。
- 炊烟复用现有 `_process` 做上升、漂移、放大和淡出，没有新增脚本或粒子依赖。
- 阶段 12 基础冒烟测试通过，开始扩展结构与动态断言。
- 阶段 12 扩展冒烟测试通过：三栋村屋、三个窗光、九团烟雾及烟雾动态均有覆盖。
- 首轮正式开场录帧未作为最终结果接受：窗边光偏亮，出生视角无法确认炊烟近景质量。
- 录制村庄中心近景，确认首版烟囱和炊烟被高坡屋顶完全遮挡，开始按屋顶实际高度修正位置。
- 根据屋顶包围盒将烟囱整体抬高 3.1m、烟源抬至 y=6.45，并提高炊烟基础可见度。
- 将窗光能量从 0.32 降至 0.14、范围从 3.6 降至 2.6，避免日景出现黄白色块。
- 第二轮村庄近景仍未显示出可辨认烟囱或炊烟，暂停数值微调并转向运行时节点/边界诊断。
- 运行时诊断确认模型已加载，但烟囱顶端低于屋脊且位于相机背侧坡面；删除临时诊断脚本。
- 将烟囱和烟源移到朝相机的外侧坡面，并提高低层烟团不透明度和灰度对比。
- 第三轮村庄近景确认烟囱已正确露出屋面，但屋顶烟雾位于固定俯视镜头画面之外。
- 阶段 12 增补广场边缘公共炉火，复用同一烟雾与暖光表现，确保正常探索视角可见。
- 完成公共炉火结构：七块岩石、两根木柴、三团火焰、暖光与三团复用烟雾。
- 首次炉火测试因旧烟雾总数断言仍为 9 而失败，已更新为 12 并增加炉火动态覆盖。
- 公共炉火首轮动态帧确认位置与火焰通过，但球形烟雾边缘过硬，开始改用径向渐变 Billboard 面片。
- 将十二团共享烟雾改为径向透明 GradientTexture2D + Billboard QuadMesh。
- 第五轮村庄近景确认软边烟雾、炉火尺度和道路通行构图通过；删除临时村庄摆位脚本。
- 录制阶段 12 正式出生开场并检查第 40、75、95 帧，炉火、烟囱、窗光与传送门层级通过。
- 完成阶段 12。
- 保存阶段基准图 `captures/initial-scene-phase12.png`，规划检查通过 `12/12`。
- 关闭阶段 11 试玩 PID 19360，启动阶段 12 试玩 PID 6460；窗口标题正确且响应正常。
- 开始阶段 13：在出生道路左侧增加异界浅水洼、岸石、芦草和动态水纹。
- 对比阶段 12 村庄近景与正式出生帧，确认水洼落点为空草地且不会侵占主路或现有地标。
- 增加 `MistPond`：软边椭圆水面、八块岸石、五株风摆草木、两个共享水纹和不可见椭圆碰撞。
- 将原位于水洼内的蘑菇移到西侧岸外，避免现有布景穿入水面。
- 阶段 13 基础冒烟测试通过，开始扩展结构与动态断言。
- 阶段 13 扩展冒烟测试通过：水面、碰撞、17 个岸边节点、15 株风摆草木和两个动态水纹均有覆盖。
- 首轮动态开场确认构图有效，但水面和最大水纹偏亮；降低水面饱和度、发光强度和水纹扩散上限。
- 第二轮动态开场检查第 40、70、95 帧，水面色彩、岸景融合、水纹强度和传送门主次关系通过。
- 完成阶段 13。
- 保存阶段基准图 `captures/initial-scene-phase13.png`，规划检查通过 `13/13`。
- 关闭阶段 12 试玩 PID 6460，启动阶段 13 试玩 PID 12236；窗口标题正确且响应正常。
- 开始阶段 14：用原生低多边形网格重塑漂泊者外观，并增加轻微步态反馈。
- 复核玩家结构，确认碰撞体与 CameraRig 不依赖 Visual 子节点，可独立替换角色外观。
- 用九个稳定命名的原生低多边形部件替换黄色胶囊：斗篷、头部、围巾与尾带、背包、双靴和两层旅帽。
- 在 `player.gd` 增加轻微身体起伏、交替靴步和围巾尾摆动，CameraRig 保持独立不参与起伏。
- 阶段 14 基础冒烟测试通过，开始扩展角色结构与步态断言。
- 扩展测试首次因通用 Node 的 rotation 无法静态推断而编译失败；改为显式 Node3D 类型。
- 阶段 14 扩展冒烟测试通过：九个视觉部件和身体/双靴/围巾步态变化均有覆盖。
- 正式开场静态帧确认新漂泊者轮廓、颜色层级和尺寸通过。
- 录制自动前进行走序列，检查第 15、30、45、70 帧，角色转向、移动构图和相机稳定性通过。
- 删除仅用于自动按住前进键的临时录帧脚本。
- 完成阶段 14。
- 保存阶段基准图 `captures/initial-scene-phase14.png`，规划检查通过 `14/14`。
- 关闭阶段 13 试玩 PID 12236，启动阶段 14 试玩 PID 14296；窗口标题正确且响应正常。
- 开始阶段 15：加入雾谷环境循环声与传送门空间低鸣。
- 检查项目确认当前没有音频资源或 AudioStream 节点。
- Meowa 认证未配置，未启动生成或请求密钥；阶段改用可核验许可的 CC0 现成音频。
- 在内部浏览器核实 `Park ambiences` 与 `Loopable Dungeon Ambience` 两个来源页均明确标注 CC0。
- 下载并处理最终音频：30 秒雾谷环境循环约 415 KB，94 秒传送门低鸣约 822 KB。
- 新增全局 `MistValleyAmbience` 与空间 `PortalHum`，后者随玩家接近从 -24 dB 提升到 -11 dB。
- 新增 `assets/audio/LICENSES.md`，记录来源页、CC0 链接、原文件和处理方式。
- 阶段 15 扩展冒烟测试通过：资源导入、循环、播放状态、空间位置和距离响度均有覆盖。
- 临时源目录删除被安全策略拒绝；已加入 `.gdignore`，避免 Godot 后续扫描原始素材。
- 完成阶段 15。
- 开始阶段 16：在现有村屋与水洼附近加入三名村民 NPC。
- 新增药草师 Mira、守门人 Toren 和织工 Nia；三人具备稳定碰撞、不同衣色、帽型和专属随身物。
- 待机动画只驱动 Visual 的轻微上下起伏与转身，NPC 的 StaticBody3D 碰撞保持不动。
- 首轮测试因动态碰撞节点缺少稳定名称失败；补充 `CollisionShape3D` 名称后完整冒烟测试通过。
- 正式开场帧确认最近村民不抢玩家和传送门层级；村庄中心近景确认另外两名村民及道路、房门、炉火通行关系通过。
- 保存阶段基准图 `captures/initial-scene-phase16.png`。
- 完成阶段 16。
- 最终规划检查通过 `16/16`，完整冒烟测试再次输出 `SMOKE TEST PASSED`。
- 关闭阶段 14 试玩和首轮失败测试遗留进程；首次绝对路径启动因空格参数拆分退出，改用相对路径后成功。
- 启动阶段 16 最新试玩 PID 43492；窗口标题正确且响应正常。
- 开始阶段 17：让三名现有村民支持就近交谈，并复用现有 `F` 交互入口。
- 增加 3 米最近村民判定；村民交谈优先于传送门调查，离开范围后提示自动隐藏。
- 为米拉、托伦和尼娅分别加入一条身份化短对白，并用一次轻微点头提供说话反馈。
- 阶段 17 首轮完整冒烟测试通过：村民列表、最近目标、姓名提示、对白显示和原传送门交互均有覆盖。
- 录制并检查尼娅交谈实机帧；对白宽度、底部安全区、人物可读性和道路遮挡均通过。
- 将冒烟测试扩展为逐一验证米拉、托伦、尼娅的姓名提示与身份对白。
- 保存阶段基准图 `captures/initial-scene-phase17.png`。
- 完成阶段 17。
- 最终规划检查通过 `17/17`，逐一覆盖三名村民的完整冒烟测试输出 `SMOKE TEST PASSED`。
- 关闭阶段 16 试玩 PID 43492，启动阶段 17 最新试玩 PID 45332；窗口标题正确且响应正常。
- 开始阶段 18：在水洼岸边与林缘增加四组缓慢发光的异界雾灯菇。
- 复核阶段 16 正式开场图，确认四处落点不会侵占主路、水洼碰撞或传送门地标。
- 新增四组共享网格雾灯菇：共 12 个菌帽与 4 盏微弱点光，不增加碰撞或外部资源。
- 在现有 `_process` 中加入低频发光和点光呼吸变化，能量保持低于传送门。
- 阶段 18 结构与动态冒烟测试一次通过。
- 录制并检查阶段 18 正式开场：近路菌菇可见但克制，其余菌群保留探索发现感，传送门仍是主地标。
- 保存阶段基准图 `captures/initial-scene-phase18.png`。
- 完成阶段 18。
- 最终规划检查通过 `18/18`，完整冒烟测试输出 `SMOKE TEST PASSED`。
- 关闭阶段 17 试玩 PID 45332，启动阶段 18 最新试玩 PID 47216；窗口标题正确且响应正常。
- 开始阶段 19：在地图边界与林缘增加六片低空漂移软雾。
- 复核阶段 18 正式开场，确认雾片只需补左右林缘层次，不应覆盖中央探索动线。
- 新增六片共享 QuadMesh 与径向渐变材质的低空软雾，全部关闭阴影并放置在边界区域。
- 在现有 `_process` 中加入约 1 米缓慢横移、轻微起伏和透明度变化。
- 阶段 19 完整冒烟测试一次通过：数量、原点、禁用阴影及动态变化均有覆盖。
- 录制 100 帧正式开场并对比中后段画面；漂移可见、软边完整，中心探索目标无雾遮挡。
- 保存阶段基准图 `captures/initial-scene-phase19.png`。
- 完成阶段 19。
- 最终规划检查通过 `19/19`，完整冒烟测试输出 `SMOKE TEST PASSED`。
- 关闭阶段 18 试玩 PID 47216，启动阶段 19 最新试玩 PID 34116；窗口标题正确且响应正常。
- 开始阶段 20：为现有俯视相机加入鼠标滚轮平滑缩放。
- 确认开场 FOV Tween、CameraRig 旋转与局部位置缩放互不冲突，采用高度 10-20 的安全范围。
- 在 `player.gd` 增加滚轮目标距离与平滑局部位置插值，不新增输入映射或相机节点。
- 阶段 20 冒烟测试一次通过：滚轮方向、位置比例以及最近/最远边界均有覆盖。
- 首轮近远景录帧确认安全边界可用，但切换时机与开场 FOV 缓动重叠；延后切换后重新录制受控对比。
- 开场 FOV 稳定后重新录制 160 帧受控序列，确认近景人物比例和远景地图边界均通过。
- 保存 `captures/initial-scene-phase20-near.png` 与 `captures/initial-scene-phase20-far.png`。
- 完成阶段 20。
- 最终规划检查通过 `20/20`，完整冒烟测试输出 `SMOKE TEST PASSED`。
- 关闭阶段 19 试玩 PID 34116，启动阶段 20 最新试玩 PID 46148；窗口标题正确且响应正常。
- 开始阶段 21：为传送门调查增加一次性空间声和短暂光效响应。
- 在内部浏览器重新核实 `Portal sound` 来源页、作者、下载文件与 CC0 标记；本地原始 Ogg 仍完整可用。
- 复制最终 `portal_react.ogg` 并验证为 44.1 kHz 单声道 Vorbis、0.574 秒、峰值 -14.5 dB，无长静音。
- 更新音频许可清单，记录作者、来源页、原归档路径、CC0 链接和仅重命名处理。
- 新增空间 `PortalReact` 播放器；调查时播放一次短音，并让石环、灯光与八颗微光在约 0.7 秒内共同回落。
- Godot 4.7.1 成功导入新 Ogg；扩展冒烟测试通过初始状态、非循环、空间位置、播放触发和动态回落。
- 首轮实际录音发现调查段未高于底噪；定位为高空相机监听导致 3D 衰减过度。
- 在 Player 根节点增加当前 AudioListener3D，使空间音频按角色位置而非高空摄像机位置衰减。
- 修正后重新录制调查：触发段峰值较底噪提升约 20 dB，音轨为 48 kHz 双声道 PCM 且无削波。
- 对比调查前与峰值帧，白青闪光范围、石拱轮廓、玩家层级和底部对白均通过。
- 保存阶段基准图 `captures/initial-scene-phase21.png`。
- 完成阶段 21。
- 最终规划检查通过 `21/21`，完整冒烟测试输出 `SMOKE TEST PASSED`。
- 关闭阶段 20 试玩 PID 46148，启动阶段 21 最新试玩 PID 29252；窗口标题正确且响应正常。
- 开始阶段 22：为旅行者加入与现有步态同步的轻量脚步声。
- 采用一个玩家子节点 `AudioStreamPlayer3D` 交替播放两条短音；不增加地形分类、奔跑状态或通用音频管理器。
- 已从核验过的 OpenGameArt HTTPS 下载 `Fantozzi-footsteps.7z`；本机缺少 7z CLI，改用系统 `tar` 解包。
- 选用 `Fantozzi-SandL2.ogg` 与 `Fantozzi-SandR2.ogg`，分别约 0.320 秒和 0.340 秒；原始 Ogg 仅重命名，不重复转码。
- 在 `player.gd` 内加入单个 `Footsteps` 空间播放器，并按现有步态半周期交替触发；静止和离地时不推进脚步。
- 为临时素材目录增加 `.gdignore`，避免 Godot 后续扫描候选与原始归档。
- 新增可重复的 `tests/footstep_capture.gd`：录制静止 1.5 秒、行走 3 秒、停止 0.8 秒，用于对比实际混音。
- 首轮实录脚步触及默认 3D 近场音量上限，且停止段采样窗口包含最后一步尾音；改做隔离录音定位并延后停止段窗口。
- 隔离录音确认玩家同位监听产生 3D 近场增益，脚步触及默认上限；将 `volume_db` 与 `max_db` 同时设为 `-26 dB` 后重录。
- 修正后隔离录音行走峰值约 `-34.6 dB`，完整混音静止峰值约 `-46.5 dB`、行走峰值约 `-34.3 dB`，无削波并低于传送门调查反馈。
- 完成阶段 22。
- 最终规划检查通过 `22/22`，完整冒烟测试输出 `SMOKE TEST PASSED`。
- 关闭阶段 21 试玩 PID 29252，启动阶段 22 最新试玩 PID 42672；窗口标题正确且响应正常。
- 开始阶段 23：让最近村民在交互范围内平滑面向玩家，离开后恢复原朝向。
- 直接复用 `nearby_villager` 与现有 Visual 旋转，不增加 NPC 感知组件、状态机或移动 AI。
- 在 `main.gd` 的现有村民待机循环中加入目标朝向插值；靠近时看向玩家，离开时回到各自基础朝向。
- 冒烟测试覆盖织工靠近转身、目标角误差收敛、离开后复位，完整测试一次通过。
- 新增 `tests/villager_facing_capture.gd`，用于录制双方相向交谈的实机近景。
- 首轮近景确认角度误差近乎为零，但 NPC 圆形头部正面不够清楚；为三名村民增加共享结构的低面数鼻部轮廓。
- 用户要求寻找真实人物资产；内部浏览器已核验 Quaternius `Universal Base Characters`、`Universal Animation Library 2` 与 `RPG Character Pack`。
- 选择自带骨骼、动画、贴图与 glTF 的 CC0 `RPG Character Pack` 作为首轮替换方案，避免当前阶段引入动画重定向链。
- 完成阶段 23；自动角度测试和双方相向交谈近景均通过。
- 开始阶段 24：接入 Quaternius CC0 RPG Character Pack 的完整骨骼人物。
- 已通过官方 Drive 下载并复制 `Ranger`、`Cleric`、`Warrior`、`Monk` 四个自包含 glTF；Godot 4.7.1 全部导入成功。
- 新增只读 `tests/character_asset_inspect.gd`，用于核对实际动画播放器、动画名与整体模型边界。
- 首轮检查确认四个模型各有一个 `AnimationPlayer` 和 `Idle/Walk/Run`，但初始化阶段 AABB 的全局变换无效；检查延后到入树首帧后重跑。
- 将 Ranger 接入玩家 Visual，并以模型自带 Run/Idle 替代原生几何摆腿；脚步触发、移动、镜头和碰撞逻辑保持不变。
- 将 Cleric、Warrior、Monk 分别接入米拉、托伦、尼娅；三人播放循环 Idle，原有碰撞、对话、点头与注视复位逻辑保持不变。
- 更新冒烟测试，覆盖四个人物资源、玩家动画切换、NPC Idle 动画以及既有交互回归；完整测试输出 `SMOKE TEST PASSED`。
- 录制 `temp/character-phase24.avi`；实机开场与交谈近景确认模型落地、比例、朝向和 UI 安全区通过，村民转身误差约 `0.00000019`。
- 保存 `captures/initial-scene-phase24-opening.png` 与 `captures/initial-scene-phase24.png`。
- 完成阶段 24。
- 最终规划检查通过 `24/24`，完整冒烟测试与人物资源检查再次通过。
- 关闭旧试玩 PID 42672，启动阶段 24 最新试玩 PID 49164；窗口标题正确且响应正常。
- 开始阶段 25：为俯视探索增加房屋屋顶遮挡反馈。
- 确认屋顶模型与墙体、碰撞、烟囱、烟雾相互独立，可只淡化屋顶网格而不改变房屋玩法边界。
- 首轮节点透明度调节在 Compatibility 渲染器中未生效；检查出 glTF 表面材质未启用 Alpha，改为按房屋复制材质后插值颜色 Alpha。
- 屋顶生效后发现可见 `HouseCollision` 外壳仍遮挡角色，因此将淡出范围修正为房屋可见外壳，同时保持碰撞启用。
- 最终近景确认 Ranger 和 NPC 在屋后均清晰可见，房屋仍保留轻量轮廓；录制 `temp/roof-fade-phase25d.avi` 并保存 `captures/initial-scene-phase25.png`。
- 完整冒烟测试覆盖当前房屋淡出、其他房屋保持不透明、离开恢复以及碰撞继续启用，输出 `SMOKE TEST PASSED`。
- 完成阶段 25。
- 最终规划检查通过 `25/25`；关闭旧试玩 PID 49164，以最小化窗口启动最新试玩 PID 50512，窗口响应正常且不再抢占前台。
- 开始阶段 26：为三名村民增加靠近时出现的姓名与职业标识。
- 确认现有 3 米交谈判定保持不变，身份标识只负责 7 米内的中距离识别。
- 为米拉、托伦、尼娅增加镜头朝向 Label3D；7 米内平滑淡入，离开后隐藏，文字分别包含姓名与药草师、守门人、织工身份。
- 首轮固定尺寸文字在近景异常放大，改用世界空间 `pixel_size = 0.012` 后重新录制通过。
- 保存阶段画面 `captures/initial-scene-phase26.png`；标识未遮挡人物、道路或底部对白。
- 完整冒烟测试覆盖三个标识、5 米识别、3 米交谈隔离和远离隐藏，输出 `SMOKE TEST PASSED`。
- 完成阶段 26。
- 最终规划检查通过 `26/26`；关闭旧试玩 PID 50512，以最小化窗口启动最新试玩 PID 44060，窗口响应正常。
- 开始阶段 27：让三名村民在各自房屋外的开放区域进行短距离往返巡游。
- 确认三个角色模型均有 Walk/Idle，路径可限制在约 1.2 米单轴范围内，无需引入 NavigationAgent 或通用 AI 系统。
- 将三名 NPC 根节点改为 CharacterBody3D，显示模型、碰撞、身份标识和交互位置保持同一根节点移动。
- 为三人配置各自 1.2 米单轴巡游；移动播放循环 Walk，玩家进入交谈范围后速度归零并播放 Idle，离开后恢复巡游。
- 首轮测试因旧契约仍要求首帧 Idle 失败；更新为巡游首帧 Walk，并保留交谈切回 Idle 的独立断言后完整通过。
- 新增 `tests/villager_patrol_capture.gd`，录制 `temp/villager-patrol-phase27.avi`；米拉 2.4 秒移动约 `0.715` 米，路径、步态、标签和场景通行关系通过。
- 保存 `captures/initial-scene-phase27-start.png` 与 `captures/initial-scene-phase27.png`。
- 完成阶段 27。
- 简化检查发现旧 `villager_facing_capture.gd` 仍使用 StaticBody3D 类型；同步改为 CharacterBody3D 后无窗口回归通过，转身误差约 `0.0000038`。
- 最终规划检查通过 `27/27`；关闭旧试玩 PID 44060，以最小化窗口启动最新试玩 PID 47060，窗口响应正常。
- 开始阶段 28：为村民巡游端点增加错开的短暂停留，减少立即掉头的机械感。
- 增加与村民数组同序的暂停时间；三名村民在端点分别停留 1.2、1.5、1.8 秒，停留播放 Idle，结束恢复 Walk。
- 修正动画切换守卫为 `assigned_animation`，避免 0.2 秒混合期间因旧 `current_animation` 跳过新目标。
- 自动测试按真实 CharacterBody 物理语义拆分为单步行走和直接端点验证，并覆盖停留无漂移、倒计时、方向翻转和恢复 Walk。
- 录制 `temp/villager-pause-phase28.avi`，停留 0.8 秒位置漂移为 `0.0`；保存 `captures/initial-scene-phase28-walk.png` 与 `captures/initial-scene-phase28.png`。
- 完成阶段 28。
- 最终规划检查通过 `28/28`；关闭旧试玩 PID 47060，以最小化窗口启动最新试玩 PID 50268，窗口响应正常。
# 2026-08-31 Phase 29

- Started a restrained camera-lead pass: 1.6 m in actual movement direction, smooth recenter while stopped.
- Preserving camera yaw, wheel zoom, and the player-root audio listener contract.
- Added direct camera-rig interpolation in `scripts/player.gd`, driven by post-collision real velocity.
- Extended `tests/smoke_test.gd` to cover smooth lead, the 1.6 m cap, recentering, and camera/listener isolation.
- Full headless smoke test passed: `SMOKE TEST PASSED`.
- Added `tests/herb_gather_capture.gd` for a minimized close-view MovieWriter check of gathering, facing, drift, and walk resumption.
- Recorded `temp/herb-gather-phase30.avi` minimized: 91 frames, 3.01 seconds, exit code 0.
- Numeric capture validation passed and three action keyframes were extracted.
- Gathering-start and mid-action frames passed visual review for pose readability, plot scale, and road clearance.
- Walk-resume frame passed; Phase 30 visual behavior is complete pending final regression and playable replacement.
- Final full smoke regression passed.
- Replaced PID 42036 with latest playable PID 51692; the debug window is responsive and confirmed minimized.
- Phase 30 complete: Mira now gathers from a visible herb plot during one patrol stop.
- Added `tests/camera_lead_capture.gd` for a forward-stop-right-stop MovieWriter validation sequence.
- Recorded `temp/camera-lead-phase29.avi` minimized: 155 frames, 5.05 seconds, exit code 0.
- Numeric capture output confirmed a 1.598 m directional lead and 0.017 m recenter residual after 0.9 seconds.
- Extracted four Phase 29 keyframes; forward movement and first recenter frames passed visual framing review.
- Rightward movement and final recenter keyframes also passed; all four Phase 29 visual states are readable and stable.
- Final complete smoke test passed after visual validation.
- Replaced the old playable process with PID 42036; its debug window is responsive and confirmed minimized.
- Phase 29 complete: movement-direction camera lead is implemented and verified end to end.
# 2026-08-31 Phase 30 audit

- Resumed from the verified Phase 29 build and started an initial-scene gap review.
- Confirmed the current minimized playable remains responsive and no unexpected worktree changes appeared.
- Reviewed the latest village-square frame and identified lived-in activity, rather than another camera feature, as the highest-value next pass.
- Selected a bounded Phase 30 direction: give herbalist Mira a visible herb-gathering stop using existing plants and her built-in `PickUp` animation.
- Added Phase 30 to the plan and began endpoint, animation-length, and clearance checks.
- Confirmed a clear herb-bed location north of Mira's positive patrol endpoint and chose runtime animation length as the pause duration.
- Confirmed the plot can reuse existing world-building helpers and remain collision-free.
- Added a five-plant, non-colliding herb bed beside Mira's positive endpoint.
- Added a Mira-only gathering pause that faces the plot, uses the imported `PickUp` length, and remains subordinate to conversation.
- Extended the smoke test for herb-bed structure, gathering duration/facing, normal opposite-end pause, and conversation interruption.
- Full headless smoke test passed: `SMOKE TEST PASSED`.
# 2026-08-31 Phase 31

- Started a hearth-audio pass to make the visible village fire an audible life anchor.
- Defined a looped Ogg, CC0 provenance, spatial attenuation, and restrained mix as the final asset contract.
- Verified the OpenGameArt `Fireplace Sound loop` source page, author PagDev, CC0 license, loop intent, and exact WAV download link in the in-app browser.
- Rejected the otherwise valid OpenGameArt candidate before writing bytes because its server reports `application/octet-stream` rather than `audio/*`.
- Located an exact Wikimedia Ogg candidate as the alternative source and moved to per-file verification.
- Logged a heavy Wikimedia file-page timeout and changed verification strategy instead of repeating it.
- Browser recovery succeeded, but the lightweight Wikimedia API URL was client-blocked; moved the exact metadata read to the official API client path.
- Rejected the Wikimedia candidate after its official metadata and original-media HEAD both reported `application/ogg`; no bytes were written.
- Discarded a stale in-app browser tab after navigation timeout and switched to a fresh tab per recovery guidance.
- SoundBible was DNS-unreachable; ended external-source search and moved to a local-authentication check with a procedural fallback.
- Confirmed Meowa authentication is absent and selected the local FFmpeg procedural fallback without exposing or requesting credentials.
- Generated the first deterministic procedural hearth loop candidate and validated format, duration, size, full two-cycle decode, loudness, and true peak.
- NumPy was unavailable for seam analysis; switched to a standard-library implementation without adding dependencies.
- Standard-library seam and silence validation passed; generated a 1280x720 spectrogram for content review.
- Spectrogram content review passed; approved the first deterministic candidate without another tuning round.
- Added the validated 83 KB loop as `assets/audio/hearth_fire.ogg` and documented its local generation method.
- Connected it to a direct `AudioStreamPlayer3D` at the village hearth with restrained attenuation, and extended smoke coverage.
- Logged the expected first-use Godot import-order failure and switched to an editor import pass before retrying tests.
- Completed the Godot import pass and isolated Phase 31 validation media with `.gdignore`.
- Full headless smoke test passed after import.
- Defined a stationary far-to-near capture path for full-mix and isolated-hearth recordings.
- Added `tests/hearth_audio_capture.gd` with optional isolation and fixed far/near listener positions.
- Recorded full-mix and isolated-hearth Phase 31 AVIs minimized; both completed with exit code 0.
- Far/near segment analysis confirmed audible proximity gain, near-silent out-of-range output, and correct hierarchy below footsteps and portal feedback.
- Final smoke regression passed; playable replacement produced no verification output, so current process state requires an explicit diagnostic before completion.
- Recovery audit confirmed there is no current playable process; switching the one replacement attempt to the console executable with redirected logs.
- Console retry PID 42748 stayed alive and minimized, but only its console window is visible; render-window diagnosis remains before Phase 31 completion.
- Traced the actual game to child PID 39048 and found its debug window responsive but not minimized; preparing an exact child-window minimize and verification.
- The child exited before minimization; abandoned the console-parent strategy after its third failure and moved to a direct-GUI launch with immediate window polling.
- Direct GUI launch succeeded as PID 55440; exact-window and delayed checks both confirmed a responsive minimized playable.
- Phase 31 complete: the village hearth now has a validated spatial fire loop with preserved mix hierarchy.
# 2026-08-31 Phase 32

- Started a restrained village-ground wear pass to break up the remaining uniform square.
- Limited scope to four soft activity patches using the existing ground-patch helper with a safe overlay elevation.
- Added four named soft wear patches above the village square and extended `_add_ground_patch()` with one optional elevation argument.
- Extended the smoke suite to verify patch nodes, y=0.12 overlay height, plane meshes, alpha materials, and gradient textures.
- Resumed Phase 32 from disk and confirmed the planning state, code, and untracked worktree match the recorded handoff.
- Full headless smoke test passed on the first run: `SMOKE TEST PASSED`.
- First minimized GUI MovieWriter produced a 97-frame AVI, but two extracted stable frames were fully black; logged the visual failure and changed the next attempt to a hidden, non-minimized window.
- Hidden, non-activating MovieWriter produced 97 rendered frames; pixel checks and two visual frames confirmed stable geometry but showed the wear was too faint at village scale.
- Raised only the four wear-patch center opacities from 0.24 to 0.34 through one optional helper argument; other ground patches, sizes, and elevations remain unchanged.
- Kept the 18 m village-wide frames as hierarchy evidence and changed the focused capture to the 10 m gameplay zoom for final readability review.

# 2026-08-31 Phase 33

- Started a ground-tone pass after the user identified a white-film look across both pale grass and road surfaces.
- Traced the shared contributors to global gray-green fog plus combined ambient and directional fill, rather than either base material color alone.
- User clarified that the real issue is material identity, not exposure; abandoned the light/fog pass and redirected Phase 33 to seamless grass and compacted-dirt surface detail.
- Removed the failed light-diagnostic script after recording its node-name error; it is not part of the final validation path.
- Added deterministic 64x64 seamless modulation textures to the shared grass and dirt materials: sparse short grass marks for the valley floor, compressed variation and small scuffs for paths.
- Kept the existing palette, roughness, road geometry, collisions, and lighting unchanged.
- Added a controlled same-camera MovieWriter check that switches from the old flat materials to the new textured materials during one recording.
- First A/B frames confirmed the material identity improvement but exposed over-dense repeating dash marks.
- Halved the detail density, reduced contrast, varied dirt-mark orientation, and doubled the texture world scale for a quieter natural surface.
- Second visual pass removed the obvious repeating pattern and kept the ground texture readable at gameplay zoom.
- Added two shallow cart tracks on each main-road approach, stopping them at the village square so the courtyard stays open and uncluttered.
- Added a focused road-surface capture at gameplay zoom to review grass/dirt separation, track spacing, and path readability.
- Road capture recorded 97 rendered frames; measured cart-track spacing was about 1.9 m.
- Two road frames passed visual review: material separation, compressed direction, track height, road readability, and landmark hierarchy are stable.
- Final full smoke regression passed after the Phase 33 road and ground changes.
- Phase 32 and Phase 33 are complete; stopped feature development at the user's request and moved to first-commit preparation.
- First-commit audit passed: 243 files / about 109 MB, no oversized file, no secret-pattern hit, and asset/audio licensing records are present.

# 2026-08-31 Phase 34

- 根据新的《Death's Door》式美术方向完成第一轮免费素材评估，建立独立 `ArtEvaluation` 场景。
- 哈希复核确认新下载的 Quaternius 自然与村庄模型，其二进制网格和贴图与项目现有对应资产一致；仅 glTF 元数据不同，因此不做无收益替换。
- KayKit Hooded Rogue 在统一身高和同镜头对比中拥有最清楚的帽兜、披风和紧凑比例，选为漂泊者玩家原型。
- 新增独立 `DrifterVisual` 场景，合并 KayKit General 与 Movement 动画库，并映射为现有 `Player.gd` 使用的 Idle、Walk、Run、Interact 和 PickUp。
- 新增共享 `drifter_palette.gdshader`，以 Toon 漫反射、低饱和森林绿、较高粗糙度和克制青色边缘光压低原始玩具感。
- 在 KayKit chest 骨骼下增加青色异界印记，使其随 Idle/Run 动画移动。
- 将 `main.gd` 玩家外观替换为 `DrifterVisual`，碰撞、移动、脚步、镜头和开场节点契约保持不变。
- 最终 `DRIFTER VISUAL TEST PASSED` 与 `SMOKE TEST PASSED`；仅保留原冒烟脚本已有的 ObjectDB/资源退出警告。
- 实机移动录制共 155 帧：前进与横移时 Run、朝向、落地和镜头提前量均正常。
- 保留开场、前进和横移最终帧；移除重复录制帧与无用 AVI。
- 自审后将约 183 MB 的临时评估目录迁移到 Git 忽略的 `.downloads/art-evaluation/curated-evaluation/`，正式项目只保留约 2.3 MB KayKit 玩家最小依赖。
- 完成阶段 34。

# 2026-08-31 Phase 35

- 玩家替换后实机画面暴露出新玩家与旧 NPC 头身比例不一致，选择同一 KayKit Adventurers 家族继续统一角色。
- Mage、Knight、非兜帽 Rogue 分别对应药草师米拉、守门人托伦和织工尼娅；三者与玩家共享 23 骨骼和同一动画库。
- 抽取 `kaykit_character_visual.gd`，统一完成 Idle/Walk/Run/Interact/PickUp 动画别名、Toon 材质和角色调色；漂泊者子场景只额外启用异界印记。
- 完整冒烟测试新增统一骨骼数、基础缩放和视觉高度比例约束，防止角色忽大忽小或重新混入修长体型。
- 首轮村庄近景发现米拉大帽檐与身份标签重叠；新增按模型可见包围盒计算标签高度，回归测试后重录通过。
- 村民巡游暂停漂移保持 `0.0`，尼娅注视误差约 `0.0108 rad`；巡游、采集、注视和对白逻辑未回归。
- 完成阶段 35。

# 2026-08-31 Phase 36

- 用户明确要求序章场景本身持续变化，而非只替换人物。
- 当前世界坐标显示主路已贯穿南北、传送门和雾池位于南段两侧、村庄位于中北段；最高价值改造是重新建立出生、支路和北侧出口三段叙事动线。
- 玩家出生点从主路中央移到异界石环中心南侧约 3 米；首帧碰撞只产生约 0.15 米横向解交叠，保持在 0.25 米契约内。
- 新增 `PondPath`，从传送门与主路交汇处向西连接雾池东岸，形成可选调查支路。
- 将单块 `NorthCliff` 拆成 `NorthCliffWest/East`，保留约 8 米中央缺口；新增 `MistPassPath` 与不可见 `MistPassBoundary`。
- 首轮山口画面发现旧边界中央岩石仍堵住缺口；移除该岩石，并加入三层低矮石阶。
- 第二轮画面确认通道打开，但雾墙不可读；新增 `mist_curtain.gdshader`、两枚青色符石和加强后的局部冷光。
- 复用道路 64×64 无缝纹理处理灰褐山口路面和台阶，消除纯色灰盒感。
- 最终路线录制确认石环出生、雾池岔路和浓雾山口三个画面节点均在 12 米玩法镜头下可读。
- 完整冒烟测试覆盖出生点、两条新路径、左右悬崖、15 个山口节点、碰撞边界、石阶、雾幕 Shader、符石和第七片漂雾，输出 `SMOKE TEST PASSED`。
- 完成阶段 36。

# 2026-08-31 Phase 37

- 以测试锁定五块 CSG 悬崖必须隐藏但保留碰撞，并要求新的 `CliffVisuals` 至少提供 36 个可见岩石实例。
- 首版生成 39 个错位岩石山脊，成功消除直线灰墙，但山口内侧两块岩石过大，压迫玩家和符石焦点。
- 为岩石实例增加稳定 `CliffRock00..38` 命名，并限制北侧中央 20 米范围的最大缩放不超过 2.1。
- 山口近景复核通过；最大 20 米镜头四向旋转确认没有重新出现直线 CSG 墙体。
- 首轮四向录制因 Player 物理每帧重置 CameraRig yaw 而得到四张同向画面；捕获脚本暂停玩家物理后重录成功，生产逻辑无需修改。
- 新增独立 `scenes/world/valley_boundary.tscn` 与 `valley_boundary.gd`，迁移五个碰撞盒和 39 个可见岩石。
- 无编辑器全局类缓存时，`ValleyBoundary` 类型不可见导致解析失败；取消 `class_name` 依赖，主场景通过 Node3D 公开 `build()` 接口调用。
- 组件化前后同一山口机位画面一致，完整冒烟测试输出 `SMOKE TEST PASSED`。
- 完成阶段 37。

# 2026-08-31 Phase 38

- 浓雾山口已经形成视觉和碰撞边界，但玩家靠近时没有任何剧情或交互反馈；它目前仍只是布景，不是序章目标。
- 用户要求暂停开发并提交推送；Phase 38 尚未进入功能实现，状态改回 `pending`，不在本次提交中声称完成。

# 2026-09-01 Phase 38 resume

- 恢复序章场景迭代，确认 Phase 38 是当前最高价值缺口：山口已有完整视觉节点，但尚未形成序章结尾事件。
- 交互继续复用现有底部提示与世界信息，优先级确定为附近村民、浓雾山口、异界石环。
- 反馈限定为现有雾幕 Shader、两枚符石、两盏冷光和降调后的异界反馈音，不新增任务框架或外部素材。
- 已加入山口距离判断、交互优先级、雾幕参数响应、符石与冷光联动；首轮音频和测试合并补丁因测试上下文不匹配整体未应用，改为按实际位置拆分。
- 用户将当前重点切换为传送门初始场景；已停止遗留无头测试进程并撤回本轮全部 Phase 38 生产代码与测试，Phase 38 恢复 `pending`。

# 2026-09-01 Phase 39

- 开始迭代玩家出生的异界石环场景，优先解决大块灰色圆台与周围草地割裂、落地点缺少异界叙事痕迹的问题。
- 将 `PortalPlatform` 改为不可见薄碰撞，使用软边灰绿石痕和旧土磨损把落地点融入草地。
- 将连续青色 Torus 改成七段大小错落的地面符痕，并在石拱边缘加入四块碎石、一株蕨和一簇高草。
- 完整冒烟测试首次通过，输出 `SMOKE TEST PASSED`；仅保留既有 Godot 退出清理警告。
- `git diff --check` 通过；已确认 Godot GUI 与 FFmpeg 可用于底层窗口的真实渲染录制和关键帧检查。
- 使用 GUI MovieWriter 在 `HWND_BOTTOM` 窗口层级完成首轮真实渲染，保存 `captures/portal-phase39.png`；灰圆盘问题已解决，发现符痕亮度与朝向仍需一次收敛。
- 第二轮切向测试暴露椭圆位置与圆切线公式不一致；无头会话已精确终止，改用等半径残缺圆收敛几何契约。
- 等半径残缺圆与独立低亮符痕材质完成后，完整冒烟测试再次通过。
- 最终 GUI MovieWriter 继续保持窗口在 `HWND_BOTTOM`，保存 `captures/portal-phase39-final.png`；画面确认石拱、玩家、道路、旧土与草地层级清楚。
- 玩家视觉专项测试通过，`git diff --check` 通过，录制结束后没有残留 Godot 进程；完成 Phase 39。

# 2026-09-01 Phase 40

- 开始处理初始传送门门面的平面感；现有门面是与外环共用材质的均匀 `CSGCylinder3D`，只能整体变亮，缺少独立空间层次。
- 已加入独立圆形 Quad Shader 与调查响应参数；首轮无头运行暴露无效渲染模式，修正为 Godot 4 的 `depth_prepass_alpha` 后重新验证。
- 修正后完整冒烟测试通过且无 Shader 编译错误。
- 使用底层窗口录制 `temp/portal-phase40.avi`，截取两个时间点的哈希与画面均不同；最终帧保存为 `captures/portal-phase40-final.png`，门面流动、深度和视觉主次通过。
- 用户澄清目标是主角出生点整片初始场景，而非传送门单体；Phase 40 作为已完成的局部改造保留，开始 Phase 41 整屏构图重构。
- 再次确认先前仍把范围误缩成出生点周边空地；已删除未使用的局部捕获脚本，Phase 41 改为整张序章首图的整体美术迭代，等待范围确认后启动。
# 2026-09-01 Phase 41：整体迭代序章首张地图（进行中）

- 以现有路线截图审计完整序章首图，确认首要问题是道路、广场和山口地表的大形关系，而不是传送门局部或道具数量。
- 重塑 `VillagePath`、`VillageSquare`、`PortalPath`、`PondPath` 与 `MistPassPath` 多边形轮廓，收窄主路并减少机械十字和硬接缝。
- 增加四处村庄草地软回切与三段道路低对比磨损，复用现有 `_add_ground_patch()`，未增加地形框架或新依赖。
- 扩充冒烟测试，覆盖路径点数、南侧路宽、山口色相以及新增草地/磨损节点。
- `godot --headless --path . --script res://tests/smoke_test.gd`：`SMOKE TEST PASSED`；退出时仍有既有 ObjectDB/resource 清理警告。
- 用模型实际包围盒修正共享房屋构造：门扇横向补偿 `-0.515m`，窗框取消重复抬高并按墙面深度回收，三栋房同步生效。
- 药草圃扩为 `4.6 x 2.8m`（`12.88m²`）双畦，旋转后放在西侧房屋侧院；米拉巡游改为侧院入口到药圃边缘。
- 新增门、窗、窗光、药圃面积/位置/朝向和双畦结构契约；修正后冒烟测试再次通过。
- 最新隐藏录制 `captures/prologue-phase41b*.png` 证明门窗与药圃改善，但山口仍有长距离重叠道路造成的矩形接缝，继续缩短覆盖并让车辙跟随主路弯曲。
- 按用户反馈移除主路与三条支路的几何块方案，改用 Catmull-Rom 采样、可变宽 `ArrayMesh` 路带与透明土肩；车辙同步沿路弯曲并降低到 `0.38` Alpha。
- 药圃移到西侧房屋真正的侧院，主路不再与药圃争夺窄缝；增加从房门绕向药圃南缘的窄旧土步道，并将米拉巡游改到该动线。
- 巡游斜轴暴露原实现未归一化方向的问题；在 `_add_villager()` 唯一入口归一化，所有 NPC 的 `1.2m` 巡游距离语义保持一致。
- 平滑路带、车辙与斜向巡游契约通过；最新隐藏录制 `captures/prologue-phase41d*.png` 显示道路已连续弯曲，等待独立美术复审。
- 独立只读美术复审结论：房屋门窗 P0 通过、药圃尺寸与侧院位置 P0 通过、道路“几何块”问题通过；当前无剩余 P0。
- 最终具名画面：`phase41-road-final.png`、`phase41-herb-yard-final.png`、`phase41-village-final.png`、`phase41-mist-pass-final.png`；中间录制帧与音轨已清理。
- 最终验证：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED`、`git diff --check` 通过。
- Phase 41 保持进行中：广场仍是硬边大块赭色活动面；山口视觉 P1 未过，但按用户此前要求继续暂缓山口，下一轮优先处理广场与道路接口。
- 删除大面积 `VillageCommonGround`，四条生活支路收窄约 25%-40%，主路继续保留连续车辙，炉火、板车和门前仅使用局部软边磨损。
- 为道路网格补充可配置土肩宽度和端点 Alpha 渐隐；住宅/工作区小径土肩缩至 `0.25-0.32m`，传送门与雾池支路保留较宽层级。
- 南侧住宅支路起点延伸到主路内部，消除最后一处暴露的直切端头；最终画面保存为 `captures/phase41-road-final-herb.png`、`captures/phase41-road-final-hearth.png`、`captures/phase41-road-final-south.png`。
- 独立美术复审确认固定宽土肩、广场拼块、药圃连接、炉火活动区和南侧硬端头全部通过；生活气息审核也确认主路/小径/生活节点层级达到可接受线，当前道路整体通过。
- 场景动效审核完成首轮：传送门动效通过；村庄风摆、炉火烟气与 NPC 日常动作可感度列为下一轮 P1，不与本轮静态道路调整混改。
- 最终验证：`SMOKE TEST PASSED`、`git diff --check` 通过；Godot 退出时仍有既有 ObjectDB/resource 清理警告。
- 开始 Phase 41 生活气息与动效 P1：炉火从主路中心退到东屋侧面，托伦移到北侧入村主路，米拉让出药圃入口；新增炉火座位/柴箱、药草晾晒架/收获箱和织物晾晒线。
- 首轮隐藏录制确认炉火与守门人位置关系成立，但 CSG 方板长凳产生新的几何块感，药草架和织物线在目标机位可见度不足。
- 第二轮将长凳改为八边原木座面和木桩支脚，药草架改为三束倒挂草药并移至苗床外侧，织物线移到尼娅活动范围内。
- 植被加入低频区域错相阵风；三朵火焰使用不同频率/相位双波形，炉火灯改为较慢双波形；现有烟团增加每组漂移、尺寸和不透明度倍率，炉火烟更明显而不影响房屋烟。
- 生活节点结构、托伦巡游原点、烟倍率和火焰不同步契约加入 `tests/smoke_test.gd`；完整冒烟测试通过。
- 第二轮实机复审指出织物线横跨小径、规则布片像色卡，晒药架仍像空框；第三轮把织物线移到道路一侧，布片改为不等长下垂多边形，药架增加横绳与四束放大错落草药。
- 炉火基础从 `SphereMesh` 改为底宽顶尖的七点 `CSGPolygon3D` 火舌，保留已通过的异步位置/缩放和慢速灯光节奏；最终录像关闭球状火焰 P1。
- 三类独立复审结果：整体美术 P1 清零、生活关系 P1 清零、环境动效 P1 清零；药圃入口略紧和织物线标签局部重叠仅保留 P2。
- 托伦巡游收敛为 `0.65m` 半径、`0.45m/s` 短巡视，并在两端分别守望 `4.2s` 与 `6.0s`；专项行为契约与隐藏录像均完成。
- 最终静态证据：`captures/phase41-life-herb-final.png`、`captures/phase41-life-hearth-final.png`、`captures/phase41-life-weaver-final.png`；托伦节奏证据为三张 `phase41-toren-*.png`。
- 最终回归：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED`、`git diff --check` 通过。
- 托伦 4.45 秒专项录像由场景动效审核复判通过，原机械往返 P2 关闭；当前这批生活气息、静态美术与动效问题均已完成验收。
- Phase 41 计划状态已同步：道路、生活节点和环境/NPC 动效批次全部完成，开始收敛三栋房屋的纯白窗面。
- 三栋 `MI_WindowGlass` 改为低饱和暖棕玻璃；首轮复审关闭纯白洞口，但发现房屋淡出逻辑会把玻璃 Alpha 推到 `1.0`，导致大窗格被整块橙色填充。
- 新增 `house_fade_alphas` 记录各材质基础 Alpha，墙体仍恢复 `1.0`，窗玻璃恢复 `0.66`，靠近时按各自基础值同步淡出；冒烟测试覆盖三栋暖窗、低发光阈值、基础 Alpha、淡出与恢复。
- 最终隐藏录制证据为 `phase41-window-final-center.png`、`phase41-window-final-west.png`、`phase41-window-final-hearth.png`、`phase41-window-final-weaver.png`；美术与生活气息复审均确认纯白洞口、窗格层次、炉火主次和淡出悬浮亮块 P1 全部关闭。
- 最终回归：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED`、`git diff --check` 通过。
- 清理 25 个明确的中间录像/失败截图，保留道路、生活节点、托伦与窗户最终证据；未触碰用户已有 README 和导入元数据改动。
- 继续 Phase 41 整图风格审计：排除已过期的旧广场全景，当前以道路与暖窗最终机位重新评估建筑、生活关系和动效；三类专项审核代理已重新启动。
- 当前最高优先级 P1 确认为房屋避让的幽灵叠层；开始将遮挡逻辑从整栋所有材质收敛为仅屋顶木构/瓦面平滑淡出，立面、门窗、烟囱和生活道具保持实体。
- 首轮隐藏录制 `phase41-roof-only-*` 证明透明叠层消失，但屋顶下方露出兼任可见实体的整块碰撞箱顶面，且烟囱悬空；该版本不验收，继续拆分纯碰撞与无顶可见墙壳。
- 第二轮隐藏录制 `phase41-roof-shell-*` 确认无顶三面墙壳成立，烟囱随屋顶退场，门窗/药圃/炉火保持实体；织工捕获点需改到真实可达的房外位置，开顶绿色地面等待美术复审。
- 美术复审关闭原幽灵叠层 P1，并要求只补克制的暗暖棕室内地面；三栋房加入内缩无碰撞地板，织工捕获点移到东侧墙外真实可达位置。
- 第三版隐藏录制与四张最终机位完成；静态美术、室内外关系和生活动线复审已通过，进入/离开 12 帧接触表也确认屋顶/烟囱过渡连续，等待动效代理独立复判。
- 动效代理逐帧复判通过：屋顶/烟囱连续淡出恢复，墙体、门窗、NPC、炉火、传送门和环境动效均未受影响；房屋遮挡批次三类复审全部完成。
- 最终证据为 `phase41-roof-cutaway-final-herb.png`、`-hearth.png`、`-weaver.png`、`-center.png` 及两张 `phase41-roof-transition-*.png`；清理 11 个失败版截图和临时 AVI。
- 最终回归再次通过：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED`、`git diff --check`。Phase 41 保持进行中，下一轮处理板车车辕与支路方向关系，山口继续暂缓。
- 开始板车空间叙事 P1：首轮按整体 AABB 推断车辕为局部 `-Z` 并旋到 `-1.77rad`，但隐藏实机图显示车辕仍指向草地；改以可见几何确认车辕为局部 `+Z`，修正目标为 `+1.37rad`。两个卸货箱已移到车身后侧，碰撞盒收敛到车身/车轮范围。
- 复核第二版总览截图后确认方向修正成立，但板车被画面下缘裁切；在既有 `prologue_overview_capture.gd` 增加独立 `--wagon` 近景分支，玩家停在真实可达位置后暂停物理，只偏移既有相机支架完成取证。隐藏、非激活、底层 MovieWriter 录制 `temp/phase41-wagon-final.avi` 成功，Godot 退出码为 0。
- 最终候选录像为 1280×720、30fps、97 帧，抽取 `captures/phase41-wagon-final.png`；画面包含完整板车、支路、主路、卸货箱和可达玩家站位，已送交两类独立复审。
- 板车美术与生活逻辑复审均通过，P0/P1 清零；不处理小箱辨识稍弱的可选 P2。完整回归再次通过 `SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED` 与 `git diff --check`，开始排除山口后的 Phase 41 最终总体验收。
- 清理 8 个明确的板车中间产物：两轮旧 AVI、最终取证 AVI 和五张裁切/失败截图；保留 `captures/phase41-wagon-final.png` 作为最终证据。
- 排除山口与北侧雾幕后，整体美术、生活气息和场景动效三类最终总验收均通过，出生点到村庄范围无剩余 P0/P1；Phase 41 完成。山口仍作为独立待办暂缓。

# 2026-09-01 Phase 42

- 开始收敛出生点到村庄入口的连续舞台感；确认现有传送门与南侧道路截图来自不同阶段，先重录统一当前版本，山口继续排除。
- 隐藏、非激活、底层 MovieWriter 完成当前路线录像：1280×720、30fps、223 帧；已抽取石环、岔口和村庄入口三个同版本候选帧。石环本体通过，初步缺口集中在空前景与岔路视觉组织。
- 新增主路专用捕获站位，确认远端炉火已经承担进村暖色目标；双代理审计后将 Phase 42 实现收敛为一个低矮、无发光、无文字的村界阈值节点，其他留白保持不动。
- 在主路右侧肩外加入 `VillageBoundaryMarker`：复用低模岩石基座，搭配不到 1 米的旧木立柱与朝村内的短横臂；不使用碰撞、灯光、文字或第二门柱。冒烟测试新增位置、朝向、高度和无灯光契约并通过。
- 首轮实机图中短横臂与立柱投影重叠、读成弯木桩；第二版仅补三角木质箭头尖并略加粗木件，冒烟测试再次通过。当前从岔口与村口均可读且不挡路，等待代理判断是否过于 UI 化。
- 第二版双复审否决标准箭头造型；第三版删除完整木箭头，改为不对称旧界石和短木楔。最新岔口/入口实机帧已消除 waypoint 观感，保持低对比村界层级。
- 第三版最终证据为 `phase42-route-portal.png`、`phase42-marker-final-crossroads.png`、`phase42-marker-final-entry.png` 和 `phase42-marker-final-inside.png`；整体美术、生活气息和场景动效终审均通过，P0/P1 清零。
- 最终回归通过 `SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED` 与 `git diff --check`。清理 16 个明确的 Phase 42 中间录像和失败/过期截图，Phase 42 完成；山口继续暂缓。

# 2026-09-01 Phase 43

- 开始审计雾池支路的调查舞台感；新增三处真实可达的专用捕获站位，生产场景暂未修改，山口继续排除。
- 查看 `phase43-pond-baseline-approach.png` 与 `phase43-pond-baseline-shore.png`：两帧中雾池主体均被织工屋与红树冠压在左侧阴影内，支路终点更像住宅侧院而非独立调查舞台；生产场景仍未修改，等待第三个侧向站位确认根因。
- 查看 `phase43-pond-baseline-side.png`：侧向站位同样无法显露完整水面，确认问题来自雾池与住宅/大树的空间冲突。已提交美术、生活气息和动效三类只读专项复审；等待共同确认后再做单一最高优先级修正。
- 三类复审完成：动效通过；美术与生活气息均给出 P1，确认雾池当前更像织工屋侧院湿地而非独立调查节点。按单一最高优先级原则，仅将 `MistPond` 从 `(-10, 12)` 东移到 `(-7.8, 12)`，同步收短 `PondPath` 末段和三个捕获站位，并增加位置回归断言；未增加任何道具、光效或新系统。
- 改后冒烟测试通过，`git diff --check` 通过。首轮隐藏 MovieWriter 生成 `phase43-pond-east.avi` 且 Godot 退出码 0，但显式设置 `HWND_BOTTOM` 的 `Add-Type` 参数组合失败、隐藏进程未暴露 `MainWindowHandle`；该 AVI 仅用于快速检查，不作为最终验收证据。
- 从首轮改后 AVI 抽取接近/东岸画面：东移已让约三分之二水面连续可见，岸线与涟漪脱离主要阴影，构图改善成立；支路末端仍缺少可停留岸台，待第三帧确认后再决定是否采用生活审核的单一地面修正。
- 第三帧确认池体东移充分且无需扩张；复用 `_add_ground_patch()` 在东岸加入 `PondLookout` 软边磨损岸台，道路端点收回岸台中心。岸台约 `2.04×2.85m`、长边沿岸线，两块既有岸石自然分列开口两侧，未增加新道具。
- 岸台版冒烟测试与 `git diff --check` 通过。隐藏 MovieWriter 成功枚举 Godot 窗口句柄并设置 `HWND_BOTTOM`/`NOACTIVATE`，Godot 退出码 0；已抽取两张最终帧，确认岸台未产生新硬边块且东岸中央净空保留。
- 最终 `KAYKIT NPC VISUAL TEST PASSED` 与 `DRIFTER VISUAL TEST PASSED`。一次碰撞检索再次误用 Windows 通配路径，已改为明确目录配 `--glob` 并把同类错误计数更新为 2；正确检索确认玩家胶囊半径为 `0.45m`。
- 美术终审通过且 P0/P1/P2 均为 0：三视角水体可读约 60%～75%，岸线连续，住宅/树冠退为框景，`PondLookout` 没有形成圆盘或地毯式贴片。
- 生活气息终审通过且 P0/P1 为 0：支路、岸台、水面形成连续调查轴线，中央净空容纳玩家碰撞体，织工屋退为邻近生活背景。动效终审通过且 P0/P1 为 0；仅保留双涟漪节拍略规则的既有 P2。
- Phase 43 最终证据为 `phase43-pond-final-approach.png`、`phase43-pond-final-shore.png`、`phase43-pond-final-side.png` 与 `temp/phase43-pond-final.avi`；山口与北侧雾幕继续暂缓。
- 清理 `phase43-pond-baseline` 与 `phase43-pond-east` 的 2 个中间 AVI 和 6 张过期截图，保留最终三帧与最终 AVI。最终录像为 1280×720、30fps、130 帧、4.33 秒。
- 最终回归通过 `SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED` 与 `git diff --check`；Phase 43 完成。

# 2026-09-01 Phase 44

- 开始复审 Phase 43 后的完整出生路线；先重录石环、岔口、雾池与村口的同版本画面，山口与北侧雾幕继续排除，生产场景暂未修改。
- 隐藏、非激活、`HWND_BOTTOM` MovieWriter 完成当前路线基线录制，Godot 退出码 0；查看岔口与村口接近帧，确认三向选择成立，但岔口宽亮土路大形可能重新成为最高权重元素，等待越过帧与三类独立审核确认。
- 查看越过村口帧：生活节点和炉火层级成立，候选问题进一步收敛为主路在岔口与村内均保持约 `4m` 宽、浅亮且连续的地面大形。生产场景仍未修改，提交三类专项代理独立审核。
- 三类审核完成：美术/动效给出道路尺度 P1，生活审核将同项列为当前最高价值 P2。仅调整 `VillagePath` 现有半宽数组，使村内核心路面收至 `3.2-3.3m`、路口约 `3.5m`、入口渐变到 `3.7-4.0m`；增加生成网格最小/最大横截面宽度断言，其他场景节点保持不变。
- 首轮回归因 `PackedFloat32Array` 不提供 `.min()` / `.max()` 产生测试解析错误；改用 `minf()` / `maxf()` 单次遍历生成网格横截面，不改变生产实现。
- 修正后 `SMOKE TEST PASSED` 与 `git diff --check` 通过。隐藏、非激活、`HWND_BOTTOM` MovieWriter 完成收窄版路线录制，Godot 退出码 0；前两帧确认三向选择和支路接缝保持，主路两侧草地边界恢复。
- 用户补充角色资产偏大。临时 Godot 探针读取当前渲染高度：玩家 `2.173m`、米拉 `2.655m`、托伦 `2.543m`、尼娅 `2.180m`；统一 `0.86` 无法把不同源模型归一，下一步按统一目标视觉高度计算各自缩放并核对脚底/碰撞基准。
- 脚底探针确认玩家视觉随角色体悬高约 `0.96m`，NPC 接地正常。实现按实际包围盒归一：四名角色目标高度约 `1.70m`；玩家改为与 NPC 相同的根节点落地结构，胶囊中心统一 `y=0.8`。玩家/NPC 胶囊同步缩小并保持交互距离、速度、动画、标签字号与相机不变，冒烟测试增加绝对高度、缩放与碰撞契约。

# 2026-09-01 Phase 45

- Phase 44 道路收窄经美术、生活气息和动效三类终审通过，P0/P1 清零；用户新增的角色尺度问题独立进入 Phase 45。
- 四名角色已归一到 `1.695-1.704m` 视觉高度，玩家石台脚底与 NPC 地面脚底均通过运行时探针确认；`SMOKE TEST PASSED` 与 `git diff --check` 通过。新增四站位角色比例捕获分支，等待实机复验。
- 隐藏、非激活、`HWND_BOTTOM` MovieWriter 完成 Phase 45 四站位录制，Godot 退出码 0。尼娅与米拉帧确认门、织物线、药圃和板车比例恢复；姓名标签相对角色略宽，等待后两帧与专项审核判断。
- 查看托伦与村内总览帧：角色实体尺度继续成立，主路、板车、房屋和炉火层级保持；托伦姓名标签相对缩小后的身体过宽并出现边缘读不完整，提交三类专项代理终审。
- 三类首轮终审确认角色比例、接地、碰撞、通行和动画均通过，唯一共同问题是名牌偏大；只将 `IdentityLabel.pixel_size` 从 `0.012` 收到 `0.009`，同步冒烟测试断言。
- 修改后 `SMOKE TEST PASSED` 与 `git diff --check` 通过。使用隐藏、非激活、`HWND_BOTTOM` GUI MovieWriter 重录 `temp/phase45-character-label-final.avi`，1280x720、60fps、312 帧、5.2 秒；四张最终截图已按实际站位重新抽取，进入三类最终复判。
- 美术、生活气息与场景动效最终复判全部通过，Phase 45 范围 P0/P1/P2 清零；标签淡入淡出、Idle/Walk/PickUp、职业节点层级和相邻遮挡均通过。
- 最终回归：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED` 与 `git diff --check` 全部通过。Phase 45 完成，山口与北侧雾幕继续暂缓。
- 清理 5 个明确过期的中间证据：Phase 44 基线 AVI 与三张基线截图、Phase 45 旧标签版录像；保留四张角色最终截图和 `temp/phase45-character-label-final.avi`。

# 2026-09-01 Phase 46

- 继续按 `docs/art-direction.md` 迭代完整序章场景；先重录当前版本，再由美术、生活气息和动效三类代理独立寻找下一处 P1。山口与北侧雾幕继续排除，生产场景暂未修改。
- 隐藏、非激活、`HWND_BOTTOM` MovieWriter 完成当前六站位基线 `temp/phase46-scene-baseline.avi`，Godot 退出码 0；录像为 1280x720、60fps、432 帧、7.2 秒，已抽取六张同版本截图。初步候选是多处大块深色投影压过中景，尚未修改生产场景。
- 收到用户的六项画面与活世界优化草案后暂停 Phase 46 审计并完成只读对照：检查生产地表、道路、房屋覆写、光照与动态公式，查看草甸/道路/昼夜/生态 demo 实机输出，确认需要在执行前收紧美术、性能与可复现契约；未修改生产代码。
- 用户确认继续贴合既定美术风格，并补充天气系统允许随机；将天气记为时间系统后的独立固定种子日程，当前不扩入任务 1。Phase 46 转为待续，开始 Phase 47 地皮纹理单项实现。
- Phase 47 生产与测试首轮实现完成：地皮和道路改为独立生成器，地皮替换为固定种子的 128px 环绕软斑与保留暖冷色相的短草痕，UV 从 7 调至 24；道路纹理和 UV 保持原状。冒烟契约新增尺寸、接缝、暖冷像素占比、通道范围与确定性验证。
- Phase 47 隐藏后台 GUI 捕获完成 21 个固定机位，Godot 日志逐张输出 `SAVED`；首个带临时目录清理的启动命令被环境策略拒绝且未启动 Godot，随后改为按固定文件名直接覆盖，捕获成功。
- 人工复核近景、20 米远景、村庄全景和四角画面：绿色地皮无旧斜向条纹、接缝或远景摩尔纹，短草痕克制；道路仍使用旧纹理，留待任务 3。
- 三类专项复审完成：美术与动效 P0/P1/P2 清零，生活气息无 P0/P1，仅保留均匀短草痕的非阻断 P2，并转交任务 2 的分簇草甸验收观察。
- 最终验证通过：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED` 与 `git diff --check`；Godot 退出时仍只有既有 ObjectDB/resource 清理警告。
- 最终证据归档为 `captures/phase47-ground-final-portal-near.png`、`phase47-ground-final-portal-far.png`、`phase47-ground-final-village-far.png` 和 `phase47-ground-final-corner.png`。Phase 47 完成并停止，等待用户验收后再进入草甸系统。
- 用户要求三名子代理重新签字审核 Phase 47：美术与动效 P0/P1/P2 清零，生活气息 P0/P1 清零且仅保留均匀短草痕 P2；综合结论达到验收门槛，进入 Phase 48 草甸系统。
- Phase 48 读取已验证 demo、当前八条道路、三处生活节点和草资产结构；确认仅复用单个 MultiMesh、现有资产与独立 Shader，密度与排除均由固定种子和当前场景坐标驱动。
- Phase 48 首轮生产实现加入 `MeadowGrass` MultiMesh、独立 Shader、固定种子低频密度、道路线段距离排除和生活节点硬排除；完整冒烟测试最终通过。headless MultiMesh 变换/颜色 getter 返回默认值，契约改验节点保留的原始固定种子布局与颜色，实际上传由 GUI 画面验证。
- 首轮 21 机位 GUI 扫查证明草甸上传和排除区成立，但整体过密、过高、过深，视觉形成均匀草毯；该版本不验收，进入第二轮尺度、颜色和密度阈值收敛。
- 第二轮把草株降至 `0.20-0.34` 缩放并用低频阈值形成空地/草簇，21 机位确认分簇和主路肩密度关系成立；放大图发现草色仍近黑，定位为源网格 `COLOR_0` 与实例 `COLOR` 混合，第三轮仅将亮度抖动迁移到 `INSTANCE_CUSTOM.r`。
- 第三轮 `INSTANCE_CUSTOM.r` 契约与冒烟测试通过，但 21 机位放大图中双面草片仍受侧向/背向漫反射压暗；第四轮只增加 20% 同色环境提亮，不改分布与尺度。
- 第四轮最新 21 机位由美术、生活气息和动效代理独立复审，三方均判定 Phase 48 不通过：合并阻断为草色/受光、连续路肩草带、远景高频和 NPC 活动区留白四项；比例、主要排除区和山口疏密方向通过。
- 开始第五轮最小根因修正：双面草片按朝向翻转法线，emission 从 `20%` 降至 `4%`；草甸在 `20-34m` 连续缩退；村庄基础簇降密，主路肩改为固定种子低频门控的间歇 `6-8株/m²`；晾衣区、尼娅活动圈和托伦巡逻圈加入踩踏留白。同步扩充冒烟契约，Phase 48 保持进行中。
- 第五轮首次冒烟在实例数量下限断言失败；测试进程按精确 PID 结束，未留下本轮后台会话。保留数量契约并加入实际数量错误消息，下一次结果用于校准分簇覆盖率，不以删除断言绕过。
- 固定种子第五轮实际生成 `1153` 株；高密簇仍由独立密度与路肩疏密断言约束，因此将仅用于防空上传/失控总量的全局范围校准为 `1000-7000`，不恢复已被视觉审核否决的连续高覆盖率。
- 第二次冒烟继续在旧村庄总量 `>900` 处失败；为村庄与路肩断言补入实际计数消息，先读取固定布局真值，再以“村庄存在足量簇、路肩同时存在断口与高密段”的组合契约校准。
- 固定布局有 `799/1153` 株位于村庄范围，村庄占比约 `69%`；将村庄总量护栏校准为 `>750`，继续保留全局、排除区、单簇密度和路肩双峰契约。
- 第五轮完整冒烟输出 `SMOKE TEST PASSED`，随后隐藏后台重录 21 机位，所有截图写入 `temp/grass-sweep/`；GUI 仍只在退出时报告既有 RID/resource 清理警告。
- 人工复核代表机位确认黑线、异常自发光、连续路肩和生活区穿插已解决，但草甸整体过淡、过疏且远景过早消失。Phase 48 不提交复审，进入第六轮小幅回调可见距离、草色与簇覆盖率。
- 第六轮仅回调现有参数：几何缩退改为 `26-42m`，草叶线性明度收至 `0.36-0.50`、emission 收至 `3%`，簇阈值由 `0.54-0.70` 微调到 `0.52-0.69`；法线翻转、路肩门控和生活区排除保持不变。
- 第六轮冒烟通过，但首轮隐藏扫查证据失败：哈希证明 `03-21` 为同一停滞帧。记录为捕获错误；只清理精确匹配失败 smoke_test 的遗留 headless 进程，保留用户要求的后台试玩 PID `19276`，随后重录并验证唯一哈希数。
- 用户纠正草量方向：不是减少草甸，而是避免均匀暗色草毯。已精确结束 11 个仅匹配失败 `smoke_test.gd` 命令行的遗留进程，后台试玩 PID `19276` 保留；簇覆盖扩大并把全图/村庄实例下限恢复为 `>1600/>1100`，继续由路肩双峰和硬排除契约控制自然节奏。
- 恢复草量后的完整冒烟再次输出 `SMOKE TEST PASSED`；隐藏后台重录 21 机位成功，`IMAGE_COUNT=21`、`UNIQUE_HASHES=21`。代表帧确认灰绿草簇、间歇路肩和 NPC 活动留白方向成立，继续补查远景与动态证据。
- 复核传送门远景、尼娅生活区和四角站位，未见远景摩尔纹或重新形成连续草墙；新增独立 `tests/grass_motion_capture.gd`，用同一站位近/远镜头各录固定间隔 A/B 帧，只作为风摆验收证据。
- 隐藏运行动态捕获成功，`near-a/b` 与 `far-a/b` 四张均保存且哈希互异；人工对照可见近景错相轻摆、远景衰减成立，未见同步草浪。进入角色视觉回归与三类最终复审。
- 第六轮完整回归通过：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED` 与 `git diff --check`；当前只保留用户要求的后台试玩 PID `19276`，提交三类代理终审。
- 三类最终复审全部通过：生活气息与动效 P0/P1/P2 清零；美术 P0/P1 清零，仅保留远景单一草模型重复感 P2，并明确后续用形态变体而非减草处理。
- 最终静态证据归档为 `captures/phase48-grass-final-portal.png`、`phase48-grass-final-road.png`、`phase48-grass-final-village.png`、`phase48-grass-final-herb.png`；动态 A/B 归档为 `phase48-grass-motion-near-a/b.png` 与 `phase48-grass-motion-far-a/b.png`。Phase 48 完成，停止等待用户验收，不进入任务 3。

# 2026-09-01 Phase 49

- 用户授权后续项目自行检验并在通过后连续执行。Phase 49 道路提案开始；保留后台试玩 PID `19276`，所有新增 Godot 验证继续隐藏静默运行。
- 完成道路实现边界审计：只修改纹理生成、正式路面横截面、车辙参数和路缘碎石；道路中心线、宽度、土肩渐隐、通行碰撞与 Phase 48 草甸分布不动。
- 完成首轮实现与契约同步：道路纹理改为固定种子 128px 土斑/纵向短痕/石点；正式路面增加三列横截面与中心磨损；车辙更新为 `0.14m/0.42 Alpha`；九条道路生成固定种子 Quaternius 路缘碎石组。
- 首轮隐藏冒烟因 `road_arrays` 无法推断类型而在测试脚本解析阶段退出，生产场景尚未加载；为局部变量补充明确 `Array` 类型，并将纹理短痕横向像素偏移显式取整后重跑。
- 第二轮冒烟进入场景后在中道顶点色精确比较处失败；Godot 网格颜色量化后约为 `0.9294`。保留 `0.93` 契约，改为窄范围 RGB 校验并要求三列 Alpha 一致，以兼容既有渐隐端点。
- 第三轮冒烟到达道路纹理暖冷像素统计，预设阈值未命中；先为暖、冷、深色细节断言加入实际计数诊断，再按固定种子结果校准，不删除纹理内容契约。
- 固定种子道路纹理真值为暖偏 `131`、冷偏 `1632`；将双向色偏护栏校准为各 `>100`，保留低饱和冷偏占优以压住土路橙黄，并继续验证深色细节、接缝和确定性。
- 第四轮完整隐藏冒烟输出 `SMOKE TEST PASSED`；退出时只有既有 Dummy 渲染资源清理告警。以 `captures/phase48-grass-final-road.png` 作为改前基线，确认规则波纹、单一浅黄和几何色带感均清晰可见。
- 隐藏 Compatibility 扫查完成，21 个机位全部保存且 SHA-256 唯一数为 21；代表帧确认道路纹理、中心磨损、车辙和路缘碎石生效，Phase 48 草量与活动区留白保持不变。
- 近景、远景与传送门侧补查未见道路摩尔纹、闪烁证据或新遮挡；随后角色视觉回归和 `git diff --check` 全部通过，Phase 49 已提交三个既有专项子代理终审。
- 首轮终审结果：生活气息 `PASS P0/P1/P2=0/0/1`，动效 `PASS 0/0/1`，美术 `FAIL 0/2/1`。阻断项收敛为连续等宽车辙和均匀高密短痕；进入第二轮最小修正。
- 第二轮将短痕从 `260` 收至 `96`；车辙保留 `0.14m/0.42 Alpha`，启用顶点色，以三段平滑缺口、左右错位和端点淡出打破连续贴条。同步增加车辙 Alpha 动态范围契约。
- 第二轮冒烟输出 `SMOKE TEST PASSED`，隐藏重录 21 机位再次得到 `IMAGE_COUNT=21`、`UNIQUE_HASHES=21`；人工复核确认车辙已断续错位、路面安静区增加，提交三类最终复审。
- 第二轮三类最终复审全部 `PASS`，P0/P1 清零；四张代表证据归档为 `captures/phase49-road-final-pond-fork.png`、`phase49-road-final-mid.png`、`phase49-road-final-village.png`、`phase49-road-final-north.png`。Phase 49 完成并自动进入 Phase 50。

# 2026-09-01 Phase 50

- 建筑材质统一开始。范围锁定为三栋房屋屋顶资源的 `MI_WoodTrim` 山墙和 `MI_RoundTiles` 屋瓦覆写；保持房屋布局、门窗、碰撞和现有屋顶淡出机制不动。
- 使用确定性 FFmpeg 调色生成 2048x2048 派生屋瓦贴图 `T_RoundTiles_BaseColor_Muted.png`，未覆盖原素材；接入 `MI_WoodTrim` 暖灰米乘色和 `MI_RoundTiles` 派生贴图分支，并增加逐栋材质、贴图统计与基础 Alpha 契约。
- Phase 50 首轮冒烟在屋瓦平均饱和度降幅预设处失败；三栋材质分支、派生贴图路径和尺寸此前均通过。为原/新 HSV 平均值补诊断，先读取 Godot 采样真值再决定是否重新调色。
- 临时 Godot 像素采样确认 `.45/-0.04` 饱和度候选接近目标但明度过低；继续只在 `temp/` 比较 `.48` 饱和度与两档正亮度补偿，最终只保留一张正式派生贴图。
- 完成派生贴图参数夹逼并选择 `.70/+0.06`：Godot HSV 平均值 `0.5341/0.6714`，原图为 `0.7334/0.6989`。正式贴图已覆盖为该候选并后台重新导入，人工检查未见纹理结构损失。
- Phase 50 完整冒烟输出 `SMOKE TEST PASSED`；三栋山墙/屋瓦材质、派生贴图统计和 `house_fade_alphas` 基础值契约全部通过，进入 21 机位真实渲染扫查。
- Phase 50 隐藏 Compatibility 扫查完成，`IMAGE_COUNT=21`、`UNIQUE_HASHES=21`；三栋房屋远近景和切顶机位未见纯白山墙、瓦面抢过炉火、贴图损坏或淡出恢复回归。
## 2026-09-01 Phase 50 完成

- `scripts/main.gd`：三栋屋顶山墙统一为墙体同族暖灰米色，屋瓦替换为低饱和派生贴图，同时保留原 StandardMaterial3D 属性与逐材质淡出链。
- `assets/quaternius/village/T_RoundTiles_BaseColor_Muted.png`：固定派生瓦片贴图，Godot HSV 平均值由 `0.7334/0.6989` 调整为 `0.5341/0.6714`。
- `tests/smoke_test.gd`：覆盖三栋山墙/屋瓦、贴图尺寸与 HSV 差异、屋顶基础 Alpha 和切顶恢复契约。
- 验证：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED`、`git diff --check` 通过；21 张扫查图为 21 个唯一哈希。
- 三类终审：美术 `PASS P0/P1/P2=0/0/1`，生活气息 `PASS 0/0/0`，动效 `PASS 0/0/2`；所有阻断项清零，进入 Phase 51。

## 2026-09-01 Phase 51 完成

- `scripts/main.gd`：落地 30 分钟一昼夜的 11 关键帧连续曲线，联动太阳/月光、环境、雾、背景、阴影及炉火、窗光、传送门、雾灯菇和山口符石。
- `shaders/portal_surface.gdshader`：新增可由时间系统驱动的 `time_glow`，保留调查反应参数。
- 夜间玩家增加只照角色层的相机同向 `SpotLight3D` 补光，地面与道路不受影响；18 个主场景捕获脚本全部显式锁定 `time_hour` 和 `time_running=false`。
- 验证：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED`、`git diff --check` 通过；21 张扫查图均为唯一哈希，8 个定点时刻截图成功。
- 三类终审：美术 `PASS P0/P1/P2=0/0/1`，生活气息 `PASS 0/0/0`，动效 `PASS 0/0/1`；P0/P1 清零，自动进入 Phase 52。

# 2026-09-01 Phase 52

- 开始分时生态系统：复用可控 `portal_time` 和 `time_hour`，新增固定种子 `3131/6262` 的 7 只蝴蝶与 14 只萤火虫，不改草量、道路或互动布局。
- 蝴蝶按 `7:00-19:00` 平滑显隐并活动于村庄草甸；萤火虫按 `19:30-5:30` 平滑显隐并活动于两侧林缘低空草丛。两组均复用共享程序化纹理、网格和材质。
- 新增数量、种子、共享材质、时间曲线、动态位移、道路和功能区净空契约；首轮冒烟只暴露测试时钟比较同一时刻，已明确改为 `0s→1s`。
- 首轮终审：生活气息 `PASS 0/0/0`，动效 `PASS 0/0/1`，美术 `FAIL 0/1/1`。阻断项仅为蝴蝶单帧轮廓语义不足；保持生态参数不变，收窄翼形并加强中央身体、翼缝和前后翼明暗差。

## 2026-09-01 Phase 52 完成

- `scripts/main.gd`：新增固定种子 `3131/6262` 的 7 只日间蝴蝶与 14 只夜间萤火虫，复用共享程序纹理/网格/材质和现有可控时间变量。
- `tests/smoke_test.gd`：覆盖数量、种子、尺寸、活动窗、平滑边界、昼夜互斥、动态位移、色相以及道路/房屋/炉火/药圃/传送门净空。
- `tests/ecosystem_capture.gd` 与 `captures/phase52-*`：固定时刻、固定机位的昼夜与 A/B 动态证据；最终 21 机位 `IMAGE_COUNT=21`、`UNIQUE_HASHES=21`。
- 验证：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED`、`git diff --check` 通过。
- 三类终审：美术 `PASS 0/0/1`，生活气息 `PASS 0/0/0`，动效 `PASS 0/0/1`；P0/P1 清零，自动进入 Phase 53 随机天气。

# 2026-09-01 Phase 53

- 新增固定种子 `20260902` 的 13 段天气日程，覆盖晴、阴、薄雾、小雨；各状态有 3-5 小时以上最短持续时间，并在末尾 `0.75` 游戏小时平滑过渡。
- 天气复用现有昼夜采样调制太阳、环境、阴影、雾和背景，不覆盖炉火、窗光、传送门、雾灯菇及角色夜间补光。
- 小雨使用 28 条固定种子、共享网格/材质的低透明雨线跟随玩家，位置连续回绕，不引入粒子系统、外部依赖、雨声或积水框架。
- 所有 19 个当前捕获脚本显式锁定天气种子、停止天气日程并指定状态；旧捕获锁定 `clear`，新增 `tests/weather_capture.gd` 覆盖四种天气与日/夜雨 A/B。
- 完整冒烟、两项角色视觉回归和 `git diff --check` 通过；锁定晴天的 21 机位再次得到 `IMAGE_COUNT=21`、`UNIQUE_HASHES=21`。

## 2026-09-01 Phase 53 完成

- `scripts/main.gd`：固定种子随机天气日程、连续状态过渡与 28 条低透明玩家跟随雨线完成，并保持全部叙事光源独立。
- `tests/smoke_test.gd`：天气种子、日程、持续时间、过渡、环境调制、雨线共享资源与净空契约通过。
- `tests/weather_capture.gd` 与 `captures/phase53-weather-*`：四类天气、昼夜雨 A/B 和药圃昼雨共 7 张固定时间/固定天气证据，`IMAGE_COUNT=7`、`UNIQUE_HASHES=7`。
- 验证：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED`、晴天 21 机位 `21/21` 唯一哈希，`git diff --check` 通过。
- 三类终审：美术 `PASS 0/0/1`、生活气息 `PASS 0/0/1`、动效 `PASS 0/0/1`；P0/P1 清零，Phase 53 完成。

# 2026-09-01 Phase 54

- 三类代理对当前完整场景独立复审后，美术与动效分别确认房屋全向完成度、切顶空盒和雨线穿室内为 P1；开始在同一房屋边界内做最小修正。
- 尼娅傍晚炉火作息作为独立生活气息 P1 排入 Phase 55，本阶段不扩展 NPC 行为。

## 2026-09-01 Phase 54 完成

- 三栋房屋侧后墙补齐石基、木梁与背窗，切顶室内增加深暖灰地面、地毯、长凳和木箱；屋顶近距离端态由完全消失改为 `0.22` 淡影。
- 28 条雨线按三栋旋转房屋本地范围逐条遮蔽，半宽 `3.15m`、边缘过渡 `0.55m`；屋外雨量、速度、数量与天气日程不变。
- 验证：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED`、21 机位 `21/21` 唯一哈希、专项证据 `7/7` 唯一哈希。
- 三类终审：美术 `PASS 0/0/1`、生活气息 `PASS 0/0/0`、动效 `PASS 0/0/0`；P0/P1 清零，自动进入 Phase 55。

# 2026-09-01 Phase 55

- 开始为尼娅增加最小固定作息；仅复用现有角色、动画、昼夜和天气状态，不创建通用日程框架。

## 2026-09-01 Phase 55 完成

- `scripts/main.gd`：尼娅 `06:30-18:30` 保留织工巡游，`18:30-22:30` 前往炉火；雨天转到东屋门廊，`22:30` 后回屋隐藏，清晨恢复原巡游。
- 炉火与门廊之间使用约 3 米短线直接互切；雨天终点定为 `(8.6, 0.0, -4.2)`，避开深色门洞并保持门前通行。
- `tests/smoke_test.gd` 与 `tests/nia_routine_capture.gd`：覆盖日间、黄昏、夜间、雨天、交谈优先级及天气切换路线；四张证据 `4/4` 唯一哈希，21 机位 `21/21` 唯一哈希。
- 验证：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED`、`git diff --check` 通过；只保留后台试玩 PID `19276`。
- 三类终审：美术 `PASS 0/0/0`、生活气息 `PASS 0/0/0`、动效 `PASS 0/0/1`；P0/P1 清零，P2 仅为缺少完整回屋与清晨恢复录像。
- Phase 55 后三类代理独立提名下一项，结果一致为 `P0=0、P1=0`；当前阶段进入稳定验收状态，当时暂停自动扩展，但不永久冻结后续美术迭代。

# 2026-09-02 Phase 56

- 用户明确要求继续按现有美术风格迭代；开始审计非叙事植被的焦点层级。
- 修正规划门禁：P0/P1 清零只代表当前阶段验收通过；用户要求继续时，允许从 P2 中选择一个符合规范、收益明确的独立精修项。
- 已定位高饱和红叶来自普通 `Bush_Common` 的原始 `Leaves_TwistedTree` 材质；阶段范围锁定为材质收敛，不改草量、布局、动效和叙事光源。
- `docs/art-direction.md` 升级到 0.3：取消高饱和对象绝对白名单，改为主焦点、次级环境点缀和大面积底色的层级规则；红叶保留与否改由实际构图审核决定。
- 三类审核一致确认红叶为当前最高收益的单一 P2 精修，且没有更高收益的 P1；保留红叶季节性，只校准其注意力层级。
- 新增 `Leaves_TwistedTree_C_Muted.png` 派生纹理；3 个 `Bush_Common` 使用各自材质副本，保持 Alpha scissor、双面、粗糙受光、无自发光和原 CPU 风摆。
- `tests/smoke_test.gd` 新增实例数量、材质独立性、贴图路径、透明边缘、尺寸、饱和度和明度契约；第二版候选输出 `SMOKE TEST PASSED`。
- `tests/seasonal_foliage_capture.gd` 固定种子、时刻和天气，完成晴天 A/B、日落与夜雨 4 张证据，`IMAGE_COUNT=4`、`UNIQUE_HASHES=4`。

## 2026-09-02 Phase 56 完成

- 21 机位隐藏扫查 `IMAGE_COUNT=21`、`UNIQUE_HASHES=21`；普通灌木统一调色，红叶乔木保持原季节锚点。
- 完整验证：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED`、`git diff --check` 通过。
- 最终证据归档为 `captures/phase56-foliage-*` 共 6 张，包含晴天风摆 A/B、日落、夜雨、村庄远景和季节锚点，`6/6` 唯一哈希。
- 三类终审：美术 `PASS 0/0/0`、生活气息 `PASS 0/0/0`、动效 `PASS 0/0/0`；Phase 56 完成。

# 2026-09-02 Phase 57

- 用户确认旧高饱和绝对白名单不合理；`docs/art-direction.md` 0.3 的三级色彩层级继续作为唯一美术权威。
- 开始评估轻雨下露天炉火的克制天气响应；范围锁定为复用现有雨量、炉火、烟雾和点光变量，不增加系统、不改天气日程或尼娅作息。
- 已向美术、生活气息和场景动效三个现有专项代理发起只读优先级审核；动效审核先返回 `GO / P1=1`，确认晴雨完全一致是当前最小可信度缺口。
- 三类代理均返回 `GO`；按共同建议在 `_process()` 内加入连续雨量倍率，没有新增 helper、状态机、随机源、素材或依赖。
- `tests/smoke_test.gd` 已同步晴雨火焰、烟雾、点光、余烬/火焰发光与传送门独立性契约；新增 `tests/hearth_weather_capture.gd` 固定昼夜、天气、相位、角色和相机。
- 首轮完整冒烟输出 `SMOKE TEST PASSED`；退出时仅有既有 Dummy 渲染资源清理提示。
- 隐藏 Compatibility 专项捕获成功生成 5 张固定证据，`IMAGE_COUNT=5`、`UNIQUE_HASHES=5`；夜间晴/雨同相位人工对照确认炉火主焦点保持。
- 人工复核发现首张昼晴图仍带开场地点标题；已在捕获脚本中显式隐藏 `Opening`，首轮图片不作为最终证据，准备同条件重录。
- 隐藏重录再次得到 `5/5` 唯一哈希；昼间晴/雨、夜间晴/雨及夜雨 A/B 人工复核均通过，未见熄火、色相漂移、暖光范围回归或火焰静止。
- 隐藏运行 21 机位全场景扫查成功，`IMAGE_COUNT=21`、`UNIQUE_HASHES=21`；人工抽查炉火近景和村庄远景通过。
- 角色视觉回归通过：`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED`。

## 2026-09-02 Phase 57 完成

- 轻雨只连续调制露天炉火：满雨量火焰高度/位移 `0.88`、点光 `0.92`、火焰发光 `0.94`、余烬 `0.96`、炉火烟可见量 `0.80`、烟漂移 `1.10`；房屋炊烟、色相、光照范围、天气日程和尼娅作息不变。
- 最终证据归档为 `captures/phase57-hearth-*` 共 5 张，固定昼夜、天气、`portal_time`、角色和镜头，`5/5` 唯一哈希。
- 完整验证：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED`、21 机位 `21/21` 唯一哈希。
- 三类终审：美术、生活气息、动效均为 `PASS 0/0/0`；Phase 57 完成。

# 2026-09-02 Phase 58 候选复审

- 目标继续保持为按 `docs/art-direction.md` 0.3 迭代序章场景；当前工作树以已推送提交 `02f5fc7` 为基线。
- 已向美术、生活气息和动效三个现有专项代理发起下一项单一提名，明确排除山口、草量减少、新资产包和新系统。
- 人工总览最新 21 机位，先记录近距离屋顶淡出叠线为候选，等待三方优先级结论后再决定是否建立 Phase 58。
- 三类提名已返回：屋顶透明叠层与雾池水波循环均为 P1，三户身份差异为 P2。Phase 58 选择先处理直接影响角色/活动区可读性的屋顶 P1，雾池水波留作后续独立阶段。
- 范围锁定为现有屋顶淡出端态、冒烟契约和固定近屋证据；不改房屋结构、室内布局、草量、天气、NPC 或山口。
- 首轮实现将近屋目标 Alpha 从 `0.22` 收至 `0.0`，保留原有平滑插值；冒烟契约新增进入/离开中间态、近景完全隐藏、远景恢复及非目标房屋不变。
- 扩展现有 `tests/roof_fade_capture.gd`，固定时刻/天气并覆盖炉火屋、药圃屋、西屋切顶和村庄全屋顶恢复四张证据。
- 完整冒烟输出 `SMOKE TEST PASSED`；首轮隐藏 Compatibility 捕获 `IMAGE_COUNT=4`、`UNIQUE_HASHES=4`。
- 人工复核确认生产效果通过，但药圃屋/西屋捕获站位落在侧墙后；已仅调整证据站位到两栋正门前，准备重录。
- 第二轮正门站位仍因反向相机 yaw 把玩家放到背墙后；最终捕获仅将两张 yaw 归零，从正门方向重录。

## 2026-09-02 Phase 58 完成

- `scripts/main.gd`：近屋屋顶目标 Alpha 从 `0.22` 收至 `0.0`，保留原有 `delta * 5.0` 平滑进入与恢复；墙壳、室内、家具、门窗和碰撞不变。
- `docs/art-direction.md` 升级到 0.4，明确最新规范效力、切顶完整隐藏和“疏密不等于减草”。
- `tests/smoke_test.gd` 使用 `1/60s` 连续帧验证进入、反向、淡出和恢复；`tests/roof_fade_capture.gd` 固定时刻与天气覆盖三屋切顶和村庄恢复。
- 验证：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED`；21 机位 `21/21` 唯一哈希，专项证据 `4/4` 唯一哈希。
- 证据归档为 `captures/phase58-roof-*` 四张。三类终审 P0/P1 清零；美术只保留距离触发语义 P2，Phase 58 完成并进入 Phase 59 雾池水波连续性修复。

## 2026-09-02 Phase 59 完成

- `scripts/main.gd`：雾池波纹透明度改为首尾消隐、中段渐显的连续正弦包络；保留两枚波纹的缩放、位置、材质与半周期错相。
- `tests/smoke_test.gd`：新增 `fmod` 回绕两侧与周期中点的确定性透明度契约；`tests/pond_ripple_capture.gd` 固定昼间晴天、镜头和 `portal_time` 录制三张 A/B 证据。
- 隐藏 Compatibility 捕获：专项 `IMAGE_COUNT=3`、`UNIQUE_HASHES=3`；21 机位 `IMAGE_COUNT=21`、`UNIQUE_HASHES=21`。
- 完整回归：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED`、`git diff --check` 通过。
- 证据归档为 `captures/phase59-pond-*` 五张。三类终审 P0/P1 清零；美术只保留峰值波纹多边形感 P2，Phase 59 完成。

# 2026-09-02 Phase 60

- 当前提交 `668000f`、工作树和后台试玩进程均已复核；继续以 `docs/art-direction.md` 0.4 为唯一权威，排除山口、减草、新资产包和新系统。
- 三类代理重新提名后，Phase 60 选择修复屋顶无意义切除 P1；三户室内同模和波纹峰值几何感保留为后续 P2。
- 首轮实现保留原淡出链，在 6 米距离条件上增加相机到玩家的二维遮挡带判断；冒烟和专项捕获同步改为三屋正反镜头 A/B。
- 首轮冒烟在解析阶段发现测试作用域已有 `camera_rig`；生产场景尚未加载，新增测试变量已改名为 `roof_camera_rig`。
- 第二轮屋顶断言通过，但测试未恢复玩家位置导致后续 NPC 标签断言失败；已结束两个残留无头测试进程，保留试玩 PID `51896`，并在屋顶契约末尾恢复玩家到远处。
- 第三轮确认零时长更新不会推进已显示标签的淡出；恢复步骤改为 1 秒真实更新，仍不改变生产代码。
- 1 秒清理虽然恢复标签，却改变了末段 NPC 动效基线；测试收尾已重构为保存/恢复 `portal_time` 并直接复原标签状态，彻底隔离屋顶契约的时间副作用。
- 隔离后的完整冒烟输出 `SMOKE TEST PASSED`；XZ 线段增加零长度保护后再次通过。
- 隐藏 Compatibility 专项捕获完成，`IMAGE_COUNT=7`、`UNIQUE_HASHES=7`。三处正面/活动区完整屋顶和三处反向切顶均生效，远景恢复正常。
- 隐藏 21 机位扫查完成，`IMAGE_COUNT=21`、`UNIQUE_HASHES=21`；炉火活动区和西屋普通近景保持完整屋顶，药圃斜向实际遮挡仍正确切顶，远景村庄轮廓无回归。

## 2026-09-02 Phase 60 完成

- `scripts/main.gd`：保留 6 米近屋初筛和 `delta * 5.0` 平滑过渡，新增相机到玩家 XZ 视线遮挡带与零长度保护；只有房屋确实位于镜头和玩家之间时才切顶。
- `docs/art-direction.md` 升级为 0.5：单纯靠近、站在门前、炉火旁或房屋侧面不再构成切顶条件。
- `tests/smoke_test.gd` 与 `tests/roof_fade_capture.gd`：覆盖三屋正常完整、反向遮挡切顶、恢复、非目标房屋和窗玻璃隔离，并隔离测试时间与标签状态。
- 专项证据 `7/7`、全场景扫查 `21/21` 唯一哈希；三类终审均通过且 P0/P1 清零，实体墙真实遮挡只保留为生活气息 P2。
- 最终回归：`SMOKE TEST PASSED`、`KAYKIT NPC VISUAL TEST PASSED`、`DRIFTER VISUAL TEST PASSED`、`git diff --check` 通过；Godot 退出仅保留既有 DummyRenderer 资源清理告警。

# 2026-09-02 Phase 61 候选复审

- 从干净提交 `ff065a6` 继续迭代；重新读取 0.5 美术规范、规划记录和当前运行进程，不沿用未复核的旧候选结论。
- 三类现有专项代理已并行进行只读提名；人工先核对炉火屋与药师屋当前实图，记录三户室内同模为候选，不修改生产场景。
- 三类提名完成：动效审核发现雾池 16 边波纹为 P1，美术与生活审核的室内同模为 P2；Phase 61 先收圆波纹，范围锁定为一个共享网格参数及其契约。
- 首轮误将 `TorusMesh.ring_segments` 从 `16` 提升到 `32`；冒烟契约虽通过，但后续实图证明该参数只细分管截面，已在同阶段纠正且没有作为完成结果保留。
- 首轮完整冒烟输出 `SMOKE TEST PASSED`；沿用旧脚本的三张图为 `3/3` 唯一哈希，但人工 A/B 发现中景波纹过小且受树冠遮挡，证据不足，准备强化专项捕获而非直接通过。
- 专项脚本扩展为回绕前后、岔口峰值、玩法近景峰值和 7 米细节峰值共 5 张；只调整测试相机与固定站位，不修改生产布局。
- 强化后专项 5 张虽为唯一哈希，但 21 机位 `04-pond-fork` 在更大波纹相位仍暴露十二边形；阶段未通过。已纠正 TorusMesh 参数语义：主环改为 `rings = 32`，截面恢复 `ring_segments = 16`。
- 第二轮专项补充 `portal_time = 4.0` 的岔口与 7 米细节大尺寸轮廓图，与 `2.5` 的最高可见度图共同覆盖最差几何状态。
- 第二轮专项捕获 `7/7` 唯一哈希；`fork-large` 与 `detail-large` 人工复核通过，准备重新执行 21 机位并复查原失败帧。
- 第二轮 21 机位完成，`IMAGE_COUNT=21`、`UNIQUE_HASHES=21`；原失败的 `04-pond-fork` 与近景 `05-pond-close` 人工复核通过，提交三类终审。

## 2026-09-02 Phase 61 完成

- `scripts/main.gd`：雾池两枚波纹共享 `TorusMesh.rings` 从 `12` 提升到 `32`，`ring_segments` 保持 `16`；周期、材质、发光、位置、缩放、透明包络和错相均不变。
- `tests/smoke_test.gd`：锁定主环分段、截面分段和共享网格，并继续覆盖 Phase 59 的回绕连续性。
- `tests/pond_ripple_capture.gd`：固定最高可见度、大尺寸相位、玩法岔口、10 米近景、7 米细节和回绕前后，共 7 张证据。
- 验证：`SMOKE TEST PASSED`、专项 `7/7`、21 机位 `21/21` 唯一哈希、两项角色视觉回归和 `git diff --check` 通过；三类终审全部 `PASS 0/0/0`。
