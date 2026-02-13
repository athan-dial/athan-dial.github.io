#!/usr/bin/env bash
set -euo pipefail

# sync-to-quartz.sh
# Syncs 700 Model Citizen/ vault content to Quartz content/ directory
# Replaces workflow-based publish-sync.sh with simpler folder mirror approach

# Color output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Paths
readonly VAULT_DIR="/Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen"
readonly QUARTZ_DIR="/Users/adial/Documents/GitHub/quartz"
readonly QUARTZ_CONTENT_DIR="${QUARTZ_DIR}/content"
readonly LOCK_FILE="/tmp/sync-to-quartz.lock"

# Parse arguments
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

# Cleanup function
cleanup() {
    if [[ -f "${LOCK_FILE}" ]]; then
        rm -f "${LOCK_FILE}"
    fi
}
trap cleanup EXIT INT TERM

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Check for lock file to prevent concurrent runs
if [[ -f "${LOCK_FILE}" ]]; then
    log_error "Another sync is already running (lock file exists: ${LOCK_FILE})"
    exit 1
fi

# Create lock file
echo $$ > "${LOCK_FILE}"

# Verify source directory exists
if [[ ! -d "${VAULT_DIR}" ]]; then
    log_error "Vault directory not found: ${VAULT_DIR}"
    exit 1
fi

# Verify Quartz repository exists
if [[ ! -d "${QUARTZ_DIR}" ]]; then
    log_error "Quartz repository not found: ${QUARTZ_DIR}"
    exit 1
fi

# Verify Quartz content directory exists
if [[ ! -d "${QUARTZ_CONTENT_DIR}" ]]; then
    log_error "Quartz content directory not found: ${QUARTZ_CONTENT_DIR}"
    exit 1
fi

log_info "Syncing 700 Model Citizen/ to Quartz..."

# Build rsync command
RSYNC_OPTS=(
    -avz
    --delete
    --exclude='.gitkeep'
    --exclude='.DS_Store'
    --exclude='.obsidian'
)

if [[ "${DRY_RUN}" == true ]]; then
    log_info "DRY RUN MODE - No changes will be made"
    RSYNC_OPTS+=(--dry-run)
fi

# Execute rsync
if rsync "${RSYNC_OPTS[@]}" "${VAULT_DIR}/" "${QUARTZ_CONTENT_DIR}/"; then
    log_info "Sync completed successfully"
else
    log_error "rsync failed"
    exit 1
fi

# Exit if dry run
if [[ "${DRY_RUN}" == true ]]; then
    log_info "Dry run complete - no git operations performed"
    exit 0
fi

# Git operations
log_info "Committing changes to Quartz repository..."

cd "${QUARTZ_DIR}"

# Check if there are changes to commit
if [[ -z $(git status --porcelain) ]]; then
    log_info "No changes to commit"
    exit 0
fi

# Stage all changes
git add content/

# Commit with timestamp
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
git commit -m "sync: Update Model Citizen content

Synced from 700 Model Citizen/ vault at ${TIMESTAMP}"

# Push to remote
if git push; then
    log_info "Changes pushed to remote successfully"
else
    log_error "Failed to push changes to remote"
    exit 1
fi

log_info "Sync complete!"
