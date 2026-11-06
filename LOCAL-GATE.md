# Local gate: dev/atlas-integration (about 15 minutes)

Nothing from this branch goes to origin until you sign this. `.githooks/pre-push` refuses the push
unless `.local-gate-passed` holds the exact commit SHA being pushed. Any new commit voids the sign-off.

One-time per clone: `git config --local core.hooksPath .githooks`
Start from the worktree root. Restart your `hugo server` first (the Atlas mount in `module.toml` needs a restart; a running server shows an old page).

## 1. Look (hugo server, 5 min)
`hugo server -D` then open:
1. http://localhost:1313/ . Pass: homepage looks the same as main; only the nav gained "Atlas".
2. http://localhost:1313/atlas/ . Pass: "16 of 16 records", Topic/Evidence filters and search narrow the list.
3. http://localhost:1313/atlas/mem0ai--mem0/ . Pass: repo link, license, limitations, facts, sources render.
4. A record with `NOASSERTION` license: /atlas/mksglu--context-mode/ . Pass: license shows NOASSERTION, nothing blank.
5. Evidence states: all 16 records are `inspected`. No record exists for evaluated, tested or adopted, so those states cannot be eyeballed yet. Pass: the filter lists only "inspected".
6. Nav "Atlas" link is current-page highlighted on /atlas/ and record pages.

## 2. Stress (3 min)
- 200% zoom (Cmd +) on /atlas/ and a record. Pass: no overlap, no sideways scroll.
- JavaScript off (DevTools, Disable JavaScript). Pass: all 16 cards visible, filter controls hidden.
- Mobile 390px (DevTools device toolbar). Pass: no sideways scroll; the nav wraps to two lines (known, matches the rest of the site).

## 3. Scripts (3 min)
```
python3 atlas/validate.py atlas/records     # pass: "16 valid, 0 invalid"
bash atlas/tests/run.sh                     # pass: bad fixtures fail as expected, no unexpected PASS
bash scripts/verify-build.sh                # pass: ends "verify-build: PASS"
rm -rf public && hugo --gc --minify && bash scripts/publish-gate.sh   # pass: "9 pass, 0 fail"
bash scripts/verify-content-safety.sh       # pass is structural only: denylist is MISSING, see below
```
Content safety limit: `.planning/private/denylist.txt` does not exist here, so name-based scanning is off. A
"PASS" does not clear names. Read the 16 records once for private or employer content yourself.

## 4. Review the diff (3 min)
`git diff --stat origin/main...HEAD` (about 90 files: atlas/, out/ evidence, the site wiring; `out/` is local-only for now). Ask:
- Should `out/` (Hugo vs Astro evidence, audit) ship to a public repo? `.planning/` and `out/` are public once pushed.
- Any file you did not expect under `content/`, `data/`, `layouts/`?

## 5. Rebase check (already run, 1 min to repeat)
```
git worktree add --detach /tmp/rb-check HEAD && (cd /tmp/rb-check && git rebase origin/main); git worktree remove --force /tmp/rb-check
```
Last result (origin/main 3640e693, 2 commits ahead of merge base): clean, no conflicts.

## Decisions taken (2026-11-06)
- Candidate/reviewed label is not rendered. Records are treated as approved for the site; the TOML `status` field is unchanged.
- Atlas records are in the main `/index.xml` and the sitemap (about 46 feed items).
- `out/` stays committed on this branch and local only; decide before any push whether it ships to the public repo.

## Sign-off
Only after every pass above:
```
git rev-parse HEAD > .local-gate-passed
```
Gate passed by Athan: date ____ / commit SHA ____
