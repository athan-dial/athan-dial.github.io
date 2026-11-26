---
arwc_version: "0.4"
arwc_kind: ticket
status: proposed
---

# Parent
Ref: .planning/specs/2026-11-26-ai-guided-discovery.md
Digest: 86a64234f02750aa67f29570bde20304b3c56d0624a934d98bbeea795d31aabf

# What to build
A reader selects an illustrative program evidence state and inspects the scientific rationale for a proposed next decision, including when broad predictive search may be a poor use of experimental capacity.

# Carries
R6, C1, C2, C3, C4, C5

# Acceptance criteria

### R6: Evidence-state strategy explorer
- [ ] Four selectable states cover inconclusive biological signal, credible but chemically concentrated signal, distributed signal with unexplored chemistry, and sufficient credible series. Each produces a distinct plausible visual example and explanation with assumptions.
- [ ] Explain broad exploratory search versus experimental deepening/hit expansion, plus biological signal, model applicability/generalization, feasible chemistry, experimental capacity and opportunity cost. State what evidence could change the decision.
- [ ] The explorer is a conditional educational framework, not a universal policy, validated model, outcome prediction or automated approval; historical claims require private evidence review.
- [ ] All states and reset are accessible by keyboard, and a static equivalent preserves the main scientific reasoning.

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
Implement the four parent evidence states as illustrative scenarios; source-backed historical wording waits on approved evidence.

## Executor discretion
Scenario layout, simple visual encodings and state behavior; choose concise explanatory language within the scientific constraints.

## Escalate before deciding
Any unsupported historical decision, implied clinical/experimental result, or consequential change to the scientific decision framework.

# Testing Decisions
- **R6:** seam: scenario state and render; evidence: exercise all four states and reset, verify distinct visual/explanation, explicit limitations and change conditions, keyboard and no-script alternative; review scientific wording.
- **C1:** seam: changed files, fixtures, asset metadata and screenshots; evidence: manual public-safety review plus existing safety checks, no private identifiers or real source records.
- **C2:** seam: historical copy and evidence ledger; evidence: private evidence and voice review before drafting, source-backed claim/maturity/role audit or explicit blocked historical claim.
- **C3:** seam: scenario inputs, displayed outputs and scientific wording; evidence: deterministic calculations where applicable, synthetic labels, no score-as-assay or unsupported scientific claims.
- **C4:** seam: repo diff and rendered local page; evidence: existing tokens/components, no runtime external requests or committed publish output, relevant build and accessibility checks.
- **C5:** seam: draft config and repository changes; evidence: ordinary production build/index excludes the page, no unauthorized publication or execution, explicit review status.

# Blocked by
01

# Out of Scope
Real predictive models, program-specific policies, automated scientific approvals, and real datasets.
