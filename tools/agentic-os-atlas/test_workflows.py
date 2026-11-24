#!/usr/bin/env python3
"""Negative fixtures for validate_workflows.py: each mutation of known-good data must make it fail.

  python3 tools/agentic-os-atlas/test_workflows.py

The baseline is a copy of the real data plus a synthetic wayfinder guide and build graph, so these
tests keep working whatever the real guides say. Exit status is non-zero if any case is not caught.
"""
import copy, json, shutil, subprocess, sys, tempfile
from pathlib import Path

repo = Path(__file__).resolve().parents[2]
validator = Path(__file__).with_name('validate_workflows.py')

MAP = dict(destination='a spec', states=[
    dict(label='Session 1', fog=['how names are reconciled'], tickets=[
        dict(id='T1', title='Who may borrow', type='grilling', status='frontier', blocked_by=[]),
        dict(id='T2', title='Get inventories', type='task', status='frontier', blocked_by=[]),
        dict(id='T3', title='Catalogue page', type='prototype', status='blocked', blocked_by=['T2'])]),
    dict(label='Session 3', fog=[], tickets=[
        dict(id='T1', title='Who may borrow', type='grilling', status='settled', answer='Members only', blocked_by=[]),
        dict(id='T2', title='Get inventories', type='task', status='frontier', blocked_by=[]),
        dict(id='T3', title='Catalogue page', type='prototype', status='blocked', blocked_by=['T2']),
        dict(id='T4', title='Guest access', type='grilling', status='frontier', blocked_by=[], exposed_by='T1')])])
BUILD = dict(slices=[dict(id='S1', title='Record a pledge', blocked_by=[], verify='ledger test'),
                     dict(id='S2', title='List stock', blocked_by=['S1'], verify='stock test')])
STEPS = [dict(actor='skill', skill='wayfinder', label='a', text='b', public_equivalents=['grilling', 'prototype']), dict(actor='skill', skill='to-spec', label='a2', text='b2'), dict(actor='human', label='c', text='d'),
         dict(actor='artifact', label='e', text='f')]
GUIDE = dict(id='wayfinder', title='t', lead='l', produces='p', scenario='s', input='i', steps=STEPS, artifact=dict(title='a', lines=['x']),
             stop='s', limits='l', map=MAP, build=BUILD, compare=dict(rows=[]))

def make(mutate, files=None):
    d = Path(tempfile.mkdtemp())
    shutil.copytree(repo / 'data', d / 'data', ignore=shutil.ignore_patterns('plates'))
    shutil.copytree(repo / 'data/agentic-os/plates', d / 'data/agentic-os/plates')
    (d / 'tools/agentic-os-atlas').mkdir(parents=True)
    shutil.copytree(repo / 'tools/agentic-os-atlas/src', d / 'tools/agentic-os-atlas/src')
    shutil.copy(repo / 'tools/agentic-os-atlas/.bundle-digest', d / 'tools/agentic-os-atlas/.bundle-digest')
    reg = json.loads((d / 'data/workflows/registry.json').read_text())
    guides = {p.stem: json.loads(p.read_text()) for p in (d / 'data/workflows/guides').glob('*.json')}
    guides['wayfinder'] = copy.deepcopy(GUIDE)
    reg['guides'] = [g for g in reg['guides']]
    mutate(reg, guides)
    (d / 'data/workflows/registry.json').write_text(json.dumps(reg))
    for f in (d / 'data/workflows/guides').glob('*.json'): f.unlink()
    for k, v in guides.items(): (d / f'data/workflows/guides/{k}.json').write_text(json.dumps(v))
    if files: files(d)
    return d

def run(mutate, files=None, flags=()):
    d = make(mutate, files)
    try:
        r = subprocess.run([sys.executable, str(validator), '--root', str(d), *flags], capture_output=True, text=True)
        return r.returncode, r.stdout
    finally:
        shutil.rmtree(d, ignore_errors=True)

def skill(reg, i): return next(s for s in reg['skills'] if s['id'] == i)
def guide(reg, i): return next(g for g in reg['guides'] if g['id'] == i)

