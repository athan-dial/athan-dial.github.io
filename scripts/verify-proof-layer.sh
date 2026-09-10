#!/usr/bin/env bash
# Regression gate for the personal-brand proof-layer pass (2026-09-10).
#
# Authority: .planning/specs/2026-09-10-personal-brand-proof-layer-design.md
#
# Usage:
#   bash scripts/verify-proof-layer.sh [/path/to/build]
#
# Default build dir: public
#
# What this covers that the existing gates do not:
#
#   * scripts/verify-redirects.sh asserts every redirect stub EXISTS and names its target.
#     It cannot tell you a real page has taken the route over instead. That is the failure
#     this pass actually hit: deleting content/skills/_index.md (which carried
#     build.render: never) left content/skills/case-studies/ behind, Hugo generated a
#     section index for the parentless branch, and /skills/ started serving a real "Skills"
#     list page that beat the redirect adapter. Section 1 below is that check.
#   * The About page is now the site's only proof surface for trajectory, ownership, and
#     the research record. Sections 2 and 3 assert its seven canonical sections are all
#     present and that its computed research figures still agree with data/publications.json
#     rather than having been typed in.
#   * The Outer Loop artwork must be the lossless high-resolution source through Hugo's
#     image pipeline, never the retired lossy WebP. Section 4.
#   * The retired content files must stay deleted. Section 5.
#
# Exit non-zero on the first failure, naming it. No network.

set -eu

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${1:-$REPO_ROOT/public}"

fail() {
  printf 'verify-proof-layer: FAIL — %s\n' "$*" >&2
  exit 1
}

ok() { printf 'verify-proof-layer:   ok — %s\n' "$*"; }

[ -d "$BUILD_DIR" ] || fail "build directory not found: $BUILD_DIR (run hugo --gc --minify first)"

# A running dev server invalidates this whole gate. `hugo server -D` writes DRAFT pages
# into publishDir, so every assertion below would be measured against a build that is not
# the production build — and it can fail loudly OR pass quietly on the wrong output. Warn
# once, up front, so a later failure is not mistaken for a content or template bug.
if pgrep -f 'hugo server' >/dev/null 2>&1; then
  printf 'verify-proof-layer: WARNING — a "hugo server" is running. If it was started with -D it writes draft pages into %s, and the results below are measured against a polluted build. Stop it and rerun "hugo --gc --minify" for a trustworthy result.\n' "$BUILD_DIR" >&2
fi

# ---------------------------------------------------------------------------
# 1. Redirect sole ownership.
#
#    Each of these routes must be a meta-refresh STUB pointing at the expected
#    target — not a real page. A real page here means a content file or an
#    auto-generated section index has taken the route back from the adapter.
# ---------------------------------------------------------------------------
check_stub() {
  route="$1"
  target="$2"
  rel="${route#/}"
  rel="${rel%/}"
  stub="$BUILD_DIR/$rel/index.html"

  [ -f "$stub" ] || fail "$route is not built at all (expected a redirect stub at $stub)"

  grep -q -F 'http-equiv=refresh' "$stub" \
    || grep -q -F 'http-equiv="refresh"' "$stub" \
    || fail "$route is a REAL PAGE, not a redirect stub — a content file or generated section index has taken the route from data/redirects.toml"

  grep -q -F "$target" "$stub" \
    || fail "$route redirects somewhere other than $target"

  ok "$route is a stub -> $target (sole owner)"
}

check_stub "/writing/"              "/thinking/"
check_stub "/advisory/"             "/about/#conversations"
check_stub "/consulting/"           "/about/#conversations"
check_stub "/skills/"               "/thinking/"
check_stub "/skills/case-studies/"  "/thinking/"
check_stub "/skills/orc/"           "/thinking/"
check_stub "/skills/folio/"         "/thinking/"
check_stub "/skills/dev/"           "/thinking/"

