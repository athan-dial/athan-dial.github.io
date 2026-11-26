---
arwc_version: "0.4"
arwc_kind: spec
status: proposed
---

# Problem Statement

A technical reader assessing a portfolio needs to see how product judgment translates into a governed AI experience for consequential expert work. The existing advisor case study describes a conversation and verified critique workflow, but a static journey figure and decision cards do not let the reader experience the evidence boundary, inspect the architecture, or understand how expertise would be evaluated. A good demonstration makes the user's preparation problem, the author's product choices, the evidence mechanism and its limits concrete within three minutes and supports deeper inspection.

# Solution

Augment the existing unpublished advisor case study with a visually rich, interactive editorial work-product experience. Open with a specific preparation problem and a fictional research-deck critique, then disclose the governed knowledge architecture, the two runtime trust postures, claim inspection, the distinct fidelity evaluation design and the evidence-driven roadmap. Preserve truthful author/team attribution and calibrated reflections. Use the existing portfolio visual system and the stronger work-story pattern, with synthetic material and sanitized work products only.

This is a proposal for a portfolio review draft, not an implementation of the internal product or a scientific/model validation study.

# Requirements

### R1: A short product narrative with visible contribution
As a technical R&D or AI product leader, I want to understand the user's job and the author's contribution quickly, so I can choose which decisions and mechanisms to inspect.

**Acceptance**
- GIVEN a cold reader, WHEN the existing advisor case study is opened, THEN the opening explains a concrete expert-conversation preparation problem, why useful advice and supported artifacts require different handling, and the author's contribution in plain language.
- A roughly three-minute walkthrough moves from the problem to an interactive example, the trust boundary and architecture, with optional depth through anchored sections. An independent reader can follow the narrative without narration or jargon.
- Preserve the substance of the existing case study where verified. Distinguish product definition, trust contract, success criteria and prioritization led by the author from engineering, scientific and executive contributions. Add no personal implementation credit without evidence.
- Static reading order and an accessible example remain complete with scripts and animation disabled. The page reads as an editorial work product rather than a generic assistant demo or hiring pitch.

### R2: An interactive synthetic advisor workspace
As a reader preparing for an expert discussion, I want to inspect a small example deck and interact with a fictional advisor lens, so I can experience the difference between strategic exploration and a governed critique.

**Acceptance**
- GIVEN a self-contained fictional deck with at least two slides and an illustrative source corpus, WHEN the reader opens the demo, THEN they can inspect slide content, choose at least two distinct discipline-based lenses, see the lens's decision criteria and scope, and explore an example discussion.
- WHEN the reader chooses an exploratory question and requests a critique of the same deck, THEN the workspace retains the selected material and lens, visibly identifies the mode, and presents the corresponding example conversation or critique. Changing lenses changes the questions or prioritization where the fixture establishes a real difference.
- The critique action visibly traverses a deterministic illustrative draft/check/revise/readout progression. No fabricated percentages, purported live model calls or pre-verification claims presented as final findings. The visitor can skip or replay the progression and reset to the original state.
- The final readout includes supported observations, explicitly scoped evidence gaps, and access to the claim evidence inspector. Unknown or contradicted assertions must never be presented as admitted factual claims.
- Empty/unavailable material, missing evidence and reset/switch actions have intelligible states. A changed deck or lens cannot silently reuse an old readout under the new identity. No upload, account or network is required.
- All example deck values, source passages, lens behavior, reviewer responses and outputs are labeled fictional and simulated, with no impersonation, real expert data, inferred scientific outcome or implied live inference.

### R3: Claim-level evidence and verification inspection
As a reader checking the critique, I want to trace a finding to its exact premises and verdict, so I can distinguish evidence support from a plausible narrative.

