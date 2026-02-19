# Project Research Summary

**Project:** v1.2 GoodLinks Ingestion Pipeline
**Domain:** Read-later app (GoodLinks) to Obsidian vault via automated bash/Python pipeline
**Researched:** 2026-02-19
**Confidence:** HIGH (stack/data access verified directly on this machine), MEDIUM (iCloud sync pitfalls based on community reports)

## Executive Summary

The v1.2 milestone adds GoodLinks as an automated content source to the Model Citizen enrichment pipeline. The core technical question — how to access GoodLinks data programmatically — has been definitively answered: GoodLinks stores all link metadata and extracted article text in a directly readable SQLite database at `~/Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite`. The schema was verified directly on this machine (92 active links, 87 with full article text in the `content` table). This means the integration requires zero new dependencies — only Python 3.12 stdlib (`sqlite3`, `datetime`, `json`) — and follows the identical structural pattern to the existing `ingest-youtube.sh` script.

The recommended implementation is a two-file addition: `ingest-goodlinks.sh` (bash orchestrator) and `goodlinks-query.py` (Python SQLite reader that emits Markdown source notes with proper YAML frontmatter). The new source plugs directly into the existing `enrich-source.sh` pipeline, writing output to `sources/goodlinks/` in the same schema as `sources/youtube/`. The MVP feature set — SQLite scanner, incremental scan via `addedAt` timestamp cursor, URL deduplication, GoodLinks tag inheritance, and launchd integration — is entirely P1, low complexity, and implementable without surprises.

The primary risks are pipeline integration pitfalls, not implementation complexity. iCloud sync lag (GoodLinks syncs items saved from iPhone with 0–20+ minute delays) can cause articles to be missed if the scanner uses a hard timestamp cursor without a lookback buffer. URL normalization is critical to avoid cross-source duplicates, since GoodLinks saves URLs with `utm_*` tracking parameters that produce different strings than the same article captured earlier via Slack or Outlook. Both risks have clear, inexpensive mitigations that must be designed in from day one.

Note on ARCHITECTURE.md: The architecture research file in this directory was produced for the prior Hugo Resume theme migration milestone (v1.0, now complete). It is not relevant to v1.2. The GoodLinks integration architecture follows the established pipeline pattern already in production.

## Key Findings

### Recommended Stack

See full details: `.planning/research/STACK.md`

The integration uses only tools already installed on this machine. No new installations are required. Python 3.12 at `/opt/homebrew/bin/python3.12` queries the SQLite database using the stdlib `sqlite3` module. The bash orchestrator follows the exact pattern of `ingest-youtube.sh`. The critical finding is that GoodLinks' `content` table already contains extracted plain text for ~94% of saved links — no HTML parsing or readability web fetch is needed for the existing library.

**Core technologies:**
- **Python 3.12 + sqlite3 stdlib**: Query GoodLinks SQLite DB — zero new dependencies, verified working on this machine
- **SQLite 3.51.0 (system)**: GoodLinks data store at stable Group Containers path — direct read is safe and fast
- **bash (system zsh-compat)**: Orchestration script — consistent with all other pipeline scripts; safe for launchd
- **GoodLinks `content` table**: Pre-extracted plain text — no HTML parser or readability fetch needed for existing articles

**What NOT to use:**
- Shortcuts CLI (`shortcuts run`) — requires GUI user session, fails silently in launchd context
- AppleScript / URL scheme — no bulk enumerate capability; single-link operations only
- CloudKit database (`~/Library/Containers/.../CloudKit/`) — BLOBs are NSKeyedArchiver format, unreadable
- Third-party Python packages — unnecessary; launchd PATH issues make installs fragile

### Expected Features

See full details: `.planning/research/FEATURES.md`

**Must have (table stakes — v1):**
- SQLite scanner script (`ingest-goodlinks.sh` + `goodlinks-query.py`) — pipeline does not exist without it
- Incremental scan with `addedAt` cursor + lookback buffer — prevents re-ingesting all 92 existing links on every run
- URL deduplication — same article may already be in vault from Slack/Outlook capture
- GoodLinks tag inheritance — user-applied GoodLinks tags flow into note frontmatter as initial tags
- launchd integration — runs as part of daily 7AM job alongside existing scanners

**Should have (v1.x — add after validation):**
- Read-status routing — separate handling for unread vs. already-read items
- Starred flag passthrough — `starred: true` in frontmatter for enrichment prioritization
- Content fetch fallback — for the ~6% of links without a `content` table row (pending fetch)

**Defer (v2+):**
- `goodlinks_id` round-trip metadata — useful for debugging but no current pipeline dependency
- Highlights integration — `highlight` table contains user-annotated excerpts; niche enhancement

**Anti-features to avoid:**
- Bi-directional sync — writing back to GoodLinks SQLite risks corrupting app state on iCloud sync
- Full re-scan on every run — creates duplicates, defeats deduplication, floods enrichment queue
- Tag removal as "processed" signal — GoodLinks silently deletes tags with zero links; pipeline breaks on success