# A stub must never be indexable — it is not a page, it is a signpost.
for route in writing advisory consulting skills; do
  grep -q -F 'noindex' "$BUILD_DIR/$route/index.html" \
    || fail "/$route/ stub is missing robots noindex"
done
ok "redirect stubs carry robots noindex"

# ---------------------------------------------------------------------------
# 2. Routes that must stay real and stable.
# ---------------------------------------------------------------------------
for rel in \
  "about/index.html" \
  "work/index.html" \
  "thinking/index.html" \
  "essays/index.html" \
  "notes/index.html" \
  "work/analog-search-as-a-product/index.html" \
  "essays/the-outer-loop/index.html" \
  "essays/the-operating-layer/index.html" \
  "notes/an-all-false-column-is-a-legal-column/index.html"
do
  [ -f "$BUILD_DIR/$rel" ] || fail "public route missing from build: /$rel"
  if grep -q -F 'http-equiv=refresh' "$BUILD_DIR/$rel"; then
    fail "/$rel is a redirect stub but must be a real page"
  fi
done
ok "work, fieldnotes, essay, and note routes are real and stable"

# ---------------------------------------------------------------------------
# 3. About page contract — the seven canonical sections and their anchors.
#
#    #conversations is load-bearing beyond the page itself: /advisory/ and
#    /consulting/ both redirect to it, so losing the anchor silently turns two
#    redirects into a scroll to the top of About.
# ---------------------------------------------------------------------------
ABOUT="$BUILD_DIR/about/index.html"

for anchor in trajectory work-evidence research territory conversations; do
  grep -qE "id=\"?$anchor\"?" "$ABOUT" || fail "About is missing the #$anchor section"
done
ok "About carries every canonical section anchor"

# Opening classification: the four facts a hiring reader needs, from data/profile.toml.
for needle in "Associate Director" "Montai Therapeutics" "Boston" "PhD in Medical Sciences"; do
  grep -q -F "$needle" "$ABOUT" || fail "About no longer states: $needle"
done
ok "About states role, organisation, location, and foundation"

# The legacy experience summaries must never reach a rendered page. These phrases come
# from data/experience.json, whose summary fields claim unhedged ownership of shared
# systems — the reason the Data Research Lead description was unpublished on 2026-08-14
# (CLAUDE.md hard constraint 3). DESIGN.md bans them from the homepage; the boundary is
# about the claims, so it holds for About too.
for banned in "Orchestrated AI product adoption" "Owned the end-to-end nomination product" "Designed a dbt/S3 warehouse" "Directed analytics strategy"; do
  if grep -q -F "$banned" "$ABOUT" "$BUILD_DIR/index.html"; then
    fail "a legacy data/experience.json summary has been rendered onto a public page: $banned"
  fi
done
ok "legacy experience summaries stay out of About and the homepage"

# No consultancy framing survived the /advisory/ fold-in.
for banned in "discovery call" "engagement" "pricing" "book a" "my services" "retainer"; do
  if grep -qi -F "$banned" "$ABOUT"; then
    fail "About contains consultancy language: $banned"
  fi
done
ok "About carries no consultancy framing"

# ---------------------------------------------------------------------------
# 4. Research signal is COMPUTED, not typed.
#
#    Recompute the three aggregates from data/publications.json and assert the
#    rendered page agrees. If someone hardcodes a figure and the data later
#    changes, this is what catches the drift.
# ---------------------------------------------------------------------------
PUBS="$REPO_ROOT/data/publications.json"
[ -f "$PUBS" ] || fail "missing $PUBS"

COUNTS="$(
  python3 - "$PUBS" <<'PY'
import json, sys
pubs = json.load(open(sys.argv[1]))
total = len(pubs)
first = sum(1 for p in pubs if p.get("first_author"))
peer = sum(1 for p in pubs if p.get("type") in ("journal article", "review"))
print(total, first, peer)
PY
)" || fail "could not parse data/publications.json"

