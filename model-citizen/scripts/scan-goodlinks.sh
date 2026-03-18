#!/usr/bin/env bash
# scan-goodlinks.sh
# Pipeline A GoodLinks ingestion — writes to 2B-new/700 Model Citizen vault.
# Called by scan-all.sh. Wraps goodlinks-query.py with the correct output dir.
#
# Usage:
#   scan-goodlinks.sh [--dry-run]

set -euo pipefail

GOODLINKS_SCRIPT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault/scripts/goodlinks-query.py"
OUTPUT_DIR="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/sources/goodlinks"
PYTHON="/opt/homebrew/bin/python3.12"

DRY_RUN=""
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN="--dry-run"
fi

mkdir -p "$OUTPUT_DIR"

"$PYTHON" "$GOODLINKS_SCRIPT" --output-dir "$OUTPUT_DIR" $DRY_RUN
