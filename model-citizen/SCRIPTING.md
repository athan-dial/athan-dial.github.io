# Model Citizen: Scripting Reference

Complete reference for scripts that power the Model Citizen automation engine.

---

## Scripts Overview

| Script | Purpose | Location | Invoked By |
|--------|---------|----------|-----------|
| `publish-sync.sh` | Sync approved notes from vault to Quartz | `vault/scripts/` | Manual, n8n, scheduler |
| `transform-frontmatter.py` | Convert vault frontmatter → Quartz format | `vault/scripts/` | `publish-sync.sh` |

---

## publish-sync.sh

**Full path**: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault/scripts/publish-sync.sh`

**Purpose**: Sync approved notes from Obsidian vault to Quartz publishing site.

### Usage

```bash
bash /path/to/publish-sync.sh [OPTIONS]
```

### Options

| Option | Description |
|--------|-------------|
| `--dry-run` | Show what would happen without making changes |
| `--verbose` | Print detailed per-file output |
| `--help` | Show help text |

### Examples

```bash
# Normal operation (publish approved notes)
bash publish-sync.sh

# Preview changes without making them
bash publish-sync.sh --dry-run

# Verbose output for debugging
bash publish-sync.sh --verbose

# Combined
bash publish-sync.sh --dry-run --verbose
```

### How It Works

#### Step 0: Lock File Management
- Creates lock file at `~/.model-citizen/sync.lock` (contains PID)
- If lock exists → script exits with error (another sync running)
- Cleanup trap removes lock on exit

**Why**: Prevents race conditions if sync triggered multiple times

#### Step 1: Find Approved Notes (Dual Gate)

Searches for approved content via **two methods**:

**Method 1: Folder-based**
```bash
find $VAULT_ROOT/publish_queue -type f -name "*.md"
```
- Files in `publish_queue/` folder are auto-approved

**Method 2: Frontmatter-based**
```bash
find $VAULT_ROOT/{drafts,ideas,sources} -type f -name "*.md" -exec sh -c '
  head -20 "$1" | grep -q "^status: publish" && echo "$1"
' _ {} \;
```
- Files with `status: publish` in first 20 lines are approved
- Scans `drafts/`, `ideas/`, `sources/` folders

**Deduplication**:
```bash
sort -u $APPROVED_LIST  # Remove duplicates by filename
```
- If same file appears via both methods, only publish once

**Output**:
```
log "Found 3 approved note(s)"
```

#### Step 2: Process Each Approved Note

For each approved file:

1. **Calculate content hash**
   ```bash
   CONTENT_HASH=$(shasum "$SOURCE_FILE" | cut -d' ' -f1)
   ```
   - SHA1 hash of file contents
   - Used to detect changes

2. **Check tracking file**
   ```bash
   EXISTING_HASH=$(grep "^${BASENAME}," $TRACKING_FILE | cut -d',' -f2)
   ```
   - Lookup in `~/.model-citizen/published-list.txt`
   - Format: `filename,hash,date`

3. **Determine status**
   ```
   If hash matches → SKIP (unchanged)
   Else if no entry → NEW (first publish)
   Else → UPDATED (content changed)
   ```

4. **Transform frontmatter**
   ```bash
   python3 $SCRIPTS_DIR/transform-frontmatter.py "$SOURCE_FILE" > "$DEST_FILE"
   ```
   - Delegates to `transform-frontmatter.py`
   - Output goes to `model-citizen-quartz/content/`

5. **Copy images**
   ```bash
   IMAGES=$(grep -o '!\[\[[^]]*\]\]' "$SOURCE_FILE" | sed 's/!\[\[\(.*\)\]\]/\1/')
   # For each image:
   SOURCE_IMAGE="$VAULT_ROOT/media/$IMAGE"
   DEST_IMAGE="$QUARTZ_ROOT/static/$IMAGE"
   cp "$SOURCE_IMAGE" "$DEST_IMAGE"
   ```
   - Finds wiki-link image references: `![[filename]]`
   - Copies from `vault/media/` to `quartz/static/`
   - Creates directories as needed

6. **Update tracking**
   ```bash
   echo "${BASENAME},${CONTENT_HASH},$(date +%Y-%m-%d)" >> $TRACKING_FILE
   ```
   - Appends new entry to published-list.txt
   - Deduplicates by filename (removes old entry first)

#### Step 3: Git Commit & Push

If any files synced (NEW or UPDATED):

```bash
cd $QUARTZ_ROOT
git add content/ static/
git commit -m "publish: sync $SYNCED_COUNT note(s) from vault

