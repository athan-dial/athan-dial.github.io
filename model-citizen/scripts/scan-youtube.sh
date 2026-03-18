#!/usr/bin/env bash
# scan-youtube.sh
# Pipeline A YouTube ingestion — reads MacWhisper DB, writes to 2B-new/700 Model Citizen vault.
# Called by scan-all.sh. Wraps ingest-youtube.py from the-agency skills.
#
# Usage:
#   scan-youtube.sh [--dry-run]

set -euo pipefail

THE_AGENCY_DIR="$HOME/Github/the-agency"
INGEST_SCRIPT="$THE_AGENCY_DIR/skills/ingest-youtube/ingest-youtube.py"

DRY_RUN=""
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN="--dry-run"
fi

echo "[scan-youtube] Starting YouTube ingest (MacWhisper → vault)..."
python3 "$INGEST_SCRIPT" $DRY_RUN
echo "[scan-youtube] Scan complete."
