#!/usr/bin/env bash
# Build guard for athan-dial.github.io.
#
# Asserts that the site builds, that the static tree under docs/ is intact, that the
# retired Agency tree stays retired, and that nothing publishes past its gates.
# Safe to run repeatedly. No network access.
#
# WHY THE STATIC-TREE ASSERTIONS ARE ALL INVERTED NOW:
#   docs/ once held two trees Hugo does not generate. docs/agency/** was retired 2026-08-12,
#   and the fetched docs/skills/** plugin subsites were retired 2026-08-14 when
#   athan-dial/skills was deleted and scripts/fetch-skills.sh went with it. Both checks
#   assert absence rather than presence (sections 2 and 3), so a stale build or a restore
#   from a backup bundle cannot quietly republish either. /skills/case-studies/ is ordinary
#   Hugo output and is still asserted present.
#
# Usage:
#   bash scripts/verify-build.sh
#
# Exit codes:
#   0  all assertions passed
#   1  hugo build failed
#   2  docs/agency tree damaged or missing
#   3  retired docs/skills plugin subsite republished, or case-studies missing
#   4  hugo not installed
#   5  content gate breached (an unsafe page would publish)
#   6  content safety violation (employer-confidential material in content/)
#   7  employer_review not cleared on a page that would publish
#   8  render-HTML assertion failed (what the reader receives)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || exit 1

fail() {
  local code="$1"; shift
  printf 'verify-build: FAIL — %s\n' "$*" >&2
  exit "$code"
}

ok() { printf 'verify-build:   ok — %s\n' "$*"; }

command -v hugo >/dev/null 2>&1 || fail 4 "hugo is not installed or not on PATH"

# ---------------------------------------------------------------------------
# 1. The site must build. Build to a throwaway dir so docs/ is never touched.
# ---------------------------------------------------------------------------
BUILD_OUT="$(mktemp -d)"
trap 'rm -rf "$BUILD_OUT"' EXIT

if ! BUILD_LOG="$(hugo --gc --destination "$BUILD_OUT" 2>&1)"; then
  printf '%s\n' "$BUILD_LOG" >&2
  fail 1 "hugo build failed (see output above)"
fi
ok "hugo build succeeded (throwaway dir, docs/ untouched)"

if printf '%s' "$BUILD_LOG" | grep -q 'deprecated'; then
  printf 'verify-build: warn — build emitted deprecation warnings:\n' >&2
  printf '%s\n' "$BUILD_LOG" | grep 'deprecated' >&2
fi

# ---------------------------------------------------------------------------
# 2. docs/agency — RETIRED 2026-08-12, deliberately. Assert it stays gone.
#
# This slot used to assert the opposite: that 127 tracked files under docs/agency were
# present, because they had no source anywhere and a clean build would destroy them.
# The tree was retired by owner decision — the dispatch notes were removed as
# off-subject, and the playbooks, tag pages and diagrams went with them.
#
# The check is inverted rather than deleted so a stale build output, a bad merge, or a
# restore from a backup bundle cannot quietly republish the retired site. The Agency
# URLs still resolve: data/redirects.toml generates meta-refresh stubs for /agency/,
# /agency/dispatches/, /agency/playbooks/ and the seven dispatch slugs, so external
# inbound links land on /thinking/ instead of 404ing.
#
# If the tree is ever intentionally brought back, replace this block with the
# presence assertions from git history (see the commit that retired it).
# ---------------------------------------------------------------------------
# Check SHAPE, not tracking. An earlier version of this asserted zero tracked files under
# docs/agency, which failed in CI for a boring reason: docs/ is the committed publish dir,
# so the redirect stubs Hugo generates there are necessarily tracked too. The stubs are
# supposed to exist. What must not come back is the retired *content*.
if [ -d docs/agency ]; then
  # Every surviving file must be a meta-refresh stub. Real pages carry a stylesheet link.
  AGENCY_NONSTUB=""
  while IFS= read -r f; do
    grep -qi 'http-equiv=.\?refresh' "$f" || AGENCY_NONSTUB="$AGENCY_NONSTUB$f"$'\n'
  done < <(find docs/agency -type f -name '*.html')
  if [ -n "$AGENCY_NONSTUB" ]; then
    printf 'verify-build: non-stub pages under docs/agency:\n%s\n' "$AGENCY_NONSTUB" >&2
    fail 2 "docs/agency contains real pages — the retired Agency site is back; it should be redirect stubs only"
  fi

  # The retired subtrees must not reappear with content in them.
  for sub in playbooks tags diagrams; do
    n="$(find "docs/agency/$sub" -type f 2>/dev/null | wc -l | tr -d ' ')"
    if [ "$n" -gt 1 ]; then
      fail 2 "docs/agency/$sub has $n files — the retired Agency $sub tree is back (expected at most one redirect stub)"
    fi
  done

  # Any non-HTML asset means the old site's CSS/JS/images were restored.
  AGENCY_ASSETS="$(find docs/agency -type f ! -name '*.html' | head -5)"
  if [ -n "$AGENCY_ASSETS" ]; then
    printf 'verify-build: unexpected assets under docs/agency:\n%s\n' "$AGENCY_ASSETS" >&2
    fail 2 "docs/agency contains non-HTML assets — the retired Agency site has been restored"
  fi
