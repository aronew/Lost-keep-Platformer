"""Stand-in sprites for the platformer's first systems, drawn here until the
creative lead generates the real art (Book 1 / Book 2 cards):

  game/assets/characters/thornhound/thornhound.png  10 frames of 48 x 32
      0-3 walk, 4 notice, 5 wind-up, 6 lunge, 7 land, 8 flinch, 9 down
  game/assets/items/chest.png                       2 frames of 30 x 24 (shut, open)
  game/assets/ui/flame.png                          3 frames of 11 x 14 (lit, spent, flare)
  game/assets/ui/cocoon_icon.png                    2 frames of 9 x 12 (missing, found)

Colours keep the colour language: the hound is plum and charcoal with crimson
Blight tendrils (it is Blight-touched, so its red is the Blight's); the chest
is timber and bronze; health is amber flame; nothing else is red.

Usage: python3 tools/make_standins.py
"""
import os

from PIL import Image, ImageDraw

ROOT = os.path.join(os.path.dirname(__file__), "..", "game", "assets")
OUT = (18, 12, 24, 255)

# --- The Thornhound ---------------------------------------------------------------------------
FUR_D, FUR_M, FUR_L = (38, 30, 52, 255), (66, 52, 82, 255), (104, 88, 118, 255)
SPINE = (150, 132, 112, 255)
BLIGHT, BLIGHT_L = (142, 30, 58, 255), (194, 56, 90, 255)
EYE = (236, 226, 160, 255)
MOUTH = (24, 10, 20, 255)


def _ellipse(d, box, fill):
    d.ellipse(box, fill=fill, outline=OUT)


