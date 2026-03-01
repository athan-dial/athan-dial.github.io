---
plan: 16-02
phase: 16-e2e-wiring-verification
status: complete
completed: 2026-03-01
---

# Plan 16-02: content-strategist Claude Code Command

## What Was Built

Created `.claude/commands/content-strategist.md` — an interactive co-creation command for the Model Citizen content pipeline. The command enables a guided workflow: lock check → unmatched atom discovery → theme matching → human-confirmed synthesis.

## Tasks Completed

| Task | Status | Commit |
|------|--------|--------|
| Task 1: Write content-strategist Claude Code command | ✓ Complete | f2db828 |
| Task 2: Verify command structure and key constraints | ✓ Complete | (validated inline) |

## Key Files

### Created
- `.claude/commands/content-strategist.md` — Interactive co-creation command for content pipeline

## What Was Delivered

- **Step 1 — pipeline.lock check**: Reads `~/.model-citizen/pipeline.lock`; fails fast if scan holds lock, acquires lock if free, registers EXIT trap for auto-release
- **Step 2 — Cluster proposals**: Finds all atoms missing "## Theme connections" section; groups by `source_type` and `created` date; presents numbered list with quit ('q') option
- **Step 3 — Theme matching**: Runs same three grep passes as match-themes.md (title keywords vs themes/, tag overlap vs atoms/, title keywords vs atoms/); adds <= 3 wikilinks with justifications
- **Step 4 — Synthesis (human-confirmed)**: Human must enter theme before synthesis runs; uses same logic as synthesize-draft.md; draft includes voice TODO flag and is written as `publishability: private`
- **Step 5 — Lock release**: EXIT trap releases pipeline.lock automatically; prints confirmation message
- **CRITICAL constraints**: pipeline.lock check before any vault writes, no synthesis without user theme input, dual frontmatter (`type:` + `tags:`), voice TODO flag on all drafts, quit/skip paths at both decision points

## Verification

All checks passed:
- File exists at `.claude/commands/content-strategist.md`
- pipeline.lock references: 9 occurrences (check, acquire, release, etc.)
- Theme connections / unmatched references: 10 occurrences
- Human gate before synthesis: present ("Ready to synthesize... Enter a theme")
- Voice TODO flag: 2 occurrences ("TODO: Apply Voice & Style Guide before publishing — ChatGPT Deep Research pending")
- Quit/skip paths: 6 occurrences (at atom selection and synthesis steps)
- Dual frontmatter: 2 occurrences (`type: draft`, `tags: [type/draft]`)
- ChatGPT Deep Research reference: 2 occurrences

## Self-Check: PASSED

Requirement ORCH-04 satisfied.