### Architecture Approach

The integration follows the established Model Citizen pipeline pattern exactly. GoodLinks is a new source that feeds the existing enrichment flow identically to YouTube and web captures. A Python script queries the SQLite DB and writes Markdown files to `sources/goodlinks/`. The existing `enrich-source.sh` picks these up without modification.

**Major components:**

1. **`goodlinks-query.py`** — queries `link JOIN content` tables, emits Markdown source notes with YAML frontmatter; handles tag parsing (comma-separated string → YAML list), timestamp conversion (Unix float → ISO-8601), and content availability (~6% of links have no `content` row)

2. **`ingest-goodlinks.sh`** — bash orchestrator; loads/writes state file at `~/.model-citizen/seen-goodlinks-ids.json`; calls Python script with `--since` timestamp and lookback buffer; passes output dir to existing `enrich-source.sh`

3. **State file** at `~/.model-citizen/seen-goodlinks-ids.json` — stores max `addedAt` seen on last successful run; same directory pattern as other pipeline state files

4. **launchd plist update** — adds `ingest-goodlinks.sh` call to existing daily 7AM orchestrator script

### Critical Pitfalls

See full details: `.planning/research/PITFALLS.md`

1. **iCloud sync lag loses items saved from phone** — Use a lookback buffer (2–3× scan interval) on the `addedAt` cursor; rely on hash-based idempotency to prevent duplicates from the overlap window. Never use a hard cursor without a buffer. Warning sign: items saved on iPhone appear hours later or never.

2. **URL normalization misses cross-source duplicates** — GoodLinks saves URLs with `utm_*` tracking parameters appended by iOS share sheets. The same article captured earlier via Slack/Outlook has a clean URL. Different strings → different hashes → duplicate vault note. Strip tracking params before computing deduplication hash; store raw URL separately for provenance.

3. **Tags disappear when queue is drained** — GoodLinks silently deletes any tag with zero associated links. Tag-based scan queues break on success (the moment all queued items are processed). Use date-window scanning with hash dedup instead of tag-based queues. If tags are used, keep a permanent dummy link to hold the tag open.

4. **Shortcuts CLI fails silently in headless launchd context** — `shortcuts run` requires a logged-in GUI session. The recommended SQLite direct-read approach avoids this entirely. If Shortcuts is ever introduced, use a user launchd agent (`~/Library/LaunchAgents/`) with `SessionCreate = true`.

5. **First run floods enrichment queue with historical links** — Initializing `since_timestamp = 0` on first run ingests all 92 existing links at once. Set initial `since` to `now - 30 days` and accept that older history catches up incrementally, or selectively backfill.

## Implications for Roadmap

The implementation is well-scoped and can be delivered in two focused phases, with a third optional phase for enrichment quality improvements.

### Phase 1: Core Scanner

**Rationale:** The load-bearing component — everything else depends on this working correctly. SQLite access is verified, schema is fully known, and the Python pattern is completely specified in STACK.md with working code samples. No unknowns remain.

**Delivers:** Working `goodlinks-query.py` + `ingest-goodlinks.sh` that reads SQLite, applies active-item filters (`status = 0`, `deletedAt IS NULL`, `addedAt > since - buffer`), and emits Markdown source notes with correct YAML frontmatter matching vault schema. Run manually, produces notes in `sources/goodlinks/`.

**Addresses features:** SQLite scanner script, incremental scan, tag inheritance, GoodLinks-sourced deduplication (checking seen-IDs state file)

**Avoids pitfalls:** iCloud sync lag (implement lookback buffer from day one — baked in, not a hotfix); first-run queue flood (initialize state file with `now - 30 days`); tags-disappear failure (use date-window scanning, not tag queues)

**Research flag:** None. Implementation is fully specified in STACK.md with working code. Confidence is HIGH based on ground-truth DB inspection.

### Phase 2: Pipeline Integration and Cross-Source Deduplication

**Rationale:** Wire the working scanner into daily automation and add the shared infrastructure fix (URL normalization) that prevents cross-source duplicates from accumulating. URL normalization must be added before GoodLinks creates duplicates of existing vault notes — not retroactively.

**Delivers:** launchd integration (GoodLinks runs as part of 7AM daily job); state file management across runs; cross-source URL normalization utility (strip `utm_*` and other tracking params before hashing); end-to-end validation (save link on phone, confirm it appears in vault within 2 scan cycles)

**Avoids pitfalls:** Scheduled execution failure (test launchd execution path explicitly, not just terminal); cross-source duplicate accumulation (normalization in place before GoodLinks launches)

**Research flag:** Before writing normalization logic, sample 10–15 actual GoodLinks URLs from the live DB and inspect for `utm_*` and other tracking param patterns. Five minutes of inspection prevents over-engineering or under-engineering the normalization list.

### Phase 3: Enrichment Quality (v1.x)

