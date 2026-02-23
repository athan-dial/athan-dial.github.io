---
phase: 14-vault-schema
plan: 01
subsystem: model-citizen
tags: [vault, schema, obsidian, auto-note-mover, frontmatter]
dependency_graph:
  requires: []
  provides: [vault-schema-contract, vault-folders, anm-routing-rules]
  affects: [phase-15-scanners, phase-16-intelligence-skills, phase-17-synthesis]
tech_stack:
  added: []
  patterns: [frontmatter-schema, anm-pattern-routing, nested-yaml-provenance]
key_files:
  created:
    - model-citizen/vault/SCHEMA.md
    - ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/sources/slack/ (folder)
    - ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/sources/outlook/ (folder)
    - ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/atoms/ (folder)
    - ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/themes/ (folder)
    - ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/drafts/ (folder)
    - ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/Test atom - adoption curve plateau.md
  modified:
    - ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/.obsidian/plugins/auto-note-mover/data.json
decisions:
  - "Use nested provenance: YAML object for both Slack and Outlook (readable + Dataview dot-notation queryable)"
  - "Include split_index on atoms for reconstruction ordering across multi-atom splits"
  - "source_type on atoms satisfies ATOM-02 intent without copying full provenance (backlink pattern)"
  - "ANM rules prepended to folder_tag_pattern array — specific source/slack before generic sources/ rule"
  - "themes/ vs concepts/ distinction documented: concepts = manual frameworks, themes = pipeline aggregation hubs"
metrics:
  duration_seconds: 114
  completed_date: 2026-02-23
  tasks_completed: 3
  files_created: 8
  files_modified: 1
---

# Phase 14 Plan 01: Vault Schema Contract Summary

**One-liner:** Frontmatter schema contract with 4 note types, nested provenance, publishability gate, and ANM pattern-routing rules prepended before existing tag-based rules.

---

## What Was Built

Complete vault schema infrastructure for the v1.3 content intelligence pipeline:

1. **SCHEMA.md** (`model-citizen/vault/SCHEMA.md`) — authoritative frontmatter contract defining source/slack, source/outlook, atom, theme, and draft note types with complete field tables, provenance format, content_status lifecycle, publishability rules, folder routing documentation, and Dataview audit queries.

2. **Five vault folders** created in `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/`:
   - `sources/slack/` — receives source/slack notes from Phase 15 Slack scanner
   - `sources/outlook/` — receives source/outlook notes from Phase 15 Outlook scanner
   - `atoms/` — receives atom notes from Phase 16 splitter
   - `themes/` — receives theme notes from Phase 16 theme-matcher
   - `drafts/` — receives draft notes from Phase 17 synthesis

3. **ANM routing rules** (5 new pattern-based rules prepended to existing 8 tag-based rules = 13 total). New rules use regex anchored to frontmatter type field (`^type: atom$`). Specific sub-type rules for source/slack and source/outlook appear before any generic rule to prevent mis-routing.

4. **Test atom note** (`Test atom - adoption curve plateau.md`) created in vault root with all required frontmatter fields. ANM will route it to `atoms/` on save in Obsidian.

---

## Decisions Made

### Nested provenance YAML object
Used `provenance:` nested object (not flat `provenance_*` prefixes) for both Slack and Outlook. Enables Dataview dot-notation queries (`WHERE provenance.channel = "general"`). Consistent format across both source types.

### split_index on atoms
Included `split_index` (integer, 1-based) on atom notes. When a source note yields multiple atoms, split_index records their extraction order. Enables reconstruction of original source context. Cost: one field. Benefit: ordering integrity across multi-atom splits.

### source_type as lightweight provenance on atoms
ATOM-02 requires provenance metadata on atoms. CONTEXT.md prohibits copying full provenance to atoms (two sources of truth). Resolution: `source_type` field (`slack`, `outlook`, `goodlinks`, `youtube`) on atoms satisfies ATOM-02 by enabling origin-based Dataview queries without traversing the backlink. Full provenance stays on source note.

### ANM prepend order
New rules are prepended to `folder_tag_pattern` (before existing 8 rules). This ensures `source/slack` and `source/outlook` rules match before any generic `#model-citizen/source` tag rule that routes to the flat `sources/` folder.

### themes/ vs concepts/ distinction
Documented explicitly: `concepts/` = manually created frameworks and mental models; `themes/` = programmatically created aggregation hubs from the intelligence pipeline. Existing tag-based routing for concepts/ unchanged.

---

## Checkpoint: Task 3 (Auto-approved)

**Type:** checkpoint:human-verify
**Auto-approved:** yes (auto_advance: true in config.json)
**What to verify in Obsidian:**
1. Five new folders visible in vault sidebar
2. Test atom note opens in Obsidian and shows correct frontmatter
3. On save, test atom routes to `atoms/` folder via ANM
4. Dataview query `LIST FROM "700 Model Citizen/atoms"` returns the test atom

---

## Deviations from Plan

None — plan executed exactly as written.

---

## Self-Check

- [x] `model-citizen/vault/SCHEMA.md` created with all 4 note type definitions
- [x] ANM data.json has 13 rules (`jq '.folder_tag_pattern | length'` = 13)
- [x] First ANM rule is `^type: source/slack$` (prepended correctly)
- [x] Vault folders created: sources/slack/, sources/outlook/, atoms/, themes/, drafts/
- [x] Test atom note created with all required fields
- [x] Commit 69de982 exists for Task 1

## Self-Check: PASSED
