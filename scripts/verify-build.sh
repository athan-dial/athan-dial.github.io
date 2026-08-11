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

printf 'verify-build: PASS\n'
