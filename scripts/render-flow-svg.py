#!/usr/bin/env python3
"""Render assets/work-products/<slug>/flow.json to workflow.svg. No dependencies.

Why this exists: the OpenFlowKit exporter centered descriptions, fixed card sublabels at 11px, and
embedded icons as nested data-URI <image> elements that many viewers drop. This renderer lays out
the flow itself: left-aligned measured text, icons inlined as vector paths (assets/work-products/
icons.json, Lucide, ISC), square Fieldnotes cards, orthogonal edges.

Node types: action (forest), judgment (citrus, heavy top rule), gate (citrus diamond),
state (paper, doubled left rule), direction (paper). Edge route hints in flow.json:
left-lane (loop up the left margin), right-bus (loop on the right margin), return-bottom
(under all stages back to an earlier node). Unhinted edges: same stage = down, adjacent stage = elbow."""
import json
import re
import sys
from html import escape
from pathlib import Path

root = Path(__file__).resolve().parents[1]
slug = sys.argv[1] if len(sys.argv) > 1 else 'talos'
folder = root / 'assets/work-products' / slug
flow = json.loads((folder / 'flow.json').read_text())
icons = json.loads((root / 'assets/work-products/icons.json').read_text())
tokens = (root / 'assets/css/tokens.css').read_text()
tok = lambda n: re.search(r'--' + re.escape(n) + r':\s*(#[0-9a-fA-F]+)', tokens).group(1)
INK, PAPER, SURFACE, ACCENT, CITRUS, MUTED = tok('ink'), tok('paper'), tok('surface'), tok('accent'), tok('citrus'), tok('ink-secondary')
RULE, FRAME = tok('field-rule'), '#f3f3f1'
FONT = '"Archivo","Helvetica Neue",Helvetica,Arial,sans-serif'
MONO = '"IBM Plex Mono",ui-monospace,Menlo,monospace'
EDGE = '#3d4452'

NODE_W, NODE_H, GATE_W, PITCH = 296, 118, 224, 164
PAD, HEADER, GAP, MARGIN, TOP = 42, 58, 88, 24, 20
FRAME_W = NODE_W + 2 * PAD
CHIP = 44

def wrap(text, size, bold, width):
    per = size * (0.585 if bold else 0.52)
    lines, cur = [], ''
    for word in text.split():
        trial = (cur + ' ' + word).strip()
        if len(trial) * per <= width or not cur:
            cur = trial
        else:
            lines.append(cur); cur = word
    return lines + [cur] if cur else lines

# ---- layout
stage_rows = max(len(s['nodes']) for s in flow['stages'])
frame_h = HEADER + (stage_rows - 1) * PITCH + NODE_H + PAD - 8
nodes, stage_of, frames = {}, {}, []
for si, st in enumerate(flow['stages']):
    fx = MARGIN + si * (FRAME_W + GAP)
    frames.append((fx, TOP, st['title']))
    for row, n in enumerate(st['nodes']):
        w = GATE_W if n['type'] == 'gate' else NODE_W
        nodes[n['id']] = dict(n, x=fx + (FRAME_W - w) / 2, y=TOP + HEADER + row * PITCH, w=w, h=NODE_H, stage=si, row=row)
        stage_of[n['id']] = si
width = MARGIN * 2 + len(flow['stages']) * FRAME_W + (len(flow['stages']) - 1) * GAP
has_return = any(e.get('route') == 'return-bottom' for e in flow['edges'])
bottom_y = TOP + frame_h + 34
height = bottom_y + 34 if has_return else TOP + frame_h + MARGIN

def side(n, s):
    return {'left': (n['x'], n['y'] + n['h'] / 2), 'right': (n['x'] + n['w'], n['y'] + n['h'] / 2),
            'top': (n['x'] + n['w'] / 2, n['y']), 'bottom': (n['x'] + n['w'] / 2, n['y'] + n['h'])}[s]

