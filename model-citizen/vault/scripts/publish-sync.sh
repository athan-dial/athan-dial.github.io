#!/bin/bash
#
# Publish Sync Script
#
# Syncs approved notes from vault to Quartz for public publishing.
# Dual approval: notes in publish_queue/ OR with status: publish frontmatter
#
# Usage:
#   publish-sync.sh [--dry-run] [--verbose]

set -euo pipefail

# Paths
VAULT_ROOT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault"
QUARTZ_ROOT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-quartz"
SCRIPTS_DIR="$VAULT_ROOT/scripts"
PUBLISH_QUEUE="$VAULT_ROOT/publish_queue"
QUARTZ_CONTENT="$QUARTZ_ROOT/content"
MC_ROOT="$HOME/.model-citizen"
TRACKING_FILE="$MC_ROOT/published-list.txt"
LOCK_FILE="$MC_ROOT/sync.lock"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Options
DRY_RUN=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            cat << 'EOF'
Usage: publish-sync.sh [options]

Options:
  --dry-run     Show what would happen without making changes
  --verbose     Show detailed per-file output
  --help        Show this help

Description:
  Syncs approved notes from vault to Quartz repository for public publishing.
  Handles frontmatter cleanup, asset copying, and idempotent tracking.

Approval modes:
  1. Folder-based: Notes in publish_queue/ folder
  2. Frontmatter-based: Notes with "status: publish" in any vault folder

Examples:
  publish-sync.sh                    # Normal operation
  publish-sync.sh --dry-run          # Preview changes
  publish-sync.sh --verbose          # Show detailed output
EOF
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

