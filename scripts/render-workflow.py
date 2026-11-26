#!/usr/bin/env python3
"""Render a Work Product diagram: python3 scripts/render-workflow.py [slug] (default talos).
OpenFlowKit 0.3.0, Node 20.11+. Edge routing below is keyed to TALOS node ids; other slugs use native routing."""
import json
import sys
import copy
import re
import textwrap
import subprocess
from pathlib import Path
root = Path(__file__).resolve().parents[1]
slug = sys.argv[1] if len(sys.argv) > 1 else 'talos'
folder = root / 'assets/work-products' / slug
cli = ['npx', '--yes', 'openflowkit@0.3.0']
subprocess.run(cli + ['validate', str(folder / 'workflow.ofk'), '--strict'], check=True)
subprocess.run(cli + ['convert', str(folder / 'workflow.ofk'), '-o', str(folder / 'workflow.openflow.json'), '--strict'], check=True)
path = folder / 'workflow.openflow.json'
doc = json.loads(path.read_text())
# Pins are relative to their containing frame. Fit each native frame to its
# children, then export the four stage frames without the compiler's outer frame.
page = doc['pages'][0]
root_frame = next(node for node in page['nodes'] if node['parentId'] is None)
# Native icon-card sublabels are fixed at 11px in OpenFlowKit 0.3.0. Keep
# provenance as editable native text nodes so descriptions can meet the site's
# 15px floor without modifying the renderer or post-processing exported SVG.
tokens = (root / 'assets/css/tokens.css').read_text()
def token(name):
    return re.search(r'--' + re.escape(name) + r':\s*(#[0-9a-fA-F]+)', tokens).group(1)
annotations = []
for node in page['nodes']:
    node['appearance']['cornerRadius'] = 0
    if node['kind'] == 'frame':
        continue
    node['appearance']['fontSize'] = 16
    node['size']['height'] = max(node['size']['height'], 105)
    description = node['content'].pop('subLabel', '')
    if not description:
        continue
    node['appearance']['textVerticalAlign'] = 'top'
    if node['kind'] == 'architecture':
        node['appearance']['textAlign'] = 'start'
        node['content']['contentLayout']['labelAlignment'] = 'start'
    inset = 54 if node['kind'] == 'architecture' else 12
    annotation = copy.deepcopy(node)
    annotation.update(id=node['id'] + '-description', kind='text', parentId=node['id'])
    annotation['transform']['translation'] = {'x': inset, 'y': 55}
    annotation['size'] = {'width': node['size']['width'] - inset - 8, 'height': 42}
    annotation['content'] = {'label': '\n'.join(textwrap.wrap(description, max(12, int((node['size']['width'] - inset - 8) / 7.8)))), 'fontSize': 16,
                             'fontFamily': 'system-ui, sans-serif', 'fontWeight': '400',
                             'textColor': token('surface') if node['content'].get('customColor') == token('accent') else token('ink')}
    annotation['appearance'] = {'fontSize': 16, 'textPadding': 0,
                               'textAlign': 'start', 'textVerticalAlign': 'top',
                               'textColor': token('surface') if node['content'].get('customColor') == token('accent') else token('ink')}
    annotation['metadata'] = {'purpose': 'provenance-description'}
    annotation['ports'] = []
    annotations.append(annotation)
page['nodes'].extend(annotations)

for frame in page['nodes']:
    if frame['kind'] != 'frame' or frame is root_frame:
        continue
    # OpenFlowKit 0.3.0 preserves group pins as DSL metadata but does not
    # apply them to frame placement. Apply those native scene coordinates.
    pin = next(attr['value'] for attr in frame['metadata']['dsl']['attrs'] if attr['key'] == 'pin')
    x, y = map(float, pin.split(','))
    frame['transform']['translation'] = {'x': x, 'y': y}
    children = [node for node in page['nodes'] if node['parentId'] == frame['id']]
    frame['size'] = {
        'width': max(node['transform']['translation']['x'] + node['size']['width'] for node in children) + 20,
        'height': 625,
    }
# Native connector waypoints keep returns in the outside margin and the accept
# path between stages, avoiding labels or paths running through evidence cards.
by_id = {node['id']: node for node in page['nodes']}
def bounds(node_id):
    node = by_id[node_id]
    x = node['transform']['translation']['x']
    y = node['transform']['translation']['y']
    parent = node['parentId']
    while parent:
        ancestor = by_id[parent]
        x += ancestor['transform']['translation']['x']
        y += ancestor['transform']['translation']['y']
        parent = ancestor['parentId']
    return x, y, node['size']['width'], node['size']['height']

def route(edge, points, source_side, target_side):
    edge['route'] = {'kind': 'orthogonal', 'ownership': 'manual'}
    edge['waypoints'] = [{'x': x, 'y': y} for x, y in points]
    for end, side in [('source', source_side), ('target', target_side)]:
        edge[end]['anchor'] = {'kind': 'side', 'side': side, 'ratio': .5}

for edge in page['connectors']:
    pair = (edge['source']['nodeId'], edge['target']['nodeId'])
    if pair == ('briefs', 'sources'):
        bx, by, bw, bh = bounds('briefs')
        sx, sy, sw, sh = bounds('sources')
        route(edge, [(bx + bw / 2, bounds('hold')[1] + bounds('hold')[3] + 80),
                     (sx - 35, bounds('hold')[1] + bounds('hold')[3] + 80),
                     (sx - 35, sy + sh / 2)], 'bottom', 'left')
    elif pair == ('hold', 'review'):
        hx, hy, hw, hh = bounds('hold')
        rx, ry, rw, rh = bounds('review')
        route(edge, [(rx - 10, hy + hh / 2), (rx - 10, ry + rh / 2)], 'left', 'left')
    elif pair == ('ready', 'record'):
        gx, gy, gw, gh = bounds('ready')
        rx, ry, rw, rh = bounds('record')
        route(edge, [(rx - 10, gy + gh / 2), (rx - 10, ry + rh / 2)], 'right', 'left')
        for label in edge['labels']:
            label['pathRatio'] = .05
            label['offset'] = {'x': 0, 'y': -14}
    elif pair in [('record', 'timelines'), ('record', 'briefs')]:
        rx, ry, rw, rh = bounds('record')
        tx, ty, tw, th = bounds(pair[1])
        lane = max(bounds(item)[0] + bounds(item)[2] for item in ['record', 'landscapes', 'timelines', 'briefs']) + 10
        route(edge, [(lane, ry + rh / 2), (lane, ty + th / 2)], 'right', 'right')
        edge['labels'] = []
stage_frames = [n for n in page['nodes'] if n['kind'] == 'frame' and n is not root_frame]
root_frame['size'] = {'width': max(f['transform']['translation']['x'] + f['size']['width'] for f in stage_frames) + 14,
                      'height': max(f['size']['height'] for f in stage_frames) + 25}
path.write_text(json.dumps(doc, indent=2) + '\n')
args = {'format': 'svg', 'scope': 'selection',
        'ids': [node['id'] for node in page['nodes'] if node is not root_frame]
               + [edge['id'] for edge in page['connectors']]}
result = subprocess.run(cli + ['op', 'export', '--doc', str(path), '--args', json.dumps(args)],
                        check=True, capture_output=True, text=True)
(folder / 'workflow.svg').write_text(json.loads(result.stdout)['output']['files'][0]['text'])
