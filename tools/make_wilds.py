"""Bring the creative lead's Region 1 kit (Book 3) into the game.

The kit's raw sheets (art/source/wilds/, the generator's originals, unchanged)
are reduced to true pixel scale the way Lost Keep's accepted sheets were
(tools/process_art.py: a box reduction to the art's intended size, a palette
of the image's own colours, hard alpha). Nothing is redrawn, reshaped or
snapped to fixed hex codes: the kit's own "native" exports were rebuilt and
snapped to 40 colours by a script, the process Lost Keep's review rejected,
so they are not used (kit_notes/ keeps its README for the record).

Each sheet is saved to game/assets/environment/wilds/<name>.png, and its
pieces (each connected group of pixels, small bits merged into the nearest
piece) are listed with their rects in wilds_pieces.json for the builders.

Usage: python3 tools/make_wilds.py
"""
import json
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(__file__))
from process_art import process  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..")
SRC = os.path.join(ROOT, "art", "source", "wilds")
OUT = os.path.join(ROOT, "game", "assets", "environment", "wilds")

# raw file -> (game name, art width in game pixels, colours). Height follows
# the raw sheet's own aspect (never stretched).
SPECS = {
    "01-stone-bands": ("ruin_stone_bands", 384, 64),
    "02-wall-corners": ("ruin_stone_walls_corners", 256, 64),
    "03-market-stall": ("stall_on_arches", 288, 96),
    "04-islands-source": ("water_islands", 384, 64),
    "05-trunk-root-source": ("trunk_and_root_arch", 384, 64),
    "07-trees-source": ("treetops", 384, 64),
    "08-chest-frames": ("chest", 192, 48),
    "09-breakable-stone": ("cracked_wall", 128, 48),
    "10-brambles": ("brambles", 256, 32),
    "11-flora": ("flora", 256, 64),
    "12-hud-icons": ("hud_icons", 160, 32),
    "14-distant-aqueduct": ("far_aqueduct", 768, 64),
    "15-triad-sky": ("triad_sky", 768, 64),
}


