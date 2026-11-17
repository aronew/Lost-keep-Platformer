"""Stand-in sprites drawn here until the creative lead's Book 4 kit brings the
real ones (each is listed in Book 4):

  game/assets/items/letters.png     4 frames of 16 x 18: K, L, E, O, gold (in the world)
  game/assets/ui/letter_icons.png   8 frames of 9 x 11: K L E O dim, then lit (the HUD)
  game/assets/items/token.png       4 frames of 16 x 16: the bonus token, turning
  game/assets/items/banner.png      3 frames of 40 x 64: the midway checkpoint, a
                                    Guard's banner: furled, then flying (2 frames)
  game/assets/items/knot.png        2 frames of 20 x 20: Morvath's thorn knot, its
                                    eye shut, then open (each level's great secret)

The letters spell KLEO, as Donkey Kong Country's spell KONG: four per level.
The token is a gold coin with a Prism-blue shard on it: a bonus area's prize.

Usage: python3 tools/make_standins.py
"""
import os

from PIL import Image, ImageDraw

ROOT = os.path.join(os.path.dirname(__file__), "..", "game", "assets")
OUT = (40, 24, 18, 255)
GOLD, GOLD_L, GOLD_D = (242, 176, 74, 255), (255, 229, 154, 255), (184, 116, 42, 255)
DIM, DIM_D = (112, 98, 128, 255), (70, 60, 84, 255)
ICE, ICE_D = (159, 230, 245, 255), (58, 127, 176, 255)

GLYPHS = {
    "K": ["X...X", "X..X.", "X.X..", "XX...", "X.X..", "X..X.", "X...X"],
    "L": ["X....", "X....", "X....", "X....", "X....", "X....", "XXXXX"],
    "E": ["XXXXX", "X....", "X....", "XXXX.", "X....", "X....", "XXXXX"],
    "O": [".XXX.", "X...X", "X...X", "X...X", "X...X", "X...X", ".XXX."],
}


def glyph(letter, scale, fill, light, shade):
    rows = GLYPHS[letter]
    w, h = 5 * scale + 2, 7 * scale + 2
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = im.load()
    on = set()
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch == "X":
                for dy in range(scale):
                    for dx in range(scale):
                        on.add((1 + x * scale + dx, 1 + y * scale + dy))
    # outline: every empty pixel touching the letter
    for (x, y) in on:
        for ox in (-1, 0, 1):
            for oy in (-1, 0, 1):
                q = (x + ox, y + oy)
                if q not in on and 0 <= q[0] < w and 0 <= q[1] < h:
                    px[q] = OUT
    for (x, y) in on:
        c = fill
        if (x, y - 1) not in on:
            c = light          # lit from above
        elif (x, y + 1) not in on or (x + 1, y) not in on:
            c = shade
        px[x, y] = c
    return im


