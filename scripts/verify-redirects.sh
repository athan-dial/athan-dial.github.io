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
#    Agency playbooks / dispatches index live in the committed docs/ tree (Hugo
#    does not regenerate them into a throwaway destination). Confirm they still
#    exist under docs/, and that this build did not emit a colliding stub there.
# ---------------------------------------------------------------------------
for rel in \
  "agency/playbooks/build-your-first-skill/index.html" \
  "agency/dispatches/index.html"
do
  [ -f "$REPO_ROOT/docs/$rel" ] || fail "must-not-break missing in docs/: /$rel"
  if [ -f "$BUILD_DIR/$rel" ]; then
    fail "build emitted $rel — would overwrite committed docs/$rel"
  fi
  ok "protected /$rel (present in docs/, absent from build)"
done

# /skills/ is the committed docs/skills/** plugin tree (not Hugo content). A
# throwaway destination will not contain it; assert the source-of-record exists
# and the build did not emit a colliding /skills/index.html stub.
[ -d "$REPO_ROOT/docs/skills" ] || fail "must-not-break missing in docs/: /skills/"
if [ -f "$BUILD_DIR/skills/index.html" ]; then
  fail "build emitted skills/index.html — would overwrite committed docs/skills/"
fi
ok "protected /skills/ (present in docs/, no colliding build stub)"

for rel in "resume.pdf" "about/index.html"; do
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
  [ -z "$unexpected" ] || fail "build generated unexpected agency path(s): ${unexpected}(would shadow docs/agency)"
  ok "agency build output limited to redirect map entries"
fi

printf 'verify-redirects: PASS\n'
