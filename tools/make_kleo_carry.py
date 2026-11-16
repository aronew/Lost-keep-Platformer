"""Kleo lifting, carrying, throwing and setting down a crate (Book 3's C2,
the kit's 13-kleo-interact sheet) as a 64 x 64 frame strip, by the same method
as her other sheets (tools/process_sprites.py): cut from the generator's raw
sheet, scaled to her standing height (28 px), snapped to her shared
palette, feet on the anchor (x 32, y 56).

The sheet's key-green boxes only show where the crate is in each frame. They
are dropped from the art and kept as numbers: where each frame's crate rests
(the box's bottom centre), measured from her feet (facing right), so the game
holds the real crate there.

The raw sheet: 4 columns x 3 rows, frames left to right then down:
lift A, B, C, carry stand, carry run 1-4, throw A, B, C (no crate), set down.

Output: game/assets/characters/kleo/carry.png (12 frames) and carry.json
({"frames": 12, "crate": [[x, y] or null, ...]}).
Usage: python3 tools/make_kleo_carry.py
"""
import json
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(__file__))
import process_sprites as ps  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..")
SRC = os.path.join(ROOT, "art", "source", "wilds", "13-kleo-interact.png")
KLEO_SRC = os.path.join(ROOT, "art", "source", "kleo")
OUT = os.path.join(ROOT, "game", "assets", "characters", "kleo")


def green_box(cell):
    a = np.asarray(cell).astype(int)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    m = (g > 180) & (r < 110) & (b < 110) & (a[..., 3] > 128)
    if m.sum() < 50:
        return None
    ys, xs = np.nonzero(m)
    # the box's bottom centre: where it rests on her hands
    return ((xs.min() + xs.max() + 1) / 2.0, float(ys.max() + 1))


def raw_cells():
    im = Image.open(SRC).convert("RGBA")
    cw, ch = im.width / 4, im.height / 3
    for r in range(3):
        for c in range(4):
            yield im.crop((round(c * cw), round(r * ch), round((c + 1) * cw), round((r + 1) * ch)))


def main():
    cells = list(raw_cells())
    boxes = [green_box(c) for c in cells]
    raw = [ps.drop_key_green(c) for c in cells]
    # Her scale and palette, exactly as process_sprites.py makes them.
    s = ps.scale_of(KLEO_SRC)
    idle = list(ps.cells(os.path.join(KLEO_SRC, "01_idle.png"), 3))
    idle_areas = sorted(ps.hair_area(f) for f in idle)
    ref_area = idle_areas[len(idle_areas) // 2]
    others = []
    for stem, (rows, mode) in ps.SHEETS.items():
        path = os.path.join(KLEO_SRC, stem + ".png")
        if os.path.exists(path) and not stem.startswith("25"):
            fr = list(ps.cells(path, rows))[:ps.KEEP.get(stem)]
            k = s if mode == "fx" else ps.sheet_scale(fr, ref_area, s)
            others += [ps.shrink(f, k) for f in fr]
    # Scaled by her height, not her hair: her raised arms hide the hair the
    # other sheets are matched by (that made her half again too big). Frame 2
    # (lift B) has her standing upright: boot soles to the top of her head
    # is her standing height, as in every other sheet.
    x0, y0, x1, y1 = ps.mask_bbox(raw[1])
    k = ps.HEIGHT / (y1 - y0)
    small = [ps.shrink(f, k) for f in raw]
    # The very palette her other sheets were snapped to (the same input to the
    # same median cut), so the carry frames share their colours exactly.
    pal = ps.build_palette(others)
    strip = Image.new("RGBA", (ps.CELL * len(small), ps.CELL), (0, 0, 0, 0))
    crate = []
    for i, f in enumerate(small):
        f = ps.snap(f, pal)
        x0, y0, x1, y1 = ps.mask_bbox(f)
        dx, dy = ps.ANCHOR[0] - ps.torso_x(f), ps.ANCHOR[1] - y1
        cell = Image.new("RGBA", (ps.CELL, ps.CELL), (0, 0, 0, 0))
        cell.paste(f, (int(dx), int(dy)), f)
        strip.alpha_composite(cell, (i * ps.CELL, 0))
        if boxes[i] is None:
            crate.append(None)
        else:
            bx, by = boxes[i]
            # raw cell px -> game px in the 64 cell -> from her feet
            crate.append([round(bx * k + dx - ps.ANCHOR[0]), round(by * k + dy - ps.ANCHOR[1])])
    strip.save(os.path.join(OUT, "carry.png"))
    with open(os.path.join(OUT, "carry.json"), "w") as fh:
        json.dump({"frames": len(small), "crate": crate}, fh)
    print("scale %.4f" % k, "crate", crate)


if __name__ == "__main__":
    main()
