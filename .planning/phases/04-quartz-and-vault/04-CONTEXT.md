# Phase 4: Quartz & Vault Schema - Context

**Gathered:** 2026-02-05
**Status:** Ready for planning

<domain>

## Phase Boundary

Set up the infrastructure and documentation for Model Citizen's dual-repo architecture:
1. Quartz site deployed to GitHub Pages at `athan-dial.github.io/model-citizen/`
2. Public Obsidian vault folder structure and Markdown schema documented

This phase establishes the **scaffolding**. Actual automation (ingestion, enrichment, publishing) comes in later phases.

</domain>

<decisions>

## Implementation Decisions

### Deployment Model
- Quartz deployed as **GitHub Pages project site** (not subdomain at a separate domain)
- Base path: `athan-dial.github.io/model-citizen/` (all URLs relative to `/model-citizen/`)
- Single GitHub Pages site hosts both resume (root) + Model Citizen (project subdirectory)

### Repository Strategy
- Repo A (Model Citizen Vault) is **public GitHub repository** (not private)
  - Public only option available on free GitHub Pages tier
  - Transparency is intentional: let people see your thinking process and sources
  - All content Git-tracked (every thought is version-controlled)

- Repo B (Quartz Site) is separate repo or subdirectory
  - Option to decide during Phase 4 planning: separate repo vs monorepo subdirectory
  - Quartz handles content/ directory as source of published posts

### Vault Folder Taxonomy
The Vault uses this structure (documented, not implemented):

```
vault/
├── inbox/           # Raw captures (unprocessed, weekly review)
├── sources/         # Normalized source notes (YouTube transcripts, articles, email extracts)
├── enriched/        # Enriched notes (summaries, tags, quotes added)
├── ideas/           # Idea cards (blog angles, outlines, supporting references)
├── drafts/          # Draft posts (first outlines and full drafts)
├── publish_queue/   # Approved for publishing (explicit human move here)
└── published/       # Archive of what's been published to Quartz
```

**Rationale:** Separates thinking (vault) from publishing (Quartz). Allows iterating on ideas without affecting the public site.

### Markdown Schema

All notes follow this frontmatter structure (documented in Phase 4):

```yaml
---
title: "Note title"
date: 2026-02-05
source: "YouTube/Email/Web" # Where this came from
source_url: "https://..." # Original source
status: "inbox|enriched|idea|draft|publish|published"
tags: ["tag1", "tag2"] # Machine-generated + manual
summary: "1-2 sentence summary"
# Optional:
idea_angles: ["Blog angle 1", "Blog angle 2"]
related: ["note-id-1", "note-id-2"]
---
```

**Rationale:** Consistent metadata enables filtering, searching, and workflow state tracking.

### Publishing Rules

Content becomes public if **either** of these is true:
- Note is moved to `/publish_queue/` folder, **OR**
- Frontmatter has `status: publish`

**Safety guardrail:** Nothing goes public without explicit human intent signal. Daily automation never auto-publishes.

### Claude's Discretion

- Exact Quartz theme configuration (colors, fonts, sidebar layout)
- Folder naming conventions (snake_case vs kebab-case)
- Archive strategy for published notes (keep in vault or move to published/ folder)
- Nested subfolder structure within main folders (e.g., sources/youtube/, sources/articles/)

</decisions>

<specifics>

## Specific Ideas

- **Vault transparency:** The public vault is intentional brand differentiation. Unlike polished blogs that hide the messy thinking, Model Citizen shows your sources, drafts, rejected ideas. This signals intellectual honesty.

- **n8n writing into vault:** The automation will write directly into /sources/ and /enriched/. Manual approval happens in the vault itself (move to /publish_queue/).

- **Quartz aesthetic:** Lightweight, knowledge-garden vibes. Links and backlinks prominent. No heavy design. Consistent with "intellectual rigor" positioning.

</specifics>

<deferred>

## Deferred Ideas

- Email and web link ingestion — Phase 5+ (separate phases for each source type)
- Vault UI for approval workflows — Phase 8 may use native Obsidian UI, or custom dashboard later
- Automated backlinking between notes — v2
- Quartz full-text search — v2
- Analytics on published articles — v2

</deferred>

---

*Phase: 04-quartz-and-vault*
*Context gathered: 2026-02-05*
