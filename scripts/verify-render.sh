#!/usr/bin/env bash
# Render-HTML guard for athan-dial.github.io.
#
# Asserts against the HTML a reader actually receives — not that Hugo compiled.
#
# WHY THIS IS NOT REDUNDANT WITH verify-build.sh:
#   verify-build.sh checks that the site BUILDS and that no unsafe or unreviewed
#   page publishes. It never inspects rendered HTML. That gap let all of the
#   following ship green to production simultaneously:
#
#     - an eight-anchor case outline that had never rendered once
#     - an evidence label printed twice on every case page
#     - five Open Graph tags emitted twice on every page
#     - "Not yet documented" printed four times on the homepage
#     - every essay and every note page shipping with no active nav item
#
#   A green build proved the site compiled. It proved nothing about what a
#   reader received. This script closes that gap.
#
# Builds to a throwaway directory (NEVER docs/). docs/ is a mixed publish tree
# — Hugo output plus a separately synced microsite, plus stale orphans from
# unpublished pages — so asserting against it would produce false results.
# Never use --cleanDestinationDir.
#
# Usage:
#   bash scripts/verify-render.sh
#
# Exit codes:
#   0  all render assertions passed
#   1  a render assertion failed (or the throwaway hugo build failed)
#   4  hugo not installed
#
# PORTABILITY TRAP: do not wrap python heredocs in RESULT="$( python <<'PY' ... )".
# Bash counts parentheses inside $() across the heredoc body; a python raw-string
# like r'["\']' terminates a single-quoted span early and a later ) closes $()
# mid-script. Write python output to a file under the throwaway build dir instead.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || exit 1

fail() {
  local code="$1"; shift
  printf 'verify-render: FAIL — %s\n' "$*" >&2
  exit "$code"
}

ok() { printf 'verify-render:   ok — %s\n' "$*"; }

command -v hugo >/dev/null 2>&1 || fail 4 "hugo is not installed or not on PATH"
command -v python3 >/dev/null 2>&1 || fail 1 "python3 is not installed or not on PATH"

# ---------------------------------------------------------------------------
# Throwaway build. docs/ is never touched.
# ---------------------------------------------------------------------------
BUILD_OUT="$(mktemp -d)"
trap 'rm -rf "$BUILD_OUT"' EXIT

if ! BUILD_LOG="$(hugo --gc --destination "$BUILD_OUT" 2>&1)"; then
  printf '%s\n' "$BUILD_LOG" >&2
  fail 1 "hugo build failed (see output above)"
fi
ok "hugo build succeeded (throwaway dir, docs/ untouched)"

# Scratch files for python checkers (cleaned with BUILD_OUT).
OG_OUT="$BUILD_OUT/.verify-render-og"
JSONLD_OUT="$BUILD_OUT/.verify-render-jsonld"
SITEMAP_OUT="$BUILD_OUT/.verify-render-sitemap"

# ---------------------------------------------------------------------------
# 1. Exactly one og:title / og:description / og:type / og:url / og:image and
#    exactly one rel=canonical per full page.
#
# Redirect stubs intentionally omit OG tags; they are skipped. Everything else
# under the throwaway tree that carries the editorial shell is in scope — so a
# new section cannot quietly ship with duplicated head tags.
# ---------------------------------------------------------------------------
python3 - "$BUILD_OUT" "$OG_OUT" <<'PY'
import os, re, sys

root, out_path = sys.argv[1], sys.argv[2]
props = ("og:title", "og:description", "og:type", "og:url", "og:image")
# property="og:image" must not count og:image:width / :height / :alt.
prop_re = {p: re.compile(r'property="%s"' % re.escape(p)) for p in props}
canonical_re = re.compile(r'rel="canonical"')