New: $NEW_COUNT
Updated: $UPDATED_COUNT"
git push origin v4
```

**Details**:
- Stages all changes in `content/` and `static/`
- Single commit with summary
- Pushes to `origin v4` branch (configurable)
- GitHub Actions automatically deploys

#### Step 4: Summary Output

```
=== Publish Sync Summary ===
New notes:     3
Updated notes: 1
Skipped:       2
Total synced:  4

Synced files:
  - article-1.md
  - article-2.md
  - article-3.md
  - updated-article.md
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success (including no files to sync) |
| 1 | Error (lock file, transformation failed, etc.) |

### Configuration Variables (Edit Script to Customize)

```bash
# Vault location
VAULT_ROOT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault"

# Quartz repo location
QUARTZ_ROOT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-quartz"

# Tracking file (published archive)
TRACKING_FILE="$MC_ROOT/published-list.txt"

# Lock file (concurrency control)
LOCK_FILE="$MC_ROOT/sync.lock"

# Publishing branch
BRANCH="v4"  # (In git push command)
```

### Environment Variables

Script respects standard git configuration:
- `SSH_KEY` — If set, uses for git auth
- `GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL` — For commit authorship

### Integration Points

**From n8n**:
```javascript
// Execute Command node
bash /path/to/vault/scripts/publish-sync.sh --verbose
```

**From cron/launchd**:
```bash
0 6 * * * bash /path/to/vault/scripts/publish-sync.sh >> /tmp/publish.log 2>&1
```

**From CI/CD**:
```yaml
# GitHub Actions
- run: bash vault/scripts/publish-sync.sh
```

---

## transform-frontmatter.py

**Full path**: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault/scripts/transform-frontmatter.py`

**Purpose**: Convert Obsidian vault frontmatter to Quartz-compatible format.

### Usage

```bash
python3 transform-frontmatter.py [INPUT_FILE]
```

### Examples

```bash
# From file
python3 transform-frontmatter.py vault-note.md > published-note.md

# From stdin
cat vault-note.md | python3 transform-frontmatter.py > published-note.md

# Piped from publish-sync.sh
python3 transform-frontmatter.py "$SOURCE_FILE" > "$DEST_FILE"
```

### Transformations

#### Removes (Vault-only metadata)
```yaml
status: draft          ← REMOVED
idea_score: 8          ← REMOVED
```

**Why**: Vault-only fields; Quartz doesn't use them

#### Renames (Standard date fields)
```yaml
created: 2026-02-09    ← Becomes: date: 2026-02-09
modified: 2026-02-10   ← Becomes: lastmod: 2026-02-10
```

**Why**: Quartz uses `date` and `lastmod`; Obsidian uses `created`/`modified`

#### Adds (Quartz requirements)
```yaml
# (Not in input)          → Becomes: draft: false
```

**Why**: Quartz marks drafts with `draft: true`; published articles use `false`

#### Passes Through (Unchanged)
```yaml
title: "Article"       ← UNCHANGED
tags: [topic1, topic2] ← UNCHANGED
# Any other fields     ← UNCHANGED
```

### Example Transformation

**Input** (Vault frontmatter):
```yaml
---
title: "Understanding Machine Learning"
created: 2026-02-05
modified: 2026-02-09
type: draft
status: publish
tags: [machine-learning, ai, education]
idea_score: 9
---

Content here...
```

**Output** (Quartz frontmatter):
```yaml
---
title: "Understanding Machine Learning"
date: 2026-02-05
lastmod: 2026-02-09
type: draft
tags: [machine-learning, ai, education]
draft: false
---

