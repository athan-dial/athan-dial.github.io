# Phase 10: Content Ingestion - Context

**Gathered:** 2026-02-10
**Status:** Ready for planning

<domain>
## Phase Boundary

Ingest content from multiple external sources (web articles, Slack, Outlook, YouTube) into the central Model Citizen vault. Content flows through the existing enrichment pipeline (Phase 7). This phase adds new source connectors and a unified capture/scan mechanism — it does NOT change the enrichment, review, or publish workflows.

</domain>

<decisions>
## Implementation Decisions

### Content Sources
- **YouTube videos** — already working from Phase 5; extend or keep as-is
- **Web articles/blogs** — full text extraction + original URL preserved as vault note
- **Slack** — saved items + DMs from boss; extract URLs AND surrounding context ("read this because...")
- **Outlook (M365 work)** — boss's emails with links; capture URL + commentary context
- **Read-later app** — currently uses GoodLinks (macOS + iOS); open to researcher recommending better alternatives or replacing with direct vault capture. Criteria: free or one-time purchase, macOS + iOS

### Capture Workflow
- **Primary gesture:** Share sheet / keyboard shortcut — instant capture from any app (browser, iOS)
- **Share sheet behavior:** Adds to a queue (not instant ingest); next scan/batch processes the queue
- **Optional quick note** at capture time — one-liner like "boss recommended" or "for Model Citizen idea" but not required
- **Slack/Outlook scan mode:** On-demand pull that grabs recently delivered materials with links
  - Slack: scan saved items + DMs from boss
  - Outlook: scan boss's emails for links
- **Scan as Claude skill** — user wants this invocable as a Claude Code skill (e.g., `/scan`)

### Normalization Rules
- **Article content:** Full text extraction into markdown note + original URL preserved (Reader-mode style)
- **Source type tracking:** Frontmatter field `source_type: article|youtube|slack|email` (not subfolders)
- **All sources → enrichment pipeline:** Same Phase 7 pipeline (summarize, tag, generate ideas) regardless of source type
- **Dedup behavior:** If same URL arrives from multiple sources, merge context into existing note (append "also shared by boss via email") rather than skipping or creating duplicate

### Trigger & Scheduling
- **Daily auto-scan:** Scheduled scan of Slack saved items, boss DMs, and Outlook emails
- **Manual trigger:** Also invocable on-demand (Claude skill or CLI)
- **Scan timing:** Claude's discretion (reasonable default)

### Claude's Discretion
- Whether scan + enrichment runs as single pipeline or separate steps
- Daily scan timing
- Share sheet technical implementation (Shortcuts app, bookmarklet, etc.)
- Read-later app recommendation (keep GoodLinks, switch, or eliminate aggregator)
- Queue mechanism for share sheet captures

</decisions>

<specifics>
## Specific Ideas

- Boss sends emails with links to read — these are high-signal content worth capturing with his commentary
- Slack saved items are a natural "I want to revisit this" signal — good capture trigger
- GoodLinks is current read-later app but user is open to the vault itself replacing the aggregator
- Scan should feel like a periodic sweep, not constant monitoring

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 10-content-ingestion-from-various-locations-into-the-central-model-citizen-vault*
*Context gathered: 2026-02-10*
