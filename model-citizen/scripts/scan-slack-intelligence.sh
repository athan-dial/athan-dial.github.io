#!/bin/bash
# Slack Intelligence Scanner — Phase 15
# Invoked by scan-all.sh (Phase 16 wiring)
# Direct execution: claude --command scan-slack-intelligence

set -euo pipefail

STATE_FILE="$HOME/.model-citizen/slack-intelligence-state.json"

# Ensure state file exists
if [[ ! -f "$STATE_FILE" ]]; then
  echo '{"last_scan_ts": 0, "seen_ids": []}' > "$STATE_FILE"
fi

# Run the intelligence scanner command via Claude Code
echo "[slack-intelligence] Starting Slack intelligence scan..."
claude --command scan-slack-intelligence
echo "[slack-intelligence] Scan complete."
