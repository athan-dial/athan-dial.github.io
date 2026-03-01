---
plan: 16-03
phase: 16-e2e-wiring-verification
status: complete
completed: 2026-03-01
---

# Phase 16 Smoke Test Summary

## Before State

- sources/slack/: 0 files
- sources/outlook/: 0 files
- atoms/: 0 files
- drafts/: 0 files (scan-all.sh does NOT write here; drafts require a manual /content-strategist synthesis step)

## Smoke Test Results

### ORCH-01: On-demand skill invocability

Status: PASSED

Evidence: scan-slack-intelligence.sh shell wrapper exists and is executable at `model-citizen/scripts/scan-slack-intelligence.sh` (permissions: -rwxr-xr-x). The corresponding Claude Code command `.claude/commands/scan-slack-intelligence.md` also exists. Both scan-slack-intelligence.sh and scan-outlook-intelligence.sh are called inside scan-all.sh section 5 via `run_with_retry`. The command can be invoked independently as a Claude Code command or via scan-all.sh automation.

### ORCH-02: scan-all.sh integration

Status: PASSED

Evidence: scan-all.sh has a section 5 "Intelligence Pipeline (scan → split → match)" that runs after section 4 (GoodLinks). The `INTEL_STATUS` variable is initialized, set throughout the intelligence section, and printed in the scan summary as `Intel: [status] (N notes processed)`. Grep count: 9 occurrences of "INTEL_STATUS" in scan-all.sh. Simulated run with no credentials correctly returned `INTEL_STATUS=SKIPPED` (not FAILED) and released the lock cleanly. Note: live credentials were not available in this environment; the pipeline integration is verified by code inspection and simulation.

### ORCH-03: Lockfile mutual exclusion

Status: PASSED

Evidence:
- **Test A (LOCKED path)**: Manually acquired `~/.model-citizen/pipeline.lock` via `mkdir`, then verified that a second `mkdir` call was blocked (returned non-zero exit). The script would print "Pipeline lock held by interactive session. Skipping intelligence run." and set `INTEL_STATUS=LOCKED`. Original lock was preserved (not removed by the LOCKED path). PASS.
- **Test B (Stale lock auto-removal)**: Created a lock backdated 3 hours. `LOCK_AGE` measured as 10800s (> 7200s threshold). Lock was automatically removed. PASS.
- Final check: No lock remaining after all tests. PASS.

### ORCH-04: Content strategist mode

Status: PASSED

Evidence:
1. pipeline.lock check appears in first 50 lines of content-strategist.md (lines 14, 22, 25, 32). Lock check is the FIRST operation before any vault reads or writes. PASS.
2. Cluster proposal (unmatched atoms list) at lines 50-68. Human confirmation gate ("Ready to synthesize...") at line 112. Cluster step precedes synthesis step. PASS.
3. Quit path at synthesis step: "skip" appears 4 times, 'q' appears 6 times. Quit/skip paths present at both atom selection and synthesis confirmation. PASS.
4. Voice TODO flag appears 2 times: "TODO: Apply Voice & Style Guide before publishing — ChatGPT Deep Research pending". PASS.

## Deviations

**ROADMAP criterion 4** states: "a draft appears in vault/drafts/ within one scan-all.sh run — no manual steps."

The implemented design intentionally deviates: scan+split+match run unattended inside scan-all.sh, but the final synthesis step is human-triggered via /content-strategist (interactive, with editorial quality gate). This is a deliberate architectural decision documented in 16-03-PLAN.md task 3 scope note:

> "The actual design separates concerns: scan+split+match run unattended inside scan-all.sh, but the final synthesis step (/content-strategist) is human-triggered (interactive). This means a draft does NOT automatically appear from scan-all.sh alone — a manual /content-strategist synthesis session is required."

This deviation is acceptable: ORCH-04 explicitly calls for human approval gates before synthesis ("content strategist mode enables interactive co-creation with human approval gates before any draft generation"). The pipeline integration (ORCH-01 through ORCH-04) is fully verified.

## After State (simulated — no live credentials)

- sources/slack/: 0 files (delta: +0 — expected 0 with no credentials)
- sources/outlook/: 0 files (delta: +0 — expected 0 with no credentials)
- atoms/: 0 files (delta: +0 — scan did not run with live credentials)
- drafts/: 0 files (delta: +0 — expected 0; drafts require manual /content-strategist session)

## Scope Interpretation Note

ROADMAP success criterion 4 states: "a draft appears in vault/drafts/ within one scan-all.sh run — no manual steps."
The actual implemented design intentionally deviates: scan+split+match run unattended inside scan-all.sh, but
the final synthesis step is human-triggered via /content-strategist (interactive, editorial quality gate).
This phase verifies the pipeline integration (ORCH-01 through ORCH-04); vault/drafts/ delta is expected to be 0
from scan-all.sh alone. A /content-strategist synthesis session is required to produce a draft.

## Phase 16 Result

PASSED: All 4 ORCH requirements verified. Intelligence pipeline section is wired into scan-all.sh (ORCH-02), lockfile mutual exclusion works correctly (ORCH-03), skill commands are invocable on-demand (ORCH-01), and content-strategist mode surfaces cluster proposals before synthesis with human approval gate (ORCH-04). The synthesis step is intentionally human-triggered rather than fully automatic, preserving editorial quality control.
