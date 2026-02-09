# Model Citizen: Content Automation Engine

A frictionless knowledge capture and publishing system that continuously ingests, synthesizes, and publishes ideas with explicit human control.

**Live Site**: https://athan-dial.github.io/model-citizen/

---

## What This Is

Model Citizen is a three-layer content automation system:

1. **Obsidian Vault** (private, local) — Capture zone for raw ideas, sources, and work-in-progress
2. **Automation Pipeline** (n8n) — Daily orchestration: ingest → enrich → synthesize → queue for review
3. **Quartz Publishing Site** (GitHub Pages) — Public knowledge base with only approved content

**Core principle**: Nothing goes public without explicit human approval. The vault is your thinking space; the site is your finished thoughts.

---

## Quick Start

### Prerequisites
- Obsidian vault setup at `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault`
- Quartz repository setup at `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-quartz`
- n8n running locally (Docker or standalone)
- Git configured on your machine
- Python 3.7+

### One-Time Setup

```bash
# Clone or create the vault and Quartz repos
mkdir -p ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/

# Initialize vault structure (if new)
mkdir -p model-citizen-vault/{inbox,sources,enriched,ideas,drafts,publish_queue,media,scripts}

# Copy scripts
cp -r model-citizen/vault/scripts/ model-citizen-vault/scripts/

# Initialize Quartz repo (if new)
git clone https://github.com/jackyzha0/quartz.git model-citizen-quartz
cd model-citizen-quartz
npm install
git checkout -b v4  # or use your publishing branch

# Create tracking directory
mkdir -p ~/.model-citizen
touch ~/.model-citizen/published-list.txt
```

### Daily Operation

```bash
# Run the publish sync (approve and publish queued content)
bash ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/scripts/publish-sync.sh

# Or preview changes first
bash ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault/scripts/publish-sync.sh --dry-run

# Rebuild Quartz site locally
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
npm run build
npm run preview  # http://localhost:3000
```

---

## Architecture

### Directory Structure

```
model-citizen-vault/
├── inbox/              # Raw captures (YouTube transcripts, email snippets)
├── sources/            # Normalized sources with metadata
├── enriched/           # Sources + AI summaries, tags, quotes
├── ideas/              # Extracted blog angles, outlines, angles to explore
├── drafts/             # Full draft articles (work-in-progress)
├── publish_queue/      # Approved articles ready to publish
├── media/              # Images, diagrams, assets referenced in notes
├── scripts/            # Automation scripts (publish-sync.sh, transform-frontmatter.py)
└── .obsidian/          # Obsidian workspace config

model-citizen-quartz/
├── content/            # Published markdown articles
├── static/             # Published assets (images, etc.)
├── src/                # Quartz source code
├── quartz.config.ts    # Quartz configuration
└── package.json        # Dependencies
```

### Markdown Schema

All vault notes follow this frontmatter structure:

```yaml
---
title: "Article or note title"
created: 2026-02-09
modified: 2026-02-09
tags: [tag1, tag2]
type: "draft" | "idea" | "source"
status: "draft" | "publish"        # Only files with status: publish get published
idea_score: 0-10                   # Relevance/interest score (optional)
source: "YouTube, email, book"     # Where this came from
---
```

**Key Fields**:
- `status: publish` — Manual approval flag; files in `publish_queue/` are auto-approved
- `type` — "draft" (full article), "idea" (outline/angle), "source" (captured material)
- `created/modified` — Timestamps; `created` → `date`, `modified` → `lastmod` during publishing

---

## How It Works

### The Approval Workflow (Dual Gate)

Content gets published when **either**:
1. **Folder-based**: Note lives in `publish_queue/` folder, OR
2. **Frontmatter-based**: Note has `status: publish` in any vault folder

This gives flexibility: quick approval via folder move, or explicit frontmatter flag for long-term decisions.

### The Publish Sync Pipeline

Run `publish-sync.sh` to:
1. **Find approved notes** — Scan both `publish_queue/` and any folder with `status: publish`
2. **Transform frontmatter** — Remove vault-only fields (`status`, `idea_score`), rename dates
3. **Copy to Quartz** — Move markdown to `model-citizen-quartz/content/`
4. **Copy assets** — Find image references (`![[image.ext]]`) and copy from `media/` to Quartz
5. **Deduplicate** — Track published files by content hash; skip unchanged files
6. **Git sync** — Commit and push to Quartz repository
7. **GitHub Pages** — Site auto-rebuilds

