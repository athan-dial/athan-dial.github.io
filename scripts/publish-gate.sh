#!/usr/bin/env bash
# Publication gate for athan-dial.github.io.
#
# One command that answers "is this site publication worthy right now?" — the read side of
# .planning/GOAL-EOD-PUBLISH.md. Composes the four existing verify-*.sh guards and adds the
# publication-specific checks they do not cover (PII, dead internal links, unreachable pages,
# sitemap coverage).
#
# WHY A COMPOSITE EXISTS AT ALL:
#   The four guards were each run by hand, in whatever order the session remembered. One of
#   them (verify-redirects.sh) defaults to a build dir that no longer exists, so a hand-run
#   suite reported FAIL for a reason that had nothing to do with the site. A loop cannot
#   converge on a gate table it has to interpret. This prints one line per gate and exits
#   non-zero if any blocking gate fails.
#
# Usage:
#   bash scripts/publish-gate.sh          # build fresh, then check
#   bash scripts/publish-gate.sh --no-build
#
# No network. Safe to run repeatedly.
#
# G10 (viewport UAT), G11 (contrast) and G12 (docs current) are NOT checked here — they need a
# browser and a human read. They are listed as SKIP so the table stays honest about coverage.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

BUILD_DIR="public"
DO_BUILD=1
[[ "${1:-}" == "--no-build" ]] && DO_BUILD=0

PASS=0
FAIL=0
declare -a FAILED

ok()   { printf '  \033[32mPASS\033[0m  %-4s %s\n' "$1" "$2"; PASS=$((PASS+1)); }
bad()  { printf '  \033[31mFAIL\033[0m  %-4s %s\n' "$1" "$2"; FAIL=$((FAIL+1)); FAILED+=("$1"); }
skip() { printf '  \033[33mSKIP\033[0m  %-4s %s\n' "$1" "$2"; }

echo "publish-gate: athan-dial.github.io"
echo

# ---------------------------------------------------------------- G1  build
if [[ $DO_BUILD -eq 1 ]]; then
  BUILD_LOG=$(hugo 2>&1)
  if [[ $? -ne 0 ]]; then
    bad G1 "hugo exited non-zero"
    echo "$BUILD_LOG" | tail -20
  elif echo "$BUILD_LOG" | grep -q '^ERROR'; then
    bad G1 "hugo emitted ERROR lines"
    echo "$BUILD_LOG" | grep '^ERROR' | head -5
  else
    ok G1 "site builds clean"
  fi
else
  skip G1 "build skipped (--no-build)"
fi

[[ -d "$BUILD_DIR" ]] || { bad G1 "no build dir: $BUILD_DIR"; echo; echo "publish-gate: ABORT"; exit 1; }

# ---------------------------------------------------- G2/G3/G4  existing guards
run_guard() {
  local gate="$1" script="$2"; shift 2
  if [[ ! -x "$script" && ! -f "$script" ]]; then bad "$gate" "missing $script"; return; fi
  if out=$(bash "$script" "$@" 2>&1); then
    ok "$gate" "$(basename "$script") clean"
  else
    bad "$gate" "$(basename "$script") failed"
    echo "$out" | grep -iE 'fail|error' | head -5 | sed 's/^/        /'
  fi
}

run_guard G2 scripts/verify-build.sh
run_guard G3 scripts/verify-content-safety.sh
run_guard G4 scripts/verify-redirects.sh "$BUILD_DIR"

# ---------------------------------------------------------------- G5  no PII
# A phone number shipped for months inside a flattened PDF. Check the built HTML, any PDF
# that made it into the build, and assert the gitignored private tree never lands in output.
PII=0
if grep -rEoh '\(?[0-9]{3}\)?[-. ][0-9]{3}[-. ][0-9]{4}' "$BUILD_DIR" \
     --include='*.html' --include='*.xml' --include='*.json' 2>/dev/null | grep -q .; then
  PII=1
fi
if find "$BUILD_DIR" -iname '*.pdf' 2>/dev/null | grep -q .; then
  echo "        note: PDF(s) present in build — image-only PDFs are opaque, read them" >&2
  PII=1
fi
[[ -e "$BUILD_DIR/_private" ]] && PII=1
if [[ $PII -eq 0 ]]; then ok G5 "no phone patterns, no PDF, no private tree in build"
else bad G5 "possible PII in build output — inspect before publishing"; fi

