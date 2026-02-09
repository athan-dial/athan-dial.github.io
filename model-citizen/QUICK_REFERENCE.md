# Model Citizen: Quick Reference

Copy-paste cheat sheet for common operations.

---

## Daily Shortcuts

### Publish an article

```bash
# Move draft to publish_queue/
mv ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/drafts/article.md \
   ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/publish_queue/

# Publish
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
bash scripts/publish-sync.sh

# View on site (wait 30s)
open https://athan-dial.github.io/model-citizen/
```

### Preview before publishing

```bash
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
bash scripts/publish-sync.sh --dry-run --verbose
```

### Check what's in publish_queue

```bash
ls -lh ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/publish_queue/
```

### See recent publications

```bash
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
git log --oneline -n 10
```

---

## Path Shortcuts

```bash
# Vault root
VAULT=~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault

# Quartz root
QUARTZ=~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz

# Publish to queue
mv "$VAULT/drafts/article.md" "$VAULT/publish_queue/"

# List sources
ls "$VAULT/sources/"

# List draft ideas
ls "$VAULT/ideas/"
```

---

## Common Edits

### Create new note with correct frontmatter

```bash
cat > ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/drafts/my-article.md << 'EOF'
---
title: "Article Title"
created: $(date +%Y-%m-%d)
modified: $(date +%Y-%m-%d)
type: draft
status: draft
tags: [topic1, topic2]
---

Your content here.
EOF
```

### Add image reference

```markdown
![[screenshot.png]]
![[diagrams/architecture.svg]]
```

### Change status to publish

In Obsidian:
1. Open note
2. Edit frontmatter: `status: draft` → `status: publish`
3. Save

Or via terminal:
```bash
sed -i '' 's/^status: draft/status: publish/' "$VAULT/drafts/article.md"
```

---

## Debugging

### Test frontmatter transformation

```bash
python3 ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/scripts/transform-frontmatter.py \
  ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/drafts/problem.md
```

### Fix stuck lock file

```bash
rm ~/.model-citizen/sync.lock
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
bash scripts/publish-sync.sh --verbose
```

### Check git status

```bash
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
git status
git diff content/
```

### View recent commits

```bash
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
git log --oneline -n 20
```

### Manually push if sync failed

```bash
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
git push origin v4 -v
```

---

## Batch Operations

### Publish multiple articles

```bash
# Move all to publish_queue
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
mv drafts/article-1.md publish_queue/
mv drafts/article-2.md publish_queue/
mv drafts/article-3.md publish_queue/

# Publish all at once
bash scripts/publish-sync.sh
```

### Archive old drafts

```bash
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
mkdir -p archive
find drafts -name "*.md" -mtime +180 -exec mv {} archive/ \;
```

### Count files by type

```bash
VAULT=~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
echo "Inbox: $(find $VAULT/inbox -name '*.md' | wc -l)"
echo "Sources: $(find $VAULT/sources -name '*.md' | wc -l)"
echo "Enriched: $(find $VAULT/enriched -name '*.md' | wc -l)"
echo "Ideas: $(find $VAULT/ideas -name '*.md' | wc -l)"
echo "Drafts: $(find $VAULT/drafts -name '*.md' | wc -l)"
echo "Publish Queue: $(find $VAULT/publish_queue -name '*.md' | wc -l)"
```

---

## Monitoring

### Check vault size

```bash
du -sh ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/
```

### Check site is live

```bash
curl -I https://athan-dial.github.io/model-citizen/
```

### Find largest files

```bash
VAULT=~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
find $VAULT -type f -size +1M -exec ls -lh {} \;
```

### View publication history

```bash
cat ~/.model-citizen/published-list.txt | tail -20
```

---

## Environment Setup (One-Time)

### Install Python (if needed)

```bash
brew install python3
pip3 install python-frontmatter  # Optional, but recommended
```

### Initialize tracking directory

```bash
mkdir -p ~/.model-citizen
touch ~/.model-citizen/published-list.txt
```

### Test git SSH

```bash
ssh -T git@github.com
# Should output: "Hi [username]! You've successfully authenticated..."
```

### Clone/init repos (if new)

```bash
# Create vault structure
mkdir -p ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/{inbox,sources,enriched,ideas,drafts,publish_queue,media,scripts}

# Copy scripts
cp -r model-citizen/vault/scripts/ ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/

# Clone Quartz repo
git clone https://github.com/jackyzha0/quartz.git ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
npm install
git checkout -b v4
```

