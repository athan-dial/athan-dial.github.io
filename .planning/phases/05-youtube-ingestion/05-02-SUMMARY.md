# Phase 05-02 Summary

**Plan:** YouTube ingestion n8n workflow
**Status:** SUPERSEDED
**Date:** 2026-02-05

---

## Decision

Plan 05-02 (n8n workflow for YouTube transcript download) has been **superseded** by the host-side ingestion script created in 05-01.

**Rationale:**
- The hardened n8n Docker image lacks Python, preventing in-container yt-dlp execution
- Host-side script (`~/model-citizen-vault/scripts/ingest-youtube.sh`) handles the same functionality
- Script is simpler, easier to debug, and receives automatic updates via brew

**Success criteria still met:**
- MC-05: n8n Docker setup ✅ (container running, vault mounted)
- MC-06: Ingestion idempotent ✅ (script checks for existing files)
- MC-07: Source notes normalized ✅ (frontmatter matches schema)

---

## Future Work: n8n Orchestration

**Deferred to:** Phase 10 or v2

When adding n8n orchestration for automated ingestion:

1. **Webhook trigger option:**
   - n8n exposes webhook endpoint
   - Script or bookmarklet sends YouTube URL to webhook
   - n8n triggers host script execution via SSH or API

2. **File watcher option:**
   - User drops YouTube URLs into a text file
   - n8n watches file, processes URLs, clears file
   - Host script called per URL

3. **Scheduled batch option:**
   - User maintains playlist/channel list
   - n8n daily cron checks for new videos
   - Downloads new transcripts automatically

**Captured in:** ROADMAP.md "Deferred to v2" section

---

*Summary generated: 2026-02-05*