fi
ok "docs/agency stays retired (redirect stubs only, no content)"

# ---------------------------------------------------------------------------
# 3. docs/skills plugin subsites — RETIRED 2026-08-14, deliberately. Assert they stay gone.
#
# This slot used to assert the opposite: that the fetched subsites were PRESENT, because a
# clean build would silently drop them (they were not Hugo output, and only
# scripts/fetch-skills.sh could regenerate them — needing network plus gh auth).
#
# The source is gone. The dev plugin moved into the private claude-skills repo as user-level
# dev:* skills, athan-dial/skills was deleted, and fetch-skills.sh went with it. Nothing can
# regenerate these trees, so asserting their presence would fail every build from now on.
#
# Inverted rather than deleted, for the same reason as docs/agency above: a stale build
# output, a bad merge, or a restore from the backup bundle must not quietly republish plugin
# docs for a repo that no longer exists. The URLs still resolve — data/redirects.toml
# generates meta-refresh stubs for /skills/, /skills/orc/ and /skills/folio/.
#
# /skills/case-studies/ is NOT retired. It is ordinary Hugo output from content/skills/
# and must keep building.
# ---------------------------------------------------------------------------
RETIRED_SKILLS_TREES="orc folio _template"
if [ -d docs/skills ]; then
  for sub in $RETIRED_SKILLS_TREES; do
    [ -d "docs/skills/$sub" ] || continue
    # Any surviving file must be a meta-refresh stub. Real pages carry a stylesheet link.
    NONSTUB=""
    while IFS= read -r f; do
      grep -qi 'http-equiv=.\?refresh' "$f" || NONSTUB="$NONSTUB$f"$'\n'
    done < <(find "docs/skills/$sub" -type f -name '*.html')
    if [ -n "$NONSTUB" ]; then
      printf 'verify-build: non-stub pages under docs/skills/%s:\n%s\n' "$sub" "$NONSTUB" >&2
      fail 3 "docs/skills/$sub contains real pages — a retired plugin subsite is back; it should be redirect stubs only"
    fi
    # Any non-HTML asset means the fetched bundle's CSS/JS/search index was restored.
    ASSETS="$(find "docs/skills/$sub" -type f ! -name '*.html' | head -5)"
    if [ -n "$ASSETS" ]; then
      printf 'verify-build: unexpected assets under docs/skills/%s:\n%s\n' "$sub" "$ASSETS" >&2
      fail 3 "docs/skills/$sub contains non-HTML assets — a retired plugin subsite has been restored"
    fi
  done
fi
ok "docs/skills plugin subsites stay retired (redirect stubs only, no content)"

# /skills/case-studies/ is live Hugo output and must not vanish with them.
[ -d docs/skills/case-studies ] || fail 3 "docs/skills/case-studies/ is missing — it is Hugo output from content/skills/case-studies/, not a retired tree"
ok "docs/skills/case-studies intact"

# ---------------------------------------------------------------------------
# 4. Content gate — status/visibility must agree with draft.
#
# hugo.toml gates publication on `buildDrafts = false` plus a convention: anything
# not (status: published AND visibility: public) keeps `draft: true`. Section
# cascades set that default, but an explicit `draft: false` in a page's own
# frontmatter OVERRIDES the cascade — so one wrong field silently publishes private
# content and lists it in the sitemap. Verified failure, 2026-08-11.
#
# The plan requires that such a page produce no output at all, so this is enforced
# here rather than trusted: the build refuses instead of publishing.
# ---------------------------------------------------------------------------
GATE_VIOLATIONS="$(
  python3 - <<'PY'
import glob, os, re, sys

bad = []
for path in glob.glob("content/**/*.md", recursive=True):
    with open(path, encoding="utf-8") as fh:
        text = fh.read()
    m = re.match(r"^---\n(.*?)\n---", text, re.S)
    if not m:
        continue
    fm = m.group(1)

    def field(name):
        f = re.search(rf"^{name}:\s*(\S+)", fm, re.M)
        return f.group(1).strip().strip("\"'").lower() if f else None

    status, visibility, draft = field("status"), field("visibility"), field("draft")
    # Only pages that declare the new content-model fields are in scope.
    if status is None and visibility is None:
        continue
    unsafe = (status not in (None, "published")) or (visibility not in (None, "public"))
    if unsafe and draft != "true":
        bad.append(f"{path}: status={status} visibility={visibility} draft={draft}")

print("\n".join(bad))
PY
)"