pages = []
for dirpath, _, filenames in os.walk(root):
    if "index.html" not in filenames:
        continue
    path = os.path.join(dirpath, "index.html")
    rel = "/" + os.path.relpath(path, root).replace(os.sep, "/")
    if rel == "/index.html":
        rel_url = "/"
    elif rel.endswith("/index.html"):
        rel_url = rel[: -len("index.html")]
    else:
        rel_url = rel
    with open(path, encoding="utf-8") as fh:
        html = fh.read()
    # Redirect stubs: meta-refresh, no editorial shell.
    lower = html.lower()
    if "http-equiv" in lower and "refresh" in lower and "site-header" not in html:
        continue
    if "site-header" not in html and 'property="og:title"' not in html:
        continue
    pages.append((rel_url, html))

def write(msg):
    with open(out_path, "w", encoding="utf-8") as fh:
        fh.write(msg)

if not pages:
    write("no editorial pages found in throwaway build")
    raise SystemExit(0)

have = {u for u, _ in pages}
about = sorted(u for u in have if u.rstrip("/") == "/about")
work_cases = sorted(u for u in have if re.fullmatch(r"/work/[^/]+/", u))
essays = sorted(u for u in have if re.fullmatch(r"/essays/[^/]+/", u))
missing = []
if "/" not in have:
    missing.append("/")
if not about:
    missing.append("/about/")
if not work_cases:
    missing.append("/work/<case>/")
if not essays:
    missing.append("/essays/<essay>/")
if missing:
    write("required surfaces missing from build: " + ", ".join(missing))
    raise SystemExit(0)

must = ["/", about[0], work_cases[0], essays[0]]
bad = []
checked = set()
for rel_url, html in pages:
    counts = {p: len(prop_re[p].findall(html)) for p in props}
    counts["canonical"] = len(canonical_re.findall(html))
    for key, n in counts.items():
        if n != 1:
            bad.append("%s: %s=%d (want 1)" % (rel_url, key, n))
    checked.add(rel_url)
for u in must:
    if u not in checked:
        bad.append("%s: required surface was not checked" % u)
if bad:
    write("\n".join(bad))
else:
    write(
        "OK %d pages (incl. /, /about/, %s, %s)"
        % (len(pages), work_cases[0], essays[0])
    )
PY

OG_RESULT="$(cat "$OG_OUT")"
if [ -z "$OG_RESULT" ]; then
  fail 1 "Open Graph / canonical check produced no output"
fi
if [ "${OG_RESULT#OK }" = "$OG_RESULT" ]; then
  printf 'verify-render: Open Graph / canonical violations:\n%s\n' "$OG_RESULT" >&2
  fail 1 "Open Graph or canonical tags are missing or duplicated on one or more pages"
fi
ok "Open Graph + canonical exactly-once ($OG_RESULT)"

# ---------------------------------------------------------------------------
# 2. Every built /work/<case>/ page carries the case outline.
#
# The outline lived in a partial that no layout called — eight anchors, never
# rendered. Presence of the class is the proof the partial is wired.
# ---------------------------------------------------------------------------
WORK_CASES="$(find "$BUILD_OUT/work" -mindepth 2 -maxdepth 2 -name index.html 2>/dev/null | sort)"
[ -n "$WORK_CASES" ] || fail 1 "no /work/<case>/ pages in throwaway build"

OUTLINE_MISSING=""
while IFS= read -r f; do
  [ -n "$f" ] || continue
  if ! grep -q 'work-article__outline' "$f"; then
    OUTLINE_MISSING="${OUTLINE_MISSING}${f#"$BUILD_OUT"}\n"
  fi
done <<EOF
$WORK_CASES
EOF

if [ -n "$OUTLINE_MISSING" ]; then
  printf 'verify-render: work pages missing work-article__outline:\n%b' "$OUTLINE_MISSING" >&2
  fail 1 "case outline missing from one or more /work/<case>/ pages"
fi
CASE_N="$(printf '%s\n' "$WORK_CASES" | grep -c . || true)"
ok "work-article__outline present on every /work/<case>/ page ($CASE_N)"

