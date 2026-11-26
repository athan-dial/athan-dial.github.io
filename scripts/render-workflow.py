#!/usr/bin/env python3
"""Render TALOS's native diagram with OpenFlowKit 0.3.0 (Node 20.11+)."""
import json
import subprocess
from pathlib import Path
root = Path(__file__).resolve().parents[1]
folder = root / 'assets/work-products/talos'
cli = ['npx', '--yes', 'openflowkit@0.3.0']
subprocess.run(cli + ['validate', str(folder / 'workflow.ofk'), '--strict'], check=True)
subprocess.run(cli + ['convert', str(folder / 'workflow.ofk'), '-o', str(folder / 'workflow.openflow.json'), '--strict'], check=True)
path = folder / 'workflow.openflow.json'
doc = json.loads(path.read_text())
# Pins are relative to their containing frame. Fit each native frame to its
# children, then export the four stage frames without the compiler's outer frame.
page = doc['pages'][0]
root_frame = next(node for node in page['nodes'] if node['parentId'] is None)
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
        'height': 590,
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
        route(edge, [(bx + bw / 2, 730), (145, 730), (145, sy + sh / 2)], 'bottom', 'left')
    elif pair == ('hold', 'review'):
        hx, hy, hw, hh = bounds('hold')
        rx, ry, rw, rh = bounds('review')
        route(edge, [(735, hy + hh / 2), (735, ry + rh / 2)], 'left', 'left')
    elif pair == ('ready', 'record'):
        gx, gy, gw, gh = bounds('ready')
        rx, ry, rw, rh = bounds('record')
        route(edge, [(1030, gy + gh / 2), (1030, ry + rh / 2)], 'right', 'left')
    elif pair in [('record', 'timelines'), ('record', 'briefs')]:
        rx, ry, rw, rh = bounds('record')
        tx, ty, tw, th = bounds(pair[1])
        lane = 1292 if pair[1] == 'timelines' else 1300
        route(edge, [(lane, ry + rh / 2), (lane, ty + th / 2)], 'right', 'right')
        edge['labels'] = []
root_frame['size'] = {'width': 1166, 'height': 650}
path.write_text(json.dumps(doc, indent=2) + '\n')
args = {'format': 'svg', 'scope': 'selection',
        'ids': [node['id'] for node in page['nodes'] if node is not root_frame]
               + [edge['id'] for edge in page['connectors']]}
result = subprocess.run(cli + ['op', 'export', '--doc', str(path), '--args', json.dumps(args)],
                        check=True, capture_output=True, text=True)
(folder / 'workflow.svg').write_text(json.loads(result.stdout)['output']['files'][0]['text'])
