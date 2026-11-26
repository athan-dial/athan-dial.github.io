---
arwc_version: "0.4"
arwc_kind: spec
status: proposed
---

# Problem Statement

The existing personal operating-system page contains a substantial seven-view architecture atlas, but its front door is a conceptual description. A cold reader evaluating technical product leadership needs to see what changes in actual work when intent is explicit, agents have bounded autonomy, verification is independent, and evidence carries forward. The page succeeds when the reader can experience an illustrative task in about three minutes, then inspect the actual operating principles and their limitations without needing access to internal systems.

# Solution

Augment the existing draft with a visually rich editorial introduction tied to the Outer Loop essay, a deterministic work-lifecycle simulator with meaningful failure and authorization cases, an inspectable contract/evidence chain, a layered introduction to the existing atlas, and a durable-learning and R&D discussion exhibit. Preserve the seven-view atlas and its data-driven text equivalent as the deeper architecture surface. The page demonstrates a personal method and potential transfer of its principles; it does not operate a real agent or claim enterprise validation.

# Requirements

### R1: Orient a cold reader with the outer loop
As a technical R&D leader, I want to understand the problem this personal operating method addresses, so I can see why disciplined delegation matters before inspecting implementation details.

**Acceptance**
- The opening identifies a concrete problem: faster implementation can amplify unclear intent, unverified completion and lost context. Explain how human direction and product judgment surround a plan/build/verify/revise loop and how evidence informs the next decision.
- Provide a concise visual problem statement, human contribution and a roughly three-minute path through the simulator, control boundaries and architecture, with anchors for deeper exploration. Link to the existing Outer Loop essay where available. Do not imply that every piece of work follows one fixed sequence.
- Retain the existing personal-method framing and accurately distinguish the author as operator/designer of the method from team or enterprise delivery. Clearly label the example and conceptual architecture; no claim of enterprise deployment, measured productivity or regulated-system validation.
- Opening explanation and representative example remain understandable with JavaScript disabled or reduced motion. Prefer a brief purposeful visual progression to decorative animation.

### R2: Operate a complete illustrative work lifecycle
As a visitor, I want to advance a realistic task through a governed operating method, so I can understand what agents do and what human decisions remain.

**Acceptance**
- Use one fictional scientific-software task: add an evidence inspector that resolves cited support and represents missing evidence without presenting unsupported findings as verified. The task has a small explicit Spec Contract, stable requirement/constraint IDs, a dependency graph of executable Ticket Contracts and coherent sample artifacts.
- From a reproducible initial state, the reader can step through human intent, shaping, specification review, decomposition, ticket readiness/certification, authorized activation, dependency-aware dispatch, isolated implementation, independent review, verification and human handoff. Show the distinction between a spec being ready to decompose and a ticket being eligible to execute.
- The graph includes a first working slice, at least two independent follow-on slices and an integration slice blocked by their completion. The available frontier and task labels are derived from the same scenario state and declared dependency policy; distinguish work verified for handoff from human-closed work where closure gates dependencies. Parallel work is possible only when prerequisites and authority permit.
- Expose current task, actor, relevant artifact and reason for each transition. Use advance, replay/reset and optionally step-back controls, with a stable static example; no invented live progress or real agent calls.
- Final successful simulated execution reaches a verified review handoff, not automatic Done, merge, deployment or publish. An explicit simulated human decision may demonstrate a later transition. All states and artifacts are labeled fictional/local simulation.

### R3: Demonstrate failure, readiness and revision gates
As a reader evaluating agent autonomy, I want to introduce consequential failures and see which transitions are refused, so I can inspect the safety mechanism rather than assume the orchestrator works.

**Acceptance**
- Include four selectable scenarios sharing the same fixture and transition model: valid implementation; executor reports success without sufficient evidence (including a plausible passing-test-but-missing-evidence failure); changed parent specification; attempted unauthorized publication. The last scenario may reuse the authorization controls from R6.
- An executor's evidence is an assertion for review. Failed, absent or insufficient independent evidence prevents verified handoff and any dependent eligibility that requires verified/closed prerequisites; the explanation identifies the unmet R/C and next repair or escalation. Show a repair/reverification route, without silently weakening acceptance.
- A parent normative revision invalidates stale parent digest bindings and affected approval/certification. New dispatch is held and an affected in-flight result cannot pass handoff against stale intent. Show the rebind/re-review/re-certify path; do not imply destructive cancellation or universal automatic runtime enforcement.
- A blocked dependency, missing certification or mismatched revision prevents dispatch. Display the concrete reason, not merely a disabled button. Recovery requires the corresponding simulated evidence or approval; reset and scenario switch clear stale state.
- Derive all transitions, labels, readiness reasons and requirement results from one deterministic local model; do not hardcode inconsistent visual states. No invalid completion, release, dispatch or dependent advancement through repeated or out-of-order control use.