set -- $COUNTS
TOTAL="$1"; FIRST="$2"; PEER="$3"

grep -q -F ">$TOTAL<" "$ABOUT" || fail "About does not render the computed publication total ($TOTAL)"
grep -q -F ">$FIRST<" "$ABOUT" || fail "About does not render the computed first-author count ($FIRST)"
grep -q -F ">$PEER<" "$ABOUT" || fail "About does not render the computed peer-reviewed count ($PEER)"
ok "research aggregates match data/publications.json ($TOTAL total, $FIRST first-author, $PEER peer-reviewed)"

# The full bibliography must NOT be inline — the spec caps About at a selected few.
PAPER_ROWS="$(grep -o 'about__paper-title' "$ABOUT" | wc -l | tr -d ' ')"
[ "$PAPER_ROWS" -ge 1 ] || fail "About renders no selected research at all"
[ "$PAPER_ROWS" -le 5 ] || fail "About renders $PAPER_ROWS papers — that is a CV, not a selection (cap 5)"
ok "About renders $PAPER_ROWS selected papers, not the full $TOTAL-item record"

# ---------------------------------------------------------------------------
# 5. Work index evidence model.
# ---------------------------------------------------------------------------
WORK="$BUILD_DIR/work/index.html"
grep -q -F "What I owned" "$WORK" || fail "Work index does not show ownership per case"
grep -q -F "Not measured" "$WORK" || fail "Work index does not state what was not measured"
grep -q -F "Measured" "$WORK"     || fail "Work index does not label measured outcomes"
ok "Work index exposes ownership, measured, and not-measured"

# Evidence class must render as WORDS. Colour alone never carries meaning (PRODUCT.md).
grep -qE "Measured, published as a range|Mechanism only" "$WORK" \
  || fail "Work index does not state the evidence class in words"
ok "evidence class is stated in words, not by colour alone"

# ---------------------------------------------------------------------------
# 5b. Work depth contract, and the publication gate around it.
#
#     RETIRED 2026-09-10: this section used to assert "exactly 2 public cases" and
#     required /work/intelligence-platform-for-an-absent-user/ to be a real page. Both
#     were wrong after the content pass. The absent-user narrative was QUARANTINED —
#     source review found its primary-user reframe was not actually resolved by the
#     record — and the collection is no longer a fixed pair: `work_kind` now names two
#     depths (flagship cases and proof notes) and more are queued behind review.
#
#     A count is the wrong invariant anyway. It fails for two opposite reasons — someone
#     inventing a case, and someone legitimately publishing one — so it cannot tell you
#     which happened. What needs protecting is the GATE, not the number: every row on the
#     index must be genuinely published and public, and nothing draft or quarantined may
#     appear. So the expected count is DERIVED from the source frontmatter and the page
#     is required to agree with it exactly.
# ---------------------------------------------------------------------------
CASE_ROWS="$(grep -o 'work-card__title' "$WORK" | wc -l | tr -d ' ')"
[ "$CASE_ROWS" -ge 1 ] || fail "Work index lists no cases at all"

EXPECTED_PUBLIC="$(
  python3 - "$REPO_ROOT/content/work" <<'PYGATE'
import pathlib, re, sys
n = 0
for f in sorted(pathlib.Path(sys.argv[1]).glob("*.md")):
    if f.name == "_index.md":
        continue
    parts = f.read_text(encoding="utf-8").split("---")
    if len(parts) < 2:
        continue
    fm = parts[1]
    if re.search(r'^status:\s*published\s*$', fm, re.M) and re.search(r'^visibility:\s*public\s*$', fm, re.M):
        n += 1
print(n)
PYGATE
)" || fail "could not scan content/work frontmatter"

[ "$CASE_ROWS" -eq "$EXPECTED_PUBLIC" ] \
  || fail "Work index shows $CASE_ROWS rows but $EXPECTED_PUBLIC page(s) are published+public in content/work — the index and the gate disagree"
