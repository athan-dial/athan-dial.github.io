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

**Plans:** (created by /gsd:plan-phase)

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

**Plans:** (created by /gsd:plan-phase)

**Research Flags:** None (standard deployment validation)

---

## Progress

| Phase | Status | Requirements | Progress |
|-------|--------|--------------|----------|
| 1 - Theme Foundation | ✓ Complete | THEME-01, THEME-02, THEME-03 | 100% |
| 2 - Content & Styling | Ready | CONT-01, CONT-02, CONT-03, CONT-04, CONT-05, DESIGN-01, THEME-05, THEME-06 | 0% |
| 3 - Production Deployment | Pending | THEME-04, DESIGN-02 | 0% |

**Overall:** 3/13 requirements complete (23%)

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
*Roadmap created: 2026-02-04*
*Last updated: 2026-02-05*
