#!/usr/bin/env bash
# Source-level voice gate for Personal Fieldnotes Work narratives.
#
# Work is documentary: the problem, evidence, decisions, and consequences are the
# grammatical subjects. First-person singular is reserved for the final Retrospective,
# where personal hindsight is actually the point.

set -eu

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$REPO_ROOT/content/work"

fail() {
  printf 'verify-documentary-voice: FAIL - %s\n' "$*" >&2
  exit 1
}

ok() { printf 'verify-documentary-voice:   ok - %s\n' "$*"; }

FILES="
$WORK/analog-search-as-a-product.md
$WORK/the-result-got-weaker-after-we-checked-it.md
$WORK/lock-the-outcome-not-the-prototype.md
$WORK/before-the-agent-build-the-benchmark.md
$WORK/automation-was-not-the-whole-bottleneck.md
"

for file in $FILES; do
  [ -f "$file" ] || fail "missing Work narrative: $file"
  grep -q '^narrative_voice: documentary$' "$file" \
    || fail "$file does not declare narrative_voice: documentary"
  grep -q '^## Role in the case$' "$file" \
    || fail "$file is missing the documentary ownership section: Role in the case"
  grep -q '^## Retrospective$' "$file" \
    || fail "$file is missing the explicitly personal Retrospective section"
  if grep -q '^## My ownership$' "$file"; then
    fail "$file still uses the first-person ownership heading"
  fi
  if grep -q '^## What I would change now$' "$file"; then
    fail "$file still uses the first-person retrospective heading"
  fi

done
ok "all five Work narratives declare documentary voice and the shared section grammar"

python3 - $FILES <<'PY'
import pathlib
import re
import sys

pronoun = re.compile(r"(?i)(?<![A-Za-z])(?:I|I'm|I've|I'd|I'll|me|my|mine|myself)(?![A-Za-z])")

for raw in sys.argv[1:]:
    path = pathlib.Path(raw)
    text = path.read_text()
    parts = text.split('---', 2)
    if len(parts) != 3:
        raise SystemExit(f"verify-documentary-voice: FAIL - malformed front matter: {path}")
    body = parts[2]
    section = ""
    outside = []
    retrospective = []
    for line in body.splitlines():
        if line.startswith('## '):
            section = line[3:].strip()
        matches = pronoun.findall(line)
        if not matches:
            continue
        if section == 'Retrospective':
            retrospective.extend((line.strip(), m) for m in matches)
        else:
            outside.extend((line.strip(), m) for m in matches)

    if outside:
        sample = outside[0][0]
        raise SystemExit(
            f"verify-documentary-voice: FAIL - {path} uses first-person singular outside Retrospective: {sample}"
        )
    if len(retrospective) > 6:
        raise SystemExit(
            f"verify-documentary-voice: FAIL - {path} uses first-person singular {len(retrospective)} times in Retrospective; cap is 6"
        )

print('verify-documentary-voice:   ok - first-person singular is confined to sparse retrospective use')
PY

printf 'verify-documentary-voice: PASS\n'
