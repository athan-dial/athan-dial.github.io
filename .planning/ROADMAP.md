# Roadmap: Athan Dial Portfolio Site

**Created:** 2026-02-04

## Milestones

- ✅ **v1.0 Hugo Resume** — Phases 1-3 (shipped 2026-02-09)
- ✅ **v1.1 Model Citizen** — Phases 4-11 (shipped 2026-02-14)
- ✅ **v1.2 GoodLinks Ingestion** — Phases 12-13 (shipped 2026-02-20)
- ◆ **v1.3 Content Intelligence Pipeline** — Phases 14-17 (active)

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

<details>
<summary>✅ v1.2 GoodLinks Ingestion (Phases 12-13) — SHIPPED 2026-02-20</summary>

- [x] Phase 12: GoodLinks Scanner (1/1 plans) — SQLite reader, incremental scan, vault note creation with tags and content
- [x] Phase 13: Pipeline Integration (2/2 plans) — URL normalization, scan-all.sh integration, enrichment wiring, failure notifications

</details>

**v1.3 Content Intelligence Pipeline:**

- [x] **Phase 14: Vault Schema** — Extended frontmatter contract and new vault folders for intelligence tier (completed 2026-02-23)
- [x] **Phase 15: Intelligence Skills** — All skills built in parallel: Slack scanner, Outlook scanner, atomic splitting, theme matching, synthesis (fully parallelizable) (completed 2026-03-01)
- [ ] **Phase 16: E2E Wiring + Verification** — Wire all skills into daily automation, lockfile, content strategist mode, end-to-end smoke test

## Phase Details

### Phase 14: Vault Schema
**Goal**: The vault has a committed schema contract that every component in the intelligence tier reads and respects
**Depends on**: Nothing (first phase of v1.3)
**Requirements**: SCAN-05, ATOM-02, ATOM-03, SYNTH-04
**Success Criteria** (what must be TRUE):
  1. `vault/SCHEMA.md` exists with documented frontmatter fields for source notes, atomic notes, and draft notes (including `type`, `atom_of`, `publishability`, `provenance.*`)
  2. `vault/atoms/` and `vault/themes/` folders exist and Obsidian Auto Note Mover routes notes typed `atom` correctly
  3. A manually created test atom note contains all required provenance fields and routes to the correct folder
  4. The `publishability` field (public/private) is defined with clear default rules for Slack-sourced content
**Plans**: 1 plan
Plans:
- [ ] 14-01-PLAN.md — Schema contract, vault folders, ANM routing, test atom note

### Phase 15: Intelligence Skills
**Goal**: All intelligence tier skills exist as tested, standalone Claude Code skills — scanners produce content-rich source notes, splitting produces atomic notes, matching connects themes, synthesis produces draft posts
**Depends on**: Phase 14 (vault schema)
**Requirements**: SCAN-01, SCAN-02, SCAN-03, SCAN-04, ATOM-01, ATOM-04, THEME-01, THEME-02, THEME-03, SYNTH-01, SYNTH-02, SYNTH-03
**Parallelization**: All plans run in a single parallel wave — no inter-skill dependencies during development
**Success Criteria** (what must be TRUE):
  1. Slack scanner skill creates vault source notes with full message text, sender, channel, thread context (not just URLs)
  2. Outlook scanner skill creates vault source notes with full email subject and body (not just URLs)
  3. Running either scanner a second time without new content creates no new notes (incremental state)
  4. Atomic splitting skill decomposes a source note into single-concept atoms in `vault/atoms/` with why-it-matters context preserved
  5. Theme matching skill adds at most 3 wikilinks per atom with written justification for each connection
  6. Synthesis skill produces a draft blog post in `vault/drafts/` with inline citations to source atom IDs
**Plans**: 5 plans
Plans:
- [ ] 15-01-PLAN.md — Slack intelligence scanner (MCP debugging + command + shell wrapper)
- [ ] 15-02-PLAN.md — Outlook intelligence scanner (Graph API full body + command + shell wrapper)
- [ ] 15-03-PLAN.md — Atomic splitting skill (split-source command)
- [ ] 15-04-PLAN.md — Theme matching skill (match-themes command)
- [ ] 15-05-PLAN.md — Synthesis skill (synthesize-draft command with voice TODO flag)

### Phase 16: E2E Wiring + Verification
**Goal**: All skills are wired into daily automation and verified end-to-end — real content flows from sources through splitting → matching → synthesis in a single unattended run
**Depends on**: Phase 15 (all skills exist and individually tested)
**Requirements**: ORCH-01, ORCH-02, ORCH-03, ORCH-04
**Success Criteria** (what must be TRUE):
  1. Running `scan-all.sh` triggers the full intelligence pipeline (scan → split → match → synthesis) automatically after existing scanners
  2. A `pipeline.lock` file prevents a scheduled scan from writing to the vault while an interactive content strategist session is active
  3. Content strategist slash command surfaces a cluster proposal and requests direction before generating any draft
  4. End-to-end smoke test: real Slack/Outlook content enters pipeline and a draft appears in `vault/drafts/` within one `scan-all.sh` run — no manual steps
**Plans**: TBD

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
| 12. GoodLinks Scanner | v1.2 | 1/1 | Complete | 2026-02-19 |
| 13. Pipeline Integration | v1.2 | 2/2 | Complete | 2026-02-20 |
| 14. Vault Schema | v1.3 | 1/1 | Complete | 2026-02-23 |
| 15. Intelligence Skills | 5/5 | Complete   | 2026-03-01 | — |
| 16. E2E Wiring + Verification | v1.3 | 0/? | Not started | — |

---

*Roadmap created: 2026-02-04*
*Last updated: 2026-03-01 (phase 15 plans defined — 5 plans, wave 1 parallel)*
