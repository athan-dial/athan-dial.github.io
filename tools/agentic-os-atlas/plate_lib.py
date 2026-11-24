"""Shared helper for authoring native Arc plates (nodes, connectors, groups) as plain Arc JSON.

build_plates.py uses it for the seven architecture views; workflow_plates/*.py use it for the small
diagrams embedded in guides (written to data/agentic-os/workflow-plates/). Public-safe content only:
no project, employer, ticket, path or account names.
"""
import json
from pathlib import Path

OUT = Path(__file__).resolve().parents[2] / 'data' / 'agentic-os'
(OUT / 'plates').mkdir(parents=True, exist_ok=True)
(OUT / 'workflow-plates').mkdir(parents=True, exist_ok=True)

W, H = 232, 112            # standard node
GW, GH = 252, 176         # decision diamond
COL, ROW, X0 = 340, 250, 40

KIND = {  # kind -> (palette colour, icon, silhouette)
    'human':  ('amber',   'UserRound',   'pill'),      # human judgment / authorization (citrus)
    'tool':   ('emerald', 'Bot',         'rounded'),   # an action or tool (forest)
    'state':  ('zinc',    'FileText',    'square'),    # data, evidence or state (paper)
    'check':  ('blue',    'ShieldCheck', 'rounded'),   # an independent check or enforced rule
    'gate':   ('amber',   'GitFork',     'diamond'),   # a decision a person makes
    'rule':   ('blue',    'GitFork',     'diamond'),   # a deterministic yes/no
}
STYLES = {
    'normal':   dict(color='zinc', strokeWidth=1.7, toArrow='arrow'),
    'pass':     dict(color='emerald', strokeWidth=1.9, toArrow='arrow'),
    'decision': dict(color='amber', strokeWidth=1.9, toArrow='arrow'),
    'feedback': dict(color='zinc', strokeWidth=1.7, lineStyle='dashed', toArrow='open'),
    'normalL': dict(color='zinc', strokeWidth=1.7, toArrow='arrow', labelAlign='left'),
    'feedbackL': dict(color='zinc', strokeWidth=1.7, lineStyle='dashed', toArrow='open', labelAlign='left'),
}


ORDER = {}


class Plate:
    def __init__(self, pid, code, title, y0=70, folder='plates'):
        self.id, self.code, self.title, self.y0, self.folder = pid, code, title, y0, folder
        self.nodes, self.data, self.conns, self.groups = {}, {}, [], []

    def node(self, nid, name, kind, col, row, *, icon=None, sub=None, desc=None, child=None,
             dx=0, dy=0):
        color, ic, shape = KIND[kind]
        w, h = (GW, GH) if shape == 'diamond' else (W, H)
        x = X0 + col * COL + dx - (w - W) // 2
        y = self.y0 + row * ROW + dy - (h - H) // 2
        self.nodes[nid] = dict(x=round(x), y=round(y), size='m', width=w, height=h)
        d = dict(name=name, color=color, icon=icon or ic, shape=shape)
        if sub: d['subtitle'] = sub
        if desc: d['description'] = desc
        if child: d['child'] = child
        self.data[nid] = d

    def edge(self, a, b, fa, ta, label, style='normal', curve='direct', depth=None):
        c = {'id': f'e{len(self.conns)}', 'from': a, 'to': b, 'fromAnchor': fa, 'toAnchor': ta,
             'style': style, 'label': label, 'curve': curve}
        if depth: c['curveDepth'] = depth
        self.conns.append(c)

    def group(self, label, ids, color='zinc', pad=(16, 32, 16, 14)):
        n = [self.nodes[i] for i in ids]
        l = min(v['x'] for v in n) - pad[0]
        t = min(v['y'] for v in n) - pad[1]
        r = max(v['x'] + v['width'] for v in n) + pad[2]
        b = max(v['y'] + v['height'] for v in n) + pad[3]
        self.groups.append(dict(id=f'g{len(self.groups)}', type='rect', label=label,
                                x=l, y=t, width=r - l, height=b - t, color=color))

    def save(self):
        ORDER[self.id] = list(self.nodes)
        n = list(self.nodes.values())
        width = max(v['x'] + v['width'] for v in n) + 150
        height = max(v['y'] + v['height'] for v in n) + 110
        used = {c['style'] for c in self.conns}
        doc = dict(id=self.id, figure=dict(title=self.title, code=self.code),
                   layout=dict(width=width, height=height), nodes=self.nodes, nodeData=self.data,
                   connectorStyles={k: v for k, v in STYLES.items() if k in used},
                   connectors=self.conns, groups=self.groups,
                   _meta=dict(viewMode='2d', colorMode='light'))
        (OUT / self.folder / f'{self.id}.arc.json').write_text(json.dumps(doc, indent=2) + '\n')
