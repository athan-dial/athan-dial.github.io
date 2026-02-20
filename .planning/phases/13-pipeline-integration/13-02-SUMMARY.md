---
phase: 13-pipeline-integration
plan: 02
subsystem: vault-scripts
tags: [goodlinks, dedup, enrichment, scan-all, notifications, pipeline]
dependency_graph:
  requires: [13-01-url-normalization]
  provides: [goodlinks-pipeline-integration, dedup-in-scanner, enrichment-trigger, failure-notifications]
  affects: [daily-automation, scan-all-orchestrator]
tech_stack:
  added: []
  patterns: [importlib-dynamic-import, continue-on-failure, run-with-retry, osascript-notifications]
key_files:
  created: []
  modified:
    - ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault/scripts/goodlinks-query.py
    - ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault/scripts/ingest-goodlinks.sh
    - ~/Documents/GitHub/athan-dial.github.io/model-citizen/scripts/scan-all.sh
decisions:
  - "Used importlib.util for dedup-check.py import (same hyphenated-filename pattern as normalize-url.py in Plan 01)"
  - "sources_dir derived as output_dir.parent so dedup check scans all vault sources, not just goodlinks/"
  - "find -mmin -5 used as proxy for notes created in current run — simpler than parsing script output"
  - "run_with_retry added as shared helper for all scanners, applied specifically to GoodLinks section"
metrics:
  duration: "~8 min"
  completed: 2026-02-20
  tasks: 2
  files: 3
---

# Phase 13 Plan 02: GoodLinks Pipeline Integration Summary

GoodLinks wired into daily automation — scan-all.sh runs GoodLinks as 4th source with dedup check before note creation, enrichment trigger for new notes, macOS failure notifications, and a per-source run summary including dedup counts.

## Tasks Completed

| # | Task | Commit | Key Files |
|---|------|--------|-----------|
| 1 | Integrate dedup into goodlinks-query.py and add enrichment to ingest-goodlinks.sh | 60640ee (vault) | goodlinks-query.py, ingest-goodlinks.sh |
| 2 | Add GoodLinks to scan-all.sh with failure notifications and run summary | fad7921 | scan-all.sh |

## What Was Built

### goodlinks-query.py changes
- Imports `normalize_url` and `check_and_handle_dedup` via importlib (consistent with dedup-check.py's pattern for hyphenated filenames)
- Calls `check_and_handle_dedup` before `emit_note` — skips note creation and merges tags if URL already exists in vault under any source
- `sources_dir` derived as `output_dir.parent` (the `sources/` directory) so dedup scan covers all sources, not just `goodlinks/`
- Adds `normalized_url` field to note frontmatter alongside `source_url`
- Updated summary line: "GoodLinks scan complete: N notes created, M duplicates skipped"

### ingest-goodlinks.sh changes
- After Python script completes (non-dry-run only), finds notes modified within the last 5 minutes via `find -mmin -5`
- Calls `enrich-source.sh --source <note> --verbose` for each new note
- Per-note enrichment failures log a warning and continue (don't abort the run)
- Updated completion message: "GoodLinks scan + enrichment complete"

### scan-all.sh changes
- Added `run_with_retry` helper function: runs command once, retries after 3s on failure
- Added GoodLinks as section 4 with DB existence check before calling ingest-goodlinks.sh
- Extracts `GOODLINKS_URLS` and `GOODLINKS_DEDUP` from script output using grep
- Added macOS failure notification: osascript triggers when any scanner has FAILED status
- Updated `TOTAL_URLS` to include `GOODLINKS_URLS`
- Updated all-failed check to require all 4 scanners to fail before exiting 1
- Added GoodLinks row to summary table with notes and dedup counts
- Added `/tmp/scan-goodlinks.log` to cleanup list

## Verification Results

- `ingest-goodlinks.sh --dry-run` exits 0, reports "0 notes created, 0 duplicates skipped"
- `scan-all.sh --dry-run` shows all 4 scanner sections (Slack, Outlook, Queue, GoodLinks) with correct statuses
- GoodLinks row appears in run summary with notes/dedup columns
- All-failed check includes GOODLINKS_STATUS (confirmed via grep)
- osascript notification line exists in script (line 176)

## End-to-End Flow Achieved

```
GoodLinks app (iOS/macOS)
  → sqlite DB (group.com.ngocluu.goodlinks)
  → goodlinks-query.py (dedup check → emit note with normalized_url)
  → ingest-goodlinks.sh (enrichment trigger for new notes)
  → enrich-source.sh (summary, tags, ideas)
  → scan-all.sh (orchestration, retry, notifications, summary)
```

Saving an article in GoodLinks and running scan-all.sh now produces an enriched vault note without manual intervention. A URL already in the vault from Slack or web capture is detected by dedup check, tags merged, no duplicate note created.

## Deviations from Plan

None — plan executed exactly as written.

## Self-Check: PASSED

Files exist:
- FOUND: goodlinks-query.py (vault)
- FOUND: ingest-goodlinks.sh (vault)
- FOUND: scan-all.sh (repo)

Commits exist:
- FOUND: 60640ee — feat(13-02): integrate dedup check and enrichment trigger into GoodLinks scanner
- FOUND: fad7921 — feat(13-02): add GoodLinks to scan-all.sh with retry, notifications, and run summary
