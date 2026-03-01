#!/bin/bash
# Outlook Intelligence Scanner — Phase 15
# Invoked by scan-all.sh (Phase 16 wiring)
# Direct execution: claude --command scan-outlook-intelligence

set -euo pipefail

STATE_FILE="$HOME/.model-citizen/outlook-intelligence-state.json"

# Ensure state file exists
if [[ ! -f "$STATE_FILE" ]]; then
  echo '{"last_scan_ts": 0, "seen_ids": []}' > "$STATE_FILE"
fi

# Run the intelligence scanner command via Claude Code
echo "[outlook-intelligence] Starting Outlook intelligence scan..."
claude --command scan-outlook-intelligence
echo "[outlook-intelligence] Scan complete."
