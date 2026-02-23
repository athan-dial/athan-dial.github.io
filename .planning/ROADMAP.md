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
- [ ] **Phase 15: Content Scanners** — Outlook full-body extraction and Slack MCP content scanner
- [ ] **Phase 16: Intelligence Skills** — Atomic splitting and theme matching as Claude Code skills
- [ ] **Phase 17: Synthesis and Orchestration** — Draft blog post synthesis, daily automation wiring, lockfile, content strategist mode

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

### Phase 15: Content Scanners
**Goal**: Slack and Outlook produce content-rich source notes in the vault — not just URLs — with full message context and incremental state
**Depends on**: Phase 14 (vault schema)
**Requirements**: SCAN-01, SCAN-02, SCAN-03, SCAN-04
**Success Criteria** (what must be TRUE):
  1. Running the Slack scanner subagent creates vault source notes that include full message text and conversational context (sender, channel, thread context, reason for starring)
  2. Running the Outlook scanner creates vault source notes with full email body and subject, not just extracted URLs
  3. Running either scanner a second time without new content creates no new notes (incremental state working)
  4. A `429` rate-limit error from Slack does not advance the last-scan timestamp (scan state remains safe)
**Plans**: TBD

### Phase 16: Intelligence Skills
**Goal**: New atomic notes exist in the vault from real source content, with provenance metadata and theme connections to existing vault content
**Depends on**: Phase 15 (real source notes exist)
**Requirements**: ATOM-01, ATOM-02, ATOM-03, ATOM-04, THEME-01, THEME-02, THEME-03
**Success Criteria** (what must be TRUE):
  1. Invoking `split-atomic` on a source note produces atomic notes in `vault/atoms/` where each note contains exactly one concept plus the original conversational context that explains why it was captured
  2. Each atomic note has `provenance` frontmatter (`source_type`, `source_channel`, `source_sender`, `source_timestamp`) and `atom_of` backlink to the parent source note
  3. Invoking `match-themes` on a set of atoms adds at most 3 wikilinks per note and each link includes a written sentence explaining why the connection exists (not just vocabulary overlap)
  4. Theme notes in `vault/themes/` aggregate related atoms with back-links
**Plans**: TBD

### Phase 17: Synthesis and Orchestration
**Goal**: Draft blog posts exist in the vault from real atomic content; the intelligence tier runs automatically in the daily scan and can be invoked interactively on demand
**Depends on**: Phase 16 (atomic notes and theme connections exist)
**Requirements**: SYNTH-01, SYNTH-02, SYNTH-03, SYNTH-04, ORCH-01, ORCH-02, ORCH-03, ORCH-04
**Success Criteria** (what must be TRUE):
  1. A draft blog post in `vault/drafts/` contains inline citations to specific atomic note IDs; every factual claim in the draft traces to a source atom
  2. The draft cannot be published automatically — a human must explicitly approve it through the existing Obsidian approval workflow
  3. Running `scan-all.sh` triggers the full intelligence pipeline (split → match → synthesis) after the existing scanners without any manual intervention
  4. A `pipeline.lock` file prevents a scheduled scan from writing to the vault while an interactive content strategist session is active
  5. Typing a content strategist slash command in Claude Code surfaces a cluster proposal and requests direction before generating any draft
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
| 14. Vault Schema | 1/1 | Complete   | 2026-02-23 | — |
| 15. Content Scanners | v1.3 | 0/? | Not started | — |
| 16. Intelligence Skills | v1.3 | 0/? | Not started | — |
| 17. Synthesis and Orchestration | v1.3 | 0/? | Not started | — |

---

*Roadmap created: 2026-02-04*
*Last updated: 2026-02-22 (v1.3 phases 14-17 added)*