# ---------------------------------------------------------------------------
# 3. aria-current="page" on every essay, every note, and /thinking/.
#
# Essays and notes render outside /thinking/, so a naive prefix match left
# Thinking unmarked on those pages.
# ---------------------------------------------------------------------------
NAV_MISSING=""
while IFS= read -r f; do
  [ -n "$f" ] || continue
  if ! grep -q 'aria-current="page"' "$f"; then
    NAV_MISSING="${NAV_MISSING}${f#"$BUILD_OUT"}\n"
  fi
done <<EOF
$(find "$BUILD_OUT/essays" -mindepth 2 -maxdepth 2 -name index.html 2>/dev/null | sort)
$(find "$BUILD_OUT/notes" -mindepth 2 -maxdepth 2 -name index.html 2>/dev/null | sort)
$BUILD_OUT/thinking/index.html
EOF

[ -f "$BUILD_OUT/thinking/index.html" ] || fail 1 "/thinking/ missing from throwaway build"

if [ -n "$NAV_MISSING" ]; then
  printf 'verify-render: pages missing aria-current="page":\n%b' "$NAV_MISSING" >&2
  fail 1 "active nav marker missing on an essay, note, or /thinking/"
fi
ok 'aria-current="page" present on essays, notes, and /thinking/'

# ---------------------------------------------------------------------------
# 4–5. Forbidden strings that previously shipped on a green build.
# ---------------------------------------------------------------------------
FORBIDDEN_HITS="$(grep -rF --include='*.html' -n 'Not yet documented' "$BUILD_OUT" 2>/dev/null || true)"
if [ -n "$FORBIDDEN_HITS" ]; then
  printf 'verify-render: "Not yet documented" still renders:\n%s\n' "$FORBIDDEN_HITS" >&2
  fail 1 '"Not yet documented" appears in rendered HTML (want zero site-wide)'
fi
ok '"Not yet documented" absent site-wide'

FORBIDDEN_HITS="$(grep -rF --include='*.html' -n 'evidence-label' "$BUILD_OUT" 2>/dev/null || true)"
if [ -n "$FORBIDDEN_HITS" ]; then
  printf 'verify-render: evidence-label still renders:\n%s\n' "$FORBIDDEN_HITS" >&2
  fail 1 '"evidence-label" appears in rendered HTML (want zero site-wide)'
fi
ok '"evidence-label" absent site-wide'

# ---------------------------------------------------------------------------
# 6. Every JSON-LD block must parse as JSON. Regex is not a JSON parser.
# ---------------------------------------------------------------------------
python3 - "$BUILD_OUT" "$JSONLD_OUT" <<'PY'
import json, os, re, sys

root, out_path = sys.argv[1], sys.argv[2]
# Split markers avoid a single regex that confuses bash when this file is edited
# under a $() wrap; keep the extractor in python only.
start_re = re.compile(
    r'<script\s+type=["\']application/ld\+json["\']\s*>',
    re.I,
)
end_re = re.compile(r'</script>', re.I)
bad = []
n = 0
for dirpath, _, filenames in os.walk(root):
    for name in filenames:
        if not name.endswith(".html"):
            continue
        path = os.path.join(dirpath, name)
        html = open(path, encoding="utf-8").read()
        pos = 0
        while True:
            m = start_re.search(html, pos)
            if not m:
                break
            m2 = end_re.search(html, m.end())
            if not m2:
                rel = "/" + os.path.relpath(path, root).replace(os.sep, "/")
                bad.append("%s: unclosed JSON-LD script" % rel)
                break
            raw = html[m.end() : m2.start()].strip()
            n += 1
            try:
                json.loads(raw)
            except Exception as e:
                rel = "/" + os.path.relpath(path, root).replace(os.sep, "/")
                bad.append("%s: %s" % (rel, e))
            pos = m2.end()

with open(out_path, "w", encoding="utf-8") as fh:
    if bad:
        fh.write("\n".join(bad))
    else:
        fh.write("OK %d" % n)
