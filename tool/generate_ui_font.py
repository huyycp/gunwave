#!/usr/bin/env python3
"""Build the in-house 5x7 UI font atlas and its Flame glyph metadata."""

import json
import math
import struct
import unicodedata
import zlib
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets/images/ui/fonts"
CELL_WIDTH = 8
CELL_HEIGHT = 14
COLUMNS = 16

# Each character is authored as seven 5-pixel rows. This is a tiny original
# bitmap font designed to stay readable at small Flame HUD sizes.
FONT = {
    "A": ("01110", "10001", "10001", "11111", "10001", "10001", "10001"),
    "B": ("11110", "10001", "10001", "11110", "10001", "10001", "11110"),
    "C": ("01111", "10000", "10000", "10000", "10000", "10000", "01111"),
    "D": ("11110", "10001", "10001", "10001", "10001", "10001", "11110"),
    "E": ("11111", "10000", "10000", "11110", "10000", "10000", "11111"),
    "F": ("11111", "10000", "10000", "11110", "10000", "10000", "10000"),
    "G": ("01111", "10000", "10000", "10111", "10001", "10001", "01111"),
    "H": ("10001", "10001", "10001", "11111", "10001", "10001", "10001"),
    "I": ("11111", "00100", "00100", "00100", "00100", "00100", "11111"),
    "J": ("00111", "00010", "00010", "00010", "10010", "10010", "01100"),
    "K": ("10001", "10010", "10100", "11000", "10100", "10010", "10001"),
    "L": ("10000", "10000", "10000", "10000", "10000", "10000", "11111"),
    "M": ("10001", "11011", "10101", "10101", "10001", "10001", "10001"),
    "N": ("10001", "11001", "11001", "10101", "10011", "10011", "10001"),
    "O": ("01110", "10001", "10001", "10001", "10001", "10001", "01110"),
    "P": ("11110", "10001", "10001", "11110", "10000", "10000", "10000"),
    "Q": ("01110", "10001", "10001", "10001", "10101", "10010", "01101"),
    "R": ("11110", "10001", "10001", "11110", "10100", "10010", "10001"),
    "S": ("01111", "10000", "10000", "01110", "00001", "00001", "11110"),
    "T": ("11111", "00100", "00100", "00100", "00100", "00100", "00100"),
    "U": ("10001", "10001", "10001", "10001", "10001", "10001", "01110"),
    "V": ("10001", "10001", "10001", "10001", "10001", "01010", "00100"),
    "W": ("10001", "10001", "10001", "10101", "10101", "11011", "10001"),
    "X": ("10001", "10001", "01010", "00100", "01010", "10001", "10001"),
    "Y": ("10001", "10001", "01010", "00100", "00100", "00100", "00100"),
    "Z": ("11111", "00001", "00010", "00100", "01000", "10000", "11111"),
    "a": ("00000", "00000", "01110", "00001", "01111", "10001", "01111"),
    "b": ("10000", "10000", "10110", "11001", "10001", "10001", "11110"),
    "c": ("00000", "00000", "01111", "10000", "10000", "10000", "01111"),
    "d": ("00001", "00001", "01101", "10011", "10001", "10001", "01111"),
    "e": ("00000", "00000", "01110", "10001", "11111", "10000", "01111"),
    "f": ("00110", "01001", "01000", "11100", "01000", "01000", "01000"),
    "g": ("00000", "00000", "01111", "10001", "10001", "01111", "00001"),
    "h": ("10000", "10000", "10110", "11001", "10001", "10001", "10001"),
    "i": ("00100", "00000", "01100", "00100", "00100", "00100", "01110"),
    "j": ("00010", "00000", "00110", "00010", "00010", "10010", "01100"),
    "k": ("10000", "10010", "10100", "11000", "10100", "10010", "10001"),
    "l": ("01100", "00100", "00100", "00100", "00100", "00100", "01110"),
    "m": ("00000", "00000", "11010", "10101", "10101", "10101", "10101"),
    "n": ("00000", "00000", "10110", "11001", "10001", "10001", "10001"),
    "o": ("00000", "00000", "01110", "10001", "10001", "10001", "01110"),
    "p": ("00000", "10110", "11001", "10001", "11001", "10110", "10000"),
    "q": ("00000", "01101", "10011", "10001", "10011", "01101", "00001"),
    "r": ("00000", "00000", "10110", "11001", "10000", "10000", "10000"),
    "s": ("00000", "00000", "01111", "10000", "01110", "00001", "11110"),
    "t": ("01000", "01000", "11100", "01000", "01000", "01001", "00110"),
    "u": ("00000", "00000", "10001", "10001", "10001", "10011", "01101"),
    "v": ("00000", "00000", "10001", "10001", "10001", "01010", "00100"),
    "w": ("00000", "00000", "10001", "10001", "10101", "10101", "01010"),
    "x": ("00000", "00000", "10001", "01010", "00100", "01010", "10001"),
    "y": ("00000", "10001", "10001", "01111", "00001", "01001", "00110"),
    "z": ("00000", "00000", "11111", "00010", "00100", "01000", "11111"),
    "0": ("01110", "10001", "10011", "10101", "11001", "10001", "01110"),
    "1": ("00100", "01100", "00100", "00100", "00100", "00100", "01110"),
    "2": ("01110", "10001", "00001", "00010", "00100", "01000", "11111"),
    "3": ("11110", "00001", "00001", "01110", "00001", "00001", "11110"),
    "4": ("00010", "00110", "01010", "10010", "11111", "00010", "00010"),
    "5": ("11111", "10000", "10000", "11110", "00001", "00001", "11110"),
    "6": ("01110", "10000", "10000", "11110", "10001", "10001", "01110"),
    "7": ("11111", "00001", "00010", "00100", "01000", "01000", "01000"),
    "8": ("01110", "10001", "10001", "01110", "10001", "10001", "01110"),
    "9": ("01110", "10001", "10001", "01111", "00001", "00001", "01110"),
    "!": ("00100", "00100", "00100", "00100", "00100", "00000", "00100"),
    '"': ("01010", "01010", "01010", "00000", "00000", "00000", "00000"),
    "#": ("01010", "11111", "01010", "01010", "11111", "01010", "00000"),
    "$": ("00100", "01111", "10100", "01110", "00101", "11110", "00100"),
    "%": ("11001", "11010", "00100", "01000", "10110", "00110", "00000"),
    "&": ("01100", "10010", "10100", "01000", "10101", "10010", "01101"),
    "'": ("00100", "00100", "01000", "00000", "00000", "00000", "00000"),
    "(": ("00010", "00100", "01000", "01000", "01000", "00100", "00010"),
    ")": ("01000", "00100", "00010", "00010", "00010", "00100", "01000"),
    "*": ("00000", "10101", "01110", "11111", "01110", "10101", "00000"),
    "+": ("00000", "00100", "00100", "11111", "00100", "00100", "00000"),
    ",": ("00000", "00000", "00000", "00000", "00100", "00100", "01000"),
    "-": ("00000", "00000", "00000", "11111", "00000", "00000", "00000"),
    ".": ("00000", "00000", "00000", "00000", "00000", "00110", "00110"),
    "/": ("00001", "00010", "00010", "00100", "01000", "01000", "10000"),
    ":": ("00000", "00110", "00110", "00000", "00110", "00110", "00000"),
    ";": ("00000", "00110", "00110", "00000", "00100", "00100", "01000"),
    "<": ("00010", "00100", "01000", "10000", "01000", "00100", "00010"),
    "=": ("00000", "11111", "00000", "11111", "00000", "00000", "00000"),
    ">": ("01000", "00100", "00010", "00001", "00010", "00100", "01000"),
    "?": ("01110", "10001", "00001", "00010", "00100", "00000", "00100"),
    "@": ("01110", "10001", "10111", "10101", "10111", "10000", "01110"),
    "[": ("01110", "01000", "01000", "01000", "01000", "01000", "01110"),
    "\\": ("10000", "01000", "01000", "00100", "00010", "00010", "00001"),
    "]": ("01110", "00010", "00010", "00010", "00010", "00010", "01110"),
    "^": ("00100", "01010", "10001", "00000", "00000", "00000", "00000"),
    "_": ("00000", "00000", "00000", "00000", "00000", "00000", "11111"),
    "`": ("01000", "00100", "00000", "00000", "00000", "00000", "00000"),
    "{": ("00010", "00100", "00100", "01000", "00100", "00100", "00010"),
    "|": ("00100", "00100", "00100", "00100", "00100", "00100", "00100"),
    "}": ("01000", "00100", "00100", "00010", "00100", "00100", "01000"),
    "~": ("00000", "00000", "01001", "10110", "00000", "00000", "00000"),
}

