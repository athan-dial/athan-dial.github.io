# Phase 8: Human Review & Approval Dashboard - Context

**Gathered:** 2026-02-06
**Status:** Ready for planning

<domain>
## Phase Boundary

User has a clear workflow to review enriched content (summaries, tags, idea cards) and approve, skip, or reject items for publishing. Only approved content proceeds to Phase 9 (Publish Sync). This phase covers the review surface, approval mechanism, and publishing rules — NOT the actual sync/deploy to Quartz.

</domain>

<decisions>
## Implementation Decisions

### Review surface
- Show summary + idea cards together for each source (enough context to decide without opening every file)
- Research Obsidian Bases (new native feature) as potential review surface before defaulting to Dataview or plain markdown — researcher should compare Bases vs Dataview vs static markdown for this use case

### Approval mechanism
- Three states: approved, skip (stays pending), rejected (archived/hidden)
- Both manual (edit frontmatter / move files in Obsidian) and script command for batch operations
- Script handles status updates, file moves, and any bookkeeping

### Claude's Discretion
- Whether to use frontmatter status changes vs folder moves (or hybrid) — pick what fits existing vault conventions
- Review surface implementation (Bases vs Dataview vs plain markdown) — based on research findings
- Whether sources and idea cards are approved separately or as a bundle — pick what's simplest for the workflow
- Sorting/filtering approach — design for whatever volume makes sense
- Exact review dashboard layout and information density

</decisions>

<specifics>
## Specific Ideas

- User specifically called out Obsidian Bases as worth researching — it's a relatively new native feature that may replace the need for Dataview plugin
- Manual + script hybrid: manual for one-offs, script for batch operations

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 08-review-approval*
*Context gathered: 2026-02-06*
