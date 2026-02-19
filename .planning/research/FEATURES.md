# Feature Research

**Domain:** GoodLinks-to-Obsidian ingestion pipeline (subsequent milestone to Model Citizen)
**Researched:** 2026-02-19
**Confidence:** HIGH (GoodLinks data access method confirmed via open-source tooling and direct SQLite schema)

---

## How GoodLinks Works (Access Patterns)

Before features, this context is essential for implementation decisions.

**Three available access methods (in order of preference for automation):**

1. **SQLite direct read** — GoodLinks stores data at `$HOME/Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite`. The `link` table contains all fields. This is the most reliable, scriptable, and automation-friendly method. Confirmed by open-source tooling (cychong47/goodlinks on GitHub). No app dependency at runtime.

2. **JSON export file** — GoodLinks has a built-in export (File > Export on Mac) that produces a JSON array. Each object contains: `id`, `url`, `originalURL`, `title`, `summary`, `author`, `preview`, `tags` (array), `starred` (bool), `readAt` (Unix timestamp or null), `addedAt` (Unix timestamp), `modifiedAt` (Unix timestamp), `fetchStatus`, `status`. Export is manual, not automatable without Shortcuts.

3. **Apple Shortcuts** — GoodLinks exposes a "Find Links" Shortcuts action with rich filtering (unread, tagged, date range, etc.) and returns link objects with full metadata including article content in HTML, plain text, or Markdown. Automatable via `shortcuts run` from shell. Requires GoodLinks app to be running/available. More fragile for headless/launchd use.

**Recommendation:** Use SQLite direct read as primary access method. It requires no app interaction, works in launchd context, and gives full field access without going through the Shortcuts API surface.

---

## Feature Landscape

### Table Stakes (Users Expect These)

Features the pipeline must have to be useful at all. Missing these = the integration is broken.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| SQLite scanner script (`scan-goodlinks.sh`) | All other sources (Slack, Outlook, YouTube) have a dedicated scanner script — GoodLinks needs the same pattern | LOW | Read from `$HOME/Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite`, query `link` table |
| URL-based deduplication | Same URL may be in GoodLinks and already captured via `capture-web.sh` or another source — duplicates pollute inbox | LOW | Check existing vault notes for matching `url:` in frontmatter before creating new note |
| YAML frontmatter matching pipeline schema | Output notes must have `title`, `url`, `source: goodlinks`, `date`, `tags`, `status: inbox` to flow into enrichment | LOW | Map GoodLinks `addedAt` → `date`, `tags[]` → `tags`, generate filename from title/date |
| Incremental scan (new-only) | Daily 7AM job must not re-ingest already-processed links on every run | LOW | Store last-seen `addedAt` timestamp in a state file (e.g., `.goodlinks-last-scan`) OR query SQLite with `WHERE addedAt > {last_run_epoch}` |
| Integration with existing daily launchd job | GoodLinks scanner must run as part of the 7AM automation, not as a separate manual step | LOW | Add `scan-goodlinks.sh` call to the existing orchestrator script |

### Differentiators (Valuable but Not Required for V1)

Features that make the integration smarter. The pipeline works without these, but they add meaningful signal.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Read-status routing | Links marked as `readAt IS NOT NULL` in GoodLinks can be routed differently than unread — e.g., unread → inbox for enrichment, already-read → direct to enriched queue | LOW | Single `WHERE` filter variation; aligns with how GoodLinks users actually organize reading |
| Starred flag passthrough | GoodLinks `starred = 1` maps to high-priority content — surface this in frontmatter as a tag or priority field so enrichment can weight it | LOW | Add `starred: true` to frontmatter when flag is set |
| Tag inheritance | GoodLinks tags (already applied by user) should flow into Obsidian note tags — avoids Claude re-inventing tags the user already assigned | LOW | Map `tags[]` array from SQLite directly into frontmatter `tags:` list |
| Article content extraction on capture | GoodLinks stores a `preview` field (excerpt), but not full article text. Run the URL through existing readability extraction (already built in `capture-web.sh`) when importing an unread GoodLinks link to get full content for enrichment | MEDIUM | Reuse existing readability logic rather than building new; skip for already-read items to avoid re-fetching stale content |
| Source metadata in note | Include `goodlinks_id`, `added_at`, `read_at` in frontmatter for traceability and potential round-trip debugging | LOW | Useful for troubleshooting; no downstream dependency in current pipeline |

### Anti-Features (Avoid These)

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Apple Shortcuts-based access | Looks clean, avoids direct DB access, "official" API surface | Requires GoodLinks app available at runtime, fragile in headless launchd context, Shortcuts runner adds latency and failure modes | Use SQLite direct read — it's what the app itself writes to, it's stable, and it's already used by open-source GoodLinks tooling |
| Full re-scan on every run | Simple to implement — just pull everything every time | Re-creates thousands of notes on every daily run, floods inbox, defeats deduplication | Timestamp-based incremental scan with state file |
| Bi-directional sync (write back to GoodLinks) | Appealing if you want to mark items read in GoodLinks from Obsidian | GoodLinks SQLite is app-owned storage — writes could corrupt app state or be overwritten on next iCloud sync | One-directional only: GoodLinks → Obsidian. Use the app itself to manage GoodLinks state |
| Polling for GoodLinks changes in real-time | "Instant" capture when you save a link | launchd daily schedule is sufficient; real-time polling adds always-on process complexity with minimal value | Stick to daily 7AM schedule |
| Separate enrichment pass for GoodLinks vs other sources | GoodLinks content might seem "different" from web captures | The existing Claude enrichment pipeline already handles any source with proper frontmatter — adding a separate pass fragments the pipeline | Route GoodLinks notes through the same inbox enrichment flow everything else uses |

