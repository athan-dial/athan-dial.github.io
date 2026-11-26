---
arwc_version: "0.4"
arwc_kind: ticket
status: proposed
---

# Parent
Ref: .planning/specs/2026-11-26-governed-advisor.md
Digest: 63e3162e8c8855dd02fb055864ce6de6482b8f256768b470bec2446ccc27ae7c

# What to build
A reader compares evidence support and expert-review fidelity as separate qualities, then inspects a synthetic positive-control design without mistaking it for results.

# Carries
R6, C1, C2, C3, C4, C5

# Acceptance criteria
### R6: Separate fidelity evaluation from evidence grounding
- [ ] A two-dimensional visual has meaningful fictional examples of all four grounding/fidelity combinations.
- [ ] Show the proposed comparison of same material, recorded expert reference, governed candidate and generic control, with frozen/held-out cases, independent scoring, leakage and style-versus-judgment limitations.
- [ ] Interactive synthetic rubric compares generic and discipline-specific critiques by priority, grounding, review moves, actionability and overreach; include a known-bad candidate and explain what would justify promotion. Static equivalent and no real expert identities, claims of measured results or implemented gate.

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
Keep evaluation separate from runtime verification. Use fictional rubric and examples; historical evaluation remains proposed unless separately substantiated.

## Executor discretion
Choose local implementation and evidence seams within the parent contract and current repository conventions. Keep changes narrowly scoped to this vertical slice.

## Escalate before deciding
Missing mandatory private evidence or disclosure permission, ambiguous individual attribution, a factual conflict with current as-built evidence, a material change to trust semantics or publishing/naming policy, or a branch conflict that would overwrite sibling work. Block affected historical content rather than inventing it. Require separate authorization for publication, PR/merge, external integration or expanded scope.

# Testing Decisions
- **R6:** seam: evaluation visual and synthetic rubric example; evidence: inspect all four grounding/fidelity combinations, positive-control/reference/generic comparison, known-bad failure and leakage limits; ensure no result is implied.
- **C1:** seam: diff, assets, fixture and metadata; evidence: manual proper-noun/number/private-link/asset review and canonical safety checks; no new disclosure or scanner weakening.
- **C2:** seam: private evidence and historical copy; evidence: inspect required corpus, ledger and role/maturity classifications before writing; affected unsupported claims explicitly blocked.
- **C3:** seam: fixture and claim/readout/export behavior; evidence: deterministic replay, disposition and referential integrity tests, explicit simulation labels, fail-closed missing evidence, no external model or transfer.
- **C4:** seam: site diff and rendered draft; evidence: reuse appropriate patterns, no unrelated regressions or generated output, applicable Hugo, accessibility and safety checks with fresh render evidence.
- **C5:** seam: contract review state, draft configuration and Git history; evidence: current approved graph/digest before execution, independent certification, no unauthorized release or merge, explicit review handoff.

# Blocked by
01

# Out of Scope
Real expert impersonation, model benchmarking, real historical deck or validation study.
