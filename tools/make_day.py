"""The creative lead's Sunlit Woodland kit (Book 4, region 1 by day) into the game.

The kit (art/source/day/, unchanged) holds the generator's images
(`sources/`) and the kit's own export of them (`native/`, `sheets/`), made by
its `export_kit.py`: crops and placements that hold every walking line,
opening, seam and step to the book's numbers, but with nearest-neighbour
downscales (pixels dropped) and every pixel snapped to fixed colour ramps per
material: the rebuilt, colour-snapped kind of export Lost Keep's review
rejected (the great trees came out with garish red trunks and blue leaves).

So the kit's own script is run again on the sources (a copy, in a scratch
folder; the kit stays unchanged) with two changes only: downscales average
the generator's pixels (BOX, as tools/process_art.py), and each sheet keeps
its own colours (a median-cut palette of 96, binary alpha) instead of the
fixed ramps. Every crop, placement, walking line and opening is the kit's.
The atlas (rectangles, anchors) is the kit's atlas.json.

Writes game/assets/environment/day/:
  <sheet>.png              every native sheet, as delivered
  terrain/day_*.png        the ground's bands, wall, corners and fill, cut out
  fg_day_bottom_a/b.png    the leafy foreground band (b: the same, half a band on)
  day_atlas.json           the kit's atlas
and replaces the stand-ins:
  game/assets/items/letters.png     K L E O, 16 x 18 each
  game/assets/items/token.png       the bonus token, 4 frames of 16 x 16
  game/assets/ui/letter_icons.png   K L E O dim, then found, 9 x 11 each

Usage: python3 tools/make_day.py [scratch_dir]
"""
import json
import os
import shutil

from PIL import Image

ROOT = os.path.join(os.path.dirname(__file__), "..")
SRC = os.path.join(ROOT, "art", "source", "day")
OUT = os.path.join(ROOT, "game", "assets", "environment", "day")
ASSETS = os.path.join(ROOT, "game", "assets")


NATIVE = None  # set by reexport(): the re-exported native sheets


def native(name):
    return Image.open(os.path.join(NATIVE, name + ".png")).convert("RGBA")


PALETTE = """
def palette(im,kind='general'):
 # The generator's own colours: a median-cut palette per sheet, binary alpha
 # (tools/make_day.py replaces the kit's fixed per-material ramps).
 a=np.array(im); alpha=np.where(a[:,:,3]>=128,255,0).astype(np.uint8)
 q=Image.fromarray(a[:,:,:3]).quantize(colors=96,method=Image.Quantize.MEDIANCUT,dither=Image.Dither.NONE).convert('RGB')
 b=np.array(q.convert('RGBA')); b[:,:,3]=alpha; b[alpha==0]=0
 return Image.fromarray(b)
"""


def reexport(work):
    """Run the kit's export_kit.py on its sources in `work`, patched as above."""
    import re
    import subprocess
    import sys
    os.makedirs(work, exist_ok=True)
    src = open(os.path.join(SRC, "export_kit.py")).read()
    src = src.replace("NN=Image.Resampling.NEAREST", "NN=Image.Resampling.BOX")
    i = src.index("def palette(im,kind='general'):")
    j = src.index("def seam(")
    src = src[:i] + PALETTE.strip() + "\n" + src[j:]
    # Only the native sheets and the atlas are wanted; the review sheet's
    # thumbnails and the x8 sheets are skipped.
    src = src.replace(" im.resize((im.width*scale,im.height*scale),NN).save(ROOT/'sheets'/f'{name}.png')\n", "")
    src = src.replace(" im.resize((w*sc,h*sc),NN).save(ROOT/'pieces'/f'{name}.png')\n", "")
    src = src[:src.index("cols=3;cw=520")] + "print('re-exported',len(MAN),'sheets')\n"
    with open(os.path.join(work, "export_kit.py"), "w") as fh:
        fh.write(src)
    if not os.path.exists(os.path.join(work, "sources")):
        os.symlink(os.path.join(SRC, "sources"), os.path.join(work, "sources"))
    subprocess.run([sys.executable, os.path.join(work, "export_kit.py")], check=True, cwd=work)
    return os.path.join(work, "native")


def piece(atlas, name):
    for sh in atlas["sheets"]:
        for p in sh["pieces"]:
            if p["name"] == name:
                x, y, w, h = p["rect_native"]
                return native(sh["name"]).crop((x, y, x + w, y + h)), p
    raise KeyError(name)


def save(im, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    im.save(path)
    print("wrote", os.path.relpath(path, ROOT), im.size)


def main(work):
    global NATIVE
    NATIVE = reexport(work)
    atlas = json.load(open(os.path.join(SRC, "atlas.json")))
    mine = json.load(open(os.path.join(work, "atlas.json")))
    assert mine["sheets"] == atlas["sheets"], "the re-export's rectangles differ from the kit's atlas"
    os.makedirs(OUT, exist_ok=True)
    for f in sorted(os.listdir(NATIVE)):
        if f.endswith(".png"):
            shutil.copyfile(os.path.join(NATIVE, f), os.path.join(OUT, f))
    shutil.copyfile(os.path.join(SRC, "atlas.json"), os.path.join(OUT, "day_atlas.json"))
    # The ground (D1, D2, D3).
    t = os.path.join(OUT, "terrain")
    for name, out in [("walkable-ground-band", "day_top"), ("ground-underside-band", "day_under"),
                      ("right-facing-wall", "day_wall"), ("outer-top", "day_corner_top"),
                      ("outer-under", "day_corner_under"), ("inner-top", "day_inner_top"),
                      ("inner-under", "day_inner_under"), ("earth-fill", "day_fill")]:
        save(piece(atlas, name)[0], os.path.join(t, out + ".png"))
    # The foreground band, and a second copy half a band on (the band pair).
    fg = piece(atlas, "foreground-foliage")[0]
    save(fg, os.path.join(OUT, "fg_day_bottom_a.png"))
    b = Image.new("RGBA", fg.size)
    half = fg.width // 2
    b.paste(fg.crop((half, 0, fg.width, fg.height)), (0, 0))
    b.paste(fg.crop((0, 0, half, fg.height)), (fg.width - half, 0))
    save(b, os.path.join(OUT, "fg_day_bottom_b.png"))
    # The collectibles, in the strips the game reads.
    letters = Image.new("RGBA", (64, 18))
    for i, l in enumerate("KLEO"):
        letters.alpha_composite(piece(atlas, "collectible-" + l)[0], (i * 16, 0))
    save(letters, os.path.join(ASSETS, "items", "letters.png"))
    token = Image.new("RGBA", (64, 16))
    for i in range(4):
        token.alpha_composite(piece(atlas, "bonus-token-frame-%d" % i)[0], (i * 16, 0))
    save(token, os.path.join(ASSETS, "items", "token.png"))
    icons = Image.new("RGBA", (72, 11))
    for s, state in enumerate(["dim", "found"]):
        for i, l in enumerate("KLEO"):
            icons.alpha_composite(piece(atlas, "hud-%s-%s" % (l, state))[0], ((s * 4 + i) * 9, 0))
    save(icons, os.path.join(ASSETS, "ui", "letter_icons.png"))


if __name__ == "__main__":
    import sys
    import tempfile
    main(sys.argv[1] if len(sys.argv) > 1 else tempfile.mkdtemp(prefix="day_kit_"))
