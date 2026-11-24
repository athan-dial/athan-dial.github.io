#!/usr/bin/env python3
"""Validate the atlas dataset: Arc JSON schema, graph integrity and reachability, public-safety scan.

  python3 tools/agentic-os-atlas/validate.py [--schema path/to/arc-diagram.schema.json]

The schema ships with Arc (schemas/arc-diagram.schema.json in the pinned checkout, under
tools/agentic-os-atlas/.arc/arc after build.sh). Exit status is non-zero on the first class of failure.
"""
import json, re, sys
from pathlib import Path

root = Path(__file__).resolve().parents[2]
data = root / 'data' / 'agentic-os'
args = sys.argv[1:]
schema_path = Path(args[args.index('--schema') + 1]) if '--schema' in args else root / 'tools/agentic-os-atlas/.arc/arc/schemas/arc-diagram.schema.json'
failures = []

def fail(msg): failures.append(msg); print('FAIL', msg)
def ok(msg): print('ok  ', msg)

views = json.loads((data / 'views.json').read_text())
plates = {p.name.replace('.arc.json', ''): json.loads(p.read_text()) for p in sorted((data / 'plates').glob('*.arc.json'))}

# 1. schema
try:
    import jsonschema
    schema = json.loads(schema_path.read_text())
    for pid, plate in plates.items():
        errs = sorted(jsonschema.Draft7Validator(schema).iter_errors(plate), key=lambda e: list(e.path))
        (fail if errs else ok)(f'schema {pid}' + (f': {errs[0].message} at {list(errs[0].path)}' if errs else ''))
except Exception as e:  # missing schema or jsonschema: report, do not pretend
    print('SKIP schema validation:', e)

# 2. graph integrity
total_nodes = total_edges = 0
for pid, p in plates.items():
    nodes = set(p['nodes']); total_nodes += len(nodes); total_edges += len(p['connectors'])
    if nodes != set(p['nodeData']): fail(f'{pid}: nodes/nodeData keys differ')
    for c in p['connectors']:
        if c['from'] not in nodes or c['to'] not in nodes: fail(f'{pid}: connector {c["id"]} points at a missing node')
        if c['style'] not in p['connectorStyles']: fail(f'{pid}: connector {c["id"]} uses undefined style {c["style"]}')
        if not c.get('label'): fail(f'{pid}: connector {c["id"]} has no label')
    for nid, nd in p['nodeData'].items():
        if 'child' in nd and nd['child'] not in plates: fail(f'{pid}.{nid}: child {nd["child"]} is not a plate')
        if not nd.get('description'): fail(f'{pid}.{nid}: no description for the text version')
    if [v['order'] for v in views['views'] if v['id'] == pid][0] != list(p['nodes']): fail(f'{pid}: views.json order drifted from the plate')
ok(f'{len(plates)} plates, {total_nodes} nodes, {total_edges} labelled relationships')

# 3. reachability from the overview through child links, and a way back (every plate is a child of exactly one parent)
seen, queue, parents = {views['root']}, [views['root']], {}
while queue:
    cur = queue.pop(0)
    for nid, nd in plates[cur]['nodeData'].items():
        ch = nd.get('child')
        if ch:
            parents.setdefault(ch, []).append(cur)
            if ch not in seen: seen.add(ch); queue.append(ch)
(ok if seen == set(plates) else fail)(f'all views reachable from overview: {sorted(set(plates) - seen) or "yes"}')
(ok if all(len(v) == 1 for v in parents.values()) else fail)('each drill-down view has one parent: ' + json.dumps({k: v[0] for k, v in parents.items()}))

# 4. public safety: private names, paths, accounts, secrets-looking strings
blob = '\n'.join((data / f).read_text() for f in ['views.json', 'style.json']) + '\n'.join(p.read_text() for p in (data / 'plates').glob('*.json'))
blob += (root / 'content/work/agentic-operating-system.md').read_text()
patterns = {'employer/project terms': r'\b(montai|aops|jira|confluence|atlas goal|todoist|slack)\b', 'paths': r'(/Users/|/home/|~/\.|C:\\)', 'email': r'[\w.+-]+@[\w-]+\.[\w.]+',
            'urls': r'https?://(?!github\.com/hudsonkit/arc)', 'tokens': r'(sk-[A-Za-z0-9]{10,}|ghp_[A-Za-z0-9]{10,}|AKIA[0-9A-Z]{12,})', 'ticket keys': r'\b(?!AOS-0[1-7]\b)[A-Z]{2,6}-\d{2,5}\b'}
for name, pat in patterns.items():
    hits = re.findall(pat, blob, flags=re.I if name == 'employer/project terms' else 0)
    (fail if hits else ok)(f'public-safety scan: {name}' + (f' -> {hits[:3]}' if hits else ''))

print('\nRESULT:', 'FAIL' if failures else 'PASS'); sys.exit(1 if failures else 0)
