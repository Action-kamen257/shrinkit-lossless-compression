import os
from PIL import Image, ImageDraw, ImageFont

def create_shrinkit_icon(output_ico_path, output_png_path):
    # Render at 2048x2048 for supersampling (4x of 512x512)
    canvas_size = 2048
    s = canvas_size / 512.0

    img = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Background Squircle
    pad = int(18 * s)
    radius = int(112 * s)
    bg_box = [pad, pad, canvas_size - pad, canvas_size - pad]
    
    # Outer dark graphite fill
    draw.rounded_rectangle(bg_box, radius=radius, fill=(12, 12, 15, 255), outline=(255, 255, 255, 32), width=int(2.5 * s))

    # Inner subtle glow
    inner_pad = int(24 * s)
    inner_radius = int(106 * s)
    draw.rounded_rectangle([inner_pad, inner_pad, canvas_size - inner_pad, canvas_size - inner_pad],
                           radius=inner_radius, outline=(255, 255, 255, 12), width=int(1.5 * s))

    # 2. Left: BIG FILE (Raw document)
    # 512 coords: x0=68, y0=116, x1=214, y1=396 -> width=146, height=280
    bx0, by0, bx1, by1 = int(68 * s), int(116 * s), int(214 * s), int(396 * s)
    bfold = int(44 * s)

    # Big file shadow
    shadow_offset = int(8 * s)
    draw.rounded_rectangle([bx0, by0 + shadow_offset, bx1, by1 + shadow_offset], radius=int(14 * s), fill=(0, 0, 0, 90))

    # Big file body
    big_poly = [
        (bx0 + int(14 * s), by0),
        (bx1 - bfold, by0),
        (bx1, by0 + bfold),
        (bx1, by1 - int(14 * s)),
        (bx1 - int(14 * s), by1),
        (bx0 + int(14 * s), by1),
        (bx0, by1 - int(14 * s)),
        (bx0, by0 + int(14 * s))
    ]
    draw.polygon(big_poly, fill=(36, 36, 44, 255), outline=(113, 113, 122, 255))
    draw.line(big_poly + [big_poly[0]], fill=(113, 113, 122, 255), width=int(3 * s))

    # Big file dog-ear flap
    big_flap = [
        (bx1 - bfold, by0),
        (bx1 - bfold, by0 + bfold - int(8 * s)),
        (bx1 - bfold + int(8 * s), by0 + bfold),
        (bx1, by0 + bfold)
    ]
    draw.polygon(big_flap, fill=(63, 63, 70, 255), outline=(161, 161, 170, 255))
    draw.line(big_flap + [big_flap[0]], fill=(161, 161, 170, 255), width=int(2.5 * s))

    # Big file content lines (data stream)
    for ly in [186, 218, 250, 282, 314]:
        lw = 110 if ly != 250 and ly != 314 else 75
        lx0 = int(88 * s)
        lx1 = int((88 + lw) * s)
        ly_pos = int(ly * s)
        lh = int(7 * s)
        draw.rounded_rectangle([lx0, ly_pos, lx1, ly_pos + lh], radius=int(3.5 * s), fill=(255, 255, 255, 60))

    # Big file "RAW" pill badge
    badge_x0, badge_y0 = int(88 * s), int(346 * s)
    badge_x1, badge_y1 = int(148 * s), int(372 * s)
    draw.rounded_rectangle([badge_x0, badge_y0, badge_x1, badge_y1], radius=int(5 * s), fill=(24, 24, 27, 255), outline=(113, 113, 122, 200), width=int(1.5 * s))

    # 3. Center: CRISP ARROW (Compression Vector)
    arrow_y = int(256 * s)
    ax_start = int(232 * s)
    ax_end = int(294 * s)
    arrow_w = int(11 * s)

    # Shaft
    draw.line([(ax_start, arrow_y), (ax_end, arrow_y)], fill=(255, 255, 255, 255), width=arrow_w)
    
    # Arrow head
    head_len = int(22 * s)
    head_h = int(20 * s)
    draw.line([(ax_end - head_len, arrow_y - head_h), (ax_end + int(2 * s), arrow_y)], fill=(255, 255, 255, 255), width=arrow_w)
    draw.line([(ax_end - head_len, arrow_y + head_h), (ax_end + int(2 * s), arrow_y)], fill=(255, 255, 255, 255), width=arrow_w)

    # 4. Right: SMALL FILE (Compressed .huff Archive)
    # 512 coords: x0=316, y0=168, x1=436, y1=360 -> width=120, height=192
    sx0, sy0, sx1, sy1 = int(316 * s), int(168 * s), int(436 * s), int(360 * s)
    sfold = int(36 * s)

    # Small file shadow
    draw.rounded_rectangle([sx0, sy0 + shadow_offset, sx1, sy1 + shadow_offset], radius=int(12 * s), fill=(0, 0, 0, 90))

    # Small file body (Bright Pure White / High Contrast)
    small_poly = [
        (sx0 + int(12 * s), sy0),
        (sx1 - sfold, sy0),
        (sx1, sy0 + sfold),
        (sx1, sy1 - int(12 * s)),
        (sx1 - int(12 * s), sy1),
        (sx0 + int(12 * s), sy1),
        (sx0, sy1 - int(12 * s)),
        (sx0, sy0 + int(12 * s))
    ]
    draw.polygon(small_poly, fill=(255, 255, 255, 255), outline=(228, 228, 231, 255))
    draw.line(small_poly + [small_poly[0]], fill=(255, 255, 255, 255), width=int(2.5 * s))

    # Small file dog-ear flap
    small_flap = [
        (sx1 - sfold, sy0),
        (sx1 - sfold, sy0 + sfold - int(6 * s)),
        (sx1 - sfold + int(6 * s), sy0 + sfold),
        (sx1, sy0 + sfold)
    ]
    draw.polygon(small_flap, fill=(212, 212, 216, 255), outline=(161, 161, 170, 255))
    draw.line(small_flap + [small_flap[0]], fill=(212, 212, 216, 255), width=int(2 * s))

    # Small file content lines (compressed binary tokens)
    for ly in [224, 250, 276]:
        lw = 84 if ly != 276 else 55
        lx0 = int(334 * s)
        lx1 = int((334 + lw) * s)
        ly_pos = int(ly * s)
        lh = int(7 * s)
        draw.rounded_rectangle([lx0, ly_pos, lx1, ly_pos + lh], radius=int(3.5 * s), fill=(36, 36, 44, 255))

    # Small file ".HUFF" pill badge
    sbadge_x0, sbadge_y0 = int(334 * s), int(308 * s)
    sbadge_x1, sbadge_y1 = int(404 * s), int(336 * s)
    draw.rounded_rectangle([sbadge_x0, sbadge_y0, sbadge_x1, sbadge_y1], radius=int(5 * s), fill=(24, 24, 27, 255), outline=(63, 63, 70, 200), width=int(1.5 * s))

    # Downscale smoothly to 512x512
    final_512 = img.resize((512, 512), Image.Resampling.LANCZOS)
    
    # Save high-res PNG
    os.makedirs(os.path.dirname(output_png_path), exist_ok=True)
    final_512.save(output_png_path, "PNG")
    print(f"Saved PNG to {output_png_path}")

    # Generate multi-resolution Windows ICO (256, 128, 64, 48, 32, 24, 16)
    sizes = [(256, 256), (128, 128), (64, 64), (48, 48), (32, 32), (24, 24), (16, 16)]
    final_512.save(output_ico_path, format="ICO", sizes=sizes)
    print(f"Saved ICO to {output_ico_path} with {len(sizes)} resolutions")

if __name__ == "__main__":
    ico_dest = r"c:\Users\Tushar\OneDrive\Desktop\daa project\src\ui\assets\app_icon.ico"
    png_dest = r"c:\Users\Tushar\OneDrive\Desktop\daa project\src\ui\assets\app_icon.png"
    create_shrinkit_icon(ico_dest, png_dest)
