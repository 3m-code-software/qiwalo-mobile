"""توليد أيقونة تطبيق قيوالو (كحلي/ذهبي) لكل كثافات أندرويد، بدون حزم إضافية."""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / "android" / "app" / "src" / "main" / "res"
DOCS = ROOT / "docs" / "design"

NAVY = (11, 35, 65, 255)
NAVY_SOLID = (11, 35, 65)
GOLD = (201, 162, 39, 255)

DENSITIES = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}

FONT_CANDIDATES = [
    Path(r"C:\Windows\Fonts\arialbd.ttf"),
    Path(r"C:\Windows\Fonts\segoeuib.ttf"),
    Path(r"C:\Windows\Fonts\tahomabd.ttf"),
]


def base_icon(size: int = 512, transparent: bool = False) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0) if transparent else NAVY)
    draw = ImageDraw.Draw(img)
    unit = size / 512
    inset = int(56 * unit)
    draw.ellipse(
        (inset, inset, size - inset, size - inset),
        outline=GOLD,
        width=max(2, int(22 * unit)),
    )

    font_path = next((p for p in FONT_CANDIDATES if p.exists()), None)
    if font_path is None:
        raise RuntimeError("No Arabic-capable bold font found")
    font = ImageFont.truetype(str(font_path), int(300 * unit))
    text = "ق"
    box = draw.textbbox((0, 0), text, font=font)
    x = (size - (box[2] - box[0])) / 2 - box[0]
    y = (size - (box[3] - box[1])) / 2 - box[1]
    draw.text((x, y), text, font=font, fill=GOLD)
    return img


def round_icon(img: Image.Image) -> Image.Image:
    size = img.size[0]
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, size - 1, size - 1), fill=255)
    out = img.copy()
    out.putalpha(mask)
    return out


def main() -> None:
    full = base_icon()
    DOCS.mkdir(parents=True, exist_ok=True)
    full.save(DOCS / "app-icon.png")

    # الأيقونة القديمة (legacy) للإصدارات الأقل من Android 8
    for density, size in DENSITIES.items():
        folder = RES / f"mipmap-{density}"
        folder.mkdir(parents=True, exist_ok=True)
        scaled = full.resize((size, size), Image.Resampling.LANCZOS)
        scaled.save(folder / "ic_launcher.png")
        round_icon(scaled).save(folder / "ic_launcher_round.png")

    # الأيقونة التكيفية (adaptive) — المحتوى داخل الدائرة الآمنة الوسطى ٦٦٪
    safe = int(512 * 0.66)
    offset = (512 - safe) // 2
    foreground = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    foreground.paste(base_icon(512, transparent=True).resize((safe, safe), Image.Resampling.LANCZOS), (offset, offset))
    for density, size in DENSITIES.items():
        folder = RES / f"mipmap-{density}"
        foreground.resize((size, size), Image.Resampling.LANCZOS).save(folder / "ic_launcher_foreground.png")

    print("Generated launcher icons for:", ", ".join(DENSITIES))


if __name__ == "__main__":
    main()
