#!/usr/bin/env python3
"""Author the seven Agentic Operating System plates as native Arc JSON.

This script is an authoring convenience, not a schema: it writes plain Arc diagram files
into data/agentic-os/plates/ plus views.json (the prose for each view). The JSON is the
canonical dataset. It can be opened and edited in Arc Studio, and Hugo reads the same files
to render the no-JavaScript text version of every view. Re-running this script overwrites
them, so edit one or the other, not both.

Everything here is a curated, generalised account of a personal working method. No project,
customer, employer, ticket, path or account names belong in this file.
"""
import json
from pathlib import Path

OUT = Path(__file__).resolve().parents[2] / 'data' / 'agentic-os'
(OUT / 'plates').mkdir(parents=True, exist_ok=True)

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
    def __init__(self, pid, code, title, y0=70):
        self.id, self.code, self.title, self.y0 = pid, code, title, y0
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
        (OUT / 'plates' / f'{self.id}.arc.json').write_text(json.dumps(doc, indent=2) + '\n')


# ---------------------------------------------------------------- 01 overview
p = Plate('overview', 'AOS-01', 'System overview', y0=120)
p.node('human', 'Human direction', 'human', 0, 0, sub='Intent, taste, accountability',
       desc='A person sets the direction, makes the judgment calls and owns the outcome.')
p.node('thinking', 'Thinking', 'tool', 1, 0, icon='Lightbulb', child='thinking', sub='Open ↗',
       desc='Research, discovery, tradeoffs and shaping, ending in a written decision.')
p.node('decide', 'Build it?', 'gate', 2, 0, icon='Scale',
       desc='A person decides whether a shaped idea is worth building.')
p.node('making', 'Making', 'tool', 3, 0, icon='Hammer', child='making', sub='Open ↗',
       desc='A specification becomes verified work through governed execution.')
p.node('sharing', 'Sharing', 'tool', 4, 0, icon='Send', child='sharing', sub='Open ↗',
       desc='Verified work becomes an artifact a reader can use, shared with authorization.')
p.node('lessons', 'Decisions and lessons', 'state', 4, 1, icon='BookMarked',
       desc='What was decided, what was learned and what happened, recorded for reuse.')
p.node('knowledge', 'Knowledge and memory', 'state', 1, 2, icon='Library',
       desc='Where decisions, hypotheses and work records live between sessions.')
p.node('governance', 'Governance and orchestration', 'check', 2, 2, icon='Landmark',
       desc='Policy, readiness checks and authorization boundaries that apply to every stage.')
p.node('substrate', 'Execution substrate', 'tool', 3, 2, icon='Cpu',
       desc='Agent runtimes that do the work: Claude Code and Cursor under the supervisor, Codex by delegation. A limited ChatGPT pilot carries a few portable skills only; most of the method does not run there.')
p.edge('human', 'thinking', 'right', 'left', 'Intent', 'decision')
p.edge('thinking', 'decide', 'right', 'left', 'Shaped')
p.edge('decide', 'making', 'right', 'left', 'Yes', 'pass')
p.edge('decide', 'thinking', 'top', 'top', 'No, rethink', 'feedback', 'step', 56)
p.edge('making', 'sharing', 'right', 'left', 'Verified')
p.edge('sharing', 'lessons', 'bottom', 'top', 'Record')
p.edge('lessons', 'thinking', 'left', 'bottom', 'Informs the next question', 'feedback', 'step')
p.group('Cross-cutting: available to every stage', ['knowledge', 'governance', 'substrate'], 'zinc')
p.save()

# ---------------------------------------------------------------- 02 thinking
p = Plate('thinking', 'AOS-02', 'Thinking')
p.node('question', 'Question or intent', 'human', 0, 0, sub='From a person',
       desc='The starting point is a person\'s question, not an agent\'s guess.')
p.node('research', 'Research and discovery', 'tool', 1, 0, icon='Search',
       desc='Fan-out research over sources, reusing earlier decisions and lessons.')
p.node('evidence', 'Evidence and options', 'state', 2, 0, icon='FileStack',
       desc='Findings and candidate approaches, with their sources.')
p.node('challenge', 'Challenge the tradeoffs', 'tool', 3, 0, icon='Swords',
       desc='Opposing perspectives and structured interviews stress-test the options.')
