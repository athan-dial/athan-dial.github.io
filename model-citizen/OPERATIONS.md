# Model Citizen: Operations Guide

Step-by-step procedures for running and maintaining the Model Citizen content automation engine.

---

## Daily Operations

### Morning Routine (5 min)

1. **Open Obsidian vault**
   ```bash
   open ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
   ```
   - Check `inbox/` for overnight captures (automated ingestion)
   - Skim new `sources/` and `enriched/` notes
   - Review what's in `ideas/` for interesting angles

2. **Quick review**
   - Read summaries in `enriched/` folder
   - Note which sources warrant deeper exploration
   - Check `publish_queue/` for anything pending

### Whenever You Finish a Draft

1. **Move to publish_queue/ (fast-track) OR add frontmatter**

   **Option A: Folder-based approval (fastest)**
   ```bash
   # In Obsidian, move file from drafts/ to publish_queue/
   # (Cmd+Opt+M to show file in Finder, then move)
   ```

   **Option B: Frontmatter-based (explicit)**
   ```markdown
   ---
   status: draft        ← Change this to:
   ---

   ---
   status: publish      ← Now approved
   ---
   ```

2. **Publish when ready**
   ```bash
   cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
   bash scripts/publish-sync.sh --dry-run --verbose  # Preview
   bash scripts/publish-sync.sh                      # Publish
   ```

3. **Verify on live site**
   ```bash
   # Wait 30s-1min for GitHub Pages to rebuild
   open https://athan-dial.github.io/model-citizen/
   ```

---

## Weekly Operations

### Content Review & Curation (30 min)

1. **Audit inbox**
   ```bash
   # Check what n8n captured this week
   ls -ltr ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/inbox/

   # Process each item:
   # 1. Move to sources/ and normalize (add frontmatter)
   # 2. Delete if not relevant
   # 3. Mark date processed
   ```

2. **Review enriched notes**
   ```bash
   # Find notes that are ready for drafting
   ls -ltr ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/enriched/

   # For interesting ones:
   # 1. Read full note (Claude summary + quotes)
   # 2. Ask: "Is there an article here?"
   # 3. If yes: create draft in drafts/
   ```

3. **Check ideas folder**
   ```bash
   # See outlines and angles that haven't been developed
   ls -ltr ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/ideas/

   # If any are ripe for development:
   # 1. Move to drafts/
   # 2. Expand outline to full article
   ```

### Publishing Cadence Check

```bash
# See what's published
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
git log --oneline | head -10

# If nothing in past week, consider:
# 1. Are there drafts sitting in drafts/ folder? → Move to publish_queue/
# 2. Are ideas ripe for development? → Write draft
# 3. Is vault stale? → Check n8n automation logs
```

---

## Publishing Workflow (Step-by-Step)

### Scenario: Publish a Draft

```bash
# 1. Draft is complete and in vault/drafts/my-article.md
# 2. Frontmatter looks good:
---
title: "My Article Title"
created: 2026-02-05
modified: 2026-02-09
type: draft
status: draft
tags: [topic1, topic2]
---

# 3. Choose approval method:

# OPTION A: Folder-based (fast)
# In Obsidian: Finder → vault/drafts/ → drag my-article.md to publish_queue/

# OPTION B: Frontmatter (explicit)
# Edit frontmatter: status: draft → status: publish

# 4. Run publish-sync
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
bash scripts/publish-sync.sh --dry-run --verbose

# Expected output:
# ✓ Check 1: Loading site...
# ✓ Found 1 approved note(s)
# Processing: my-article.md
#   Status: new
#   Copied to Quartz content/
#   [Image handling if needed]
#
# === Publish Sync Summary ===
# New notes:     1
# Updated notes: 0
# Skipped:       0
# Total synced:  1

# 5. If preview looks good, run for real:
bash scripts/publish-sync.sh --verbose

# 6. Verify git push succeeded:
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
git log --oneline -n 1
# Should show: "publish: sync 1 note(s)"

# 7. Check live site (give GH Pages 30-60 sec):
open https://athan-dial.github.io/model-citizen/
# Your article should appear
```

### Scenario: Publish Multiple Articles at Once

```bash
# 1. Move all drafts to publish_queue/
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
mv drafts/article-1.md publish_queue/
mv drafts/article-2.md publish_queue/
mv drafts/article-3.md publish_queue/

# 2. Single publish-sync publishes all
bash scripts/publish-sync.sh --dry-run --verbose
bash scripts/publish-sync.sh

# Output shows:
# === Publish Sync Summary ===
# New notes:     3
# Updated notes: 0
# Skipped:       0
# Total synced:  3
```

