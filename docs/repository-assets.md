# 仓库与美术资源下载

## 本轮调整

- 删除 Git 跟踪的 `captures/`，并忽略后续截图产物。
- 制作预览不再批量提交；84 个预览文件约 112.6 MiB 已取消跟踪，本机文件保留。保留四张/段代表预览；`art/**/textures/` 是源素材依赖，继续管理。
- Blender、GLB、纹理、音视频等 299 个文件使用 Git LFS；本轮资源负载约 483 MiB。普通 Git 当前快照约 13.6 MiB（包含约 11.2 MiB 文本 glTF）。这些是未压缩内容统计，不等同实际网络流量。
- 旧地图仍被逐版构建脚本使用，保留并使用 LFS；不要直接删除链接素材或移动目录。
- 本轮不改写历史。历史里的大文件仍然存在；新机器优先浅克隆，既有仓库不会因为这次调整自动缩小 `.git`。

## 新机器：先下载代码与资源指针

安装 Git LFS 后，在 PowerShell 运行。此流程需要本轮改动已提交并推送到指定分支；运行前确认新目录尚不存在。

```powershell
git clone --depth 1 --single-branch --branch codex/fantasy-tree-assets --filter=blob:none --no-checkout git@github.com:DarClsr/well_world.git well_world_light
Set-Location well_world_light
git lfs install --local --skip-smudge
git checkout codex/fantasy-tree-assets
```

`--skip-smudge` 是此克隆的本地配置，之后 pull 不会自动下载全部 LFS 素材。只有指针时不能直接运行游戏或打开 Blender 源文件。

## 按用途获取资源

只运行/开发 Godot 游戏：

```powershell
git lfs pull --include="assets/**" --exclude=""
```

制作 Blender 场景，需要源素材、贴图与关联文件：

```powershell
git lfs pull --include="art/**,assets/**" --exclude=""
```

更新后执行同一条按需下载命令，以取得最新版本对应的资源。不要用文本编辑器覆盖尚未下载的指针文件。

若确实需要恢复自动下载所有 LFS 资源：

```powershell
git lfs install --local --force
git lfs pull --include="" --exclude=""
```

## 维护

- 首次推送本轮变更会上传约 483 MiB 的 LFS 内容（实际按对象去重），应确认远端 LFS 配额。上传成功前，新机器不能获取这些资源；正常 Git LFS pre-push hook 会在 Git 提交发布前上传对象。
- 截图、逐帧图片、Blender 自动备份不进入日常提交。旧文档提到的制作预览是历史生成记录，未保留的预览需在本机通过相应构建/检查脚本重新渲染。
- LFS 不会自动外置 Blender 内嵌贴图，也不会减少完整美术工作集；后续可单独优化源文件中的重复贴图。
- 若后续要让完整历史克隆也变小，需先备份并在独立镜像中验证历史迁移，再协调分支/标签与强制推送。不要直接在当前工作目录执行 `git lfs migrate import --everything`。
