# Phase 5: YouTube Ingestion - Context

**Gathered:** 2026-02-05
**Status:** Ready for planning

<domain>

## Phase Boundary

Build the first n8n ingestion pipeline: download YouTube videos, extract transcripts, normalize to Markdown with proper frontmatter, and store in Vault `/sources/` folder. The workflow must be **idempotent** (running twice with same URL produces one note, not two).

This phase focuses on **YouTube only**. Other sources (email, web links) are separate phases.

</domain>

<decisions>

## Implementation Decisions

### n8n Setup
- Local Docker instance running on your machine
- Can trigger daily via cron or manually
- No cloud dependencies (local-first for privacy)

### YouTube Ingestion Flow
- Accept YouTube URL as input
- Use **yt-dlp** to download video and extract transcript
- Handle edge cases: no transcript available, private videos, deleted videos
- Normalize to Markdown with frontmatter (see Phase 4 schema)

### Idempotency
- Check if source already exists in vault (by URL)
- If exists, skip re-processing (don't create duplicate)
- Allow force-refresh flag if user wants to re-process
- Log all processed URLs to prevent duplicates

### Output Format
- Save to `/sources/youtube/{video-id}-{title-slug}.md`
- Frontmatter includes: title, source_url, date captured, transcript, status: "enriched" (ready for next phase)
- Body contains full transcript
- Tags pre-populated from YouTube description/keywords if available

### Error Handling
- Graceful failures: log error, continue to next item
- Don't crash workflow on single bad URL
- Notify user of failures in workflow summary note

### Claude's Discretion
- Transcript preprocessing (removing timestamps, cleaning up artifacts)
- Naming convention for generated files
- How to handle playlist URLs (single video vs batch processing)
- Transcript language handling (auto-detect vs user-specified)

</decisions>

<specifics>

## Specific Ideas

- **Transcript quality matters:** yt-dlp's transcript extraction is good but imperfect. You may want to manually clean up important videos. That's fine — Phase 5 just gets you started.

- **No AI processing yet:** Phase 5 is just capture and normalization. Summaries, tagging, and idea generation happen in Phase 6+ (Claude Code integration).

- **Workflow logging:** Include a "what happened today" summary: X videos ingested, Y already existed, Z failures.

</specifics>

<deferred>

## Deferred Ideas

- Batch YouTube playlist processing — could be added later
- YouTube channel subscription automation (continuous monitoring for new uploads)
- Transcript sentiment analysis or key speaker detection — analytical layer, separate phase
- Multi-language support — v2

</deferred>

---

*Phase: 05-youtube-ingestion*
*Context gathered: 2026-02-05*
