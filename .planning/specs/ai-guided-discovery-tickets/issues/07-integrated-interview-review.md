---
arwc_version: "0.4"
arwc_kind: ticket
status: proposed
---

# Parent
Ref: .planning/specs/2026-11-26-ai-guided-discovery.md
Digest: 86a64234f02750aa67f29570bde20304b3c56d0624a934d98bbeea795d31aabf

# What to build
The integrated draft is a coherent, three-minute technical interview walkthrough with deeper exploration, and carries current evidence that every parent requirement and constraint is satisfied or explicitly blocked. Deliver the reviewable draft without publishing.

# Carries
R1, R2, R3, R4, R5, R6, R7, R8, C1, C2, C3, C4, C5

# Acceptance criteria

### R1: Integrated walkthrough
- [ ] The opening explains the decision and contribution; the short path includes discovery loop, interactive scenario and link to architecture and can be presented in approximately three minutes. The remaining sections are logically navigable with useful anchors and return paths, and independent exploration does not require narration.
- [ ] With JavaScript disabled and reduced motion, the static narrative remains complete. The experience reads as a work-product case study, not an application pitch.

### R2: Integrated discovery visual
- [ ] The opening transformation and full causal sequence remain intact, clearly illustrative and static-readable.

### R3: Integrated workbench
- [ ] All workbench controls, details, baseline, reset and empty states function on the assembled page; fresh selection invariants and plot/table/summary agreement pass, including boundary cases.

### R4: Integrated narrative accuracy
- [ ] Chronology, maturity, role statements and all historical claims match the reviewed private ledger and disclose missing evidence or measurements.

### R5: Integrated architecture
- [ ] Trace key handoffs, responsibility boundaries, expert review and nonautomatic feedback; detail links and geometry work in the final render.

### R6: Integrated strategy explorer
- [ ] All four states and reset remain operable, scientifically conditional and distinguishable; static alternatives and limitations remain visible.

### R7: Integrated evidence exhibits
- [ ] All exhibits and returns work; claims, artifacts and reflection remain safe, supported and accurately attributed.

### R8: Accessible and coherent final draft
- [ ] Existing visual language, hierarchy and diagram vocabulary are consistent across the assembled page; workbench and architecture have appropriate visual space. Desktop and narrow layouts show no clipped controls, overlaps, broken connectors or unintended page overflow.
- [ ] Verify keyboard navigation/focus, named controls and state, chart descriptions, contrast, touch targets, 200% text zoom, no-script and reduced-motion behavior.
- [ ] Applicable Hugo and existing verification checks pass; unrelated pages and routes are unaffected. Draft remains absent from ordinary production output and indexes.
- [ ] Provide current screenshots, behavioral test results and an R/C evidence matrix. Identify failures or blocked checks rather than asserting readiness without proof.

# Constraints

### C1: Evidence and public-repository safety
Inherit C1 from the parent. Every tracked file and asset is public-visible; use synthetic data and approved abstractions. Keep real source evidence and mappings private/untracked.

### C2: Content-authenticity gate
Inherit C2. Inspect the required private evidence and voice corpus before historical claims; if unavailable, leave affected claims blocked and use explicitly illustrative content only. Distinguish target, estimate, measurement and attribution.

### C3: Scientific and computational integrity
Inherit C3. Use deterministic synthetic data, compute claims about the selection from actual selected rows, and distinguish model scores from assay results and conditional strategy from scientific validation.

### C4: Site design and engineering boundaries
Inherit C4. Use existing Hugo and Personal Fieldnotes conventions, native/local behavior, accessibility and performance practices; avoid unnecessary abstractions, services and generated publish output.

### C5: Review and publication authority
Inherit C5. Work remains draft/private; no public deployment, merge to deployment branch, new disclosure or live workflow without separate authorization. Proposed contracts require review and certification before execution.

# Implementation Decisions

## Locked
Verify against the original parent spec and integrated build, not child ticket status. Preserve all approved content and publication gates.

## Executor discretion
Use existing build/browser seams, make local fixes that satisfy the parent and do not alter normative intent.

## Escalate before deciding
Any remaining historical evidence or disclosure blocker, required but unavailable verification, or material scope/authority change. Do not publish.

# Testing Decisions
- **R1:** seam: full rendered page; evidence: timed walkthrough, navigation and no-script inspection.
- **R2:** seam: integrated opening; evidence: stage/feedback and static/reduced-motion audit.
- **R3:** seam: integrated selection and controls; evidence: rerun membership/constraint tests and exercise controls, empty states, reset and baseline in-browser.
- **R4:** seam: narrative/ledger; evidence: recheck chronology, maturity, roles and measurements against approved private evidence.
- **R5:** seam: integrated architecture; evidence: handoff semantics, geometry and keyboard navigation review.
- **R6:** seam: integrated explorer; evidence: all state transitions and limitations plus keyboard/no-script review.
- **R7:** seam: gallery and reflection; evidence: all local details, claim and asset review.
- **R8:** seam: full Hugo render; evidence: desktop/narrow screenshots, 200% zoom, keyboard, contrast, no-script/reduced-motion, no overflow; run applicable hugo --gc --minify, scripts/verify-build.sh, scripts/verify-render.sh, scripts/publish-gate.sh and whitespace checks. Confirm production exclusion and unrelated route stability.
- **C1:** seam: changed files, fixtures, asset metadata and screenshots; evidence: manual public-safety review plus existing safety checks, no private identifiers or real source records.
- **C2:** seam: historical copy and evidence ledger; evidence: private evidence and voice review before drafting, source-backed claim/maturity/role audit or explicit blocked historical claim.
- **C3:** seam: scenario inputs, displayed outputs and scientific wording; evidence: deterministic calculations where applicable, synthetic labels, no score-as-assay or unsupported scientific claims.
- **C4:** seam: repo diff and rendered local page; evidence: existing tokens/components, no runtime external requests or committed publish output, relevant build and accessibility checks.
- **C5:** seam: draft config and repository changes; evidence: ordinary production build/index excludes the page, no unauthorized publication or execution, explicit review status.

# Blocked by
03, 05, 06

# Out of Scope
Live publication, merge to deployment branch, new product scope, and treating unverified results as complete.