def pieces(img, min_pixels=24, gap=2):
    """Bounding rects of the sheet's separate pieces: groups of opaque pixels
    joined across gaps of up to `gap` px; specks smaller than `min_pixels`
    join the nearest piece."""
    a = np.array(img.getchannel("A")) > 0
    h, w = a.shape
    lab = np.zeros((h, w), dtype=np.int32)
    n = 0
    rects = []
    for y in range(h):
        for x in range(w):
            if a[y, x] and lab[y, x] == 0:
                n += 1
                stack = [(y, x)]
                lab[y, x] = n
                ys, xs = [], []
                while stack:
                    cy, cx = stack.pop()
                    ys.append(cy)
                    xs.append(cx)
                    for dy in range(-gap, gap + 1):
                        for dx in range(-gap, gap + 1):
                            yy, xx = cy + dy, cx + dx
                            if 0 <= yy < h and 0 <= xx < w and a[yy, xx] and lab[yy, xx] == 0:
                                lab[yy, xx] = n
                                stack.append((yy, xx))
                rects.append([min(xs), min(ys), max(xs) - min(xs) + 1, max(ys) - min(ys) + 1, len(ys)])
    big = [r for r in rects if r[4] >= min_pixels]
    for r in rects:
        if r[4] >= min_pixels or not big:
            continue
        cx, cy = r[0] + r[2] / 2, r[1] + r[3] / 2
        t = min(big, key=lambda b: abs(b[0] + b[2] / 2 - cx) + abs(b[1] + b[3] / 2 - cy))
        x0, y0 = min(t[0], r[0]), min(t[1], r[1])
        x1, y1 = max(t[0] + t[2], r[0] + r[2]), max(t[1] + t[3], r[1] + r[3])
        t[0], t[1], t[2], t[3] = x0, y0, x1 - x0, y1 - y0
    big.sort(key=lambda r: (r[1] // 24, r[0]))
    return [r[:4] for r in big]


def main():
    os.makedirs(OUT, exist_ok=True)
    table = {}
    for key, (name, width, colours) in SPECS.items():
        path = os.path.join(SRC, key + ".png")
        if not os.path.exists(path):
            print("missing", key)
            continue
        out = process(path, width, colours)
        out.save(os.path.join(OUT, name + ".png"))
        table[name] = {"size": list(out.size), "pieces": pieces(out)}
        print(f"{key:22} -> {name}.png {out.size[0]}x{out.size[1]}, {len(table[name]['pieces'])} pieces")
    with open(os.path.join(OUT, "wilds_pieces.json"), "w") as f:
        json.dump(table, f, indent=1)


if __name__ == "__main__" and len(sys.argv) == 1:
    main()
    strips()
    ruin_terrain()


# --- Strips the game's systems read (cropped and padded only, pixels unchanged) ---

def strip(sheet, rects, cell, out, bottom_align=True):
    """Lay pieces side by side in equal cells, each centred and, by default,
    standing on the cell's bottom edge (their own pixels untouched)."""
    img = Image.open(os.path.join(OUT, sheet + ".png")).convert("RGBA")
    cw, ch = cell
    s = Image.new("RGBA", (cw * len(rects), ch), (0, 0, 0, 0))
    for i, (x, y, w, h) in enumerate(rects):
        piece = img.crop((x, y, x + w, y + h))
        px = i * cw + (cw - w) // 2
        py = ch - h if bottom_align else (ch - h) // 2
        s.alpha_composite(piece, (px, py))
    s.save(out)
    print("strip", os.path.relpath(out, ROOT), s.size)


def strips():
    t = json.load(open(os.path.join(OUT, "wilds_pieces.json")))
    game = os.path.join(ROOT, "game", "assets")
    chest = t["chest"]["pieces"]  # sorted by row: open (tallest) first; order by x: shut, opening, open
    chest = sorted(chest, key=lambda r: r[0])
    strip("chest", chest, (40, 40), os.path.join(game, "items", "chest.png"))
    icons = sorted(t["hud_icons"]["pieces"], key=lambda r: r[0])
    # lanterns: lit, spent, flaring; drops: six turning frames; cocoons: sealed, found
    strip("hud_icons", icons[0:3], (12, 21), os.path.join(game, "ui", "flame.png"))
    strip("hud_icons", icons[3:9], (12, 12), os.path.join(game, "items", "resin.png"), bottom_align=False)
    strip("hud_icons", icons[9:11], (10, 19), os.path.join(game, "ui", "cocoon_icon.png"))


# The ruin stone terrain (Book 3's W1 and W2), cut into the bands the terrain
# skin paints along every edge: [sheet, rect]. Crops only. The lines and
# anchors (measured) are in RUIN_LINES and used by level_builder.gd.
RUIN = {
    "ruin_top": ("ruin_stone_bands", (0, 6, 384, 52)),       # walking line at row 15
    "ruin_under": ("ruin_stone_bands", (0, 70, 384, 55)),    # ceiling line at row 25
    "ruin_fill": ("ruin_stone_bands", (0, 36, 384, 16)),     # a dim course of blocks, for the inside
    "ruin_wall": ("ruin_stone_walls_corners", (2, 2, 41, 252)),          # face at column 31, facing right
    "ruin_corner_top": ("ruin_stone_walls_corners", (57, 28, 79, 88)),   # anchor (67, 14)
    "ruin_corner_under": ("ruin_stone_walls_corners", (155, 27, 84, 94)),  # anchor (77, 77)
    "ruin_inner_top": ("ruin_stone_walls_corners", (57, 131, 85, 86)),   # anchor (22, 67)
    "ruin_inner_under": ("ruin_stone_walls_corners", (155, 130, 87, 87)),  # anchor (27, 29)
}


def ruin_terrain():
    os.makedirs(os.path.join(OUT, "terrain"), exist_ok=True)
    for name, (sheet, (x, y, w, h)) in RUIN.items():
        img = Image.open(os.path.join(OUT, sheet + ".png")).convert("RGBA")
        img.crop((x, y, x + w, y + h)).save(os.path.join(OUT, "terrain", name + ".png"))
        print("terrain", name, (w, h))


if __name__ == "__main__" and len(sys.argv) > 1 and sys.argv[1] == "strips":
    strips()
if __name__ == "__main__" and len(sys.argv) > 1 and sys.argv[1] == "terrain":
    ruin_terrain()
