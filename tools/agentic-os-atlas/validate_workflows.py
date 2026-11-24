#!/usr/bin/env python3
"""Validate the workflow registry and the guides built on it.

  python3 tools/agentic-os-atlas/validate_workflows.py [--root DIR] [--complete] [--online]

One curated registry (data/workflows/registry.json) supplies skill identity, source status and the
guide-to-skill-to-view relationships. Guide files (data/workflows/guides/<id>.json) carry the worked
example. Nothing here reads Agent Home: a skill is "private" because the registry says so, and a
private skill carries no URL and no instruction text.

  --complete  fail while any guide is still a draft stub
  --online    also fetch each upstream source anonymously (raw.githubusercontent.com mirror of the
              pinned blob URL) and require HTTP 200. The github.com page itself is not fetched: some
              networks block it, which says nothing about anonymous access.
Exit status is non-zero on any failure.
"""
import json, re, sys, urllib.request
from pathlib import Path

args = sys.argv[1:]
root = Path(args[args.index('--root') + 1]) if '--root' in args else Path(__file__).resolve().parents[2]
data = root / 'data'
failures = []
def fail(m): failures.append(m); print('FAIL', m)
def ok(m): print('ok  ', m)

PATTERNS = {'private names and systems': (r'\b(montai|jira|confluence|todoist|slack)\b', re.I),
            'paths': (r'(/Users/|/home/|~/\.|C:\\|\.mex/|\.dev/)', 0), 'email': (r'[\w.+-]+@[\w-]+\.[\w.]+', 0),
            'foreign urls': (r'https?://(?!github\.com/mattpocock/skills\b)', 0), 'tokens': (r'(sk-[A-Za-z0-9]{10,}|ghp_[A-Za-z0-9]{10,}|AKIA[0-9A-Z]{12,})', 0),
            'ticket keys': (r'\b[A-Z]{2,6}-\d{2,5}\b', 0)}

def strings(o):
    """Every decoded string value in a JSON document. Scanning decoded text, not json.dumps output, so a name after
    a newline or an escaped character is still seen."""
    if isinstance(o, str): yield o
    elif isinstance(o, dict):
        for v in o.values(): yield from strings(v)
    elif isinstance(o, list):
        for v in o: yield from strings(v)

def scan(label, doc):
    for name, (pat, fl) in PATTERNS.items():
        hits = [m for s in strings(doc) for m in re.findall(pat, s, flags=fl)]
        if hits: fail(f'{label}: public-safety scan: {name} -> {hits[:3]}')

def load(p):
    try: return json.loads(Path(p).read_text())
    except Exception as e: fail(f'{p}: cannot read ({e})'); return None

reg = load(data / 'workflows/registry.json')
views = load(data / 'agentic-os/views.json')
if reg is None or views is None: sys.exit(1)
view_ids = {v['id'] for v in views['views']}
plate_dir = data / 'agentic-os/workflow-plates'
plate_ids = {p.name.replace('.arc.json', '') for p in plate_dir.glob('*.arc.json')} if plate_dir.exists() else set()

# ---- workflow plates: native Arc JSON, same integrity rules as the architecture plates
for pid in sorted(plate_ids):
    pl = load(plate_dir / f'{pid}.arc.json')
    if pl is None: continue
    nodes = set(pl.get('nodes', {}))
    if nodes != set(pl.get('nodeData', {})): fail(f'plate {pid}: nodes/nodeData keys differ')
    for c in pl.get('connectors', []):
        if c['from'] not in nodes or c['to'] not in nodes: fail(f'plate {pid}: connector {c.get("id")} points at a missing node')
        if not c.get('label'): fail(f'plate {pid}: connector {c.get("id")} has no label')
        if c.get('style') not in pl.get('connectorStyles', {}): fail(f'plate {pid}: connector {c.get("id")} uses an undefined style')
    for nid, nd in pl.get('nodeData', {}).items():
        if not nd.get('description'): fail(f'plate {pid}.{nid}: no description for the text version')
    scan(f'plate {pid}', pl)
    if not (pl.get('layout', {}).get('width') and pl.get('layout', {}).get('height')): fail(f'plate {pid}: layout width and height are required')
    cids = [c.get('id') for c in pl.get('connectors', [])]
    if len(cids) != len(set(cids)): fail(f'plate {pid}: duplicate connector ids')
    if any(not nd.get('name') for nd in pl.get('nodeData', {}).values()): fail(f'plate {pid}: a node has no name')
    if re.search(r'[,|]', pid): fail(f'plate id {pid} contains a comma or bar')
if plate_ids: ok(f'{len(plate_ids)} workflow plate(s) pass integrity checks')

