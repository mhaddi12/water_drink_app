#!/usr/bin/env python3
"""Build white Hydra native splash assets: HD icon + Hydra wordmark."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

WHITE = (255, 255, 255, 255)
INK = (20, 48, 100, 255)
TEAL = (0, 140, 160, 255)
ROOT = Path(__file__).resolve().parents[1]
BRANDING = ROOT / 'assets/branding'
ICON_SRC = BRANDING / 'app_icon.png'
if not ICON_SRC.exists():
    ICON_SRC = ROOT / 'tool/branding/device_splashes/icon.png'

FONT_CANDIDATES = [
    '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
    '/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf',
    '/usr/share/fonts/truetype/ubuntu/Ubuntu-B.ttf',
]


def _load_font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    for path in FONT_CANDIDATES:
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def make_hd_icon(out_path: Path, size: int = 1024) -> None:
    src = Image.open(ICON_SRC).convert('RGBA')
    hd = src.resize((size, size), Image.Resampling.LANCZOS)
    hd.save(out_path, format='PNG', optimize=True)


def make_android12_icon(out_path: Path, size: int = 1152) -> None:
    icon = Image.open(BRANDING / 'splash_icon_hd.png').convert('RGBA')
    canvas = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    max_side = int(size * 0.62)
    fitted = icon.copy()
    fitted.thumbnail((max_side, max_side), Image.Resampling.LANCZOS)
    ox = (size - fitted.width) // 2
    oy = (size - fitted.height) // 2 - int(size * 0.04)
    canvas.paste(fitted, (ox, oy), fitted)
    canvas.save(out_path, format='PNG', optimize=True)


def make_branding_wordmark(out_path: Path, width: int = 800, height: int = 320) -> None:
    canvas = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)
    text = 'Hydra'
    font = _load_font(88)
    bbox = draw.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    x = (width - tw) // 2
    y = (height - th) // 2 + 24
    draw.text((x, y), text, font=font, fill=INK)
  # subtle accent underline
    line_y = y + th + 10
    draw.rounded_rectangle(
        (x, line_y, x + tw, line_y + 5),
        radius=2,
        fill=TEAL,
    )
    canvas.save(out_path, format='PNG', optimize=True)


def main() -> None:
    if not ICON_SRC.exists():
        raise SystemExit(f'Missing icon source: {ICON_SRC}')

    BRANDING.mkdir(parents=True, exist_ok=True)
    make_hd_icon(BRANDING / 'splash_icon_hd.png')
    make_android12_icon(BRANDING / 'splash_android12_icon.png')
    make_branding_wordmark(BRANDING / 'splash_branding_hydra.png')
    print(
        'Wrote splash_icon_hd.png, splash_android12_icon.png, splash_branding_hydra.png'
    )


if __name__ == '__main__':
    main()
