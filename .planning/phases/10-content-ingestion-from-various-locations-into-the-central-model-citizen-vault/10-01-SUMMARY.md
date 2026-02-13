---
phase: 10-content-ingestion
plan: 01
subsystem: vault-infrastructure
tags: [vault-structure, obsidian, templates, auto-note-mover, sync-script]
dependency_graph:
  requires: []
  provides:
    - 700-model-citizen-folder-structure
    - obsidian-templates
    - tag-based-routing
    - quartz-sync-script
  affects:
    - content-ingestion-pipeline
    - vault-organization
    - quartz-publishing
tech_stack:
  added:
    - Auto Note Mover plugin (tag-to-folder routing)
    - rsync (vault-to-quartz mirroring)
  patterns:
    - Tag-based content curation
    - Git-based vault versioning
    - Folder mirroring with rsync --delete
key_files:
  created:
    - /Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/index.md
    - /Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/{concepts,writing,sources,explorations,ideas}/.gitkeep
    - /Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/000 System/03 Templates/model-citizen-{concept,source,writing,exploration,idea}.md
    - /Users/adial/Documents/GitHub/athan-dial.github.io/model-citizen/scripts/sync-to-quartz.sh
  modified:
    - /Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/.obsidian/plugins/auto-note-mover/data.json
decisions:
  - decision: "Use tag-based routing (not folder-based) for content curation"
    rationale: "More flexible - users can tag from anywhere without moving notes manually"
    date: "2026-02-13"
  - decision: "Five content sections instead of seven workflow stages"
    rationale: "Simpler taxonomy focused on content type rather than workflow state"
    date: "2026-02-13"
  - decision: "rsync --delete for vault-to-quartz sync"
    rationale: "True mirror - removes deleted content from Quartz automatically"
    date: "2026-02-13"
metrics:
  duration: 122 # seconds
  completed: "2026-02-13T15:17:00Z"
---

# Phase 10 Plan 01: Vault Structure & Tag-Based Curation Summary

**One-liner:** Created 700 Model Citizen/ vault structure with 5 content sections, Obsidian templates, Auto Note Mover tag routing, and rsync-based Quartz sync script.

---

## What Was Built

### Vault Structure
- **700 Model Citizen/** parent folder with 5 content sections:
  - `concepts/` - Frameworks, mental models, decision systems
  - `writing/` - Original essays and long-form thinking
  - `sources/` - Curated references, articles, research
  - `explorations/` - Active investigations and thought experiments
  - `ideas/` - Quick captures and emerging thoughts
- **index.md** - Quartz landing page explaining the sections
- **.gitkeep files** - Preserve empty folder structure in git

### Obsidian Templates
Created 5 templates in `000 System/03 Templates/`:
- **model-citizen-concept.md** - What It Is | How It Works | Where I've Seen It
- **model-citizen-source.md** - Summary | Key Ideas | Quotes (with URL, source_type)
- **model-citizen-writing.md** - Minimal frontmatter with draft flag
- **model-citizen-exploration.md** - Premise | Design | Open Questions (with status)
- **model-citizen-idea.md** - Minimal capture template

All templates use Obsidian variable syntax (`{{title}}`, `{{date}}`) for core plugin integration.

### Auto Note Mover Configuration
Added 5 tag-based routing rules to `.obsidian/plugins/auto-note-mover/data.json`:
| Tag | Destination Folder |
|-----|-------------------|
| `#model-citizen/concept` | `700 Model Citizen/concepts/` |
| `#model-citizen/writing` | `700 Model Citizen/writing/` |
| `#model-citizen/source` | `700 Model Citizen/sources/` |
| `#model-citizen/exploration` | `700 Model Citizen/explorations/` |
| `#model-citizen/idea` | `700 Model Citizen/ideas/` |

### Sync Script
Created `model-citizen/scripts/sync-to-quartz.sh`:
- Mirrors `700 Model Citizen/` → `/Users/adial/Documents/GitHub/quartz/content/`
- Uses `rsync -avz --delete` (removes files deleted from vault)
- Excludes: `.gitkeep`, `.DS_Store`, `.obsidian`
- Auto-commits with timestamp and pushes to quartz remote
- `--dry-run` flag for testing without modifying files
- Lock file prevents concurrent runs
- Color-coded logging (info/warn/error)

---

## Deviations from Plan

**None** - Plan executed exactly as written.

---

## Task Breakdown

| Task | Name | Duration | Commit (Vault) | Commit (Portfolio) | Files |
|------|------|----------|----------------|-------------------|-------|
| 1 | Create vault structure and templates | ~1 min | 4efaf0f | - | 11 files created |
| 2 | Configure Auto Note Mover and create sync script | ~1 min | 970a3b0 | 2dcf88e | 2 files modified/created |

**Total Duration:** 2 min 2 sec

---

## Commits

**Vault Repository** (2B-new):
- `4efaf0f` - feat(10-01): create 700 Model Citizen vault structure and templates
- `970a3b0` - feat(10-01): configure Auto Note Mover for model-citizen tag routing

**Portfolio Repository** (athan-dial.github.io):
- `2dcf88e` - feat(10-01): create sync-to-quartz.sh script

---

## Verification Results

### Task 1 Verification
✅ All 5 section folders exist under 700 Model Citizen/
✅ index.md exists with `#model-citizen` tag
✅ 5 templates exist in 000 System/03 Templates/ with correct tag prefixes
✅ All templates use Obsidian variable syntax ({{title}}, {{date}})

### Task 2 Verification
✅ Auto Note Mover data.json is valid JSON
✅ 5 model-citizen tag rules exist in configuration
✅ sync-to-quartz.sh passes bash -n syntax check
✅ `--dry-run` flag works correctly (tested with sample content)

---

## What's Next

This plan establishes the **vault-side curation infrastructure** that all ingestion tools will feed into:

1. **Phase 10 Plan 02** - ChatGPT conversation ingestion
2. **Phase 10 Plan 03** - Browser bookmark ingestion
3. Future ingestion tools (email, Slack, RSS, etc.) will use the same tag-based routing

---

## Self-Check: PASSED

**Created files verified:**
✅ /Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/index.md
✅ /Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/concepts/.gitkeep
✅ /Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/writing/.gitkeep
✅ /Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/sources/.gitkeep
✅ /Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/explorations/.gitkeep
✅ /Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/ideas/.gitkeep
✅ /Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/000 System/03 Templates/model-citizen-concept.md
✅ /Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/000 System/03 Templates/model-citizen-source.md
✅ /Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/000 System/03 Templates/model-citizen-writing.md
✅ /Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/000 System/03 Templates/model-citizen-exploration.md
✅ /Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/000 System/03 Templates/model-citizen-idea.md
✅ /Users/adial/Documents/GitHub/athan-dial.github.io/model-citizen/scripts/sync-to-quartz.sh

**Commits verified:**
✅ Vault commit 4efaf0f exists
✅ Vault commit 970a3b0 exists
✅ Portfolio commit 2dcf88e exists
