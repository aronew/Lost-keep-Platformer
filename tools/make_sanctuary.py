"""The creative lead's Flooded Sanctuary kit (Book 5, level 1-2's look) into the game.

The generator's sheets (art/source/sanctuary/F1..F16, unchanged) are reduced
to true pixel scale as tools/process_art.py does: averaged down, each sheet
in its own colours (a median-cut palette), binary alpha. Nothing is redrawn.

Writes game/assets/environment/sanctuary/:
  <sheet>.png            every sheet at game scale
  terrain/sanct_*.png    the stone's top band, underside band, wall face, fill
  sanct_water.png        the water's paint (the sheet's long strip)
  fg_sanct_bottom_a/b    the foreground band (b: half a band on)
  sanct_pieces.json      every sheet's separate pieces: [x, y, w, h]

Usage: python3 tools/make_sanctuary.py
"""
import json
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(__file__))
from process_art import process  # noqa: E402
from make_wilds import pieces  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..")
SRC = os.path.join(ROOT, "art", "source", "sanctuary")
OUT = os.path.join(ROOT, "game", "assets", "environment", "sanctuary")

# sheet: (game width, colours)
SHEETS = {
    "F1-stone-bands": (384, 96), "F2-walls-corners": (256, 96), "F3-stone-fill": (128, 48),
    "F4-ruins": (256, 96), "F5-islands-pillars": (384, 96), "F6-log-root": (384, 96),
    "F7-ceiling": (384, 96), "F8-water": (384, 48), "F9-sunken": (256, 96),
    "F10-hut-door": (256, 128), "F11-flora": (256, 96), "F12-things": (256, 96),
    "F13-far-ruins": (768, 48), "F14-mid-ruins": (768, 48), "F15-cavern-light": (768, 48),
    "F16-foreground": (768, 64),
}
# The stone, cut from F1 and F2 (rows and columns measured on the reduced sheets).
TERRAIN = {
    "sanct_top": ("F1-stone-bands", (0, 9, 384, 60)),      # walking line on row 24: line 15
    "sanct_under": ("F1-stone-bands", (0, 76, 384, 123)),  # solid to row 92: line 16
    "sanct_wall": ("F2-walls-corners", (0, 0, 41, 256)),   # face about column 34
}


def save(im, name):
    path = os.path.join(OUT, name)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    im.save(path)
    print("wrote", os.path.relpath(path, ROOT), im.size)


def main():
    out = {}
    done = {}
    for name, (w, colours) in SHEETS.items():
        im = process(os.path.join(SRC, name + ".png"), w, colours)
        done[name] = im
        save(im, name + ".png")
        if name not in ("F3-stone-fill", "F15-cavern-light"):
            out[name] = {"size": list(im.size), "pieces": pieces(im)}
    for t, (sheet, box) in TERRAIN.items():
        save(done[sheet].crop(box), "terrain/%s.png" % t)
    save(done["F3-stone-fill"], "terrain/sanct_fill.png")
    # The water: the sheet's widest piece.
    wp = max(out["F8-water"]["pieces"], key=lambda r: r[2])
    save(done["F8-water"].crop((wp[0], wp[1], wp[0] + wp[2], wp[1] + wp[3])), "sanct_water.png")
    # The foreground band, trimmed to its plants, and a copy half a band on.
    fg = done["F16-foreground"]
    box = fg.getchannel("A").getbbox()
    fg = fg.crop((0, box[1], fg.width, box[3]))
    save(fg, "fg_sanct_bottom_a.png")
    half = fg.width // 2
    b = Image.new("RGBA", fg.size)
    b.paste(fg.crop((half, 0, fg.width, fg.height)), (0, 0))
    b.paste(fg.crop((0, 0, half, fg.height)), (fg.width - half, 0))
    save(b, "fg_sanct_bottom_b.png")
    with open(os.path.join(OUT, "sanct_pieces.json"), "w") as fh:
        json.dump(out, fh, indent=1)


if __name__ == "__main__":
    main()