if [ -n "$GATE_VIOLATIONS" ]; then
  printf 'verify-build: content-gate violations (unsafe status/visibility without draft: true):\n' >&2
  printf '%s\n' "$GATE_VIOLATIONS" >&2
  fail 5 "content gate breached — these pages would publish. Set draft: true, or promote to status: published + visibility: public."
fi

# ---------------------------------------------------------------------------
# 4b. Employer review gate — employer_review must be cleared before a work page ships.
#
# The work/ cascade sets `employer_review: pending`. Until 2026-08-12 NOTHING read that
# field: it looked like a gate and was decoration, so flipping the three publication
# fields would ship an unreviewed page describing the employer's internal work. This
# makes the field real.
#
# Scope: only pages that declare employer_review. Essays and notes do not carry it.
#
# Accepted values, and what each MEANS -- the distinction is the point:
#   cleared        a human at the employer reviewed and signed off.
#   self-cleared   Athan judged it safe himself. No employer review happened. Valid for
#                  pages that name no employer, program, or figure and pass the safety
#                  scan, which is the bar the content-safety contract sets.
#   n/a            the page describes no employer work.
#   not-required   explicitly exempted.
# Anything else (notably `pending`) blocks publication.
# ---------------------------------------------------------------------------
REVIEW_VIOLATIONS="$(
  python3 - <<'PY_REVIEW'
import glob, re

CLEARED = {"cleared", "self-cleared", "n/a", "not-required"}
bad = []
for path in glob.glob("content/**/*.md", recursive=True):
    with open(path, encoding="utf-8") as fh:
        text = fh.read()
    m = re.match(r"^---\n(.*?)\n---", text, re.S)
    if not m:
        continue
    fm = m.group(1)

    def field(name):
        f = re.search(rf"^{name}:\s*(\S+)", fm, re.M)
        return f.group(1).strip().strip("\"'").lower() if f else None

    review = field("employer_review")
    if review is None:
        continue  # not in scope
    status, visibility, draft = field("status"), field("visibility"), field("draft")
    would_publish = status == "published" and visibility == "public" and draft == "false"
    if would_publish and review not in CLEARED:
        bad.append(f"{path}: employer_review={review}")

print("\n".join(bad))
PY_REVIEW
)"

if [ -n "$REVIEW_VIOLATIONS" ]; then
  printf 'verify-build: pages that would publish without employer review:\n' >&2
  printf '%s\n' "$REVIEW_VIOLATIONS" >&2
  fail 7 "employer_review not cleared — set employer_review: cleared once a human at the employer has signed off, or keep the page unpublished."
fi
ok "employer review gate holds (no unreviewed page would publish)"

ok "content gate holds (no unsafe page is publishable)"

# ---------------------------------------------------------------------------
# 5. Content safety — nothing employer-confidential in content/.
#
# THIS REPO IS PUBLIC. Delegated to scripts/verify-content-safety.sh, which reads its
# denied-term list at runtime from a gitignored file (a denylist of real names committed
# to a public repo would leak what it defends). That script warns loudly and passes if the
# private list is missing, so a fresh clone still builds.
# ---------------------------------------------------------------------------
if [ -x scripts/verify-content-safety.sh ] || [ -f scripts/verify-content-safety.sh ]; then
  if ! SAFETY_OUT="$(bash scripts/verify-content-safety.sh 2>&1)"; then
    printf '%s\n' "$SAFETY_OUT" >&2
    fail 6 "content safety violations — see above. Reword the prose; do not weaken the denylist."
  fi
  printf '%s\n' "$SAFETY_OUT" | grep -E 'WARNING|scanned' >&2 || true
  ok "content safety scan clean"
else
  printf 'verify-build: warn — scripts/verify-content-safety.sh missing; content not scanned\n' >&2
fi

# ---------------------------------------------------------------------------
# 6. Render-HTML assertions — what the reader receives, not that Hugo compiled.
#
# Delegated to scripts/verify-render.sh. verify-build.sh never inspected rendered
# HTML; that gap shipped duplicated OG tags, a never-rendered case outline,
# homepage placeholders, a removed evidence label still printing, and essay/note
# pages with no active nav — all on a green build. Warn-but-pass if the
# sub-script is missing so a partial checkout still builds.
# ---------------------------------------------------------------------------
if [ -x scripts/verify-render.sh ] || [ -f scripts/verify-render.sh ]; then
  if ! RENDER_OUT="$(bash scripts/verify-render.sh 2>&1)"; then
    printf '%s\n' "$RENDER_OUT" >&2
    fail 8 "render-HTML assertions failed — see above. Fix the template or content; do not weaken the check."
  fi
  printf '%s\n' "$RENDER_OUT" | grep -E 'verify-render: (  ok|PASS)' || true
  ok "render-HTML assertions clean"
else
  printf 'verify-build: warn — scripts/verify-render.sh missing; rendered HTML not checked\n' >&2
fi

printf 'verify-build: PASS\n'
