#!/usr/bin/env python3
"""Generate TTNS Roku splash, posters, and a square circular logo."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
IMAGES = ROOT / "images"
BG = (10, 10, 10)
GREEN = (0, 255, 0)
WHITE = (246, 247, 244)
SOURCE_NAMES = ("ttns-logo-source.png", "ttns-logo-source.jpg")
LOGO = IMAGES / "ttns-logo.png"


def find_source() -> Path:
    for name in SOURCE_NAMES:
        path = IMAGES / name
        if path.exists():
            return path
    raise SystemExit("missing logo source: images/ttns-logo-source.png or .jpg")


def font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial Bold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    ]
    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def draw_centered(draw: ImageDraw.ImageDraw, box, text: str, fill, size: int) -> None:
    f = font(size)
    x0, y0, x1, y1 = box
    bbox = draw.textbbox((0, 0), text, font=f)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    x = x0 + (x1 - x0 - tw) / 2
    y = y0 + (y1 - y0 - th) / 2
    draw.text((x, y), text, font=f, fill=fill)


def punch_black_to_alpha(im: Image.Image, threshold: int = 16) -> Image.Image:
    """Turn a black-backed JPEG/PNG into a real transparent mark."""
    im = im.convert("RGBA")
    pixels = list(im.getdata())
    opaque = 0
    for r, _g, _b, a in pixels:
        if a > 16 and max(r, _g, _b) > threshold:
            opaque += 1
    if opaque > 0 and im.mode == "RGBA":
        # Keep existing alpha if the file already has a real hole count.
        alpha_vals = [p[3] for p in pixels]
        if min(alpha_vals) < 8 and max(alpha_vals) > 200:
            return im
    out = []
    soft = 22
    for r, g, b, _a in pixels:
        mx = max(r, g, b)
        if mx <= threshold:
            out.append((r, g, b, 0))
        elif mx < threshold + soft:
            alpha = int(255 * (mx - threshold) / soft)
            out.append((r, g, b, alpha))
        else:
            out.append((r, g, b, 255))
    im.putdata(out)
    return im


def logo_bbox(im: Image.Image, threshold: int = 20) -> tuple[int, int, int, int]:
    px = im.load()
    w, h = im.size
    minx, miny, maxx, maxy = w, h, -1, -1
    for y in range(h):
        for x in range(w):
            pixel = px[x, y]
            r, g, b = pixel[0], pixel[1], pixel[2]
            a = pixel[3] if len(pixel) > 3 else 255
            if a > 12 and max(r, g, b) > threshold:
                if x < minx:
                    minx = x
                if y < miny:
                    miny = y
                if x > maxx:
                    maxx = x
                if y > maxy:
                    maxy = y
    if maxx < 0:
        return (0, 0, w, h)
    return (minx, miny, maxx + 1, maxy + 1)


def write_square_logo(src: Path, dest: Path, size: int = 512) -> None:
    im = punch_black_to_alpha(Image.open(src))
    left, top, right, bottom = logo_bbox(im)
    cx = (left + right) / 2
    cy = (top + bottom) / 2
    side = max(right - left, bottom - top) + 16
    x0 = int(round(cx - side / 2))
    y0 = int(round(cy - side / 2))
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.paste(im, (-x0, -y0), im)
    out = canvas.resize((size, size), Image.Resampling.LANCZOS)
    dest.parent.mkdir(parents=True, exist_ok=True)
    out.save(dest)


def load_logo(max_side: int) -> Image.Image:
    im = Image.open(LOGO).convert("RGBA")
    im.thumbnail((max_side, max_side), Image.Resampling.LANCZOS)
    return im


def paste_logo(base: Image.Image, logo: Image.Image, xy: tuple[int, int]) -> None:
    base.paste(logo, xy, logo)


def splash(size: tuple[int, int], dest: Path) -> None:
    im = Image.new("RGB", size, BG)
    draw = ImageDraw.Draw(im)
    w, h = size
    logo = load_logo(max(160, w // 6))
    lx = (w - logo.width) // 2
    ly = int(h * 0.16)
    paste_logo(im, logo, (lx, ly))
    text_top = ly + logo.height + int(h * 0.04)
    draw.rectangle((int(w * 0.35), text_top, int(w * 0.65), text_top + 6), fill=GREEN)
    draw_centered(draw, (0, text_top + 16, w, text_top + int(h * 0.14)), "TTNS FM", GREEN, max(40, w // 14))
    draw_centered(draw, (0, text_top + int(h * 0.14), w, text_top + int(h * 0.24)), "Live radio  -  Local gigs", WHITE, max(16, w // 30))
    dest.parent.mkdir(parents=True, exist_ok=True)
    im.save(dest, quality=92)


def poster(size: tuple[int, int], dest: Path) -> None:
    """Required Roku sizes, but never stretch the circular mark."""
    im = Image.new("RGB", size, BG)
    w, h = size
    max_side = int(min(w, h) * 0.92)
    logo = load_logo(max_side)
    x = (w - logo.width) // 2
    y = (h - logo.height) // 2
    paste_logo(im, logo, (x, y))
    dest.parent.mkdir(parents=True, exist_ok=True)
    im.save(dest)


def spinner(dest: Path) -> None:
    size = 128
    im = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    pad = 12
    box = [pad, pad, size - pad - 1, size - pad - 1]
    draw.arc(box, start=-50, end=240, fill=(0, 255, 0, 255), width=14)
    dest.parent.mkdir(parents=True, exist_ok=True)
    im.save(dest)


def fallback(dest: Path) -> None:
    size = (720, 720)
    im = Image.new("RGB", size, BG)
    logo = load_logo(520)
    paste_logo(im, logo, ((size[0] - logo.width) // 2, (size[1] - logo.height) // 2))
    dest.parent.mkdir(parents=True, exist_ok=True)
    im.save(dest)


def main() -> None:
    write_square_logo(find_source(), LOGO, 512)
    splash((1920, 1080), IMAGES / "splash-screen_fhd.jpg")
    splash((1280, 720), IMAGES / "splash-screen_hd.jpg")
    splash((720, 480), IMAGES / "splash-screen_sd.jpg")
    # Home-row slot is ~4:3. The old 336x210 / 246x140 docs squash a circle.
    poster((540, 405), IMAGES / "channel-poster_fhd.png")
    poster((290, 218), IMAGES / "channel-poster_hd.png")
    poster((214, 144), IMAGES / "channel-poster_sd.png")
    fallback(IMAGES / "artwork-fallback.png")
    spinner(IMAGES / "spinner.png")
    print(f"wrote images in {IMAGES}")


if __name__ == "__main__":
    main()