### Scenario: Update a Published Article

```bash
# 1. Article is already published (in quartz/content/)
# 2. You find a typo or want to improve it
# 3. Edit the SOURCE in vault:

cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault

# Option A: If still in publish_queue/
# Just edit and save; run publish-sync again

# Option B: If moved to archive or elsewhere
# Either:
#   a) Copy back to publish_queue/, OR
#   b) Add status: publish to frontmatter

# 4. Run publish-sync
bash scripts/publish-sync.sh

# Output shows:
# Processing: article-name.md
#   Status: updated    (← Different from "new")

# 5. Verify update on live site
open https://athan-dial.github.io/model-citizen/article-name
```

---

## Image Management

### Adding Images to Articles

1. **Save image to vault media folder**
   ```bash
   cp ~/Downloads/screenshot.png \
      ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/media/screenshot.png
   ```

2. **Reference in Obsidian markdown**
   ```markdown
   ## My Section

   Here's a screenshot:

   ![[screenshot.png]]

   And a diagram:

   ![[diagrams/architecture.svg]]
   ```

3. **Organize by subdirectory (optional)**
   ```bash
   mkdir -p ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/media/diagrams/
   cp ~/Downloads/arch.svg media/diagrams/architecture.svg
   ```

4. **publish-sync.sh handles copying**
   ```bash
   # When you run publish-sync:
   # - Scans article for ![[image]] references
   # - Finds image in vault/media/
   # - Copies to quartz/static/
   # - Markdown is unchanged (Quartz resolves from root)
   ```

### Troubleshooting Images Not Appearing

```bash
# 1. Check reference format
# ✓ Correct: ![[filename.png]]
# ✗ Wrong: ![](media/filename.png)
# ✗ Wrong: <img src="filename.png">

# 2. Check case sensitivity
grep "!\[\[" vault/drafts/article.md
# Must match filename exactly

# 3. Check file exists in media/
ls vault/media/screenshot.png

# 4. Run with verbose and check image output
bash scripts/publish-sync.sh --verbose 2>&1 | grep -i image

# 5. Manual copy if needed
mkdir -p ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz/static/
cp vault/media/screenshot.png \
   ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz/static/
```

---

## Automation Setup (n8n)

### Running n8n Locally (Docker)

```bash
# Start n8n container
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -e N8N_HOST=localhost \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n:latest

# Access at http://localhost:5678
# Set up admin account

# Stop when done
docker stop n8n
```

### Creating a YouTube Ingestion Workflow

1. **n8n Setup**
   - Create new workflow
   - Add "Cron" trigger (daily)
   - Add YouTube node to download transcripts

2. **Normalize to Markdown**
   ```javascript
   // JavaScript node in n8n
   const title = $input.first().json.title;
   const transcript = $input.first().json.transcript;

   const markdown = `---
   title: "${title}"
   created: ${new Date().toISOString().split('T')[0]}
   source: YouTube
   type: source
   tags: []
   ---

   ${transcript}`;

   return [{ json: { content: markdown, filename: title.toLowerCase().replace(/ /g, '-') + '.md' } }];
   ```

3. **Commit to Vault**
   ```bash
   # Use n8n "Execute Command" or SSH node
   ssh user@localhost << 'EOF'
   cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
   cat > sources/youtube-$(date +%s).md << 'CONTENT'
   [markdown content from n8n]
   CONTENT
   git add sources/
   git commit -m "ingest: youtube transcript from n8n"
   git push origin main
   EOF
   ```

4. **Enrich with Claude (Optional)**
   ```bash
   # SSH + invoke Claude Code
   ssh user@localhost << 'EOF'
   cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
   claude code << 'PROMPT'
   Read the YouTube transcript at sources/latest.md
   Write a 2-3 sentence summary
   Extract 3-5 key quotes
   Add 5 relevant tags
   Save result to enriched/latest-summary.md
   PROMPT
   git add enriched/
   git commit -m "enrich: youtube summary"
   git push origin main
   EOF
   ```

### Scheduling publish-sync.sh

Option A: **From n8n** (recommended for automation)
```javascript
// Execute Command node in n8n
bash /path/to/vault/scripts/publish-sync.sh --verbose
```

