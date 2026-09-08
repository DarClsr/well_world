# 山海探索宝箱 v1

独立源文件：`v1/Ancient_Wood_Jade_Chest.blend`。打开即可预览；向其他场景 Link / Append 时只选择 `Ancient_Wood_Jade_Chest` Collection，不选 `Preview_Stage`。

箱体约 1.28 × 0.81 × 0.83 米，独立中空箱体与铰链箱盖。旧木、暗铜、玉环以及呼应狌狌的白耳兽面，配原创山形水纹；不是《山海经》原文中某件器物的复原。

动画时间线：帧 1–20 关闭，20–55 开盖，55–85 保持，110 回到关闭。玉饰微光、两道上升青玉光纹、三组山形符纹、24 个金色光屑和箱内暖光随开盖显现、消退。细微光晕来自 Blender 合成器，特效物体集中于 `Chest_Opening_FX` 层级，箱内灯为 `Chest_Interior_Glow`。

已在 `art/prologue_terrain/prologue_terrain_v12.blend` 放置三个链接实例：隐藏遗迹旁、林间歇脚点旁、山脊采集点石旁。v11 保留。地图初始帧为关闭状态，源集合动画在 Blender 时间线上会驱动所有实例同步预览。

当前只完成 Blender 资产、布景和视觉动画；独立交互触发、奖励、一次性领取、存档与 Godot 粒子/发光材质尚未接入。程序化材质、灯光和合成器不会自动成为引擎效果。

生成：`tools/build_prologue_chests.py`。重开与动作检查、最终预览：`tools/check_prologue_chests.py`。命令使用 Blender 的 `--python-exit-code 1 --python`。截图：`v1/chest_closed.png`、`v1/chest_open.png`；动作预览：`v1/chest_magic.gif`。
