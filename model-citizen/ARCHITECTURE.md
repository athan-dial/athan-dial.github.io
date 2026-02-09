# Model Citizen: Architecture & Design

## System Overview

Model Citizen is a three-layer content automation system designed to make knowledge capture and publishing frictionless while maintaining explicit human control over what goes public.

```
┌─────────────────────────────────────────────────────────────────┐
│                    PUBLIC (GitHub Pages)                        │
│                   https://athan-dial.github.io                  │
│                      /model-citizen/                            │
│                  (Quartz v4 Publishing Site)                    │
│                     - Published articles only                   │
│                     - Versioned with git                        │
│                     - Auto-deployed via GH Actions              │
└─────────────────────────────────────────────────────────────────┘
                             ▲
                             │ publish-sync.sh
                    (approved content only)
                             │
┌─────────────────────────────────────────────────────────────────┐
│              AUTOMATION (Local / n8n instance)                   │
│              - YouTube ingestion (transcript download)          │
│              - Email/web ingestion (text clip)                  │
│              - Claude Code synthesis (SSH invocation)           │
│              - n8n daily orchestration                          │
│              - Archive tracking + idempotency                  │
└─────────────────────────────────────────────────────────────────┘
                             ▲
                             │ (git commits)
                             │
┌─────────────────────────────────────────────────────────────────┐
│                    PRIVATE (Obsidian Vault)                     │
│     ~/Library/Mobile Documents/iCloud~md~obsidian/...           │
│                                                                 │
│  inbox/          → Raw captures, not yet processed              │
│  sources/        → Normalized sources with metadata             │
│  enriched/       → Sources + summaries, tags, quotes            │
│  ideas/          → Blog angles, outlines, threads to explore    │
│  drafts/         → Full articles, work-in-progress              │
│  publish_queue/  → ✓ APPROVED for publication                  │
│  media/          → Images, diagrams, assets                     │
│  scripts/        → publish-sync.sh, transform-frontmatter.py    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Component Architecture

### Layer 1: Obsidian Vault (Knowledge Capture)

**Purpose**: Private, local knowledge base where all thinking happens

**Key folders**:

| Folder | Purpose | Lifecycle |
|--------|---------|-----------|
| `inbox/` | Raw captures, zero-processing | Transient; processed into `sources/` or deleted |
| `sources/` | Normalized material with frontmatter metadata | Long-term archive; version-controlled |
| `enriched/` | Sources + AI summaries, tags, extracted quotes | Reference material; builds index |
| `ideas/` | Blog angles, outlines, questions to explore | Growing collection of half-baked ideas |
| `drafts/` | Full articles, publication-ready text | WIP; move to `publish_queue/` when ready |
| `publish_queue/` | **✓ Approved for publication** | Synced to Quartz by `publish-sync.sh` |
| `media/` | Images, diagrams, audio transcripts, assets | Referenced by markdown via `![[filename]]` |
| `scripts/` | Automation scripts (publish-sync.sh, etc.) | Git-tracked, shared across machines |

**Vault as version control**: Every note is git-tracked. Full history of how thoughts evolved.

**Obsidian workspace config** (`.obsidian/`): Includes community plugins, themes, snippets. Shared via iCloud sync.

### Layer 2: Automation Pipeline (n8n + Claude Code)

**Purpose**: Daily orchestration of ingestion, enrichment, and synthesis

**Workflow components**:

```
┌──────────────────┐
│ YouTube Ingest   │  → Download transcript via youtube-dl or API
│                  │  → Normalize to Markdown with frontmatter
│                  │  → Commit to sources/ folder
└────────┬─────────┘
         │
┌────────▼──────────────┐
│ Email/Web Ingest      │  → Clip text from inbox
│                       │  → Add context metadata
│                       │  → Store in inbox/ or sources/
└────────┬──────────────┘
         │
┌────────▼──────────────┐
│ Claude Enrichment     │  → Summarize content
│ (SSH → Claude Code)   │  → Extract key quotes
│                       │  → Generate tags
│                       │  → Write to enriched/ folder
└────────┬──────────────┘
         │
┌────────▼──────────────┐
│ Ideation              │  → Generate blog angles
│ (Claude-powered)      │  → Create outlines
│                       │  → Write to ideas/ folder
└────────┬──────────────┘
         │
