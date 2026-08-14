#!/usr/bin/env bash
# Build guard for athan-dial.github.io.
#
# Asserts that the site builds, that the static tree under docs/ is intact, that the
# retired Agency tree stays retired, and that nothing publishes past its gates.
# Safe to run repeatedly. No network access.
#
# WHY THE STATIC-TREE ASSERTION EXISTS:
#   docs/skills/** is not Hugo output. It is regenerable, but only via
#   scripts/fetch-skills.sh, which needs network + gh auth — so a clean build silently
#   drops it. docs/agency/** used to be a second such tree; it was retired 2026-08-12
#   and the check for it is now inverted (see section 2).
#
# Usage:
#   bash scripts/verify-build.sh
#
# Exit codes:
#   0  all assertions passed
#   1  hugo build failed
#   2  docs/agency tree damaged or missing
#   3  docs/skills tree damaged or missing
#   4  hugo not installed
#   5  content gate breached (an unsafe page would publish)
#   6  content safety violation (employer-confidential material in content/)
#   7  employer_review not cleared on a page that would publish

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
# 2 & 3. Retired static trees — /agency/ and the /skills/ plugin subsites.
#
# docs/ is no longer a committed tree. publishDir moved to public/ and docs/ is gitignored,
# so these assertions run against the FRESH BUILD OUTPUT ($BUILD_OUT), which is the thing the
# deploy actually uploads. Checking a committed directory could only ever tell you what was
# checked in, not what ships.
#
# What is being asserted, and why each was retired:
#   /agency/**  — RETIRED 2026-08-12. 127 files with no source anywhere; the dispatch notes
#                 were removed as off-subject and the playbooks, tag pages and diagrams went
#                 with them.
#   /skills/**  — RETIRED 2026-08-14. Plugin subsites fetched from athan-dial/skills, which
#                 was deleted when the dev plugin moved into the private claude-skills repo
#                 as user-level dev:* skills. Nothing can regenerate them.
#
# Both checks assert ABSENCE of real content, not absence of the path: data/redirects.toml
# generates meta-refresh stubs under both prefixes so external inbound links resolve instead
# of 404ing. A stub is allowed; a real page is not.
#
# /skills/case-studies/ is NOT retired — it is ordinary Hugo output from content/skills/.
# ---------------------------------------------------------------------------
assert_stubs_only() {
  local prefix="$1" label="$2" code="$3"
  local dir="$BUILD_OUT/$prefix"
  [ -d "$dir" ] || return 0

  local nonstub=""
  while IFS= read -r f; do
    grep -qi 'http-equiv=.\?refresh' "$f" || nonstub="$nonstub$f"$'\n'
  done < <(find "$dir" -type f -name '*.html' ! -path "$BUILD_OUT/skills/case-studies/*")
  if [ -n "$nonstub" ]; then
    printf 'verify-build: non-stub pages under /%s:\n%s\n' "$prefix" "$nonstub" >&2
    fail "$code" "/$prefix contains real pages — the retired $label site is back; it should be redirect stubs only"
  fi

  local assets
  assets="$(find "$dir" -type f ! -name '*.html' ! -path "$BUILD_OUT/skills/case-studies/*" | head -5)"
  if [ -n "$assets" ]; then
    printf 'verify-build: unexpected assets under /%s:\n%s\n' "$prefix" "$assets" >&2
    fail "$code" "/$prefix contains non-HTML assets — the retired $label site has been restored"
  fi
}

assert_stubs_only agency Agency 2
ok "/agency stays retired (redirect stubs only, no content)"

assert_stubs_only skills "plugin subsite" 3
ok "/skills plugin subsites stay retired (redirect stubs only, no content)"

# /skills/case-studies/ is NOT asserted present, and that is deliberate. It was live at 200
# until 2026-08-14 — but only because the old committed docs/ tree still held a copy from
# before the section was hidden. Both content/skills/_index.md and
# content/skills/case-studies/_index.md carry draft: true and build.render: never, and the
# latter describes itself as "Hidden — placeholder section, not yet populated." A clean build
# renders neither, which is what their frontmatter asks for.
#
# The content gate in section 4 never caught this: the gate is right that the page is not
# publishable. What published it was the committed artifact, not the build. Untracking docs/
# is what closes the hole, and this note exists so nobody "fixes" the resulting 404 by
# re-committing the page.

# docs/ must not come back as a committed tree. It is build output; committing it is how three
# superseded CSS fingerprints and a localhost-referencing RSS feed ended up served publicly.
DOCS_TRACKED="$(git ls-files docs | head -5)"
if [ -n "$DOCS_TRACKED" ]; then
  printf 'verify-build: tracked files under docs/:\n%s\n' "$DOCS_TRACKED" >&2
  fail 3 "docs/ has tracked files again — it is build output and must stay gitignored (publishDir is public/)"
fi
ok "docs/ stays untracked"

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

printf 'verify-build: PASS\n'