out = []
add = out.append
add(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="{width}" height="{height}" role="img" font-family=\'{FONT}\'>')
add(f'<defs><marker id="ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="9" markerHeight="9" orient="auto-start-reverse"><path d="M1 1 L9 5 L1 9" fill="none" stroke="{EDGE}" stroke-width="1.6" stroke-linejoin="round" stroke-linecap="round"/></marker></defs>')
add(f'<rect width="{width}" height="{height}" fill="{PAPER}"/>')
for fx, fy, title in frames:
    add(f'<rect x="{fx}" y="{fy}" width="{FRAME_W}" height="{frame_h}" fill="{FRAME}" stroke="{RULE}" stroke-width="1.25"/>')
    add(f'<text x="{fx + 20}" y="{fy + 34}" font-family=\'{MONO}\' font-size="14" font-weight="600" letter-spacing="1.1" fill="{MUTED}">{escape(title.upper())}</text>')

# ---- edges (drawn before nodes so cards sit on top; labels after)
labels, gap_slot = [], {}
for e in flow['edges']:
    a, b = nodes[e['from']], nodes[e['to']]
    route, dashed = e.get('route'), e.get('dashed')
    lab = e.get('label')
    rot = False
    if route == 'left-lane':
        lx = frames[a['stage']][0] + 17
        p = [side(a, 'left'), (lx, a['y'] + a['h'] / 2), (lx, b['y'] + b['h'] / 2), side(b, 'left')]
        lp = (lx, (p[1][1] + p[2][1]) / 2); rot = True
    elif route == 'right-bus':
        k = gap_slot.setdefault(('rb', a['id'] if 'id' in a else e['from']), 0)
        gap_slot[('rb', e['from'])] += 1
        lx = frames[a['stage']][0] + FRAME_W - 12 - 17 * k
        p = [side(a, 'right'), (lx, a['y'] + a['h'] / 2), (lx, b['y'] + b['h'] / 2), side(b, 'right')]
        lp = (lx, (p[1][1] + p[2][1]) / 2); rot = True
    elif route == 'return-bottom':
        lx = frames[b['stage']][0] + 17
        p = [side(a, 'bottom'), (side(a, 'bottom')[0], bottom_y), (lx, bottom_y), (lx, b['y'] + b['h'] / 2), side(b, 'left')]
        lp = ((p[1][0] + p[2][0]) / 2, bottom_y)
    elif a['stage'] == b['stage']:
        p = [side(a, 'bottom'), side(b, 'top')]
        lp = ((p[0][0] + p[1][0]) / 2, p[0][1] + (p[1][1] - p[0][1]) * .5)
    else:
        sa, ea = side(a, 'right'), side(b, 'left')
        gx0 = frames[a['stage']][0] + FRAME_W
        slot = gap_slot.setdefault(('g', a['stage']), 0)
        gap_slot[('g', a['stage'])] += 1
        gx = gx0 + GAP / 2
        if abs(sa[1] - ea[1]) < 1:
            p = [sa, ea]; lp = (gx, sa[1])
        else:
            p = [sa, (gx, sa[1]), (gx, ea[1]), ea]; lp = (gx, (sa[1] + ea[1]) / 2)
    d = 'M' + ' L'.join(f'{x:.1f} {y:.1f}' for x, y in p)
    add(f'<path d="{d}" fill="none" stroke="{EDGE}" stroke-width="1.6"{" stroke-dasharray=\"7 5\"" if dashed else ""} stroke-linejoin="round" marker-end="url(#ah)"/>')
    if lab:
        labels.append((lab, lp, rot, dashed))

# ---- nodes
def chip_icon(x, y, name, stroke, fill):
    add(f'<rect x="{x}" y="{y}" width="{CHIP}" height="{CHIP}" fill="{fill}"/>')
    s = 26 / 24
    add(f'<g transform="translate({x + (CHIP - 26) / 2:.1f} {y + (CHIP - 26) / 2:.1f}) scale({s:.4f})" fill="none" stroke="{stroke}" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">{icons[name]}</g>')

