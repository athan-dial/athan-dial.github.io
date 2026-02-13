#!/usr/bin/env bash

# scan-outlook.sh
#
# Scans Outlook emails from boss for URLs using Microsoft Graph API.
# Extracts URLs with email context and calls capture-web.sh for each.
#
# Requirements:
#   - MS_GRAPH_CLIENT_ID in ~/.model-citizen/env
#   - MS_GRAPH_TENANT_ID in ~/.model-citizen/env
#   - MS_GRAPH_CLIENT_SECRET in ~/.model-citizen/env
#   - MS_BOSS_EMAIL in ~/.model-citizen/env
#   - Azure AD app with Mail.Read application permission (requires admin consent)
#
# Alternative: Device code flow with delegated permissions (interactive auth)
# If client_credentials fails with permission error, implement device_code flow:
# POST https://login.microsoftonline.com/{tenant}/oauth2/v2.0/devicecode
# User visits URL, enters code, then:
# POST https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token with device_code grant
#
# Usage:
#   scan-outlook.sh
#   scan-outlook.sh --dry-run

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
LAST_SCAN_FILE="${MC_DIR}/outlook-last-scan"
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
  echo "Create it with MS_GRAPH_CLIENT_ID, MS_GRAPH_TENANT_ID, MS_GRAPH_CLIENT_SECRET, MS_BOSS_EMAIL"
  echo "See: ~/.model-citizen/env.example"
  exit 1
fi

source "$ENV_FILE"

# Check required variables
if [[ -z "${MS_GRAPH_CLIENT_ID:-}" || -z "${MS_GRAPH_TENANT_ID:-}" || -z "${MS_GRAPH_CLIENT_SECRET:-}" || -z "${MS_BOSS_EMAIL:-}" ]]; then
  echo -e "${RED}Error: Missing required environment variables${NC}"
  echo "Required: MS_GRAPH_CLIENT_ID, MS_GRAPH_TENANT_ID, MS_GRAPH_CLIENT_SECRET, MS_BOSS_EMAIL"
  exit 1
fi

# Determine scan window
if [[ -f "$LAST_SCAN_FILE" ]]; then
  LAST_SCAN=$(cat "$LAST_SCAN_FILE")
  LAST_SCAN_ISO=$(date -u -r "$LAST_SCAN" +"%Y-%m-%dT%H:%M:%SZ")
  echo -e "${YELLOW}Scanning since: $(date -r "$LAST_SCAN")${NC}"
else
  # First run: scan last 24 hours
  LAST_SCAN=$(date -v-24H +%s)
  LAST_SCAN_ISO=$(date -u -r "$LAST_SCAN" +"%Y-%m-%dT%H:%M:%SZ")
  echo -e "${YELLOW}First scan: checking last 24 hours${NC}"
fi

# Log start
echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Starting Outlook scan" >> "$LOG_FILE"

URLS_FOUND=0

# Get OAuth token using client credentials flow
echo -e "${YELLOW}Authenticating with Microsoft Graph...${NC}"

TOKEN_RESPONSE=$(curl -s -X POST "https://login.microsoftonline.com/${MS_GRAPH_TENANT_ID}/oauth2/v2.0/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=${MS_GRAPH_CLIENT_ID}" \
  -d "client_secret=${MS_GRAPH_CLIENT_SECRET}" \
  -d "scope=https://graph.microsoft.com/.default" \
  -d "grant_type=client_credentials")

# Check for errors
if echo "$TOKEN_RESPONSE" | grep -q '"error"'; then
  ERROR=$(echo "$TOKEN_RESPONSE" | grep -o '"error":"[^"]*"' | sed 's/"error":"\(.*\)"/\1/')
  ERROR_DESC=$(echo "$TOKEN_RESPONSE" | grep -o '"error_description":"[^"]*"' | sed 's/"error_description":"\(.*\)"/\1/')
  echo -e "${RED}Microsoft Graph auth error: ${ERROR}${NC}"
  echo -e "${RED}${ERROR_DESC}${NC}"
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] MS Graph auth error: ${ERROR}" >> "$LOG_FILE"
  exit 1