Content here...
```

**Changes**:
- `status` removed
- `idea_score` removed
- `created` → `date`
- `modified` → `lastmod`
- `draft: false` added
- All other fields unchanged

### Implementation Details

#### Dual-Mode Parsing

Script attempts to parse YAML using two methods:

**Method 1: python-frontmatter library** (preferred)
```python
import frontmatter
post = frontmatter.loads(content)
metadata = post.metadata
# Modify metadata dict
return frontmatter.dumps(post)
```

**Advantages**:
- Robust YAML parsing
- Preserves formatting (comments, indentation)
- Handles edge cases (special chars, multiline)

**Method 2: Regex-based parsing** (fallback)
```python
# If python-frontmatter not installed
parts = content.split('---', 2)
frontmatter_text = parts[1]
body = parts[2]
# Parse line-by-line with regex
# Reconstruct markdown
```

**Advantages**:
- No dependencies
- Fast
- Works offline

**Auto-selection**:
```python
if HAS_FRONTMATTER:
    result = transform_with_library(content)
else:
    result = transform_with_regex(content)
```

### Error Handling

**Exit on invalid input**:
```python
# No frontmatter found
print("Error: No valid frontmatter found", file=sys.stderr)
sys.exit(1)

# File not found
print(f"Error: File not found: {input_path}", file=sys.stderr)
sys.exit(1)

# Parse error
print(f"Error parsing frontmatter: {e}", file=sys.stderr)
sys.exit(1)
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success, transformed markdown on stdout |
| 1 | Error (invalid input, missing file, parse error) |

### Integration

Called automatically by `publish-sync.sh`:

```bash
python3 "$SCRIPTS_DIR/transform-frontmatter.py" "$SOURCE_FILE" > "$DEST_FILE"

# If exit code != 0:
if ! python3 "$SCRIPTS_DIR/transform-frontmatter.py" "$SOURCE_FILE" > "$DEST_FILE"; then
    echo "Warning: Frontmatter transformation failed for $BASENAME"
    rm -f "$DEST_FILE"
    continue
fi
```

---

## Custom Script Examples

### Example 1: Batch Create Test Articles

```bash
#!/bin/bash
# Create 5 test articles in publish_queue/

VAULT_ROOT=~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
QUEUE=$VAULT_ROOT/publish_queue

for i in {1..5}; do
  cat > "$QUEUE/test-article-$i.md" << EOF
---
title: "Test Article $i"
created: $(date +%Y-%m-%d)
type: draft
status: publish
tags: [test]
---

This is test article number $i.

Lorem ipsum dolor sit amet, consectetur adipiscing elit.
EOF
  echo "Created: test-article-$i.md"
done

echo "Created 5 test articles. Run publish-sync.sh to publish."
```

### Example 2: Find Unpublished Drafts

```bash
#!/bin/bash
# Find drafts ready for publishing

VAULT_ROOT=~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
DRAFTS=$VAULT_ROOT/drafts

echo "Drafts older than 7 days (ready to publish?):"
find "$DRAFTS" -name "*.md" -mtime +7 -exec basename {} \;

echo ""
echo "Move to publish_queue/ to approve, then run:"
echo "  bash scripts/publish-sync.sh"
```

### Example 3: Check Publishing History

```bash
#!/bin/bash
# Show recent publications

TRACKING_FILE=~/.model-citizen/published-list.txt

echo "Recently published articles:"
tail -10 "$TRACKING_FILE" | while IFS=',' read filename hash date; do
  echo "  $date: $filename"
done
```

### Example 4: Validate All Notes

```bash
#!/bin/bash
# Check all notes for valid frontmatter

VAULT_ROOT=~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault

for folder in inbox sources enriched ideas drafts publish_queue; do
  echo "Checking $folder/"
  find "$VAULT_ROOT/$folder" -name "*.md" | while read file; do
    if ! head -20 "$file" | grep -q "^---"; then
      echo "  ✗ INVALID: $(basename $file) - missing frontmatter"
    fi
  done
done
echo "Validation complete"
```

---

## Debugging & Troubleshooting Scripts

### Enable Debug Output

```bash
# Run with bash -x (trace mode)
bash -x publish-sync.sh --verbose 2>&1 | head -50

# Or capture full log
bash publish-sync.sh --verbose 2>&1 | tee /tmp/debug.log
tail -f /tmp/debug.log  # Monitor in real-time
```

### Test Individual Steps

