#!/usr/bin/env python3
"""Plates for the wayfinder guide. Synthetic example (three village choirs); not live tracker state.

Shape grammar, so status never rests on colour alone:
  square  = settled          pill = answerable now (frontier)
  rounded = blocked          diamond = fog (not yet specified)
  solid arrow = blocks       dashed arrow = a settled decision exposed this question
Run: python3 tools/agentic-os-atlas/workflow_plates/wayfinder.py
"""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from plate_lib import Plate

ICON = {'research': 'Search', 'grilling': 'Scale', 'prototype': 'Lightbulb', 'task': 'Hammer'}
KIND = {'settled': 'state', 'frontier': 'human', 'blocked': 'check'}
LABEL = {'settled': 'Settled', 'frontier': 'Answerable now', 'blocked': 'Blocked'}


def ticket(p, nid, name, status, typ, col, row, desc):
    p.node(nid, name, KIND[status], col, row, icon=ICON[typ], sub=f'{LABEL[status]} · {typ}', desc=desc)


def fog(p, nid, name, col, row, desc):
    p.node(nid, name, 'rule', col, row, icon='FileStack', sub='Fog · not yet a question', desc=desc)


# ---- map after session 1: one ticket settled, the page ticket unblocked
p = Plate('wf-map-1', 'WF-01', 'Choir season map, after session 1', folder='workflow-plates')
ticket(p, 'cal', "Collect each choir's calendar", 'settled', 'task', 0, 0, 'Done in session 1. All three choirs rehearse Thursday and Saturday evenings; two already book the same hall.')
ticket(p, 'add', 'Who may add a concert?', 'frontier', 'grilling', 0, 1, 'A question for you, one session. Nothing blocks it.')
ticket(p, 'fees', 'How do other festivals split hall hire?', 'frontier', 'research', 0, 2, 'An agent can run this alone and report findings.')
ticket(p, 'page', 'What should the calendar page show?', 'frontier', 'prototype', 1, 0, 'Was waiting for the calendars. Now answerable.')
ticket(p, 'clash', 'How are clashes settled?', 'blocked', 'grilling', 1, 1, 'Cannot be asked well until we know who may add a concert.')
fog(p, 'fog1', 'Singers in two choirs', 2, 0, 'Sensed, but not yet a sharp question.')
fog(p, 'fog2', 'Who pays the piano tuner', 2, 1, 'Sensed, but not yet a sharp question.')
p.edge('cal', 'page', 'right', 'left', 'Unblocked')
p.edge('add', 'clash', 'right', 'left', 'Blocks', 'decision')
p.group('Not yet specified', ['fog1', 'fog2'], 'zinc')
p.save()

# ---- map after session 3
p = Plate('wf-map-2', 'WF-02', 'Choir season map, after session 3', folder='workflow-plates')
ticket(p, 'cal', "Collect each choir's calendar", 'settled', 'task', 0, 0, 'Settled in session 1.')
ticket(p, 'add', 'Who may add a concert?', 'settled', 'grilling', 0, 1, 'Settled in session 2. Any choir chair may add one; a second chair must confirm.')
ticket(p, 'fees', 'How do other festivals split hall hire?', 'settled', 'research', 0, 2, 'Settled in session 2 by an agent. Most split hall hire evenly and keep their own ticket money.')
ticket(p, 'page', 'What should the calendar page show?', 'settled', 'prototype', 1, 0, 'Settled in session 3. A month grid, a hall name on each concert, no sign-in.')
ticket(p, 'clash', 'How are clashes settled?', 'frontier', 'grilling', 1, 1, 'Unblocked once the first rule was settled.')
ticket(p, 'costs', 'How are shared costs split?', 'frontier', 'grilling', 1, 2, 'New. Raised by the research finding.')
ticket(p, 'mixed', 'How are two-choir singers counted?', 'frontier', 'grilling', 2, 0, 'New. The calendars showed nine singers on two lists.')
ticket(p, 'notice', 'How far ahead is the season published?', 'blocked', 'grilling', 2, 1, 'New, raised by the calendar prototype. Waits for the clash rule.')
fog(p, 'fog3', 'A shared conductor', 2, 2, 'Sensed, but not yet a sharp question.')
p.edge('clash', 'notice', 'right', 'left', 'Blocks', 'decision')
p.edge('fees', 'costs', 'right', 'left', 'Exposed', 'feedback')
p.edge('cal', 'mixed', 'top', 'top', 'Exposed', 'feedback', 'step', 56)
p.group('Not yet specified', ['fog3'], 'zinc')
p.save()

# ---- compare: decision map
p = Plate('wf-compare-decisions', 'WF-03', 'Decision map: questions found along the way', folder='workflow-plates')
ticket(p, 'q1', 'Who may add a concert?', 'settled', 'grilling', 0, 0, 'Settled. It exposed the next question.')
ticket(p, 'q2', 'How are clashes settled?', 'frontier', 'grilling', 1, 0, 'Asked after the first answer, not before.')
fog(p, 'fog', 'Questions not yet visible', 1, 1, 'The graph is partial. It grows as answers arrive.')
p.node('spec', 'A specification', 'state', 2, 0, icon='ScrollText', sub='The map ends here', desc='A document someone could build from.')
p.edge('q1', 'q2', 'right', 'left', 'Exposes', 'feedback')
p.edge('q2', 'spec', 'right', 'left', 'Decision')
p.save()

# ---- compare: build graph
p = Plate('wf-compare-build', 'WF-04', 'Build graph: slices drafted up front', folder='workflow-plates')
p.node('s1', 'Record a booking', 'tool', 0, 0, icon='Hammer', sub='Slice 1 · unblocked', desc='Works end to end on its own.')
p.node('s2', 'Show the season calendar', 'tool', 1, 0, icon='Hammer', sub='Slice 2', desc='Needs bookings to show.')
p.node('s3', 'Flag a clash', 'tool', 2, 0, icon='Hammer', sub='Slice 3', desc='Needs the calendar to compare against.')
p.node('code', 'Working calendar', 'check', 3, 0, icon='ShieldCheck', sub='The graph ends here', desc='Each slice was checked on its own.')
p.edge('s1', 's2', 'right', 'left', 'Blocks')
p.edge('s2', 's3', 'right', 'left', 'Blocks')
p.edge('s3', 'code', 'right', 'left', 'Verified')
p.save()
