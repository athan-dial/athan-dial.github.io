---
plan: 15-03
phase: 15-intelligence-skills
status: complete
completed: 2026-03-01
---

# Summary: Atomic Splitting Skill

## What Was Built

Claude Code command `/split-source <path>` that:
- Reads a source note and identifies distinct concepts
- Writes one atom note per concept to `vault/atoms/` with full SCHEMA.md frontmatter
- Enforces ATOM-04: 2-3 sentences per atom including "why it matters" context
- Updates source note `content_status` from `raw` to `processed`

## Key Files

### key-files.created
- `.claude/commands/split-source.md` — Claude Code command with full splitting logic

## Decisions Made

**Explicit ATOM-04 instruction embedded verbatim:** The command prompt includes the exact wording: "Write 2–3 sentences: Sentence 1: Restate the concept with context. Sentences 2–3: Explain why this matters in the context of the original source material." This directly prevents the telegraphic atom anti-pattern.

**Already-processed guard:** Command checks `content_status: processed` before splitting and stops with a clear message. Prevents duplicate atoms from double-processing.

**Source type derivation from type field:** `source/slack` → `source_type: slack`, `source/outlook` → `source_type: outlook`. No manual input required.

**No provenance copying:** Atoms use only `atom_of` wikilink for provenance — no `provenance.*` fields copied. This is per SCHEMA.md design.

## Deviations from Plan

None. Single-task plan, implemented as specified.

## Self-Check

| Check | Result |
|-------|--------|
| `.claude/commands/split-source.md` exists | ✅ |
| Contains `atom_of` wikilink requirement | ✅ |
| ATOM-04 "why it matters" constraint embedded explicitly | ✅ |
| Writes to `atoms/` directly | ✅ |
| `tags: [type/atom]` included for ANM routing | ✅ |
| `split_index` sequential from 1 | ✅ |
| Updates source note `content_status` to processed | ✅ |
| `publishability: private` always | ✅ |
