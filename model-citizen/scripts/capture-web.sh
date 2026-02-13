#!/usr/bin/env bash

# capture-web.sh
#
# Captures web articles to Obsidian vault using @mozilla/readability extraction.
# Detects duplicate URLs and merges context instead of creating duplicate notes.
#
# Usage:
#   capture-web.sh "https://example.com/article"
#   capture-web.sh "https://example.com/article" --note "boss recommended"
#
# Requirements:
#   - Node.js 18+ (for native fetch)
#   - npm dependencies installed in same directory (run: npm install)

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_INBOX="/Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/000 System/01 Inbox"
VAULT_MODEL_CITIZEN="/Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen"

# Parse arguments
URL=""
NOTE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --note)
      NOTE="$2"
      shift 2
      ;;
    *)
      if [[ -z "$URL" ]]; then
        URL="$1"
      fi
      shift
      ;;
  esac
done

if [[ -z "$URL" ]]; then
  echo -e "${RED}Error: URL required${NC}"
  echo "Usage: capture-web.sh \"https://example.com\" [--note \"context\"]"
  exit 1
fi

echo -e "${YELLOW}Extracting article from: ${URL}${NC}"

# Extract article using Node.js script
ARTICLE_JSON=$(node "$SCRIPT_DIR/extract-article.mjs" "$URL" 2>&1)
EXIT_CODE=$?

if [[ $EXIT_CODE -ne 0 ]]; then
  echo -e "${RED}Failed to extract article${NC}"
  echo "$ARTICLE_JSON"
  exit 1
fi

# Parse JSON (using jq-style extraction with grep/sed for portability)
TITLE=$(echo "$ARTICLE_JSON" | grep -o '"title": "[^"]*"' | head -1 | sed 's/"title": "\(.*\)"/\1/')
BYLINE=$(echo "$ARTICLE_JSON" | grep -o '"byline": "[^"]*"' | head -1 | sed 's/"byline": "\(.*\)"/\1/')
EXCERPT=$(echo "$ARTICLE_JSON" | grep -o '"excerpt": "[^"]*"' | head -1 | sed 's/"excerpt": "\(.*\)"/\1/')
SITE_NAME=$(echo "$ARTICLE_JSON" | grep -o '"siteName": "[^"]*"' | head -1 | sed 's/"siteName": "\(.*\)"/\1/')

# Extract content (multiline JSON string - more complex)
CONTENT=$(echo "$ARTICLE_JSON" | sed -n '/"content":/,/"url":/p' | sed '1d;$d' | sed 's/^[[:space:]]*//')

if [[ -z "$TITLE" ]]; then
  TITLE="Untitled Article"
fi

# Generate filename from title (slugify: lowercase, spaces to hyphens, max 60 chars)
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//' | cut -c1-60)
DATE=$(date +%Y%m%d)
FILENAME="${DATE}-${SLUG}.md"

# Check for duplicate URL in vault
echo -e "${YELLOW}Checking for duplicates...${NC}"
EXISTING_FILE=$(grep -rl "^url: ${URL}$" "$VAULT_INBOX" "$VAULT_MODEL_CITIZEN" 2>/dev/null | head -1 || true)

if [[ -n "$EXISTING_FILE" ]]; then
  echo -e "${YELLOW}Duplicate URL found: ${EXISTING_FILE}${NC}"
  echo -e "${YELLOW}Appending context note instead of creating new file${NC}"

  # Append context to existing file
  TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
  echo "" >> "$EXISTING_FILE"
  echo "---" >> "$EXISTING_FILE"
  echo "" >> "$EXISTING_FILE"
  echo "**Re-captured:** ${TIMESTAMP}" >> "$EXISTING_FILE"
  if [[ -n "$NOTE" ]]; then
    echo "**Context:** ${NOTE}" >> "$EXISTING_FILE"
  fi

  echo -e "${GREEN}✓ Context appended to existing note${NC}"
  echo -e "  ${EXISTING_FILE}"
  exit 0
fi

# Create new note
NOTE_PATH="${VAULT_INBOX}/${FILENAME}"

# Generate frontmatter
cat > "$NOTE_PATH" <<EOF
---
title: "${TITLE}"
url: ${URL}
source_type: article
captured_at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
tags: []
site_name: "${SITE_NAME}"
---

EOF

# Add optional quick note
if [[ -n "$NOTE" ]]; then
  echo "> ${NOTE}" >> "$NOTE_PATH"
  echo "" >> "$NOTE_PATH"
fi

# Add summary section if excerpt exists
if [[ -n "$EXCERPT" ]]; then
  echo "## Summary" >> "$NOTE_PATH"
  echo "" >> "$NOTE_PATH"
  echo "$EXCERPT" >> "$NOTE_PATH"
  echo "" >> "$NOTE_PATH"
fi

# Add byline if exists
if [[ -n "$BYLINE" ]]; then
  echo "*By ${BYLINE}*" >> "$NOTE_PATH"
  echo "" >> "$NOTE_PATH"
fi

# Add content
echo "## Content" >> "$NOTE_PATH"
echo "" >> "$NOTE_PATH"
echo "$CONTENT" >> "$NOTE_PATH"

echo -e "${GREEN}✓ Article captured successfully${NC}"
echo -e "  ${NOTE_PATH}"
