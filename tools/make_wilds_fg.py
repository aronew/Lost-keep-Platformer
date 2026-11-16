"""Bring in the creative lead's Region 1 foreground (art/source/wilds/foreground/):
the painted deep water, the teal fern band and the plum stone band. Each atlas
holds two versions of its band (A above B), each a long run plus two short
end pieces. Reduced 3:1 exactly as Lost Keep's foreground bands were
(tools/make_fg_bands.py: box average with premultiplied alpha, alpha hardened
at half), nothing else done. Saved to game/assets/environment/wilds/:

    fg_ferns_bottom_a.png, _b    the fern band (foreground, bottom of the view)
    fg_stones_bottom_a.png, _b   the stone band (foreground, nearest)
    water_paint.png              the water's A and B runs side by side (the
                                 level's water surface and depth)
    fg_<name>_<a|b>_cap1/2.png   the short end pieces, kept for later

    python3 tools/make_wilds_fg.py
"""
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(__file__))
from make_fg_bands import reduce  # noqa: E402
from make_wilds import pieces  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..")
SRC = os.path.join(ROOT, "art", "source", "wilds", "foreground")
OUT = os.path.join(ROOT, "game", "assets", "environment", "wilds")


def bands(name):
    a = np.array(Image.open(os.path.join(SRC, name + "_atlas.png")).convert("RGBA"))
    img = Image.fromarray(reduce(a), "RGBA")
    ps = pieces(img, min_pixels=60, gap=1)
    h = img.size[1]
    rows = [[p for p in ps if p[1] + p[3] / 2 < h / 2], [p for p in ps if p[1] + p[3] / 2 >= h / 2]]
    out = {}
    for label, row in zip("ab", rows):
        row.sort(key=lambda p: p[0])
        crops = [img.crop((x, y, x + w, y + hh)) for x, y, w, hh in row]
        out[label] = crops
        print(name, label, [tuple(p) for p in row])
    return out


def main():
    for name, game in (("fern", "ferns"), ("stone", "stones")):
        b = bands(name)
        for label in "ab":
            longest = max(b[label], key=lambda c: c.size[0])
            longest.save(os.path.join(OUT, f"fg_{game}_bottom_{label}.png"))
            for i, c in enumerate([c for c in b[label] if c is not longest]):
                c.save(os.path.join(OUT, f"fg_{game}_{label}_cap{i + 1}.png"))
    w = bands("water")
    a = max(w["a"], key=lambda c: c.size[0])
    bb = max(w["b"], key=lambda c: c.size[0])
    hh = max(a.size[1], bb.size[1])
    strip = Image.new("RGBA", (a.size[0] + bb.size[0], hh), (0, 0, 0, 0))
    strip.alpha_composite(a, (0, 0))
    strip.alpha_composite(bb, (a.size[0], 0))
    strip.save(os.path.join(OUT, "water_paint.png"))
    print("water_paint", strip.size)


if __name__ == "__main__":
    main()
