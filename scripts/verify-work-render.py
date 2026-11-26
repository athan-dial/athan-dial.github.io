#!/usr/bin/env python3
"""Render check for the TALOS Work Product (arg: slug, default talos; needs `hugo server -D --port 8765`).
Fails if the diagram is clipped at laptop width, sits below the fold, or the page overflows on mobile."""
import sys
from playwright.sync_api import sync_playwright
SLUG = sys.argv[1] if len(sys.argv) > 1 else 'talos'
URL = f'http://localhost:8765/work/{SLUG}/'
bad = []
with sync_playwright() as p:
    b = p.chromium.launch()
    for w, h in [(1280, 800), (1440, 900), (390, 844)]:
        pg = b.new_page(viewport={'width': w, 'height': h})
        pg.goto(URL); pg.wait_for_timeout(500)
        story = pg.evaluate("() => !!document.querySelector('.ts-problem')")
        if story:
            m = pg.evaluate("""() => ({top: document.querySelector('#problem').getBoundingClientRect().top, doc: document.documentElement.scrollWidth})""")
            if w >= 1000 and m['top'] > h * 0.9: bad.append(f'{w}: problem section below fold {m}')
            if m['doc'] > w: bad.append(f'{w}: page overflows {m}')
            continue
        d = pg.evaluate("""() => { const e = document.querySelector('.wp-diagram');
          return {scroll: e.scrollWidth, client: e.clientWidth, top: e.getBoundingClientRect().top,
                  doc: document.documentElement.scrollWidth} }""")
        if w >= 1000 and d['scroll'] > d['client'] + 1: bad.append(f'{w}: diagram clipped {d}')
        if w >= 1000 and d['top'] > h * 0.6: bad.append(f'{w}: diagram below fold {d}')
        if d['doc'] > w: bad.append(f'{w}: page overflows {d}')
    b.close()
print('\n'.join(bad) or 'ok'); sys.exit(1 if bad else 0)
