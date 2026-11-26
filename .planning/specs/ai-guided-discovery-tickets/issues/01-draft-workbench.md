---
arwc_version: "0.4"
arwc_kind: ticket
status: proposed
---

# Parent
Ref: .planning/specs/2026-11-26-ai-guided-discovery.md
Digest: 86a64234f02750aa67f29570bde20304b3c56d0624a934d98bbeea795d31aabf

# What to build
A reader can open a private draft of the proposed work-product page and operate one complete synthetic compound-selection scenario. This is the first end-to-end slice: fixture, calculation, controls, selected results and tests in the actual page, rather than an isolated algorithm or a blank scaffold.

# Carries
R1, R3, R8, C1, C2, C3, C4, C5

# Acceptance criteria

### R1: Short walkthrough foundation
- [ ] The draft opens with a plain-language explanation of compound nomination and the illustrative scenario, and includes navigable anchors for completed sections. Do not present unbuilt sections or historical claims as completed.
- [ ] With scripts disabled, a static narrative and documented default example remain legible.

### R3: Functional synthetic nomination workbench
- [ ] A deterministic fictional candidate set includes IDs, scores, clusters, relevant properties and synthetic cost/accessibility; the displayed default selection and rules are inspectable.
- [ ] Activity-oriented and cost-adjusted ranking, eligibility/property criteria, budget/capacity and a per-cluster diversity cap are adjustable. The fixture demonstrates real membership changes under objective, budget and diversity changes.
- [ ] One shared selection calculation determines eligible unique IDs, count, cluster coverage, estimated cost, plot highlights and table membership; cost/capacity and cluster caps are never exceeded. Identical inputs, including ties, produce identical results. Explain rules and tie-breaking.
- [ ] A compound or pool detail reveals fictional inputs and eligibility/selection rationale. Baseline comparison and scenario summary include criteria, selected IDs and counts; reset restores the identical default.
- [ ] Zero-feasible and invalid/out-of-range inputs have understandable states and a reset path. No purchase, order or external workflow occurs. All data and algorithm behavior are labeled synthetic/illustrative.

### R8: Draft and accessible baseline
- [ ] Use existing work-product layout, typography, tokens and semantic controls; draft is excluded from normal public build and indexes.
- [ ] Controls work with keyboard and visible focus; chart has an accessible textual equivalent, no color-only distinctions, and no unintended page overflow. No-script default selection and reduced-motion behavior remain readable.

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
Use the parent proposed route and draft/private conventions. A single deterministic selection seam supplies all outputs. Historical claims await evidence review. Use local fixture data only.

## Executor discretion
Fixture size, cost units, property thresholds, ranking formula, tie-breaks, visual encodings and component implementation within parent constraints.

## Escalate before deciding
Consequential route conflict, evidence or disclosure uncertainty, proposed external dependency or expansion beyond a local educational demo.

# Testing Decisions
- **R1:** seam: draft render; evidence: inspect opening, navigation and no-script example.
- **R3:** seam: selection function and browser controls; evidence: tests for default, objective, budget, cap, filters, zero results, boundary inputs, ties and reset; independently recompute sums, clusters and membership and compare plot/table/summary. A hardcoded count, ineligible ID, overspend or divergent highlight must fail.
- **R8:** seam: draft build and browser; evidence: keyboard/focus, chart equivalent, narrow width, no-script default and absence from production output/index.
- **C1:** seam: changed files, fixtures, asset metadata and screenshots; evidence: manual public-safety review plus existing safety checks, no private identifiers or real source records.
- **C2:** seam: historical copy and evidence ledger; evidence: private evidence and voice review before drafting, source-backed claim/maturity/role audit or explicit blocked historical claim.
- **C3:** seam: scenario inputs, displayed outputs and scientific wording; evidence: deterministic calculations where applicable, synthetic labels, no score-as-assay or unsupported scientific claims.
- **C4:** seam: repo diff and rendered local page; evidence: existing tokens/components, no runtime external requests or committed publish output, relevant build and accessibility checks.
- **C5:** seam: draft config and repository changes; evidence: ordinary production build/index excludes the page, no unauthorized publication or execution, explicit review status.

# Blocked by
None

# Out of Scope
Historical narrative and attribution, other exhibits and diagrams, scientific strategy explorer, live publication.
