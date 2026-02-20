# Requirements: Athan Dial Portfolio Site

**Defined:** 2026-02-19
**Core Value:** Demonstrate strategic credibility through the site itself

## v1.2 Requirements

Requirements for GoodLinks Ingestion milestone. Each maps to roadmap phases.

### Data Access

- [x] **DATA-01**: Scanner can read GoodLinks SQLite database in read-only mode
- [x] **DATA-02**: Scanner tracks last-scan timestamp for incremental processing
- [x] **DATA-03**: Scanner uses lookback buffer to handle iCloud sync lag

### Ingestion

- [x] **INGS-01**: Scanner creates vault notes with standard frontmatter (title, url, source, date, tags, status)
- [x] **INGS-02**: Scanner passes GoodLinks tags through as initial note tags
- [x] **INGS-03**: Scanner extracts pre-stored article content from GoodLinks content table
- [x] **INGS-04**: Scanner marks links without pre-extracted content with `content_status: pending` for downstream enrichment

### Integration

- [ ] **INTG-01**: GoodLinks scanner is wired into scan-all.sh orchestrator
- [x] **INTG-02**: URL normalization prevents duplicates across GoodLinks, web capture, Slack, and Outlook sources
- [ ] **INTG-03**: GoodLinks notes flow through existing Claude enrichment pipeline (summaries, tags, ideas)

## Future Requirements

### Enhanced GoodLinks Features

- **GLNK-01**: Starred articles get priority enrichment processing
- **GLNK-02**: Read-status from GoodLinks maps to vault note metadata
- **GLNK-03**: Custom tag mapping rules (GoodLinks tag → vault category)

## Out of Scope

| Feature | Reason |
|---------|--------|
| GoodLinks write-back | Pipeline is read-only; don't modify GoodLinks state |
| Apple Shortcuts integration | SQLite direct access is simpler and works headless |
| Real-time sync | Daily batch scan sufficient for content pipeline |
| GoodLinks API | No public API exists; SQLite is the stable access method |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| DATA-01 | Phase 12 | Complete |
| DATA-02 | Phase 12 | Complete |
| DATA-03 | Phase 12 | Complete |
| INGS-01 | Phase 12 | Complete |
| INGS-02 | Phase 12 | Complete |
| INGS-03 | Phase 12 | Complete |
| INGS-04 | Phase 12 | Complete |
| INTG-01 | Phase 13 | Pending |
| INTG-02 | Phase 13 | Complete |
| INTG-03 | Phase 13 | Pending |

**Coverage:**
- v1.2 requirements: 10 total
- Mapped to phases: 10
- Unmapped: 0 ✓

---
*Requirements defined: 2026-02-19*
*Last updated: 2026-02-19 after roadmap creation (traceability complete)*
