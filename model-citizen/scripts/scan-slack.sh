#!/usr/bin/env bash

# scan-slack.sh
#
# Scans Slack for URLs from:
# 1. Saved/starred items
# 2. Direct messages with boss
#
# Extracts URLs with surrounding context and calls capture-web.sh for each.
#
# Requirements:
#   - SLACK_BOT_TOKEN in ~/.model-citizen/env
#   - SLACK_BOSS_USER_ID in ~/.model-citizen/env
#   - Slack App with scopes: stars:read, im:history, im:read, users:read
#
# Usage:
#   scan-slack.sh
#   scan-slack.sh --dry-run

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MC_DIR="${HOME}/.model-citizen"
ENV_FILE="${MC_DIR}/env"
LAST_SCAN_FILE="${MC_DIR}/slack-last-scan"
LOG_FILE="${MC_DIR}/scan.log"

# Parse arguments
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  echo -e "${BLUE}[DRY RUN MODE]${NC}"
fi

# Create directories if needed
mkdir -p "$MC_DIR"

# Source environment variables
if [[ ! -f "$ENV_FILE" ]]; then
  echo -e "${RED}Error: ~/.model-citizen/env not found${NC}"
  echo "Create it with: SLACK_BOT_TOKEN=xoxb-... and SLACK_BOSS_USER_ID=U..."
  echo "See: ~/.model-citizen/env.example"
  exit 1
fi

source "$ENV_FILE"

# Check required variables
if [[ -z "${SLACK_BOT_TOKEN:-}" ]]; then
  echo -e "${RED}Error: SLACK_BOT_TOKEN not set in ~/.model-citizen/env${NC}"
  exit 1
fi

if [[ -z "${SLACK_BOSS_USER_ID:-}" ]]; then
  echo -e "${RED}Error: SLACK_BOSS_USER_ID not set in ~/.model-citizen/env${NC}"
  exit 1
fi

# Determine scan window
if [[ -f "$LAST_SCAN_FILE" ]]; then
  LAST_SCAN=$(cat "$LAST_SCAN_FILE")
  echo -e "${YELLOW}Scanning since: $(date -r "$LAST_SCAN")${NC}"
else
  # First run: scan last 24 hours
  LAST_SCAN=$(date -v-24H +%s)
  echo -e "${YELLOW}First scan: checking last 24 hours${NC}"
fi

# Log start
echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Starting Slack scan" >> "$LOG_FILE"

URLS_FOUND=0

# Function to extract URLs from text
extract_urls() {
  local text="$1"
  echo "$text" | grep -oE 'https?://[^ >)]+' || true
}

# Function to capture URL with context
capture_url() {
  local url="$1"
  local context="$2"

  echo -e "${BLUE}  Found URL: ${url}${NC}"

  if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}  [DRY RUN] Would capture with context: ${context}${NC}"
    return
  fi

  # Call capture-web.sh with context
  if "$SCRIPT_DIR/capture-web.sh" "$url" --note "$context"; then
    echo -e "${GREEN}  ✓ Captured${NC}"
    ((URLS_FOUND++)) || true
  else
    echo -e "${RED}  ✗ Failed to capture${NC}"
  fi
}

# 1. Scan saved/starred items
echo -e "${YELLOW}Scanning starred items...${NC}"

STARS_RESPONSE=$(curl -s -X GET "https://slack.com/api/stars.list" \
  -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
  -H "Content-Type: application/json")