┌────────▼──────────────┐
│ Human Review Gate     │  → Open Obsidian
│                       │  → Read and decide
│                       │  → Move to publish_queue/ OR
│                       │  → Add status: publish to frontmatter
└────────┬──────────────┘
         │
┌────────▼──────────────┐
│ publish-sync.sh       │  → Find approved notes (dual gate)
│ (Manual or scheduled) │  → Transform frontmatter
│                       │  → Copy images
│                       │  → Git sync to Quartz repo
│                       │  → GitHub Actions deploys
└──────────────────────┘
```

**Key design decisions**:

1. **SSH invocation for Claude Code**: n8n can't directly call Claude's vision/analysis APIs with complex inputs. Instead, n8n stages input data in vault, SSHes into local machine, invokes Claude Code agent, and commits results back.

2. **Dual approval gates**: Content approved via:
   - **Folder**: Move to `publish_queue/`
   - **Frontmatter**: Add `status: publish`
   - Provides flexibility: quick approval via folder, long-term flag via metadata

3. **Idempotency via content hash**: `publish-sync.sh` tracks published files by SHA1 hash. Unchanged content isn't republished, preventing duplicate git commits.

4. **Lock file safety**: Only one `publish-sync.sh` can run at a time. Lock file prevents race conditions.

### Layer 3: Quartz Publishing Site (Public Knowledge Base)

**Purpose**: Polished public knowledge base with only approved content

**Structure**:
```
model-citizen-quartz/
├── content/              ← Published markdown (synced from vault)
├── static/               ← Assets (images, etc.)
├── src/
│   ├── components/       ← React components for site rendering
│   ├── layouts/          ← Page layouts
│   └── plugins/          ← Quartz plugins (search, backlinks, etc.)
├── quartz.config.ts      ← Configuration (site title, plugins, etc.)
├── tsconfig.json
├── package.json
└── .github/
    └── workflows/        ← GitHub Actions (auto-deploy on push)
```

**Frontmatter transformation** (`transform-frontmatter.py`):

| Vault Field | Action | Published Field |
|-------------|--------|-----------------|
| `status` | Remove | — |
| `idea_score` | Remove | — |
| `created` | Rename | `date` |
| `modified` | Rename | `lastmod` |
| — | Add | `draft: false` |
| `title`, `tags`, etc. | Keep | Unchanged |

**GitHub Pages deployment**:
- Quartz repo on branch `v4` (or main)
- GitHub Actions workflow triggers on push
- Builds static site → commits to `gh-pages` branch
- GitHub Pages serves from `gh-pages` → live at `athan-dial.github.io/model-citizen/`

---

## Data Flow

### End-to-End Example: YouTube Video → Published Article

```
1. n8n (scheduled daily)
   └─ Downloads YouTube transcript via API
   └─ Creates normalized markdown:
      ---
      title: "Video Title"
      created: 2026-02-09
      source: YouTube
      type: source
      tags: [...]
      ---
      [Transcript text]
   └─ Commits to vault/sources/video-title.md

2. Vault syncs via Obsidian (iCloud)
   └─ File appears on your machine

3. Claude Enrichment (n8n invokes Claude Code via SSH)
   └─ Reads vault/sources/video-title.md
   └─ Generates summary, key quotes, tags
   └─ Writes vault/enriched/video-title-enriched.md
   └─ Commits back to vault

4. You review in Obsidian
   └─ Read enriched note
   └─ Decide: "This is interesting, should write a post"

5. Claude Drafting (Manual or automated)
   └─ Claude reads enriched note
   └─ Writes full blog post
   └─ Creates vault/drafts/my-blog-post.md

6. You approve
   └─ Move to vault/publish_queue/my-blog-post.md
   └─ OR add "status: publish" to frontmatter

7. Run publish-sync.sh
   └─ Finds approved note
   └─ Transforms frontmatter (removes status field, renames dates)
   └─ Copies to model-citizen-quartz/content/my-blog-post.md
   └─ Scans for images (e.g., ![[screenshot.png]])
   └─ Copies images to model-citizen-quartz/static/
   └─ Commits to Quartz repo with "publish: sync 1 note(s)" message
   └─ Pushes to GitHub

8. GitHub Actions
   └─ Detects push to Quartz repo
   └─ Runs npm run build
   └─ Commits compiled site to gh-pages branch

9. GitHub Pages
   └─ Serves updated site
   └─ Live at https://athan-dial.github.io/model-citizen/my-blog-post
