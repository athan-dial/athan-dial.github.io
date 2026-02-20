---
phase: 12
plan: 01
subsystem: goodlinks-scanner
tags: [python, sqlite, bash, obsidian, ingestion]
dependency_graph:
  requires: []
  provides: [goodlinks-scanner, vault-source-notes]
  affects: [phase-13-pipeline-integration]
tech_stack:
  added: [goodlinks-query.py, ingest-goodlinks.sh]
  patterns: [sqlite-read-only-uri, incremental-state-file, lookback-buffer, content-status-pending]
key_files:
  created:
    - ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault/scripts/goodlinks-query.py
    - ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault/scripts/ingest-goodlinks.sh
    - sources/goodlinks/*.md (42 vault notes created on first run)
  modified: []
decisions:
  - deletedAt=0.0 not NULL for active GoodLinks items — query uses (deletedAt IS NULL OR deletedAt = 0)
  - LOOKBACK_SECONDS=3600 for iCloud sync buffer with seen_ids dedup to prevent re-emission
  - content_status pending for 2/42 links without pre-extracted content (stub note approach)
metrics:
  duration: 134 seconds
  tasks_completed: 2
  files_created: 44
  completed_date: 2026-02-19
---

# Phase 12 Plan 01: GoodLinks Scanner Summary

Python + bash scanner that reads GoodLinks SQLite DB with read-only URI mode, emits vault Markdown notes with YAML frontmatter, and tracks incremental state via JSON seen_ids for dedup across runs.

## What Was Built

**goodlinks-query.py** — Core Python script that:
- Connects read-only to `~/Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite` using `sqlite3.connect("file:{path}?mode=ro", uri=True)`
- Loads/saves state from `~/.model-citizen/goodlinks-state.json` with `last_scan_ts` + `seen_ids`
- Default first-run: 30 days back to avoid flooding enrichment queue
- LOOKBACK_SECONDS=3600 buffer for iCloud sync lag + `seen_ids` set for dedup
- Queries `link LEFT JOIN content` filtering `status=0 AND (deletedAt IS NULL OR deletedAt=0) AND addedAt > since_ts`
- Emits vault Markdown notes with full YAML frontmatter to `--output-dir`
- `content_status: pending` for links without pre-extracted content
- `argparse` CLI with `--output-dir` (required) and `--dry-run` (optional)

**ingest-goodlinks.sh** — Bash orchestrator that:
- Sets `VAULT_DIR`, `OUTPUT_DIR=sources/goodlinks`, `PYTHON=/opt/homebrew/bin/python3.12`
- `set -euo pipefail` + `mkdir -p "$OUTPUT_DIR"`
- Passes `--dry-run` flag through to Python script
- Matches `ingest-youtube.sh` structure for pipeline consistency

**Initial run results:** 42 vault notes created from last 30 days of GoodLinks saves. 2 notes with `content_status: pending`.

## Verification Results

| Check | Result |
|-------|--------|
| `goodlinks-query.py --dry-run` exits 0 | PASS |
| `ingest-goodlinks.sh --dry-run` exits 0 | PASS |
| Real run creates 42 .md files in sources/goodlinks/ | PASS |
| All notes have title, date, status, tags, source, source_url, goodlinks_id | PASS |
| Links without content have content_status: pending | PASS (2/42) |
| `~/.model-citizen/goodlinks-state.json` has last_scan_ts + seen_ids | PASS |
| Re-run reports "0 new" (idempotency) | PASS |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed deletedAt NULL assumption**
- **Found during:** Task 1 verification — dry-run returned 0 links
- **Issue:** Research noted `deletedAt IS NULL` as filter, but GoodLinks stores `0.0` (epoch) for non-deleted items, not NULL. All 92 links have `deletedAt = 0.0`.
- **Fix:** Changed query filter from `l.deletedAt IS NULL` to `(l.deletedAt IS NULL OR l.deletedAt = 0)`
- **Files modified:** goodlinks-query.py
- **Commit:** 4874f30 (amended before final)

## Commits

| Task | Commit | Files |
|------|--------|-------|
| Task 1: goodlinks-query.py | 4874f30 | scripts/goodlinks-query.py |
| Task 2: ingest-goodlinks.sh + vault notes | 83bcb11 | scripts/ingest-goodlinks.sh, sources/goodlinks/*.md (42 files) |

Note: Both scripts committed to vault git repo (`model-citizen-vault/`) since files are outside the portfolio site repo.

## Self-Check: PASSED

- `goodlinks-query.py` exists and is executable: CONFIRMED
- `ingest-goodlinks.sh` exists and is executable: CONFIRMED
- 42 .md files in sources/goodlinks/: CONFIRMED
- `~/.model-citizen/goodlinks-state.json` exists: CONFIRMED
- Vault commits 4874f30 and 83bcb11 exist: CONFIRMED