def hound_frame(kind, t=0):
    im = Image.new("RGBA", (48, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    feet = 31
    # pose: body box, head centre, leg offsets (front, back), lift
    if kind == "walk":
        bob = [0, -1, 0, -1][t]
        swing = [2, 0, -2, 0][t]
        body = (10, 13 + bob, 34, 25 + bob)
        head = (36, 15 + bob)
        legs = [(28 + swing, 0), (31 - swing, 0), (13 - swing, 0), (16 + swing, 0)]
        mouth = False
        eye_h = 1
    elif kind == "notice":
        body = (10, 12, 34, 24)
        head = (37, 10)
        legs = [(28, 0), (31, 0), (13, 0), (16, 0)]
        mouth = False
        eye_h = 2
    elif kind == "windup":
        body = (8, 18, 33, 28)
        head = (37, 20)
        legs = [(30, -1), (33, -1), (10, 2), (13, 2)]
        mouth = True
        eye_h = 2
    elif kind == "lunge":
        body = (6, 10, 38, 20)
        head = (41, 11)
        legs = [(40, -6), (43, -7), (4, -4), (7, -3)]
        mouth = True
        eye_h = 2
    elif kind == "land":
        body = (9, 17, 35, 27)
        head = (38, 19)
        legs = [(29, 0), (33, 0), (11, 0), (15, 0)]
        mouth = False
        eye_h = 1
    elif kind == "flinch":
        body = (8, 13, 31, 25)
        head = (32, 11)
        legs = [(25, -1), (28, 0), (11, 0), (14, 0)]
        mouth = True
        eye_h = 0
    else:  # down
        body = (8, 22, 38, 30)
        head = (40, 25)
        legs = []
        mouth = False
        eye_h = 0
    # legs (behind the body), then the body, then the spines, then the head
    for i, (lx, lift) in enumerate(legs):
        top = (body[1] + body[3]) // 2
        if kind == "lunge":
            # airborne: forelegs reach ahead, hind legs kick back
            reach = 5 if i < 2 else -5
            d.line((lx - reach // 2, top, lx + reach, body[3] + 6), fill=OUT, width=3)
            d.line((lx - reach // 2, top, lx + reach, body[3] + 6), fill=FUR_D, width=1)
        else:
            d.rectangle((lx, top, lx + 2, feet + lift), fill=FUR_D, outline=OUT)
    _ellipse(d, body, FUR_M)
    d.line((body[0] + 4, body[1] + 2, body[2] - 4, body[1] + 2), fill=FUR_L)
    # thorny spines along the back
    for i, sx in enumerate(range(body[0] + 3, body[2] - 2, 4)):
        h = 4 if i % 2 == 0 else 3
        d.polygon([(sx, body[1] + 1), (sx + 2, body[1] - h), (sx + 3, body[1] + 1)], fill=SPINE, outline=OUT)
    # Blight tendrils on the shoulder
    d.line((body[2] - 9, body[1] + 4, body[2] - 6, body[3] - 3), fill=BLIGHT, width=1)
    d.line((body[2] - 12, body[1] + 5, body[2] - 10, body[1] + 9), fill=BLIGHT_L, width=1)
    d.point((body[2] - 7, body[1] + 6), fill=BLIGHT_L)
    # head: a long muzzle, an ear, an eye
    hx, hy = head
    d.polygon([(hx - 6, hy - 4), (hx + 2, hy - 5), (hx + 7, hy - 1), (hx + 6, hy + 3), (hx - 5, hy + 4)], fill=FUR_M, outline=OUT)
    d.polygon([(hx - 4, hy - 4), (hx - 2, hy - 9 if kind in ("notice", "windup") else hy - 7), (hx, hy - 4)], fill=FUR_D, outline=OUT)
    if eye_h > 0:
        d.rectangle((hx, hy - 2, hx + 1, hy - 2 + eye_h - 1), fill=EYE)
    else:
        d.line((hx - 1, hy - 1, hx + 1, hy - 1), fill=OUT)
    if mouth:
        d.polygon([(hx + 1, hy + 1), (hx + 7, hy), (hx + 6, hy + 3)], fill=MOUTH)
        d.point((hx + 4, hy + 1), fill=(220, 214, 200, 255))
    # tail
    tx, ty = body[0] + 1, body[1] + 4
    d.line((tx, ty, tx - 5, ty - 3 if kind != "down" else ty + 2), fill=FUR_D, width=2)
    return im


def thornhound():
    sheet = Image.new("RGBA", (48 * 10, 32), (0, 0, 0, 0))
    frames = [hound_frame("walk", i) for i in range(4)] + [hound_frame(k) for k in
              ("notice", "windup", "lunge", "land", "flinch", "down")]
    for i, f in enumerate(frames):
        sheet.alpha_composite(f, (i * 48, 0))
    return sheet


# --- The chest ---------------------------------------------------------------------------------
WOOD_D, WOOD_M, WOOD_L = (70, 42, 30, 255), (112, 70, 44, 255), (150, 100, 62, 255)
BRONZE, BRONZE_L = (150, 110, 52, 255), (214, 170, 92, 255)
MOSS = (84, 128, 64, 255)


def chest():
    sheet = Image.new("RGBA", (60, 24), (0, 0, 0, 0))
    for f in range(2):
        im = Image.new("RGBA", (30, 24), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        # the box
        d.rectangle((2, 11, 27, 23), fill=WOOD_M, outline=OUT)
        for y in (15, 19):
            d.line((3, y, 26, y), fill=WOOD_D)
        d.rectangle((2, 11, 4, 23), fill=BRONZE, outline=OUT)
        d.rectangle((25, 11, 27, 23), fill=BRONZE, outline=OUT)
        if f == 0:
            # the lid, shut
            d.rounded_rectangle((1, 4, 28, 12), radius=4, fill=WOOD_L, outline=OUT)
            d.line((3, 7, 26, 7), fill=WOOD_M)
            d.rectangle((1, 4, 4, 12), fill=BRONZE, outline=OUT)
            d.rectangle((25, 4, 28, 12), fill=BRONZE, outline=OUT)
            d.rectangle((13, 10, 16, 14), fill=BRONZE_L, outline=OUT)
            d.line((6, 4, 11, 4), fill=MOSS)
        else:
            # the lid thrown back, the dark inside showing
            d.rectangle((3, 9, 26, 12), fill=(30, 18, 16, 255))
            d.polygon([(2, 9), (27, 9), (24, 1), (5, 1)], fill=WOOD_D, outline=OUT)
            d.line((6, 4, 23, 4), fill=WOOD_M)
        sheet.alpha_composite(im, (f * 30, 0))
    return sheet


# --- Health flames and the cocoon icon ---------------------------------------------------------
AMBER, AMBER_L, AMBER_W = (242, 176, 74, 255), (255, 214, 130, 255), (255, 246, 214, 255)
EMBER, ASH = (122, 70, 40, 255), (58, 46, 60, 255)


def flame():
    sheet = Image.new("RGBA", (33, 14), (0, 0, 0, 0))
    for f in range(3):
        im = Image.new("RGBA", (11, 14), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        if f == 1:  # spent: a dark wick and a little ember
            d.polygon([(5, 6), (8, 10), (7, 13), (3, 13), (2, 10)], fill=ASH, outline=OUT)
            d.point((5, 11), fill=EMBER)
        else:
            tip = 0 if f == 2 else 1
            d.polygon([(5, tip), (9, 7), (9, 10), (7, 13), (3, 13), (1, 10), (1, 7)], fill=AMBER, outline=OUT)
            d.polygon([(5, tip + 4), (7, 8), (7, 11), (3, 11), (3, 8)], fill=AMBER_L)
            d.rectangle((4, 9, 6, 11), fill=AMBER_W)
        sheet.alpha_composite(im, (f * 11, 0))
    return sheet


SILK, SILK_L, SILK_D = (176, 160, 186, 255), (214, 204, 222, 255), (110, 96, 124, 255)


def cocoon_icon():
    sheet = Image.new("RGBA", (18, 12), (0, 0, 0, 0))
    for f in range(2):
        im = Image.new("RGBA", (9, 12), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        d.line((4, 0, 4, 2), fill=SILK_D)
        if f == 0:
            d.ellipse((1, 2, 7, 11), fill=(60, 52, 70, 255), outline=OUT)
        else:
            d.ellipse((1, 2, 7, 11), fill=SILK, outline=OUT)
            d.line((2, 5, 6, 8), fill=SILK_L)
            d.point((4, 6), fill=AMBER)
        sheet.alpha_composite(im, (f * 9, 0))
    return sheet


def save(im, *parts):
    path = os.path.join(ROOT, *parts)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    im.save(path)
    print("wrote", os.path.normpath(path), im.size)


if __name__ == "__main__":
    save(thornhound(), "characters", "thornhound", "thornhound.png")
    save(chest(), "items", "chest.png")
    save(flame(), "ui", "flame.png")
    save(cocoon_icon(), "ui", "cocoon_icon.png")