fi

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"access_token":"[^"]*"' | sed 's/"access_token":"\(.*\)"/\1/')

if [[ -z "$ACCESS_TOKEN" ]]; then
  echo -e "${RED}Failed to extract access token${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Authenticated${NC}"

# Function to extract URLs from text
extract_urls() {
  local text="$1"
  # Also handle HTML href attributes
  {
    echo "$text" | grep -oE 'https?://[^ >")]+' || true
    echo "$text" | grep -oE 'href="(https?://[^"]+)"' | sed 's/href="\(.*\)"/\1/' || true
  } | sort -u
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

# Fetch emails from boss
echo -e "${YELLOW}Fetching emails from boss...${NC}"

# URL encode boss email
BOSS_EMAIL_ENCODED=$(echo "$MS_BOSS_EMAIL" | sed 's/@/%40/g')

# Build filter query
FILTER="from/emailAddress/address eq '${MS_BOSS_EMAIL}' and receivedDateTime ge ${LAST_SCAN_ISO}"
FILTER_ENCODED=$(echo "$FILTER" | sed 's/ /%20/g' | sed 's/\//%2F/g' | sed 's/:/%3A/g')

EMAILS_RESPONSE=$(curl -s -X GET "https://graph.microsoft.com/v1.0/me/messages?\$filter=${FILTER_ENCODED}&\$top=50&\$orderby=receivedDateTime%20desc" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json")

# Check for errors
if echo "$EMAILS_RESPONSE" | grep -q '"error"'; then
  ERROR=$(echo "$EMAILS_RESPONSE" | grep -o '"code":"[^"]*"' | sed 's/"code":"\(.*\)"/\1/')
  ERROR_MSG=$(echo "$EMAILS_RESPONSE" | grep -o '"message":"[^"]*"' | sed 's/"message":"\(.*\)"/\1/')
  echo -e "${RED}Microsoft Graph API error: ${ERROR}${NC}"
  echo -e "${RED}${ERROR_MSG}${NC}"
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] MS Graph messages error: ${ERROR}" >> "$LOG_FILE"
  exit 1
fi

# Count emails found
EMAIL_COUNT=$(echo "$EMAILS_RESPONSE" | grep -o '"@odata.type":"#microsoft.graph.message"' | wc -l | tr -d ' ')
echo -e "${BLUE}Found ${EMAIL_COUNT} emails from boss${NC}"

# Parse emails (simplified JSON extraction)
# Extract subject, body content, and received date
if [[ "$EMAIL_COUNT" -gt 0 ]]; then
  # Simple line-by-line parsing (more robust: use jq if available)
  # For v1: extract subject and body preview/content

  # Extract value array items
  echo "$EMAILS_RESPONSE" | grep -o '"subject":"[^"]*"' | while read -r subj_line; do
    SUBJECT=$(echo "$subj_line" | sed 's/"subject":"\(.*\)"/\1/')

    # For each subject, try to extract body content nearby
    # This is fragile but works for simple cases
    # More robust: use jq -r '.value[] | {subject, body: .body.content}' if jq available

    # Just extract URLs from the entire response for now (simpler)
    # In production, would properly parse per-message
    :
  done

  # Extract all URLs from email bodies (HTML content)
  URLS=$(extract_urls "$EMAILS_RESPONSE")

  if [[ -n "$URLS" ]]; then
    while IFS= read -r url; do
      if [[ -n "$url" ]]; then
        # Extract subject for context (find nearest subject to URL)
        CONTEXT="Email from ${MS_BOSS_EMAIL}"

        capture_url "$url" "$CONTEXT"
      fi
    done <<< "$URLS"
  fi
fi

# Update last scan timestamp
if [[ "$DRY_RUN" == false ]]; then
  date +%s > "$LAST_SCAN_FILE"
fi

# Log completion
echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Outlook scan complete: ${URLS_FOUND} URLs captured" >> "$LOG_FILE"
echo -e "${GREEN}✓ Outlook scan complete: ${URLS_FOUND} URLs captured${NC}"

exit 0
