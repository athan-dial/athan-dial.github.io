# Requirements: Athan Dial Portfolio Site

**Defined:** 2026-03-02
**Core Value:** Demonstrate strategic credibility through the site itself

## v1.4 Requirements

### Ingestion

- [ ] **INGEST-01**: Slack scanner runs successfully against at least one real channel and creates source notes with full message text (not stubs)
- [ ] **INGEST-02**: GoodLinks source notes contain extracted article body text (not empty/stub content)
- [ ] **INGEST-03**: Running any scanner a second time without new content creates no duplicate notes (incremental state validated with real data)
- [ ] **INGEST-04**: YouTube ingestion runs cleanly with no silent failures

### Enrichment

- [ ] **ENRICH-01**: At least 10 source notes pass through enrichment and produce summaries + tags
- [ ] **ENRICH-02**: Atomic splitting produces single-concept atoms in `vault/atoms/` for at least 5 source notes
- [ ] **ENRICH-03**: Theme matching connects at least 3 atoms to existing vault themes with written justifications

### Drafting

- [ ] **DRAFT-01**: At least one draft blog post exists in `vault/drafts/` generated from real atom content
- [ ] **DRAFT-02**: Draft post contains inline citations linking back to source atom IDs

### Interactive

- [ ] **STRAT-01**: `/content-strategist` command runs end-to-end without crashing and discovers real unmatched atoms
- [ ] **STRAT-02**: A complete `/content-strategist` session produces a draft worth editing (human judgment)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Outlook scanner validation | Deferred to v1.5 — Slack is higher priority source |
| Portfolio case studies | Blocked on ChatGPT Deep Research voice/archaeology outputs |
| Publishing to Quartz site | Drafts stay in vault — publish gate is separate concern |
| New ingestion sources | YouTube/Slack/GoodLinks only for v1.4 |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| INGEST-01 | Phase 17 | Pending |
| INGEST-02 | Phase 17 | Pending |
| INGEST-03 | Phase 17 | Pending |
| INGEST-04 | Phase 17 | Pending |
| ENRICH-01 | Phase 18 | Pending |
| ENRICH-02 | Phase 18 | Pending |
| ENRICH-03 | Phase 18 | Pending |
| DRAFT-01 | Phase 19 | Pending |
| DRAFT-02 | Phase 19 | Pending |
| STRAT-01 | Phase 19 | Pending |
| STRAT-02 | Phase 19 | Pending |

**Coverage:**
- v1.4 requirements: 11 total
- Mapped to phases: 11
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-02*
*Last updated: 2026-03-02 — traceability mapped after roadmap creation*
