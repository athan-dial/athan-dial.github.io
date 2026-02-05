# Phase 9: Publish Sync & End-to-End Example - Context

**Gathered:** 2026-02-05
**Status:** Ready for planning

<domain>

## Phase Boundary

Implement the final pipeline: approved content from Vault exports to Quartz, assets are copied, links are rewritten if needed, and GitHub Pages deploys. Then demonstrate the entire system working end-to-end: YouTube video → ingested → enriched → idea generated → draft written → approved → published on Quartz.

Phase 9 is the **launch point** where the Model Citizen system becomes fully operational.

</domain>

<decisions>

## Implementation Decisions

### Publish Sync Pipeline

**Input:** Approved content in `/publish_queue/` or with `status: publish`

**Steps:**
1. Identify all approved notes (folder or frontmatter)
2. Copy to Quartz repo `content/` directory
3. Convert Vault frontmatter to Quartz frontmatter if needed (Hugo vs Quartz formats differ slightly)
4. Copy any referenced assets (images, attachments) to Quartz `static/` directory
5. Rewrite internal links (Vault wiki-style `[[note-id]]` → Quartz relative links)
6. Commit all changes to Quartz repo
7. Push to GitHub (or rely on Pages auto-build if monorepo)

**Idempotency:**
- Don't duplicate notes on re-runs
- Update existing notes if source changed
- Track published notes in `.model-citizen/published-list.txt` or similar

### Link Rewriting Rules

**Vault format:** `[[source-note-id]] → original source`
**Quartz format:** `[source-note-id](../../sources/source-note-id/) → relative path in Quartz`

Rules documented in Phase 9 planning.

### Asset Handling

- Copy images from `/media/` or inline assets
- Rewrite image paths in Markdown (Vault paths → Quartz paths)
- Handle external URLs (leave as-is)

### Quartz Deploy

**GitHub Actions OR manual push:**
- If pushing to separate Quartz repo: GitHub Pages auto-builds
- If monorepo: push to gh-pages branch triggers Hugo build
- Verify: site builds without errors, old published content remains

### End-to-End Example

**Demonstrate the full pipeline with one real example:**
1. Find a YouTube video of real interest (TBD during Phase 9)
2. Run Phase 5 ingestion
3. Run Phase 7 enrichment
4. Write or refine draft in Phase 8
5. Approve for publication
6. Run Phase 9 sync
7. Verify on live Quartz site

**Success:** Full workflow runs, published article appears on `athan-dial.github.io/model-citizen/`, and article links back to Vault sources.

### Error Handling

- Link rewriting failures: log and alert (don't publish broken links)
- Asset copying failures: log and continue (missing assets are recoverable)
- Quartz build failures: halt sync and notify user
- Network failures on push: retry or allow manual push

### Claude's Discretion

- Exact frontmatter conversion logic (Quartz may use different fields than Vault)
- Asset naming conventions in Quartz
- Whether to archive published notes in Vault or leave them in place
- How many retries on transient failures
- Logging verbosity and format

</decisions>

<specifics>

## Specific Ideas

- **One publish sync per approval cycle:** Run sync manually when you've approved content. Daily automatic sync is optional (Phase 10+).

- **Link transparency:** Keeping links to Vault sources in published posts is intentional. It shows where ideas come from and invites readers into your thinking process.

- **Quartz is the public face:** Everything published here should be substantive and represent your thinking. The Vault contains the raw material; Quartz contains the refined ideas.

</specifics>

<deferred>

## Deferred Ideas

- Scheduled daily publish sync (Phase 10)
- Automated deploy on successful sync
- Draft preview in Quartz before approving
- Vault archival strategy (delete published notes or archive to /published/)
- Revision history for published posts (Git handles this, but could expose via Quartz)
- Comments on published posts

</deferred>

---

*Phase: 09-publish-sync*
*Context gathered: 2026-02-05*