# ---- registry: identity and source status
up = reg.get('upstream', {})
rev, repo = up.get('rev', ''), up.get('repo', '')
if not re.fullmatch(r'[0-9a-f]{40}', rev): fail('upstream.rev is not a 40-character commit')
base = f'{repo}/blob/{rev}/skills/'
if not re.fullmatch(r'\d{4}-\d{2}-\d{2}', up.get('compared_on', '')): fail('upstream.compared_on must be a date (when the copies were last compared)')
for k in ('examples', 'sources'):
    if not (reg.get('intro') or {}).get(k): fail(f'registry intro.{k} is missing: the synthetic-example and source-access notes appear once, near the top')
skills = reg.get('skills', [])
ids = [s.get('id') for s in skills]
dupes = sorted({i for i in ids if ids.count(i) > 1})
(fail if dupes else ok)('skill ids unique' + (f': duplicates {dupes}' if dupes else ''))
sid = set(ids)
for s in skills:
    i = s.get('id', '?')
    for k in ('id', 'name', 'job', 'source_kind', 'customized'):
        if k not in s: fail(f'skill {i}: missing {k}')
    kind = s.get('source_kind')
    if kind == 'upstream':
        u = s.get('url') or ''
        if not (u.startswith(base) and re.fullmatch(r'(engineering|productivity)/[a-z0-9-]+/SKILL\.md', u[len(base):])):
            fail(f'skill {i}: upstream url is not a SKILL.md at the pinned revision')
        elif u.split('/')[-2] != s.get('name'): fail(f'skill {i}: url folder does not match name')
        if s.get('customized') and not s.get('difference'): fail(f'skill {i}: customized upstream skill must say how it differs')
        if not s.get('customized') and s.get('difference'): fail(f'skill {i}: difference given for an uncustomized skill')
    elif kind == 'private':
        if s.get('url'): fail(f'skill {i}: private skill must not carry a url')
        if not s.get('status_note'): fail(f'skill {i}: private skill needs a status_note')
        if not s.get('customized'): fail(f'skill {i}: a private skill is by definition not the upstream one')
    else:
        fail(f'skill {i}: source_kind {kind!r} is not upstream or private')

# ---- registry: guides
guides = reg.get('guides', [])
gids = [g.get('id') for g in guides]
gd = sorted({i for i in gids if gids.count(i) > 1})
(fail if gd else ok)('guide ids unique' + (f': duplicates {gd}' if gd else ''))
used = set()
for g in guides:
    i = g.get('id', '?')
    for k in ('id', 'priority', 'task', 'skills', 'views'):
        if k not in g: fail(f'guide {i}: missing {k}')
    for s in g.get('skills', []):
        used.add(s)
        if s not in sid: fail(f'guide {i}: dangling skill {s}')
    for v in g.get('views', []):
        if v not in view_ids: fail(f'guide {i}: dangling view {v}')
    public = [s for s in g.get('skills', []) if next((x for x in skills if x['id'] == s), {}).get('url')]
    if not public and not g.get('source_status'): fail(f'guide {i}: no public skill link and no source_status explaining why')
orphans = sorted(sid - used)
(fail if orphans else ok)('every skill is used by a guide' + (f': orphans {orphans}' if orphans else ''))

# ---- guides: content and graph semantics
ACTORS = {'skill', 'human', 'artifact', 'open'}
stubs = []

def toposort(nodes):
    """nodes: id -> set(blocker ids). True when acyclic."""
    seen, stack = set(), set()
    def visit(n):
        if n in stack: return False
        if n in seen: return True
        stack.add(n)
        okay = all(visit(b) for b in nodes.get(n, ()) if b in nodes)
        stack.discard(n); seen.add(n); return okay
    return all(visit(n) for n in nodes)

