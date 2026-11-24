#!/usr/bin/env python3
"""Rebuild the synthetic benchmark workflow (fixture.json, 13 nodes / 17 transitions)
as a native Arc plate in the site's Fieldnotes style, using the patched engine's
diamond gateway, return lanes and larger symbols.  Layout is authored, not auto."""
import json
from pathlib import Path

here = Path(__file__).parent
fx = json.loads((here / 'fixture.json').read_text())['views']['workflow']

ROLE = {  # role -> (color, icon, shape)
    'human':   ('amber',   'UserRound',   'pill'),
    'skill':   ('blue',    'Layers',      'rounded'),
    'worker':  ('emerald', 'Bot',         'rounded'),
    'store':   ('zinc',    'Database',    'square'),
    'control': ('blue',    'Route',       'rounded'),
    'review':  ('emerald', 'ShieldCheck', 'rounded'),
}
W, H, GATE_H, GATE_W, COL, X0, Y0 = 224, 120, 168, 236, 310, 40, 56
pos = {  # key -> (col, y)
    'request': (0, 250), 'scan': (1, 250), 'frame': (2, 250), 'spec': (3, 250), 'gate': (4, 250),
    'implement': (5, 250), 'verify': (6, 250), 'peer': (7, 250), 'release': (8, 250),
    'approval': (4, Y0), 'rework': (6, 490), 'backlog': (2, 650), 'retro': (8, 650)}
nodes, data = {}, {}
for key, (label, role, *_rest) in fx['nodes'].items():
    color, icon, shape = ROLE[role]
    col, y = pos[key]
    h = H
    w, x_off = W, 0
    if key == 'gate':
        color, icon, shape, h, w = 'amber', 'GitFork', 'diamond', GATE_H, GATE_W
        y = 250 - (GATE_H - H) // 2
        x_off = -(GATE_W - W) // 2
    if key == 'verify': icon = 'ShieldCheck'
    if key == 'peer': icon, color = 'UserRoundCheck', 'amber'
    if key == 'implement': icon = 'Bot'
    if key == 'release': icon = 'Rocket'
    nodes[key] = dict(x=X0 + col * COL + x_off, y=y, size='m', width=w, height=h)
    data[key] = dict(name=label, color=color, icon=icon, shape=shape)

A = lambda f, t, fa, ta, label, style='normal', curve=None: dict(
    **{'from': f, 'to': t}, fromAnchor=fa, toAnchor=ta, style=style, label=label,
    **({'curve': curve} if curve else {}))
route = {  # (from,to) -> anchors/style, in fixture order
    ('request', 'scan'): ('right', 'left', 'normal', 'direct'),
    ('scan', 'frame'): ('right', 'left', 'normal', 'direct'),
    ('frame', 'spec'): ('right', 'left', 'normal', 'direct'),
    ('spec', 'gate'): ('right', 'left', 'normal', 'direct'),
    ('gate', 'implement'): ('right', 'left', 'pass', 'direct'),
    ('gate', 'approval'): ('top', 'bottom', 'decision', 'direct'),
    ('approval', 'implement'): ('right', 'top', 'pass', 'step'),
    ('approval', 'frame'): ('left', 'top', 'feedback', 'step'),
    ('implement', 'verify'): ('right', 'left', 'normal', 'direct'),
    ('verify', 'peer'): ('right', 'left', 'pass', 'direct'),
    ('verify', 'rework'): ('bottom', 'top', 'feedback', 'direct'),
    ('peer', 'release'): ('right', 'left', 'pass', 'direct'),
    ('peer', 'rework'): ('bottom', 'right', 'feedback', 'step'),
    ('rework', 'implement'): ('left', 'bottom', 'feedback', 'step'),
    ('release', 'retro'): ('bottom', 'top', 'normal', 'direct'),
    ('retro', 'backlog'): ('left', 'right', 'feedback', 'direct'),
    ('backlog', 'frame'): ('top', 'bottom', 'feedback', 'direct'),
}
conns = []
for i, (f, t, label) in enumerate(fx['edges']):
    fa, ta, style, curve = route[(f, t)]
    c = A(f, t, fa, ta, label, style, curve); c['id'] = f'e{i}'
    conns.append(c)
assert len(conns) == 17 and len(nodes) == 13
plate = dict(
    id='fixture-workflow', figure=dict(title='Product delivery workflow', code='BM-02'),
    layout=dict(width=X0 * 2 + 8 * COL + W, height=800), nodes=nodes, nodeData=data,
    connectorStyles={
        'normal': dict(color='zinc', strokeWidth=1.7, toArrow='arrow'),
        'pass': dict(color='emerald', strokeWidth=1.9, toArrow='arrow'),
        'decision': dict(color='amber', strokeWidth=1.9, toArrow='arrow'),
        'feedback': dict(color='zinc', strokeWidth=1.7, lineStyle='dashed', toArrow='open')},
    connectors=conns, groups=[], _meta=dict(viewMode='2d', colorMode='light'))
(here / 'workflow.fieldnotes.arc.json').write_text(json.dumps(plate, indent=2) + '\n')
print('ok', len(nodes), 'nodes', len(conns), 'connectors')