CASES = {
 'baseline passes': (None, 'RESULT: PASS'),
 'duplicate skill id': (lambda r, g: r['skills'].append(copy.deepcopy(r['skills'][0])), 'skill ids unique: duplicates'),
 'duplicate guide id': (lambda r, g: r['guides'].append(copy.deepcopy(r['guides'][0])), 'guide ids unique: duplicates'),
 'dangling skill in guide': (lambda r, g: guide(r, 'idea-to-spec')['skills'].append('no-such-skill'), 'dangling skill'),
 'dangling view in guide': (lambda r, g: guide(r, 'idea-to-spec')['views'].append('no-such-view'), 'dangling view'),
 'orphan skill': (lambda r, g: r['skills'].append(dict(id='lonely', name='lonely', job='j', source_kind='private', url=None, customized=True, status_note='n')), 'orphans'),
 'upstream url off the pinned revision': (lambda r, g: skill(r, 'to-spec').update(url=skill(r, 'to-spec')['url'].replace(r['upstream']['rev'], 'main')), 'pinned revision'),
 'upstream url for the wrong folder': (lambda r, g: skill(r, 'to-spec').update(url=skill(r, 'to-tickets')['url']), 'folder does not match'),
 'private skill with a url': (lambda r, g: skill(r, 'research').update(url='https://example.com/x'), 'must not carry a url'),
 'private skill without a status note': (lambda r, g: skill(r, 'research').pop('status_note'), 'needs a status_note'),
 'customized skill without a difference': (lambda r, g: skill(r, 'tdd').pop('difference'), 'must say how it differs'),
 'private guide without a source status': (lambda r, g: guide(r, 'research').pop('source_status'), 'no public skill link'),
 'guide file missing': (lambda r, g: g.pop('research'), 'no file'),
 'skill attached but never used': (lambda r, g: g['idea-to-spec'].update(steps=[s for s in g['idea-to-spec']['steps'] if s.get('skill') != 'to-spec']), 'never used in a step'),
 'step with unknown actor': (lambda r, g: g['idea-to-spec']['steps'][0].update(actor='robot'), 'actor'),
 'step names a skill the guide lacks': (lambda r, g: g['idea-to-spec']['steps'][0].update(skill='implement'), 'does not attach'),
 'no human step': (lambda r, g: g['idea-to-spec'].update(steps=[s for s in g['idea-to-spec']['steps'] if s['actor'] != 'human']), 'no human decision step'),
 'missing stop condition': (lambda r, g: g['idea-to-spec'].pop('stop'), 'missing stop'),
 'private name leaks into a guide': (lambda r, g: g['idea-to-spec'].update(lead='Tracked in a Jira board.'), 'public-safety'),
 'private path leaks into a guide': (lambda r, g: g['idea-to-spec'].update(limits='See ~/.claude/skills.'), 'public-safety'),
 'foreign url in a guide': (lambda r, g: g['idea-to-spec'].update(limits='See https://example.com/skill.'), 'public-safety'),
 'frontier ticket still blocked': (lambda r, g: g['wayfinder']['map']['states'][0]['tickets'][2].update(status='frontier'), 'frontier ticket T3 still has open blockers'),
 'blocked ticket nothing blocks': (lambda r, g: g['wayfinder']['map']['states'][0]['tickets'][2].update(blocked_by=[]), 'marked blocked but nothing blocks'),
 'settled ticket without an answer': (lambda r, g: g['wayfinder']['map']['states'][1]['tickets'][0].pop('answer'), 'no recorded answer'),
 'ticket blocked by a missing ticket': (lambda r, g: g['wayfinder']['map']['states'][0]['tickets'][2].update(blocked_by=['T9']), 'missing T9'),
 'decision ticket typed as a build step': (lambda r, g: g['wayfinder']['map']['states'][0]['tickets'][0].update(type='slice'), 'decision-map tickets are'),
 'later state un-settles a decision': (lambda r, g: (g['wayfinder']['map']['states'][0]['tickets'][0].update(status='settled', answer='x'), g['wayfinder']['map']['states'][1]['tickets'][0].update(status='frontier')), 'un-settles'),
 'new ticket not exposed by a decision': (lambda r, g: g['wayfinder']['map']['states'][1]['tickets'][3].pop('exposed_by'), 'must say which settled decision exposed it'),
 'no fog in the first state': (lambda r, g: g['wayfinder']['map']['states'][0].update(fog=[]), 'no unresolved scope'),
 'decision cycle': (lambda r, g: (g['wayfinder']['map']['states'][0]['tickets'][1].update(blocked_by=['T3']),), 'cycle'),
 'build slice with nothing to verify it': (lambda r, g: g['wayfinder']['build']['slices'][0].pop('verify'), 'no way to verify'),
 'build slice that is a decision ticket': (lambda r, g: g['wayfinder']['build']['slices'][0].update(type='research'), 'decision ticket'),
 'build cycle': (lambda r, g: (g['wayfinder']['build']['slices'][0].update(blocked_by=['S2']),), 'cycle'),
 'wayfinder without a comparison': (lambda r, g: g['wayfinder'].pop('compare'), 'comparison'),
 'unknown plate': (lambda r, g: g['idea-to-spec'].update(plates=['ghost']), 'does not exist'),
}

def plate_edit(fn):
    def go(d):
        f = d / 'data/agentic-os/workflow-plates/wf-map-1.arc.json'
        if not f.exists(): f = next((d / 'data/agentic-os/workflow-plates').glob('*.arc.json'))
        doc = json.loads(f.read_text()); fn(doc); f.write_text(json.dumps(doc))
    return go