---

## Feature Dependencies

```
[SQLite scanner script]
    └──requires──> [SQLite access to GoodLinks DB file]
    └──requires──> [State file for last-scan timestamp]
    └──produces──> [Inbox notes with YAML frontmatter]

[Incremental scan]
    └──requires──> [State file (.goodlinks-last-scan)]
    └──enhances──> [SQLite scanner script]

[URL deduplication]
    └──requires──> [Vault index or grep of existing note URLs]
    └──enhances──> [SQLite scanner script]

[Article content extraction]
    └──requires──> [Existing readability extraction (capture-web.sh logic)]
    └──enhances──> [SQLite scanner script]
    └──optional──> not needed for basic pipeline to work

[Tag inheritance]
    └──requires──> [SQLite scanner script]  (tags come from DB query)
    └──feeds into──> [Existing Claude enrichment] (fewer redundant tag suggestions)

[Daily launchd integration]
    └──requires──> [SQLite scanner script working correctly]
    └──wraps──> [All above features]
```

### Dependency Notes

- **SQLite scanner is the load-bearing feature:** Everything else (deduplication, incremental scan, tag inheritance) builds on it. Ship the scanner first, then layer in the rest.
- **Article content extraction is optional at launch:** The enrichment pipeline can work with just title + URL + tags + summary from GoodLinks. Full-text extraction is an enhancement, not a requirement.
- **Deduplication requires a decision on scope:** Simple approach = grep vault for matching URL in frontmatter. More robust = maintain a seen-URLs file. The simple approach is sufficient for V1.

---

## MVP Definition

### Launch With (v1)

Minimum needed to make GoodLinks a functioning pipeline source.

- [ ] `scan-goodlinks.sh` — reads SQLite, outputs markdown notes to inbox with correct frontmatter schema
- [ ] Incremental scan — only new links since last run (state file or timestamp query)
- [ ] URL deduplication — skip if URL already in vault
- [ ] Tag inheritance — pass GoodLinks user tags through to note frontmatter
- [ ] launchd integration — scanner runs as part of daily 7AM job

### Add After Validation (v1.x)

Add once V1 is confirmed working and notes are flowing correctly.

- [ ] Read-status routing — separate handling for unread vs already-read GoodLinks items
- [ ] Starred flag passthrough — surface `starred: true` in frontmatter for enrichment prioritization
- [ ] Article content extraction — reuse readability logic for unread items to improve enrichment quality

### Future Consideration (v2+)

- [ ] `goodlinks_id` round-trip metadata — only needed if you want to query back to GoodLinks by internal ID; no current use case

---

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| SQLite scanner script | HIGH | LOW | P1 |
| Incremental scan (state file) | HIGH | LOW | P1 |
| URL deduplication | HIGH | LOW | P1 |
| Tag inheritance | HIGH | LOW | P1 |
| launchd integration | HIGH | LOW | P1 |
| Read-status routing | MEDIUM | LOW | P2 |
| Starred flag passthrough | MEDIUM | LOW | P2 |
| Article content extraction | MEDIUM | MEDIUM | P2 |
| Source traceability metadata | LOW | LOW | P3 |

**Priority key:**
- P1: Must have for launch — pipeline does not work without it
- P2: Should have, add when P1 is stable
- P3: Nice to have, add opportunistically

---

## Sources

- [cychong47/goodlinks — SQLite access confirmed](https://github.com/cychong47/goodlinks) — DB path `$HOME/Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite`, fields confirmed from PRAGMA query in source code
- [tdhooten/goodlinks-exporter — JSON export field structure](https://github.com/tdhooten/goodlinks-exporter/blob/master/goodlinks-exporter.py) — confirms `url`, `addedAt`, `readAt`, `tags` fields in export
- [MacStories GoodLinks 2.0 review — Shortcuts depth](https://www.macstories.net/reviews/goodlinks-2-0-the-automation-focused-read-later-app-ive-always-wanted/) — confirms article content return in plain text/Markdown via Shortcuts, but fragile for headless use
- [GoodLinks URL scheme documentation](https://goodlinks.app/url-scheme/) — confirms no bulk query/export via URL scheme; only single-link operations
- [GoodLinks export format incompatibility note](https://micro.blog/jayeless/11534638) — user confirms JSON is the native export format (not CSV/OPML)

---

*Feature research for: GoodLinks ingestion pipeline (Model Citizen subsequent milestone)*
*Researched: 2026-02-19*
