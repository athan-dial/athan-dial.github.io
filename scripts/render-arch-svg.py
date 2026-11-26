#!/usr/bin/env python3
"""Render assets/work-products/<slug>/arch.json to architecture.svg (wide) and architecture-mobile.svg.

An architecture view, not a flow: four regions (sources, computation, canonical substrate,
products), per-lane processing paths, a selective-review workbench, and a continuous loop bar.
Status is drawn, not colored: solid outline = built, dashed = documented design, dotted = planned.
Regions link to page anchors (inline SVG); icons are inlined Lucide paths (assets/work-products/icons.json).
No dependencies."""
import json
import re
import sys
from html import escape
from pathlib import Path

root = Path(__file__).resolve().parents[1]
slug = sys.argv[1] if len(sys.argv) > 1 else 'talos'
folder = root / 'assets/work-products' / slug
spec = json.loads((folder / 'arch.json').read_text())
icons = json.loads((root / 'assets/work-products/icons.json').read_text())
tokens = (root / 'assets/css/tokens.css').read_text()
tok = lambda n: re.search(r'--' + re.escape(n) + r':\s*(#[0-9a-fA-F]+)', tokens).group(1)
INK, PAPER, SURFACE, ACCENT, CITRUS, MUTED, RULE = (tok(n) for n in ('ink', 'paper', 'surface', 'accent', 'citrus', 'ink-secondary', 'field-rule'))
FRAME, EDGE, ONFOREST, ONFOREST_SUB = '#f3f3f1', '#3d4452', '#ffffff', '#cfe3d9'
FONT = "var(--font-sans,'Helvetica Neue',Helvetica,Arial,sans-serif)"
MONO = "var(--font-mono,ui-monospace,Menlo,monospace)"


def wrap(text, size, bold, width):
    per = size * (0.585 if bold else 0.52)
    lines, cur = [], ''
    for word in text.split():
        trial = (cur + ' ' + word).strip()
        if len(trial) * per <= width or not cur:
            cur = trial
        else:
            lines.append(cur)
            cur = word
    return lines + [cur] if cur else lines


