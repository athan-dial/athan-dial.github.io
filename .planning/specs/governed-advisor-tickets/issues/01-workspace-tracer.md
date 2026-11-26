---
arwc_version: "0.4"
arwc_kind: ticket
status: proposed
---

# Parent
Ref: .planning/specs/2026-11-26-governed-advisor.md
Digest: 63e3162e8c8855dd02fb055864ce6de6482b8f256768b470bec2446ccc27ae7c

# What to build
The existing draft gains a usable, end-to-end synthetic workspace with a selected discipline lens, fictional deck, exploration and governed critique. Deliver a real vertical slice rather than an empty shell.

# Carries
R1, R2, R3, R5, C1, C2, C3, C4, C5

# Acceptance criteria
### R1: A short product narrative with visible contribution
- [ ] The draft opens with a concrete preparation problem, an illustrative example and anchor path for later depth. Existing draft and attribution limitations remain intact.

### R2: An interactive synthetic advisor workspace
- [ ] At least two fictional discipline lenses and at least two fictional slides can be inspected; lens choice affects example review priorities. Explore and critique retain selected context.
- [ ] A deterministic, explicitly simulated run delivers a readout; skip/replay, reset, lens changes and unavailable material work. Changed context invalidates stale output.

### R3: Claim-level evidence and verification inspection
- [ ] One shared claim record seam resolves supported points, gaps and withheld candidates from fixture IDs; final readout cannot admit unknown or contradicted claims. Missing or failed verification fails closed.

### R5: Two trust postures and a bounded handoff
- [ ] Exploration can show a labeled hedged hypothesis; critique is labeled separately and does not display unverified candidates as findings. Use the same material to demonstrate the contrast.

# Constraints
### C1: Public-repository and disclosure safety
Inherit parent C1. Every tracked file, including this contract, planning files, screenshots, fixture, assets, metadata and client bundles, is public-visible regardless of branch or frontmatter. Follow the child repository's content-safety and employer-review rules. Use approved functional descriptions and invented examples. Do not add internal codenames, real expert or colleague identities, internal links, unpublished project facts, private decks, transcripts, source corpus, vendor relationships, internal metrics, schemas, hostnames or credentials. Keep private evidence and mapping in authorized untracked locations. Existing review-copy names are not blanket disclosure permission; resolve naming with the author before public release. Do not weaken scanners or copy private evidence into Git.

### C2: Evidence and attribution before historical claims
Inherit parent C2. Use the required authorized private work-archaeology and voice materials before editing factual historical narrative. Maintain a private claim-to-source and disclosure/maturity/ownership ledger. Separate built, tested, planned, recommended and measured; target is not result. Do not claim individual credit for others' implementation or scientific judgment. If mandatory evidence is unavailable, continue only with explicitly illustrative design/demo work and block the affected historical claims; do not invent or silently upgrade them.

### C3: Honest simulation and trust semantics
Inherit parent C3. The public demo is deterministic, synthetic and offline. It never claims to run an AI model, reproduce an actual expert, verify scientific truth or certify production fidelity. All visible outputs share declared fixtures, premise links and verdicts. Final findings are supported only; contradicted findings are withheld; unresolved unknowns are explicit gaps. Missing or failed verification cannot become an admitted finding. Diagnostic draft views are clearly separate. Any export/handoff preview preserves the boundary and makes no external request.

### C4: Site and accessibility boundaries
Inherit parent C4. Follow the existing Hugo and Personal Fieldnotes implementation, site tokens and diagram vocabulary. Reuse the improved work-story primitives when appropriate, avoid speculative general frameworks and unnecessary dependencies, preserve other work pages and routes, and do not commit generated publish output. No motion may gate access; provide static equivalents and keyboard-accessible controls. Do not silently revert work from sibling branches.

### C5: Review and execution authority
Inherit parent C5. This proposed spec and its ticket drafts are for review and decomposition, not authorization to execute, deploy, disclose, merge to the deployment branch or open a PR. Bind the approved parent digest, obtain required graph approval and independent Steward certification before dispatch. Implement and review a private draft; require explicit publication and disclosure authorization separately. Keep review feedback and private evidence out of the public repository.

# Implementation Decisions

## Locked
Establish the draft page and shared local scenario/claim records. Preserve the current work-story components; no live AI, uploads or backend. Leave richer inspection and handoff preview to 02.

## Executor discretion
Choose local implementation and evidence seams within the parent contract and current repository conventions. Keep changes narrowly scoped to this vertical slice.

## Escalate before deciding
Missing mandatory private evidence or disclosure permission, ambiguous individual attribution, a factual conflict with current as-built evidence, a material change to trust semantics or publishing/naming policy, or a branch conflict that would overwrite sibling work. Block affected historical content rather than inventing it. Require separate authorization for publication, PR/merge, external integration or expanded scope.

# Testing Decisions
- **R1:** seam: rendered draft and opening anchors; evidence: cold-reader walkthrough in about three minutes, attribution review, no-script and navigation inspection.
- **R2:** seam: workspace state and rendered controls; evidence: exercise both lenses, deck inspection, exploration, simulated critique, skip/replay, reset and context changes; confirm no stale output or live request.
- **R3:** seam: claim-record disposition and citation resolver plus rendered inspector; evidence: supported, unknown-revised, unresolved, contradicted, broken-ref and failed-check fixtures; independently reconcile final points, gaps, counts, slide evidence and preview, with no rejected claims admitted.
- **R5:** seam: mode transition and deliverable/handoff previews; evidence: same input shows hedged exploration and checked artifact, blocked claims never reach preview, citations and gaps preserved, external continuation labeled unverified and no network transfer.
- **C1:** seam: diff, assets, fixture and metadata; evidence: manual proper-noun/number/private-link/asset review and canonical safety checks; no new disclosure or scanner weakening.
- **C2:** seam: private evidence and historical copy; evidence: inspect required corpus, ledger and role/maturity classifications before writing; affected unsupported claims explicitly blocked.
- **C3:** seam: fixture and claim/readout/export behavior; evidence: deterministic replay, disposition and referential integrity tests, explicit simulation labels, fail-closed missing evidence, no external model or transfer.
- **C4:** seam: site diff and rendered draft; evidence: reuse appropriate patterns, no unrelated regressions or generated output, applicable Hugo, accessibility and safety checks with fresh render evidence.
- **C5:** seam: contract review state, draft configuration and Git history; evidence: current approved graph/digest before execution, independent certification, no unauthorized release or merge, explicit review handoff.

# Blocked by
None

# Out of Scope
Historical narrative changes, full evidence inspector, export/handoff previews, architecture and evaluation exhibits.
