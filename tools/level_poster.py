"""Fold a long level picture into a poster that reads on one page: the level
cut into strips stacked top to bottom, each with its x range in tiles.

Usage: python3 tools/level_poster.py <room> [image] [strips]
  image: room_routes (default), room_box or room_art, from the room's map folder.
Writes game/tests/out/<room>/map/<image>_poster.png.
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

room = sys.argv[1]
name = sys.argv[2] if len(sys.argv) > 2 else "room_routes"
strips = int(sys.argv[3]) if len(sys.argv) > 3 else 4
base = f"game/tests/out/{room}/map"
im = Image.open(os.path.join(base, name + ".png")).convert("RGB")
w, h = im.size
sw = -(-w // strips)
gap = 28
out = Image.new("RGB", (sw, strips * (h + gap)), (11, 8, 18))
d = ImageDraw.Draw(out)
try:
    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 16)
except OSError:
    font = ImageFont.load_default()
for i in range(strips):
    x0 = i * sw
    out.paste(im.crop((x0, 0, min(x0 + sw, w), h)), (0, i * (h + gap) + gap))
    d.text((8, i * (h + gap) + 5), f"tiles {x0 // 16} to {min(x0 + sw, w) // 16}", fill=(235, 238, 245), font=font)
path = os.path.join(base, name + "_poster.png")
out.save(path)
print("wrote", path, out.size)