ok "Work index shows exactly the $EXPECTED_PUBLIC published+public page(s), no more and no fewer"

# The quarantined narrative must not be in the production build, and must stay
# quarantined at source. Do NOT resolve a failure here by publishing it: its framing has
# not been reconciled against the discovery record.
QUARANTINED="$REPO_ROOT/content/work/intelligence-platform-for-an-absent-user.md"
if [ -f "$QUARANTINED" ]; then
  grep -q -F "work_kind: quarantined" "$QUARANTINED" \
    || fail "the absent-user narrative is no longer marked work_kind: quarantined"
  grep -q -F "visibility: private" "$QUARANTINED" \
    || fail "the absent-user narrative is no longer private — its user-flip framing is unreconciled"
  ok "absent-user narrative stays quarantined and private at source"
fi
if [ -e "$BUILD_DIR/work/intelligence-platform-for-an-absent-user" ]; then
  # Before blaming the content, check the likeliest cause. A freshly started
  # `hugo server -D` writes draft pages into publishDir, so a gate run alongside it sees
  # draft output in a directory it believes is a production build. That produces exactly
  # this failure with entirely correct frontmatter, which sends you looking in the wrong
  # place — verified the hard way on 2026-09-10.
  if pgrep -f 'hugo server' >/dev/null 2>&1; then
    fail "a 'hugo server' is running and has written draft pages into $BUILD_DIR — this is a POLLUTED BUILD DIR, not a content failure. Stop the server, rerun 'hugo --gc --minify', then rerun this gate. (Frontmatter may be entirely correct.)"
  fi
  fail "the quarantined absent-user narrative is in the production build"
fi
ok "quarantined narrative is absent from the production build"

