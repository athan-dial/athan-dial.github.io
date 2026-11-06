# Local gate: dev/atlas-integration (about 15 minutes)

Nothing from this branch goes to origin until you sign this. `.githooks/pre-push` refuses the push
unless `.local-gate-passed` holds the exact commit SHA being pushed. Any new commit voids the sign-off.

One-time per clone: `git config --local core.hooksPath .githooks`
Start from the worktree root. Restart your `hugo server` first (the Atlas mount in `module.toml` needs a restart; a running server shows an old page).

## 1. Look (hugo server, 5 min)
`hugo server -D` (restart it first), then open:
1. http://localhost:1313/ . Pass: homepage unchanged; only the nav gained "Atlas".
2. http://localhost:1313/atlas/ . Pass: 9 headed groups (Agent memory 14, Running agents together and safely 18, Data lineage and pipelines 4, Tools and directories for agents 12, Retrieval and knowledge graphs 12, Data and analytics agents 5, Agents that use computers and browsers 4, Research agents 4, Agent skills and harnesses 14), every card has an image tile (43 real images, 44 catalogue plates), a jump-link row, each group shows its first 6 cards with a "Show N more" dropdown, no broken images, "87 of 87 systems", an intro that says you read 16 projects and ran none, a legend, and a "Terms used here" disclosure (agent, MCP, knowledge graph, data lineage).
3. Type "lineage" in Search. Pass: matching systems only (all groups with matches expand), URL gains `?q=lineage`, "Clear search" restores all 87.
4. http://localhost:1313/atlas/sqlmesh--sqlmesh/ . Pass: breadcrumb, image with credit line and "View original image" link, citrus "My read" block, a "Use it when / Skip it when" line, "What I did not check", numbered "What the project says about itself" facts whose [n] jump to Sources, rail on the right.
5. http://localhost:1313/atlas/letta-ai--letta/ . Pass: a catalogue plate (topic, name, repo path, ghosted initial) instead of an image; no licence anywhere on the page.
6. Evidence: all 87 are "Read, not run". No record exists for Compared, Run or In use yet, so those cannot be seen.

## 2. Stress (3 min)
- 200% zoom (Cmd +) on /atlas/ and a record. Pass: no overlap, no sideways scroll.
- JavaScript off (DevTools, Disable JavaScript). Pass: all cards visible (collapsed groups open with their dropdown), filter controls hidden.
- Mobile 390px (DevTools device toolbar). Pass: no sideways scroll; the header nav (Work, Fieldnotes, Atlas, About) stays on one line.

## 3. Scripts (3 min)
```
python3 atlas/validate.py atlas/records     # pass: "87 valid, 0 invalid"
python3 atlas/lint_copy.py atlas/records    # pass: findings only on old records and 2 licence-in-fit lines (known)
bash atlas/tests/run.sh                     # pass: bad fixtures fail as expected, no unexpected PASS
bash scripts/verify-build.sh                # pass: ends "verify-build: PASS"
rm -rf public && hugo --gc --minify && bash scripts/publish-gate.sh   # pass: "9 pass, 0 fail"
bash scripts/verify-content-safety.sh       # pass is structural only: denylist is MISSING, see below
```
Content safety limit: `.planning/private/denylist.txt` does not exist here, so name-based scanning is off. A
"PASS" does not clear names. Skim the 71 new records once for private or employer content yourself.

## 4. Image provenance (3 min)
Open `atlas/PROVENANCE.md`. You decided to include every licence class and logos and banners, so you own the risk. The Claude Squad image (AGPL-3.0 repo) is already removed, and no AGPL repo has an image. 7 non-permissive or unstated licence rows are marked REVIEW (see PROVENANCE.md); you accepted the risk, so this is a keep-or-drop read, not a blocker; to drop one, delete its `[image]` table in the record. Pass: you are comfortable with each image, including logos (trademarked) on the permissive repos.

## 5. Review the diff (3 min)
`git diff --stat origin/main...HEAD` (about 250 files: atlas/, 11 images in assets/atlas/, out/ evidence, the site wiring; `out/` is local-only for now). Ask:
- Should `out/` (Hugo vs Astro evidence, audit) ship to a public repo? `.planning/` and `out/` are public once pushed.
- Any file you did not expect under `content/`, `data/`, `layouts/`?

## 6. Rebase check (already run, 1 min to repeat)
```
git worktree add --detach /tmp/rb-check HEAD && (cd /tmp/rb-check && git rebase origin/main); git worktree remove --force /tmp/rb-check
```
Last result (origin/main 3640e693, 2 commits ahead of merge base): clean, no conflicts.

## Decisions taken (2026-11-06)
- Candidate/reviewed label is not rendered. Records are treated as approved for the site; the TOML `status` field is unchanged.
- Images self-hosted from the READMEs, all licence classes (2026-11-06). See step 4.
- Atlas records are in the main `/index.xml` and the sitemap (about 46 feed items).
- `out/` stays committed on this branch and local only; decide before any push whether it ships to the public repo.

## Sign-off
Only after every pass above:
```
git rev-parse HEAD > .local-gate-passed
```
Gate passed by Athan: date ____ / commit SHA ____
