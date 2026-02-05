---
phase: "04"
plan: "02"
title: "Create Vault Repository & Schema"
subsystem: "content-infrastructure"
status: "complete"
completed: "2026-02-05"
duration: "106 seconds"

requires:
  - "04-01: Domain research and architecture decisions"

provides:
  - "Public Obsidian vault repository with workflow folder structure"
  - "SCHEMA.md documentation for frontmatter and folder taxonomy"
  - "Obsidian templates for all workflow stages"
  - "Git-tracked vault ready for automation integration"

affects:
  - "05: YouTube ingestion will write to inbox/ and sources/ folders"
  - "07: Enrichment pipeline will read from sources/ and write to enriched/"
  - "09: Publish sync will read from publish_queue/ folder"

tech-stack:
  added:
    - "Obsidian vault structure (workflow-based folders)"
    - "GitHub repository: athan-dial/model-citizen-vault"
  patterns:
    - "Workflow-based folder taxonomy (vs topic categories)"
    - "Frontmatter-driven status tracking"
    - "Git-tracked knowledge base with .gitkeep for empty folders"
    - "Public-by-default vault (publish_queue/ gates public rendering)"

decisions:
  - id: "vault-workflow-folders"
    choice: "7 workflow folders (inbox → sources → enriched → ideas → drafts → publish_queue → published)"
    rationale: "Status-based folders make automation simpler (folder = stage) and clarify review boundaries"
    alternatives: "Topic-based folders, flat structure with status-only frontmatter"
    date: "2026-02-05"

  - id: "public-vault-strategy"
    choice: "Entire vault is public on GitHub"
    rationale: "Learning in public; Quartz ignorePatterns + ExplicitPublish plugin gate what renders on site"
    alternatives: "Private vault with sync to public publish_queue/"
    date: "2026-02-05"

  - id: "gitkeep-for-empty-folders"
    choice: "Add .gitkeep files to all workflow folders"
    rationale: "Ensures folder structure exists in git even when empty (fresh clone works immediately)"
    alternatives: "Let folders be created on-demand"
    date: "2026-02-05"

key-files:
  created:
    - path: "~/model-citizen-vault/SCHEMA.md"
      purpose: "Documents frontmatter schema, folder taxonomy, publishing rules"
      lines: 208
    - path: "~/model-citizen-vault/README.md"
      purpose: "Repository landing page explaining folder structure"
      lines: 23
    - path: "~/model-citizen-vault/.templates/source-note.md"
      purpose: "Obsidian template for source notes (YouTube, articles)"
    - path: "~/model-citizen-vault/.templates/enriched-note.md"
      purpose: "Obsidian template for enriched notes (post-Claude processing)"
    - path: "~/model-citizen-vault/.templates/idea-card.md"
      purpose: "Obsidian template for blog idea cards"
    - path: "~/model-citizen-vault/.templates/draft-post.md"
      purpose: "Obsidian template for draft posts"
    - path: "~/model-citizen-vault/inbox/.gitkeep"
      purpose: "Track inbox/ folder in git"
    - path: "~/model-citizen-vault/sources/.gitkeep"
      purpose: "Track sources/ folder in git"
    - path: "~/model-citizen-vault/enriched/.gitkeep"
      purpose: "Track enriched/ folder in git"
    - path: "~/model-citizen-vault/ideas/.gitkeep"
      purpose: "Track ideas/ folder in git"
    - path: "~/model-citizen-vault/drafts/.gitkeep"
      purpose: "Track drafts/ folder in git"
    - path: "~/model-citizen-vault/publish_queue/.gitkeep"
      purpose: "Track publish_queue/ folder in git"
    - path: "~/model-citizen-vault/published/.gitkeep"
      purpose: "Track published/ folder in git"
  modified: []

tags: ["obsidian", "content-infrastructure", "schema", "workflow-automation"]
---

# Phase 04 Plan 02: Create Vault Repository & Schema Summary

**One-liner:** Public Obsidian vault with 7 workflow folders, SCHEMA.md documentation, and templates for automated content pipeline.

---

## What Was Built

Created the **model-citizen-vault** repository as the source-of-truth for all captured content:

