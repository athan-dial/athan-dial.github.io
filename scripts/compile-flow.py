#!/usr/bin/env python3
"""Compile assets/work-products/<slug>/flow.json into workflow.ofk (+ routes.json for render-workflow.py).
Node types: action (forest), judgment (citrus), gate (citrus diamond), state / direction (outline).
Edge route hints: gate-lane, left-lane, right-bus, return-bottom (see render-workflow.py)."""
import json, subprocess, sys, tempfile
from pathlib import Path
root = Path(__file__).resolve().parents[1]
slug = sys.argv[1] if len(sys.argv) > 1 else 'talos'
folder = root / 'assets/work-products' / slug
flow = json.loads((folder / 'flow.json').read_text())
GAP, ROW0, ROW = 36, 42, 150
STYLE = {'action': '"#14543c", bold', 'judgment': '"#e4f17c", bold', 'gate': '"#e4f17c", bold',
         'state': 'gray, outline', 'direction': 'gray, outline'}

def build(xs):
    out = ['architecture right', 'appearance: paper', 'icons: off']
    stage_of = {}
    for si, st in enumerate(flow['stages']):
        out.append(f'group {st["id"]} = "{st["title"]}" [pin: "{xs[si]},0"] {{')
        for row, n in enumerate(st['nodes']):
            stage_of[n['id']] = si
            x, y = n.get('x', 20), ROW0 + row * ROW
            if n['type'] == 'gate':
                attrs = f'diamond, {STYLE["gate"]}, width: 150, height: 88, pin: "{x},{y}"'
            else:
                icon = f'icon: tabler/{n["icon"]}, iconpos: left, ' if n.get('icon') else ''
                desc = f', desc: "{n["desc"]}"' if n.get('desc') else ''
                attrs = f'{icon}{STYLE[n["type"]]}{desc}, pin: "{x},{y}"'
            out.append(f'  {n["id"]} = "{n["label"]}" [{attrs}]')
        out.append('}')
    for e in flow['edges']:
        arrow = '-->' if e.get('dashed') else '->'
        label = f' : {e["label"]}' if e.get('label') else ''
        sides = e.get('sides') or (['right', 'left'] if stage_of[e['from']] != stage_of[e['to']] else None)
        side = f' [from: {sides[0]}, to: {sides[1]}]' if sides else ''
        out.append(f'{e["from"]} {arrow} {e["to"]}{label}{side}')
    return '\n'.join(out) + '\n'

def frame_widths(ofk):
    with tempfile.TemporaryDirectory() as d:
        f, j = Path(d) / 'p.ofk', Path(d) / 'p.json'
        f.write_text(ofk)
        subprocess.run(['npx', '--yes', 'openflowkit@0.3.0', 'convert', str(f), '-o', str(j), '--strict'],
                       check=True, capture_output=True)
        nodes = json.loads(j.read_text())['pages'][0]['nodes']
    return [max(n['transform']['translation']['x'] + n['size']['width'] for n in nodes if n['parentId'] == st_id) + 20
            for st_id in [next(n['id'] for n in nodes if n['id'] == st['id']) for st in flow['stages']]]

widths = frame_widths(build([i * 400 for i in range(len(flow['stages']))]))
xs, x = [], 0
for w in widths:
    xs.append(round(x)); x += w + GAP
(folder / 'workflow.ofk').write_text(build(xs))
(folder / 'routes.json').write_text(json.dumps(
    [{'from': e['from'], 'to': e['to'], 'kind': e['route']} for e in flow['edges'] if e.get('route')], indent=1) + '\n')
print(f'compiled {slug}: stage x = {xs}')
