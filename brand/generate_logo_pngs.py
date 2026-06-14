"""
Genera archivos PNG del logo de Extractor URL usando Pillow.
Produce: logo-icon-100.png, logo-icon-256.png
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("ERROR: Instala Pillow — pip install Pillow", file=sys.stderr)
    sys.exit(1)

OUT_DIR = Path(__file__).parent

# Paleta de colores
BRAND_PRIMARY   = (79,  110, 247)   # #4F6EF7
BRAND_SECONDARY = (58,  86,  212)   # #3A56D4
BRAND_ACCENT    = (99,  194, 169)   # #63C2A9
WHITE           = (255, 255, 255)


def lerp_color(a: tuple, b: tuple, t: float) -> tuple:
    """Interpolación lineal entre dos colores RGB."""
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def draw_circle_aa(draw: ImageDraw.ImageDraw, center: tuple, radius: float,
                   fill: tuple, alpha: int = 255) -> None:
    """Dibuja un círculo sólido (RGBA) con antialiasing via sobreescalado."""
    cx, cy = center
    bbox = [cx - radius, cy - radius, cx + radius, cy + radius]
    draw.ellipse(bbox, fill=(*fill, alpha))


def draw_line_aa(draw: ImageDraw.ImageDraw, p1: tuple, p2: tuple,
                 fill: tuple, width: float, alpha: int = 255) -> None:
    """Dibuja una línea con el ancho especificado."""
    draw.line([p1, p2], fill=(*fill, alpha), width=int(width))


def render_logo(size: int) -> Image.Image:
    """Renderiza el LogoMark en un canvas RGBA de `size` x `size`."""
    # Sobreescalado 4× para antialiasing
    scale = 4
    S = size * scale

    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    cx, cy = S // 2, S // 2
    r = S // 2 - scale  # radio del fondo circular (1px de margen)

    # ── Fondo circular con gradiente diagonal ────────────────────────────
    # Simulamos el gradiente dibujando líneas diagonales
    for row in range(S):
        for col in range(S):
            # distancia al centro
            dx, dy = col - cx, row - cy
            dist = math.sqrt(dx * dx + dy * dy)
            if dist > r:
                continue
            # t para el gradiente diagonal (0 en top-left, 1 en bottom-right)
            t = ((col / S) + (row / S)) / 2
            color = lerp_color(BRAND_PRIMARY, BRAND_SECONDARY, t)
            img.putpixel((col, row), (*color, 255))

    draw = ImageDraw.Draw(img)

    # Parámetros internos del logo
    s         = r * 0.36          # escala de las ramas
    node_r    = s * 0.28          # radio nodo central
    dot_r     = node_r * 0.7      # radio puntos terminales
    line_w    = max(3, r * 0.09)  # grosor líneas

    # ── Nodo central ─────────────────────────────────────────────────────
    draw_circle_aa(draw, (cx, cy), node_r, WHITE)

    # ── 3 ramas (0°, 120°, 240°) ─────────────────────────────────────────
    for deg in [0, 120, 240]:
        angle = math.radians(deg)
        ex = cx + math.cos(angle) * s
        ey = cy + math.sin(angle) * s

        # Línea desde el borde del nodo hasta el extremo
        sx2 = cx + math.cos(angle) * node_r
        sy2 = cy + math.sin(angle) * node_r
        draw_line_aa(draw, (sx2, sy2), (ex, ey), WHITE, line_w, alpha=234)

        # Punto terminal mint
        draw_circle_aa(draw, (ex, ey), dot_r, BRAND_ACCENT)

    # Reducir al tamaño final con antialiasing LANCZOS
    img_out = img.resize((size, size), Image.LANCZOS)
    return img_out


def main() -> None:
    sizes = [100, 256]
    for size in sizes:
        img = render_logo(size)
        out_path = OUT_DIR / f"logo-icon-{size}.png"
        img.save(out_path, "PNG", optimize=True)
        print(f"Generado: {out_path} ({size}x{size})")


if __name__ == "__main__":
    main()