1. **Workflow folder structure** with 7 stages:
   - `inbox/` - Raw captures (unprocessed)
   - `sources/` - Normalized source notes (YouTube transcripts, articles)
   - `enriched/` - Enriched notes (summaries, tags, quotes added by Claude)
   - `ideas/` - Blog idea cards (angles, outlines)
   - `drafts/` - Draft posts (first outlines and full drafts)
   - `publish_queue/` - Approved for publishing (human-gated)
   - `published/` - Archive of published content

2. **SCHEMA.md documentation** (208 lines) defining:
   - Frontmatter requirements for each workflow stage
   - Status values (`inbox`, `enriched`, `idea`, `draft`, `publish`, `published`)
   - Tag conventions (lowercase-kebab-case)
   - Publishing rules (must be in `publish_queue/` AND have `status: publish`)
   - File naming conventions
   - Wikilink resolution patterns

3. **Obsidian templates** for all workflow stages:
   - `source-note.md` - For YouTube/article captures
   - `enriched-note.md` - For Claude-processed notes
   - `idea-card.md` - For blog angles
   - `draft-post.md` - For draft content

4. **Git tracking** with `.gitkeep` files ensuring empty folders exist in fresh clones

5. **Public GitHub repository** at https://github.com/athan-dial/model-citizen-vault

---

## Decisions Made

### 1. Workflow-Based Folder Taxonomy

**Decision:** 7 workflow folders representing content lifecycle stages

**Rationale:**
- Automation is simpler: folder location = workflow stage (no need to parse frontmatter to determine next action)
- Clear review boundaries: human only needs to check specific folders weekly
- Status progression is visible: moving a file = explicit workflow transition

**Alternatives considered:**
- **Topic-based folders** (ml-systems/, product-strategy/, etc.) - rejected because notes would need to be in multiple topics, and workflow stage wouldn't be obvious from folder
- **Flat structure with status-only frontmatter** - rejected because automation would need to scan all notes to find work

**Impact:** Phases 05-09 can use folder location as primary routing signal

---

### 2. Public Vault Strategy

**Decision:** Entire vault is public on GitHub (not just `publish_queue/`)

**Rationale:**
- **Learning in public:** Showing the messy middle (inbox/, drafts/) demonstrates authentic process
- **Simplifies architecture:** No sync mechanism needed between private vault and public publish queue
- **Safety via Quartz:** ignorePatterns exclude inbox/ through drafts/, ExplicitPublish plugin only renders notes with `status: publish`

