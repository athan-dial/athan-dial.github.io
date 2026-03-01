# Requirements: Athan Dial Portfolio Site

**Defined:** 2026-02-22
**Core Value:** Demonstrate strategic credibility through the site itself

## v1.3 Requirements

Requirements for Content Intelligence Pipeline milestone. Each maps to roadmap phases.

### Scanning

- [ ] **SCAN-01**: Slack scanner skill extracts full message content from starred items and specified channels via MCP tools
- [ ] **SCAN-02**: Slack scanner preserves conversational context (sender, channel, thread replies, reason for starring)
- [ ] **SCAN-03**: Outlook scanner extracts email subject and body content (not just URLs) via Graph API
- [ ] **SCAN-04**: Both scanners perform incremental scanning (only new content since last run)
- [x] **SCAN-05**: Scanned content creates source-layer vault notes with provenance frontmatter

### Atomic Notes

- [ ] **ATOM-01**: Splitting skill decomposes source notes into single-concept atomic notes
- [x] **ATOM-02**: Each atomic note includes provenance metadata (source_type, source_channel, source_sender, source_timestamp)
- [x] **ATOM-03**: Atomic notes include content_status tracking for pipeline progression
- [ ] **ATOM-04**: Splitting preserves why-it-matters context from the original source

### Theme Matching

- [ ] **THEME-01**: Matching skill connects new atomic notes to existing vault content via tags and titles (grep-based)
- [ ] **THEME-02**: Each connection includes written justification for why the link exists
- [ ] **THEME-03**: Maximum 3 theme connections per atomic note to prevent hub-and-spoke sprawl

### Synthesis

- [ ] **SYNTH-01**: Synthesis workflow clusters related atomic notes by theme
- [ ] **SYNTH-02**: Produces draft blog posts with inline citations to source atomic notes
- [ ] **SYNTH-03**: Drafts do not introduce claims beyond what source notes support
- [x] **SYNTH-04**: Human approval gate required before any draft is published

### Orchestration

- [ ] **ORCH-01**: Scanning skills can be invoked on-demand via Claude Code commands
- [ ] **ORCH-02**: Scanning integrates into existing scan-all.sh daily automation
- [ ] **ORCH-03**: Lockfile prevents concurrent vault writes between scheduled and interactive sessions
- [ ] **ORCH-04**: Content strategist mode enables interactive co-creation of synthesis and connections

## Future Requirements

### Voice & Style

- **VOICE-01**: Synthesis drafts match Athan's authentic voice (pending ChatGPT Deep Research Voice & Style Guide)
- **VOICE-02**: Anti-pattern detection for generic AI writing patterns

### Advanced Matching

- **MATCH-01**: Semantic search via embeddings for theme matching (deferred per PROJECT.md scope)
- **MATCH-02**: Cross-vault link suggestions beyond tag/title grep

## Out of Scope

| Feature | Reason |
|---------|--------|
| Semantic search / embeddings | PROJECT.md explicitly defers; grep sufficient at current vault scale |
| Auto-publish without approval | Non-negotiable design principle — explicit publish gate |
| Personal email scanning | Scoped to work Slack + work Outlook only |
| Real-time Slack monitoring | Batch scanning is sufficient; real-time adds complexity |
| Podcast/audio ingestion | YouTube only for audio content per existing scope |
| n8n orchestration | Bash scripts + launchd for v1; n8n deferred |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| SCAN-01 | Phase 15 | Pending |
| SCAN-02 | Phase 15 | Pending |
| SCAN-03 | Phase 15 | Pending |
| SCAN-04 | Phase 15 | Pending |
| SCAN-05 | Phase 14 | Complete |
| ATOM-01 | Phase 15 | Pending |
| ATOM-02 | Phase 14 | Complete |
| ATOM-03 | Phase 14 | Complete |
| ATOM-04 | Phase 15 | Pending |
| THEME-01 | Phase 15 | Pending |
| THEME-02 | Phase 15 | Pending |
| THEME-03 | Phase 15 | Pending |
| SYNTH-01 | Phase 15 | Pending |
| SYNTH-02 | Phase 15 | Pending |
| SYNTH-03 | Phase 15 | Pending |
| SYNTH-04 | Phase 14 | Complete |
| ORCH-01 | Phase 16 | Pending |
| ORCH-02 | Phase 16 | Pending |
| ORCH-03 | Phase 16 | Pending |
| ORCH-04 | Phase 16 | Pending |

**Coverage:**
- v1.3 requirements: 20 total
- Mapped to phases: 20
- Unmapped: 0 ✓

---
*Requirements defined: 2026-02-22*
*Last updated: 2026-02-22 — traceability mapped to phases 14-17*
