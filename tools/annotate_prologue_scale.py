"""Annotate the measured top-down Blender render for layout discussion."""
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'art/prologue_terrain/scale_review'
report = json.loads((OUT / 'measurements.json').read_text())
font_path = 'C:/Windows/Fonts/msyh.ttc'
def font(size):
    return ImageFont.truetype(font_path, size)
base = Image.open(OUT / 'map_top_raw.png').convert('RGB')
canvas = Image.new('RGB', (1600, 1740), '#f2f4f3')
canvas.paste(base, (0, 110))
d = ImageDraw.Draw(canvas)
d.text((45, 20), '序章现状 · 整图尺度与路线', font=font(34), fill='#182424')
d.text((45, 66), 'v05 实际地形 180 × 160 米 | 当前布局评估，尚未扩图', font=font(23), fill='#465252')
def pixel(x, z):
    return (800 + x * 1600 / 220, 860 + z * 1600 / 220)
colors = ['#f5c657', '#ff9472', '#82dddf', '#e8c6ff']
for route, color in zip(report['routes_godot_xz'], colors):
    pts = [pixel(*p) for p in route]
    d.line(pts, fill='#253333', width=9)
    d.line(pts, fill=color, width=5)
for label, x, z, dx, dy in [
    ('① 出生废墟 约12×9米', -60, -45, -175, -105),
    ('② 下山通道', -57, -10, -260, -20),
    ('③ 聚落区域', -10, 10, -270, 50),
    ('④ 东侧试炼坡', 57, -35, 25, -80),
    ('⑤ 溪岸返回路线', 12, 65, 60, 10),
]:
    px, py = pixel(x, z)
    tx, ty = px + dx, py + dy
    text_box = d.textbbox((tx + 12, ty + 8), label, font=font(23))
    d.line((px, py, tx + 15, ty + 20), fill='#ffffff', width=3)
    d.ellipse((px-7, py-7, px+7, py+7), fill='#ffffff', outline='#172323', width=2)
    d.rectangle((tx, ty, text_box[2] + 12, ty + 46), fill='#233232')
    d.text((tx+12, ty+8), label, font=font(23), fill='white')
x0, y0 = 85, 1555
bar = 20 * 1600 / 220
d.line((x0, y0, x0 + bar, y0), fill='white', width=6)
for x in (x0, x0 + bar):
    d.line((x, y0-9, x, y0+9), fill='white', width=3)
d.text((x0, y0-45), '20 米', font=font(23), fill='white')
lengths = report['route_plan_lengths_m']
d.text((45, 1620), f'废墟→聚落约 {lengths[0]:.0f} 米    聚落→试炼坡约 {lengths[1]:.0f} 米    全部标线合计约 {sum(lengths):.0f} 米', font=font(25), fill='#203131')
d.text((45, 1670), '路线为设计折线的平面长度，不是实走记录；山坡、战斗、采集和探索停留尚未计入。', font=font(22), fill='#465252')
canvas.save(OUT / 'map_scale_annotated.png')
print('ANNOTATED_MAP_OK')
