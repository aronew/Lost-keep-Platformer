"""The creative lead's region map, reduced to the game's size by
process_art.py's method (a box average to 640 x 360, a palette snap with no
dither). The original stays unchanged in art/source/maps/.

  art/source/maps/region1_flooded_sanctuary.png -> game/assets/ui/region1_map.png

Usage: python3 tools/make_region_map.py
"""
import os

from PIL import Image

ROOT = os.path.join(os.path.dirname(__file__), "..")
SRC = os.path.join(ROOT, "art", "source", "maps", "region1_flooded_sanctuary.png")
OUT = os.path.join(ROOT, "game", "assets", "ui", "region1_map.png")

if __name__ == "__main__":
    im = Image.open(SRC).convert("RGB")
    small = im.resize((640, 360), Image.BOX)
    q = small.quantize(colors=128, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert("RGB")
    q.save(OUT)
    print("wrote", os.path.normpath(OUT), q.size)
