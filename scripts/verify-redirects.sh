#!/usr/bin/env bash
# Assert redirect stubs from data/redirects.toml exist in a built site directory,
# and that must-not-break paths remain intact.
#
# Usage:
#   bash scripts/verify-redirects.sh [/path/to/build]
#
# Default build dir: /private/tmp/hugo-guard
#
# Exit non-zero on the first failure, naming it.
# No network.

set -eu

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${1:-/private/tmp/hugo-guard}"
REDIRECTS_TOML="$REPO_ROOT/data/redirects.toml"

fail() {
  printf 'verify-redirects: FAIL — %s\n' "$*" >&2
  exit 1
}

ok() { printf 'verify-redirects:   ok — %s\n' "$*"; }

[ -d "$BUILD_DIR" ] || fail "build directory not found: $BUILD_DIR"
[ -f "$REDIRECTS_TOML" ] || fail "missing $REDIRECTS_TOML"

# ---------------------------------------------------------------------------
# 1. Every redirects.toml source resolves to a stub containing the target.
# ---------------------------------------------------------------------------
REDIRECT_LINES="$(
  python3 - "$REDIRECTS_TOML" <<'PY'
import re, sys
from pathlib import Path
text = Path(sys.argv[1]).read_text(encoding="utf-8")
blocks = re.split(r"\n\s*\[\[redirects\]\]\s*\n", text)
if len(blocks) <= 1:
    sys.exit("no [[redirects]] tables found")
for block in blocks[1:]:
    frm = re.search(r'^\s*from\s*=\s*"([^"]+)"', block, re.M)
    to = re.search(r'^\s*to\s*=\s*"([^"]+)"', block, re.M)
    if not frm or not to:
        sys.exit("redirect block missing from/to")
    print(f"{frm.group(1)}\t{to.group(1)}")
PY
)" || fail "could not parse data/redirects.toml"

[ -n "$REDIRECT_LINES" ] || fail "data/redirects.toml has no redirects"

printf '%s\n' "$REDIRECT_LINES" | while IFS="$(printf '\t')" read -r from to; do
  [ -n "$from" ] || continue
  rel="${from#/}"
  rel="${rel%/}"
  [ -n "$rel" ] || fail "refusing to treat site root as a redirect source"
  stub="$BUILD_DIR/$rel/index.html"
  [ -f "$stub" ] || fail "missing redirect stub for ${from} (expected $stub)"
  if ! grep -q -F "$to" "$stub"; then
    fail "redirect stub for ${from} does not contain target ${to}"
  fi
  ok "${from} -> ${to}"
done

# Re-check in the main shell: a failing while-pipeline can be masked by pipefail
# quirks on macOS bash 3. Count stubs explicitly.
EXPECTED="$(printf '%s\n' "$REDIRECT_LINES" | awk 'NF{c++} END{print c+0}')"
FOUND=0
MISSING=""
while IFS="$(printf '\t')" read -r from to; do
  [ -n "$from" ] || continue
  rel="${from#/}"
  rel="${rel%/}"
  stub="$BUILD_DIR/$rel/index.html"
  if [ -f "$stub" ] && grep -q -F "$to" "$stub"; then
    FOUND=$((FOUND + 1))
  else
    MISSING="${MISSING}${from} "
  fi
done <<EOF
$REDIRECT_LINES
EOF

[ "$FOUND" -eq "$EXPECTED" ] || fail "redirect stubs incomplete (found $FOUND/$EXPECTED). Missing: ${MISSING:-unknown}"

# ---------------------------------------------------------------------------
# 2. Must-not-break paths.
#
#    Retired 2026-08-14 (was: assert docs/agency/playbooks/build-your-first-skill/
#    and docs/agency/dispatches/ still exist in a committed docs/ tree, plus a
#    docs/skills/ check below it). Both targets are gone, on purpose, for two
#    independent reasons:
#      1. docs/agency/** (127 files) was deliberately retired in d8e83376
#         (2026-08-12) — "retire the Agency tree and purge 69 orphaned pages".
#         That commit itself deleted docs/agency/playbooks/build-your-first-skill/
#         index.html. Individual playbook slugs were never re-added as redirect
#         stubs — only /agency/, /agency/dispatches/, /agency/playbooks/ (the
#         index pages) and the seven migrated dispatch slugs were, per
#         data/redirects.toml. content/_content.gotmpl:13 confirms this is
#         intentional: "playbooks and other Agency deep links are not
#         generated." /agency/playbooks/ builds as an empty list page by design.
#      2. docs/skills/** (the fetched plugin subsites) was separately retired
#         2026-08-14 — see the /skills/* redirect stubs in data/redirects.toml.
#    Both checks also hardcoded "docs/" regardless of the $BUILD_DIR argument,
#    which is doubly moot now: publishDir moved docs/ -> public/ on 2026-08-14
#    and docs/ no longer exists in this repo at all. Asserting a deleted path
#    exists in a renamed, nonexistent directory was never going to pass; it was
#    dismissible as "stale path" instead of a real regression. Nothing here
#    protects the retired trees going forward — that job belongs to
#    verify-build.sh's inverted exit-code-2 check, which asserts they stay gone.
# ---------------------------------------------------------------------------

# resume.pdf dropped from this list 2026-08-14: this check (c6cf9bdd, 2026-08-11)
# predates 61597158 "security: pull the resume PDF" (2026-08-12), the deliberate
# fix for the flattened-Canva-PDF phone-number leak (CLAUDE.md hard constraint 1).
# data/profile.toml:36-39 explicitly forbids reintroducing a resume_pdf key —
# asserting the PDF must be present in every build fights that decision and
# would only ever pass by accident (or force someone to undo the security fix
# to turn this gate green). /resume/ itself stays unpublished (draft: true,
# build.render: never) so there is no page to link a PDF from either.
for rel in "about/index.html"; do
  if [ -e "$BUILD_DIR/$rel" ]; then
    ok "must-not-break present in build: /$rel"
  else
    fail "must-not-break missing in build: /$rel"
  fi
done

# ---------------------------------------------------------------------------
# 3. Agency collision audit — only allowed generated agency paths are stubs
#    listed in redirects.toml (no playbooks, no dispatches index, no RSS).
# ---------------------------------------------------------------------------
if [ -d "$BUILD_DIR/agency" ]; then
  allowed="$(
    python3 - "$REDIRECTS_TOML" <<'PY'
import re, sys
from pathlib import Path
text = Path(sys.argv[1]).read_text(encoding="utf-8")
for block in re.split(r"\n\s*\[\[redirects\]\]\s*\n", text)[1:]:
    frm = re.search(r'^\s*from\s*=\s*"([^"]+)"', block, re.M)
    if not frm:
        continue
    path = frm.group(1).strip("/")
    if path == "agency" or path.startswith("agency/"):
        print(f"{path}/index.html")
PY
  )"
  unexpected=""
  while IFS= read -r generated; do
    [ -n "$generated" ] || continue
    rel="${generated#"$BUILD_DIR/"}"
    if ! printf '%s\n' "$allowed" | grep -qx "$rel"; then
      unexpected="${unexpected}/${rel} "
    fi
  done <<EOF
$(find "$BUILD_DIR/agency" -type f)
EOF
  [ -z "$unexpected" ] || fail "build generated unexpected agency path(s): ${unexpected}(not in the retired-agency redirect map)"
  ok "agency build output limited to redirect map entries"
fi

printf 'verify-redirects: PASS\n'
