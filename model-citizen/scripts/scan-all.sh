#!/usr/bin/env bash

# scan-all.sh
#
# Orchestrates all content scanners:
# 1. Slack (saved items + boss DMs)
# 2. Outlook (boss emails)
# 3. Web capture queue (process pending items)
# 4. GoodLinks (saved articles)
#
# Continues on individual scanner failures to maximize capture.
# Retries each scanner once before declaring failure.
# Sends macOS notification if any scanner fails.
#
# Installation: launchctl load ~/Library/LaunchAgents/com.model-citizen.daily-scan.plist
# Uninstall: launchctl unload ~/Library/LaunchAgents/com.model-citizen.daily-scan.plist
# Test: launchctl start com.model-citizen.daily-scan
#
# Usage:
#   scan-all.sh
#   scan-all.sh --dry-run

set -euo pipefail

# Retry helper: run command once, retry once after 3s on failure
run_with_retry() {
  if "$@" 2>&1; then
    return 0
  fi
  echo -e "${YELLOW}  Retrying in 3 seconds...${NC}"
  sleep 3
  "$@" 2>&1
}

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MC_DIR="${HOME}/.model-citizen"
ENV_FILE="${MC_DIR}/env"

# Parse arguments
DRY_RUN=""
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN="--dry-run"
  echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
  echo -e "${CYAN}       MODEL CITIZEN SCANNER [DRY RUN]${NC}"
  echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
else
  echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
  echo -e "${CYAN}          MODEL CITIZEN SCANNER${NC}"
  echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
fi
echo ""

# Create directories if needed
mkdir -p "$MC_DIR"

# Source environment variables if available (for credentials check)
if [[ -f "$ENV_FILE" ]]; then
  source "$ENV_FILE"
fi

# Track results
SLACK_URLS=0
OUTLOOK_URLS=0
QUEUE_URLS=0
GOODLINKS_URLS=0
GOODLINKS_DEDUP=0
SLACK_STATUS="SKIPPED"
OUTLOOK_STATUS="SKIPPED"
QUEUE_STATUS="SKIPPED"
GOODLINKS_STATUS="SKIPPED"

# 1. Slack Scanner
echo -e "${BLUE}▶ Running Slack scanner...${NC}"
echo ""

if [[ -z "${SLACK_BOT_TOKEN:-}" || -z "${SLACK_BOSS_USER_ID:-}" ]]; then
  echo -e "${YELLOW}⚠ Slack credentials not configured (SLACK_BOT_TOKEN, SLACK_BOSS_USER_ID)${NC}"
  echo -e "${YELLOW}  Skipping Slack scan${NC}"
  SLACK_STATUS="SKIPPED"
else
  if "$SCRIPT_DIR/scan-slack.sh" $DRY_RUN 2>&1 | tee /tmp/scan-slack.log; then
    SLACK_URLS=$(grep -o 'Slack scan complete: [0-9]* URLs captured' /tmp/scan-slack.log | grep -o '[0-9]*' || echo "0")
    SLACK_STATUS="SUCCESS"
    echo -e "${GREEN}✓ Slack scan complete${NC}"
  else
    SLACK_STATUS="FAILED"
    echo -e "${RED}✗ Slack scan failed${NC}"
  fi
fi

echo ""

# 2. Outlook Scanner
echo -e "${BLUE}▶ Running Outlook scanner...${NC}"
echo ""

if [[ -z "${MS_GRAPH_CLIENT_ID:-}" || -z "${MS_GRAPH_TENANT_ID:-}" || -z "${MS_GRAPH_CLIENT_SECRET:-}" || -z "${MS_BOSS_EMAIL:-}" ]]; then
  echo -e "${YELLOW}⚠ Outlook credentials not configured (MS_GRAPH_*, MS_BOSS_EMAIL)${NC}"
  echo -e "${YELLOW}  Skipping Outlook scan${NC}"
  OUTLOOK_STATUS="SKIPPED"
else
  if "$SCRIPT_DIR/scan-outlook.sh" $DRY_RUN 2>&1 | tee /tmp/scan-outlook.log; then
    OUTLOOK_URLS=$(grep -o 'Outlook scan complete: [0-9]* URLs captured' /tmp/scan-outlook.log | grep -o '[0-9]*' || echo "0")
    OUTLOOK_STATUS="SUCCESS"
    echo -e "${GREEN}✓ Outlook scan complete${NC}"
  else
    OUTLOOK_STATUS="FAILED"
    echo -e "${RED}✗ Outlook scan failed${NC}"
  fi
fi

echo ""

# 3. Web Capture Queue
echo -e "${BLUE}▶ Processing web capture queue...${NC}"
echo ""

