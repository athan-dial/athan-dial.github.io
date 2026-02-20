---
phase: 13-pipeline-integration
plan: 01
subsystem: vault-scripts
tags: [url-normalization, dedup, migration, python]
dependency_graph:
  requires: []
  provides: [normalize-url.py, dedup-check.py, migrate-normalize-urls.py]
  affects: [13-02-pipeline-wiring]
tech_stack:
  added: [python-frontmatter]
  patterns: [importlib-dynamic-import, atomic-write-temp-rename, argparse-cli]
key_files:
  created:
    - ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault/scripts/normalize-url.py
    - ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault/scripts/dedup-check.py
    - ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault/scripts/migrate-normalize-urls.py
  modified:
    - ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault/sources/**/*.md (46 files — added normalized_url)
decisions:
  - "Used importlib.util for sibling script import because normalize-url.py filename has hyphen (not valid Python module name)"
  - "Migration inserts normalized_url via python-frontmatter (same lib used by update-frontmatter.py) for consistency"
  - "dedup-check.py exits 0 on duplicate (caller can check), exits 1 for new URL — shell-friendly exit codes"
  - "Retained perma and lid as additional tracking params after sampling real GoodLinks URLs"
metrics:
  duration: "~12 min"
  completed: 2026-02-20
  tasks: 2
  files: 49
---

# Phase 13 Plan 01: URL Normalization Infrastructure Summary

URL normalization and dedup check utilities built as shared cross-source infrastructure — strip UTM/tracking params and www. prefix, identify existing vault notes by canonical URL, merge tags on duplicate, migrate 46 existing source notes with normalized_url field.

## Tasks Completed

| # | Task | Commit | Key Files |
|---|------|--------|-----------|
| 1 | Create normalize-url.py and dedup-check.py | 9c64ad3 (vault) | normalize-url.py, dedup-check.py |
| 2 | Create migrate-normalize-urls.py and run migration | 6a10cb7 (vault) | migrate-normalize-urls.py + 46 source notes |

## What Was Built

### normalize-url.py
Shared URL normalization utility. Strips 17 tracking parameters (UTM set, share_id, fbclid, gclid, lid, perma, etc.) sampled from real GoodLinks iOS captures. Removes www. prefix, forces https, strips trailing slashes, sorts remaining query params alphabetically. CLI-friendly: `python3 normalize-url.py "<url>"` prints canonical form.

### dedup-check.py
Dedup check with tag merge. Scans all .md files in vault sources recursively for source_url (or normalized_url) frontmatter that normalizes to the same URL. On duplicate: merges tags (union, no dupes), converts single `source` string to `sources` array for multi-provenance tracking. Shell exit codes: 0 = duplicate found, 1 = new URL.

### migrate-normalize-urls.py
One-time migration script. Scanned 49 source notes, added normalized_url to 46 (3 had no source_url). Idempotent: re-run produces 0 changes. Supports --dry-run for safe preview.

## Verification Results

- `normalize-url.py` strips Reddit iOS share params correctly: `https://www.reddit.com/r/ClaudeAI/comments/1r3hr40/?share_id=...&utm_content=1&utm_medium=ios_app` → `https://reddit.com/r/ClaudeAI/comments/1r3hr40`
- `dedup-check.py` correctly finds existing note when URL differs only in tracking params (exit 0)
- `dedup-check.py` correctly returns NEW for unknown URL (exit 1)
- Migration ran: 46 migrated, 0 errors, 0 corrupted files
- Idempotency confirmed: re-run shows 46 skipped, 0 migrated

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] importlib required for hyphenated filename import**
- **Found during:** Task 1 verification
- **Issue:** `from normalize_url import normalize_url` fails because Python cannot import modules with hyphens in filenames
- **Fix:** Used `importlib.util.spec_from_file_location` to load normalize-url.py by path
- **Files modified:** dedup-check.py, migrate-normalize-urls.py (same pattern)
- **Commit:** part of 9c64ad3

None of the other planned behaviors changed. Plan executed cleanly.

## Self-Check: PASSED

Files exist:
- FOUND: normalize-url.py (vault)
- FOUND: dedup-check.py (vault)
- FOUND: migrate-normalize-urls.py (vault)

Commits exist:
- FOUND: 9c64ad3 — feat(13-01): add URL normalization and dedup check utilities
- FOUND: 6a10cb7 — feat(13-01): add migration script and apply retroactive URL normalization

Vault source notes migrated: 46 confirmed via grep count.
