"""Builds the Play Store images from the raw app renders.
Run after: flutter test tool/store_screenshots_test.dart
Output: playstore/screenshots/phone-N.png, feature-graphic.png, app-icon-512.png
"""
from PIL import Image, ImageChops, ImageDraw, ImageFont, ImageFilter
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "playstore")
RAW = os.path.join(OUT, "screenshots", "raw")
FLUTTER = os.popen("dirname $(dirname $(which flutter))").read().strip()
ROBOTO_BLACK = f"{FLUTTER}/bin/cache/artifacts/material_fonts/Roboto-Black.ttf"
ROBOTO_MED = f"{FLUTTER}/bin/cache/artifacts/material_fonts/Roboto-Medium.ttf"
TINOS_BOLD = os.path.join(ROOT, "assets/fonts/Tinos-Bold.ttf")

FOREST, LEAF, ROOF = (27, 94, 32), (76, 154, 42), (247, 148, 29)


def gradient(size, c1, c2):
    """Smooth top-left -> bottom-right gradient."""
    w, h = size
    g = Image.linear_gradient("L")
    v = g.resize(size, Image.BICUBIC)
    hz = g.rotate(90).resize(size, Image.BICUBIC)
    mask = ImageChops.add(v, hz, scale=2)
    return Image.composite(Image.new("RGB", size, c2), Image.new("RGB", size, c1), mask)


def rounded(im, radius):
    im = im.convert("RGBA")
    m = Image.new("L", im.size, 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, *im.size), radius, fill=255)
    im.putalpha(m)
    return im


def shadow(size, radius, blur, alpha=90):
    pad = blur * 3
    s = Image.new("RGBA", (size[0] + pad * 2, size[1] + pad * 2), (0, 0, 0, 0))
    ImageDraw.Draw(s).rounded_rectangle(
        (pad, pad, pad + size[0], pad + size[1]), radius, fill=(0, 0, 0, alpha))
    return s.filter(ImageFilter.GaussianBlur(blur)), pad


def phone(img, width, radius_ratio=0.07, bezel=0):
    """Screenshot with rounded corners and a soft shadow, as RGBA."""
    h = round(img.height * width / img.width)
    shot = rounded(img.resize((width, h), Image.LANCZOS), round(width * radius_ratio))
    sh, pad = shadow((width, h), round(width * radius_ratio), 28)
    canvas = Image.new("RGBA", sh.size, (0, 0, 0, 0))
    canvas.alpha_composite(sh, (0, 14))
    canvas.alpha_composite(shot, (pad, pad))
    return canvas, pad


CAPTIONS = [
    ("Find trusted workers", "near you", "Electricians, plumbers, carpenters and many more"),
    ("Browse local workers", "in your city", "Ratings, experience and availability at a glance"),
    ("Check profiles", "before you hire", "Call or message a worker in one tap"),
    ("You decide how", "customers reach you", "Control who sees your number and who can message"),
]
RAW_FILES = ["01_home", "02_workers", "03_detail", "04_profile"]


def screenshots():
    os.makedirs(os.path.join(OUT, "screenshots"), exist_ok=True)
    for i, (name, (l1, l2, sub)) in enumerate(zip(RAW_FILES, CAPTIONS), 1):
        raw = Image.open(os.path.join(RAW, name + ".png")).convert("RGB")
        W, H = 1080, 1920
        bg = gradient((W, H), FOREST, LEAF).convert("RGBA")
        d = ImageDraw.Draw(bg)
        big = ImageFont.truetype(ROBOTO_BLACK, 84)
        small = ImageFont.truetype(ROBOTO_MED, 38)
        d.text((W / 2, 150), l1, font=big, fill="white", anchor="mm")
        d.text((W / 2, 250), l2, font=big, fill=(255, 214, 153), anchor="mm")
        d.text((W / 2, 335), sub, font=small, fill=(225, 240, 222), anchor="mm")
        card, pad = phone(raw, 820)
        bg.alpha_composite(card, ((W - 820) // 2 - pad, 400 - pad))
        bg.convert("RGB").save(os.path.join(OUT, "screenshots", f"phone-{i}.png"), optimize=True)


def feature_graphic():
    W, H = 1024, 500
    bg = gradient((W, H), FOREST, LEAF).convert("RGBA")
    # soft orange glow, bottom right
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse((560, 120, 1100, 640), fill=(*ROOF, 70))
    bg.alpha_composite(glow.filter(ImageFilter.GaussianBlur(60)))

    # logo on a white round card
    logo = Image.open(os.path.join(ROOT, "assets/logo.png")).convert("RGB").resize((230, 230), Image.LANCZOS)
    card = Image.new("RGBA", (260, 260), (0, 0, 0, 0))
    ImageDraw.Draw(card).rounded_rectangle((0, 0, 259, 259), 56, fill="white")
    card.alpha_composite(rounded(logo, 44), (15, 15))
    sh, pad = shadow((260, 260), 56, 18, 80)
    bg.alpha_composite(sh, (48 - pad, 70 - pad + 10))
    bg.alpha_composite(card, (48, 70))

    d = ImageDraw.Draw(bg)
    chip_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    cd = ImageDraw.Draw(chip_layer)
    d.text((340, 108), "Sahayi", font=ImageFont.truetype(ROBOTO_BLACK, 104), fill="white", anchor="lm")
    d.text((342, 192), "Reliable service, now at your home too.",
           font=ImageFont.truetype(TINOS_BOLD, 28), fill=(255, 214, 153), anchor="lm")
    # service chips
    chips = ["Electrician", "Plumber", "Carpenter", "Painter", "Cleaner", "AC Repair"]
    f = ImageFont.truetype(ROBOTO_MED, 22)
    x, y = 342, 250
    for c in chips:
        w = d.textlength(c, font=f) + 36
        if x + w > 770:
            x, y = 342, y + 54
        cd.rounded_rectangle((x, y, x + w, y + 42), 21, fill=(255, 255, 255, 45), outline=(255, 255, 255, 140), width=2)
        cd.text((x + w / 2, y + 21), c, font=f, fill="white", anchor="mm")
        x += w + 12
    bg.alpha_composite(chip_layer)
    d = ImageDraw.Draw(bg)
    d.text((342, 420), "Find skilled workers near you", font=ImageFont.truetype(ROBOTO_MED, 26),
           fill=(225, 240, 222), anchor="lm")

    # two phones on the right
    for name, w, rot, pos in [("02_workers", 250, -6, (700, 120)), ("01_home", 270, 5, (800, 60))]:
        raw = Image.open(os.path.join(RAW, name + ".png")).convert("RGB")
        p, pad = phone(raw, w)
        p = p.rotate(rot, resample=Image.BICUBIC, expand=True)
        bg.alpha_composite(p, pos)
    bg.convert("RGB").save(os.path.join(OUT, "feature-graphic.png"), optimize=True)


def icon():
    im = Image.open(os.path.join(ROOT, "assets/logo.png")).convert("RGBA").resize((512, 512), Image.LANCZOS)
    im.save(os.path.join(OUT, "app-icon-512.png"), optimize=True)


if __name__ == "__main__":
    screenshots()
    feature_graphic()
    icon()
    print("done")
