#!/usr/bin/env bash
# Content safety scanner for athan-dial.github.io.
#
# Scans content/**/*.md for material that must never appear in a PUBLIC repo: internal
# program and tool codenames, vendor and CRO names, colleague names, internal schema and
# infrastructure identifiers, chat/wiki permalinks, and absolute dollar figures.
#
# WHY THE DENYLIST IS NOT IN THIS FILE:
#   A list of the real names, committed to a public repo, discloses exactly what it is
#   supposed to protect. So the sensitive patterns are read at runtime from
#   .planning/private/denylist.txt, which is gitignored. This script is safe to publish;
#   the list it consumes is not.
#
#   If the private list is absent (a fresh clone, or CI without it), the scan degrades
#   LOUDLY but does not fail the build: it prints a clear warning that name-based scanning
#   is unavailable and continues with the structural checks below, which need no secrets.
#   That is deliberate. A missing list must not silently look like a pass, and must not
#   block a legitimate build either.
#
# Usage:
#   bash scripts/verify-content-safety.sh
#
# Exit codes:
#   0  no violations found (see the warning above re: a missing denylist)
#   1  violations found — output names file:line and the matched marker
#
# PORTABILITY TRAP, learned the hard way: `grep` here may be ugrep. With a `--` separator it
# treats a TRAILING --include as a filename, warns on stderr, and exits 2 — so an
# `if grep ...; then` guard reads as "no match" even when matches were printed. That made an
# earlier version of this script pass unconditionally. Every scan below therefore puts
# --include BEFORE the pattern and gates on whether the output file is non-empty, never on
# grep's exit status.
#
# A match is a prompt to reword, not necessarily proof of a leak. Fix it in the prose.
# Never resolve a false positive by weakening the denylist.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || exit 1

DENYLIST=".planning/private/denylist.txt"
SCAN_DIR="content"
VIOLATIONS=0
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

if [ ! -d "$SCAN_DIR" ]; then
  printf 'content-safety: no %s/ directory — nothing to scan\n' "$SCAN_DIR"
  exit 0
fi

report() {
  printf 'content-safety: VIOLATION  %s\n' "$*" >&2
  VIOLATIONS=$((VIOLATIONS + 1))
}

# ---------------------------------------------------------------------------
# 1. Name-based scan, from the private denylist.
# ---------------------------------------------------------------------------
if [ -f "$DENYLIST" ]; then
  PATTERN_COUNT=0
  while IFS= read -r raw; do
    pat="${raw%%#*}"
    pat="$(printf '%s' "$pat" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [ -z "$pat" ] && continue
    PATTERN_COUNT=$((PATTERN_COUNT + 1))
    # -w applies word boundaries so "PEAK" does not fire on "peaks" mid-word,
    # while still catching the standalone codename.
    grep -rniwE --include='*.md' -- "$pat" "$SCAN_DIR" > "$TMP" 2>/dev/null || true
    if [ -s "$TMP" ]; then
      while IFS= read -r hit; do
        f="${hit%%:*}"; rest="${hit#*:}"; ln="${rest%%:*}"
        report "$f:$ln  matched denied term: $pat"
      done < "$TMP"
    fi
  done < "$DENYLIST"
  printf 'content-safety:   scanned %s/ against %s denied patterns\n' "$SCAN_DIR" "$PATTERN_COUNT"
else
  printf 'content-safety: WARNING — %s not found.\n' "$DENYLIST" >&2
  printf 'content-safety: WARNING — name-based scanning is UNAVAILABLE. Structural checks only.\n' >&2
  printf 'content-safety: WARNING — do not read this run as a clean bill of health.\n' >&2
fi

# ---------------------------------------------------------------------------
# 2. Structural checks. These need no secret list, so they always run.
# ---------------------------------------------------------------------------

# Internal service permalinks. Nothing on a public site should link into a private workspace.
grep -rniE --include='*.md' -- '(slack\.com|atlassian\.net|\.notion\.so|app\.notion\.com|hub\.zoom\.us|docs\.zoom\.us)' \
     "$SCAN_DIR" > "$TMP" 2>/dev/null || true
if [ -s "$TMP" ]; then
  while IFS= read -r hit; do
    f="${hit%%:*}"; rest="${hit#*:}"; ln="${rest%%:*}"
    report "$f:$ln  internal service permalink"
  done < "$TMP"
fi

# Internal document / infrastructure identifier shapes.
grep -rniE --include='*.md' -- '(pageId=[0-9]+|\bZ0[A-Z0-9]{9,}\b|arn:aws:)' \
     "$SCAN_DIR" > "$TMP" 2>/dev/null || true
if [ -s "$TMP" ]; then
  while IFS= read -r hit; do
    f="${hit%%:*}"; rest="${hit#*:}"; ln="${rest%%:*}"
    report "$f:$ln  internal identifier pattern"
  done < "$TMP"
fi

# Absolute dollar figures of four digits or more (including comma-grouped).
# Unpublished cost and portfolio figures are the highest-risk numbers on the site.
# Small figures are allowed — the point of the lineage story is that the amount was trivial.
grep -rnE --include='*.md' -- '\$[0-9]{1,3},[0-9]{3}|\$[0-9]{4,}' \
     "$SCAN_DIR" > "$TMP" 2>/dev/null || true
if [ -s "$TMP" ]; then
  while IFS= read -r hit; do
    f="${hit%%:*}"; rest="${hit#*:}"; ln="${rest%%:*}"
    report "$f:$ln  absolute dollar figure — use a range, or characterise it"
  done < "$TMP"
fi

# ---------------------------------------------------------------------------
if [ "$VIOLATIONS" -gt 0 ]; then
  printf '\ncontent-safety: FAIL — %s violation(s). Reword the prose; do not weaken the denylist.\n' "$VIOLATIONS" >&2
  printf 'content-safety: rules and approved vocabulary: .planning/CONTENT-SAFETY-CONTRACT.md\n' >&2
  exit 1
fi

printf 'content-safety: PASS\n'
