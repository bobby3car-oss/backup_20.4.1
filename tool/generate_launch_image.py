#!/usr/bin/env python3
"""
Generates the launch_image.png for Operationsbegleiter.
Design matches the app's splash screen:
  - Light blue radial gradient background
  - Centered shield logo
  - "Operationsbegleiter" title
  - Subtitle text
"""

import math
import os
import sys
from PIL import Image, ImageDraw, ImageFont

# ── Paths (script can be run from any directory) ─────────────────────────────
_HERE = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.dirname(_HERE)

# Canvas size (high-res, covers iPhone 14 Pro Max @3x + large Android)
W, H = 1242, 2688

# ── Background gradient ──────────────────────────────────────────────────────
def lerp(a, b, t):
    return int(a + (b - a) * t)

def gradient_color(t):
    t = max(0.0, min(1.0, t))
    if t < 0.55:
        s = t / 0.55
        r = lerp(235, 200, s)
        g = lerp(245, 223, s)
        b = lerp(255, 242, s)
    else:
        s = (t - 0.55) / 0.45
        r = lerp(200, 155, s)
        g = lerp(223, 195, s)
        b = lerp(242, 228, s)
    return (r, g, b, 255)

cx = W / 2
cy = H * 0.38
max_dist = math.sqrt((W * 0.75) ** 2 + (H * 0.75) ** 2)

# Fast gradient: compute at 1/8 scale, then upscale (100× faster, same quality)
SCALE = 8
W_s = max(1, W // SCALE)
H_s = max(1, H // SCALE)
cx_s = cx / SCALE
cy_s = cy / SCALE
max_dist_s = max_dist / SCALE

colors = []
for y in range(H_s):
    for x in range(W_s):
        dx = x - cx_s
        dy = y - cy_s
        dist = math.sqrt(dx * dx + dy * dy) / max_dist_s
        colors.append(gradient_color(dist))

img_small = Image.new("RGBA", (W_s, H_s))
img_small.putdata(colors)
img = img_small.resize((W, H), Image.Resampling.BILINEAR)

# ── Logo ─────────────────────────────────────────────────────────────────────
logo_path = os.path.join(_ROOT, "assets", "images", "app_logo.png")
if not os.path.exists(logo_path):
    print(f"❌  Logo nicht gefunden: {logo_path}", file=sys.stderr)
    sys.exit(1)

logo = Image.open(logo_path).convert("RGBA")
logo_size = int(W * 0.42)
logo = logo.resize((logo_size, logo_size), Image.Resampling.LANCZOS)

logo_x = (W - logo_size) // 2
logo_y = int(H * 0.20)
img.paste(logo, (logo_x, logo_y), logo)

# ── Text ─────────────────────────────────────────────────────────────────────
draw = ImageDraw.Draw(img)

# Font candidates – uses first path that exists
_FONT_CANDIDATES_BOLD = [
    "/System/Library/Fonts/Supplemental/Trebuchet MS Bold.ttf",
    "/Library/Fonts/Trebuchet MS Bold.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
]
_FONT_CANDIDATES_REG = [
    "/System/Library/Fonts/Supplemental/Trebuchet MS.ttf",
    "/Library/Fonts/Trebuchet MS.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
]

def _load_font(candidates: list, size: int) -> ImageFont.FreeTypeFont:
    for path in candidates:
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    # Ultimate fallback: Pillow built-in (no TTF required)
    print(f"⚠️  Keine Trebuchet-Schriftart gefunden – nutze Standard-Font", file=sys.stderr)
    return ImageFont.load_default(size=size)

title_size = 92
sub_size   = 52

font_title = _load_font(_FONT_CANDIDATES_BOLD, title_size)
font_sub   = _load_font(_FONT_CANDIDATES_REG,  sub_size)

title_text = "Operationsbegleiter"
sub_text   = "Dein Begleiter vor und\nnach der Operation"

color_title = (52,  63,  80,  255)
color_sub   = (90, 110, 130, 255)

# Title – centred below logo
title_bbox = draw.textbbox((0, 0), title_text, font=font_title)
title_w = title_bbox[2] - title_bbox[0]
title_x = (W - title_w) // 2
title_y = logo_y + logo_size + int(H * 0.045)

draw.text((title_x, title_y), title_text, font=font_title, fill=color_title)

# Subtitle – use multiline_textbbox for correct width of multi-line text
sub_bbox = draw.multiline_textbbox((0, 0), sub_text, font=font_sub,
                                   align="center", spacing=18)
sub_w = sub_bbox[2] - sub_bbox[0]
sub_x = (W - sub_w) // 2
sub_y = title_y + title_size + int(H * 0.020)

draw.multiline_text(
    (sub_x, sub_y),
    sub_text,
    font=font_sub,
    fill=color_sub,
    align="center",
    spacing=18,
)

# ── Save ─────────────────────────────────────────────────────────────────────
out_path = os.path.join(_ROOT, "assets", "images", "launch_image.png")
img.convert("RGB").save(out_path, "PNG", optimize=True)
print(f"✅  Saved {out_path}  ({W}×{H} px)")