### R4: Inspect the contract and evidence chain
As a technical reader, I want to inspect the records exchanged across stages, so I can understand the interface between product intent and autonomous execution.

**Acceptance**
- Provide inspectable example artifacts for the spec, ticket graph and at least one ticket, readiness certificate, execution brief, executor evidence package, independent review/verification and human decision/hand-off. Artifacts have a clear purpose, authoring/consuming role, revision identity and relationship to the next gate.
- At least one trace connects a parent R/C to child acceptance, test/evidence, independent result and integrated disposition. Distinguish the authoritative WHAT from implementation choices, and the executor's evidence claim from an independent assessment. Use actual public-safe contract format conventions or explicitly illustrative excerpts; never imply fixture certificates, hashes or test outcomes are live records.
- Readiness artifacts and displayed proof use the same active scenario IDs and revision binding as the simulator. Missing evidence remains missing; changing the scenario or parent revision updates or marks artifacts stale rather than silently preserving approval.
- Artifacts open and return via accessible controls; a static representation of the representative trace is available. The page may reference public-approved examples from the portfolio; no confidential work records, private repo links or unapproved artifacts.

### R5: Preserve and introduce the seven-view architecture atlas
As a technical reader, I want to move from an understandable layered model into the existing atlas, so I can inspect the full operating method without confusing conceptual views with a deployed topology.

**Acceptance**
- Introduce a compact architecture with human direction, control plane, execution plane and durable state. Explain authority and interfaces: shaping/certification versus deterministic admission/dispatch, execution versus independent review/verification, and records that retain intent, code, evidence and knowledge. Treat these as conceptual roles/surfaces, not a runtime call graph.
- Preserve the existing seven atlas views: overview, thinking, making, sharing, governed execution, human authorization and durable learning. Keep the Arc-based engine, editable plates and text-equivalent data path functional; reuse the improved portfolio work-story patterns where appropriate without replacing or flattening the atlas.
- Provide useful anchors or drill-down links from the new narrative and layered view into the relevant atlas views. Retain each view's claim, basis and not-claimed limitations, plus navigation back to overview and the main story. If a historical detail conflicts with current verified documentation, correct it transparently without silently widening a capability claim.
- Maintain the same relationships and semantic roles in the interactive and text versions. Check keyboard access, diagram geometry, local scrolling or reflow, no-script access and normal/narrow viewports. Do not load draft-only assets into an ordinary published build or regress other work pages.

### R6: Expose authorization boundaries and role separation
As a person delegating work, I want to see which reversible actions may proceed under scope and which reserved actions wait for a specific decision, so I can calibrate authority.

**Acceptance**
- Show reversible local read/search/edit/check operations as eligible only within an admitted scope. Show reserved actions such as closing work, pushing/releasing or merging, deployment, outbound communication, credential use and spend as requiring the applicable explicit authority. Use representative examples, not a claim that every hook catches every violation.
- Differentiate review approval, readiness certification, activation and authorization to execute/release. A spec review does not automatically certify tickets, an agent readiness decision does not authorize release, a verified handoff does not close work, and an approval bound to one revision/action does not authorize a changed item.
- In the unauthorized-publication scenario the visitor can inspect the draft action and choose hold/deny or explicitly simulate approval for that exact item and revision. Hold/deny makes no external change; changing the item invalidates the illustrative approval. Any later release state is visibly simulated, never an external action.
- Explain the responsibility boundary among human owner, shaper, independent certifier, supervisor, executor, reviewer and verifier, without claiming a separate person for every role or that policy is universally technically enforced. Cross-check against the atlas and current documented policy.

### R7: Demonstrate durable learning and resumable work
As a reader concerned with knowledge continuity, I want to inspect how one run leaves usable records for the next, so I can distinguish learning from accumulating chat history.

**Acceptance**
- Show three separate durable record types: project decision (choice, rationale, rejected alternatives and reconsideration condition), reusable hypothesis (claim, evidence and possible counterevidence) and ledger entry (observed work or state change). Use fictional examples grounded in the scenario.
- Show an illustrative close-out record that links the task, evidence, unresolved state and next action; a simulated fresh session can resume the work from the records without relying on the original conversation. Do not imply all capture is automatic or hooks fire in every environment.
- Explain how a recurring supported hypothesis may be promoted into a working rule and later demoted when contradicted. Distinguish documented policy from illustrative mechanism; do not present unverified numeric thresholds or count repeated copies of one observation as independent evidence.
- Show how evidence feeds the outer loop to revisit a problem or product assumption rather than merely accelerating execution. Preserve uncertainty and unresolved decisions; the simulated learning record does not change actual agent behavior or any external state.