p.node('decision', 'Decide', 'gate', 3, 1, icon='Scale', child='authorization', sub='Open ↗',
       desc='A person decides. Agents advise; they do not close the decision.')
p.node('spec', 'Written specification', 'state', 4, 1, icon='ScrollText',
       desc='The resolved decision, written down with acceptance criteria.')
p.node('parked', 'Parked or dropped', 'state', 3, 2, icon='Archive',
       desc='Not worth doing now. The reason is recorded so the question is not reopened blind.')
p.edge('question', 'research', 'right', 'left', 'Frame', 'decision')
p.edge('research', 'evidence', 'right', 'left', 'Findings')
p.edge('evidence', 'challenge', 'right', 'left', 'Options')
p.edge('challenge', 'decision', 'bottom', 'top', 'Tradeoffs')
p.edge('decision', 'spec', 'right', 'left', 'Commit', 'pass')
p.edge('decision', 'parked', 'bottom', 'top', 'Not now', 'normal')
p.edge('decision', 'research', 'left', 'bottom', 'Needs more evidence', 'feedback', 'step')
p.save()

# ---------------------------------------------------------------- 03 making
p = Plate('making', 'AOS-03', 'Making', y0=130)
p.node('spec', 'Written specification', 'state', 0, 0, icon='ScrollText',
       desc='The contract: what must be true when the work is done.')
p.node('tickets', 'Slice into tickets', 'tool', 1, 0, icon='ListTree',
       desc='A dependency graph of small slices, each with its own acceptance criteria.')
p.node('ready', 'Ready to run?', 'rule', 2, 0, icon='GitFork', child='governed', sub='Open ↗',
       desc='A deterministic readiness check decides whether a ticket may be admitted.')
p.node('dispatch', 'Dispatch executors', 'tool', 3, 0, icon='Workflow',
       desc='Blocking edges decide what can run in parallel: tickets with no unfinished blockers can run side by side.')
p.node('implement', 'Implement test-first', 'tool', 4, 0, icon='Code',
       desc='An executor builds each slice test-first, in an isolated working copy when run under the supervisor.')
p.node('review', 'Independent review', 'check', 4, 1, icon='ScanSearch',
       desc='A different reviewer checks the diff against the standards and the specification.')
p.node('verify', 'Meets contract?', 'rule', 3, 1, icon='GitFork',
       desc='A reviewer checks each requirement against the evidence, and a fixed check on the evidence package gates the move to review.')
p.node('human', 'Human closes the work', 'human', 1, 1, icon='UserRoundCheck',
       desc='Accepting the work, merging to the main line and publishing stay with a person.')
p.edge('spec', 'tickets', 'right', 'left', 'Decompose')
p.edge('tickets', 'ready', 'right', 'left', 'Propose')
p.edge('ready', 'dispatch', 'right', 'left', 'Admit', 'pass')
p.edge('ready', 'tickets', 'top', 'top', 'Not ready', 'feedback', 'step', 56)
p.edge('dispatch', 'implement', 'right', 'left', 'Assign')
p.edge('implement', 'review', 'bottom', 'top', 'Diff and tests', 'normalL')
p.edge('review', 'verify', 'left', 'right', 'Evidence')
p.edge('review', 'implement', 'right', 'right', 'Changes', 'feedbackL', 'step', 136)
p.edge('verify', 'human', 'left', 'right', 'Verified', 'pass')
p.edge('verify', 'dispatch', 'top', 'bottom', 'Not met: re-dispatch', 'feedback')
p.group('Governed execution', ['ready', 'dispatch', 'implement', 'review', 'verify'], 'emerald')
p.save()

# ---------------------------------------------------------------- 04 sharing
p = Plate('sharing', 'AOS-04', 'Sharing', y0=130)
p.node('work', 'Verified work', 'state', 0, 0, icon='BadgeCheck',
       desc='Work that has already passed verification, and its evidence.')
p.node('audience', 'Choose artifact and audience', 'tool', 1, 0, icon='Users',
       desc='A deck, a page, a plain document: whichever the reader will actually use.')
p.node('draft', 'Draft for the reader', 'tool', 2, 0, icon='PenLine',
       desc='Written in the reader\'s terms, in the author\'s voice, with figures where a picture helps.')
