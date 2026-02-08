# Roadmap: Athan Dial Portfolio Site

**Project:** Hugo Resume Theme Migration
**Core Value:** Demonstrate strategic credibility through the site itself
**Depth:** Quick (3-5 phases, critical path)
**Created:** 2026-02-04

## Overview

This roadmap delivers a working professional portfolio by migrating from Blowfish to Hugo Resume theme. The migration is treated as a content transformation project, not just a theme swap. Three phases progress from clean foundation to populated content to validated deployment.

## Phases

### Phase 1: Theme Foundation

**Goal:** Users can view a functional single-page resume with Hugo Resume theme

**Dependencies:** None (starting point)

**Requirements:**
- THEME-01: Hugo Resume theme installed, Blowfish removed
- THEME-02: Site configuration set (baseURL, title, author info)
- THEME-03: Hugo Modules cleaned (go.mod/go.sum updated, no ghost refs)

**Success Criteria:**
1. User visits localhost:1313 and sees Hugo Resume theme rendering (not Blowfish)
2. User inspects page source and confirms no Blowfish CSS or layout references
3. User runs `hugo mod graph` and sees only Hugo Resume module (no Blowfish traces)
4. User views site config and sees correct baseURL, title, and author metadata

**Plans:** 1 plan
Plans:
- [x] 01-01-PLAN.md — Install Hugo Resume, remove Blowfish, validate theme fit (Go/No-Go gate) ✓

**Research Flags:** None (standard Hugo module management)

---

### Phase 2: Content & Styling

**Goal:** Users can explore a complete professional profile with work history, skills, and custom branding

**Dependencies:** Phase 1 (requires theme installed to know data structure)

**Requirements:**
- CONT-01: Experience timeline populated (JSON data file with work history)
- CONT-02: Skills inventory populated (JSON data file with skill categories)
- CONT-03: Education section populated (JSON data file)
- CONT-04: About/bio section written (profile summary on homepage)
- CONT-05: Contact information and social links configured
- DESIGN-01: Minimal custom CSS applied (accent colors, minor overrides)
- THEME-05: Dark mode functional (custom CSS implementation)
- THEME-06: Accent color customized (replace orange sidebar with modern palette)

**Success Criteria:**
1. User views homepage and sees complete work history with company names, titles, dates, and descriptions
2. User scrolls to skills section and sees categorized technical skills (data science, product, tools)
3. User navigates to education section and sees PhD and prior degrees with institutions
4. User reads bio section and understands professional positioning (PhD → Product leader)
5. User clicks contact links and reaches LinkedIn, GitHub, and email successfully
6. User toggles to dark mode and sees theme switch without broken styles
7. User views site on mobile device and confirms responsive layout works

**Plans:** 3 plans
Plans:
- [x] 02-01-PLAN.md — Populate JSON data files (experience, skills, education) and bio content ✓
- [x] 02-02-PLAN.md — Implement custom CSS with executive blue palette and dark mode ✓
- [x] 02-03-PLAN.md — Human verification checkpoint for content and styling ✓

**Research Flags:** None (standard content transformation and CSS customization)

---

### Phase 3: Production Deployment

**Goal:** Users can access the live portfolio at the production URL with all features working

**Dependencies:** Phase 2 (requires complete content before production launch)

**Requirements:**
- THEME-04: GitHub Pages deployment verified (docs/ directory builds correctly)
- DESIGN-02: Mobile responsive validated (theme built-in, verify works)

**Success Criteria:**
1. User visits production URL and sees site load without 404 errors in DevTools
2. User inspects page source and confirms CSS and assets load from correct paths
3. User runs Lighthouse audit and sees performance score above 90
4. User shares portfolio link on LinkedIn and sees correct Open Graph preview card
5. User tests site on mobile device and confirms all sections responsive

**Plans:** 1 plan
Plans:
- [ ] 03-01-PLAN.md — Clean build, fix OG image, deploy and validate live site

**Research Flags:** None (standard deployment validation)

---

## Progress

| Phase | Status | Requirements | Progress |
|-------|--------|--------------|----------|
| 1 - Theme Foundation | ✓ Complete | THEME-01, THEME-02, THEME-03 | 100% |
| 2 - Content & Styling | ✓ Complete | CONT-01, CONT-02, CONT-03, CONT-04, CONT-05, DESIGN-01, THEME-05, THEME-06 | 100% |
| 3 - Production Deployment | Ready | THEME-04, DESIGN-02 | 0% |

**Overall:** 11/13 requirements complete (85%)

---

## Notes

**Critical Decision Point:** Phase 1 must validate that Hugo Resume's single-page layout supports "decision portfolio" positioning. If single-page feels constrained, reconsider theme choice before Phase 2.

**Deferred to v2:**
- Case studies migration (requires architectural fit validation)
- Full 1200-line CSS port (starting with minimal overrides)
- Blog/writing section
- Publications section
- Downloadable PDF resume

**Coverage:** All 13 v1 requirements mapped across 3 phases (100%)

