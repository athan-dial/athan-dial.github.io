---
arwc_version: "0.4"
arwc_kind: ticket
status: proposed
---

# Parent
Ref: https://github.com/athan-dial/athan-dial.github.io/issues/32
Digest: b9402b81fb1cfa5f889008a608a40632e9590fbcb16334ff6881d62b833a60b4

# What to build
A visitor can move from the existing homepage to an evidence-led, visually curated Work index and open an eligible flagship or system. This establishes the shared publication/preview eligibility behavior as a vertical slice with real navigation.

# Carries
R1, R2, C1, C2, C3, C4, C5

# Acceptance criteria
### R1: Cohesive homepage and professional narrative
- [ ] Preserve the exact approved headline and all eight homepage chapters, profile, portrait, trajectory, canonical links and practitioner-first editorial register. Revise only the work-introduction surfaces needed to connect scientific discovery, information architecture, governed AI and the personal operating method.
- [ ] Work in practice explains the conceptual relationship of the exhibits, with eligible links; no invented shared deployment. The first useful work action remains functional. With no eligible exhibits, omit the unavailable feature or use a meaningful public destination without dead anchors. Static and reduced-motion reading remain complete.

### R2: Curated flagship exhibition
- [ ] The Work index retains its evidence note and content categories. The product case order is discovery, scientific intelligence, governed AI; preserve a distinct featured personal system and other eligible cases/proof notes. Show each eligible exhibit's user problem, concrete decision/mechanism and actual destination.
- [ ] Use public-safe visuals derived from available case diagrams or deterministic demo data; identify illustrative previews and missing work honestly. Check the full, mixed and empty eligible sets with no duplicate cards, empty shelves or broken destinations.
- [ ] Production eligibility requires the applicable content approval gates; draft-review links are available only in the explicit review build. The same small eligibility seam is available to subsequent navigation tickets. No draft links, preview assets or metadata leak into ordinary output.

# Constraints
### C1: Editorial and content authority
Inherit parent C1 in full. See the bound parent issue; the slice may not weaken this constraint.

### C2: Public repository and disclosure safety
Inherit parent C2 in full. See the bound parent issue; the slice may not weaken this constraint.

### C3: Preserve verified behavior and contract authority
Inherit parent C3 in full. See the bound parent issue; the slice may not weaken this constraint.

### C4: Build and preview separation
Inherit parent C4 in full. See the bound parent issue; the slice may not weaken this constraint.

### C5: Authorization and release
Inherit parent C5 in full. See the bound parent issue; the slice may not weaken this constraint.

# Implementation Decisions

## Locked
Retain Home chapter order and Work classification; use existing Hugo content/data as authority and the smallest useful shared eligibility/preview helper. Preserve existing public URLs and all other working content.
- Work index owner: the trunk's work/list.html and work-card.html. The atlas's flat grid is not used.
- Keep work_kind unchanged (flagship = case, system = operating system). Add a frontmatter number exhibit_order: it orders Cases ahead of date (discovery, intelligence, governed); the system block stays the capstone.
- Local draft-review flag: define the build-mode flag and the shared eligibility helper here. Draft-review links appear only when it is set; verify-build.sh asserts their absence in production.

## Executor discretion
Choose the smallest local implementation and verification seam that delivers this slice in accordance with the parent and repository authorities. Preserve prior verified behavior.

## Escalate before deciding
A consequential conflict in original contracts, approval or disclosure, missing required evidence, or a change to editorial, branch or publication authority. Stop the affected behavior; record the blocker without inventing approval.

# Testing Decisions
- **R1:** seam: rendered homepage; evidence: cold-reader short-path walkthrough, exact headline and chapter-order regression, eligible work links, static/no-script reading, correct behavior with no eligible work.
- **R2:** seam: Work index and shared content eligibility; evidence: full/mixed/empty exhibit fixtures or builds, no duplication, actual sanitized preview provenance, eligible links and retained published/proof-note entries.
- **C1:** seam: profile, page content and rendered hierarchy; evidence: approved editorial and site authority comparison, canonical checks, manual prose/attribution review.
- **C2:** seam: issue/branch diff, public build, images, metadata and preview; evidence: canonical safety checks plus manual confidential-detail/number/source/asset review; explicitly note if required private denylist or evidence is unavailable.
- **C3:** seam: original contract and integrated behavior; evidence: current case-specific verification and scope review, explicit blockers for missing implementations or evidence.
- **C4:** seam: build-mode and publication predicate; evidence: production/draft output and assets, feeds/indexes/sitemap/metadata, all/some/none availability, existing redirect and build checks, no extra backend or generated output.
- **C5:** seam: tracker review state, exact candidate and Git history; evidence: approved current parent/graph before execution, independent certification, candidate handoff without unauthorized release, existing release gate records preserved.
For this slice, collect direct evidence for its acceptance criteria. Integrated re-verification remains a separate obligation under 07.

# Blocked by
01a

# Out of Scope
Site rebrand, new generic case-study engine, rewriting historical case claims, capability navigation, guided route, publication.

# Further Notes
This is a proposed review artifact, not an activated tracker ticket. Numeric blockers are draft graph IDs; after the required graph approval, map them to actual issue identifiers, preserve the parent binding, create one issue per contract and independently certify its current revision.
