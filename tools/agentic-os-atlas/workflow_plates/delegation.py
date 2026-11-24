#!/usr/bin/env python3
"""Plate for the safe-delegation guide: readiness, execution and completion as separate gates,
with a missing-evidence branch and an escalation to a person. Invented, public-safe content."""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from plate_lib import Plate

p = Plate('wf-delegation-gates', 'Fig W6', 'Delegation gates', y0=130, folder='workflow-plates')
p.node('contract', 'Shaped contract', 'state', 0, 0, icon='ScrollText', sub='Requirements, checks',
       desc='Requirements with stable ids, each with an acceptance check, written by one pass.')
p.node('certify', 'Readiness lint', 'check', 1, 0, icon='ClipboardCheck', sub='A separate pass',
       desc='A different pass reads the contract fresh and returns ready, needs repair or blocked. The pass that wrote the contract never certifies it.')
p.node('ready', 'Ready?', 'rule', 2, 0,
       desc='Yes only if the certification matches the current text of the contract and every explicit policy gate passes. An agent may promote work to ready at that point. Done, merge and publish stay with a person.')
p.node('admit', 'Admit', 'check', 3, 0, icon='DoorOpen', sub='Deterministic',
       desc='A fixed check admits the work: ready, still certified, nothing it needs is blocked. No judgment call is made here.')
p.node('build', 'Build in isolation', 'tool', 4, 0, icon='Code', sub='Own working copy',
       desc='A builder works in its own copy and records evidence against each requirement id as it goes.')
p.node('review', 'Independent review', 'check', 4, 1, icon='ScanSearch',
       desc='A reviewer who did not build the work checks the diff against the standards and the contract.')
p.node('verify', 'Evidence meets contract?', 'rule', 3, 1,
       desc='Each requirement is checked against recorded evidence. A requirement with no evidence counts as unmet, not as passed.')
p.node('accept', 'Person accepts', 'human', 2, 1, icon='UserRoundCheck', sub='Done, merge, publish',
       desc='Accepting the work, merging it and publishing it stay with a person, who reads the evidence first.')
p.node('escalate', 'Person rules', 'human', 3, 2, icon='UserRound', sub='Stuck or out of contract',
       desc='After the retry limit, or when the contract itself is wrong, a person decides: amend the contract, narrow the scope or drop the work.')
p.edge('contract', 'certify', 'right', 'left', 'Lint')
p.edge('certify', 'ready', 'right', 'left', 'Verdict')
p.edge('ready', 'admit', 'right', 'left', 'Promote', 'pass')
p.edge('ready', 'contract', 'top', 'top', 'Repair first', 'feedback', 'step', 56)
p.edge('admit', 'build', 'right', 'left', 'Assign')
p.edge('build', 'review', 'bottom', 'top', 'Diff, evidence', 'normalL')
p.edge('review', 'verify', 'left', 'right', 'Findings')
p.edge('verify', 'accept', 'left', 'right', 'All met', 'pass')
p.edge('verify', 'admit', 'top', 'bottom', 'Missing: retry', 'feedback')
p.edge('verify', 'escalate', 'bottom', 'top', 'Retry limit', 'decision')
p.edge('escalate', 'contract', 'left', 'bottom', 'Amend contract', 'feedback', 'step')
p.group('Readiness', ['contract', 'certify', 'ready'], 'zinc')
p.group('Execution', ['admit', 'build', 'review', 'verify'], 'emerald')
p.save()