p.node('fresh', 'Fresh-reader review', 'check', 3, 0, icon='Eye',
       desc='An independent reader with no prior context looks for jargon, gaps and unsupported claims.')
p.node('ready', 'Reader-ready?', 'gate', 4, 0, icon='Scale',
       desc='A person decides whether the artifact is good enough to go out.')
p.node('authorize', 'Authorize sharing', 'human', 4, 1, icon='UserRoundCheck',
       desc='Sending, posting or publishing needs explicit approval for that specific item.')
p.node('share', 'Share or publish', 'tool', 3, 1, icon='Send',
       desc='Drafts are prepared for review; the release itself follows the approval.')
p.node('learn', 'Lessons captured', 'state', 2, 1, icon='BookMarked', child='learning', sub='How context carries forward ↗',
       desc='What worked, what the reader did with it and what to change next time.')
p.edge('work', 'audience', 'right', 'left', 'Select')
p.edge('audience', 'draft', 'right', 'left', 'Brief')
p.edge('draft', 'fresh', 'right', 'left', 'Draft')
p.edge('fresh', 'ready', 'right', 'left', 'Verdict')
p.edge('ready', 'draft', 'top', 'top', 'Revise', 'feedback', 'step', 56)
p.edge('ready', 'authorize', 'bottom', 'top', 'Ready', 'decision')
p.edge('authorize', 'share', 'left', 'right', 'Approved', 'pass')
p.edge('share', 'learn', 'left', 'right', 'Record')
p.save()

# ---------------------------------------------------------------- 05 governed execution
p = Plate('governed', 'AOS-05', 'Governed execution', y0=130)
p.node('contract', 'Shaped contract', 'state', 0, 0, icon='ScrollText',
       desc='A written contract with acceptance criteria, authored by one party.')
p.node('certify', 'Readiness check', 'check', 1, 0, icon='ClipboardCheck', sub='A separate certifier',
       desc='A different pass reads the contract fresh and certifies it. Shaping and certifying never share one pass.')
p.node('certified', 'Certified?', 'rule', 2, 0,
       desc='Yes only if the certification still matches the current text of the contract.')
p.node('admit', 'Admit', 'check', 3, 0, icon='DoorOpen', sub='Deterministic',
       desc='Fixed predicates, no model judgment: ready state, one executor, no hold, blockers done.')
p.node('dispatch', 'Dispatch', 'tool', 4, 0, icon='Workflow', sub='Bounded',
       desc='The supervisor starts one executor in an isolated working copy. It enforces transitions; it builds nothing.')
p.node('execute', 'Execute', 'tool', 4, 1, icon='Bot',
       desc='The executor implements the contract in the working copy.')
p.node('evidence', 'Evidence package', 'state', 3, 1, icon='FileCheck',
       desc='Diff, test output and a mapping from each criterion to its proof.')
p.node('review', 'Independent review', 'check', 2, 1, icon='ScanSearch',
       desc='A reviewer other than the executor.')
p.node('verify', 'Meets contract?', 'rule', 1, 1,
       desc='An independent reviewer checks each requirement of the admitted contract against the evidence; a fixed check on the evidence package then gates the move to review.')
p.node('human', 'Human closure', 'human', 0, 1, icon='UserRoundCheck', sub='Accept, merge, publish',
       desc='Marking work done, merging to the main line and publishing are reserved for a person.')
p.edge('contract', 'certify', 'right', 'left', 'Certify')
p.edge('certify', 'certified', 'right', 'left', 'Verdict')
p.edge('certified', 'admit', 'right', 'left', 'Promote', 'pass')
p.edge('certified', 'contract', 'top', 'top', 'Stale or incomplete', 'feedback', 'step', 56)
p.edge('admit', 'dispatch', 'right', 'left', 'Start run')
p.edge('dispatch', 'execute', 'bottom', 'top', 'Dispatch')
p.edge('execute', 'evidence', 'left', 'right', 'Hand over')
p.edge('evidence', 'review', 'left', 'right', 'Review')
p.edge('review', 'verify', 'left', 'right', 'Findings')
p.edge('verify', 'human', 'left', 'right', 'Verified', 'pass')
p.edge('verify', 'execute', 'bottom', 'bottom', 'Not met: revise', 'feedback', 'step', 60)
p.group('Planning and certification', ['contract', 'certify', 'certified'], 'blue')
p.group('Supervisor: enforces transitions', ['admit', 'dispatch'], 'zinc')
p.group('Executor and reviewers', ['execute', 'evidence', 'review', 'verify'], 'emerald')
p.save()