def check_map(i, m):
    states = m.get('states', [])
    if not m.get('destination'): fail(f'guide {i}: map has no destination')
    if len(states) < 2: fail(f'guide {i}: a map needs at least two states to show progress')
    prev_settled = set(); prev_ids = set()
    for n, st in enumerate(states):
        if not st.get('label'): fail(f'guide {i}: map state {n} needs a label')
        if any('id' not in tk for tk in st.get('tickets', [])): fail(f'guide {i}: state {n} has a ticket with no id'); continue
        ts = {tk['id']: tk for tk in st.get('tickets', [])}
        if len(ts) != len(st.get('tickets', [])): fail(f'guide {i}: state {n} repeats a ticket id')
        for t in ts.values():
            if t.get('type') not in {'grilling', 'research', 'prototype', 'task'}: fail(f'guide {i}: ticket {t.get("id")} has type {t.get("type")!r}; decision-map tickets are grilling, research, prototype or task')
            if t.get('status') not in {'settled', 'frontier', 'blocked'}: fail(f'guide {i}: ticket {t.get("id")} status {t.get("status")!r}')
            for b in t.get('blocked_by', []):
                if b not in ts: fail(f'guide {i}: ticket {t["id"]} is blocked by missing {b}')
        settled = {k for k, t in ts.items() if t['status'] == 'settled'}
        for t in ts.values():
            open_blockers = [b for b in t.get('blocked_by', []) if b in ts and ts[b]['status'] != 'settled']
            if t['status'] == 'frontier' and open_blockers: fail(f'guide {i}: state {n}: frontier ticket {t["id"]} still has open blockers {open_blockers}')
            if t['status'] == 'blocked' and not open_blockers: fail(f'guide {i}: state {n}: ticket {t["id"]} is marked blocked but nothing blocks it')
            if t['status'] == 'settled' and open_blockers: fail(f'guide {i}: state {n}: settled ticket {t["id"]} still waits for {open_blockers}')
            if t['status'] == 'settled' and not t.get('answer'): fail(f'guide {i}: settled ticket {t["id"]} has no recorded answer')
        if not toposort({k: set(t.get('blocked_by', [])) for k, t in ts.items()}): fail(f'guide {i}: state {n}: blocking edges form a cycle')
        if n and not prev_settled <= settled: fail(f'guide {i}: state {n} un-settles {sorted(prev_settled - settled)}')
        if n and not prev_ids <= set(ts): fail(f'guide {i}: state {n} drops tickets {sorted(prev_ids - set(ts))}')
        for t in ts.values():
            if n and t['id'] not in prev_ids and t.get('exposed_by') not in prev_settled | settled: fail(f'guide {i}: new ticket {t["id"]} in state {n} must say which settled decision exposed it (exposed_by)')
        if not any(t['status'] == 'frontier' for t in ts.values()) and n < len(states) - 1: fail(f'guide {i}: state {n} has no answerable frontier')
        if not st.get('fog') and n == 0: fail(f'guide {i}: state 0 shows no unresolved scope (fog)')
        prev_settled, prev_ids = settled, set(ts)
    if len(states) >= 2 and not any(t.get('exposed_by') for t in states[-1].get('tickets', [])): fail(f'guide {i}: no later ticket shows a decision exposing a new question')

def check_build(i, b):
    sl = {s['id']: s for s in b.get('slices', [])}
    if len(sl) != len(b.get('slices', [])): fail(f'guide {i}: build graph repeats a slice id')
    for s in sl.values():
        if not s.get('verify'): fail(f'guide {i}: slice {s["id"]} has no way to verify it independently')
        if s.get('type') in {'grilling', 'research', 'prototype'}: fail(f'guide {i}: slice {s["id"]} is a decision ticket; the build graph holds work slices')
        for x in s.get('blocked_by', []):
            if x not in sl: fail(f'guide {i}: slice {s["id"]} is blocked by missing {x}')
    if not toposort({k: set(s.get('blocked_by', [])) for k, s in sl.items()}): fail(f'guide {i}: build slices form a cycle')
    if not any(not s.get('blocked_by') for s in sl.values()): fail(f'guide {i}: build graph has no unblocked slice')