Option B: **OS Scheduler (cron/launchd)**
```bash
# Create launchd plist (macOS)
cat > ~/Library/LaunchAgents/com.model-citizen.publish-sync.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.model-citizen.publish-sync</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>/path/to/vault/scripts/publish-sync.sh</string>
  </array>
  <key>StartCalendarInterval</key>
  <array>
    <dict>
      <key>Hour</key>
      <integer>18</integer>  <!-- 6 PM -->
      <key>Minute</key>
      <integer>0</integer>
      <key>Weekday</key>
      <integer>0</integer>   <!-- Daily -->
    </dict>
  </array>
  <key>StandardErrorPath</key>
  <string>/tmp/publish-sync.err.log</string>
  <key>StandardOutPath</key>
  <string>/tmp/publish-sync.out.log</string>
</dict>
</plist>
EOF

# Enable
launchctl load ~/Library/LaunchAgents/com.model-citizen.publish-sync.plist

# Check status
launchctl list | grep model-citizen

# Disable if needed
launchctl unload ~/Library/LaunchAgents/com.model-citizen.publish-sync.plist
```

---

## Maintenance Tasks

### Monthly

1. **Review published-list.txt**
   ```bash
   cat ~/.model-citizen/published-list.txt
   # Should show all published articles
   # Format: filename,hash,date

   # Archive old entries (optional)
   # Keep last 6 months, move older to backup
   ```

2. **Audit vault size**
   ```bash
   du -sh ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/
   # Alert if >1GB (might be cache/assets)

   # Find large files
   find vault -type f -size +5M -exec ls -lh {} \;
   ```

3. **Test end-to-end**
   ```bash
   # Create test article
   cat > ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/publish_queue/test-$(date +%s).md << 'EOF'
   ---
   title: "Test Article"
   created: 2026-02-09
   type: draft
   status: publish
   tags: [test]
   ---

   This is a test article to verify the publish pipeline works.
   EOF

   # Publish
   bash ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/scripts/publish-sync.sh --verbose

   # Verify on site
   open https://athan-dial.github.io/model-citizen/test-article

   # Clean up (remove from Quartz)
   cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
   rm content/test-*.md
   git add content/
   git commit -m "test: remove test article"
   git push
   ```

### Quarterly

1. **Update Quartz**
   ```bash
   cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz

   # Check for updates
   npm outdated

   # Update dependencies
   npm update

   # Test build
   npm run build
   npm run preview  # http://localhost:3000

   # If successful, commit
   git add package.json package-lock.json
   git commit -m "chore: update quartz and dependencies"
   git push origin v4
   ```

2. **Archive old drafts**
   ```bash
   # Move stale drafts to archive
   mkdir -p ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/archive/

   # Find old files (>6 months)
   find ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/drafts -type f -mtime +180

   # Move them
   mv ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/drafts/old-*.md ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/archive/
   ```

3. **Review vault structure**
   ```bash
   # Count items by folder
   for folder in inbox sources enriched ideas drafts publish_queue archive; do
     echo "$folder: $(find vault/$folder -name '*.md' 2>/dev/null | wc -l) files"
   done

   # If any are too large, consider splitting or archiving
   ```

---

## Troubleshooting

### Issue: publish-sync.sh Hangs

**Symptom**: Script doesn't complete, sits at one step

**Diagnosis**:
```bash
# Run with timeout
timeout 10 bash publish-sync.sh --verbose
# If it times out, check which step

# Check if lock file stuck
ls -la ~/.model-citizen/sync.lock
```

**Fix**:
```bash
# Remove lock and retry
rm ~/.model-citizen/sync.lock
bash publish-sync.sh --dry-run --verbose

# If still hangs, check git
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
git status  # Check for incomplete operations
```

### Issue: Files Not Publishing Despite Being in publish_queue/

**Diagnosis**:
```bash
# Check file exists and has valid frontmatter
ls -la ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/publish_queue/

# Validate frontmatter format
head -20 ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/publish_queue/problem.md

# Test transformation manually
python3 ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/scripts/transform-frontmatter.py \
  ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/publish_queue/problem.md
```

**Common causes**:
- Missing or malformed frontmatter (must start with `---`)
- File encoding issue (ensure UTF-8)
- Path with spaces or special characters

**Fix**:
```bash
# Fix frontmatter manually
cat > fixed.md << 'EOF'
---
title: "Title"
created: 2026-02-09
---

Content here
EOF

mv fixed.md problem.md
bash publish-sync.sh
```

### Issue: Images Not Appearing on Published Site

See "Image Management" section above.

### Issue: Git Push Fails with Authentication Error

**Diagnosis**:
```bash
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
git push origin v4 -v  # Verbose output shows real error
```