### R8: Deliver an evidence-backed capstone and R&D discussion surface
As an independent reader, I want a coherent, accessible work-product exhibit that connects the method to scientific technology leadership, so I can evaluate the approach and its limits.

**Acceptance**
- Curate a short set of evidence-backed design decisions: durable intent versus disposable execution plans, dependency/authority gating, independent verification and evidence-linked learning. For each, identify the practical problem, chosen boundary, tradeoff, maturity and author contribution. Distinguish documented design, observed use, prototype and measured effect; do not invent implementation history or results.
- Connect the principles to potential pharmaceutical R&D applications such as reproducible computational research, dependent analytical work, scientific quality checks, human decision authority and durable evidence. Explicitly distinguish transfer hypotheses from actual enterprise deployment, scientific validation or GxP compliance; regulated use would require separate controls, validation and organizational authorization.
- Use the Personal Fieldnotes light editorial design and semantic diagram vocabulary, giving the interactive example and atlas substantial visual space. Preserve the existing case-study route and other pages. Provide meaningful heading/anchor structure, keyboard controls, visible focus, accessible labels/state, contrast, touch targets, 200% text zoom, reduced motion, no-script equivalents and no unintended page overflow.
- Verify the existing atlas build/validation path and site build/render/safety/publication checks; exercise the simulator in a browser at desktop and narrow widths. Deliver screenshots and a requirement-to-evidence matrix for review, with unavailable checks or missing source evidence named. Keep the page draft/private, excluded from ordinary production output and indexes.

# Constraints

### C1: Disclosure and evidence safety
Every tracked file in the public repository is public-visible even on a draft branch. Follow the site's content-safety contract and private evidence/voice rules. Do not add internal project names, colleague or expert identities, private URLs, tracker IDs, private repository content, paths tied to credentials, internal scientific data, unapproved metrics or employer artifacts. Use fictional examples, approved abstractions and sanitized assets; keep evidence, mappings and review feedback in authorized private/untracked storage. Existing names do not confer new disclosure authority.

### C2: Personal method and attribution accuracy
Ground historical, technical and ownership claims in current authorized sources, classifying documented design, implemented mechanism, observed use and measured result separately. Preserve the existing page's limitations; do not claim company deployment, audited controls, scientific validity, regulatory compliance or quantified business outcomes. If required evidence/voice materials are unavailable, block affected historical claims and continue explicitly illustrative work only.

### C3: Simulation and transition integrity
All demo actions are deterministic, local and clearly simulated. One state model drives eligibility, dependencies, revision identity, evidence, approval, artifact links and displayed outcomes. Fail closed for missing/stale authority or evidence, with explicit reasons. Executor output cannot authorize verification or closure. No live runner, tracker writes, model calls, external transfer or actual release. Do not depict intended policy as guaranteed universal runtime enforcement.

### C4: Existing atlas and site integrity
Preserve the existing Arc engine and seven-view data-driven atlas with text parity, current site routes and publication exclusions. Use Personal Fieldnotes design and existing work-story primitives as suitable. Keep added behavior page-scoped, accessible and small; no speculative shared framework, replacement diagram engine, backend or additional runtime dependency. Do not commit generated site output or weaken checks.

### C5: Review, branch and release authority
This is a proposed spec and proposed repository-local ticket package, not approval to execute or deploy. Bind tickets to the approved parent revision; collect graph approval and independent Steward certification before dispatch. Work on a review integration branch incorporating the existing atlas revision and reconciling relevant sibling portfolio changes. Do not silently overwrite branch work, merge to the deployment branch, open a PR, disclose private material or publish without separate authorization.

# Implementation Decisions

## Locked
- Repo: athan-dial/athan-dial.github.io
- Base branch: integration/historical-reconciliation
- Starting implementation revision: f81c500408ad4a7e26d5827ae093bbfacd31ed22. Preserve the existing agentic-operating-system route, Arc atlas, its seven view definitions and text equivalents. Reconcile the newer shared work-story design and sibling portfolio changes before integration; do not start from main alone or replace the atlas.
- Use the existing title, The Agentic Operating System, and the personal author/operator framing. The visitor's main path is problem, human intent and outer loop, working simulator, artifact and authorization inspection, architecture atlas, durable learning, R&D relevance and reflection.
- Use the existing documented role and lifecycle semantics; a deterministic fictional scenario models a subset of them without claiming real runtime enforcement. One state model supplies task eligibility, artifact revision and evidence/approval dispositions.
- Deliver a draft review experience only, with separate human authorization for any real publication.