```

---

## Markdown & Frontmatter Schema

### Vault Frontmatter (Sources, Enriched, Ideas, Drafts)

```yaml
---
title: "Human-readable title"
created: 2026-02-09               # ISO date, set once
modified: 2026-02-09              # Updated when note changes
type: "source" | "idea" | "draft"  # Content type
status: "draft" | "publish"        # publish = ready to publish
tags: [tag1, tag2, tag3]           # Lowercase, hyphenated
source: "YouTube, book, email"     # Where this came from
idea_score: 8                      # 0-10 relevance/interest (optional)
---

Content here...
```

### Published Frontmatter (After Transform)

```yaml
---
title: "Human-readable title"
date: 2026-02-09                   # created → date (ISO)
lastmod: 2026-02-09                # modified → lastmod (ISO)
draft: false                       # Always false for published
tags: [tag1, tag2, tag3]           # Same as vault
---

Content here...
```

**Key differences**:
- `status` and `idea_score` are **removed** (vault-only metadata)
- `created` → `date`, `modified` → `lastmod` (Quartz conventions)
- `draft: false` always added (Quartz requirement)
- All other fields pass through unchanged

### Image References

Use Obsidian wiki-link syntax for images:

```markdown
![[screenshot.png]]
![[diagrams/architecture.svg]]
```

`publish-sync.sh` scans for these patterns and copies matching files from `vault/media/` to `quartz/static/`.

---

## Integration Points

### n8n to Claude Code

**Workflow**: n8n stages input → SSH invoke → Claude processes → Commit result

```bash
# From n8n node (HTTP + SSH):
ssh user@localhost << 'EOF'
cd ~/path/to/vault
claude code << 'PROMPT'
Read vault/sources/input.md
Write summary to vault/enriched/input-enriched.md
Include 3-5 key quotes
Tag with relevant concepts
PROMPT
EOF
```

**Why SSH?**: n8n can invoke remote commands; local machine has Claude configured. Alternative: use Claude API directly from n8n (requires API key in n8n, more complex).

### GitHub Actions Auto-Deploy

**Trigger**: Push to Quartz repo
**Action**: `.github/workflows/build-and-deploy.yml`

```yaml
on:
  push:
    branches: [v4]  # or main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm install && npm run build
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
          publish_branch: gh-pages
```

---

## Safety & Constraints

### Content Safety

1. **Dual approval gate**: Nothing goes public without explicit action
   - Folder-based: Move to `publish_queue/`
   - Frontmatter-based: Add `status: publish`

2. **No raw inbox content**: `inbox/` is never directly published. Must be normalized to `sources/` first.

3. **Human review**: `publish-sync.sh` doesn't modify vault; it only syncs already-approved content.

4. **Git tracking**: Full history of what was published and when. Easy to revert or track changes.

### Idempotency

`publish-sync.sh` tracks published files by SHA1 content hash:
- `~/.model-citizen/published-list.txt` stores: `filename,hash,date`
- If hash unchanged → skip (don't re-publish)
- If hash changed → republish as "updated"
- If file new → publish as "new"

**Benefit**: Safe to run publish-sync multiple times; won't duplicate.

### Lock File Safety

Only one `publish-sync.sh` can run at a time:
- Creates `~/.model-citizen/sync.lock` with PID
- If lock exists → script exits with error
- Cleanup trap removes lock on exit (even if script crashes)

**Benefit**: Prevents concurrent syncs from conflicting.

---

## Performance & Scalability

### Current Bottlenecks

| Operation | Time | Bottleneck |
|-----------|------|-----------|
| Find approved notes | <1s | Vault size (many files to scan) |
| Transform frontmatter | <100ms/file | Python startup + regex parsing |
| Copy images | Variable | Network (iCloud sync) |
| Git commit + push | 1-5s | Network, GitHub API |
| **Total** | **<30s** | Quartz rebuild (external) |

### Optimization Opportunities

1. **Batch approval**: Move 10+ files at once → single publish-sync run
2. **Async git push**: Don't wait for GitHub; queue and push later
3. **Image deduplication**: Skip if image already exists in Quartz (check hash)
4. **Cache file list**: Don't re-scan vault every run; track modified dates

### Scaling (Future)

- **Volume**: Current design handles ~1 new article/week easily
- **Automation**: n8n can ingest 50+ sources/day without bottleneck
- **Archive**: Move old drafts to `archive/` folder to keep active vault lean

---

## Failure Modes & Recovery

### Scenario 1: publish-sync.sh Crashes

**Symptoms**: Lock file stuck at `~/.model-citizen/sync.lock`

**Recovery**:
```bash
rm ~/.model-citizen/sync.lock
bash publish-sync.sh --verbose  # Try again with debug output
```

### Scenario 2: Frontmatter Transform Fails

**Symptoms**: Warning message, file not published

**Recovery**:
```bash
# Test transformation manually
python3 vault/scripts/transform-frontmatter.py problem-file.md

