#!/usr/bin/env bash
# Source-level regression gate for the evidence-backed Work content pass.
# This gate intentionally does not need a Hugo build. It protects the authored content
# package while the new stories remain draft/private for Athan's review.

set -eu

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$REPO_ROOT/content/work"
ABOUT="$REPO_ROOT/content/about.md"

fail() {
  printf 'verify-content-depth: FAIL — %s\n' "$*" >&2
  exit 1
}

ok() { printf 'verify-content-depth:   ok — %s\n' "$*"; }

assert_contains() {
  file="$1"
  needle="$2"
  grep -q -F "$needle" "$file" || fail "$file is missing: $needle"
}

assert_not_contains() {
  file="$1"
  needle="$2"
  if grep -q -F "$needle" "$file"; then
    fail "$file still contains retired/disputed copy: $needle"
  fi
}

# ---------------------------------------------------------------------------
# 1. The disputed absent-user narrative is quarantined, not silently repaired.
# ---------------------------------------------------------------------------
ABSENT="$WORK/intelligence-platform-for-an-absent-user.md"
[ -f "$ABSENT" ] || fail "the disputed narrative disappeared instead of being quarantined"
assert_contains "$ABSENT" "status: draft"
assert_contains "$ABSENT" "visibility: private"
assert_contains "$ABSENT" "draft: true"
ok "disputed absent-user narrative is draft/private"

assert_not_contains "$ABOUT" "the primary user turned out not to be the person who had asked for the tool"
assert_not_contains "$ABOUT" "That user was not in the room"
assert_not_contains "$ABOUT" "primary user was not in the room"
ok "About no longer depends on the disputed user-flip story"

# ---------------------------------------------------------------------------
# 2. Three flagship narratives exist as an intentional set.
#    Only the already-cleared analog-search case may be public before Athan reviews
#    the new prose. New material must stay draft/private.
# ---------------------------------------------------------------------------
ANALOG="$WORK/analog-search-as-a-product.md"
WEAKER="$WORK/the-result-got-weaker-after-we-checked-it.md"
OUTCOME="$WORK/lock-the-outcome-not-the-prototype.md"

for file in "$ANALOG" "$WEAKER" "$OUTCOME"; do
  [ -f "$file" ] || fail "missing flagship narrative: $file"
  assert_contains "$file" "work_kind: flagship"
done
ok "three flagship narratives are present and classified"

for file in "$WEAKER" "$OUTCOME"; do
  assert_contains "$file" "status: draft"
  assert_contains "$file" "visibility: private"
  assert_contains "$file" "draft: true"
done
ok "new flagship narratives remain review-gated"

# ---------------------------------------------------------------------------
# 3. Two proof notes exist. These are shorter evidence artifacts, not padded cases.
# ---------------------------------------------------------------------------
BENCHMARK="$WORK/before-the-agent-build-the-benchmark.md"
AUTOMATION="$WORK/automation-was-not-the-whole-bottleneck.md"

for file in "$BENCHMARK" "$AUTOMATION"; do
  [ -f "$file" ] || fail "missing proof note: $file"
  assert_contains "$file" "work_kind: proof-note"
  assert_contains "$file" "status: draft"
  assert_contains "$file" "visibility: private"
  assert_contains "$file" "draft: true"
done
ok "two proof notes are present and review-gated"

# ---------------------------------------------------------------------------
# 4. Work/About copy describes depth rather than defending an exact item count.
# ---------------------------------------------------------------------------
INDEX="$WORK/_index.md"
assert_not_contains "$INDEX" "Two product narratives"
assert_not_contains "$INDEX" "the collection stays small on purpose"
assert_not_contains "$ABOUT" "Two product narratives"
ok "Work and About no longer institutionalize a two-case ceiling"

# ---------------------------------------------------------------------------
# 5. Public-safety smoke test for the newly-authored files.
#    The full denylist remains owned by scripts/verify-content-safety.sh; these are
#    especially easy leak paths given the private source material used for this pass.
# ---------------------------------------------------------------------------
for file in "$WEAKER" "$OUTCOME" "$BENCHMARK" "$AUTOMATION"; do
  for banned in "TALOS" "ACN" "STAT6" "TL1A" "OX40L" "IL5" "Montai" "Jira" "Confluence"; do
    if grep -q -F "$banned" "$file"; then
      fail "$file leaks an unnecessary internal/source-system name: $banned"
    fi
  done
done
ok "new stories pass the content-pass public-safety smoke test"

printf 'verify-content-depth: PASS\n'