---

## Current Milestone: Model Citizen (Content Engine)

**Project:** Automated Content Generation & Publishing to Quartz
**Core Value:** Capture knowledge continuously, publish consciously with explicit human approval
**Depth:** 5 phases (MVP to working system), designed for parallel execution
**Created:** 2026-02-05

### Overview

Model Citizen is a separate publishing system deployed to `athan-dial.github.io/model-citizen/`. It combines a **public Obsidian vault** (sources, ideas, drafts) with a **Quartz publishing site** (approved content only) and **n8n automation** (daily ingestion → enrichment → ideation → draft → publish gate). Claude Code handles AI-driven synthesis via SSH invocation from n8n workflows.

**Key Architecture:**
- Repo A (Model Citizen Vault): Public Obsidian vault with all raw material, thinking, sources
- Repo B (Quartz Site): Published articles only (subset of Vault)
- n8n (Local Docker): Daily workflow orchestration
- Claude Code (SSH agent): AI synthesis and drafting on-demand

---

### Phase 4: Quartz Site & Vault Schema (Parallel A)

**Goal:** Quartz project site is deployed to GitHub Pages and vault folder structure is documented

**Dependencies:** None (can start immediately, parallel with other work)

**Requirements:**
- MC-01: Quartz repo scaffolded with project site config (baseURL = `/model-citizen/`)
- MC-02: GitHub Pages deploy pipeline working (GitHub Actions or Pages build)
- MC-03: Vault folder taxonomy documented (inbox/, sources/, enriched/, ideas/, drafts/, publish_queue/)
- MC-04: Markdown schema documented (frontmatter spec, tags, metadata fields)

**Success Criteria:**
1. User can deploy empty Quartz site to `athan-dial.github.io/model-citizen/` and see it load
2. User can inspect Vault folder structure and find documented schema
3. User can create a sample note in `/sources/` following the schema
4. User confirms no broken links between Vault and Quartz site

**Plans:** 3 plans
Plans:
- [x] 04-01-PLAN.md — Scaffold Quartz repo and deploy to GitHub Pages ✓
- [x] 04-02-PLAN.md — Create vault repo with folder structure and schema documentation ✓
- [x] 04-03-PLAN.md — End-to-end verification with sample note ✓

**Research Flags:** None (standard Quartz setup + folder documentation)

---

### Phase 5: n8n YouTube Ingestion (Parallel B)

**Goal:** n8n workflow can download YouTube transcripts, normalize them, and store them in Vault

**Dependencies:** Phase 4 (Vault schema must exist to know where to write)

**Requirements:**
- MC-05: n8n Docker setup with YouTube integration (yt-dlp for download, transcript extraction)
- MC-06: Ingestion pipeline idempotent (no duplicate notes on re-runs)
- MC-07: Source notes normalized to Markdown with consistent frontmatter

**Success Criteria:**
1. User starts n8n Docker instance and runs YouTube ingestion workflow
2. User provides YouTube URL and workflow fetches transcript
3. User checks Vault `/sources/` folder and finds normalized Markdown file with frontmatter
4. User re-runs ingestion with same URL and confirms no duplicate is created

**Plans:** 2 plans
Plans:
- [x] 05-01-PLAN.md — Set up n8n Docker environment with yt-dlp and vault access ✓
- [x] 05-02-PLAN.md — SUPERSEDED: Host script handles ingestion (see 05-02-SUMMARY.md)

**Architectural Note:** n8n hardened image lacks Python; yt-dlp runs on host via brew. n8n orchestration deferred to v2.

**Research Flags:** n8n YouTube node availability, yt-dlp integration, idempotency patterns

---

### Phase 6: Claude Code Agent Integration (Parallel C)

**Goal:** n8n can invoke Claude Code via SSH to handle AI-driven synthesis (summaries, tagging, idea generation)

**Dependencies:** Phase 5 (needs ingested content to enrich)

