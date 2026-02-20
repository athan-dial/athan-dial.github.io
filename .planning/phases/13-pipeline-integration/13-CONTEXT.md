# Phase 13: Pipeline Integration - Context

**Gathered:** 2026-02-20
**Status:** Ready for planning

<domain>
## Phase Boundary

Wire the GoodLinks scanner into daily 7AM automation, add cross-source URL normalization for deduplication, and validate end-to-end flow from GoodLinks save to enriched vault note. The scanner itself (Phase 12) is complete; this phase connects it to the existing pipeline.

</domain>

<decisions>
## Implementation Decisions

### URL Normalization
- Claude's discretion on aggressiveness — sample 10-15 real GoodLinks URLs from live DB first, then decide which tracking params to strip
- Canonicalize domains: strip www., resolve mobile/amp subdomains to canonical form
- Apply retroactively to all existing vault notes (Slack, Outlook, YouTube) — one-time migration ensures dedup catches old+new overlaps
- Shared utility: standalone normalize-url script/function that all scanners import (single source of truth)

### Failure Behavior
- Continue-on-failure pattern (consistent with existing scan-all.sh) — one source failing doesn't block others
- macOS notification on any scanner failure (all sources, not just GoodLinks) — retrofit existing sources
- One retry with short delay before declaring failure and notifying

### Dedup Strategy
- Dedup check happens before enrichment (no wasted Claude calls on duplicates)
- URL-only matching (normalized URL, no fuzzy title matching)
- On duplicate: merge tags from GoodLinks into existing note, don't create new note
- Multi-source field: change `source` from single string to array (e.g., `['slack', 'goodlinks']`) to show provenance

### Validation
- Build dry-run mode (--dry-run flag shows what WOULD happen without creating notes or calling enrichment)
- Also validate with real data: save article in GoodLinks, trigger manual scan, verify enriched note in vault
- Trust dedup logic at unit level (no explicit cross-source integration test required)
- Auto-enable in scan-all.sh once validation passes (no manual switch)
- Run summary after each daily scan: X notes from Slack, Y from GoodLinks, Z skipped (dedup) — logged for observability

### Claude's Discretion
- URL normalization param strip list (after sampling real URLs)
- Retry delay duration
- Exact run summary format and location
- Migration script approach for retroactive URL normalization

</decisions>

<specifics>
## Specific Ideas

- Carried concern from STATE.md: "Sample 10-15 real GoodLinks URLs from live DB before writing normalization list. Five-minute task; prevents over/under-engineering tracking param strip list."
- Run summary should be actionable — show counts per source plus dedup skips so you can spot anomalies at a glance

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 13-pipeline-integration*
*Context gathered: 2026-02-20*