**Common fixes**:
- SSH key not set up: `ssh-keygen -t ed25519 -C "your_email@example.com"`
- Add key to GitHub: Settings → SSH and GPG keys → New SSH key
- Test SSH: `ssh -T git@github.com`

### Issue: Quartz Build Fails After Dependency Update

**Diagnosis**:
```bash
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
npm run build 2>&1 | tail -50
```

**Fix**:
```bash
# Clear cache and reinstall
rm -rf node_modules/ package-lock.json
npm install
npm run build

# If still fails, check Node version
node --version  # Should be 18+

# Downgrade Quartz if necessary
npm install quartz@4.0.0  # Specific version
```

---

## Performance Tuning

### Speeding Up publish-sync.sh

**Current baseline**: ~30 seconds end-to-end

**Optimization tips**:

1. **Skip image scanning if none used**
   ```bash
   # Edit publish-sync.sh, comment out image block
   # Saves ~2-3 seconds
   ```

2. **Batch publishes together**
   ```bash
   # Moving 5 files and publishing once = 1 git commit
   # vs publishing one-by-one = 5 commits
   ```

3. **Use dry-run first**
   ```bash
   # Identifies issues before actual publish
   bash publish-sync.sh --dry-run  # <1 second
   bash publish-sync.sh             # Full publish if dry-run OK
   ```

### Monitoring publish-sync Performance

```bash
# Measure total time
time bash publish-sync.sh

# Break down by step (add debug timing to script)
bash publish-sync.sh --verbose 2>&1 | tee /tmp/sync.log
# Analyze log file for slow steps
```

---

## Recovery Procedures

### Recovering from Accidental Deletion

**Scenario**: Deleted a note from `publish_queue/` before publishing

**Recovery**:
```bash
# Check git history
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
git log --oneline | head -10
git show <commit>:publish_queue/deleted-note.md > recovered-note.md
# Re-add and commit
```

### Rolling Back a Published Article

**Scenario**: Published something by mistake and want to unpublish

**Recovery**:
```bash
# Option 1: Remove from publish_queue/archive it
mv ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/publish_queue/article.md \
   ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/archive/

# Option 2: Remove from Quartz repo
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
rm content/article.md
git add content/
git commit -m "unpublish: article.md"
git push origin v4

# Note: History remains in git; article is just hidden from live site
```

### Re-syncing All Articles (Nuclear Option)

```bash
# Only if vault and Quartz are out of sync
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz

# Clear published content
rm content/*.md

# Reset published-list.txt
echo "" > ~/.model-citizen/published-list.txt

# Move all approved notes back to publish_queue/
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
mkdir -p publish_queue_bulk
# (Move files you want to republish)

# Run publish-sync to rebuild from scratch
bash scripts/publish-sync.sh --verbose
```

---

## Checklists

### Pre-Publishing Checklist

- [ ] Read article once more for typos
- [ ] Check frontmatter is valid (title, date, tags)
- [ ] Verify all images are in media/ folder and referenced correctly
- [ ] Run `publish-sync.sh --dry-run --verbose` and review output
- [ ] Move to publish_queue/ OR add status: publish
- [ ] Run `publish-sync.sh --verbose`
- [ ] Check git output for "✓ Committed changes" and "✓ Pushed to GitHub"
- [ ] Wait 30-60 seconds
- [ ] Visit live site and verify article appears

### Monthly Maintenance Checklist

- [ ] Audit inbox (process or delete)
- [ ] Review enriched/ notes for drafting opportunities
- [ ] Check publish-sync success (git log)
- [ ] Verify site loads without errors
- [ ] Clean up lock files if any stale
- [ ] Run one test publish-sync cycle
- [ ] Check vault size (should stay <500MB)

### Quarterly Checklist

- [ ] Update Quartz dependencies
- [ ] Archive stale drafts
- [ ] Review and consolidate old ideas/sources
- [ ] Check n8n automation logs for errors
- [ ] Verify all images are still working
- [ ] Test full backup/recovery procedure

---

## Getting Help

1. **Check README.md** for quick start and common tasks
2. **Check ARCHITECTURE.md** for system design and rationale
3. **Check SCRIPTING.md** for script reference
4. **Review error messages** with `--verbose` flag
5. **Check git logs** to understand what changed
6. **Test in dry-run mode** before making changes

---

## Contact & Support

For issues, questions, or improvements:
- Check `.planning/projects/MODEL_CITIZEN_PROJECT.md` for project status
- Review GitHub issues if using GitHub
- SSH into machine and inspect files manually
- Use `--verbose` flags for maximum detail
