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

## Open question — `publishDir`

`hugo.toml` still sets `publishDir = "docs"`, and `deploy.yml` deliberately relies on it: building
into `docs/` is what preserves `docs/agency/**` and `docs/skills/**` in the uploaded artifact,
because Hugo does not prune files it did not generate.

**Recommendation: keep `publishDir = "docs"`.** Changing it to a clean directory would require
explicitly copying both static trees into the build output, adding a failure mode where a missed
copy silently drops `/agency/` from the live site. The current arrangement is uglier to read and
harder to break.

What *should* change once this migration is verified: `docs/` stops being committed. Add it to
`.gitignore` **only after** Step 6 passes, and in a separate commit, so the working state is easy
to bisect. Note that `docs/agency/**` must stay tracked — it is source-of-record, not build output.
So the correct `.gitignore` entry is narrow, not `/docs/`:

```
/docs/*
!/docs/agency/
```

Verify with `git status --short` that no generated page reappears as untracked noise before
committing that change.