# If regex parser fails, install python-frontmatter
pip3 install python-frontmatter

# Try sync again
bash publish-sync.sh --verbose
```

### Scenario 3: Image Not Found

**Symptoms**: Warning "Image not found: diagram.png", image missing from published site

**Recovery**:
```bash
# Check if image exists in vault
ls vault/media/diagram.png

# Check image reference in note (exact filename match, case-sensitive)
grep -n "!\[\[diagram.png\]\]" vault/drafts/article.md

# If file exists but sync missed it, manually copy
cp vault/media/diagram.png \
   model-citizen-quartz/static/diagram.png
```

### Scenario 4: Git Push Fails

**Symptoms**: "fatal: could not read Username"

**Recovery**:
```bash
# Test git manually
cd model-citizen-quartz
git push origin v4 -v  # See detailed error

# Common fixes:
# - SSH key not configured: ssh-keygen + add to GitHub
# - Branch doesn't exist: git branch -a (check branch name)
# - Remote outdated: git remote -v (verify origin URL)
```

---

## Monitoring & Observability

### Publishing Tracking

`~/.model-citizen/published-list.txt` records every publish:

```
article-one.md,a1b2c3d4e5f6...,2026-02-09
article-two.md,f5e6d7c8b9a0...,2026-02-09
article-three.md,0a9b8c7d6e5f...,2026-02-10
```

**Columns**: `filename,content_hash,date`

**Use**: Track what's published, detect changes, audit trail.

### Vault Health Check

```bash
# Check vault size
du -sh ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/model-citizen-vault

# Count files by type
find vault/sources -type f | wc -l    # Num sources
find vault/drafts -type f | wc -l     # Num drafts
find vault/publish_queue -type f | wc -l  # Num pending

# List oldest notes (find stale content)
find vault -name "*.md" -exec stat -f "%Sm %N" {} \; | sort
```

### Site Health Check

```bash
# Test site loads
curl -I https://athan-dial.github.io/model-citizen/

# Check latest published article
curl https://athan-dial.github.io/model-citizen/ | grep -o 'href="[^"]*"' | head -10

# Check build logs
cd model-citizen-quartz
git log --oneline | head -10  # Recent commits
```

---

## Design Rationale

| Decision | Rationale | Trade-off |
|----------|-----------|-----------|
| Separate vault + Quartz repos | Decouples thinking from publishing; publish subset of vault | Requires sync logic |
| Obsidian for vault | Popular, powerful, Markdown-native, plugin ecosystem | Proprietary sync (iCloud) |
| n8n for automation | Visual workflow builder, no-code/low-code, flexible | Requires local instance |
| Dual approval gates | Flexibility: quick folder-based OR explicit frontmatter-based | Slight complexity |
| Content hash tracking | Idempotent publishes, no duplicates | Additional state file |
| public vault (planned) | Transparency about thinking process, credibility | Privacy concerns (mitigated by Obsidian security) |
| Quartz for site | Lightweight, static, backlinks/graph, Markdown-native | Less flexible than dynamic CMS |
| GitHub Pages | Free, simple, integrates with GitHub | Limited customization |

---

## Future Enhancements

- [ ] **Multi-source ingestion**: Email newsletters, podcasts, Slack threads, RSS feeds
- [ ] **Draft preview in Quartz**: Before publication, see how it renders
- [ ] **Automated related links**: Find related published articles and link them
- [ ] **Search on Quartz site**: Full-text search of published knowledge
- [ ] **Analytics**: Track which articles get views, time spent, referrers
- [ ] **Social integration**: Auto-tweet new articles, LinkedIn sync
- [ ] **Comment system**: Let readers leave feedback on articles
- [ ] **API**: Expose published articles via JSON API for downstream tools