for n in nodes.values():
    x, y, w, h, t = n['x'], n['y'], n['w'], n['h'], n['type']
    if t == 'gate':
        cx, cy = x + w / 2, y + h / 2
        add(f'<polygon points="{cx},{y} {x + w},{cy} {cx},{y + h} {x},{cy}" fill="{CITRUS}" stroke="{INK}" stroke-width="1.5"/>')
        lines = wrap(n['label'], 19, True, 120)
        for i, ln in enumerate(lines):
            ty = cy + 7 + (i - (len(lines) - 1) / 2) * 23
            add(f'<text x="{cx}" y="{ty:.1f}" text-anchor="middle" font-size="19" font-weight="700" fill="{INK}">{escape(ln)}</text>')
        continue
    if t == 'action':
        fill, ink, sub, stroke, chipf, chips = ACCENT, SURFACE, '#d4e4dc', ACCENT, 'rgba(255,255,255,.16)', SURFACE
    elif t == 'judgment':
        fill, ink, sub, stroke, chipf, chips = CITRUS, INK, '#2b2e24', INK, 'rgba(11,11,12,.09)', INK
    else:
        fill, ink, sub, stroke, chipf, chips = SURFACE, INK, MUTED, INK, '#efefec', INK
    add(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{fill}" stroke="{stroke}" stroke-width="1.25"/>')
    if t == 'judgment':
        add(f'<rect x="{x}" y="{y}" width="{w}" height="5" fill="{INK}"/>')
    if t == 'state':
        add(f'<rect x="{x}" y="{y}" width="4" height="{h}" fill="{INK}"/><line x1="{x + 8}" y1="{y}" x2="{x + 8}" y2="{y + h}" stroke="{INK}" stroke-width="1"/>')
    tx = x + 22
    if n.get('icon'):
        chip_icon(x + (22 if t != 'state' else 24), y + (h - CHIP) / 2 + (2 if t == 'judgment' else 0), n['icon'], chips, chipf)
        tx = x + (22 if t != 'state' else 24) + CHIP + 14
    elif t == 'state':
        tx = x + 26
    tw = x + w - 14 - tx
    tl = wrap(n['label'], 19, True, tw)
    dl = wrap(n.get('desc', ''), 16, False, tw)[:2] if n.get('desc') else []
    block = len(tl) * 24 + (7 + len(dl) * 21 if dl else 0)
    cy0 = y + (h - block) / 2 + (2 if t == 'judgment' else 0)
    for i, ln in enumerate(tl):
        add(f'<text x="{tx}" y="{cy0 + 18 + i * 24:.1f}" font-size="19" font-weight="700" fill="{ink}">{escape(ln)}</text>')
    for i, ln in enumerate(dl):
        add(f'<text x="{tx}" y="{cy0 + len(tl) * 24 + 7 + 15 + i * 21:.1f}" font-size="16" fill="{sub}">{escape(ln)}</text>')

# ---- edge labels last, on top
for lab, (x, y), rot, dashed in labels:
    wlab = len(lab) * 8.2 + 18
    if rot:
        add(f'<g transform="translate({x:.1f} {y:.1f}) rotate(-90)"><rect x="{-wlab / 2:.1f}" y="-11" width="{wlab:.1f}" height="22" fill="{PAPER}" stroke="{RULE}"/><text y="5" text-anchor="middle" font-size="14.5" fill="{EDGE}">{escape(lab)}</text></g>')
    else:
        add(f'<rect x="{x - wlab / 2:.1f}" y="{y - 11:.1f}" width="{wlab:.1f}" height="22" fill="{PAPER}" stroke="{RULE}"/><text x="{x:.1f}" y="{y + 5:.1f}" text-anchor="middle" font-size="14.5" fill="{EDGE}">{escape(lab)}</text>')
add('</svg>')
(folder / 'workflow.svg').write_text('\n'.join(out) + '\n')
print(f'rendered {slug}: {width}x{height}')
