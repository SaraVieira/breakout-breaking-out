#!/usr/bin/env python3
"""Regenerate font.html: every glyph in dungeon-mode.ttf, no links, copy-pasteable."""

import html
import unicodedata

from fontTools.ttLib import TTFont

FONT = "dungeon-mode.ttf"
OUT = "font.html"

# Unicode block ranges we actually need, in codepoint order.
BLOCKS = [
    (0x0000, 0x007F, "Basic Latin"),
    (0x0080, 0x00FF, "Latin-1 Supplement"),
    (0x0100, 0x017F, "Latin Extended-A"),
    (0x0180, 0x024F, "Latin Extended-B"),
    (0x02B0, 0x02FF, "Spacing Modifier Letters"),
    (0x0370, 0x03FF, "Greek and Coptic"),
    (0x2000, 0x206F, "General Punctuation"),
    (0x2070, 0x209F, "Superscripts and Subscripts"),
    (0x20A0, 0x20CF, "Currency Symbols"),
    (0x2190, 0x21FF, "Arrows"),
    (0x2200, 0x22FF, "Mathematical Operators"),
    (0x2300, 0x23FF, "Miscellaneous Technical"),
    (0x2400, 0x243F, "Control Pictures"),
    (0x2460, 0x24FF, "Enclosed Alphanumerics"),
    (0x2500, 0x257F, "Box Drawing"),
    (0x2580, 0x259F, "Block Elements"),
    (0x25A0, 0x25FF, "Geometric Shapes"),
    (0x2600, 0x26FF, "Miscellaneous Symbols"),
    (0x2700, 0x27BF, "Dingbats"),
    (0x27C0, 0x27EF, "Miscellaneous Mathematical Symbols-A"),
    (0x2980, 0x29FF, "Miscellaneous Mathematical Symbols-B"),
    (0x2A00, 0x2AFF, "Supplemental Mathematical Operators"),
    (0x2B00, 0x2BFF, "Miscellaneous Symbols and Arrows"),
    (0x2E00, 0x2E7F, "Supplemental Punctuation"),
]


def block_of(cp):
    for lo, hi, name in BLOCKS:
        if lo <= cp <= hi:
            return name
    return "Other"


def char_name(cp):
    try:
        return unicodedata.name(chr(cp))
    except ValueError:
        return "<unnamed>"


codepoints = sorted(TTFont(FONT).getBestCmap())

groups = []
for cp in codepoints:
    name = block_of(cp)
    if not groups or groups[-1][0] != name:
        groups.append((name, []))
    groups[-1][1].append(cp)

all_glyphs = "".join(chr(cp) for cp in codepoints)

parts = []
for name, cps in groups:
    parts.append(f'    <h2>{html.escape(name)} <em>({len(cps)})</em></h2>')
    parts.append('    <div class="grid">')
    for cp in cps:
        label = f"U+{cp:04X} {char_name(cp)}"
        parts.append(
            f'      <button class="cell" type="button" '
            f'data-char="{html.escape(chr(cp))}" title="{html.escape(label)}">'
            f'<span class="glyph">{html.escape(chr(cp))}</span>'
            f'<span class="code">{cp:04X}</span></button>'
        )
    parts.append("    </div>")

cells = "\n".join(parts)

doc = f"""<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <title>dungeon-mode &mdash; all glyphs</title>
    <style>
        @font-face {{
            font-family: 'dungeon-mode';
            src: url('dungeon-mode.ttf') format('truetype');
        }}

        @font-face {{
            font-family: 'dungeon-mode-inverted';
            src: url('dungeon-mode-inverted.ttf') format('truetype');
        }}

        :root {{
            color-scheme: dark;
        }}

        body {{
            margin: 0 auto;
            padding: 2rem 1.5rem 4rem;
            max-width: 70rem;
            background: #14131a;
            color: #e8e6f0;
            font-family: ui-sans-serif, system-ui, sans-serif;
        }}

        h1 {{
            margin: 0 0 .25rem;
            font-size: 1.5rem;
        }}

        p.sub {{
            margin: 0 0 2rem;
            color: #9b97ad;
        }}

        h2 {{
            margin: 2.5rem 0 .75rem;
            padding-bottom: .35rem;
            border-bottom: 1px solid #2e2b3a;
            font-size: 1rem;
            font-weight: 600;
            letter-spacing: .04em;
            text-transform: uppercase;
            color: #b8b3cc;
        }}

        h2 em {{
            font-style: normal;
            color: #6f6b82;
        }}

        .grid {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(4.5rem, 1fr));
            gap: .4rem;
        }}

        .cell {{
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: .35rem;
            padding: .6rem .25rem .4rem;
            border: 1px solid #2e2b3a;
            border-radius: .35rem;
            background: #1c1a24;
            color: inherit;
            font: inherit;
            cursor: pointer;
        }}

        .cell:hover {{
            border-color: #6d5ce7;
            background: #241f33;
        }}

        .cell.copied {{
            border-color: #4ade80;
            background: #1c2e22;
        }}

        .glyph {{
            font-family: 'dungeon-mode';
            font-size: 2rem;
            line-height: 1;
            user-select: all;
        }}

        .inverted .glyph {{
            font-family: 'dungeon-mode-inverted';
        }}

        .code {{
            font-family: ui-monospace, monospace;
            font-size: .7rem;
            color: #7d7891;
        }}

        .bulk {{
            margin-bottom: 1rem;
        }}

        textarea {{
            width: 100%;
            height: 6rem;
            padding: .6rem;
            border: 1px solid #2e2b3a;
            border-radius: .35rem;
            background: #1c1a24;
            color: #e8e6f0;
            font-family: 'dungeon-mode';
            font-size: 1.25rem;
        }}

        label {{
            display: inline-flex;
            align-items: center;
            gap: .4rem;
            color: #9b97ad;
            cursor: pointer;
        }}
    </style>
</head>

<body>
    <h1>dungeon-mode</h1>
    <p class="sub">{len(codepoints)} glyphs. Click any cell to copy the character.</p>

    <div class="bulk">
        <label><input type="checkbox" id="invert"> preview with dungeon-mode-inverted</label>
        <textarea readonly>{html.escape(all_glyphs)}</textarea>
    </div>

{cells}

    <script>
        document.addEventListener('click', (e) => {{
            const cell = e.target.closest('.cell');
            if (!cell) return;
            navigator.clipboard.writeText(cell.dataset.char);
            cell.classList.add('copied');
            setTimeout(() => cell.classList.remove('copied'), 600);
        }});

        document.getElementById('invert').addEventListener('change', (e) => {{
            document.body.classList.toggle('inverted', e.target.checked);
        }});
    </script>
</body>

</html>
"""

with open(OUT, "w", encoding="utf-8") as fh:
    fh.write(doc)

print(f"{OUT}: {len(codepoints)} glyphs, {len(groups)} blocks")
