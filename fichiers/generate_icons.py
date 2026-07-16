from PIL import Image, ImageDraw
import os

sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

employes_res = (
    "C:/Users/Utilisateur/Documents/Ben/Kassa/yabisso_employes/android/app/src/main/res"
)
admin_res = (
    "C:/Users/Utilisateur/Documents/Ben/Kassa/yabisso_admin/android/app/src/main/res"
)


def draw_rounded_rect(draw, bbox, radius, fill):
    x0, y0, x1, y1 = bbox
    draw.rounded_rectangle(bbox, radius=radius, fill=fill)


def draw_line(draw, x1, y1, x2, y2, color, width):
    draw.line([(x1, y1), (x2, y2)], fill=color, width=width)


def draw_circle(draw, cx, cy, r, color):
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=color)


def render_icon(size, letter):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    s = size / 512.0

    # Fond arrondi sombre
    draw_rounded_rect(
        draw, [0, 0, size - 1, size - 1], int(96 * s), (0x15, 0x15, 0x1F, 255)
    )

    lw = int(46 * s)
    cr = int(34 * s)

    if letter == "E":
        # Barre verticale bleue
        draw_line(
            draw,
            int(176 * s),
            int(120 * s),
            int(176 * s),
            int(392 * s),
            (0x3E, 0x6B, 0xF6, 255),
            lw,
        )
        # Bras supérieur rouge
        draw_line(
            draw,
            int(176 * s),
            int(140 * s),
            int(366 * s),
            int(140 * s),
            (0xEA, 0x43, 0x35, 255),
            lw,
        )
        # Bras médian vert
        draw_line(
            draw,
            int(176 * s),
            int(256 * s),
            int(336 * s),
            int(256 * s),
            (0x34, 0xA8, 0x53, 255),
            lw,
        )
        # Bras inférieur jaune + point
        draw_line(
            draw,
            int(176 * s),
            int(372 * s),
            int(252 * s),
            int(372 * s),
            (0xFB, 0xBC, 0x05, 255),
            lw,
        )
        draw_circle(draw, int(298 * s), int(372 * s), cr, (0xFB, 0xBC, 0x05, 255))
    else:
        # Jambe gauche bleue
        draw_line(
            draw,
            int(256 * s),
            int(120 * s),
            int(156 * s),
            int(392 * s),
            (0x3E, 0x6B, 0xF6, 255),
            lw,
        )
        # Jambe droite rouge
        draw_line(
            draw,
            int(256 * s),
            int(120 * s),
            int(330 * s),
            int(344 * s),
            (0xEA, 0x43, 0x35, 255),
            lw,
        )
        # Point jaune
        draw_circle(draw, int(348 * s), int(368 * s), cr, (0xFB, 0xBC, 0x05, 255))
        # Barre transversale verte
        draw_line(
            draw,
            int(197 * s),
            int(280 * s),
            int(315 * s),
            int(280 * s),
            (0x34, 0xA8, 0x53, 255),
            lw,
        )

    return img


for dir_name, sz in sizes.items():
    for letter, res_dir in [("E", employes_res), ("A", admin_res)]:
        d = os.path.join(res_dir, dir_name)
        os.makedirs(d, exist_ok=True)
        img = render_icon(sz, letter)
        for name in ["ic_launcher.png", "ic_launcher_round.png"]:
            img.save(os.path.join(d, name))
        print(f"{letter} {dir_name} ({sz}) OK")

print("DONE")
