# 《异世界漫游记》首轮素材评估结果

版本：0.1<br>
日期：2026-08-31<br>
评估范围：序章自然、村庄模块、玩家与 NPC 候选<br>
对应规范：[美术风格规范](art-direction.md) · [素材候选清单](asset-shortlist.md)

## 1. 本轮目标

在不修改正式 `main.tscn` 的前提下完成第一批免费素材验证：

- 下载并校验官方免费压缩包。
- 保留许可证文件。
- 从完整素材包中拣选少量候选进入项目。
- 验证 Godot 4.7.1 的模型、贴图、骨骼和动画导入。
- 在相同镜头、相同光照和相同显示身高下比较素材。
- 给出第一轮取舍结论。

## 2. 下载与完整性

原始压缩包存放在 Git 忽略目录 `.downloads/art-evaluation/`，不进入版本库。

| 压缩包 | 字节数 | SHA-256 |
| --- | ---: | --- |
| `kaykit-adventurers.zip` | 13,024,345 | `ABE48F4763FBA0896BAB486EE9E6D08CA6B5B3884B9601F235C8847AE94DC479` |
| `medieval-village-megakit.zip` | 161,003,471 | `E60DEA67C10F30DCCCCFBFF92A7933F5EA5CFE99BE0E2A0FA5118CCEABEEC5C4` |
| `modular-character-outfits-fantasy.zip` | 294,347,394 | `C3468B18871CC8C8F05AB14DF7712BAF22CB9F389CBD870BABF130E595187F70` |
| `stylized-nature-megakit.zip` | 104,088,529 | `298F6732B872E4CF7B30E6E7ABF9641C7F6DC6B326DF37AC089533ED7E3D58C9` |
| `universal-base-characters.zip` | 128,968,391 | `FDBF1804C90DFC1EA03E992BFF7DA2DFD1A79318E13270A660180F9308455F40` |

5 个压缩包都可以正常列目录和解压，均包含许可证或说明文件。

## 3. 项目内评估资产

首轮验证期间，拣选资产曾位于临时 `assets/evaluation/`：

| 分组 | 内容 | 原始文件体积 |
| --- | --- | ---: |
| `quaternius_nature` | 14 个自然模型及所需贴图 | 36.34 MB |
| `quaternius_village` | 16 个建筑/道具模型及所需贴图 | 41.19 MB |
| `quaternius_characters` | 4 个完整服装角色、2 个基础身体及贴图 | 103.19 MB |
| `kaykit_characters` | 2 个角色、2 个动画库及许可 | 2.28 MB |

合计约 192 MB、233 个文件，其中包含 Godot 生成的 `.import` 配置。评估完成后，该目录因包含大量与现有项目重复的网格和贴图而从正式项目中清理，并迁移到 Git 忽略目录 `.downloads/art-evaluation/curated-evaluation/`；也可从同目录原始压缩包重新恢复。

依赖检查：

- 36 个 glTF。
- 4 个 GLB。
- 0 个缺失 buffer 或贴图依赖。
- 5 份许可证文件。
- 96 份 Godot 导入配置。

## 4. Godot 验证

验证期间使用了独立 `ArtEvaluation` 场景；完成取舍后与临时脚本一并清理，避免正式项目依赖评估资源。

场景责任仅限素材对比，包含：

- 统一的 Compatibility 渲染器环境、自然光和阴影。
- 8 组自然候选。
- 10 组村庄建筑与道具候选。
- Quaternius Ranger、Quaternius Peasant、KayKit Hooded Rogue、KayKit Ranger 四个角色候选。
- 自动身高归一化，四个角色均以约 2 米显示高度比较。
- KayKit `Idle_A` 动画挂载与播放。

评估阶段自动测试覆盖：

测试覆盖：

- 关键候选资源存在且可加载为 `PackedScene`。
- 对比场景、环境、太阳和摄像机存在。
- 自然、建筑和角色展台数量符合契约。
- 四个角色显示身高处于 1.8～2.2 米。
- 两个 KayKit 候选拥有并播放 `Idle_A`。

骨骼与动画实测：

- Quaternius Ranger/Peasant：65 骨骼，免费服装 glTF 不含动画。
- KayKit Hooded Rogue/Ranger：23 骨骼，角色 GLB 不含内嵌动画。
- KayKit General 动画库：23 骨骼，包含 `Idle_A`、`Idle_B`、`Interact`、`PickUp` 等。
- KayKit Movement 动画库：23 骨骼，包含 Walking、Running、Jump 等。
- KayKit 角色与动画库使用相同 `Rig_Medium/Skeleton3D` 路径，可直接复用动画，不需要首轮重定向。

## 5. 视觉结果

对比截图：

- [原始比例](../captures/art-evaluation00000001.png)
- [统一身高](../captures/art-evaluation-normalized00000001.png)
- [统一身高 + KayKit Idle](../captures/art-evaluation-idle00000001.png)

### 自然素材

结论：**通过造型筛选，需要调色。**

- 树干、树冠、岩石的大轮廓明显优于当前旧素材的重复感。
- Twisted Tree 默认红叶饱和度过高，会抢走炉火与传送门焦点。
- Common Tree、松树、枯树、灌木和岩石适合构成前中远景。
- 正式序章只使用 3 种主树和有限植被组合，并统一压到鼠尾草绿、灰绿与少量秋色。