# ------------------------------------------------- G6  no dead internal links
# Resolve every root-relative href/src against the build. Skips anchors, mailto, external,
# and query strings. A link to /foo/ resolves if public/foo/index.html exists.
DEAD=$(grep -rEoh '(href|src)="/[^"#?]*"' "$BUILD_DIR" --include='*.html' 2>/dev/null \
  | sed -E 's/^(href|src)="//; s/"$//' | sort -u | while read -r p; do
      [[ -z "$p" || "$p" == "/" ]] && continue
      t="${BUILD_DIR}${p}"
      [[ -e "$t" ]] && continue
      [[ -e "${t%/}/index.html" ]] && continue
      echo "$p"
    done)
if [[ -z "$DEAD" ]]; then ok G6 "every internal link resolves"
else
  bad G6 "$(echo "$DEAD" | wc -l | tr -d ' ') dead internal link target(s)"
  echo "$DEAD" | head -10 | sed 's/^/        /'
fi

# --------------------------------------------------- G8  every page reachable
# A built page nobody links to is a page no reader finds. Exclusions live in the goal doc;
# taxonomy shells and redirect stubs are structural, not orphans.
ALL_PAGES=$(cd "$BUILD_DIR" && find . -name index.html | sed 's|^\./||; s|index\.html$||; s|^|/|' | sort -u)
LINKED=$(grep -rEoh 'href="/[^"#?]*"' "$BUILD_DIR" --include='*.html' 2>/dev/null \
  | sed -E 's/^href="//; s/"$//' | sort -u)
UNREACHED=$(comm -23 <(echo "$ALL_PAGES") <(echo "$LINKED") \
  | grep -vE '^/(categories|tags|themes)/' | grep -v '^/$')
# Redirect stubs are reachable by inbound link only — they carry a refresh meta.
UNREACHED=$(echo "$UNREACHED" | while read -r p; do
      [[ -z "$p" ]] && continue
      grep -qi 'http-equiv="refresh"' "${BUILD_DIR}${p}index.html" 2>/dev/null && continue
      echo "$p"
    done)
if [[ -z "$UNREACHED" ]]; then ok G8 "no unreachable pages"
else
  bad G8 "$(echo "$UNREACHED" | wc -l | tr -d ' ') page(s) linked from nowhere"
  echo "$UNREACHED" | head -12 | sed 's/^/        /'
fi

# ---------------------------------------------------- G7  no orphan publish dir
if [[ $(git ls-files docs | wc -l | tr -d ' ') -ne 0 ]]; then
  bad G7 "docs/ is tracked again — build output must never be committed"
elif [[ -d docs ]] && find docs -name '*.html' 2>/dev/null | grep -q .; then
  bad G7 "docs/ holds stale HTML that GitHub Pages could still serve"
else
  ok G7 "no orphan publish dir"
fi

# ------------------------------------------------------- G9  sitemap coverage
if [[ ! -f "$BUILD_DIR/sitemap.xml" ]]; then
  bad G9 "no sitemap.xml"
else
  MAPPED=$(grep -oE '<loc>[^<]+</loc>' "$BUILD_DIR/sitemap.xml" \
    | sed -E 's|</?loc>||g; s|https?://[^/]+||' | sort -u)
  MISSING=$(comm -23 <(echo "$ALL_PAGES") <(echo "$MAPPED") \
    | grep -vE '^/(categories|tags)/' | while read -r p; do
        [[ -z "$p" ]] && continue
        grep -qi 'http-equiv="refresh"' "${BUILD_DIR}${p}index.html" 2>/dev/null && continue
        echo "$p"
      done)
  if [[ -z "$MISSING" ]]; then ok G9 "sitemap covers every built page"
  else
    bad G9 "$(echo "$MISSING" | wc -l | tr -d ' ') built page(s) absent from sitemap"
    echo "$MISSING" | head -12 | sed 's/^/        /'
  fi
fi

# -------------------------------------------------------- needs a human/browser
skip G10 "viewport UAT 800px + 1600px — run in-browser, keep screenshots"
skip G11 "contrast — re-measure in-browser only if colour changed"
skip G12 "CLAUDE.md / DESIGN.md currency — human read"

echo
printf 'publish-gate: %d pass, %d fail' "$PASS" "$FAIL"
[[ $FAIL -gt 0 ]] && printf ' → next: %s' "${FAILED[0]}"
echo
[[ $FAIL -eq 0 ]] && echo "publish-gate: automated gates GREEN — G10/G11/G12 and H1/H2 remain"
exit $(( FAIL > 0 ? 1 : 0 ))