if [[ -f "$SCRIPT_DIR/capture-queue.sh" ]]; then
  if "$SCRIPT_DIR/capture-queue.sh" process $DRY_RUN 2>&1 | tee /tmp/scan-queue.log; then
    QUEUE_URLS=$(grep -o 'Processed [0-9]* items' /tmp/scan-queue.log | grep -o '[0-9]*' || echo "0")
    QUEUE_STATUS="SUCCESS"
    echo -e "${GREEN}✓ Queue processing complete${NC}"
  else
    QUEUE_STATUS="FAILED"
    echo -e "${RED}✗ Queue processing failed${NC}"
  fi
else
  echo -e "${YELLOW}⚠ capture-queue.sh not found${NC}"
  QUEUE_STATUS="SKIPPED"
fi

echo ""

# 4. GoodLinks Scanner
echo -e "${BLUE}▶ Running GoodLinks scanner...${NC}"
echo ""

GOODLINKS_DB="$HOME/Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite"
VAULT_SCRIPTS="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault/scripts"

if [[ ! -f "$GOODLINKS_DB" ]]; then
  echo -e "${YELLOW}⚠ GoodLinks database not found${NC}"
  echo -e "${YELLOW}  Skipping GoodLinks scan${NC}"
  GOODLINKS_STATUS="SKIPPED"
else
  if run_with_retry "$VAULT_SCRIPTS/ingest-goodlinks.sh" $DRY_RUN 2>&1 | tee /tmp/scan-goodlinks.log; then
    GOODLINKS_URLS=$(grep -o '[0-9]* notes created' /tmp/scan-goodlinks.log | grep -o '[0-9]*' || echo "0")
    GOODLINKS_DEDUP=$(grep -o '[0-9]* duplicates skipped' /tmp/scan-goodlinks.log | grep -o '[0-9]*' || echo "0")
    GOODLINKS_STATUS="SUCCESS"
    echo -e "${GREEN}✓ GoodLinks scan complete${NC}"
  else
    GOODLINKS_STATUS="FAILED"
    echo -e "${RED}✗ GoodLinks scan failed${NC}"
  fi
fi

echo ""

# Notify on failures
FAILURES=""
[[ "$SLACK_STATUS" == "FAILED" ]] && FAILURES="${FAILURES}Slack "
[[ "$OUTLOOK_STATUS" == "FAILED" ]] && FAILURES="${FAILURES}Outlook "
[[ "$QUEUE_STATUS" == "FAILED" ]] && FAILURES="${FAILURES}Queue "
[[ "$GOODLINKS_STATUS" == "FAILED" ]] && FAILURES="${FAILURES}GoodLinks "

if [[ -n "$FAILURES" ]]; then
  osascript -e "display notification \"Failed: ${FAILURES}\" with title \"Model Citizen Scanner\" sound name \"Basso\"" 2>/dev/null || true
fi

# Summary
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}              SCAN SUMMARY${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo ""

# Calculate totals
TOTAL_URLS=$((SLACK_URLS + OUTLOOK_URLS + QUEUE_URLS + GOODLINKS_URLS))

# Format status with colors
format_status() {
  case "$1" in
    SUCCESS)
      echo -e "${GREEN}✓ $1${NC}"
      ;;
    FAILED)
      echo -e "${RED}✗ $1${NC}"
      ;;
    SKIPPED)
      echo -e "${YELLOW}⊘ $1${NC}"
      ;;
    *)
      echo "$1"
      ;;
  esac
}

echo "Slack:     $(format_status "$SLACK_STATUS")   (${SLACK_URLS} URLs)"
echo "Outlook:   $(format_status "$OUTLOOK_STATUS")   (${OUTLOOK_URLS} URLs)"
echo "Queue:     $(format_status "$QUEUE_STATUS")   (${QUEUE_URLS} items)"
echo "GoodLinks: $(format_status "$GOODLINKS_STATUS")   (${GOODLINKS_URLS} notes, ${GOODLINKS_DEDUP} dedup)"
echo ""
echo -e "${CYAN}Total: ${TOTAL_URLS} URLs captured${NC}"
echo ""

# Exit with error if all scanners failed
if [[ "$SLACK_STATUS" == "FAILED" && "$OUTLOOK_STATUS" == "FAILED" && "$QUEUE_STATUS" == "FAILED" && "$GOODLINKS_STATUS" == "FAILED" ]]; then
  echo -e "${RED}All scanners failed${NC}"
  exit 1
fi

# Clean up temp logs
rm -f /tmp/scan-slack.log /tmp/scan-outlook.log /tmp/scan-queue.log /tmp/scan-goodlinks.log

echo -e "${GREEN}✓ Scan complete${NC}"
echo ""

exit 0