# Depth labels. A proof note must announce itself, because a reader who is not told it is
# narrower by design reads its length as thinness. And the index must not advertise a
# group with nothing in it.
if grep -q -l -F 'work_kind: proof-note' "$REPO_ROOT"/content/work/*.md 2>/dev/null; then
  PN_PUBLIC=0
  for f in $(grep -l -F 'work_kind: proof-note' "$REPO_ROOT"/content/work/*.md 2>/dev/null); do
    if grep -q -F 'visibility: public' "$f" && grep -q -F 'status: published' "$f"; then
      PN_PUBLIC=$((PN_PUBLIC + 1))
    fi
  done
  if [ "$PN_PUBLIC" -gt 0 ]; then
    grep -q -F "Proof notes" "$WORK" \
      || fail "$PN_PUBLIC proof note(s) are published but the Work index has no Proof notes group"
    ok "published proof notes render under their own labelled group"
  else
    if grep -q -F "Proof notes" "$WORK"; then
      fail "the Work index advertises a Proof notes group with nothing published in it"
    fi
    ok "no proof note is public yet, and the index correctly shows no empty group"
  fi
fi

# The draft-only review shelf must never reach production. It is gated on
# site.BuildDrafts, so this asserts the gate rather than the intent.
if grep -q -F 'work-index__review' "$WORK"; then
  if pgrep -f 'hugo server' >/dev/null 2>&1; then
    fail "a 'hugo server' is running and has written a draft build into $BUILD_DIR — polluted build dir, not a template failure. Stop the server, rebuild, rerun."
  fi
  fail "the draft-only in-review shelf is in the production build — check the site.BuildDrafts gate in layouts/work/list.html"
fi
ok "draft-only in-review shelf is absent from the production build"

# ---------------------------------------------------------------------------
# 6. Outer Loop artwork — lossless source, high-density variant, no lossy WebP.
# ---------------------------------------------------------------------------
HOME="$BUILD_DIR/index.html"

[ -f "$REPO_ROOT/assets/img/outer-loop-highlight.png" ] \
  || fail "the canonical lossless Outer Loop source is missing (assets/img/outer-loop-highlight.png)"

if [ -f "$REPO_ROOT/static/img/outer-loop-highlight.webp" ]; then
  fail "the retired lossy Outer Loop WebP is back in static/img/ — there must be one canonical asset"
fi
ok "one canonical lossless Outer Loop source, retired WebP absent"

# Hugo must be emitting it through the image pipeline (fingerprinted _hu_ variants),
# and the homepage must offer a 2x candidate or Retina displays stretch the 1x file.
grep -q -F 'outer-loop-highlight_hu_' "$HOME" \
  || fail "homepage does not reference a Hugo-processed Outer Loop variant"
grep -q -F ' 2x' "$HOME" \
  || fail "homepage Outer Loop image has no 2x srcset candidate — Retina displays will upscale the 1x file"
ok "homepage serves processed 1x/2x Outer Loop variants"

# The source's own resolution has to clear the spec's floor.
python3 - "$REPO_ROOT/assets/img/outer-loop-highlight.png" <<'PY' || exit 1
import struct, sys
path = sys.argv[1]
with open(path, "rb") as fh:
    head = fh.read(24)
if head[:8] != b"\x89PNG\r\n\x1a\n":
    sys.exit("verify-proof-layer: FAIL — Outer Loop source is not a PNG (must be lossless)")
w, h = struct.unpack(">II", head[16:24])
if w < 1200 or h < 1200:
    sys.exit(f"verify-proof-layer: FAIL — Outer Loop source is {w}x{h}; the spec floor is 1200x1200")
if w != h:
    sys.exit(f"verify-proof-layer: FAIL — Outer Loop source is {w}x{h}; the composition is square")
print(f"verify-proof-layer:   ok — Outer Loop source is a lossless {w}x{h} PNG")
PY

# The homepage must not have regressed to the hardcoded mini-flow it replaced.
for banned in "fn-mini-flow" "fn-feature__diagram"; do
  if grep -q -F "$banned" "$HOME"; then
    fail "the retired hardcoded outer-loop mini-flow is back on the homepage ($banned)"
  fi
done
ok "the hardcoded mini-flow stays retired"

# ---------------------------------------------------------------------------
# 7. Retired content files stay deleted, and the asset plan stays archived.
# ---------------------------------------------------------------------------
for gone in \
  "content/writing.md" \
  "content/advisory.md" \
  "content/skills/_index.md" \
  "content/skills/case-studies/_index.md" \
  "ASSET_GENERATION_PLAN.md"
do
  if [ -e "$REPO_ROOT/$gone" ]; then
    fail "$gone is back — it was retired by the proof-layer pass"
  fi
done
ok "retired content files stay deleted"

LEGACY="$REPO_ROOT/.planning/archive/ASSET_GENERATION_PLAN-legacy.md"
[ -f "$LEGACY" ] || fail "the archived asset plan is missing from .planning/archive/"
head -1 "$LEGACY" | grep -q -F "RETIRED" \
  || fail "the archived asset plan has lost its retirement notice — an agent could read it as current authority"
ok "archived asset plan carries its retirement notice"

# The retired palette must not have leaked back into the live design tokens.
for hex in "2E5C8A" "C17A47" "8B6F9E"; do
  if grep -qi -F "$hex" "$REPO_ROOT/assets/css/tokens.css"; then
    fail "retired pre-Fieldnotes palette colour #$hex is back in tokens.css"
  fi
done
ok "retired teal/terracotta/purple palette is absent from tokens.css"

# Resume stays unpublished.
[ -f "$BUILD_DIR/resume/index.html" ] && fail "/resume/ is being generated again — it must stay unpublished"
if grep -q -F 'resume.pdf' "$HOME" "$ABOUT"; then
  fail "a resume PDF link is back on a public page"
fi
ok "resume stays unpublished, no PDF link"

printf 'verify-proof-layer: PASS\n'
