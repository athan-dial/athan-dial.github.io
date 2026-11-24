# Combined review branch, 2026-11-24

Branch `claude/lucid-cray-sezuh0`. One review candidate that combines three streams. It is not a release and
nothing here authorizes a merge or a deployment.

## Baselines (pinned)

| Stream | Source | Commit |
|---|---|---|
| Main | `main` | `3640e69` |
| Historical reconciliation (PR #19) | `integration/historical-reconciliation` | `679875f` |
| Agentic Operating System atlas (issue #17) | local Arc commits | `a011d87` (merged as `49fd308`) |
| Editorial authority and copy (issue #16) | this branch | see `git log` |

## Owner decisions recorded 2026-11-24

- Development acceptance accepts emulated touch, axe-core and accessibility-tree results for the atlas.
  Physical touch devices, screen readers, Safari and Firefox are release verification and live in issue #18.
- Live supervisor verification is separate Agent Home work and is not a blocker here.
- Agents may promote work to ready when every policy gate passes. Done, merge and publish stay with a person.
  The atlas states this distinction; Agent Home is not edited.
- Editorial positioning, voice, page jobs and the approach to cases are in `EDITORIAL.md`.

## Checks run on this branch

`hugo --gc --minify` and `-D`; `verify-content-safety`, `verify-fieldnotes-home` (now eight chapters),
`verify-proof-layer`, `verify-documentary-voice`, `verify-editorial`, `verify-build`, `verify-render`,
`verify-redirects`, `publish-gate --no-build`; `atlas/validate.py` and `atlas/tests/run.sh`;
`tools/agentic-os-atlas/validate.py`; `scripts/verify-browser.cjs`; axe-core on twelve page and viewport
combinations. See the pull request and the review pack for outputs. The private denylist was not available;
structural safety checks are not a full publication safety review.

## Still open (human)

Current role details on About; copy approval; image rights; cold-reader pass; physical-device, screen-reader and
other-browser checks (issue #18); the decision to publish the atlas page (draft until approved).

## Release decisions (owner, 2026-11-24, after CI green on 1207203)
- Ship without The Agentic Operating System: page stays draft; employer review not done. Adding it later is a draft flip plus review.
- Copy sign-off by the owner only. The outside cold read in EDITORIAL.md section 7 is waived for this release.
- No historical draft cases this release: no written confidentiality clearance.
- Release checks in #18 (physical devices, screen reader, Safari, Firefox) run on the local preview before merge.
- Owner runs the private-name denylist against the build and branch diff before merge.
- Owner reviews a local preview first. Merge to main deploys, so the owner merges; no automated deployment approval.