```bash
# Test frontmatter transformation
python3 transform-frontmatter.py ~/path/to/test.md

# Test image scanning
grep -o '!\[\[[^]]*\]\]' ~/path/to/article.md

# Test git commands
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
git status
git add content/
git commit -m "test commit"
```

### Common Script Errors

**Error: "Another sync is already running"**
```bash
# Remove stale lock
rm ~/.model-citizen/sync.lock

# Check process
ps aux | grep publish-sync

# Kill if stuck
pkill -f publish-sync
```

**Error: "python3 not found"**
```bash
# Install Python
brew install python3

# Or use full path
/usr/local/bin/python3 transform-frontmatter.py
```

**Error: "No approved notes found"**
```bash
# Check publish_queue/ exists and has files
ls ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/publish_queue/

# Check for status: publish in other folders
grep -r "^status: publish" ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/drafts/
```

---

## Performance Tips

### Speed Up Scans

```bash
# Instead of:
find $VAULT_ROOT -name "*.md" -type f

# Use:
find $VAULT_ROOT/{drafts,ideas,sources,publish_queue} -name "*.md" -type f
# (Only scan relevant folders)
```

### Avoid Redundant Calls

```bash
# Instead of:
python3 transform-frontmatter.py file.md > /tmp/1
python3 transform-frontmatter.py file.md > /tmp/2  # Redundant!

# Cache result:
OUTPUT=$(python3 transform-frontmatter.py file.md)
echo "$OUTPUT" > dest1
echo "$OUTPUT" > dest2
```

### Parallelize If Needed

```bash
# Publish multiple files in parallel (careful with git):
find publish_queue -name "*.md" | xargs -P 4 -I {} bash -c '
  python3 transform-frontmatter.py {} > /tmp/{}
'
# Then single git commit with all results
```

---

## Script Modification Guide

### Add a New Transformation

Edit `transform-frontmatter.py`:

```python
# Add to transform_with_library():
metadata = post.metadata

# NEW: Rename custom field
if 'my_field' in metadata:
    metadata['new_field'] = metadata.pop('my_field')

return frontmatter.dumps(post)
```

### Add a New Approval Method

Edit `publish-sync.sh` Step 1:

```bash
# After existing methods, add:
# Method 3: Frontmatter time-based
for folder in "archive" "ideas"; do
    if [ -d "$VAULT_ROOT/$folder" ]; then
        # Find .md files modified in last 7 days AND with status: publish
        find "$FOLDER_PATH" -type f -name "*.md" -mtime -7 -exec sh -c '
            head -20 "$1" | grep -q "^status: publish" && echo "$1"
        ' _ {} \; >> "$APPROVED_LIST"
    fi
done
```

### Add Email Notifications

Edit `publish-sync.sh` after summary output:

```bash
# After printing summary, add:
if [ "$SYNCED_COUNT" -gt 0 ]; then
    SUBJECT="Model Citizen: Published $SYNCED_COUNT note(s)"
    mail -s "$SUBJECT" your-email@example.com << EOF
Publish Sync Summary
====================
New: $NEW_COUNT
Updated: $UPDATED_COUNT
Total: $SYNCED_COUNT

See: https://athan-dial.github.io/model-citizen/
EOF
fi
```

---

## Deployment

### Using in GitHub Actions

```yaml
name: Publish Model Citizen

on:
  schedule:
    - cron: '0 6 * * *'  # Daily at 6 AM
  workflow_dispatch:     # Manual trigger

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: |
          mkdir -p ~/.model-citizen
          bash vault/scripts/publish-sync.sh
```

### Using in n8n

```javascript
// Execute Command node
{
  "command": "bash",
  "args": ["/path/to/vault/scripts/publish-sync.sh", "--verbose"]
}
```

---

## FAQ

**Q: Can I run multiple publish-syncs in parallel?**
A: No, lock file prevents it. Design is single-threaded.

**Q: What if publish-sync crashes during image copy?**
A: Partial copy may exist in Quartz. Next run will overwrite/complete it (idempotent by hash).

**Q: Can I edit the scripts without breaking things?**
A: Yes, but test with `--dry-run` first. Keep logic in Steps 1-2 stable.

**Q: How do I version scripts if I modify them?**
A: Commit to git in vault repo. Easy to revert if changes break things.
