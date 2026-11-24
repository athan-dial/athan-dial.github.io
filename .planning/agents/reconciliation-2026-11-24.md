# Branch reconciliation baseline

This is a source-inspection record, not a merge or build verdict. Issue #14 owns execution.

Observed 2026-11-24:

| Branch | HEAD | Relative to main | Proposed disposition |
| --- | --- | --- | --- |
| main | 3640e693cce18e834b0295ae316d89193c80a287 | baseline | Preserve deployed source and the two later artwork commits. |
| brand/personal-fieldnotes-proof-layer | 0f1bdd1c44242032714792d45cb570d29219149d | +4 / -0 | Recover through the stacked content branch; do not independently merge PR #2 without reconciliation. |
| brand/personal-fieldnotes-content | 2ee815871d5253418acd1a3c8162ab366187da58 | +30 / -0 | Review PR #3, proof layer and case visibility decisions; retain approved work. |
| brand/personal-fieldnotes-documentary-voice | c7afb8301980add3fe14f4d200535ee78092b30f | +28 / -0 | PR #4 merged into the content branch; no independent merge needed. |
| dev/atlas-integration | 5834df28ec46589ca95cc4e1a27063a5d0699c09 | +26 / -2 | Recover PR #12's catalogue, route and gate improvements; reconcile shared layouts. |
| design/expressive-layer | f9bb50ea1fb117158c28fd88287a84c48fbacfc1 | +1 / -22 | Older visual experiment. Inspect unique changes; do not revive superseded design by default. |
| design/hallmark-motif | 90153e350b582eee17c3234b80fbdd9cd89619c3 | +1 / -0 | Compare unique motif/artwork changes to current Fieldnotes identity and proof layer. |

## Integration notes

PR #2 and PR #3 form a stack. PR #4 was merged into #3. PR #12 has a different merge base (c48bcc365ea932078829d6f35f491846204e9d78). Shared paths include CLAUDE.md, DESIGN.md, assets/css/fieldnotes.css, content/about.md, layouts/index.html, layouts/_default/about.html, layouts/partials/work-card.html, layouts/thinking/list.html and layouts/work/list.html.

The PR #3 branch disputes a previously public narrative; resolve that through source review and a safe route disposition. Do not publish new drafts by changing frontmatter merely to satisfy a count assertion. PR #12's LOCAL-GATE.md requires current-head sign-off; prior checks are historical and must be rerun. Its catalogue README and generated content adapter also disagree about publication state, so update documentation when the actual baseline changes.

Issue #10 was reopened: the recorded closing comment explicitly says PR #12 was opened and merge was pending. Issue #11 remains blocked until deployment. Keep #5 as the existing release map.

No PR has been merged, closed or deleted in this sweep. No build or browser verification has been performed on a combined branch. Use issue #14 for integration and #15 for an architecture survey on the resulting baseline.
