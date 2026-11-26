---
arwc_version: "0.4"
arwc_kind: ticket
status: proposed
---

# Parent
Ref: https://github.com/athan-dial/athan-dial.github.io/issues/32
Digest: b9402b81fb1cfa5f889008a608a40632e9590fbcb16334ff6881d62b833a60b4

# What to build
A maintainer can open one isolated integration candidate and see exactly which approved implementation revisions are included, what still needs work and whether production and local review builds work. This slice establishes a useful, inspectable baseline rather than a new release or a blanket merge.

# Carries
R7, C1, C2, C3, C4, C5

# Acceptance criteria
### R7: Reconciled integrated site
- [ ] Read current refs, PRs, case contracts, their actual approval/evidence and the existing release gates. Produce a public-safe disposition manifest naming ancestry, tested revisions, pending implementation, overlaps, retained features and consequential conflicts for the historical baseline, work-product PR, three case-study packages and task-oriented architecture continuation.
- [ ] Create one isolated integration branch from the parent-bound baseline, reconciling only authorized compatible work; do not overwrite release heads or main. Preserve existing chapter order, routes, editorial authority, content model, atlas engine/data/fallback, work-story demos and canonical safety scripts. Conflicting requirements remain explicitly blocked for owner decision.
- [ ] Fresh normal and explicit draft-review builds establish the baseline, with current eligible exhibits and intact existing routes. Verify that unapproved pages/assets are absent from production. Record the pinned candidate SHA, actual included revisions and any failed/unavailable checks.
- [ ] Do not require unfinished sibling implementations in order to establish the preliminary baseline. Record them as external dependencies for the final integrated review; no scaffold or proposed spec is counted as a working case.

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
Use the parent's Locked branch and discovery references; inspect live state before selecting the integration tip. The existing #13–#18, #20–#31 and release gates are not superseded. Keep the disposition manifest free of private evidence.

## Executor discretion
Choose the smallest local implementation and verification seam that delivers this slice in accordance with the parent and repository authorities. Preserve prior verified behavior.

## Escalate before deciding
A consequential conflict in original contracts, approval or disclosure, missing required evidence, or a change to editorial, branch or publication authority. Stop the affected behavior; record the blocker without inventing approval.

# Testing Decisions
- **R7:** seam: pinned integration diff/history and clean builds; evidence: branch/revision disposition manifest, reconciliation of outstanding PRs/contracts, fresh production/draft output, original feature regression checks, no unresolved consequential conflict represented as complete.
- **C1:** seam: profile, page content and rendered hierarchy; evidence: approved editorial and site authority comparison, canonical checks, manual prose/attribution review.
- **C2:** seam: issue/branch diff, public build, images, metadata and preview; evidence: canonical safety checks plus manual confidential-detail/number/source/asset review; explicitly note if required private denylist or evidence is unavailable.
- **C3:** seam: original contract and integrated behavior; evidence: current case-specific verification and scope review, explicit blockers for missing implementations or evidence.
- **C4:** seam: build-mode and publication predicate; evidence: production/draft output and assets, feeds/indexes/sitemap/metadata, all/some/none availability, existing redirect and build checks, no extra backend or generated output.
- **C5:** seam: tracker review state, exact candidate and Git history; evidence: approved current parent/graph before execution, independent certification, candidate handoff without unauthorized release, existing release gate records preserved.
For this slice, collect direct evidence for its acceptance criteria. Integrated re-verification remains a separate obligation under 07.

# Blocked by
None

# Out of Scope
Building missing case-study features; approving unresolved branch conflicts; changing canonical profile, content gates, main, release heads or deployment.

# Further Notes
This is a proposed review artifact, not an activated tracker ticket. Numeric blockers are draft graph IDs; after the required graph approval, map them to actual issue identifiers, preserve the parent binding, create one issue per contract and independently certify its current revision.
