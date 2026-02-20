# Roadmap: Athan Dial Portfolio Site

**Created:** 2026-02-04

## Milestones

- ✅ **v1.0 Hugo Resume** — Phases 1-3 (shipped 2026-02-09)
- ✅ **v1.1 Model Citizen** — Phases 4-11 (shipped 2026-02-14)
- 🚧 **v1.2 GoodLinks Ingestion** — Phases 12-13 (in progress)

## Phases

<details>
<summary>✅ v1.0 Hugo Resume (Phases 1-3) — SHIPPED 2026-02-09</summary>

- [x] Phase 1: Theme Foundation (1/1 plans) — Hugo Resume installed, Blowfish removed
- [x] Phase 2: Content & Styling (3/3 plans) — Professional profile, executive blue, dark mode
- [x] Phase 3: Production Deployment (1/1 plans) — GitHub Pages live with OG image

</details>

<details>
<summary>✅ v1.1 Model Citizen (Phases 4-11) — SHIPPED 2026-02-14</summary>

- [x] Phase 4: Quartz & Vault Schema (3/3 plans) — Quartz deployed, vault folder structure documented
- [x] Phase 5: YouTube Ingestion (2/2 plans) — yt-dlp transcript pipeline
- [x] Phase 6: Claude Code Integration (2/2 plans) — SSH agent wrapper with idempotency
- [x] Phase 7: Enrichment Pipeline (4/4 plans) — Summaries, tags, idea cards, drafts
- [x] Phase 8: Review & Approval (1/1 plans) — Obsidian dashboard, dual approval workflow
- [x] Phase 9: Publish Sync (2/2 plans) — Hash-based sync, frontmatter transform
- [x] Phase 10: Content Ingestion (3/3 plans) — Web capture, Slack/Outlook scanners, daily automation
- [x] Phase 11: Model Citizen UI/UX (3/3 plans) — Executive blue theme, reader typography, Explorer filtering

</details>

### 🚧 v1.2 GoodLinks Ingestion (In Progress)

**Milestone Goal:** Add GoodLinks as an automated content source feeding the Model Citizen enrichment pipeline, turning saved articles into vault notes.

- [x] **Phase 12: GoodLinks Scanner** — SQLite reader, incremental scan, vault note creation with tags and content (completed 2026-02-19)
- [ ] **Phase 13: Pipeline Integration** — Wire into daily automation, URL normalization, end-to-end validation

## Phase Details

### Phase 12: GoodLinks Scanner
**Goal**: A working scanner that reads GoodLinks SQLite, applies incremental filtering, and creates correctly-formed vault notes — runnable manually before any automation
**Depends on**: Nothing (first phase of v1.2)
**Requirements**: DATA-01, DATA-02, DATA-03, INGS-01, INGS-02, INGS-03, INGS-04
**Success Criteria** (what must be TRUE):
  1. Running `ingest-goodlinks.sh` manually creates Markdown vault notes in `sources/goodlinks/` for recently saved GoodLinks items
  2. Each generated note has correct YAML frontmatter (title, url, source, date, tags, status) drawn from GoodLinks data
  3. GoodLinks user-applied tags appear in the note's frontmatter tag list
  4. Re-running the scanner does not create duplicate notes for already-seen items (state file tracks last-seen timestamp)
  5. Items saved on iPhone that appear in the DB after a delay are captured on the next scan run (lookback buffer prevents misses)
**Plans**: 1 plan

Plans:
- [ ] 12-01-PLAN.md — GoodLinks SQLite scanner + vault note emission

### Phase 13: Pipeline Integration
**Goal**: GoodLinks scanner runs automatically as part of daily 7AM job, notes flow through enrichment, and cross-source duplicates are prevented via URL normalization
**Depends on**: Phase 12
**Requirements**: INTG-01, INTG-02, INTG-03
**Success Criteria** (what must be TRUE):
  1. Saving an article in GoodLinks results in an enriched vault note (summary, tags, ideas) appearing in Obsidian within one daily scan cycle without manual intervention
  2. An article already captured via Slack or Outlook does not produce a duplicate vault note when later saved in GoodLinks (URL normalization strips tracking params before deduplication hash)
  3. GoodLinks notes that pass the approval gate publish to Model Citizen via the existing publish sync workflow
**Plans**: 2 plans

Plans:
- [ ] 13-01-PLAN.md — URL normalization utility, dedup checker, retroactive migration
- [ ] 13-02-PLAN.md — scan-all.sh integration, enrichment wiring, failure notifications

## Progress

| Phase | Milestone | Plans | Status | Completed |
|-------|-----------|-------|--------|-----------|
| 1. Theme Foundation | v1.0 | 1/1 | Complete | 2026-02-05 |
| 2. Content & Styling | v1.0 | 3/3 | Complete | 2026-02-05 |
| 3. Production Deployment | v1.0 | 1/1 | Complete | 2026-02-09 |
| 4. Quartz & Vault Schema | v1.1 | 3/3 | Complete | 2026-02-05 |
| 5. YouTube Ingestion | v1.1 | 2/2 | Complete | 2026-02-05 |
| 6. Claude Code Integration | v1.1 | 2/2 | Complete | 2026-02-06 |
| 7. Enrichment Pipeline | v1.1 | 4/4 | Complete | 2026-02-06 |
| 8. Review & Approval | v1.1 | 1/1 | Complete | 2026-02-06 |
| 9. Publish Sync | v1.1 | 2/2 | Complete | 2026-02-08 |
| 10. Content Ingestion | v1.1 | 3/3 | Complete | 2026-02-13 |
| 11. Model Citizen UI/UX | v1.1 | 3/3 | Complete | 2026-02-14 |
| 12. GoodLinks Scanner | 1/1 | Complete    | 2026-02-19 | - |
| 13. Pipeline Integration | v1.2 | 0/2 | Planning complete | - |

---

*Roadmap created: 2026-02-04*
*Last updated: 2026-02-19 (v1.2 roadmap added)*
