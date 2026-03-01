---
plan: 16-01
phase: 16-e2e-wiring-verification
status: complete
completed: 2026-03-01
---

# Plan 16-01: Intelligence Pipeline Wiring in scan-all.sh

## What Was Built

Added Intelligence Pipeline as section 5 to `model-citizen/scripts/scan-all.sh`, wiring the Phase 15 scanner shell wrappers (scan-slack-intelligence.sh, scan-outlook-intelligence.sh) into the daily orchestrator with pipeline.lock mutual exclusion.

## Tasks Completed

| Task | Status | Commit |
|------|--------|--------|
| Task 1: Add Intelligence Pipeline section | ✓ Complete | bd965ed |
| Task 2: Validate syntax and lockfile logic | ✓ Complete | (validated inline) |

## Key Files

### Modified
- `model-citizen/scripts/scan-all.sh` — Added section 5 Intelligence Pipeline with lockfile, scanners, auto split+match loop, and INTEL_STATUS tracking

## What Was Delivered

- **Section 5 Intelligence Pipeline**: Runs after GoodLinks section (section 4)
- **pipeline.lock mutual exclusion**: mkdir-based acquire/release; EXIT/INT/TERM trap releases on any exit
- **Stale lock detection**: Removes locks older than 2 hours before checking
- **LOCKED state**: When interactive session holds lock, scan skips cleanly (INTEL_STATUS=LOCKED, not FAILED)
- **Scanner calls**: scan-slack-intelligence.sh (when SLACK_BOT_TOKEN set) and scan-outlook-intelligence.sh (when MS_GRAPH_CLIENT_ID set)
- **Auto split+match loop**: Finds unprocessed source notes and runs split-source + match-themes on each
- **INTEL_STATUS**: Tracked and reported in summary block (SKIPPED/LOCKED/SUCCESS/FAILED)
- **Missing credentials**: Causes INTEL_STATUS=SKIPPED, not FAILED
- **Summary line**: "Intel: [status] (N notes processed)" added alongside existing scanner lines

## Verification

All checks passed:
- `bash -n model-citizen/scripts/scan-all.sh` → exit 0 (no syntax errors)
- Intelligence Pipeline section present (section 5 header)
- pipeline.lock acquire (mkdir) before any scanner calls
- EXIT trap registered immediately after lock acquisition
- Stale lock check present (LOCK_AGE > 7200)
- INTEL_STATUS in summary output
- Lock behavior test: acquire succeeds, second acquire blocked, cleanup works

## Self-Check: PASSED

Requirements ORCH-02 and ORCH-03 satisfied.
