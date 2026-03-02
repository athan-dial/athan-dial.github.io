# Roadmap: Athan Dial Portfolio Site

**Created:** 2026-02-04

## Milestones

- ✅ **v1.0 Hugo Resume** — Phases 1-3 (shipped 2026-02-09)
- ✅ **v1.1 Model Citizen** — Phases 4-11 (shipped 2026-02-14)
- ✅ **v1.2 GoodLinks Ingestion** — Phases 12-13 (shipped 2026-02-20)
- ✅ **v1.3 Content Intelligence Pipeline** — Phases 14-16 (shipped 2026-03-01)
- ◆ **v1.4 Vault Seeding & Pipeline Validation** — Phases 17-19 (active)

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

<details>
<summary>✅ v1.3 Content Intelligence Pipeline (Phases 14-16) — SHIPPED 2026-03-01</summary>

- [x] **Phase 14: Vault Schema** — Extended frontmatter contract and new vault folders for intelligence tier (completed 2026-02-23)
- [x] **Phase 15: Intelligence Skills** — All skills built in parallel: Slack scanner, Outlook scanner, atomic splitting, theme matching, synthesis (fully parallelizable) (completed 2026-03-01)
- [x] **Phase 16: E2E Wiring + Verification** — Wire all skills into daily automation, lockfile, content strategist mode, end-to-end smoke test (completed 2026-03-01)

</details>

**v1.4 Vault Seeding & Pipeline Validation:**

- [ ] **Phase 17: Ingestion Debugging** — Get Slack, GoodLinks, and YouTube actually producing real content-rich notes (not stubs or empty files)
- [ ] **Phase 18: Enrichment Validation** — Run atoms and theme matching on real notes, fix quality gaps end-to-end
- [ ] **Phase 19: Drafting & Strategist** — Generate first real draft blog post, validate `/content-strategist` end-to-end session

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
- [x] 14-01-PLAN.md — Schema contract, vault folders, ANM routing, test atom note

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
- [x] 15-01-PLAN.md — Slack intelligence scanner (MCP debugging + command + shell wrapper)
- [x] 15-02-PLAN.md — Outlook intelligence scanner (Graph API full body + command + shell wrapper)
- [x] 15-03-PLAN.md — Atomic splitting skill (split-source command)
- [x] 15-04-PLAN.md — Theme matching skill (match-themes command)
- [x] 15-05-PLAN.md — Synthesis skill (synthesize-draft command with voice TODO flag)

### Phase 16: E2E Wiring + Verification
**Goal**: All skills are wired into daily automation and verified end-to-end — real content flows from sources through splitting → matching → synthesis in a single unattended run
**Depends on**: Phase 15 (all skills exist and individually tested)
**Requirements**: ORCH-01, ORCH-02, ORCH-03, ORCH-04
**Success Criteria** (what must be TRUE):
  1. Running `scan-all.sh` triggers the full intelligence pipeline (scan → split → match → synthesis) automatically after existing scanners
  2. A `pipeline.lock` file prevents a scheduled scan from writing to the vault while an interactive content strategist session is active
  3. Content strategist slash command surfaces a cluster proposal and requests direction before generating any draft
  4. End-to-end smoke test: real Slack/Outlook content enters pipeline and a draft appears in `vault/drafts/` within one `scan-all.sh` run — no manual steps
**Plans**: 3 plans
Plans:
- [x] 16-01-PLAN.md — scan-all.sh intelligence wiring and lockfile
- [x] 16-02-PLAN.md — content-strategist Claude Code command
- [x] 16-03-PLAN.md — E2E smoke test verification

### Phase 17: Ingestion Debugging
**Goal**: Real content-rich source notes flow from Slack, GoodLinks, and YouTube into the vault — no stubs, no silent failures, incremental state verified with real data
**Depends on**: Phase 16 (all pipeline code exists)
**Requirements**: INGEST-01, INGEST-02, INGEST-03, INGEST-04
**Success Criteria** (what must be TRUE):
  1. Slack scanner runs against a real channel and creates at least one source note with full message text, sender, and thread context — not an empty stub
  2. GoodLinks source notes contain actual extracted article body text (not empty `content:` fields or placeholder text)
  3. YouTube ingestion completes at least one video without silent failure — note exists in vault with transcript content
  4. Running any scanner a second time with no new content produces zero new notes and no errors (incremental state validated with real data)
**Plans**: TBD

### Phase 18: Enrichment Validation
**Goal**: Real vault notes pass through the full enrichment path — summaries, atoms, and theme connections are produced at quality, not just as code artifacts
**Depends on**: Phase 17 (real content-rich source notes exist)
**Requirements**: ENRICH-01, ENRICH-02, ENRICH-03
**Success Criteria** (what must be TRUE):
  1. At least 10 source notes have summaries and tags written by the enrichment pipeline (not manually)
  2. At least 5 source notes have been split into atomic notes in `vault/atoms/` — each atom covers a single concept with why-it-matters preserved
  3. At least 3 atoms have theme connections added — each connection has a written justification linking the atom to an existing vault theme
**Plans**: TBD

### Phase 19: Drafting & Strategist
**Goal**: The pipeline produces a real draft blog post from vault atoms, and a complete `/content-strategist` session runs end-to-end producing output worth editing
**Depends on**: Phase 18 (enriched atoms and theme connections exist)
**Requirements**: DRAFT-01, DRAFT-02, STRAT-01, STRAT-02
**Success Criteria** (what must be TRUE):
  1. At least one draft blog post exists in `vault/drafts/` generated from real atom content (not synthetic test data)
  2. The draft post contains inline citations linking back to source atom IDs so provenance is traceable
  3. `/content-strategist` command runs without crashing and surfaces at least one cluster of unmatched atoms with a synthesis proposal
  4. A complete `/content-strategist` session — from opening to draft output — produces a blog post draft that a human judge considers worth editing
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
| 15. Intelligence Skills | v1.3 | 5/5 | Complete | 2026-03-01 |
| 16. E2E Wiring + Verification | v1.3 | 3/3 | Complete | 2026-03-01 |
| 17. Ingestion Debugging | v1.4 | 0/TBD | Not started | - |
| 18. Enrichment Validation | v1.4 | 0/TBD | Not started | - |
| 19. Drafting & Strategist | v1.4 | 0/TBD | Not started | - |

---

*Roadmap created: 2026-02-04*
*Last updated: 2026-03-02 (v1.4 phases 17-19 added)*