PY

JSONLD_RESULT="$(cat "$JSONLD_OUT")"
if [ "${JSONLD_RESULT#OK }" = "$JSONLD_RESULT" ]; then
  printf 'verify-render: invalid JSON-LD:\n%s\n' "$JSONLD_RESULT" >&2
  fail 1 "one or more JSON-LD blocks failed json.loads"
fi
ok "JSON-LD blocks parse as JSON ($JSONLD_RESULT blocks)"

# ---------------------------------------------------------------------------
# 7. No draft or quarantined page in sitemap.xml.
#
# Same front-matter rule set as verify-build.sh §4 (lines 135–168): a page that
# declares status/visibility is quarantined when status is not published or
# visibility is not public; draft: true is also unpublished. Map those content
# paths to their would-be permalinks and assert sitemap.xml names none of them.
# ---------------------------------------------------------------------------
SITEMAP="$BUILD_OUT/sitemap.xml"
[ -f "$SITEMAP" ] || fail 1 "sitemap.xml missing from throwaway build"

python3 - "$SITEMAP" "$SITEMAP_OUT" <<'PY'
import glob, re, sys
from pathlib import Path
from urllib.parse import urlparse

sitemap_path, out_path = sys.argv[1], sys.argv[2]
sitemap = Path(sitemap_path).read_text(encoding="utf-8")
locs = re.findall(r"<loc>\s*([^<]+?)\s*</loc>", sitemap)
paths = set()
for loc in locs:
    p = urlparse(loc.strip()).path
    if not p.endswith("/"):
        p = p + "/"
    paths.add(p)

bad_pages = []
for path in glob.glob("content/**/*.md", recursive=True):
    text = Path(path).read_text(encoding="utf-8")
    m = re.match(r"^---\n(.*?)\n---", text, re.S)
    if not m:
        continue
    fm = m.group(1)

    def field(name):
        f = re.search(rf"^{name}:\s*(\S+)", fm, re.M)
        return f.group(1).strip().strip("\"'").lower() if f else None

    status, visibility, draft = field("status"), field("visibility"), field("draft")
    # Same scope gate as verify-build.sh: only pages that declare the fields,
    # plus any explicit draft: true (resume/skills and the content-model pages).
    quarantined = False
    if status is not None or visibility is not None:
        quarantined = (status not in (None, "published")) or (
            visibility not in (None, "public")
        )
    is_draft = draft == "true"
    if not (quarantined or is_draft):
        continue

    # content/foo.md → /foo/ ; content/foo/_index.md → /foo/ ; content/a/b.md → /a/b/
    rel = path[len("content/") :]
    if rel.endswith("/_index.md"):
        url = "/" + rel[: -len("/_index.md")].rstrip("/") + "/"
        if url == "//":
            url = "/"
    elif rel == "_index.md":
        url = "/"
    elif rel.endswith(".md"):
        url = "/" + rel[: -len(".md")].rstrip("/") + "/"
    else:
        continue
    if url in paths:
        bad_pages.append(
            "%s → %s (status=%s visibility=%s draft=%s)"
            % (path, url, status, visibility, draft)
        )

with open(out_path, "w", encoding="utf-8") as fh:
    if bad_pages:
        fh.write("\n".join(bad_pages))
    else:
        fh.write("OK scanned sitemap (%d urls)" % len(paths))
PY

SITEMAP_RESULT="$(cat "$SITEMAP_OUT")"
if [ "${SITEMAP_RESULT#OK }" = "$SITEMAP_RESULT" ]; then
  printf 'verify-render: draft/quarantined URLs present in sitemap.xml:\n%s\n' "$SITEMAP_RESULT" >&2
  fail 1 "sitemap.xml lists a draft or quarantined page"
fi
ok "sitemap.xml lists no draft or quarantined page ($SITEMAP_RESULT)"

printf 'verify-render: PASS\n'
