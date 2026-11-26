---
arwc_version: "0.4"
arwc_kind: ticket
status: proposed
---

# Parent
Ref: .planning/specs/2026-11-26-ai-guided-discovery.md
Digest: 86a64234f02750aa67f29570bde20304b3c56d0624a934d98bbeea795d31aabf

# What to build
A technical reader can trace the sanitized scientific workflow across computational, product, expert and experimental boundaries, and inspect its handoffs without proprietary system details.

# Carries
R5, C1, C2, C3, C4, C5

# Acceptance criteria

### R5: Inspectable scientific architecture
- [ ] The main path traces experimental records and molecular identities through dataset preparation, model training/evaluation, predictions, molecular properties/diversity, nomination search/selection, scientific and operational review, sourcing or synthesis, testing, interpretation and subsequent learning.
- [ ] Distinct responsibility zones and typed states/actions/decisions show meaningful inputs and outputs, including rationale, feasibility and returned observations; scientific approval is human and scores are not assay results.
- [ ] Show separate or alternative sourcing/synthesis paths where relevant, and distinguish feedback from guaranteed retraining. Do not invent synchronization or handoffs.
- [ ] Accessible detail on each meaningful region/handoff identifies purpose, input, output, decision owner by role and relevant limitations. Architecture is labeled conceptual/sanitized and grounded in approved evidence.

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
Use the approved private evidence and safe abstractions established by 02; respect site diagram semantics and the parent handoff boundary.

## Executor discretion
Diagram format, layout, grouping and drill-down mechanics; scope detail to useful scientific decisions.

## Escalate before deciding
Unresolved handoff ownership, unclear evidence or disclosure, or a proposed new architecture not established by the source.

# Testing Decisions
- **R5:** seam: diagram model and detail links; evidence: compare stages, roles, inputs/outputs and feedback semantics against approved abstractions; inspect geometry, edge routing, responsive readability and keyboard drill-down.
- **C1:** seam: changed files, fixtures, asset metadata and screenshots; evidence: manual public-safety review plus existing safety checks, no private identifiers or real source records.
- **C2:** seam: historical copy and evidence ledger; evidence: private evidence and voice review before drafting, source-backed claim/maturity/role audit or explicit blocked historical claim.
- **C3:** seam: scenario inputs, displayed outputs and scientific wording; evidence: deterministic calculations where applicable, synthetic labels, no score-as-assay or unsupported scientific claims.
- **C4:** seam: repo diff and rendered local page; evidence: existing tokens/components, no runtime external requests or committed publish output, relevant build and accessibility checks.
- **C5:** seam: draft config and repository changes; evidence: ordinary production build/index excludes the page, no unauthorized publication or execution, explicit review status.

# Blocked by
02

# Out of Scope
Real topology, proprietary schema details, infrastructure redesign, model training or execution.