MARKS = {
    "\u0300": "grave",
    "\u0301": "acute",
    "\u0302": "circumflex",
    "\u0303": "tilde",
    "\u0306": "breve",
    "\u0309": "hook",
    "\u031b": "horn",
    "\u0323": "dot_below",
}


def visual_key(char):
    if char == " ":
        return (" ", ())
    decomposed = unicodedata.normalize("NFD", char)
    base = decomposed[0]
    marks = tuple(MARKS[mark] for mark in decomposed[1:] if mark in MARKS)
    if char in ("Đ", "đ"):
        return ("D" if char == "Đ" else "d", ("stroke",))
    if base not in FONT and base.upper() in FONT:
        base = base.upper()
    return (base if base in FONT else char, marks)


def paint_pixel(pixels, x, y):
    pixels[y][x] = (255, 255, 255, 255)


def draw_glyph(pixels, origin_x, origin_y, key):
    base, marks = key
    if base == " ":
        return
    if base == "•":
        paint_pixel(pixels, origin_x + 3, origin_y + 8)
        paint_pixel(pixels, origin_x + 4, origin_y + 8)
        return
    rows = FONT.get(base, FONT["?"])
    for row, pattern in enumerate(rows):
        for column, bit in enumerate(pattern):
            if bit == "1":
                paint_pixel(pixels, origin_x + 1 + column, origin_y + 5 + row)

    if "stroke" in marks:
        for column in range(1, 6):
            paint_pixel(pixels, origin_x + column, origin_y + 8)

    if "horn" in marks:
        paint_pixel(pixels, origin_x + 6, origin_y + 6)
        paint_pixel(pixels, origin_x + 6, origin_y + 7)

    tone = next(
        (mark for mark in marks if mark in {"grave", "acute", "tilde", "hook"}),
        None,
    )
    has_shape_mark = any(mark in marks for mark in {"circumflex", "breve"})
    if tone == "grave":
        paint_pixel(pixels, origin_x + 1, origin_y + (0 if has_shape_mark else 1))
        paint_pixel(pixels, origin_x + 2, origin_y + 1)
        paint_pixel(pixels, origin_x + 3, origin_y + 2)
    elif tone == "acute":
        paint_pixel(pixels, origin_x + 5, origin_y + (0 if has_shape_mark else 1))
        paint_pixel(pixels, origin_x + 4, origin_y + 1)
        paint_pixel(pixels, origin_x + 3, origin_y + 2)
    elif tone == "tilde":
        paint_pixel(pixels, origin_x + 1, origin_y + (0 if has_shape_mark else 1))
        paint_pixel(pixels, origin_x + 3, origin_y + (0 if has_shape_mark else 1))
        paint_pixel(pixels, origin_x + 2, origin_y + 1)
        paint_pixel(pixels, origin_x + 4, origin_y + 1)
    elif tone == "hook":
        paint_pixel(pixels, origin_x + 4, origin_y + (0 if has_shape_mark else 1))
        paint_pixel(pixels, origin_x + 5, origin_y + 1)
        paint_pixel(pixels, origin_x + 4, origin_y + 2)

    if "circumflex" in marks:
        paint_pixel(pixels, origin_x + 2, origin_y + 2)
        paint_pixel(pixels, origin_x + 1, origin_y + 3)
        paint_pixel(pixels, origin_x + 3, origin_y + 3)
    elif "breve" in marks:
        paint_pixel(pixels, origin_x + 1, origin_y + 2)
        paint_pixel(pixels, origin_x + 3, origin_y + 2)
        paint_pixel(pixels, origin_x + 2, origin_y + 3)

    if "dot_below" in marks:
        paint_pixel(pixels, origin_x + 3, origin_y + 13)