for g in guides:
    i = g.get('id', '?')
    p = data / f'workflows/guides/{i}.json'
    if not p.exists(): fail(f'guide {i}: no file {p.relative_to(root)}'); continue
    d = load(p)
    if d is None: continue
    if d.get('id') != i: fail(f'guide {i}: file id is {d.get("id")!r}')
    if d.get('draft_stub'): stubs.append(i); continue
    for k in ('title', 'lead', 'produces', 'scenario', 'input', 'steps', 'artifact', 'stop', 'limits'):
        if not d.get(k): fail(f'guide {i}: missing {k}')
    steps = d.get('steps', [])
    if len(steps) < 3: fail(f'guide {i}: fewer than three steps')
    for n, s in enumerate(steps):
        if s.get('actor') not in ACTORS: fail(f'guide {i}: step {n + 1} actor {s.get("actor")!r}')
        if not s.get('label') or not s.get('text'): fail(f'guide {i}: step {n + 1} needs a label and text')
        for ref in ([s['skill']] if s.get('skill') else []) + s.get('public_equivalents', []):
            if ref not in g.get('skills', []): fail(f'guide {i}: step {n + 1} names skill {ref} that the registry does not attach to this guide')
        if s.get('skill') and s.get('actor') != 'skill': fail(f'guide {i}: step {n + 1} names a skill but is not a skill step')
    if not any(s.get('actor') == 'human' for s in steps): fail(f'guide {i}: no human decision step')
    if not any(s.get('actor') == 'artifact' for s in steps): fail(f'guide {i}: no resulting artifact step')
    for sk in g.get('skills', []):
        if not any(sk == s.get('skill') or sk in s.get('public_equivalents', []) for s in steps): fail(f'guide {i}: registry skill {sk} is never used in a step')
    plate_refs = list(d.get('plates', []))
    for blk in ('map', 'compare', 'build'):
        pl = (d.get(blk) or {}).get('plates')
        if pl is None: continue
        if len(pl.get('labels', [])) != len(pl.get('ids', [])): fail(f'guide {i}: {blk} plates need one label per id')
        if any(re.search(r'[,|]', x) for x in pl.get('ids', []) + pl.get('labels', [])): fail(f'guide {i}: {blk} plate ids and labels may not contain a comma or bar')
        plate_refs += pl.get('ids', [])
    nx = (d.get('next') or {}).get('guide')
    if d.get('next') and (nx not in gids or nx == i or (data / f'workflows/guides/{nx}.json').exists() and (load(data / f'workflows/guides/{nx}.json') or {}).get('draft_stub')): fail(f'guide {i}: next.guide {nx!r} is not another complete guide')
    for pid in plate_refs:
        if pid not in plate_ids: fail(f'guide {i}: plate {pid} does not exist')
    if 'map' in d: check_map(i, d['map'])
    if 'build' in d: check_build(i, d['build'])
    if d.get('order', 'steps-first') not in ('steps-first', 'result-first'): fail(f'guide {i}: order must be steps-first or result-first')
    if i == 'wayfinder' and ('map' not in d or 'compare' not in d): fail('guide wayfinder: needs a map and a decision-map versus build-graph comparison')
    scan(f'guide {i}', d)
scan('registry', reg)
ok(f'{len(guides) - len(stubs)} complete guide(s), {len(stubs)} draft stub(s)' + (f': {stubs}' if stubs else ''))
if '--complete' in args and stubs: fail(f'--complete: guides still stubs: {stubs}')

# ---- the committed Arc bundle must have been built from the current plate data
import hashlib
digest_file = root / 'tools/agentic-os-atlas/.bundle-digest'
def bundle_inputs():
    h = hashlib.sha256()
    for p in sorted((data / 'agentic-os').rglob('*.json')): h.update(p.relative_to(root).as_posix().encode()); h.update(p.read_bytes())
    for p in ('tools/agentic-os-atlas/src/atlas.jsx', 'tools/agentic-os-atlas/src/frame.css'):
        if (root / p).exists(): h.update((root / p).read_bytes())
    return h.hexdigest()
if digest_file.exists():
    (ok if digest_file.read_text().strip() == bundle_inputs() else fail)('Arc bundle was built from the current plate data and sources' if digest_file.read_text().strip() == bundle_inputs() else 'Arc bundle is stale: plate data or atlas sources changed since build.sh ran (rebuild it)')
else:
    fail('tools/agentic-os-atlas/.bundle-digest is missing: run build.sh')

# ---- optional: private terms kept out of the repository. PRIVATE_TERMS_FILE names a gitignored file, one
# term per line; any hit in public data fails. Without it only the generic checks above run.
import os
tf = os.environ.get('PRIVATE_TERMS_FILE')
if tf and Path(tf).exists():
    terms = [x.strip() for x in Path(tf).read_text().splitlines() if x.strip() and not x.startswith('#')]
    blob = '\n'.join(p.read_text() for p in (data / 'workflows').rglob('*.json')) + '\n'.join(p.read_text() for p in plate_dir.glob('*.json'))
    hits = [x for x in terms if re.search(r'\b' + re.escape(x) + r'\b', blob, flags=re.I)]
    (fail if hits else ok)('private terms file: ' + (f'{len(hits)} term(s) found in public data' if hits else 'none found'))

# ---- optional: anonymous availability of each upstream source
if '--online' in args:
    for s in skills:
        if s.get('source_kind') != 'upstream': continue
        raw = s['url'].replace('https://github.com/', 'https://raw.githubusercontent.com/').replace('/blob/', '/', 1)
        try:
            code = urllib.request.urlopen(urllib.request.Request(raw, method='HEAD'), timeout=20).status
        except Exception as e:
            code = getattr(e, 'code', str(e))
        (ok if code == 200 else fail)(f'anonymous fetch {s["id"]}: HTTP {code}')

print('\nRESULT:', 'FAIL' if failures else 'PASS'); sys.exit(1 if failures else 0)
