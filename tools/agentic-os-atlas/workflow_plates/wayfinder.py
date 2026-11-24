#!/usr/bin/env python3
"""Plates for the wayfinder guide. Synthetic example (the Assay Compare results-store map); not live tracker state.

Shape grammar, so status never rests on colour alone:
  square  = settled          pill = answerable now (frontier)
  rounded = blocked          diamond = fog (not yet specified)
  solid arrow = blocks or feeds   dashed arrow = a settled decision exposed this question
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


def spec_input(p, col, row):
    p.node('input', 'Run comparison v1 spec', 'state', col, row, icon='ScrollText', sub='Settled input · not a ticket',
           desc='The specification from the first guide. Its decisions, such as one designated reference run per protocol version and CSV only, are taken as given and are not reopened on this map.')


# ---- map after session 1
p = Plate('wf-map-1', 'Fig W1', 'Results store map, after session 1', folder='workflow-plates')
ticket(p, 'exports', "Collect every instrument's export format", 'settled', 'task', 0, 0, 'Done in session 1. Instruments A and B export CSV with different column layouts, some site 2 files use a decimal comma, and instrument C has no usable export.')
ticket(p, 'first', 'Which assays move first?', 'frontier', 'grilling', 0, 1, 'A question for you, one session. Nothing blocks it.')
ticket(p, 'research', 'How do labs version protocols?', 'frontier', 'research', 0, 2, 'An agent can run this alone and report findings.')
ticket(p, 'proto', 'What should a run page show?', 'frontier', 'prototype', 1, 0, 'A rough page to react to. Nothing blocks it.')
ticket(p, 'retire', 'How are reference runs retired?', 'blocked', 'grilling', 1, 1, 'Cannot be asked well until we know which assays move first.')
spec_input(p, 1, 2)
fog(p, 'fog1', 'Retention of failed runs', 2, 0, 'Sensed, but not yet a sharp question.')
fog(p, 'fog2', 'Regulated-study audit trail', 2, 1, 'Sensed, but not yet a sharp question.')
p.edge('first', 'retire', 'right', 'left', 'Blocks', 'decision')
p.edge('input', 'retire', 'top', 'bottom', 'Input to')
p.group('Not yet specified', ['fog1', 'fog2'], 'zinc')
p.save()

# ---- map after session 3
p = Plate('wf-map-2', 'Fig W2', 'Results store map, after session 3', folder='workflow-plates')
ticket(p, 'exports', "Collect every instrument's export format", 'settled', 'task', 0, 0, 'Settled in session 1.')
ticket(p, 'research', 'How do labs version protocols?', 'settled', 'research', 0, 1, 'Settled by an agent. Of the sources found, most keep one reference run per protocol version, and several version the plate layout separately.')
ticket(p, 'first', 'Which assays move first?', 'settled', 'grilling', 0, 2, 'Settled in session 2. Unregulated assays on instruments A and B move first.')
ticket(p, 'proto', 'What should a run page show?', 'settled', 'prototype', 0, 3, 'Settled in session 3. Run name, protocol version and reference run at the top, the plate overlay, and flagged wells listed beside it.')
ticket(p, 'decimals', 'Decimal and unit conventions across sites?', 'frontier', 'grilling', 1, 0, 'New. The collected exports showed more than one decimal convention.')
ticket(p, 'layouts', 'How are plate layouts versioned?', 'frontier', 'grilling', 1, 1, 'New. Raised by the research finding.')
ticket(p, 'retire', 'How are reference runs retired?', 'frontier', 'grilling', 1, 2, 'Unblocked once the first assays were chosen.')
ticket(p, 'designate', 'Who may designate a reference run?', 'frontier', 'grilling', 1, 3, 'New. Raised by the first-assays decision.')
fog(p, 'fog3', 'Retention of failed runs', 2, 0, 'Sensed, but not yet a sharp question.')
ticket(p, 'audit', 'Audit trail for regulated studies', 'blocked', 'grilling', 2, 2, 'Graduated from fog. It can now be asked, but waits for the retirement rule.')
spec_input(p, 2, 3)
p.edge('exports', 'decimals', 'right', 'left', 'Exposed', 'feedback')
p.edge('research', 'layouts', 'right', 'left', 'Exposed', 'feedback')
p.edge('first', 'retire', 'right', 'left', 'Unblocked')
p.edge('first', 'designate', 'right', 'left', 'Exposed', 'feedback', 'step')
p.edge('retire', 'audit', 'right', 'left', 'Blocks', 'decision')
p.edge('input', 'designate', 'left', 'right', 'Input to')
p.group('Not yet specified', ['fog3'], 'zinc')
p.save()

# ---- compare: decision map
p = Plate('wf-compare-decisions', 'Fig W3', 'Decision map: questions found along the way', folder='workflow-plates')
ticket(p, 'q1', 'Which assays move first?', 'settled', 'grilling', 0, 0, 'Settled. The answer exposed the next question.')
ticket(p, 'q2', 'Who may designate a reference run?', 'frontier', 'grilling', 1, 0, 'Asked after the first answer, not before.')
fog(p, 'fog', 'Questions not yet visible', 1, 0.8, 'The graph is partial. It grows as answers arrive.')
p.node('spec', 'A specification', 'state', 2, 0, icon='ScrollText', sub='The map ends here', desc='A document someone could build from.')
p.edge('q1', 'q2', 'right', 'left', 'Exposed', 'feedback')
p.edge('q2', 'spec', 'right', 'left', 'Decision')
p.save()

# ---- compare: build graph
p = Plate('wf-compare-build', 'Fig W4', 'Build graph: slices drafted up front', folder='workflow-plates')
p.node('s1', 'Import instrument A export', 'tool', 0, 0, icon='Hammer', sub='Slice · unblocked', desc='Works end to end on its own: an export goes in and raw wells show.')
p.node('s3', 'Normalise to % of control', 'tool', 1, 0, icon='Hammer', sub='Slice', desc='Needs imported wells to normalise.')
p.node('code', 'Checked code', 'check', 2, 0, icon='ShieldCheck', sub='The graph ends here', desc='Each slice was checked on its own.')
p.edge('s1', 's3', 'right', 'left', 'Blocks')
p.edge('s3', 'code', 'right', 'left', 'Verified')
p.save()
