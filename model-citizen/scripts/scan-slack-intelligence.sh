#!/bin/bash
# Slack Intelligence Scanner — Pipeline A
# Invoked by scan-all.sh
#
# SECURITY: This script runs Pipeline A (personal/public) Slack ingestion.
# Channel scope is enforced by the ingest-slack skill allowlist at:
#   skills/ingest-slack/pipeline-a-channels.yaml (the-agency repo)
#
# Previously called: claude --command scan-slack-intelligence
# Updated 2026-03-18 (THE-57): replaced with ingest-slack PIPELINE=A
# to enforce explicit allowlist. Old command scanned #tech-team, #dr-pe,
# #team-schema (Montai internal) — hard constraint violation.

set -euo pipefail

STATE_FILE="$HOME/.model-citizen/slack-intelligence-state.json"

# Ensure state file exists
if [[ ! -f "$STATE_FILE" ]]; then
  echo '{"last_scan_ts": 0, "seen_ids": []}' > "$STATE_FILE"
fi

# Run Pipeline A ingest via the corrected ingest-slack skill
# PIPELINE=A enforces the allowlist in skills/ingest-slack/pipeline-a-channels.yaml
echo "[slack-intelligence] Starting Pipeline A Slack ingest (allowlist enforced)..."
claude --skill ingest-slack -- PIPELINE=A
echo "[slack-intelligence] Scan complete."
