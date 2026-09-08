"""Label actual v06 rendering with content locations and planned route roles."""
import json
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[1]
ART=ROOT/'art/prologue_terrain'
data=json.loads((ROOT/'assets/prologue_terrain/expansion_v06.json').read_text())
image=Image.new('RGB',(1600,1690),'#f2f4f3')
image.paste(Image.open(ART/'expanded_top_v06.png'),(0,100))
draw=ImageDraw.Draw(image)
def font(size):
    return ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',size)
def pixel(x,z):
    return 800+x*1600/370,850+z*1600/370
draw.text((35,18),'序章扩展 v06 · 320 × 280 米',font=font(32),fill='#182c2c')
draw.text((35,62),'实际 Blender 布局 | 主路线 + 三条支路 | 地点已布置，玩法尚未接入',font=font(22),fill='#465454')
for i,route in enumerate(data['routes_godot_xz']):
    pts=[pixel(*p) for p in route]
    draw.line(pts,fill='#273c3c',width=7)
    draw.line(pts,fill='#edc45a' if i<4 else '#83d6dc',width=3)
labels=[('出生废墟',-120,-95,20,-65),('隐藏旧遗迹',-143,-79,-55,20),
        ('林间歇脚点',-77,-29,-35,-65),('聚落与基础教学',-10,10,-210,35),
        ('狌狌试炼预留',127,-85,-180,-65),('沿崖采集点',146,-64,-160,0),
        ('可选异兽活动区',143,-38,-180,20),('采药棚与归路',40.67,58.8,25,10)]
for title,x,z,dx,dy in labels:
    px,py=pixel(x,z); tx,ty=px+dx,py+dy
    box=draw.textbbox((tx+9,ty+7),title,font=font(22))
    draw.line((px,py,tx+10,ty+18),fill='white',width=2)
    draw.ellipse((px-5,py-5,px+5,py+5),fill='white')
    draw.rectangle((tx,ty,box[2]+9,ty+40),fill='#243737')
    draw.text((tx+9,ty+7),title,font=font(22),fill='white')
draw.text((35,1610),'主路线约779米，支路合计约232米；长度不等于游玩时长，碰撞和导航待引擎验收。',font=font(24),fill='#233939')
draw.text((35,1650),'黄色：主路线    青色：可选支路    所有建筑与素材保持原尺度',font=font(21),fill='#465454')
image.save(ART/'expanded_content_map_v06.png')
print('CONTENT_MAP_OK')
