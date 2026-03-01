---
plan: 15-04
phase: 15-intelligence-skills
status: complete
completed: 2026-03-01
---

# Summary: Theme Matching Skill

## What Was Built

Claude Code command `/match-themes <path>` that:
- Reads a target atom note and extracts title keywords and tags
- Runs 3 grep passes across `atoms/` and `themes/` folders
- Selects at most 3 candidates by keyword overlap score (hard cap)
- Adds `## Theme connections` section to atom with wikilinks + one-sentence justifications
- Updates existing theme notes' `## Related atoms` section
- Creates new theme notes when no match exists

## Key Files

### key-files.created
- `.claude/commands/match-themes.md` — Claude Code command with full matching logic

## Decisions Made

**Three grep passes for coverage:** Pass A (title keywords vs themes), Pass B (tag overlap vs atoms), Pass C (title keywords vs atoms). This covers the most common matching patterns without requiring embeddings.

**Prefer theme files over atom files:** When ranking candidates, theme files rank higher than atom files at the same keyword overlap count. Themes are the aggregation layer — connecting to themes builds the concept graph faster than atom-to-atom links.

**Hard cap enforcement as prompt rule:** The command explicitly instructs "Take the top 3 by score. Do not add a 4th even if it seems relevant." This is a behavioral constraint, not code-enforced.

**New theme creation threshold:** The command instructs only to create theme notes for concepts broad enough to aggregate 2+ atoms — preventing hyper-specific theme notes for single-atom concepts.

## Deviations from Plan

None. Single-task plan implemented as specified. The grep patterns from the RESEARCH.md were embedded directly in the command.

## Self-Check

| Check | Result |
|-------|--------|
| `.claude/commands/match-themes.md` exists | ✅ |
| Contains "at most 3 wikilinks" hard cap (THEME-03) | ✅ |
| Requires one-sentence justification per connection (THEME-02) | ✅ |
| Three grep passes documented | ✅ |
| Updates existing theme notes' Related atoms section | ✅ |
| Creates new theme notes with `tags: [type/theme]` | ✅ |
| Writes to `themes/` directly | ✅ |