**Acceptance**
- GIVEN the simulated candidate points, WHEN the reader opens an admitted point, THEN the inspector shows its exact claim, relevant slide excerpt or observation, relevant advisor criterion/evidence when applicable, the restricted verification premise and a plain-language reason for its verdict.
- The fixture contains supported, unknown and contradicted candidate claims, a case where one revision is attempted for an unknown candidate, and at least one unresolved gap. A supported final claim is tied to the cited premises. An unknown candidate after its bounded revision appears only as a gap with the missing evidence; a contradicted candidate is excluded from the final readout.
- A separate, explicitly diagnostic view may reveal candidate claims and their rejection/revision history; it is visually and semantically distinct from the deliverable. A rejected candidate must not be rendered as a finding or included in a previewed export.
- The readout, inspector, slide citations, summary counts and export preview derive from the same deterministic claim records and terminal dispositions. No dangling references, invented snippets, mismatched lens/deck provenance, or claims without a support check. Missing references and unavailable verification fail closed for affected points.
- Explain that a separate model check in the historical design tests support against restricted evidence; it is not an independent human review or a proof of scientific truth. The portfolio demonstration replays declared fixture verdicts and does not perform semantic inference.
- Provide keyboard-accessible inspection and a return path to the relevant finding and slide. The static example includes the essential evidence and gap.

### R4: Inspectable architecture of governed expert assistance
As a technical reader, I want to understand how source-grounded knowledge, conversation and artifact verification fit together, so I can evaluate the product and its engineering boundaries.

**Acceptance**
- The architecture separates source acquisition and curated advisor knowledge from runtime workspace and artifact delivery. Show a public-safe representation of source corpus, atomic claims/evidence, review criteria and role/scope, curator review/promotion, and the two runtime paths.
- Show exploratory conversation and material-grounded critique as distinct behaviors within one workspace. The critique route shows candidate drafting, separate claim-level check against restricted cited premises, bounded unknown revision, supported/contradicted/unknown dispositions, synthesis of admitted points and explicit gaps.
- Diagram relationships distinguish data, action, decision, feedback, and maturity. The unknown revision loop returns to verification; contradicted points do not reach the delivered findings. Do not invent a guaranteed source refresh, automatic promotion, or external connector.
- A selected region opens or links to a useful explanation of its input, output, responsibility, design rationale and limitation. Show how a reader gets from a finding to slide and source evidence.
- Clearly distinguish documented built behavior, proposed evaluation/promotion criteria and future handoff directions. Confirm the historical state from authorized sources; label conceptual abstractions rather than implying exact deployed topology.
- The figure is legible, responsive, native to the site's diagram conventions, with a text equivalent and accessible links. Preserve the surrounding site and existing case-study designs.

### R5: Two trust postures and a bounded handoff
As a user, I want to understand what can be reasoned about in conversation, what can be asserted in a governed artifact, and what happens outside the product, so that I can calibrate reliance.

**Acceptance**
- GIVEN the same synthetic material and question, WHEN switching between exploration and critique, THEN the visitor sees how the evidence posture changes: a useful visibly hedged hypothesis may appear in exploration, while the governed artifact contains only checked supported assertions and explicit gaps.
- The demo demonstrates at least one plausible hypothesis that is not admitted as a verified finding. It distinguishes a supported descriptive observation from claims requiring missing statistical, causal or other evidence. Labels must be meaningful without color alone.
- The artifact boundary is explicit: draft candidates do not stream into the final readout; a separate check precedes admission, revision is bounded, and uncertainty is not converted into a claim.
- Show an illustrative standalone readout or annotated-slide preview with preserved source references and gaps. Show a bounded copy-first handoff preview with the same permitted context, clearly labeled as a proposed direction where not built; a continuation in a general assistant is outside the verification contract. No real external transfer.
- Explain the practical tradeoff: friction in a preview/copy handoff versus investment in a connector, and identify what observed user behavior would justify revisiting it. Do not assert that a connector or handoff has shipped unless verified.

### R6: Separate fidelity evaluation from evidence grounding
As an AI product leader, I want to inspect an evaluation design that distinguishes factual support from expert-specific review behavior, so I can judge whether the proposed advisor capability deserves trust.

