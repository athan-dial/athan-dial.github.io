#!/usr/bin/env python3
"""Build a self-contained TALOS review HTML file with inlined CSS and diagram SVG."""
import re
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[1]
slug = sys.argv[1] if len(sys.argv) > 1 else "talos"
html = (root / f"public/work/{slug}/index.html").read_text()
out = root / f"_private/{slug}-review/{slug}-standalone.html"

css_hrefs = re.findall(r'<link rel="stylesheet" href="([^"]+)"[^>]*>', html)
blocks = []
for href in css_hrefs:
    path = root / "public" / href.lstrip("/")
    blocks.append(f"<style>\n{path.read_text()}\n</style>")
html = re.sub(r'\s*<link rel="stylesheet"[^>]+>\s*', "\n", html)

inline = 'wp-arch' in html
svg = "" if inline else (root / f"assets/work-products/{slug}/workflow.svg").read_text()
svg = re.sub(r'(<svg[^>]*?) width="(\d+)" height="\d+"', r'\1 style="--svg-w:\2px"', svg, count=1)
html = re.sub(
    r'<div class="wp-diagram"[^>]*><img src="/work-products/[^"]*workflow[^"]*\.svg"[^>]*></div>',
    lambda m: f'<div class="wp-diagram" tabindex="0" role="region" aria-label="Workflow diagram">{svg}</div>',
    html,
    count=1,
)
assert "<svg" in html.split('class="wp-diagram', 1)[1][:600], "diagram not inlined"
if not inline:
    blocks.append("<style>.wp-diagram svg{display:block;height:auto;max-width:none;width:var(--svg-w);min-width:100%}@media(min-width:1000px){.wp-diagram svg{width:100%;min-width:0}}</style>")
html = html.replace("</head>", "\n".join(blocks) + "\n</head>", 1)
html = re.sub(r'href="/([^"]+)"', r'href="#"', html)
html = re.sub(r'src="/([^"]+)"', r'src="#"', html)
html = html.replace('<a href="#">', '<a href="#" onclick="return false">', 1)
html = re.sub(
    r'<title>[^<]+</title>',
    f"<title>{slug} Work Product (standalone review)</title>",
    html,
    count=1,
)

out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(html)
print(f"wrote {out} ({out.stat().st_size} bytes)")