def letters():
    sheet = Image.new("RGBA", (16 * 4, 18), (0, 0, 0, 0))
    for i, k in enumerate("KLEO"):
        g = glyph(k, 2, GOLD, GOLD_L, GOLD_D)
        sheet.alpha_composite(g, (i * 16 + (16 - g.width) // 2, (18 - g.height) // 2))
    return sheet


def letter_icons():
    sheet = Image.new("RGBA", (9 * 8, 11), (0, 0, 0, 0))
    for state in range(2):
        for i, k in enumerate("KLEO"):
            g = glyph(k, 1, GOLD if state else DIM, GOLD_L if state else DIM, GOLD_D if state else DIM_D)
            sheet.alpha_composite(g, ((state * 4 + i) * 9 + 1, 1))
    return sheet


def token():
    sheet = Image.new("RGBA", (16 * 4, 16), (0, 0, 0, 0))
    for f, w in enumerate([14, 10, 4, 10]):
        im = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        x0 = (16 - w) // 2
        d.ellipse((x0, 1, x0 + w - 1, 14), fill=GOLD_D, outline=OUT)
        if w > 4:
            d.ellipse((x0 + 1, 2, x0 + w - 2, 12), fill=GOLD)
            d.arc((x0 + 1, 2, x0 + w - 2, 12), 200, 320, fill=GOLD_L)
            # the shard
            cx = 8
            hw = max(1, (w - 6) // 2)
            d.polygon([(cx, 4), (cx + hw, 8), (cx, 12), (cx - hw, 8)], fill=ICE_D, outline=ICE_D)
            d.line((cx, 5, cx, 8), fill=ICE)
            if hw > 1:
                d.point((cx - 1, 7), fill=ICE)
        else:
            d.line((x0 + 1, 3, x0 + 1, 12), fill=GOLD_L)
        sheet.alpha_composite(im, (f * 16, 0))
    return sheet


BARK, BARK_L, BARK_D = (184, 165, 138, 255), (222, 208, 182, 255), (120, 102, 84, 255)


def knot():
    """Morvath's thorn knot: pale bark, thorns round it, an amber-gold eye
    (never red). Frame 0 sleeps, frame 1 has woken."""
    sheet = Image.new("RGBA", (40, 20), (0, 0, 0, 0))
    for f in range(2):
        im = Image.new("RGBA", (20, 20), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        for a, b in [((10, 0), (10, 4)), ((2, 3), (5, 6)), ((17, 3), (14, 6)), ((0, 10), (4, 10)),
                     ((19, 10), (15, 10)), ((3, 17), (6, 14)), ((16, 17), (13, 14)), ((10, 19), (10, 15))]:
            d.line([a, b], fill=OUT, width=3)
            d.line([a, b], fill=BARK_D)
        d.ellipse((3, 3, 16, 16), fill=BARK_D, outline=OUT)
        d.ellipse((4, 4, 14, 14), fill=BARK)
        d.arc((4, 4, 14, 14), 190, 300, fill=BARK_L)
        if f == 0:
            d.arc((6, 6, 13, 12), 20, 160, fill=OUT)      # a shut lid
        else:
            d.ellipse((6, 7, 13, 12), fill=GOLD_L, outline=OUT)
            d.ellipse((8, 8, 11, 11), fill=GOLD)
            d.rectangle((9, 8, 10, 11), fill=OUT)          # the pupil
        sheet.alpha_composite(im, (f * 20, 0))
    return sheet


WOOD, WOOD_L, WOOD_D = (122, 78, 48, 255), (168, 114, 70, 255), (74, 46, 30, 255)
TEAL = (63, 224, 200, 255)


def banner():
    """The midway checkpoint: an Ironbark Guard's banner on a pole. Frame 0 is
    furled (not reached); frames 1 and 2 fly (reached), amber for safety."""
    sheet = Image.new("RGBA", (40 * 3, 64), (0, 0, 0, 0))
    for f in range(3):
        im = Image.new("RGBA", (40, 64), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        d.rectangle((5, 6, 8, 63), fill=WOOD, outline=OUT)      # the pole
        d.line((6, 7, 6, 62), fill=WOOD_L)
        d.ellipse((3, 1, 10, 8), fill=GOLD, outline=OUT)        # its finial
        d.point((5, 3), fill=GOLD_L)
        d.rectangle((2, 60, 11, 63), fill=WOOD_D, outline=OUT)  # its foot
        if f == 0:
            d.rectangle((9, 9, 13, 34), fill=GOLD_D, outline=OUT)   # furled, tied
            d.line((9, 16, 13, 16), fill=OUT)
            d.line((9, 26, 13, 26), fill=OUT)
        else:
            wave = [0, 1, 2, 1, 0, -1] if f == 1 else [1, 2, 1, 0, -1, 0]
            top = [(9 + i * 5, 9 + wave[i]) for i in range(6)]
            bot = [(9 + i * 5, 31 + wave[i]) for i in range(6)]
            tail = [(top[-1][0], top[-1][1]), (top[-1][0] - 5, 20 + wave[-1]), (bot[-1][0], bot[-1][1])]
            poly = top + [tail[1]] + list(reversed(bot))
            d.polygon(poly, fill=GOLD, outline=OUT)
            d.line(top, fill=GOLD_L)
            d.line([(x, y - 1) for x, y in bot[:-1]], fill=GOLD_D)
            cx, cy = 20, 20 + wave[2]                             # the Guard's mark: a teal leaf
            d.polygon([(cx, cy - 5), (cx + 4, cy), (cx, cy + 5), (cx - 4, cy)], fill=TEAL, outline=OUT)
        sheet.alpha_composite(im, (f * 40, 0))
    return sheet


TEAL, TEAL_L, TEAL_D = (63, 224, 200, 255), (200, 255, 244, 255), (24, 120, 124, 255)


def power_spark():
    """The Anima Spark power-up: a teal flame of Anima in a gold ring, 4 frames of 16 x 16."""
    sheet = Image.new("RGBA", (64, 16), (0, 0, 0, 0))
    for f in range(4):
        im = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        d.ellipse((1, 1, 14, 14), fill=TEAL_D, outline=OUT)
        d.ellipse((2, 2, 13, 13), outline=GOLD)
        tip = [3, 2, 3, 4][f]
        lean = [0, 1, 0, -1][f]
        d.polygon([(8 + lean, tip), (11, 9), (8, 12), (5, 9)], fill=TEAL)
        d.polygon([(8 + lean, tip + 3), (9, 9), (8, 11), (7, 9)], fill=TEAL_L)
        sheet.alpha_composite(im, (f * 16, 0))
    return sheet


def save(im, *parts):
    path = os.path.join(ROOT, *parts)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    im.save(path)
    print("wrote", os.path.normpath(path), im.size)


if __name__ == "__main__":
    # The letters, their HUD icons and the token now come from the day kit
    # (tools/make_day.py); their stand-ins above are kept for reference.
    save(power_spark(), "items", "power_spark.png")
    save(knot(), "items", "knot.png")
    save(banner(), "items", "banner.png")