def write_png(path, pixels):
    height = len(pixels)
    width = len(pixels[0])
    raw = bytearray()
    for row in pixels:
        raw.append(0)
        for red, green, blue, alpha in row:
            raw.extend((red, green, blue, alpha))

    def chunk(kind, data):
        checksum = zlib.crc32(kind + data) & 0xFFFFFFFF
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", checksum)

    png = bytearray(b"\x89PNG\r\n\x1a\n")
    png += chunk(b"IHDR", struct.pack(">2I5B", width, height, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(raw), level=9))
    png += chunk(b"IEND", b"")
    path.write_bytes(png)


def main():
    localizations = [ROOT / "lib/l10n/app_en.arb", ROOT / "lib/l10n/app_vi.arb"]
    required = set(" ")
    for path in localizations:
        data = json.loads(path.read_text(encoding="utf-8"))
        for value in data.values():
            if isinstance(value, str):
                required.update(value)
    required.update(chr(code) for code in range(32, 127))
    required.add("?")

    char_to_key = {char: visual_key(char) for char in required}
    ordered_keys = sorted(set(char_to_key.values()), key=lambda key: (key[0], key[1]))
    fallback_key = visual_key("?")
    columns = COLUMNS
    rows = math.ceil(len(ordered_keys) / columns)
    width = columns * CELL_WIDTH
    height = rows * CELL_HEIGHT
    pixels = [[(0, 0, 0, 0) for _ in range(width)] for _ in range(height)]
    positions = {}

    for index, key in enumerate(ordered_keys):
        column = index % columns
        row = index // columns
        x = column * CELL_WIDTH
        y = row * CELL_HEIGHT
        positions[key] = (x, y)
        draw_glyph(pixels, x, y, key)

    glyphs = []
    for char in sorted(required, key=ord):
        key = char_to_key[char]
        x, y = positions.get(key, positions[fallback_key])
        glyphs.append({"char": char, "x": x, "y": y})

    OUTPUT.mkdir(parents=True, exist_ok=True)
    write_png(OUTPUT / "ui_font.png", pixels)
    metadata = {
        "size": CELL_HEIGHT,
        "ascent": 12,
        "cellWidth": CELL_WIDTH,
        "cellHeight": CELL_HEIGHT,
        "fallback": "?",
        "glyphs": glyphs,
    }
    metadata_lines = [
        "{",
        f'  "size": {metadata["size"]},',
        f'  "ascent": {metadata["ascent"]},',
        f'  "cellWidth": {metadata["cellWidth"]},',
        f'  "cellHeight": {metadata["cellHeight"]},',
        f'  "fallback": {json.dumps(metadata["fallback"])},',
        '  "glyphs": [',
    ]
    for index, glyph in enumerate(glyphs):
        comma = "," if index < len(glyphs) - 1 else ""
        metadata_lines.append(
            f'    {json.dumps(glyph, ensure_ascii=False, separators=(",", ":"))}'
            f"{comma}"
        )
    metadata_lines.extend(("  ]", "}"))
    (OUTPUT / "ui_font_glyphs.json").write_text(
        "\n".join(metadata_lines) + "\n",
        encoding="utf-8",
    )
    print(f"Wrote {len(glyphs)} glyphs to {OUTPUT}")


if __name__ == "__main__":
    main()
