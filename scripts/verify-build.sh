#!/usr/bin/env bash
# Build guard for athan-dial.github.io.
#
# Asserts that the site builds AND that the two irreplaceable static trees under docs/
# are still intact. Safe to run repeatedly. No network access.
#
# WHY THE STATIC-TREE ASSERTIONS EXIST:
#   docs/agency/** is 127 tracked files with NO SOURCE anywhere — not in this repo, not in
#   athan-dial/skills. A clean Hugo build does not regenerate it. `rm -rf docs/ && hugo`
#   (which CLAUDE.md documents as the rebuild command) destroys the live Agency site
#   permanently. docs/skills/** is regenerable, but only via scripts/fetch-skills.sh,
#   which needs network + gh auth.
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
# 2. docs/agency — irreplaceable, must be present and complete.
# ---------------------------------------------------------------------------
[ -f docs/agency/index.html ] || fail 2 "docs/agency/index.html is missing — the Agency site has been destroyed"

AGENCY_TRACKED="$(git ls-files docs/agency | wc -l | tr -d ' ')"
[ "$AGENCY_TRACKED" -gt 0 ] || fail 2 "no tracked files under docs/agency — expected ~127"

# Any tracked file under docs/agency that has been deleted from the working tree.
AGENCY_DELETED="$(git diff --name-only --diff-filter=D HEAD -- docs/agency | head -20)"
if [ -n "$AGENCY_DELETED" ]; then
  printf 'verify-build: deleted files under docs/agency:\n%s\n' "$AGENCY_DELETED" >&2
  fail 2 "tracked files under docs/agency have been deleted — revert with: git checkout -- docs/agency"
fi
ok "docs/agency intact ($AGENCY_TRACKED tracked files, none deleted)"

# ---------------------------------------------------------------------------
# 3. docs/skills — regenerable via fetch-skills.sh, but must not be silently gone.
# ---------------------------------------------------------------------------
[ -d docs/skills ] || fail 3 "docs/skills/ is missing — regenerate with: bash scripts/fetch-skills.sh"

SKILLS_ENTRIES="$(find docs/skills -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')"
[ "$SKILLS_ENTRIES" -gt 0 ] || fail 3 "docs/skills/ is empty — regenerate with: bash scripts/fetch-skills.sh"

SKILLS_DELETED="$(git diff --name-only --diff-filter=D HEAD -- docs/skills | head -20)"
if [ -n "$SKILLS_DELETED" ]; then
  printf 'verify-build: deleted files under docs/skills:\n%s\n' "$SKILLS_DELETED" >&2
  fail 3 "tracked files under docs/skills have been deleted — regenerate with: bash scripts/fetch-skills.sh"
fi
ok "docs/skills intact ($SKILLS_ENTRIES plugin subsites, none deleted)"

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