log() {
    if [ "$VERBOSE" = true ] || [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $*"
    fi
}

error() {
    echo -e "${RED}Error: $*${NC}" >&2
    exit 1
}

# Cleanup function
cleanup() {
    if [ -f "$LOCK_FILE" ]; then
        rm -f "$LOCK_FILE"
        log "Released lock file"
    fi
}

trap cleanup EXIT

# ============================================================================
# STEP 0: Acquire lock file
# ============================================================================

if [ -f "$LOCK_FILE" ]; then
    error "Another sync is already running (lock file exists: $LOCK_FILE)"
fi

if [ "$DRY_RUN" = false ]; then
    mkdir -p "$MC_ROOT"
    echo "$$" > "$LOCK_FILE"
    log "Acquired lock file"
fi

# ============================================================================
# STEP 1: Find approved notes (DUAL approval)
# ============================================================================

log "Finding approved notes..."

# Ensure tracking file exists
mkdir -p "$MC_ROOT"
touch "$TRACKING_FILE"

# Temp file for approved notes list
APPROVED_LIST="/tmp/publish-sync-approved-$$.txt"
trap "rm -f $APPROVED_LIST" EXIT

# Method 1: All .md files in publish_queue/
if [ -d "$PUBLISH_QUEUE" ]; then
    find "$PUBLISH_QUEUE" -type f -name "*.md" >> "$APPROVED_LIST" 2>/dev/null || true
fi

# Method 2: Files with "status: publish" in frontmatter (scan drafts, ideas, sources)
for folder in "drafts" "ideas" "sources"; do
    FOLDER_PATH="$VAULT_ROOT/$folder"
    if [ -d "$FOLDER_PATH" ]; then
        # Find .md files with "status: publish" in first 20 lines
        find "$FOLDER_PATH" -type f -name "*.md" -exec sh -c '
            head -20 "$1" | grep -q "^status: publish" && echo "$1"
        ' _ {} \; >> "$APPROVED_LIST" 2>/dev/null || true
    fi
done

# Deduplicate by basename (in case same file appears via both methods)
if [ -f "$APPROVED_LIST" ] && [ -s "$APPROVED_LIST" ]; then
    sort -u "$APPROVED_LIST" -o "$APPROVED_LIST"
    APPROVED_COUNT=$(wc -l < "$APPROVED_LIST" | tr -d ' ')
    log "Found $APPROVED_COUNT approved note(s)"
else
    echo -e "${YELLOW}No approved notes found. Nothing to publish.${NC}"
    exit 0
fi

# ============================================================================
# STEP 2: Process each approved note
# ============================================================================

NEW_COUNT=0
UPDATED_COUNT=0
SKIPPED_COUNT=0
SYNCED_FILES=()

while IFS= read -r SOURCE_FILE; do
    BASENAME=$(basename "$SOURCE_FILE")
    FILENAME="${BASENAME%.md}"

    log "Processing: $BASENAME"

    # Calculate content hash
    CONTENT_HASH=$(shasum "$SOURCE_FILE" | cut -d' ' -f1)

    # Check tracking file for existing hash
    EXISTING_HASH=$(grep "^${BASENAME}," "$TRACKING_FILE" | cut -d',' -f2 || echo "")

    if [ "$EXISTING_HASH" = "$CONTENT_HASH" ]; then
        log "  Skipped (unchanged)"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        continue
    fi

    # Determine if new or updated
    if [ -z "$EXISTING_HASH" ]; then
        STATUS="new"
        NEW_COUNT=$((NEW_COUNT + 1))
    else
        STATUS="updated"
        UPDATED_COUNT=$((UPDATED_COUNT + 1))
    fi

    log "  Status: $STATUS"

    if [ "$DRY_RUN" = false ]; then
        # Transform frontmatter and copy to Quartz content/
        DEST_FILE="$QUARTZ_CONTENT/$BASENAME"

        if ! python3 "$SCRIPTS_DIR/transform-frontmatter.py" "$SOURCE_FILE" > "$DEST_FILE"; then
            echo -e "${YELLOW}Warning: Frontmatter transformation failed for $BASENAME${NC}"
            rm -f "$DEST_FILE"
            continue
        fi

        log "  Copied to Quartz content/"

        # Scan for image references: ![[image.ext]] pattern
        IMAGES=$(grep -o '!\[\[[^]]*\]\]' "$SOURCE_FILE" | sed 's/!\[\[\(.*\)\]\]/\1/' || true)

        if [ -n "$IMAGES" ]; then
            while IFS= read -r IMAGE; do
                if [ -z "$IMAGE" ]; then
                    continue
                fi

                log "  Found image reference: $IMAGE"

                # Look for image in vault media/ folder
                SOURCE_IMAGE="$VAULT_ROOT/media/$IMAGE"

                if [ -f "$SOURCE_IMAGE" ]; then
                    DEST_IMAGE="$QUARTZ_ROOT/static/$IMAGE"
                    mkdir -p "$(dirname "$DEST_IMAGE")"
                    cp "$SOURCE_IMAGE" "$DEST_IMAGE"
                    log "    Copied: $IMAGE"
                else
                    echo -e "${YELLOW}  Warning: Image not found: $IMAGE (referenced in $BASENAME)${NC}"
                fi
            done <<< "$IMAGES"
        fi

        # Update tracking file
        # Remove old entry if exists, add new one
        grep -v "^${BASENAME}," "$TRACKING_FILE" > "${TRACKING_FILE}.tmp" || true
        echo "${BASENAME},${CONTENT_HASH},$(date +%Y-%m-%d)" >> "${TRACKING_FILE}.tmp"
        mv "${TRACKING_FILE}.tmp" "$TRACKING_FILE"

        SYNCED_FILES+=("$BASENAME")
    else
        log "  [DRY RUN] Would transform and copy to Quartz"
        log "  [DRY RUN] Would scan for images and copy assets"
        log "  [DRY RUN] Would update tracking file"
        SYNCED_FILES+=("$BASENAME")
    fi

done < "$APPROVED_LIST"

# ============================================================================
# STEP 3: Git commit and push (if any files synced)
# ============================================================================

SYNCED_COUNT=$((NEW_COUNT + UPDATED_COUNT))

if [ "$SYNCED_COUNT" -gt 0 ]; then
    if [ "$DRY_RUN" = false ]; then
        log "Committing changes to Quartz repository..."

        cd "$QUARTZ_ROOT"

        # Stage changes
        git add content/ static/ 2>/dev/null || true

        # Commit with summary
        COMMIT_MSG="publish: sync $SYNCED_COUNT note(s) from vault

New: $NEW_COUNT
Updated: $UPDATED_COUNT"

        if git commit -m "$COMMIT_MSG" 2>/dev/null; then
            echo -e "${GREEN}✓ Committed changes${NC}"

            # Push to remote
            log "Pushing to GitHub..."
            if git push origin v4 2>/dev/null; then
                echo -e "${GREEN}✓ Pushed to GitHub${NC}"
                echo -e "${GREEN}✓ GitHub Pages will deploy shortly${NC}"
            else
                echo -e "${YELLOW}Warning: Git push failed. You may need to push manually.${NC}"
            fi
        else
            log "No changes to commit (files identical)"
        fi
    else
        log "[DRY RUN] Would commit and push to Quartz repository"
    fi
fi

# ============================================================================
# STEP 4: Print summary
# ============================================================================

echo ""
echo -e "${GREEN}=== Publish Sync Summary ===${NC}"
echo "New notes:     $NEW_COUNT"
echo "Updated notes: $UPDATED_COUNT"
echo "Skipped:       $SKIPPED_COUNT"
echo "Total synced:  $SYNCED_COUNT"

if [ "$SYNCED_COUNT" -gt 0 ]; then
    echo ""
    echo "Synced files:"
    for file in "${SYNCED_FILES[@]}"; do
        echo "  - $file"
    done
fi

if [ "$DRY_RUN" = true ]; then
    echo ""
    echo -e "${YELLOW}(DRY RUN - no changes made)${NC}"
fi

exit 0