# ---------------------------------------------------------------- 06 human authorization
p = Plate('authorization', 'AOS-06', 'Human authorization')
p.node('propose', 'Agent proposes an action', 'tool', 0, 1, icon='Bot',
       desc='Reading, searching, editing a working copy and running local checks need no extra approval.')
p.node('local', 'Reversible?', 'rule', 1, 1,
       desc='Can the action be undone, and does it stay on this machine?')
p.node('proceed', 'Proceed within the task', 'tool', 1, 2, icon='Play',
       desc='Reversible local work goes ahead and is recorded.')
p.node('reserved', 'Reserved for a person', 'state', 2, 0, icon='Lock',
       desc='Push, merge to the main line, deploy, publish, send a message, spend money, use credentials, mark work done, change standing instructions.')
p.node('draft', 'Draft and hold', 'tool', 2, 1, icon='FilePen',
       desc='The agent prepares the item (a draft message, a pull request) and stops.')
p.node('decide', 'Human decision', 'human', 3, 1, icon='UserRoundCheck',
       desc='Approve this item, ask for changes, or stop.')
p.node('stop', 'Stop and record why', 'state', 3, 0, icon='OctagonX',
       desc='Nothing goes out. The reason is kept.')
p.node('act', 'Act once, as approved', 'tool', 4, 1, icon='Check',
       desc='The approval covers that specific item, not the next one.')
p.node('record', 'Record the outcome', 'state', 4, 2, icon='NotebookPen',
       desc='What ran and what was approved, written to the work ledger.')
p.edge('propose', 'local', 'right', 'left', 'Classify')
p.edge('local', 'proceed', 'bottom', 'top', 'Yes', 'pass')
p.edge('local', 'draft', 'right', 'left', 'No', 'decision')
p.edge('reserved', 'draft', 'bottom', 'top', 'Examples', 'normal')
p.edge('draft', 'decide', 'right', 'left', 'Present')
p.edge('decide', 'stop', 'top', 'bottom', 'Stop')
p.edge('decide', 'act', 'right', 'left', 'Approve', 'pass')
p.edge('decide', 'draft', 'bottom', 'bottom', 'Revise', 'feedback', 'step', 54)
p.edge('proceed', 'record', 'right', 'left', 'Record')
p.edge('act', 'record', 'bottom', 'top', 'Record')
p.save()

# ---------------------------------------------------------------- 07 durable learning
p = Plate('learning', 'AOS-07', 'Durable learning', y0=230)
p.node('work', 'Work happens', 'tool', 0, 1, icon='Hammer',
       desc='Anything that produces a decision, a pattern or a change in state.')
p.node('kind', 'What kind?', 'rule', 1, 1,
       desc='Each thing worth keeping belongs to exactly one kind of record.')
p.node('decisions', 'Decision log', 'state', 2, 0, icon='Scale',
       desc='A choice, why it was made and what was rejected. One project, append-only.')
p.node('hypotheses', 'Hypotheses', 'state', 2, 1, icon='FlaskConical',
       desc='A pattern that will recur elsewhere, with a count of confirmations and its evidence.')
p.node('ledger', 'Work ledger', 'state', 2, 2, icon='NotebookPen',
       desc='What landed and what changed, recorded at the moment it happens by a hook, not recalled later.')
p.node('rules', 'Rules', 'state', 3, 1, icon='ListChecks',
       desc='A hypothesis confirmed enough times becomes a rule that changes default behaviour.')
p.node('handoff', 'Reconcile and hand off', 'tool', 3, 2, icon='RefreshCw',
       desc='Close-out reads the ledger, distils lessons into hypotheses and rules, and leaves a handoff. A separate on-demand pass finds drift between notes, repository and board.')
p.node('next', 'Next work starts with context', 'tool', 4, 1, icon='Compass',
       desc='The next session begins from decisions, rules and the handoff rather than from memory.')