### 村庄素材

结论：**通过结构筛选，需要材质和构图处理。**

- 墙、门窗、屋顶和烟囱能够组合出清楚的俯视房屋轮廓。
- 屋顶比例适合俯视镜头，但原始陶瓦和墙面在当前光照下偏亮。
- 模块化结构适合为三栋房屋分别建立药草、守门和织造身份。
- 不使用官方演示房屋，正式场景必须重新组合。

### Quaternius 角色

结论：**可用于 NPC 基础，不作为当前玩家首选。**

- 材质细节与环境生态一致。
- 人形比例较修长，俯视下不如 KayKit 紧凑醒目。
- 免费服装模型无动画，需另做 Quaternius 动画重定向。
- Universal Base Characters 免费包实测只有 Superhero 男、女完整身体，不含预期的 Teen/Regular。
- 4K 角色纹理占用过高：Ranger/Peasant 的 Normal、ORM 和 BaseColor 单张可达约 4.8～13.5 MB；正式导入前应限制到 1K～2K。

### KayKit 角色

结论：**Hooded Rogue 是本轮最佳玩家原型。**

- 大头小身、短四肢、帽兜与披风形成清楚剪影，更接近《Death's Door》的组织方式。
- 免费动画库与角色骨架完全匹配，Idle 已在 Godot 中实际播放。
- 默认绿色过亮、表面偏玩具感，不能直接作为最终主角。
- 单材质渐变图集限制了局部换色；下一步需要制作项目专属调色贴图或 Shader，而不是只修改 `albedo_color`。
- KayKit Ranger 轮廓较普通，作为次要对照；Hooded Rogue 更适合继续改造成“漂泊者”。

## 6. 第一轮决定

保留并进入下一轮：

- Quaternius Stylized Nature：保留 Common Tree、Twisted Tree、松树、枯树、灌木、草与岩石候选。
- Quaternius Medieval Village：保留墙、门窗、屋顶、烟囱、围栏、马车和木箱候选。
- KayKit Hooded Rogue：确定为玩家原型主候选。
- KayKit General/Movement 动画库：继续用于 Idle、Walk、Run 和交互验证。
- Quaternius Ranger/Peasant：保留为修长人形和 NPC 对照。

暂不采用：

- Universal Base Characters 免费 Superhero 身体。
- KayKit Ranger 作为最终玩家。
- 原始高饱和红叶与未调色环境材质。
- 4K 角色纹理直接进入正式序章。

暂不购买任何 Source、Pro 或 Extra 版本。

## 7. 下一轮工作

1. 为 KayKit Hooded Rogue 制作“漂泊者”专属深绿、皮革棕、暖色围巾和青色异界标记调色方案。
2. 为自然与村庄素材建立统一色板和更克制的材质预览。
3. 只选一栋药草师房屋和一个道路节点接入序章副本场景。
4. 在真实游戏镜头下验证遮挡、比例、动画和性能。
5. 通过后再决定哪些素材进入正式 `assets/`，评估失败项不进入主场景。

## 8. Phase 34 接入结果

- 二进制哈希确认本轮自然与村庄候选和项目现有同名网格、贴图一致，不执行重复替换。
- KayKit Hooded Rogue 已提升到 `assets/kaykit/adventurers/`，连同 General、Movement 动画与原始 CC0 许可证进入正式候选。
- 新建 `scenes/player/drifter_visual.tscn`，以独立场景封装模型、动画别名和材质，不让 `Player.gd` 依赖 KayKit 原始动画名。
- `main.gd` 已使用漂泊者场景替换旧 Ranger 玩家外观；NPC 暂时保持原样。
- 新增 `shaders/drifter_palette.gdshader`，压低默认高饱和绿色并使用 Toon 光照。
- 新增 chest 骨骼青色印记，建立玩家与异界石环的视觉联系。
- 实机证据：[开场](../captures/initial-scene-drifter-mark00000003.png) · [前进](../captures/drifter-movement-forward.png) · [横移](../captures/drifter-movement-right.png)。
- 临时 `assets/evaluation/`、展台场景和诊断脚本已清理；原始包继续保存在被 Git 忽略的 `.downloads/art-evaluation/`，可恢复但不会污染正式资源。

## 9. Phase 35–36 持续迭代结果

- Mage、Knight、Rogue 已分别接入米拉、托伦、尼娅，和玩家共享 23 骨骼、4～5 头身、同一动画适配器与 Toon Shader。
- 自动测试约束 NPC 可见高度必须处于玩家的 0.8～1.3 倍；基础缩放统一为 `Vector3.ONE`。
- NPC 身份标签改为模型可见高度加 0.28 米，解决米拉帽檐遮挡。
- 序章空间不再保持原布局：出生点移动到石环，新增雾池支路，并把北侧封死悬崖改造成带石阶、符石、动态雾幕和碰撞封锁的浓雾山口。
- 最终实机证据：[NPC 巡游](../captures/kaykit-npc-label.png) · [尼娅交谈](../captures/kaykit-npc-facing.png) · [石环出生](../captures/prologue-route-portal-final.png) · [雾池岔路](../captures/prologue-route-pond-final.png) · [浓雾山口](../captures/prologue-route-pass-final.png)。