**Rationale:** After the pipeline is proven working in production, add signal-boosting features that improve enrichment quality without changing pipeline structure.

**Delivers:** Read-status routing (unread items vs. already-read items treated differently); starred flag passthrough (`starred: true` in frontmatter); content fetch fallback for the ~6% of links with no `content` table row

**Research flag:** None. These are low-complexity field additions and filter variants on an already-working pipeline.

### Phase Ordering Rationale

- Scanner must come first: it is the prerequisite for all other work.
- Pipeline integration is Phase 2 (not merged into Phase 1) because a broken scanner wired into daily automation is harder to debug than a broken scanner run manually. Establish correctness before automation.
- URL normalization belongs in Phase 2 (shared infrastructure) rather than Phase 1 (source-specific), because the fix applies to all sources and should be tested against existing vault content before GoodLinks adds new notes.
- v1.x enrichment features are Phase 3 because they add no pipeline functionality — they improve enrichment quality and require the pipeline to be proven stable first.

### Research Flags

Phases needing additional investigation during implementation:
- **Phase 2 (URL normalization):** Sample real GoodLinks URLs from live DB to identify which tracking params appear in practice before writing the normalization list. Five-minute task, high return.

Phases with standard, well-documented patterns (no additional research needed):
- **Phase 1 (Core scanner):** Implementation fully specified in STACK.md with working code samples. DB schema verified directly on this machine.
- **Phase 3 (Enrichment features):** Simple frontmatter field additions and filter variants. No new architecture decisions.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | SQLite schema verified by direct inspection of live GoodLinks DB on this machine; Python stdlib approach confirmed by multiple open-source tooling examples; zero new dependencies required |
| Features | HIGH | GoodLinks data access methods fully confirmed; feature set is a direct subset of established pipeline patterns already in production |
| Architecture | HIGH | Existing pipeline architecture is known and working; GoodLinks follows identical source pattern as YouTube and web captures |
| Pitfalls | MEDIUM | iCloud sync timing based on community reports and Apple forum discussions, not official SLA documentation; tag-deletion pitfall is HIGH confidence (multiple independent sources document it); Shortcuts headless failure is HIGH confidence (macOS architecture constraint) |

**Overall confidence:** HIGH — implementation path is clear with no significant unknowns remaining.

### Gaps to Address

- **URL tracking params in practice:** Sample 10–15 actual GoodLinks-saved URLs from the live DB before writing normalization logic. Confirmed that iOS share sheets commonly append tracking params, but prevalence in this vault's specific content is unverified.

- **Content availability handling for ~6% of links:** The `content` table has no row for 5 of 92 links (pending GoodLinks fetch). Decision needed before implementation: write a stub note (URL + title only) or skip until content becomes available. The existing readability fallback in the pipeline can be invoked for these URLs. Recommendation: write stub note with `content_status: pending` in frontmatter; skip enrichment until content arrives.

- **First-run timestamp initialization:** Decide initial `since_timestamp` before running for the first time. Recommendation: `now - 30 days` to capture recently saved articles without flooding the enrichment queue with all 92 historical links at once.

## Sources

### Primary (HIGH confidence — direct verification on this machine)

- Direct filesystem inspection of `~/Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite` — schema, row counts, content availability, tag values verified on this machine (GoodLinks v3.1.1)
- Model Citizen vault `SCHEMA.md` — frontmatter requirements for source notes
- `scripts/ingest-youtube.sh` — integration pattern and bash orchestrator structure to follow

### Secondary (MEDIUM confidence — community corroboration)

- [cychong47/goodlinks](https://github.com/cychong47/goodlinks) — independently confirms DB path and schema field names via PRAGMA query
- [vascobrown GoodLinks JSON export gist](https://gist.github.com/vascobrown/479bb47d3f0138a3f595143d93afa658) — confirms export fields match DB schema
- [MacStories GoodLinks 1.7 review](https://www.macstories.net/reviews/goodlinks-1-7-new-ios-16-shortcuts-actions-focus-filter-support-lock-screen-widgets-and-more/) — Shortcuts action field inventory; confirms richer metadata via Shortcuts vs. JSON export
- [Devon Dundee — GoodLinks automation](https://devondundee.com/blog/automation-april-creating-show-notes-from-goodlinks) — tag deletion pitfall documented with resolution
- [iCloud Drive sync delay community reports](https://discussions.apple.com/thread/255573626) — timing basis for lookback buffer recommendation
- [CoreData + CloudKit sync throttling — Apple Developer Forums](https://developer.apple.com/forums/thread/682861) — technical basis for iCloud sync lag pitfall

### Tertiary (LOW confidence — informational context)

- [GoodLinks URL scheme documentation](https://goodlinks.app/url-scheme/) — confirmed no bulk enumerate capability; only single-link operations
- [GoodLinks iCloud Sync help page](https://goodlinks.app/help/icloud-sync/) — official acknowledgment of sync timing variability

---
*Research completed: 2026-02-19*
*Ready for roadmap: yes*
