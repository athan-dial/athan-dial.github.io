---
plan: 15-05
phase: 15-intelligence-skills
status: complete
completed: 2026-03-01
---

# Summary: Synthesis Skill

## What Was Built

Claude Code command `/synthesize-draft "<theme-or-topic>"` that:
- Finds related atoms via theme wikilink grep and title keyword grep
- Reads all matched atoms and clusters by through-lines
- Generates a draft blog post grounded only in atom content (SYNTH-03)
- Writes draft to `vault/drafts/` with `source_atoms` frontmatter listing cited atoms
- Enforces `publishability: private` with explicit manual promotion gate note (SYNTH-04)
- Contains Voice TODO placeholder for future Deep Research injection

## Key Files

### key-files.created
- `.claude/commands/synthesize-draft.md` — Claude Code command with full synthesis logic

## Decisions Made

**2-atom minimum before synthesis:** If fewer than 2 atoms found, the command stops with a clear message directing user to run `/match-themes` on more atoms. This prevents degenerate single-atom "drafts."

**source_atoms = cited only:** The `source_atoms` frontmatter field lists only atoms actually cited with `[[atom-title]]` inline wikilinks — not all matched atoms. This maintains traceability accuracy.

**Voice TODO block placed prominently:** The `# TODO: Voice & Style Guide` block is positioned at the top of the synthesis instructions, directly after the preamble. This ensures it's visible and actionable when Deep Research results arrive.

**SYNTH-03 constraint as hard rule:** The exact text "Write ONLY from the atom content loaded in Step 2" is embedded verbatim in the command. This is the most important constraint in the entire synthesis skill.

## Deviations from Plan

None. Single-task plan implemented as specified. Voice placeholder is exactly as the RESEARCH.md specified.

## Self-Check

| Check | Result |
|-------|--------|
| `.claude/commands/synthesize-draft.md` exists | ✅ |
| Contains SYNTH-03 "Write ONLY from atom content" constraint | ✅ |
| Contains TODO: Voice placeholder | ✅ |
| Writes to `drafts/` directly | ✅ |
| `tags: [type/draft]` for ANM routing | ✅ |
| `source_atoms` lists only cited atoms | ✅ |
| `publishability: private` with manual flip note | ✅ |
| Stops with clear error when fewer than 2 atoms found | ✅ |
