# 异世界漫游记

Godot 4 俯视角 3D 探索 RPG 原型。

## 下载资源

美术二进制由 Git LFS 管理，支持仅下载游戏资源。新机器请先阅读[轻量克隆与按需下载](docs/repository-assets.md)。

## 运行

用 Godot 4.7.1 打开 `project.godot`，按 F6/F5 运行。

## 操作

- `WASD` 或方向键：移动
- `Q` / `E`：旋转镜头
- 鼠标滚轮：平滑缩放镜头
- `F`：调查传送门或与附近村民交谈

## 检查

```powershell
godot --headless --editor --path . --quit
godot --headless --path . --script res://tests/smoke_test.gd
```