# Check for API errors
if echo "$STARS_RESPONSE" | grep -q '"ok":false'; then
  ERROR=$(echo "$STARS_RESPONSE" | grep -o '"error":"[^"]*"' | sed 's/"error":"\(.*\)"/\1/')
  echo -e "${RED}Slack API error (stars.list): ${ERROR}${NC}"
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Slack stars.list error: ${ERROR}" >> "$LOG_FILE"
else
  # Parse starred items (simple JSON extraction)
  # Extract messages and channels with timestamps
  echo "$STARS_RESPONSE" | grep -o '"type":"message"' > /dev/null && {
    # Extract message items
    ITEMS=$(echo "$STARS_RESPONSE" | grep -o '"message":{[^}]*"text":"[^"]*"[^}]*"ts":"[0-9.]*"' || true)

    while IFS= read -r item; do
      if [[ -z "$item" ]]; then continue; fi

      # Extract text and timestamp
      TEXT=$(echo "$item" | sed -n 's/.*"text":"\([^"]*\)".*/\1/p')
      TS=$(echo "$item" | sed -n 's/.*"ts":"\([0-9.]*\)".*/\1/p')

      # Check if within scan window (timestamp is epoch.microseconds)
      TS_EPOCH=${TS%.*}
      if [[ "$TS_EPOCH" -lt "$LAST_SCAN" ]]; then
        continue
      fi

      # Extract URLs from text
      URLS=$(extract_urls "$TEXT")
      if [[ -n "$URLS" ]]; then
        while IFS= read -r url; do
          if [[ -n "$url" ]]; then
            capture_url "$url" "Slack starred: ${TEXT:0:100}"
          fi
        done <<< "$URLS"
      fi
    done <<< "$ITEMS"
  }
fi

# 2. Scan boss DMs
echo -e "${YELLOW}Scanning DMs with boss...${NC}"

# Find DM channel with boss
CONVERSATIONS_RESPONSE=$(curl -s -X GET "https://slack.com/api/conversations.list?types=im" \
  -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
  -H "Content-Type: application/json")

if echo "$CONVERSATIONS_RESPONSE" | grep -q '"ok":false'; then
  ERROR=$(echo "$CONVERSATIONS_RESPONSE" | grep -o '"error":"[^"]*"' | sed 's/"error":"\(.*\)"/\1/')
  echo -e "${RED}Slack API error (conversations.list): ${ERROR}${NC}"
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Slack conversations.list error: ${ERROR}" >> "$LOG_FILE"
else
  # Find channel ID for boss DM
  # Look for channel with matching user ID
  BOSS_CHANNEL=$(echo "$CONVERSATIONS_RESPONSE" | grep -o '"id":"[^"]*"[^}]*"user":"'"${SLACK_BOSS_USER_ID}"'"' | sed -n 's/.*"id":"\([^"]*\)".*/\1/p' | head -1)

  if [[ -z "$BOSS_CHANNEL" ]]; then
    echo -e "${YELLOW}No DM channel found with boss${NC}"
  else
    echo -e "${BLUE}Found boss DM channel: ${BOSS_CHANNEL}${NC}"

    # Fetch conversation history
    HISTORY_RESPONSE=$(curl -s -X GET "https://slack.com/api/conversations.history?channel=${BOSS_CHANNEL}&oldest=${LAST_SCAN}" \
      -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
      -H "Content-Type: application/json")

    if echo "$HISTORY_RESPONSE" | grep -q '"ok":false'; then
      ERROR=$(echo "$HISTORY_RESPONSE" | grep -o '"error":"[^"]*"' | sed 's/"error":"\(.*\)"/\1/')
      echo -e "${RED}Slack API error (conversations.history): ${ERROR}${NC}"
      echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Slack conversations.history error: ${ERROR}" >> "$LOG_FILE"
    else
      # Parse messages
      MESSAGES=$(echo "$HISTORY_RESPONSE" | grep -o '"text":"[^"]*"' || true)

      while IFS= read -r msg; do
        if [[ -z "$msg" ]]; then continue; fi

        # Extract text
        TEXT=$(echo "$msg" | sed 's/"text":"\(.*\)"/\1/')

        # Extract URLs
        URLS=$(extract_urls "$TEXT")
        if [[ -n "$URLS" ]]; then
          while IFS= read -r url; do
            if [[ -n "$url" ]]; then
              capture_url "$url" "Boss DM: ${TEXT:0:100}"
            fi
          done <<< "$URLS"
        fi
      done <<< "$MESSAGES"
    fi
  fi
fi

# Update last scan timestamp
if [[ "$DRY_RUN" == false ]]; then
  date +%s > "$LAST_SCAN_FILE"
fi

# Log completion
echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Slack scan complete: ${URLS_FOUND} URLs captured" >> "$LOG_FILE"
echo -e "${GREEN}✓ Slack scan complete: ${URLS_FOUND} URLs captured${NC}"

exit 0