p.edge('work', 'kind', 'right', 'left', 'Capture')
p.edge('kind', 'decisions', 'top', 'left', 'A choice was made', 'normal', 'step')
p.edge('kind', 'hypotheses', 'right', 'left', 'Pattern')
p.edge('kind', 'ledger', 'bottom', 'left', 'Work landed', 'normal', 'step')
p.edge('hypotheses', 'rules', 'right', 'left', 'Confirmed', 'pass')
p.edge('rules', 'hypotheses', 'top', 'top', 'Demote if contradicted', 'feedback', 'step', 44)
p.edge('ledger', 'handoff', 'right', 'left', 'Read at close')
p.edge('decisions', 'next', 'right', 'topLeft', 'Prior choices', 'normal', 'step')
p.edge('rules', 'next', 'right', 'left', 'Sets defaults', 'pass')
p.edge('handoff', 'next', 'right', 'bottom', 'Handoff', 'normal', 'step')
p.edge('next', 'work', 'topRight', 'top', 'Next task', 'feedback', 'step', 200)
p.save()

# ---------------------------------------------------------------- views prose
views = dict(
    root='overview',
    views=[
        dict(id='overview', short='Overview', title='Expert judgment steers the work; agents carry it out.',
             claim='Thinking, Making and Sharing run in a loop, each ending at a point where a person decides. Knowledge, governance and execution sit underneath all three.',
             basis='Conceptual organisation of a personal working method. The three stages are the grouping used in the system\'s own documentation; the boxes underneath are surfaces, not a deployment diagram.',
             not_claimed='Not a company product, not an enterprise deployment, and not a runtime call graph.'),
        dict(id='thinking', short='Thinking', title='Intent becomes a decision before anything is built.',
             claim='Research and tradeoff work are delegated to agents; the decision itself is not.',
             basis='Describes how discovery and shaping are done in practice. Which research and interview methods run depends on the question.',
             not_claimed='Does not claim every question follows every step, or that agents ever close a decision.'),
        dict(id='making', short='Making', title='A decision becomes verified work through a governed path.',
             claim='A written specification is sliced, admitted by fixed rules, built by executors and checked by someone other than the builder.',
             basis='Matches the current build-and-verify workflow as documented in the working repository. Which tasks run in parallel follows their dependencies. Execution details are in the governed execution view.',
             not_claimed='Does not claim parallel execution for every task, or that review always passes the first time.'),
        dict(id='sharing', short='Sharing', title='Work only counts once someone else can use it.',
             claim='The artifact is chosen for its reader, tested on a reader with no context, and released only with explicit approval.',
             basis='Describes the working practice for writing and publishing. The reader review is a separate pass by design, run on request or before publishing.',
             not_claimed='Does not claim every artifact gets every review, or that sending can ever happen without approval.'),
        dict(id='governed', short='Governed execution', title='Autonomous work is admitted by rules, not by confidence.',
             claim='Shaping, certifying, admitting, building, reviewing and closing are separate roles with separate gates, and only a person closes work.',
             basis='Follows the current lifecycle and supervisor design; older orchestration designs that were retired are not shown. State names are generalised. Promotion to ready is a gated step an agent or a person can take; the supervisor then admits, never closes.',
             not_claimed='Not an audited runtime. The diagram shows the intended transitions and who may perform them. Not claimed: that the supervisor is the only route to review, or that it re-runs the tests itself.'),
        dict(id='authorization', short='Human authorization', title='Autonomy ends where an action is outward-facing or hard to undo.',
             claim='Reversible local work goes ahead. Anything outward-facing or hard to undo is drafted, held and approved one item at a time.',
             basis='Reflects the standing authorization policy for agent work. The list of reserved actions is representative, not exhaustive.',
             not_claimed='Does not claim every decision is automated, or that a hook catches every violation.'),
        dict(id='learning', short='Durable learning', title='Context carries forward as records, not memory.',
             claim='Decisions, hypotheses and work records are kept separately, so a stranger could resume the work and a lesson earns its way into a rule.',
             basis='Describes the record types and their intended flow. Thresholds and automatic effects are summarised, not specified. Commits and decisions are captured by hooks; counting a hypothesis and promoting it happens at close-out, by an agent.',
             not_claimed='Does not claim the capture hooks fire in every repository.'),
    ])
for v in views['views']:
    v['order'] = ORDER[v['id']]
(OUT / 'views.json').write_text(json.dumps(views, indent=2) + '\n')
print('wrote', len(list((OUT / 'plates').glob('*.arc.json'))), 'plates')