---

## File Templates

### Source Note Template

```yaml
---
title: "Source Title"
created: 2026-02-09
modified: 2026-02-09
type: source
status: draft
tags: [topic]
source: "YouTube / Email / Book / Web"
---

[Original content, transcript, or excerpt]
```

### Idea/Outline Template

```yaml
---
title: "Potential Blog Angle: [Topic]"
created: 2026-02-09
modified: 2026-02-09
type: idea
status: draft
tags: [topic]
idea_score: 7
---

## Hook
[Opening angle - why should readers care?]

## Key Points
1. First point
2. Second point
3. Third point

## Why Now
[Current relevance or context]

## Related Ideas
- Link to source or enriched note
- Related concept
```

### Draft Article Template

```yaml
---
title: "Article Title"
created: 2026-02-09
modified: 2026-02-09
type: draft
status: draft
tags: [topic1, topic2]
---

## Introduction
[Hook and context. 2-3 sentences.]

## Main Section 1
[Supporting paragraph or explanation.]

## Main Section 2
[Supporting paragraph or explanation.]

## Conclusion
[Summary and takeaway. 1-2 sentences.]

## Further Reading
- Related article link
- Source reference
```

---

## Troubleshooting Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| Files not publishing | Run with `--verbose` to see why |
| Images not appearing | Check filename is in `media/` and reference is exact match (case-sensitive) |
| Git push fails | Check SSH: `ssh -T git@github.com` |
| Lock file stuck | `rm ~/.model-citizen/sync.lock` |
| Python error | `pip3 install python-frontmatter` |
| Nothing changed but script stuck | `ps aux \| grep publish` then `pkill -f` |
| Article published to wrong branch | Check Quartz branch: `git branch -a` |
| Build fails | Check Node version: `node --version` (should be 18+) |

---

## Emergency Procedures

### Undo Last Publish

```bash
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
git log --oneline -n 2  # Find commit to undo
git revert <commit>     # Creates new commit that undoes it
git push origin v4
```

### Recover Deleted Note

```bash
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
git log --oneline -- publish_queue/deleted.md  # Find it
git show <commit>:publish_queue/deleted.md > recovered.md
# Open recovered.md and verify, then restore
```

### Clear All Tracking (Nuclear)

```bash
# Only if vault and Quartz completely out of sync
echo "" > ~/.model-citizen/published-list.txt
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
rm content/*.md
git add content/
git commit -m "clear: reset published content"
git push origin v4
```

---

## Useful One-Liners

```bash
# Find all notes with typo word "thier" → "their"
grep -r "thier" ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/

# Fix typo across all files
find ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault -name "*.md" -exec \
  sed -i '' 's/thier/their/g' {} \;

# List notes modified in last 7 days
find ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault -name "*.md" -mtime -7

# Count total words in vault
find ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault -name "*.md" -exec wc -w {} + | tail -1

# Backup published-list.txt
cp ~/.model-citizen/published-list.txt ~/.model-citizen/published-list.txt.backup

# Show unpublished drafts
find ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/drafts -name "*.md" | \
  while read f; do grep -q "status: publish" "$f" || echo "$f"; done
```

---

## Keyboard Shortcuts (Obsidian)

| Action | Shortcut |
|--------|----------|
| Command palette | Cmd+K |
| Quick switcher (open file) | Cmd+O |
| New file | Cmd+N |
| Find in file | Cmd+F |
| Replace in file | Cmd+H |
| Reveal in Finder | Cmd+Shift+E |
| Open file in Finder | Cmd+Alt+M (if set) |

---

## Links & Resources

- **README.md** — Overview and quick start
- **ARCHITECTURE.md** — System design and components
- **OPERATIONS.md** — Detailed operational procedures
- **SCRIPTING.md** — Script reference and examples
- **Live Site**: https://athan-dial.github.io/model-citizen/
- **Project Status**: `.planning/projects/MODEL_CITIZEN_PROJECT.md`

---

## Version Info

- **System**: Model Citizen v1 (MVP)
- **Last Updated**: 2026-02-09
- **Vault Location**: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault`
- **Quartz Location**: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-quartz`
- **Published Site**: https://athan-dial.github.io/model-citizen/