**Acceptance**
- A clear two-dimensional visual explains evidence support and fidelity to a review standard as distinct properties; plausible examples demonstrate high/low combinations. The examples are fictional, not measured performance.
- Present the proposed positive-control experiment: same historical material and recorded expert review as reference, governed advisor as candidate, and generic assistant as comparison; specify matching inputs, independent scoring, held-out or frozen reference cases, and the risk of leakage or judging style instead of judgment. Distinguish a comparison design from a completed study.
- The reader can inspect a synthetic side-by-side example of generic and discipline-specific critique against an explicitly fictional review rubric. Demonstrate review priorities, source support, domain-specific review moves, actionability and overreach; an unsupported but persuasive claim cannot score as grounded.
- Explain what could justify promotion or further investment, including a known-bad behavior that should fail and the limits of model-based scoring. Do not claim a measured fidelity threshold, result, equivalence to an actual expert, or an implemented promotion gate without approved evidence.
- The static version conveys the evaluation design and the separation of dimensions. No real expert identity, transcript, imitation or private deck is used.

### R7: Evidence-driven product decisions and evolution
As a product leader, I want to inspect how actual user observations changed the roadmap, so I can understand the author's product discovery and prioritization decisions.

**Acceptance**
- The narrative maps evidence-backed observations from an unaided user walkthrough to the problem they revealed, the resulting product bet, its intended user outcome and the tradeoff or unresolved question. Do not treat a reported observation as general adoption evidence.
- Preserve the decisions around exploratory versus governed trust, measuring fidelity before expanding, sequenced outcome bets and bounded handoff. Differentiate user research observation, author recommendation, agreed decision, documented design, built behavior and open exploration.
- Show a compact now/next/later or equivalent evidence-to-priority visual with a useful detail for each major bet. Distinguish outcomes from implementation options, and explain why a broader integration was not the default bet. Do not fabricate issue counts, impact metrics, roadmap dates or delivery status.
- Ground historical claims and individual/team attribution in the required private evidence and voice corpus. State limitations, including whether evaluation, adoption or behavioral impact is unmeasured where supported; omit claims when permission or evidence is missing.

### R8: Inspectable exhibits and a polished accessible review draft
As an independent reviewer, I want to inspect actual decision work and use the page on desktop or mobile, so I can assess the author's reasoning without needing internal systems.

**Acceptance**
- Curate a small exhibit set covering the trust contract/product definition, knowledge and critique architecture, evaluation design, and research-to-roadmap decisions. Each exhibit has its purpose, decision, maturity, evidence boundary and evidenced author role; local details open and return without links into private systems. Use public-safe reconstructions instead of generic placeholders or real internal materials.
- Close with a concise evidence-grounded reflection on what worked, what remains uncertain, and how to evaluate whether critique changes behavior. No fabricated metrics or claims of benefit.
- Use the current portfolio's Personal Fieldnotes editorial system, including typography, semantic forest/citrus colors, spacing, native diagrams and the improved work-story patterns. Give the workspace and evidence inspector prominent space; use varied compositions, meaningful visuals and restrained finite or controllable motion.
- Desktop and narrow render show no clipped controls, overlap, broken links or unintended page overflow; complex diagrams reflow or offer deliberate local scrolling. Keyboard, focus, labels, state announcements, contrast, touch targets, 200% text zoom, reduced motion and no-script equivalents meet repository policy.
- All interactive fixture state is local, with no backend, paid dependency, telemetry, third-party embed or actual export of private content. Existing site builds and regression checks pass. The case study remains draft/private and excluded from production output and public indexes until separate approval.
- Provide the assembled local review page, screenshot and behavior evidence, and a requirement-to-evidence matrix; explicitly name unavailable checks and evidence blockers.

# Constraints

