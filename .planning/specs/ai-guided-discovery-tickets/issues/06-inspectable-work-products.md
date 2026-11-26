---
arwc_version: "0.4"
arwc_kind: ticket
status: proposed
---

# Parent
Ref: .planning/specs/2026-11-26-ai-guided-discovery.md
Digest: 86a64234f02750aa67f29570bde20304b3c56d0624a934d98bbeea795d31aabf

# What to build
A reviewer can inspect representative public-safe work products and understand what each demonstrates, what maturity it had and where the author contributed. The page closes with a calibrated reflection.

# Carries
R7, C1, C2, C3, C4, C5

# Acceptance criteria

### R7: Inspectable artifacts and honest lessons
- [ ] Curated local exhibits cover workflow/process architecture, nomination information architecture, scientific application evolution and scientific strategy/decision framework. Reuse or reference the approved architecture detail where appropriate.
- [ ] Each exhibit states its job, concrete decision/tradeoff, maturity and evidenced role, and opens or links to accessible details with a return path and no private links.
- [ ] Authentic sanitized reconstructions or approved public artifacts are preferred; when unsafe or unavailable, explain the mechanism honestly without fabricating a screenshot or artifact.
- [ ] Major historical claims trace to the private ledger, with gaps stated or unsupported claims removed. Reflection describes what worked, limitations and next measurements or changes without invented results.

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
Use the private claim ledger established by 02 and reviewed architecture from 04. No private source material in tracked files or public references.

## Executor discretion
Pick compact local exhibits and reconstruction depth appropriate to verified evidence; use existing details/disclosure patterns.

## Escalate before deciding
Unclear permission, attribution, or evidence for an exhibit; downgrade to mechanism-only or omit rather than expose or invent it.

# Testing Decisions
- **R7:** seam: gallery/detail interactions and claims; evidence: open every exhibit and navigate back; compare maturity/role/claims to private ledger, inspect all assets/captions/metadata for safety and authenticity; check reflection for unsupported results.
- **C1:** seam: changed files, fixtures, asset metadata and screenshots; evidence: manual public-safety review plus existing safety checks, no private identifiers or real source records.
- **C2:** seam: historical copy and evidence ledger; evidence: private evidence and voice review before drafting, source-backed claim/maturity/role audit or explicit blocked historical claim.
- **C3:** seam: scenario inputs, displayed outputs and scientific wording; evidence: deterministic calculations where applicable, synthetic labels, no score-as-assay or unsupported scientific claims.
- **C4:** seam: repo diff and rendered local page; evidence: existing tokens/components, no runtime external requests or committed publish output, relevant build and accessibility checks.
- **C5:** seam: draft config and repository changes; evidence: ordinary production build/index excludes the page, no unauthorized publication or execution, explicit review status.

# Blocked by
04

# Out of Scope
Full internal artifact archive, live vendor/software screenshots, other case studies, and publication.