**Requirements:**
- MC-08: n8n SSH integration working (can execute remote commands on your machine)
- MC-09: Claude Code wrapper CLI designed (accepts input, triggers workflow, captures output)
- MC-10: Agent invocation is idempotent (re-runs don't duplicate enrichment)

**Success Criteria:**
1. n8n workflow executes SSH command and invokes Claude Code on your machine
2. Claude Code reads input from Vault, executes synthesis task
3. Output (summary, tags, quotes) is written back to Vault
4. n8n continues orchestration after agent completes

**Plans:** 2 plans
Plans:
- [x] 06-01-PLAN.md — SSH infrastructure, wrapper script, and task schema ✓
- [x] 06-02-PLAN.md — End-to-end integration test with sample task ✓

**Research Flags:** n8n SSH node reliability, Claude Code remote invocation patterns, timeout handling

---

### Phase 7: Enrichment & Idea Generation (Sequential to Phase 6)

**Goal:** Full enrichment pipeline working: summaries, tags, idea cards, draft outlines

**Dependencies:** Phase 6 (requires Claude Code integration to execute)

**Requirements:**
- MC-11: Summary generation (Claude Code task: 2-3 sentence summary of source)
- MC-12: Tagging & metadata (Claude extracts topic tags, quotes, key takeaways)
- MC-13: Idea cards generated (blog angles, outlines, supporting sources identified)
- MC-14: Drafts scaffolded (Claude creates first outline/draft if requested)

**Success Criteria:**
1. User ingests YouTube video; n8n runs enrichment pipeline
2. User checks Vault `/enriched/` folder and sees summary, tags, and metadata
3. User checks `/ideas/` folder and sees 2-3 blog idea cards for the source
4. Optional: User checks `/drafts/` and sees draft outline with citations

**Plans:** 3 plans
Plans:
- [x] 07-01-PLAN.md — Prompt templates, enrichment scripts, frontmatter utility, and end-to-end test ✓
- [x] 07-02-PLAN.md — n8n orchestration workflow and integration test ✓
- [x] 07-03-PLAN.md — Gap closure: fix tagging extraction, idea card creation, and finalization bugs ✓
- [ ] 07-04-PLAN.md — Gap closure: fix daily enrichment log creation

**Research Flags:** Claude prompting patterns for synthesis, structured output formats, citation generation

---

### Phase 8: Human Review & Approval Dashboard (Sequential to Phase 7)

**Goal:** User has a clear workflow to review, approve, and publish content

**Dependencies:** Phase 7 (needs enriched content to review)

**Requirements:**
- MC-15: Approval workflow documented (move to `/publish_queue/` or set frontmatter `status: publish`)
- MC-16: Review screen (Vault-based, shows sources, drafts, approval state)
- MC-17: Publishing rules clear (only content in `/publish_queue/` or with `status: publish` exports)

**Success Criteria:**
1. User reviews a draft and related sources in Vault
2. User moves draft to `/publish_queue/` (or sets `status: publish`)
3. User understands that only approved content will sync to Quartz

**Plans:** 1 plan
Plans:
- [x] 08-01-PLAN.md — Draft template + review dashboard + approval workflow documentation ✓

**Research Flags:** Vault UI for approval workflows, frontmatter-based publishing rules

---

### Phase 9: Publish Sync & End-to-End Example (Final)

**Goal:** Approved content syncs to Quartz, deploys to GitHub Pages, and a complete example proves the system works

**Dependencies:** Phases 4-8 (requires all prior work to function)

**Requirements:**
- MC-18: Publish sync tool (copy approved notes from Vault → Quartz `content/`)
- MC-19: Asset handling (images, attachments copied and links rewritten if needed)
- MC-20: Quartz deploy triggered (GitHub Actions or manual push)
- MC-21: End-to-end example (YouTube → enriched → approved → published article visible)

**Success Criteria:**
1. User completes full workflow: YouTube → enrichment → approval → publish
2. User visits `athan-dial.github.io/model-citizen/` and sees published article
3. Published article links back to Vault sources
4. Daily n8n run completes without errors

**Plans:** 2 plans
Plans:
- [x] 09-01-PLAN.md — Publish sync script and frontmatter transformer ✓
- [x] 09-02-PLAN.md — End-to-end example and live site verification ✓

**Research Flags:** Quartz link rewriting, asset copying, deploy automation

---

### Phase Progress

| Phase | Status | Requirements | Progress |
|-------|--------|--------------|----------|
| 4 - Quartz & Vault Schema | ✓ Complete | MC-01, MC-02, MC-03, MC-04 | 100% |
| 5 - YouTube Ingestion | ✓ Complete | MC-05, MC-06, MC-07 | 100% |
| 6 - Claude Code Integration | ✓ Complete | MC-08, MC-09, MC-10 | 100% |
| 7 - Enrichment Pipeline | ✓ Complete | MC-11, MC-12, MC-13, MC-14 | 100% |
| 8 - Review & Approval | ✓ Complete | MC-15, MC-16, MC-17 | 100% |
| 9 - Publish Sync | ✓ Complete | MC-18, MC-19, MC-20, MC-21 | 100% |

**Overall:** 21/21 requirements complete (100%)

---

### Notes

**Parallelization:** Phases 4, 5 can start simultaneously. Phase 6 depends on Phase 5. Phases 7, 8, 9 are sequential to prior phases.

**n8n ↔ Claude Code Handoff:** SSH execution pattern selected (see Phase 6 CONTEXT.md). n8n creates task files in vault, executes wrapper script via SSH, Claude Code processes and writes output.

**Safety:** Explicit publish gate is non-negotiable. Daily runs should never auto-publish.

**Deferred to v2:**
- n8n orchestration for YouTube ingestion (webhook trigger, file watcher, or scheduled batch)
- Email/web link ingestion (Phases 10+)
- Podcast ingestion
- Automated backlinking
- Vault-native search/tagging UI
- Quartz preview before publish

---

*Roadmap created: 2026-02-04*
*Last updated: 2026-02-08*