**Alternatives considered:**
- **Private vault with sync to public publish_queue/** - rejected due to sync complexity and doesn't align with "learning in public" ethos
- **Separate private + public repos** - rejected for same reasons

**Trade-offs:**
- **Risk:** Accidentally publishing unfinished work if Quartz config is wrong
- **Mitigation:** Two-layer safety (folder-based ignore + status-based plugin)

---

### 3. .gitkeep Files for Empty Folders

**Decision:** Add `.gitkeep` to all 7 workflow folders + `.obsidian/` + `.templates/`

**Rationale:**
- Fresh clone of vault has correct folder structure immediately (automation doesn't need to create folders)
- Clear documentation of intended structure
- Prevents confusion about "missing" folders

**Alternatives considered:**
- **Create folders on-demand** - rejected because automation would need folder creation logic and structure isn't self-documenting

---

## Implementation Notes

### Frontmatter Schema Design

SCHEMA.md defines **progressive frontmatter** - fields added as notes progress:

| Stage | Required Fields |
|-------|----------------|
| inbox/ | `title`, `date`, `status`, `tags` |
| sources/ | + `source`, `source_url` |
| enriched/ | + `summary` |
| ideas/ | + `idea_angles`, `related` |
| drafts/ | + `summary`, `related` |
| publish_queue/ | (same as drafts, but clean title, `status: publish`) |

This design minimizes frontmatter boilerplate in early stages while ensuring publish-ready notes have all required metadata.

### Tag Conventions

- **Format:** `lowercase-kebab-case` (e.g., `ml-systems`, `decision-frameworks`)
- **Hierarchy via prefix:** `product-strategy`, `product-metrics` (not nested folders)
- **No spaces:** Use hyphens, not underscores or spaces

This matches Quartz's tag normalization and ensures consistent URL generation.

### Publishing Safety

Two-layer safety prevents accidental publishing:

1. **Quartz ignorePatterns:** Excludes inbox/ through drafts/ folders entirely
2. **ExplicitPublish plugin:** Only renders notes with `status: publish` frontmatter

Both must fail for content to accidentally publish.

---

## Metrics

- **Tasks completed:** 3/3
- **Duration:** 106 seconds (~1.8 minutes)
- **Files created:** 14 (SCHEMA.md, README.md, 4 templates, 9 .gitkeep files)
- **Commits:** 2
  - `dcb4cb2`: feat: initial vault structure with workflow folders
  - `e066307`: docs: add SCHEMA.md and Obsidian templates
- **Lines of documentation:** 231 (SCHEMA.md 208 + README.md 23)

---

## Verification Results

All verification checks passed:

- Repository exists at https://github.com/athan-dial/model-citizen-vault
- Repository is public (visibility: PUBLIC)
- All 7 workflow folders exist with .gitkeep files
- SCHEMA.md is 208 lines and accessible on GitHub
- 4 Obsidian templates exist in .templates/ directory
- Templates contain required frontmatter fields (verified `source_url` in source-note.md)
- README.md documents folder structure

---

## Next Phase Readiness

**Blockers:** None

**Concerns:**
- SCHEMA.md defines frontmatter requirements but doesn't enforce them (validation will be needed in Phase 07 enrichment pipeline)
- Obsidian templates use placeholder syntax (`{{title}}`, `{{date}}`) that works in Obsidian but not in automation - Phase 05 will need to generate frontmatter programmatically

**Dependencies satisfied:**
- Phase 05 (YouTube ingestion) can now write to inbox/ and sources/ folders
- Phase 07 (enrichment pipeline) has documented schema to follow
- Phase 09 (publish sync) knows to read from publish_queue/ folder

---

## Deviations from Plan

None - plan executed exactly as written.

---

## How to Use This Vault

### For humans (in Obsidian):

1. Clone repository: `git clone https://github.com/athan-dial/model-citizen-vault.git`
2. Open folder in Obsidian
3. Create notes using templates (Cmd+P → "Insert template")
4. Move notes through workflow folders as they progress
5. Move to `publish_queue/` and set `status: publish` when ready to publish

### For automation (Phase 05-09):

1. Write raw captures to `inbox/` or `sources/` folders
2. Read from specific folders based on pipeline stage
3. Write enriched content to next workflow stage
4. NEVER write to `publish_queue/` (human-only)
5. Use SCHEMA.md to validate frontmatter before writing

---

## Reflection

### What Went Well

- **Clean execution:** All tasks completed in single pass with no issues
- **GitHub CLI authentication:** User already authenticated (`gh` CLI worked without prompt)
- **Documentation completeness:** SCHEMA.md covers all workflow stages and frontmatter requirements
- **Public vault strategy:** Aligns with "learning in public" principle

### What Could Be Improved

- **Template syntax:** Obsidian templates use `{{title}}` syntax that won't work in automation - should document this in SCHEMA.md or create separate automation templates
- **Validation tooling:** SCHEMA.md defines requirements but provides no validation mechanism - could add pre-commit hook or validation script in future

### Lessons Learned

- **Workflow folders are self-documenting:** Folder name immediately tells you what stage content is in and who's responsible for next action
- **.gitkeep pattern works well:** Ensures fresh clone has correct structure without needing setup script
- **Public vault requires two-layer safety:** Both Quartz ignorePatterns and ExplicitPublish plugin needed to prevent accidental publishing

### Future Implications

- **Phase 05-09 complexity:** Automation will need to handle frontmatter generation (can't use Obsidian template syntax)
- **Schema evolution:** As workflow matures, may need to add fields (e.g., `word_count`, `target_audience`) - SCHEMA.md should be versioned
- **Validation as a service:** Consider adding GitHub Action that validates frontmatter on PR to prevent invalid notes from merging

---

*Summary created: 2026-02-05*
*Execution agent: Claude Sonnet 4.5*
