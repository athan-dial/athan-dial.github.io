---
arwc_version: "0.4"
arwc_kind: ticket
status: proposed
---

# Parent
Ref: .planning/specs/2026-11-26-ai-guided-discovery.md
Digest: 86a64234f02750aa67f29570bde20304b3c56d0624a934d98bbeea795d31aabf

# What to build
A visitor grasps the scientific decision and closed discovery loop from the opening visual without needing to operate the workbench or read a technical diagram.

# Carries
R1, R2, C1, C3, C4, C5

# Acceptance criteria

### R1: Opening visual supports the short path
- [ ] The visual is immediately understandable in the opening narrative and leads naturally to the selection scenario; static content is complete.

### R2: Scientific problem and feedback loop
- [ ] The illustration shows chemical space, prediction, constrained selection, scientific review, acquisition or synthesis, testing, interpretation and subsequent decision feedback.
- [ ] A concrete transformation or before/after illustrates the burden of reconstructing inputs, rank, selection rationale and returned evidence.
- [ ] Chemical-space and assay-like marks are labeled illustrative. Static content conveys every stage and meaning; any optional motion is brief, finite or user-controlled and reduced-motion safe.

# Constraints

### C1: Evidence and public-repository safety
Inherit C1 from the parent. Every tracked file and asset is public-visible; use synthetic data and approved abstractions. Keep real source evidence and mappings private/untracked.

### C3: Scientific and computational integrity
Inherit C3. Use deterministic synthetic data, compute claims about the selection from actual selected rows, and distinguish model scores from assay results and conditional strategy from scientific validation.

### C4: Site design and engineering boundaries
Inherit C4. Use existing Hugo and Personal Fieldnotes conventions, native/local behavior, accessibility and performance practices; avoid unnecessary abstractions, services and generated publish output.

### C5: Review and publication authority
Inherit C5. Work remains draft/private; no public deployment, merge to deployment branch, new disclosure or live workflow without separate authorization. Proposed contracts require review and certification before execution.

# Implementation Decisions

## Locked
Use the existing visual grammar and static-first narrative; do not imply automatic retraining or experimental validation.

## Executor discretion
Choose an economical visual representation and optional motion implementation; do not add motion solely for ornament.

## Escalate before deciding
Any departure from static-first or publication safety, or claim of actual scientific outcomes.

# Testing Decisions
- **R1:** seam: opening render; evidence: static/no-script walkthrough into the demo.
- **R2:** seam: diagram and optional animation; evidence: stage/order and feedback-direction audit, illustrative labels, finite/user-controlled playback and reduced-motion checks.
- **C1:** seam: changed files, fixtures, asset metadata and screenshots; evidence: manual public-safety review plus existing safety checks, no private identifiers or real source records.
- **C3:** seam: scenario inputs, displayed outputs and scientific wording; evidence: deterministic calculations where applicable, synthetic labels, no score-as-assay or unsupported scientific claims.
- **C4:** seam: repo diff and rendered local page; evidence: existing tokens/components, no runtime external requests or committed publish output, relevant build and accessibility checks.
- **C5:** seam: draft config and repository changes; evidence: ordinary production build/index excludes the page, no unauthorized publication or execution, explicit review status.

# Blocked by
01

# Out of Scope
Historical data, actual molecule or assay displays, new animation framework, and detailed system architecture.