### C1: Public-repository and disclosure safety
Every tracked file, including this contract, planning files, screenshots, fixture, assets, metadata and client bundles, is public-visible regardless of branch or frontmatter. Follow the child repository's content-safety and employer-review rules. Use approved functional descriptions and invented examples. Do not add internal codenames, real expert or colleague identities, internal links, unpublished project facts, private decks, transcripts, source corpus, vendor relationships, internal metrics, schemas, hostnames or credentials. Keep private evidence and mapping in authorized untracked locations. Existing review-copy names are not blanket disclosure permission; resolve naming with the author before public release. Do not weaken scanners or copy private evidence into Git.

### C2: Evidence and attribution before historical claims
Use the required authorized private work-archaeology and voice materials before editing factual historical narrative. Maintain a private claim-to-source and disclosure/maturity/ownership ledger. Separate built, tested, planned, recommended and measured; target is not result. Do not claim individual credit for others' implementation or scientific judgment. If mandatory evidence is unavailable, continue only with explicitly illustrative design/demo work and block the affected historical claims; do not invent or silently upgrade them.

### C3: Honest simulation and trust semantics
The public demo is deterministic, synthetic and offline. It never claims to run an AI model, reproduce an actual expert, verify scientific truth or certify production fidelity. All visible outputs share declared fixtures, premise links and verdicts. Final findings are supported only; contradicted findings are withheld; unresolved unknowns are explicit gaps. Missing or failed verification cannot become an admitted finding. Diagnostic draft views are clearly separate. Any export/handoff preview preserves the boundary and makes no external request.

### C4: Site and accessibility boundaries
Follow the existing Hugo and Personal Fieldnotes implementation, site tokens and diagram vocabulary. Reuse the improved work-story primitives when appropriate, avoid speculative general frameworks and unnecessary dependencies, preserve other work pages and routes, and do not commit generated publish output. No motion may gate access; provide static equivalents and keyboard-accessible controls. Do not silently revert work from sibling branches.

### C5: Review and execution authority
This proposed spec and its ticket drafts are for review and decomposition, not authorization to execute, deploy, disclose, merge to the deployment branch or open a PR. Bind the approved parent digest, obtain required graph approval and independent Steward certification before dispatch. Implement and review a private draft; require explicit publication and disclosure authorization separately. Keep review feedback and private evidence out of the public repository.

# Implementation Decisions

## Locked
- Repo: athan-dial/athan-dial.github.io
- Base branch: spike/talos-work-product
- Starting implementation revision: ed73bb8fe8cf6b25ef0b31ad057257a1182516df. Preserve the existing advisor work-product page and the improved shared work-story experience on this branch. Reconcile any subsequent sibling-branch integration before implementing; do not start from main alone or revert newer case-study work.
- Working public-safe title: **Governed AI for Expert Work**. Augment the existing advisor case study rather than create a duplicate route. Review the existing draft naming boundary; no expansion of internal identifiers.
- One coherent local fictional scenario and claim record model drive the workspace, evidence inspector and artifact preview. A verdict describes support relative to the declared premise, not objective truth. The evaluation exhibit is separate from runtime claim checking.
- The initial short path leads with the concrete problem, product interaction, contribution and trust boundary; deeper sections provide architecture, fidelity evaluation, research-driven roadmap, work products and reflection.
- Deliver an unpublished local review draft.

## Executor discretion
Choose the fictional deck, lens names and review criteria, exact interaction and fixture representation, visual hierarchy and responsive details, native diagram authoring mechanism, and local component boundaries. Reuse current work-story patterns where their behavior fits. Prefer existing build and browser seams and one focused deterministic claim-disposition/citation seam. Preserve the required behaviors; avoid a universal case-study framework, backend or live inference.

## Escalate before deciding
Missing mandatory private evidence or disclosure permission, ambiguous individual attribution, a factual conflict with current as-built evidence, a material change to trust semantics or publishing/naming policy, or a branch conflict that would overwrite sibling work. Block affected historical content rather than inventing it. Require separate authorization for publication, PR/merge, external integration or expanded scope.