## Executor discretion
Choose the fixture's exact IDs, labels, local state representation, event controls, artifact details, layout, animation and tests. Prefer the smallest deterministic transition seam and existing browser and atlas validation. Reuse suitable site components without introducing an orchestration framework or rewriting the diagram engine.

## Escalate before deciding
Escalate a material change to human authorization, dependency or verification semantics; unresolved branch conflicts, new publication or disclosure requests, unsupported historical ownership or enterprise claims, and missing required evidence for historical narrative. Do not invent authority or weaken checks.

# Testing Decisions

- **R1:** seam: opening and narrative navigation; evidence: a cold-reader walkthrough of the short path, role and limitation audit, static and reduced-motion inspection.
- **R2:** seam: deterministic transition model and rendered simulator; evidence: traverse the complete valid fixture from intent to review handoff, check frontier/dependency reasons and actor/artifact references at each step, replay and reset; no automatic closure.
- **R3:** seam: transition predicates and fixture state; evidence: test missing/failed evidence, stale parent, uncertified ticket, incomplete blocker, unauthorized publication, repair/rebinding, scenario switch and repeated/out-of-order inputs; reject any ineligible transition or stale display.
- **R4:** seam: artifact resolver and R/C trace; evidence: inspect every artifact type, verify IDs/revision/disposition against current scenario, trace one requirement end to end, test missing/stale evidence and accessible returns.
- **R5:** seam: atlas view data, Arc mount and text fallback; evidence: validate seven views, all drill-down/return links, node/edge geometry and text parity, inspect desktop/narrow and no-script behavior; run existing atlas validator and check draft asset exclusion.
- **R6:** seam: authorization decisions and transition predicate; evidence: exercise local eligibility, hold, deny, exact-item simulated approval and invalidated approval after revision; verify no conflation of readiness, handoff, closure and release.
- **R7:** seam: record and resume exhibit; evidence: inspect all three record types, trace unresolved state and next action into a fresh simulated session, examine hypothesis promotion and counterevidence example; confirm no real record writes.
- **R8:** seam: assembled draft, source audit and production build; evidence: fresh desktop/narrow render, keyboard/contrast/focus/zoom/reduced-motion/no-script checks, R&D caveats and evidence-to-decision review, canonical atlas/site checks, production exclusion and R/C matrix.
- **C1:** seam: changed files, fixtures, metadata and screenshots; evidence: manual sensitive-detail/source review plus site safety checks; no private evidence or new disclosure in tracked paths.
- **C2:** seam: historical narrative, atlas claims and private evidence ledger; evidence: check author/maturity/limits against authorized records, omit unsupported claims or mark blocked.
- **C3:** seam: shared scenario model and rendered trace; evidence: deterministic replay, invalid transition tests, dependency/revision/evidence/approval consistency, explicit simulation and no external requests.
- **C4:** seam: repo diff, atlas data/render and Hugo output; evidence: retained view/relationship parity and route behavior, no additional framework/generated output, applicable existing tests and draft-resource exclusion.
- **C5:** seam: parent/graph review state and Git history; evidence: matching approved digest and certification before dispatch, preserved base and sibling work, private review status and no unauthorized publish/merge/PR.

The highest-risk behavior is the simulator's transition predicate: passing executor tests alone must not promote a ticket, a stale binding must not dispatch or pass handoff, and a verified result must not authorize release. A test suite must distinguish correct behavior from visually plausible hardcoded progress. Use canonical repository and existing atlas validation/build paths, fresh Hugo render and applicable safety/publication checks; keep direct evidence for each requirement.

# Out of Scope

Live agents, supervisor or tracker integrations, actual code execution, credential use, external communication, real publication, commercial agent platform, replacing the atlas engine, real enterprise or regulated deployment, scientific quality validation, private work records, unrelated page redesign and a generalized orchestration framework.

# Starting State

The specified base revision contains the draft personal operating-system page, the atlas layout and seven Arc plates with view metadata, a page-scoped atlas bundle, editable atlas source/validation tooling and an equivalent text rendering. The existing page links to the Outer Loop essay and states the personal-method limitation. Sibling work-product branches contain newer editorial layouts and synthetic demos; inspect and reconcile their actual integration state instead of assuming they are already available. Current operating-method documentation is authoritative for descriptive semantics; private evidence pointers and voice material must stay outside tracked public artifacts.

# Further Notes

The author has delegated planning and decomposition for the portfolio sequence, with a separate implementation agent to build approved specs. Review this proposal and the ticket graph before execution. The intended review audience includes technical R&D digital product leadership, while the page should stand alone for a wider technical reader.
