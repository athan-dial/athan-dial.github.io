# Local publication gate: historical integration candidate

This checklist carries the publication requirements of PR #12 onto the combined candidate. The original branch and its pre-push hook remain unchanged. A pushed review branch does not grant publication approval. Do not create or claim a gate sign-off until the exact candidate SHA passes the applicable checks and the owner approves the content and image use.

## 1. Browser review

Stop any draft server before production checks. For local visual review run Hugo; confirm Home, Work, About, Fieldnotes, Atlas and representative record pages (including image and fallback plate). Check search, groups, source links and evidence limitations; confirm the featured essay is not repeated on Home. Review the expanded About and Work evidence fields and both conversation anchors. Confirm the withheld case redirects to Work. Check 390px and wide desktop, 200% zoom, keyboard focus, JS disabled, reduced motion and contrast where changed. No content should require JavaScript to become visible.

## 2. Fresh production checks

Use a clean output directory and the repository's pinned Hugo version. Stop the draft server first.

```sh
hugo --gc --minify --cleanDestinationDir
python3 atlas/validate.py atlas/records
python3 atlas/lint_copy.py atlas/records
bash atlas/tests/run.sh
bash scripts/verify-build.sh
bash scripts/verify-fieldnotes-home.sh
bash scripts/verify-render.sh
bash scripts/verify-redirects.sh public
bash scripts/verify-proof-layer.sh public
bash scripts/verify-documentary-voice.sh
bash scripts/publish-gate.sh --no-build
git diff --check main...HEAD
```

A missing private denylist is a limitation, not a complete content-safety pass. Review record text, image and logo rights against atlas/PROVENANCE.md. Review the entire proposed diff and source/asset safety; no logs, private evidence, unapproved draft bodies or generated build output should be included. Reassess the historical provenance review on the integrated HEAD.

## 3. Release authorization

Record exact SHA, commands and results, browser evidence, unresolved issues and the owner's sign-off. Do not sign `.local-gate-passed` or merge until authorization is recorded. Coordinate via issues #14 and #18, then existing #5/#10/#11. Historical PR checks are not evidence on this revision.