# Testing Decisions

- **R1:** seam: rendered draft and opening anchors; evidence: cold-reader walkthrough in about three minutes, attribution review, no-script and navigation inspection.
- **R2:** seam: workspace state and rendered controls; evidence: exercise both lenses, deck inspection, exploration, simulated critique, skip/replay, reset and context changes; confirm no stale output or live request.
- **R3:** seam: claim-record disposition and citation resolver plus rendered inspector; evidence: supported, unknown-revised, unresolved, contradicted, broken-ref and failed-check fixtures; independently reconcile final points, gaps, counts, slide evidence and preview, with no rejected claims admitted.
- **R4:** seam: diagram model and rendered drill-downs; evidence: trace each source, runtime path, verdict branch and loop, review maturity against authorized evidence, test local links, geometry, narrow and keyboard access.
- **R5:** seam: mode transition and deliverable/handoff previews; evidence: same input shows hedged exploration and checked artifact, blocked claims never reach preview, citations and gaps preserved, external continuation labeled unverified and no network transfer.
- **R6:** seam: evaluation visual and synthetic rubric example; evidence: inspect all four grounding/fidelity combinations, positive-control/reference/generic comparison, known-bad failure and leakage limits; ensure no result is implied.
- **R7:** seam: historical narrative and private ledger; evidence: audit each observation-to-bet mapping, maturity and individual ownership against authorized source; flag missing measurement or permissions.
- **R8:** seam: full draft render and exhibit navigation; evidence: screenshots at desktop and narrow widths, keyboard, focus, contrast, 200% zoom, reduced motion, no-script, local exhibit return paths, clean Hugo build and production exclusion; final R/C matrix.
- **C1:** seam: diff, assets, fixture and metadata; evidence: manual proper-noun/number/private-link/asset review and canonical safety checks; no new disclosure or scanner weakening.
- **C2:** seam: private evidence and historical copy; evidence: inspect required corpus, ledger and role/maturity classifications before writing; affected unsupported claims explicitly blocked.
- **C3:** seam: fixture and claim/readout/export behavior; evidence: deterministic replay, disposition and referential integrity tests, explicit simulation labels, fail-closed missing evidence, no external model or transfer.
- **C4:** seam: site diff and rendered draft; evidence: reuse appropriate patterns, no unrelated regressions or generated output, applicable Hugo, accessibility and safety checks with fresh render evidence.
- **C5:** seam: contract review state, draft configuration and Git history; evidence: current approved graph/digest before execution, independent certification, no unauthorized release or merge, explicit review handoff.

The highest-risk seam is candidate-to-deliverable disposition and evidence resolution. A superficially polished demo that admits an unknown/contradicted claim or mismatches an evidence excerpt must fail. Run canonical child-repository checks, including fresh Hugo build, safety/render and publication gates, whitespace checks and applicable work-product checks; record actual results and browser evidence rather than inferring success.

# Out of Scope

Live AI inference, real person simulation, historical expert reproduction, actual scientific or fidelity validation, user uploads, external assistant integration, access to private systems from the demo, production software changes, unapproved historical metrics or disclosure, redesign of other pages, sitewide framework refactor and live publication.

# Starting State

The parent implementation revision contains the existing advisor draft, a four-stage native workflow figure and decision/outcome/reflection sections. The same branch contains a newer work-story layout with an interactive demonstration, architecture and exhibit patterns for another case study. Use the existing page as the content baseline and the newer layout as the design precedent; inspect child repository instructions, design/product/diagram guidance and current branch state before editing. The draft's existing publication and attribution limitations still apply. The private source and voice corpus is intentionally not included in this public contract.

# Further Notes

The author requested a spec-by-spec planning and ticketing workflow, with a separate implementation agent building the approved graphs. This case study is intended to complement scientific information architecture and discovery-workflow exhibits by making AI product judgment visible. The next step is review of this proposed spec and its ticket graph, then independent certification and implementation.
