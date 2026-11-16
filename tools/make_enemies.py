"""Cut the creative lead's enemy roster (art/source/enemies/enemy_roster_02.png,
a 4 x 3 grid of single poses) into one sprite per creature, at game scale.

Same pipeline as every generated sheet (tools/process_art.py): a box reduction
by REDUCE, the image's own palette, hard alpha. Nothing is redrawn. These are
single poses: they stand in until each creature's animation sheet is made
(the game squashes and leans a one-frame sprite to act out its moves).

Usage: python3 tools/make_enemies.py
"""
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(__file__))
from process_art import process  # noqa: E402
from make_wilds import pieces  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..")
SRC = os.path.join(ROOT, "art", "source", "enemies", "enemy_roster_02.png")
OUT = os.path.join(ROOT, "game", "assets", "characters", "roster")
REDUCE = 8  # 8 roster pixels to one game pixel: the rat stands about as tall as Kleo's shoulder

# Working names, left to right, top to bottom (the creative lead names them).
NAMES = [
    "bat", "hood_knife", "skull_shaman", "cap_crawler",
    "sack_thief", "spineback", "stone_golem", "moss_blob",
    "spiked_toad", "rat", "gourd_chomper", "chained_wraith",
]


def main():
    os.makedirs(OUT, exist_ok=True)
    full = Image.open(SRC).convert("RGBA")
    w, h = full.size
    small = process(SRC, w // REDUCE, 48)
    sw, sh = small.size
    # Each creature is a connected shape (a wing tip can reach into the next
    # cell, so cut by shape, then name each by the cell its centre is in).
    found = {}
    for x, y, pw, ph in pieces(small, min_pixels=40):
        col = min(3, int((x + pw / 2) / (sw / 4)))
        row = min(2, int((y + ph / 2) / (sh / 3)))
        i = row * 4 + col
        if i not in found or pw * ph > found[i][2] * found[i][3]:
            found[i] = (x, y, pw, ph)
    for i, name in enumerate(NAMES):
        x, y, pw, ph = found[i]
        piece = small.crop((x, y, x + pw, y + ph))
        piece.save(os.path.join(OUT, name + ".png"))
        print(f"{name:15} {piece.size[0]}x{piece.size[1]}")


if __name__ == "__main__":
    main()
