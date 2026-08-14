# Deploy migration runbook — gh-pages/docs → main + Actions

**Status:** prepared, NOT executed. Every step below is for Athan to run by hand.

**Why an agent did not run this:** overwriting a branch and repointing a live deploy are
irreversible and outward-facing. The workflows and the guard are committed; the switch is yours.

**What changes:** today `gh-pages` is the default branch, the source, *and* the published output —
every content change commits a regenerated `docs/` tree. After this, `main` is the source, GitHub
Actions builds and deploys, and `docs/` is never committed again.

**What is being abandoned:** `origin/main` currently holds the **Quartz / model-citizen** project —
`quartz.config.ts`, `package.json`, `quartz/`, its own `content/`. It is an entirely unrelated tree,
268 commits behind `gh-pages`. Athan has decided to retire model-citizen. Step 1 archives it before
anything overwrites it. Note that `docs/model-citizen/` is **not tracked in this repo**, so nothing
live here depends on that branch.

---

## Step 1 — Archive the Quartz tree before it is lost

Two independent copies: a pushed tag (survives on GitHub) and a local bundle (survives if the
remote is ever pruned). Do both.

```bash
cd /Users/adial/GitHub/athan-dial.github.io
git fetch origin

# 1a. Tag the current main and push the tag.
git tag -a archive/quartz-main origin/main \
  -m "Archive: Quartz model-citizen source, retired 2026-08-11 in favour of Hugo source on main"
git push origin archive/quartz-main
```

*Expected:* `* [new tag] archive/quartz-main -> archive/quartz-main`

```bash
# 1b. Bundle it locally.
mkdir -p ~/Github/_archive
git bundle create ~/Github/_archive/quartz-main.bundle origin/main
```

*Expected:* a progress count ending in `done`, and a file of roughly a few MB:

```bash
ls -lh ~/Github/_archive/quartz-main.bundle
```

```bash
# 1c. VERIFY THE BUNDLE RESTORES. Do not skip — an unverified backup is not a backup.
git bundle verify ~/Github/_archive/quartz-main.bundle
rm -rf /private/tmp/quartz-restore-test
git clone ~/Github/_archive/quartz-main.bundle /private/tmp/quartz-restore-test
ls /private/tmp/quartz-restore-test/quartz.config.ts
git -C /private/tmp/quartz-restore-test log --oneline -1
rm -rf /private/tmp/quartz-restore-test
```

*Expected:* `git bundle verify` prints `The bundle is okay`, the clone succeeds, `quartz.config.ts`
exists, and the log shows `c5a9b87 fix: upgrade GitHub Actions to non-deprecated versions`.

**Do not proceed past this step until 1c passes.**

---

## Step 2 — Optional: record the retirement in the vault

Not done automatically; nothing writes into the Obsidian vault from here.

Suggested note path:

```
$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new-icloud/200 Projects/
```

Worth recording: model-citizen is retired as of 2026-08-11; the Quartz source lives at tag
`archive/quartz-main` and `~/Github/_archive/quartz-main.bundle`; the Quartz site itself was served
from a separate repo, not from `docs/model-citizen/` in this one.

---

## Step 3 — Push the Hugo source to main

```bash
cd /Users/adial/GitHub/athan-dial.github.io

# 3a. PRE-FLIGHT: the archive tag must exist on the remote. This must print the tag.
git ls-remote --tags origin 'refs/tags/archive/quartz-main'
```

*Expected:* one line ending `refs/tags/archive/quartz-main`. **If it prints nothing, STOP and
redo Step 1.**

```bash
# 3b. Confirm the working tree is clean and you are on the branch you think you are.
git status --short
git rev-parse --abbrev-ref HEAD    # expect: gh-pages

# 3c. Force main to the current Hugo source.
git push --force origin gh-pages:main
```

*Expected:* `+ <old>...<new> gh-pages -> main (forced update)`

---

## Step 4 — Switch Pages to the Actions source

Web UI: **Settings → Pages → Build and deployment → Source → GitHub Actions**.

Equivalent CLI:

```bash
gh api -X PUT repos/athan-dial/athan-dial.github.io/pages \
  -f build_type=workflow
```

*Expected:* HTTP 204, no body. Verify:

```bash
gh api repos/athan-dial/athan-dial.github.io/pages --jq '.build_type, .html_url'
```

*Expected:* `workflow` and `https://athan-dial.github.io/`.

---

## Step 5 — Change the default branch

```bash
gh repo edit athan-dial/athan-dial.github.io --default-branch main
gh repo view athan-dial/athan-dial.github.io --json defaultBranchRef --jq '.defaultBranchRef.name'
```

*Expected:* `main`

Then repoint your local checkout:

```bash
git remote set-head origin -a
git branch -m gh-pages main 2>/dev/null || true
git branch --set-upstream-to=origin/main main
```

---

## Step 6 — Verification checklist

First watch the deploy actually run and go green:

```bash
gh run list --workflow=deploy.yml --limit 3
gh run watch
```

Then every one of these must return HTTP 200. The `/agency/` and `/skills/` entries are the ones
that matter most — they are static trees Hugo does not generate, and this is the check that proves
the artifact strategy in `deploy.yml` worked:

```bash
for p in / /about/ /advisory/ /consulting/ /agency/ \
         /agency/dispatches/autonomous-agents-need-a-foreman/ \
         /agency/playbooks/build-your-first-skill/ \
         /skills/ /resume.pdf /sitemap.xml; do
  printf '%-58s %s\n' "$p" "$(curl -s -o /dev/null -w '%{http_code}' "https://athan-dial.github.io$p")"
done
```

*Expected:* `200` on every line. A `404` on `/agency/...` means the published artifact lost the
static tree — roll back (Step 7) and fix `deploy.yml` before retrying.

---

## Step 7 — Rollback

The old serving path is untouched by any of the above: `gh-pages` still exists with its committed
`docs/` tree. To revert:

```bash
# 7a. Point Pages back at the branch.
gh api -X PUT repos/athan-dial/athan-dial.github.io/pages \
  -f build_type=legacy -f 'source[branch]=gh-pages' -f 'source[path]=/docs'

# 7b. Restore the default branch.
gh repo edit athan-dial/athan-dial.github.io --default-branch gh-pages

# 7c. Confirm.
gh api repos/athan-dial/athan-dial.github.io/pages --jq '.build_type, .source'
```

Re-run the Step 6 checklist afterwards. Nothing about the rollback needs the archive tag, and
`main` can be left as the Hugo source while you debug.

---

## Resolved 2026-08-14 — `publishDir` moved to `public/`, `docs/` is no longer committed

This section used to recommend **keeping** `publishDir = "docs"`. The reason was specific:
building into the committed publish dir was what preserved `docs/agency/**` and
`docs/skills/**` in the uploaded artifact, because Hugo does not prune files it did not
generate. Moving to a clean directory would have required copying both trees in by hand, with
a failure mode where a missed copy silently drops `/agency/` from the live site.

Both trees are now retired, so there is nothing left to preserve:

- `docs/agency/**` — retired 2026-08-12.
- `docs/skills/**` — retired 2026-08-14. The subsites were fetched from `athan-dial/skills`,
  which was deleted when the `dev` plugin moved into the private `claude-skills` repo as
  user-level `dev:*` skills. `scripts/fetch-skills.sh` ran unconditionally in `deploy.yml`
  under `set -euo pipefail`, so the next push to `main` would have failed the deploy.

What changed: `publishDir = "public"`, `/docs/` and `/public/` are both gitignored, the fetch
step is gone, and the artifact upload points at `public/`. The old narrow `.gitignore`
recommendation (`/docs/*` with `!/docs/agency/`) is void — `docs/agency/` was source-of-record
only until it was retired, and it is now redirect stubs generated from `data/redirects.toml`.

**Why committing the publish dir was worth ending.** Untracking it removed 174 tracked files
and three live defects that had accumulated precisely because Hugo never prunes: three
superseded fingerprinted CSS files still being served, an RSS feed at `/skills/` with
`http://localhost:1313` baked into it as the channel link, and `/skills/case-studies/` serving
a page whose own frontmatter says `draft: true`, `build.render: never`, "Hidden — placeholder
section, not yet populated." The content gate in `verify-build.sh` was right that the page was
not publishable; the committed artifact published it anyway.

`verify-build.sh` sections 2 and 3 now assert against the fresh build output rather than a
committed directory, and one new assertion fails the build if `docs/` ever becomes tracked
again.

Verified before pushing: clean build, `verify-build` PASS, all six redirect stubs generated,
and **0 of the 8 URLs in the live sitemap would 404**.

---

## Note on Step 1 — never executed

`archive/quartz-main` does not exist on the remote (`git ls-remote --tags origin` returns
nothing for it), and `gh-pages` is gone. Steps 3–5 clearly happened — `main` is the Hugo
source, Pages `build_type` is `workflow`, the default branch is `main` — but the archive tag
was skipped along the way.

The retired Quartz / model-citizen tree therefore survives in only two places, neither of them
on GitHub: the stale local `main` branch at `58a3c61` in this checkout, and
`~/Github/_archive/athan-dial.github.io-20260805.bundle`. If that tree still matters, push the
tag before anyone prunes the local branch. If it does not, delete the local `main` and say so
here.
