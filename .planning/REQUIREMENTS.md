# Requirements: Athan Dial Portfolio Site

**Defined:** 2026-02-04
**Core Value:** Demonstrate strategic credibility through the site itself

## v1 Requirements

Requirements for initial release. Theme migration + resume content.

### Theme & Configuration

- [x] **THEME-01**: Hugo Resume theme installed, Blowfish removed ✓
- [x] **THEME-02**: Site configuration set (baseURL, title, author info) ✓
- [x] **THEME-03**: Hugo Modules cleaned (go.mod/go.sum updated, no ghost refs) ✓
- [ ] **THEME-04**: GitHub Pages deployment verified (docs/ directory builds correctly)
- [ ] **THEME-05**: Dark mode functional (custom CSS implementation)
- [ ] **THEME-06**: Accent color customized (replace orange sidebar with modern palette)

### Content

- [ ] **CONT-01**: Experience timeline populated (JSON data file with work history)
- [ ] **CONT-02**: Skills inventory populated (JSON data file with skill categories)
- [ ] **CONT-03**: Education section populated (JSON data file)
- [ ] **CONT-04**: About/bio section written (profile summary on homepage)
- [ ] **CONT-05**: Contact information and social links configured

### Design

- [ ] **DESIGN-01**: Minimal custom CSS applied (accent colors, minor overrides)
- [ ] **DESIGN-02**: Mobile responsive validated (theme built-in, verify works)

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Portfolio Content

- **PORT-01**: Case study archetype created (custom layouts for decision evidence)
- **PORT-02**: 2-3 polished case studies written (with authentic voice/positioning)
- **PORT-03**: Projects section configured (creations vs contributions)

### Advanced Features

- **ADV-01**: Downloadable PDF resume (browser print or Hugo plugin)
- **ADV-02**: Full design system (if minimal CSS insufficient)
- **ADV-03**: Thought leadership / writing section

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Blog/frequent posting | Focus is portfolio, not content marketing |
| Complex JavaScript interactions | Static site, minimal dependencies |
| Custom theme development | Using Hugo Resume with configuration only |
| Case study rewrites in v1 | Need voice/positioning work first; deferred to v2 |
| Full 1200+ line CSS port | Incompatible frameworks (Bootstrap vs Tailwind); minimal overrides for v1 |
| Netlify CMS integration | GitHub Pages deployment, no CMS needed |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| THEME-01 | Phase 1 | Complete |
| THEME-02 | Phase 1 | Complete |
| THEME-03 | Phase 1 | Complete |
| THEME-04 | Phase 3 | Pending |
| THEME-05 | Phase 2 | Pending |
| THEME-06 | Phase 2 | Pending |
| CONT-01 | Phase 2 | Pending |
| CONT-02 | Phase 2 | Pending |
| CONT-03 | Phase 2 | Pending |
| CONT-04 | Phase 2 | Pending |
| CONT-05 | Phase 2 | Pending |
| DESIGN-01 | Phase 2 | Pending |
| DESIGN-02 | Phase 3 | Pending |

**Coverage:**
- v1 requirements: 13 total
- Mapped to phases: 13
- Unmapped: 0

---
*Requirements defined: 2026-02-04*
*Last updated: 2026-02-05 after Phase 1 completion*
