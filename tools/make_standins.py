"""Stand-in sprites drawn here until the creative lead's Book 4 kit brings the
real ones (each is listed in Book 4):

  game/assets/items/letters.png     4 frames of 16 x 18: K, L, E, O, gold (in the world)
  game/assets/ui/letter_icons.png   8 frames of 9 x 11: K L E O dim, then lit (the HUD)
  game/assets/items/token.png       4 frames of 16 x 16: the bonus token, turning

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


def save(im, *parts):
    path = os.path.join(ROOT, *parts)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    im.save(path)
    print("wrote", os.path.normpath(path), im.size)


if __name__ == "__main__":
    save(letters(), "items", "letters.png")
    save(letter_icons(), "ui", "letter_icons.png")
    save(token(), "items", "token.png")