def first_plate(d): return next((d / 'data/agentic-os/workflow-plates').glob('*.arc.json'))

CASES.update({
 'private name after a newline in a guide': (lambda r, g: g['idea-to-spec'].update(lead='Notes.\nJira board.'), 'public-safety'),
 'private name after an em dash in a guide': (lambda r, g: g['idea-to-spec'].update(lead='A note\u2014Slack thread.'), 'public-safety'),
 'email in a guide': (lambda r, g: g['idea-to-spec'].update(lead='Write to someone@example.org.'), 'email'),
 'token in a guide': (lambda r, g: g['idea-to-spec'].update(lead='key ghp_abcdefghij12345'), 'tokens'),
 'ticket key in a guide': (lambda r, g: g['idea-to-spec'].update(lead='See PROJ-1234.'), 'ticket keys'),
 'settled ticket still waits for a blocker': (lambda r, g: g['wayfinder']['map']['states'][0]['tickets'][2].update(status='settled', answer='x'), 'settled ticket T3 still waits'),
 'map state without a label': (lambda r, g: g['wayfinder']['map']['states'][1].pop('label'), 'needs a label'),
 'no later ticket exposed by a decision': (lambda r, g: g['wayfinder']['map']['states'][1]['tickets'][3].update(exposed_by='T1', blocked_by=[]) or g['wayfinder']['map']['states'][1]['tickets'][3].pop('exposed_by'), 'must say which settled decision'),
 'next guide does not exist': (lambda r, g: g['idea-to-spec'].update(next=dict(label='x', guide='ghost')), 'next.guide'),
 'next guide is a stub': (lambda r, g: (g['idea-to-spec'].update(next=dict(label='x', guide='research')), g['research'].clear(), g['research'].update(id='research', draft_stub=True)), 'next.guide'),
 'invalid order value': (lambda r, g: g['idea-to-spec'].update(order='sideways'), 'order must be'),
 'plate id with a comma': (lambda r, g: g['wayfinder']['map'].update(plates=dict(ids=['a,b'], labels=['x'], caption='c')), 'comma or bar'),
 'plate labels do not match ids': (lambda r, g: g['wayfinder']['map'].update(plates=dict(ids=['a', 'b'], labels=['x'], caption='c')), 'one label per id'),
 'bad compared_on date': (lambda r, g: r['upstream'].update(compared_on='yesterday'), 'compared_on'),
 'bad upstream revision': (lambda r, g: r['upstream'].update(rev='main'), '40-character'),
 'guide without a produces line': (lambda r, g: g['idea-to-spec'].pop('produces'), 'missing produces'),
 'registry without the example note': (lambda r, g: r['intro'].pop('examples'), 'intro.examples'),
 'registry without the source note': (lambda r, g: r['intro'].pop('sources'), 'intro.sources'),
 '--complete with a stub': (lambda r, g: (g['research'].clear(), g['research'].update(id='research', draft_stub=True)), 'still stubs'),
})
PLATE_CASES = {
 'private name inside a plate': (plate_edit(lambda doc: doc['nodeData'][next(iter(doc['nodeData']))].update(name='Check the Jira board')), 'public-safety'),
 'plate node without a description': (plate_edit(lambda doc: doc['nodeData'][next(iter(doc['nodeData']))].update(description='')), 'no description'),
 'plate without a layout size': (plate_edit(lambda doc: doc.pop('layout')), 'layout width and height'),
 'plate connector without a label': (plate_edit(lambda doc: doc['connectors'][0].update(label='')), 'has no label'),
 'plate connector to a missing node': (plate_edit(lambda doc: doc['connectors'][0].update(to='ghost')), 'missing node'),
 'plate with duplicate connector ids': (plate_edit(lambda doc: doc['connectors'].append(dict(doc['connectors'][0]))), 'duplicate connector ids'),
 'bundle older than the plate data': (plate_edit(lambda doc: doc['figure'].update(title=doc['figure']['title'] + ' edited')), 'bundle is stale'),
}
bad = 0
for name, (mut, expect) in CASES.items():
    flags = ('--complete',) if name.startswith('--complete') else ()
    code, out = run(mut or (lambda r, g: None), flags=flags)
    good = (code == 0 and expect in out) if mut is None else (code != 0 and expect in out)
    print(('ok   ' if good else 'FAIL ') + name + ('' if good else f' (exit {code}; wanted {expect!r})'))
    bad += not good
for name, (files, expect) in PLATE_CASES.items():
    code, out = run(lambda r, g: None, files)
    good = code != 0 and expect in out
    print(('ok   ' if good else 'FAIL ') + name + ('' if good else f' (exit {code}; wanted {expect!r})'))
    bad += not good
print(f'\nRESULT: {"FAIL" if bad else "PASS"} ({len(CASES) + len(PLATE_CASES)} cases)'); sys.exit(1 if bad else 0)