---

## Scripts & Tools

### `publish-sync.sh`

Syncs approved notes from vault to Quartz for publication.

**Usage**:
```bash
# Normal operation
bash publish-sync.sh

# Preview changes (dry-run)
bash publish-sync.sh --dry-run

# Verbose output
bash publish-sync.sh --verbose

# Combined
bash publish-sync.sh --dry-run --verbose
```

**What it does**:
- Finds approved notes via folder or `status: publish` frontmatter
- Transforms frontmatter (removes vault-only fields)
- Copies images referenced in notes
- Tracks published files (idempotent, doesn't re-publish unchanged files)
- Commits and pushes to Quartz repo

**Lock file safety**: Only one sync can run at a time. Lock file at `~/.model-citizen/sync.lock`.

### `transform-frontmatter.py`

Converts vault frontmatter → Quartz frontmatter.

**Transformations**:
- Removes: `status`, `idea_score`
- Renames: `created` → `date`, `modified` → `lastmod`
- Adds: `draft: false`

**Usage**:
```bash
# Transform a file
python3 transform-frontmatter.py vault-note.md > published-note.md

# Or via stdin
cat vault-note.md | python3 transform-frontmatter.py > published-note.md
```

---

## Integration Points

### n8n Automation (Planned)

The system is designed to integrate with n8n for daily automation:

1. **YouTube Ingestion**: Download transcript → normalize to `sources/` folder with frontmatter
2. **Email/Web Ingestion**: Clip text → add to `inbox/`
3. **Enrichment**: Invoke Claude Code via SSH to summarize, tag, extract quotes
4. **Ideation**: Generate blog angles and outlines
5. **Drafting**: Create full articles from outlines
6. **Review Gate**: Wait for human approval (folder move or `status: publish`)
7. **Publish Sync**: Run `publish-sync.sh` to sync approved content

**Example n8n workflow**:
```
YouTube Transcript → Normalize → Commit to Vault → Enrich (Claude) → Tag → Ideate → Queue → Await Approval → Publish Sync → Deploy
```

### Claude Code Integration

For complex synthesis tasks (summarization, angle generation), invoke Claude Code via SSH:

```bash
# From n8n, SSH into your machine and run Claude workflow
ssh user@localhost "claude code /path/to/script.js"
```

The Claude agent reads input from vault, writes results back, and commits.

---

## Monitoring & Troubleshooting

### Common Issues

**Issue**: `publish-sync.sh` says "Another sync is already running"
- **Fix**: Check and remove `~/.model-citizen/sync.lock` if previous sync crashed
  ```bash
  rm ~/.model-citizen/sync.lock
  ```

**Issue**: Images not appearing on published site
- **Check**: Are images in `media/` folder with correct reference (`![[image.ext]]`)?
- **Check**: Are filenames referenced exactly as stored (case-sensitive)?
- **Fix**: Manually copy missing images to `model-citizen-quartz/static/`

**Issue**: Notes not publishing despite being in `publish_queue/`
- **Check**: Does the file have valid frontmatter with `---` delimiters?
- **Check**: Run with `--verbose` to see detailed output: `publish-sync.sh --verbose`
- **Debug**: Test frontmatter transformation directly:
  ```bash
  python3 scripts/transform-frontmatter.py problematic-note.md
  ```

**Issue**: Git push failing after sync
- **Likely**: SSH key not configured or GitHub auth issue
- **Fix**: Test git manually:
  ```bash
  cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
  git push origin v4 -v
  ```

### Debugging

**Enable verbose logging**:
```bash
bash publish-sync.sh --verbose 2>&1 | tee /tmp/publish-sync-debug.log
```

**Test frontmatter transformation**:
```bash
python3 scripts/transform-frontmatter.py /path/to/note.md
```

**Manual git operations**:
```bash
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-quartz
git status                    # Check what changed
git diff content/             # See specific changes
git log --oneline -n 5        # Recent commits
git push origin v4 --verbose  # Troubleshoot push
```

---

## Best Practices

### Content Workflow

1. **Capture** (`inbox/`) → Raw material, fast, messy
   - YouTube transcript from n8n
   - Email snippet
   - Web article excerpt

2. **Normalize** (`sources/`) → Add frontmatter, standardize format
   - Add `title`, `created`, `source` metadata
   - Format as markdown
   - Keep original content intact

3. **Enrich** (`enriched/`) → AI-powered synthesis
   - Summary (2-3 sentences)
   - Key quotes or data points
   - Tags and themes
   - Questions it raises

4. **Ideate** (`ideas/`) → Potential angles
   - Blog post angles (what's the story?)
   - Outline structure
   - Questions to answer
   - Related concepts to explore

5. **Draft** (`drafts/`) → Full articles
   - Complete, publishable text
   - Includes frontmatter with `status: draft`
   - Ready for light review

6. **Approve & Publish** (`publish_queue/` or `status: publish`)
   - Move to `publish_queue/` for immediate publication, OR
   - Add `status: publish` frontmatter for approval flag
   - `publish-sync.sh` handles the rest

### Frontmatter Best Practices

✅ **Do**:
- Set `created` once, update `modified` when significant changes
- Use lowercase, hyphenated tags: `machine-learning`, `product-strategy`
- Set `type` to match folder: `source`, `idea`, or `draft`
- Mark drafts as `status: draft` until ready

❌ **Avoid**:
- Manually managing `publish_queue/` filenames (use folder move or frontmatter flag)
- Editing `status` field after publication (affects future sync tracking)
- Storing API keys or credentials in notes (Obsidian sync is public-ish)

### Publishing Cadence

- **Continuous capture**: n8n ingests daily (sources and ideas)
- **Weekly enrichment**: Review and enrich captured material
- **Bi-weekly drafting**: Write 2-3 full articles
- **On-demand publishing**: Publish when ready (dry-run first with `--dry-run`)

---

## Maintenance

### Monthly Tasks

- **Review tracking file**: `~/.model-citizen/published-list.txt`
  - Should list all published files with content hash and date
  - Clean up old entries if repo was reset

- **Audit vault size**: Obsidian sync can get large
  ```bash
  du -sh ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault
  ```

- **Test publish-sync end-to-end**:
  ```bash
  publish-sync.sh --dry-run --verbose  # Preview
  publish-sync.sh                      # Publish
  ```

### Quarterly Tasks

- **Review Quartz configuration**: Check `quartz.config.ts` for updates
- **Update theme**: Quartz updates regularly
  ```bash
  cd model-citizen-quartz
  npm update
  npm run build
  ```
- **Archive old drafts**: Move stale items to an `archive/` folder
- **Rebuild search index**: Quartz has built-in indexing

---

## FAQ

**Q: Can I edit a published note?**
A: Yes! Update the source in vault, then run `publish-sync.sh` again. Content hash will change and it'll republish with updates.

**Q: How do I unpublish something?**
A: Move the note out of `publish_queue/` or remove `status: publish` from frontmatter. The published copy stays in Quartz (manual delete required).

**Q: Can I batch approve notes?**
A: Yes, move multiple files into `publish_queue/` at once, then run `publish-sync.sh`.

**Q: What if I have the same note in both `publish_queue/` and with `status: publish`?**
A: The script deduplicates by filename, so it's safe. You get one published copy.

**Q: How do I add custom Quartz plugins?**
A: Edit `quartz.config.ts` in the Quartz repo. Rebuild with `npm run build`.

**Q: Can I host this elsewhere besides GitHub Pages?**
A: Yes, Quartz supports Vercel, Netlify, and other static hosts. Update your CI/CD config accordingly.

---

## Resources

- **Quartz Docs**: https://quartz.jzhao.dev/
- **Obsidian Docs**: https://help.obsidian.md/
- **n8n Docs**: https://docs.n8n.io/
- **This Project**: `.planning/projects/MODEL_CITIZEN_PROJECT.md`

---

## Support & Debugging

For detailed architecture and design rationale, see:
- `ARCHITECTURE.md` — System design, component interactions
- `OPERATIONS.md` — Step-by-step operational guides
- `SCRIPTING.md` — Script reference and integration
