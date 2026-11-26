---
arwc_version: "0.4"
arwc_kind: ticket
status: proposed
---

# Parent
Ref: .planning/specs/2026-11-26-ai-guided-discovery.md
Digest: 86a64234f02750aa67f29570bde20304b3c56d0624a934d98bbeea795d31aabf

# What to build
A reader sees a concise, evidence-backed account of how the nomination workflow evolved and which parts the author led, personally built, contributed to or delivered with collaborators. An authorized private claim ledger supports subsequent historical exhibits and architecture.

# Carries
R1, R4, C1, C2, C3, C4, C5

# Acceptance criteria

### R1: Concise contribution and orientation
- [ ] The opening path contains a concise, understandable contribution statement and the evolution section provides an independent deeper path.

### R4: Truthful product evolution
- [ ] The required private evidence/voice corpus has been inspected before drafting historical prose; the private claim ledger classifies each major claim by source, disclosure, maturity, role and measurement status.
- [ ] The rendered chronology distinguishes documented workflow stages, changing user needs, reusable capabilities and retained expert judgment, with dates only when supported and safe.
- [ ] Separate led, built, contributed, and team-owned work; distinguish designs, prototypes and deployed/operational capabilities. No invented adoption, maturity scale, or results; acknowledge missing measurements where applicable.

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
Follow the child repository evidence/voice requirements and parent role/maturity distinctions. Keep the evidence ledger private; public copy uses approved abstractions.

## Executor discretion
Chronology format and safe level of detail; omit unsupported dates or claims.

## Escalate before deciding
Missing required corpus, unclear role ownership or unsafe disclosures; stop the affected historical claims rather than inventing them.

# Testing Decisions
- **R1:** seam: rendered opening and evolution section; evidence: cold-reader review and accessible anchors.
- **R4:** seam: private claim ledger and rendered chronology; evidence: check claim-by-claim source, classification, maturity, attribution and target/estimate/measurement distinctions; inspect no false quantified maturity or outcomes.
- **C1:** seam: changed files, fixtures, asset metadata and screenshots; evidence: manual public-safety review plus existing safety checks, no private identifiers or real source records.
- **C2:** seam: historical copy and evidence ledger; evidence: private evidence and voice review before drafting, source-backed claim/maturity/role audit or explicit blocked historical claim.
- **C3:** seam: scenario inputs, displayed outputs and scientific wording; evidence: deterministic calculations where applicable, synthetic labels, no score-as-assay or unsupported scientific claims.
- **C4:** seam: repo diff and rendered local page; evidence: existing tokens/components, no runtime external requests or committed publish output, relevant build and accessibility checks.
- **C5:** seam: draft config and repository changes; evidence: ordinary production build/index excludes the page, no unauthorized publication or execution, explicit review status.

# Blocked by
01

# Out of Scope
Publishing private sources, new historical claims outside this work, and other product exhibits.
