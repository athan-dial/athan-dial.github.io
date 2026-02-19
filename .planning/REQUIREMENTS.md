# Requirements: Athan Dial Portfolio Site

**Defined:** 2026-02-19
**Core Value:** Demonstrate strategic credibility through the site itself

## v1.2 Requirements

Requirements for GoodLinks Ingestion milestone. Each maps to roadmap phases.

### Data Access

- [ ] **DATA-01**: Scanner can read GoodLinks SQLite database in read-only mode
- [ ] **DATA-02**: Scanner tracks last-scan timestamp for incremental processing
- [ ] **DATA-03**: Scanner uses lookback buffer to handle iCloud sync lag

### Ingestion

- [ ] **INGS-01**: Scanner creates vault notes with standard frontmatter (title, url, source, date, tags, status)
- [ ] **INGS-02**: Scanner passes GoodLinks tags through as initial note tags
- [ ] **INGS-03**: Scanner extracts pre-stored article content from GoodLinks content table
- [ ] **INGS-04**: Scanner falls back to web fetch for links without pre-extracted content

### Integration

- [ ] **INTG-01**: GoodLinks scanner is wired into scan-all.sh orchestrator
- [ ] **INTG-02**: URL normalization prevents duplicates across GoodLinks, web capture, Slack, and Outlook sources
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
| DATA-01 | — | Pending |
| DATA-02 | — | Pending |
| DATA-03 | — | Pending |
| INGS-01 | — | Pending |
| INGS-02 | — | Pending |
| INGS-03 | — | Pending |
| INGS-04 | — | Pending |
| INTG-01 | — | Pending |
| INTG-02 | — | Pending |
| INTG-03 | — | Pending |

**Coverage:**
- v1.2 requirements: 10 total
- Mapped to phases: 0
- Unmapped: 10 ⚠️

---
*Requirements defined: 2026-02-19*
*Last updated: 2026-02-19 after initial definition*
