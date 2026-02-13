---
phase: 10-content-ingestion
plan: 02
subsystem: content-ingestion
tags: [web-capture, readability, share-sheet, obsidian-vault]

# Dependency graph
requires:
  - phase: 10-01
    provides: "Vault structure and templates"
provides:
  - "Web article capture CLI with full-text extraction"
  - "Queue-based capture system for macOS Shortcuts integration"
  - "Duplicate URL detection and context merging"
affects: [10-03]

# Tech tracking
tech-stack:
  added: ["@mozilla/readability", "linkedom", "turndown", "bash queue system"]
  patterns: ["Queue-based async capture", "URL-based deduplication with context merging", "Readability article extraction"]

key-files:
  created:
    - "model-citizen/scripts/extract-article.mjs"
    - "model-citizen/scripts/capture-web.sh"
    - "model-citizen/scripts/capture-queue.sh"
    - "model-citizen/scripts/package.json"
  modified: []

key-decisions:
  - "Used linkedom instead of jsdom for lightweight DOM (no native dependencies, faster)"
  - "Bash wrapper for capture-web.sh provides vault integration and duplicate detection"
  - "Queue-based architecture enables instant share sheet capture with batch processing"
  - "URL-based deduplication with context merging (not skip/overwrite)"

patterns-established:
  - "Article extraction: fetch → linkedom → Readability → turndown → markdown"
  - "Duplicate detection: grep vault for 'url: {URL}' before creating note"
  - "Queue format: JSON lines at ~/.model-citizen/capture-queue.txt"
  - "Failed captures retained in queue for retry"

# Metrics
duration: 2min
completed: 2026-02-13
---

# Phase 10 Plan 02: Web Article Capture Tool Summary

**Readability-powered web capture with share sheet integration via queue-based architecture**

## Performance

- **Duration:** 2 min
- **Started:** 2026-02-13T15:15:07Z
- **Completed:** 2026-02-13T15:18:03Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Web article extractor using @mozilla/readability with full markdown conversion
- Bash CLI wrapper with duplicate URL detection and context merging
- Queue-based capture system enabling async share sheet integration
- Complete macOS Shortcuts integration instructions

## Task Commits

Each task was committed atomically:

1. **Task 1: Create Node.js article extractor and bash capture wrapper** - `e8dca87` (feat)
2. **Task 2: Create macOS Shortcut for share sheet capture** - `e1c0642` (feat)

**Plan metadata:** (to be committed)

## Files Created/Modified

### Created
- `model-citizen/scripts/extract-article.mjs` - Node.js ESM script using @mozilla/readability + linkedom for article extraction
- `model-citizen/scripts/capture-web.sh` - Bash wrapper with vault integration, duplicate detection, and context merging
- `model-citizen/scripts/capture-queue.sh` - Queue system for async capture (add/process modes)
- `model-citizen/scripts/package.json` - Dependencies: @mozilla/readability, linkedom, turndown

### Modified
None - all new files

## Decisions Made

**1. linkedom over jsdom**
- Rationale: Lightweight pure-JS DOM implementation; no native dependencies; faster instantiation than jsdom
- Trade-off: Less feature-complete than jsdom, but sufficient for Readability API needs
- Impact: Simpler deployment, no compilation step, better performance

**2. Bash wrapper for vault integration**
- Rationale: Provides duplicate detection, frontmatter generation, and vault path handling separate from extraction logic
- Trade-off: Shell script complexity vs pure Node.js approach
- Impact: Clear separation: Node.js handles web → markdown, bash handles vault → persistence

**3. Queue-based capture architecture**
- Rationale: Share sheet must return instantly; queue enables async processing
- Trade-off: Two-step process (capture → process) vs direct capture
- Impact: Better UX (instant share sheet response), resilience (failed captures retained), batch efficiency

**4. URL-based deduplication with context merging**
- Rationale: User wants to see when content arrives from multiple sources
- Trade-off: Slightly more complex logic vs skip/overwrite
- Impact: Preserves provenance; user knows "boss recommended" came from 3 different channels

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None - all components worked as expected on first implementation.

## User Setup Required

None - no external service configuration required. All operations local (vault, filesystem).

## Next Phase Readiness

**Ready for 10-03:** Slack + Outlook scanners can now follow same pattern:
- Extract URLs + context from API
- Use capture-web.sh for article extraction and vault writing
- Leverage existing duplicate detection
- Queue-based or direct capture patterns established

Web capture validates the full ingestion → vault → dedup pipeline. Slack/Outlook are API variations on the same pattern.

---
*Phase: 10-content-ingestion*
*Completed: 2026-02-13*