class Svg:
    def __init__(self, w, h, label, uid='w'):
        self.w, self.h, self.out = w, h, []
        self.uid = uid
        self.out.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}" role="group" aria-label="{escape(label)}" style="font-family:{FONT}">')
        self.out.append(f'<defs><marker id="ah-{uid}" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="9" markerHeight="9" orient="auto-start-reverse"><path d="M1 1 L9 5 L1 9" fill="none" stroke="context-stroke" stroke-width="1.6" stroke-linejoin="round" stroke-linecap="round"/></marker>'
                        f'<marker id="dm-{uid}" viewBox="0 0 12 12" refX="11" refY="6" markerWidth="10" markerHeight="10" orient="auto"><path d="M1 6 L6 1 L11 6 L6 11 Z" fill="{PAPER}" stroke="context-stroke" stroke-width="1.4"/></marker></defs>')
        self.out.append(f'<rect width="{w}" height="{h}" fill="{PAPER}"/>')

    def add(self, s):
        self.out.append(s)

    def link(self, href, inner):
        self.out.append(f'<a href="{href}" class="arch-link">{inner}</a>' if href else inner)

    def text(self, x, y, s, size=15, weight=400, fill=INK, anchor='start', mono=False, spacing=0):
        fam = f' style="font-family:{MONO}"' if mono else ''
        ls = f' letter-spacing="{spacing}"' if spacing else ''
        self.add(f'<text x="{x:.1f}" y="{y:.1f}" font-size="{size}" font-weight="{weight}" fill="{fill}" text-anchor="{anchor}"{ls}{fam}>{escape(s)}</text>')

    def icon(self, name, x, y, box=36, stroke=INK, fill='#efefec', glyph=22):
        self.add(f'<rect x="{x:.1f}" y="{y:.1f}" width="{box}" height="{box}" fill="{fill}"/>')
        s = glyph / 24
        o = (box - glyph) / 2
        self.add(f'<g transform="translate({x + o:.1f} {y + o:.1f}) scale({s:.4f})" fill="none" stroke="{stroke}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">{icons[name]}</g>')

    def rect(self, x, y, w, h, fill=SURFACE, stroke=INK, sw=1.25, dash=None, cls=None):
        d = f' stroke-dasharray="{dash}"' if dash else ''
        c = f' class="{cls}"' if cls else ''
        self.add(f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"{d}{c}/>')

    def path(self, pts, dash=None, stroke=EDGE, end='ah', start=None, sw=1.6):
        d = ' L'.join(f'{x:.1f} {y:.1f}' for x, y in pts)
        da = f' stroke-dasharray="{dash}"' if dash else ''
        ms = f' marker-start="url(#{start}-{self.uid})"' if start else ''
        self.add(f'<path d="M{d}" fill="none" stroke="{stroke}" stroke-width="{sw}"{da} stroke-linejoin="round"{ms} marker-end="url(#{end}-{self.uid})" style="color:{stroke}"/>')

    def pill(self, x, y, s, size=13.5, fill=PAPER, stroke=RULE, color=EDGE):
        w = len(s) * size * 0.54 + 16
        self.add(f'<rect x="{x - w / 2:.1f}" y="{y - 11:.1f}" width="{w:.1f}" height="22" fill="{fill}" stroke="{stroke}"/>')
        self.text(x, y + 5, s, size, 400, color, 'middle')

    def card(self, x, y, w, h, title, desc=None, icon=None, tag=None, fill=SURFACE, ink=INK, sub=MUTED, stroke=INK,
             dash=None, chipfill='#efefec', chipstroke=INK, tsize=17, dsize=14.5, bar=False, double=False, href=None, tagc=ACCENT):
        parts_before = len(self.out)
        self.rect(x, y, w, h, fill, stroke, 1.25, dash)
        if double:
            self.add(f'<rect x="{x}" y="{y}" width="4" height="{h}" fill="{stroke}"/><line x1="{x + 8}" y1="{y}" x2="{x + 8}" y2="{y + h}" stroke="{stroke}"/>')
        if bar:
            self.add(f'<rect x="{x}" y="{y}" width="5" height="{h}" fill="{ACCENT}"/>')
        tx = x + 16 + (4 if double else 0) + (4 if bar else 0)
        if icon:
            box = 38 if h >= 70 else max(24, h - 10)
            iy = y + 14 if h >= 100 else y + (h - box) / 2
            self.icon(icon, tx - 2 + (0 if not double else 6), iy, box, chipstroke, chipfill, round(box * 0.58))
            tx += box + 12 + (6 if double else 0) - 2
        tw = x + w - 14 - tx
        tl = wrap(title, tsize, True, tw)
        dl = wrap(desc, dsize, False, tw) if desc else []
        block = (16 if tag else 0) + len(tl) * (tsize + 5) + (5 + len(dl) * (dsize + 5) if dl else 0)
        cy = y + (14 if h >= 150 else max(4, (h - block) / 2))
        if tag:
            self.text(tx, cy + 11, tag.upper(), 12, 600, tagc if ink == INK else ONFOREST_SUB, mono=True, spacing=1.0)
            cy += 16
        for i, ln in enumerate(tl):
            self.text(tx, cy + tsize + i * (tsize + 5) - 2, ln, tsize, 700, ink)
        for i, ln in enumerate(dl):
            self.text(tx, cy + len(tl) * (tsize + 5) + 5 + dsize + i * (dsize + 5) - 3, ln, dsize, 400, sub)
        if href:
            chunk = self.out[parts_before:]
            del self.out[parts_before:]
            self.add(f'<a href="{href}" class="arch-link">' + ''.join(chunk) + '</a>')

    def region(self, x, y, w, h, num, title, sub, fill=FRAME, ink=INK, subc=MUTED, stroke=RULE, href=None, key=''):
        before = len(self.out)
        cls = ' '.join(['arch-region'] + [f'arch-region--{k}' for k in key.split()])
        self.rect(x, y, w, h, fill, stroke, 1.25, None, cls)
        self.text(x + 20, y + 34, f'{num} · {title.upper()}', 14, 600, ink, mono=True, spacing=1.0)
        for i, ln in enumerate(wrap(sub, 14.5, False, w - 40)):
            self.text(x + 20, y + 58 + i * 19, ln, 14.5, 400, subc)
        if href:
            chunk = self.out[before:]
            del self.out[before:]
            self.add(f'<a href="{href}" class="arch-link">' + ''.join(chunk) + '</a>')

    def hit(self, x, y, w, h, href, label):
        if href:
            self.add(f'<a href="{href}" class="arch-link arch-hit" aria-label="{escape(label)}"><rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}"/></a>')

    def done(self):
        self.out.append('</svg>')
        return '\n'.join(self.out) + '\n'


R = spec['regions']
LANES, CHAIN = spec['lanes'], spec['chain']


def wide():
    M, TOP, H = 24, 20, 724
    R1X, R1W = M, 290
    R2X, R2W = R1X + R1W + 52, 440
    R3X, R3W = R2X + R2W + 52, 500
    R4X, R4W = R3X + R3W + 52, 330
    W = R4X + R4W + M
    WB_Y, WB_H = TOP + H + 40, 126
    LOOP_Y = WB_Y + WB_H + 28
    HGT = LOOP_Y + 56 + 24
    s = Svg(W, HGT, spec['alt'], 'w')
    s.region(R1X, TOP, R1W, H, R['sources']['num'], R['sources']['title'], R['sources']['sub'], key='sources')
    s.region(R2X, TOP, R2W, H, R['compute']['num'], R['compute']['title'], R['compute']['sub'], href=R['compute'].get('href'), key='compute')
    s.region(R3X, TOP, R3W, H, R['substrate']['num'], R['substrate']['title'], R['substrate']['sub'], fill=ACCENT, ink=ONFOREST, subc=ONFOREST_SUB, stroke=ACCENT, href=R['substrate'].get('href'), key='substrate')
    s.region(R4X, TOP, R4W, H, R['products']['num'], R['products']['title'], R['products']['sub'], href=R['products'].get('href'), key='products')
    # lanes: sources card + processing lane aligned
    y = TOP + 78
    lane_y = {}
    for ln in LANES:
        n = len(ln['steps'])
        h = 240 if ln['id'] == 'news' else (104 if ln['id'] == 'patents' else 112)
        lane_y[ln['id']] = (y, h)
        s.card(R1X + 16, y, R1W - 32, h, ln['title'], ln['desc'], ln['icon'], ln['tag'])
        lx, lw = R2X + 16, R2W - 32
        s.rect(lx, y, lw, h, SURFACE, RULE, 1.25)
        s.text(lx + 12, y + 20, ln['label'].upper(), 12, 600, ACCENT, mono=True, spacing=1.0)
        if ln['id'] == 'news':
            cy = y + 32
            for i, st in enumerate(ln['steps']):
                s.card(lx + 10, cy, lw - 20, 40, st['title'], None, st['icon'], tsize=15.5)
                if i < n - 1:
                    s.path([(lx + lw / 2, cy + 41), (lx + lw / 2, cy + 56)])
                cy += 56
        elif n == 1:
            st = ln['steps'][0]
            s.card(lx + 10, y + 30, lw - 20, 74, st['title'], st.get('desc'), st['icon'], tsize=15.5, dsize=14)
        else:
            cw = (lw - 20 - 22) / 2
            for i, st in enumerate(ln['steps']):
                s.card(lx + 10 + i * (cw + 22), y + 34, cw, 56, st['title'], None, st['icon'], tsize=15.5)
            s.path([(lx + 10 + cw, y + 62), (lx + 10 + cw + 22, y + 62)])
        # source -> lane, lane -> substrate
        mid = y + (120 if ln['id'] == 'news' else h / 2)
        ref = ln['id'] == 'reference'
        s.path([(R1X + R1W - 16, mid), (lx, mid)], dash='2 5' if ref else None, end='dm' if ref else 'ah')
        s.path([(lx + lw, mid), (R3X, mid)], dash='2 5' if ref else None, end='dm' if ref else 'ah')
        y += h + 12
    # substrate
    cx, cw = R3X + 20, 240
    ny = TOP + 98
    NH, GAP = 92, 40
    pos = {}
    for i, c in enumerate(CHAIN):
        cy = ny + i * (NH + GAP)
        pos[c['id']] = cy
        if c.get('stack'):
            for k in (2, 1):
                s.rect(cx + 7 * k, cy - 7 * k, cw, NH, SURFACE, INK, 1.0)
        s.card(cx, cy, cw, NH, c['title'], c['desc'], None if c.get('key') else c['icon'], bar=c.get('key', False), dsize=14, tsize=17, stroke=INK,
               href=R['substrate'].get('href') if c.get('key') else None)
        if c.get('key'):
            s.rect(cx - 3, cy - 3, cw + 6, NH + 6, 'none', ACCENT, 1.6)
        if i < len(CHAIN) - 1:
            end = cy + NH + GAP - (17 if CHAIN[i + 1].get('stack') else 2)
            s.path([(cx + cw / 2, cy + NH), (cx + cw / 2, end)], stroke=ONFOREST, sw=1.8)
            s.text(cx + cw / 2 + 14, cy + NH + 17, spec['chain_labels'][i], 14, 400, ONFOREST_SUB)
    ex, ew = cx + cw + 44, R3X + R3W - 20 - (cx + cw + 44)
    ent = spec['entities']
    eh = 90 + len(ent['rows']) * 38 + 10
    s.rect(ex, ny, ew, eh, 'rgba(255,255,255,.12)', ONFOREST, 1.2)
    s.text(ex + 14, ny + 26, ent['title'], 17, 700, ONFOREST)
    for i, ln in enumerate(wrap(ent['sub'], 14, False, ew - 28)):
        s.text(ex + 14, ny + 46 + i * 17, ln, 14, 400, ONFOREST_SUB)
    ry = ny + 90
    for r in ent['rows']:
        s.card(ex + 8, ry, ew - 16, 32, r['title'], None, r['icon'], tsize=15, chipfill='#efefec')
        ry += 38
    # event -> entities, program -> entities (elbows through the gap)
    evm, prm = pos['event'] + NH / 2, pos['program'] + NH / 2
    s.path([(cx + cw, evm), (cx + cw + 12, evm), (cx + cw + 12, ny + eh - 46), (ex, ny + eh - 46)], stroke=ONFOREST, sw=1.8)
    s.path([(cx + cw + 3, prm), (cx + cw + 26, prm), (cx + cw + 26, ny + eh - 22), (ex, ny + eh - 22)], stroke=ONFOREST, sw=1.8)
    chy = ny + eh + 28
    for ch in spec['chips']:
        s.card(ex, chy, ew, 62, ch['title'], ch['desc'], None, dsize=13.5, tsize=15)
        chy += 72
    # guarantees
    gy = TOP + H - 20 - 76
    s.rect(R3X + 20, gy, R3W - 40, 76, 'rgba(255,255,255,.12)', ONFOREST, 1.2)
    gw = (R3W - 40) / 2
    for i, g in enumerate(spec['guarantees']):
        gx = R3X + 20 + (i % 2) * gw + 14
        gyy = gy + 10 + (i // 2) * 30
        s.icon(g['icon'], gx, gyy, 26, ONFOREST, 'none', 18)
        s.text(gx + 36, gyy + 19, g['title'], 15.5, 600, ONFOREST)
    # products
    py = TOP + 78
    for p in spec['products']:
        s.card(R4X + 16, py, R4W - 32, 116, p['q'], p['desc'], p['icon'], p['tag'], href=R['products'].get('href'))
        py += 124
    for rx, rw, key in ((R2X, R2W, 'compute'), (R3X, R3W, 'substrate'), (R4X, R4W, 'products')):
        s.hit(rx, TOP, rw, H, R[key].get('href'), f"{R[key]['title']}: jump to the related decision")
    # workbench
    wb = spec['workbench']
    wx, ww = R2X, R3X + R3W - R2X
    wbl = lambda: None
    before = len(s.out)
    s.rect(wx, WB_Y, ww, WB_H, CITRUS, INK, 1.6, '8 5', 'arch-region arch-region--workbench')
    s.icon(wb['icon'], wx + 20, WB_Y + 26, 44, INK, 'rgba(11,11,12,.09)', 26)
    s.text(wx + 78, WB_Y + 44, wb['title'], 19, 700, INK)
    for i, ln in enumerate(wrap(wb['desc'], 14.5, False, 380)):
        s.text(wx + 78, WB_Y + 66 + i * 19, ln, 14.5, 400, '#2b2e24')
    s.text(wx + 78, WB_Y + WB_H - 18, wb['status'].upper(), 12, 600, INK, mono=True, spacing=0.9)
    bx = wx + 470
    for i, pt in enumerate(wb['points']):
        yy = WB_Y + 38 + i * 26
        s.add(f'<g transform="translate({bx} {yy - 15}) scale(0.75)" fill="none" stroke="{INK}" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">{icons["check"]}</g>')
        s.text(bx + 26, yy, pt, 15.5, 400, INK)
    chunk = s.out[before:]
    del s.out[before:]
    s.add(f'<a href="{wb["href"]}" class="arch-link">' + ''.join(chunk) + '</a>')
    ax = R2X + 120
    s.path([(ax, TOP + H), (ax, WB_Y)], dash='6 5')
    s.pill(ax, TOP + H + 20, wb['in_label'])
    bx2 = R3X + 250
    s.path([(bx2, WB_Y), (bx2, TOP + H)], dash='6 5')
    s.pill(bx2, TOP + H + 20, wb['out_label'])
    # loop bar
    lp = spec['loop']
    s.rect(M, LOOP_Y, W - 2 * M, 56, SURFACE, INK, 1.25)
    s.icon(lp['icon'], M + 14, LOOP_Y + 9, 38, INK, '#efefec', 22)
    s.text(M + 64, LOOP_Y + 34, lp['title'], 18, 700, INK)
    s.add(f'<line x1="{M + 290}" y1="{LOOP_Y + 12}" x2="{M + 290}" y2="{LOOP_Y + 44}" stroke="{RULE}" stroke-width="1.5"/>')
    s.text(M + 310, LOOP_Y + 34, '  ·  '.join(lp['items']), 16, 400, INK)
    pw = len(lp['planned']) * 8.3 + 28
    s.rect(W - M - pw - 12, LOOP_Y + 12, pw, 32, PAPER, INK, 1.4, '2 4')
    s.text(W - M - pw / 2 - 12, LOOP_Y + 33, lp['planned'], 14.5, 400, INK, 'middle')
    return s.done()


def narrow():
    W, M = 390, 10
    PW = W - 2 * M
    IW = PW - 24
    y = 10
    parts = []
    s = Svg(W, 4000, spec['alt'], 'n')  # height patched at the end

    def down(yy, label=None):
        s.path([(W / 2, yy), (W / 2, yy + 26)])
        if label:
            s.pill(W / 2 + 70, yy + 13, label, 13)

    # region 1+2 merged: lanes
    top = y
    h_lanes = 0
    SW = IW - 18                      # step card width
    TW = SW - 6 - 14 - 16 - 28 - 10   # step text width (matches card())
    def step_h(st):
        return 18 + 20 * len(wrap(st['title'], 14.5, True, TW)) + (19 if st.get('desc') else 0)
    cy = y + 78
    block = []
    for ln in LANES:
        ch = 100 if ln['id'] == 'news' else 86
        h = 8 + ch + 10 + 18 + sum(step_h(st) + 6 for st in ln['steps']) + 6
        block.append((ln, cy, h, ch))
        cy += h + 12
    total = cy - y + 4
    s.region(M, y, PW, total, '01–02', 'Sources and paths', 'Four sources, four processing paths', href=R['compute'].get('href'), key='sources compute')
    for ln, ly, h, ch in block:
        s.rect(M + 12, ly, IW, h, SURFACE, RULE, 1.25)
        s.card(M + 18, ly + 8, IW - 12, ch, ln['title'], ln['desc'], ln['icon'], ln['tag'], dsize=14, tsize=16.5)
        s.text(M + 24, ly + 8 + ch + 22, ln['label'].upper(), 12, 600, ACCENT, mono=True, spacing=1.0)
        sy = ly + 8 + ch + 30
        for st in ln['steps']:
            sh = step_h(st)
            s.card(M + 24, sy, SW - 6, sh, st['title'], st.get('desc'), st['icon'], tsize=14.5, dsize=13.5)
            sy += sh + 6
    s.hit(M, top, PW, total, R['compute'].get('href'), 'Sources and paths: jump to the related decision')
    y += total
    down(y + 2)
    y += 32
    # substrate
    sub_start = y
    parts_y = y + 78
    NH, GAP = 74, 38
    chain_h = len(CHAIN) * NH + (len(CHAIN) - 1) * GAP
    ent = spec['entities']
    eh = 70 + len(ent['rows']) * 36
    sub_h = 78 + chain_h + 22 + eh + 18 + 2 * 66 + 12 + 18 + 4 * 34 + 18
    s.region(M, y, PW, sub_h, R['substrate']['num'], R['substrate']['title'], R['substrate']['sub'], fill=ACCENT, ink=ONFOREST, subc=ONFOREST_SUB, stroke=ACCENT, href=R['substrate'].get('href'), key='substrate')
    cx, cw = M + 24, IW - 24 - 12
    for i, c in enumerate(CHAIN):
        cyy = parts_y + i * (NH + GAP)
        if c.get('stack'):
            for k in (2, 1):
                s.rect(cx + 6 * k, cyy - 6 * k, cw, NH, SURFACE, INK, 1.0)
        s.card(cx, cyy, cw, NH, c['title'], c['desc'], c['icon'], bar=c.get('key', False), dsize=13.5, tsize=16.5)
        if c.get('key'):
            s.rect(cx - 3, cyy - 3, cw + 6, NH + 6, 'none', ACCENT, 1.6)
        if i < len(CHAIN) - 1:
            end = cyy + NH + GAP - (17 if CHAIN[i + 1].get('stack') else 2)
            s.path([(cx + 30, cyy + NH), (cx + 30, end)], stroke=ONFOREST, sw=1.8)
            s.text(cx + 44, cyy + NH + 15, spec['chain_labels'][i], 13.5, 400, ONFOREST_SUB)
    ey = parts_y + chain_h + 22
    s.rect(cx, ey, cw, eh, 'rgba(255,255,255,.12)', ONFOREST, 1.2)
    s.text(cx + 12, ey + 24, ent['title'], 16.5, 700, ONFOREST)
    s.text(cx + 12, ey + 44, ent['sub'], 13.5, 400, ONFOREST_SUB)
    ry = ey + 56
    for r in ent['rows']:
        s.card(cx + 8, ry, cw - 16, 30, r['title'], None, r['icon'], tsize=14.5)
        ry += 36
    cyy = ey + eh + 18
    for ch in spec['chips']:
        s.card(cx, cyy, cw, 60, ch['title'], ch['desc'], ch['icon'], tsize=15, dsize=13.5)
        cyy += 66
    gy = cyy + 12
    s.rect(cx, gy, cw, 4 * 34 + 8, 'rgba(255,255,255,.12)', ONFOREST, 1.2)
    for i, g in enumerate(spec['guarantees']):
        s.icon(g['icon'], cx + 12, gy + 8 + i * 34, 26, ONFOREST, 'none', 18)
        s.text(cx + 48, gy + 8 + i * 34 + 19, g['title'], 15, 600, ONFOREST)
    s.hit(M, sub_start, PW, sub_h, R['substrate'].get('href'), 'Canonical intelligence: jump to the related decision')
    y += sub_h
    down(y + 2)
    y += 32
    # workbench
    wb = spec['workbench']
    wh = 118 + len(wb['points']) * 24 + 16
    before = len(s.out)
    s.rect(M, y, PW, wh, CITRUS, INK, 1.6, '8 5', 'arch-region arch-region--workbench')
    s.icon(wb['icon'], M + 14, y + 18, 40, INK, 'rgba(11,11,12,.09)', 24)
    s.text(M + 66, y + 38, wb['title'], 17, 700, INK)
    for i, ln in enumerate(wrap(wb['desc'], 14, False, PW - 80)):
        s.text(M + 66, y + 58 + i * 18, ln, 14, 400, '#2b2e24')
    s.text(M + 14, y + 94, wb['status'].upper(), 11.5, 600, INK, mono=True, spacing=0.6)
    for i, pt in enumerate(wb['points']):
        yy = y + 120 + i * 24
        s.add(f'<g transform="translate({M + 14} {yy - 14}) scale(0.7)" fill="none" stroke="{INK}" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">{icons["check"]}</g>')
        s.text(M + 36, yy, pt, 14.5, 400, INK)
    chunk = s.out[before:]
    del s.out[before:]
    s.add(f'<a href="{wb["href"]}" class="arch-link">' + ''.join(chunk) + '</a>')
    y += wh + 14
    # products
    ph = 78 + len(spec['products']) * 100 + 8
    s.region(M, y, PW, ph, R['products']['num'], R['products']['title'], R['products']['sub'], href=R['products'].get('href'), key='products')
    py = y + 78
    for p in spec['products']:
        s.card(M + 12, py, IW, 92, p['q'], p['desc'], p['icon'], p['tag'], tsize=16, dsize=14, href=R['products'].get('href'))
        py += 100
    s.hit(M, y, PW, ph, R['products'].get('href'), 'Intelligence products: jump to the related decision')
    y += ph + 14
    # loop
    lp = spec['loop']
    lh = 108
    s.rect(M, y, PW, lh, SURFACE, INK, 1.25)
    s.icon(lp['icon'], M + 14, y + 12, 38, INK, '#efefec', 22)
    s.text(M + 64, y + 38, lp['title'], 17, 700, INK)
    for i, it in enumerate(lp['items']):
        pass
    s.text(M + 14, y + 68, '  ·  '.join(lp['items'][:2]), 14.5, 400, INK)
    s.text(M + 14, y + 88, lp['items'][2], 14.5, 400, INK)
    y += lh + 10
    s.rect(M, y, PW, 34, PAPER, INK, 1.4, '2 4')
    s.text(W / 2, y + 22, lp['planned'], 14, 400, INK, 'middle')
    y += 34 + 10
    s.h = y
    out = s.done().replace('viewBox="0 0 390 4000"', f'viewBox="0 0 390 {y}"').replace('height="4000"', f'height="{y}"').replace(f'<rect width="390" height="4000"', f'<rect width="390" height="{y}"')
    return out


(folder / 'architecture.svg').write_text(wide())
(folder / 'architecture-mobile.svg').write_text(narrow())
print('rendered architecture (wide + mobile)')
