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

svg = (root / f"assets/work-products/{slug}/workflow.svg").read_text()
html = re.sub(
    r'<div class="wp-diagram"[^>]*><img src="/work-products/talos/workflow\.svg"[^>]*></div>',
    f'<div class="wp-diagram" tabindex="0" role="region" aria-label="Workflow diagram">{svg}</div>',
    html,
    count=1,
)

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