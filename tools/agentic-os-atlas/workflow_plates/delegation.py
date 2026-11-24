#!/usr/bin/env python3
"""Plate for the safe-delegation guide: readiness, execution and completion as separate gates,
with a missing-evidence branch and an escalation to a person. Invented, public-safe content."""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from plate_lib import Plate

p = Plate('wf-delegation-gates', 'Fig W6', 'Delegation gates', y0=130, folder='workflow-plates')
# Three columns, snaking: readiness along the top, execution back along the middle, people at the bottom.
p.node('contract', 'Shaped contract', 'state', 0, 0, icon='ScrollText', sub='Requirements, checks',
       desc='Requirements with stable ids, each with an acceptance check, written by one pass.')
p.node('certify', 'Readiness lint', 'check', 1, 0, icon='ClipboardCheck', sub='A separate pass',
       desc='A different pass reads the contract cold and returns ready, needs repair or blocked. The pass that wrote the contract never certifies it.')
p.node('ready', 'Ready?', 'rule', 2, 0,
       desc='Yes only if the certification is tied to the current wording and the explicit policy gates pass, which can include an instruction from a person. An agent may promote work to ready then, and cannot mark it finished, merge it or publish it.')
p.node('admit', 'Pick up', 'check', 2, 1, icon='DoorOpen', sub='Fixed check, no judgment',
       desc='When a builder is about to start, a fixed rule re-checks that the work is marked ready, the certification still matches the wording, and nothing it depends on is unfinished. No judgment call is made here.')
p.node('build', 'Build in isolation', 'tool', 1, 1, icon='Code', sub='Own working copy',
       desc='A builder works in its own copy of the project and records evidence against each requirement id as it goes.')
p.node('review', 'Independent review', 'check', 0, 1, icon='ScanSearch', sub='Not the builder',
       desc='A reviewer who did not build the work checks the diff against the project standards and the spec.')
p.node('verify', 'Evidence meets contract?', 'rule', 1, 2,
       desc='Each requirement is checked against recorded evidence. A requirement with no evidence counts as unmet, not as passed.')
p.node('accept', 'Person finishes', 'human', 1, 3, icon='UserRoundCheck', sub='Finish, merge, publish',
       desc='Marking the work finished, merging it and publishing it stay with a person, who reads the evidence first.')
p.node('escalate', 'Person rules', 'human', 2, 3, icon='UserRound', sub='Waiting or contradictory',
       desc='When attempts run out, or the contract contradicts itself, the work waits for a person, who decides: amend the contract, narrow the scope or drop the work.')
p.edge('contract', 'certify', 'right', 'left', 'Lint')
p.edge('certify', 'ready', 'right', 'left', 'Result')
p.edge('ready', 'contract', 'top', 'top', 'Needs repair', 'feedback', 'step', 56)
p.edge('ready', 'admit', 'bottom', 'top', 'Promoted', 'pass')
p.edge('admit', 'build', 'left', 'right', 'Assign')
p.edge('build', 'review', 'left', 'right', 'Diff, evidence')
p.edge('review', 'verify', 'bottom', 'left', 'Findings', 'normal', 'step')
p.edge('verify', 'build', 'top', 'bottom', 'Another attempt', 'feedback')
p.edge('verify', 'accept', 'bottom', 'top', 'All met: to review', 'pass')
p.edge('verify', 'escalate', 'right', 'top', 'Attempts used up', 'decision', 'step')
p.edge('escalate', 'ready', 'right', 'right', 'Amend', 'feedback', 'step', 60)
p.group('Readiness', ['contract', 'certify', 'ready'], 'zinc')
p.group('Execution', ['admit', 'build', 'review', 'verify'], 'emerald')
p.group('A person decides', ['accept', 'escalate'], 'amber')
p.save()
