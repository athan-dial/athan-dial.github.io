#!/usr/bin/env bash
# Explicit, non-overwriting GitHub label bootstrap. Run only with tracker write authorization.
set -euo pipefail
repo=athan-dial/athan-dial.github.io
command -v gh >/dev/null 2>&1 || { echo "gh is required" >&2; exit 1; }
existing="$(gh label list --repo "$repo" --limit 1000 --json name --jq '.[].name')"
ensure() {
  local name="$1" color="$2" description="$3"
  if printf '%s\n' "$existing" | grep -Fxq -- "$name"; then
    printf 'retain %s\n' "$name"
  else
    gh label create "$name" --repo "$repo" --color "$color" --description "$description"
  fi
}
ensure needs-triage EDEDED "Unassessed work"
ensure needs-info D876E3 "Missing decision, requirement or evidence"
ensure ready-for-agent 0E8A16 "Specified, authorized and unblocked"
ensure ready-for-human FBCA04 "Human judgment or approval required"
ensure wontfix FFFFFF "Deliberately not planned"
gh label list --repo "$repo" --limit 1000 --json name --jq '.[].name'
