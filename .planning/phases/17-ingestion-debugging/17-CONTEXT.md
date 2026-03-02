# Phase 17: Ingestion Debugging - Context

**Gathered:** 2026-03-02
**Status:** Ready for planning

<domain>
## Phase Boundary

Debug and fix ingestion failures for Slack, GoodLinks, and YouTube so each produces real content-rich vault source notes. This phase is diagnostic + repair work only — no new sources, no schema changes, no enrichment. Success = vault has real notes with actual content, not empty stubs, and incremental state prevents re-creation on second run.

</domain>

<decisions>
## Implementation Decisions

### Debugging approach
- Tackle all three sources as separate, parallelizable debugging tasks (independent failure modes)
- Each source gets its own plan: diagnose → fix → verify with real data
- Slack first priority (most infrastructure already in place — MCP command + shell wrapper)

### Definition of "real note" (minimum valid source note)
- Must have non-empty `content:` field with actual article/message body text (not placeholder, not URL-only)
- Must have correct `type: source` frontmatter
- Must have populated `source_url:` or equivalent provenance field
- Slack notes: must include full message text + sender + channel (not just the URL that was shared)
- GoodLinks notes: must include extracted article body text from the linked URL
- YouTube notes: must include transcript content (even partial) — not empty

### GoodLinks content extraction
- The gap is that notes have empty `content:` fields — article body is not being extracted
- Fix: run `extract-article.mjs` against each GoodLinks URL when writing the source note
- Fallback when extraction fails (paywall, JS-only): write note with URL + title + excerpt from meta tags, mark `content_quality: extraction-failed` in frontmatter
- No note should be silently empty — extraction failure must be visible in the note itself

### YouTube silent failures
- Silent failures = process exits 0 but no vault note created, or note is written with empty transcript
- Fix requires: visible error logging when transcript fetch fails, and a non-zero exit code or explicit FAILED status in note frontmatter
- YouTube note is only "valid" if it has at least a partial transcript (>100 chars) — empty transcript = write note anyway but mark `transcript_status: failed`
- Need to test with a real video ID during the debugging phase to surface actual failure mode

### Incremental state verification
- "Zero new notes on second run" must be tested with real data (not synthetic)
- Slack: second run within same day against same channels should produce 0 new notes
- GoodLinks: running against same export twice should produce 0 new notes
- YouTube: same video ID twice should produce 0 new notes
- State files must be inspected directly to confirm deduplication is working

### Claude's Discretion
- Specific logging format for failures (stdout, frontmatter field, or separate log file)
- Whether to add a `--dry-run` flag for diagnosis vs fix phases
- Error message wording for human-readable failure states

</decisions>

<specifics>
## Specific Ideas

- Phase goal calls out "no stubs, no silent failures" — the fix for silence is always: write something (even an error-state note) rather than nothing
- GoodLinks `capture-web.sh` + `extract-article.mjs` already exist — the question is whether they're being called during ingestion or bypassed
- YouTube was wired in Phase 5 — may need to look at what transcript API/method was used and whether it still works

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `model-citizen/scripts/capture-web.sh`: Web article capture with Readability extraction — potentially already does what GoodLinks needs
- `model-citizen/scripts/extract-article.mjs`: Node.js Readability extractor — outputs title, byline, excerpt, markdown content
- `.claude/commands/scan-slack-intelligence.md`: Full Slack scanner command using MCP tools — likely the primary thing to debug for Slack
- `model-citizen/scripts/scan-slack-intelligence.sh`: Shell wrapper that invokes `claude --command scan-slack-intelligence`
- `~/.model-citizen/slack-intelligence-state.json`: Slack state file tracking `last_scan_ts` and `seen_ids`

### Established Patterns
- State management: JSON files in `~/.model-citizen/` track what's been processed (seen by Slack scanner)
- Claude Code command pattern: Skills in `.claude/commands/*.md` invoked via `claude --command`
- Vault path: `/Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/sources/`
- Frontmatter conventions: `type: source`, provenance fields, `content_quality` — defined in Phase 14 SCHEMA

### Integration Points
- `scan-all.sh` section 5 orchestrates the intelligence pipeline — changes to individual scanners need to work when called from here
- YouTube ingestion (Phase 5) likely has its own state file and vault path — needs investigation
- GoodLinks ingestion path unknown — may be `scan.md` command or a separate script

</code_context>

<deferred>
## Deferred Ideas

- None — discussion stayed within phase scope

</deferred>

---

*Phase: 17-ingestion-debugging*
*Context gathered: 2026-03-02*
