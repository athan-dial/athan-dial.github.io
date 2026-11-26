#!/usr/bin/env bash
# One command for a Work Product review pass: render diagram, build, check, screenshot, standalone.
# Usage: scripts/work-product-ship.sh <slug> [dest-dir]   (dest-dir e.g. iCloud Downloads)
set -euo pipefail
cd "$(dirname "$0")/.."
slug="${1:?slug}"; out="_private/${slug}-review"; mkdir -p "$out"
if [ -f "assets/work-products/$slug/arch.json" ]; then python3 scripts/render-arch-svg.py "$slug"; else python3 scripts/render-flow-svg.py "$slug"; fi
hugo server -D --port 8765 >/tmp/hugo-wp.log 2>&1 & pid=$!
trap 'kill $pid 2>/dev/null' EXIT
for _ in $(seq 20); do curl -sf "http://localhost:8765/work/$slug/" >/dev/null && break; sleep 1; done
uv run --no-project --with playwright python scripts/verify-work-render.py "$slug"
uv run --no-project --with playwright python - "$slug" "$out" <<'PY'
import sys
from playwright.sync_api import sync_playwright
slug, out = sys.argv[1:3]
with sync_playwright() as p:
    b = p.chromium.launch()
    for n, w, h in [('desktop', 1440, 900), ('laptop', 1280, 800), ('mobile', 390, 844)]:
        pg = b.new_page(viewport={'width': w, 'height': h}, device_scale_factor=2)
        pg.goto(f'http://localhost:8765/work/{slug}/'); pg.wait_for_timeout(600)
        pg.screenshot(path=f'{out}/{n}.png')
        if n == 'desktop': pg.locator('.wp-diagram').screenshot(path=f'{out}/diagram.png')
PY
hugo -D --quiet
python3 scripts/render-work-standalone.py "$slug"
if [ -n "${2:-}" ]; then mkdir -p "$2/$slug-work-product"; cp "$out"/*.png "$out"/*-standalone.html "assets/work-products/$slug/"*.svg "$2/$slug-work-product/"; fi
echo "done: $out"
