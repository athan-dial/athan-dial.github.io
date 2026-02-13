#!/usr/bin/env bash

# capture-queue.sh
#
# Queue-based capture system for web articles. Enables async capture from macOS Shortcuts.
#
# Two modes:
#   1. Add to queue: capture-queue.sh add "URL" ["optional note"]
#   2. Process queue: capture-queue.sh process
#
# Queue file: ~/.model-citizen/capture-queue.txt (JSON lines)
#
# SHORTCUTS INTEGRATION
# ---------------------
# Create a macOS Shortcut named "Capture to Vault" with these steps:
#
# 1. Receive "URLs" and "Safari web pages" from Share Sheet
# 2. Get variable: URL from "Shortcut Input"
# 3. Ask for Input: "Add a note?" (optional, can be left blank)
# 4. Set variable: Note to "Provided Input"
# 5. Run Shell Script:
#      Input: Text
#      Script: /Users/adial/Documents/GitHub/athan-dial.github.io/model-citizen/scripts/capture-queue.sh add "$URL" "$Note"
# 6. Show Notification: "Queued for capture"
#
# To enable in iOS/iPadOS:
# - Install Shortcuts app and sync via iCloud
# - In Safari, tap Share → Add to Home Screen for quick access
# - Or use "Hey Siri, run Capture to Vault"

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
QUEUE_DIR="$HOME/.model-citizen"
QUEUE_FILE="$QUEUE_DIR/capture-queue.txt"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure queue directory exists
mkdir -p "$QUEUE_DIR"

# Mode: add or process
MODE="${1:-}"

if [[ "$MODE" == "add" ]]; then
  # Add URL to queue
  URL="${2:-}"
  NOTE="${3:-}"

  if [[ -z "$URL" ]]; then
    echo -e "${RED}Error: URL required${NC}"
    echo "Usage: capture-queue.sh add \"https://example.com\" [\"optional note\"]"
    exit 1
  fi

  # Create JSON entry
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  JSON_ENTRY=$(cat <<EOF
{"url":"$URL","note":"$NOTE","ts":"$TIMESTAMP"}
EOF
)

  # Append to queue file
  echo "$JSON_ENTRY" >> "$QUEUE_FILE"

  echo -e "${GREEN}✓ Added to capture queue${NC}"
  echo "  URL: $URL"
  if [[ -n "$NOTE" ]]; then
    echo "  Note: $NOTE"
  fi

elif [[ "$MODE" == "process" ]]; then
  # Process queue
  if [[ ! -f "$QUEUE_FILE" ]] || [[ ! -s "$QUEUE_FILE" ]]; then
    echo -e "${YELLOW}Queue is empty${NC}"
    exit 0
  fi

  echo -e "${YELLOW}Processing capture queue...${NC}"

  # Read queue file line by line
  FAILED_ENTRIES=""
  SUCCESS_COUNT=0
  FAIL_COUNT=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Parse JSON (simple extraction for robustness)
    URL=$(echo "$line" | grep -o '"url":"[^"]*"' | sed 's/"url":"\(.*\)"/\1/')
    NOTE=$(echo "$line" | grep -o '"note":"[^"]*"' | sed 's/"note":"\(.*\)"/\1/' || echo "")

    echo ""
    echo -e "${YELLOW}→ Processing: ${URL}${NC}"

    # Invoke capture-web.sh
    if [[ -n "$NOTE" ]]; then
      if bash "$SCRIPT_DIR/capture-web.sh" "$URL" --note "$NOTE"; then
        ((SUCCESS_COUNT++))
      else
        echo -e "${RED}✗ Failed to capture${NC}"
        FAILED_ENTRIES="${FAILED_ENTRIES}${line}\n"
        ((FAIL_COUNT++))
      fi
    else
      if bash "$SCRIPT_DIR/capture-web.sh" "$URL"; then
        ((SUCCESS_COUNT++))
      else
        echo -e "${RED}✗ Failed to capture${NC}"
        FAILED_ENTRIES="${FAILED_ENTRIES}${line}\n"
        ((FAIL_COUNT++))
      fi
    fi
  done < "$QUEUE_FILE"

  # Clear or update queue file
  if [[ -z "$FAILED_ENTRIES" ]]; then
    # All processed successfully - clear queue
    > "$QUEUE_FILE"
    echo ""
    echo -e "${GREEN}✓ Queue processed: ${SUCCESS_COUNT} captured${NC}"
  else
    # Some failed - keep failed entries
    echo -e "$FAILED_ENTRIES" > "$QUEUE_FILE"
    echo ""
    echo -e "${YELLOW}⚠ Queue processed: ${SUCCESS_COUNT} captured, ${FAIL_COUNT} failed (retained in queue)${NC}"
  fi

else
  # Invalid mode
  echo -e "${RED}Error: Invalid mode${NC}"
  echo ""
  echo "Usage:"
  echo "  capture-queue.sh add \"URL\" [\"note\"]     - Add URL to queue"
  echo "  capture-queue.sh process                   - Process queued URLs"
  exit 1
fi
