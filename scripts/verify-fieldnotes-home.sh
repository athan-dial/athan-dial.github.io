#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() { printf 'verify-fieldnotes-home: FAIL - %s\n' "$*" >&2; exit 1; }
ok() { printf 'verify-fieldnotes-home: ok - %s\n' "$*"; }

INDEX="layouts/index.html"
PROFILE="data/profile.toml"
BASE="layouts/_default/baseof.html"
CSS="assets/css/fieldnotes-home.css"
JS="assets/js/fieldnotes-home.js"

for f in "$INDEX" "$PROFILE" "$BASE" "$CSS" "$JS"; do
  [ -f "$f" ] || fail "missing required file: $f"
done

EXPECTED_HEADLINE='I build AI and data products for people whose work depends on judgment.'
grep -Fq "$EXPECTED_HEADLINE" "$PROFILE" || fail "canonical homepage headline missing from profile data"
if grep -Fq 'Try things. Keep what works.' "$INDEX" "$PROFILE"; then
  fail "retired generic hero slogan still present in homepage source"
fi
ok "canonical expert-work headline replaces retired slogan"

python3 - "$INDEX" <<'PY'
import pathlib, re, sys
text = pathlib.Path(sys.argv[1]).read_text()
ids = [
    "identity",
    "current-idea",
    "work-in-practice",
    "fieldnotes",
    "trajectory",
    "operating-territory",
    "context",
]
pos = []
for item in ids:
    m = re.search(r'id=["\']%s["\']' % re.escape(item), text)
    if not m:
        raise SystemExit("missing chapter id: " + item)
    pos.append(m.start())
if pos != sorted(pos):
    raise SystemExit("homepage chapters are out of canonical order")
for item in ids:
    if ('href="#%s"' % item) not in text:
        raise SystemExit("chapter index missing link to #%s" % item)
if 'data-fn-chapter' not in text or 'data-fn-index-link' not in text:
    raise SystemExit("progressive chapter hooks are missing")
if '.summary' in text.lower() and 'experience' in text.lower():
    # Guard against casually wiring legacy experience prose into the homepage.
    # A false positive here is preferable to silently publishing unsupported summary text.
    raise SystemExit("homepage source appears to reference experience summary prose")
print("ok")
PY
ok "seven chapters and marginal-index anchors are present in canonical order"

grep -Fq 'site.Data.experience' "$INDEX" || fail "trajectory does not consume canonical experience data"
grep -Fq '.role' "$INDEX" || fail "trajectory role field missing"
grep -Fq '.company' "$INDEX" || fail "trajectory company field missing"
grep -Fq '.range' "$INDEX" || fail "trajectory range field missing"
grep -Fq 'foundation' "$INDEX" || fail "trajectory foundation field missing"
ok "trajectory is wired to safe role/company/range plus foundation fields"

grep -Fq 'abundant-execution' "$INDEX" || fail "operating-territory schematic is not wired"
grep -Fq 'IntersectionObserver' "$JS" || fail "progressive chapter observer missing"
grep -Fq 'aria-current' "$JS" || fail "current-location enhancement missing"
grep -Fq 'prefers-reduced-motion:reduce' "$CSS" || fail "home motion layer lacks reduced-motion override"
if grep -Eq 'opacity:[[:space:]]*0([^.]|$)' "$CSS"; then
  fail "home motion layer hides content with opacity:0; motion must never gate visibility"
fi
ok "progressive enhancement and non-gating reduced-motion contract present"

grep -Fq 'resources.Get "js/fieldnotes-home.js"' "$BASE" || fail "home script is not fingerprinted through Hugo Pipes"
grep -Fq 'defer' "$BASE" || fail "home script is not deferred"
ok "home-only script is bundled through Hugo"

if [ -f public/index.html ]; then
  HTML="public/index.html"
  for item in identity current-idea work-in-practice fieldnotes trajectory operating-territory context; do
    grep -Fq "id=\"$item\"" "$HTML" || fail "built homepage missing #$item"
  done
  grep -Fq "$EXPECTED_HEADLINE" "$HTML" || fail "built homepage missing canonical headline"
  if grep -Fq 'Try things. Keep what works.' "$HTML"; then
    fail "built homepage still contains retired slogan"
  fi
  ok "built homepage matches v2 chapter and headline contract"
else
  printf 'verify-fieldnotes-home: note - public/index.html absent; rendered checks skipped\n'
fi

printf 'verify-fieldnotes-home: PASS\n'
