# Project Research Summary

**Project:** Hugo Resume Theme Migration
**Domain:** Static site theme migration (Blowfish → Hugo Resume)
**Researched:** 2026-02-04
**Confidence:** MEDIUM-HIGH

## Executive Summary

This migration changes the fundamental architecture of the portfolio site from a flexible multi-page blog/portfolio theme (Blowfish) to a single-page data-driven resume theme (Hugo Resume). The core challenge is not the theme swap itself, but restructuring 1200+ lines of custom CSS and converting markdown-based content into JSON data files.

The recommended approach treats this as a content transformation project, not a simple theme change. Phase 1 should focus on achieving a functional single-page resume with minimal custom styling, validating the architectural fit before investing in custom design recreation. The single-page layout may conflict with the "decision portfolio" positioning that emphasizes case studies - this fit issue should be validated early.

Key risks include: (1) loss of 1200+ lines of Apple-inspired custom CSS during theme switch, (2) Hugo Module cleanup failures causing build conflicts, (3) content schema mismatches between markdown frontmatter and JSON data files, and (4) GitHub Pages deployment breakage despite local builds working. Mitigation requires clean-slate CSS approach for V1, explicit module cleanup procedures, content mapping scripts, and production deployment testing before launch.

## Key Findings

### Recommended Stack

Hugo Resume is a single-page Bootstrap 4 resume theme that uses JSON data files for structured content and markdown for narrative sections. Current Hugo 0.154.3+extended is compatible with theme requirements (minimum 0.62).

**Core technologies:**
- **Hugo 0.154.3+extended (current) → 0.154.5+ (target)**: Static site generator - already in use, compatible with both themes, extended version required for SCSS processing
- **Hugo Modules (recommended) or Git Submodules (fallback)**: Theme dependency management - modules offer cleaner removal/switching versus submodules leaving repository traces
- **JSON data files (`data/skills.json`, `experience.json`, `education.json`)**: Structured resume content - theme's core pattern, requires conversion from markdown frontmatter
- **Bootstrap 4 (vendored in theme)**: CSS framework - replaces current Tailwind CSS, requires CSS migration strategy for 1200+ lines of custom styles
- **Fuse.js + jQuery (vendored)**: Client-side search - built into theme, no additional setup required

**Critical version requirements:**
- Hugo extended version required (not standard)
- Go 1.12+ if using Hugo Modules approach
- No frontend dependency management needed (theme includes all assets)

**Installation method trade-off:**
Hugo Modules provide clean theme switching and easier updates but require Go installed. Git Submodules avoid Go dependency but create repository traces and harder iteration. Recommend modules for experimentation phase.

### Expected Features

**Must have (table stakes):**
- Single-page resume layout - industry standard for quick scanning
- Work experience timeline - essential for career progression narrative
- Skills inventory - hiring managers screen by tech stack
- Education background - PhD credential verification
- Contact information + social links - LinkedIn and GitHub minimum expected
- Mobile responsive design - 60%+ of traffic is mobile
- Professional photo - humanizes portfolio, builds trust
- Custom domain - signals professionalism
- Fast load times - static site generation handles this

**Should have (competitive advantage):**
- Detailed project pages - demonstrates depth over breadth (Hugo Resume supports `/creations/` and `/contributions/`)
- Publications section - showcases academic→industry bridge (built-in archetype)
- Blog/writing section - thought leadership on decision frameworks (built-in)
- Client-side search - visitors can find specific topics (Fuse.js built-in)
- Case study format - shows decision-making process (requires custom archetype, not built-in)
- Downloadable resume PDF - enables ATS submission (not built-in, requires custom solution)

**Defer (v2+):**
- Dark mode - standard UX feature but NOT included in Hugo Resume (gap)
- Multi-language support - only if targeting global roles
- Tag-based filtering - only if 10+ projects/articles exist
- Netlify CMS integration - unnecessary for personal site maintained by owner
- QR code vCard - nice-to-have for conference networking (built-in but low priority)

**Anti-features to avoid:**
- Skills rating bars - subjective, looks amateurish
- Every project ever built - dilutes portfolio with weak work
- Testimonials carousel - feels sales-y for senior portfolios
- Animated hero sections - distracts from content
- Blog with infrequent posts - stale content signals neglect

### Architecture Approach

Hugo Resume fundamentally differs from Blowfish by using data-driven content (JSON files in `data/`) for structured sections and minimal markdown for narrative content, versus Blowfish's markdown-everything approach. Single-page layout with auto-scroll navigation replaces multi-page site structure.

**Major components:**

1. **Data-driven resume sections** - `data/skills.json`, `data/experience.json`, `data/education.json` feed templates via `.Site.Data.*` access; requires converting current markdown frontmatter → structured JSON

2. **Markdown detail pages** - `content/projects/creations/`, `content/projects/contributions/`, `content/publications/`, `content/blog/` provide narrative depth beyond single-page resume; note: theme expects `blog/` NOT `posts/` folder

3. **Section-based navigation** - `params.sections` array in config auto-generates left-hand nav with anchor links; replaces Blowfish's explicit menu configuration in `menus.en.toml`

4. **Bootstrap 4 layout system** - vendored component-based CSS replaces Tailwind utility-first approach; 1200+ lines of custom CSS overrides need complete rewrite or clean-slate approach

5. **Hugo Pipes asset pipeline** - theme uses standard Hugo asset processing; current Blowfish setup compatible but must verify custom CSS loading mechanism differs

**Key pattern: Template lookup order override** - project-level `layouts/` overrides theme templates, enabling customization without theme modification; critical for CSS loading (`layouts/partials/head.html`) and case studies (V2)

**Data flow difference:** Hugo Resume templates directly reference `.Site.Data.skills` for JSON content versus Blowfish rendering markdown through flexible layouts. This architectural shift requires content transformation, not just theme swap.

### Critical Pitfalls

1. **Custom CSS lost during migration** - Theme's CSS loading mechanism differs from Blowfish's auto-load; 1200+ lines of custom CSS silently ignored unless explicitly injected via `layouts/partials/head.html` override. Prevention: Audit CSS loading before migration, create custom head partial, test in DevTools that custom styles apply.

2. **Hugo Modules cleanup failure** - Removing Blowfish (Hugo module) while switching to Hugo Resume causes build failures or silent use of cached Blowfish templates. Prevention: Run `hugo mod clean --all`, delete `go.mod`/`go.sum`, remove `[module]` from config, verify `hugo mod graph` shows only new theme before proceeding.

3. **Content schema mismatch** - Blowfish frontmatter fields (`showDate`, `groupByYear`) incompatible with Hugo Resume expectations; core resume data must convert to JSON format in `data/` directory versus markdown frontmatter. Prevention: Map frontmatter fields between themes, create JSON schemas matching theme requirements, test sample content before bulk migration.

4. **GitHub Pages deployment breakage** - Local builds work but production shows unstyled HTML with 404s for assets despite `publishDir = "docs"` configuration. Prevention: Verify `baseURL` matches deployment URL, test actual `docs/` build (not just `hugo server`), check CI uses Hugo extended version, clear GitHub Pages cache with empty commit.

5. **Layout override conflicts** - Custom Blowfish layouts (`layouts/_default/single.html`, custom partials) persist and break Hugo Resume rendering with cryptic template errors. Prevention: Audit `layouts/` directory before migration, temporarily move overrides to backup, test clean theme first, selectively reintroduce only theme-agnostic overrides.

## Implications for Roadmap

Based on research, this migration requires 3-4 phases with explicit validation gates. The single-page architecture represents a fundamental change that may not align with portfolio positioning - Phase 1 must validate this fit before investing in custom design work.

### Phase 1: Theme Installation & Core Resume (MVP)

**Rationale:** Establish working baseline with Hugo Resume theme before content transformation. Clean Hugo Module removal critical to prevent build conflicts. Minimal CSS approach validates theme fit without investing in full design port.

**Delivers:**
- Functional single-page resume with Hugo Resume theme
- Skills, experience, education sections (data-driven via JSON)
- Contact information and social links
- Basic about/bio section
- Verification that single-page layout suits portfolio goals

**Addresses features:**
- Single-page resume layout (table stakes)
- Work experience timeline (table stakes)
- Skills inventory (table stakes)
- Education background (table stakes)
- Contact + social links (table stakes)
- Mobile responsive (table stakes)

**Avoids pitfalls:**
- Hugo Modules cleanup failure (explicit cleanup sequence)
- Layout override conflicts (audit and backup existing layouts)
- Custom CSS lost (create head partial, verify loading)

**Migration sequence:**
1. Clean Blowfish module (run `hugo mod clean --all`, delete `go.mod`/`go.sum`, remove `[module]` config)
2. Backup existing layouts (`mv layouts/ layouts.blowfish.backup/`)
3. Install Hugo Resume (Hugo Module or git submodule)
4. Consolidate config (merge `config/_default/*.toml` → single `config.toml`)
5. Create data files (extract from `content/resume.md` → `data/*.json`)
6. Simplify `content/_index.md` (remove proof tiles, keep bio)
7. Create minimal custom CSS (colors, fonts only - defer full port)
8. Verify in `hugo server` before proceeding

**Research needs:** None - straightforward implementation with clear Hugo Resume documentation.

**Validation gate:** Does single-page layout feel right for "decision portfolio" positioning? If not, reconsider theme choice before Phase 2.

### Phase 2: Content Migration & Styling Foundation

**Rationale:** With working baseline established, transform remaining content and establish CSS customization approach. Defer case studies to avoid premature investment if architecture doesn't fit.

**Delivers:**
- Professional photo integration
- Social media handles configured
- Custom domain setup (athandial.com if available)
- Enhanced custom CSS (spacing, typography, colors)
- Preservation of current content (case studies inactive but not deleted)

**Implements:**
- Professional photo (table stakes)
- Custom domain (table stakes)
- Custom CSS foundation for brand consistency

**Avoids pitfalls:**
- Asset pipeline differences (verify CSS changes reflect, check fingerprinting)
- Navigation/menu configuration differences (test all links, mobile menu)

**CSS strategy decision point:**
- **Option A (recommended):** Clean slate with minimal overrides (fast, avoids Bootstrap conflicts)
- **Option B (deferred to V2):** Full 1200-line CSS port (high effort, preserves exact brand)
- **Option C:** Hybrid CSS variables approach (requires inspecting theme's variable usage)

**Research needs:** None - standard Hugo customization patterns.

### Phase 3: Deployment & Validation

**Rationale:** Production deployment has distinct failure modes from local builds. Must verify before declaring migration complete.

**Delivers:**
- Working production deployment to GitHub Pages
- Asset loading verification (CSS, JS, images)
- SEO metadata validation
- Performance baseline (Lighthouse score)

**Avoids pitfalls:**
- GitHub Pages deployment breakage (test actual `docs/` build, verify asset paths)
- SEO metadata loss (verify Open Graph tags, structured data)

**Testing checklist:**
- Build with production `baseURL`
- Verify `docs/` directory structure matches expectations
- Test asset paths in `docs/index.html`
- Serve `docs/` locally to simulate GitHub Pages
- Check DevTools for 404s
- Run Lighthouse audit
- Test social media preview cards

**Research needs:** None - standard deployment validation.

### Phase 4 (Optional): Case Studies & Advanced Features

**Rationale:** ONLY proceed if Phase 1 validation confirms single-page layout suits portfolio needs. Case studies require custom archetypes and layout overrides.

**Delivers:**
- Case studies migrated to `/projects/creations/` or `/contributions/`
- Custom grid layout for project listing
- Case study detail page format preserved
- Proof tiles or equivalent homepage feature
- Full custom CSS design system (if desired)

**Implements:**
- Case study format (competitive advantage)
- Project detail pages (competitive advantage)
- Publications section (competitive advantage)
- Blog/writing section (competitive advantage)

**Avoids pitfalls:**
- Shortcode incompatibility (audit and port custom shortcodes)
- Data file structure mismatch (map case study frontmatter to project archetype)
- Excessive `!important` in CSS (clean CSS approach versus porting Blowfish overrides)

**Migration approach:**
- Classify each case study as "creation" (originator) or "contribution" (collaborator)
- Use `hugo new projects/creations/name.md` archetype
- Map frontmatter: `problem_type`, `scope`, `complexity` → custom fields
- Preserve content structure (Context → Ownership → Decision Frame → Outcome → Reflection)
- Override `layouts/projects/list.html` for grid view
- Override `layouts/projects/single.html` for detail page
- Reuse existing `case-study-card.html` partial

**Research needs:** MEDIUM priority - requires deeper research into:
- Hugo Resume's project archetype extensibility
- Bootstrap 4 grid system for custom card layouts
- Whether single-page navigation can accommodate multi-page case studies

**Alternative consideration:** If Phase 4 proves too complex or single-page layout feels constrained, consider sticking with Blowfish theme or exploring hybrid approach (Hugo Resume for resume subdomain, Blowfish for case studies).

### Phase Ordering Rationale

- **Phase 1 before 2:** Must establish working baseline and validate architectural fit before investing in content transformation or custom design
- **Phase 2 before 3:** Content and styling must be complete before production deployment to avoid deploying incomplete site
- **Phase 3 before 4:** Production deployment verification ensures migration foundation solid before adding complexity
- **Phase 4 optional:** Case studies are high-effort customization; only proceed if single-page architecture validated in Phase 1

**Dependency chain:**
```
Phase 1 (Theme Setup)
    └─ validates ─> Phase 2 (Content Migration)
                        └─ completes ─> Phase 3 (Deployment)
                                            └─ optional ─> Phase 4 (Case Studies)
```

**Critical decision point:** Phase 1 validation determines if Hugo Resume is right theme choice. If single-page layout doesn't support "decision portfolio" positioning, recommend staying with Blowfish or finding alternative theme.

### Research Flags

**Phases needing deeper research during planning:**
- **Phase 4 (Case Studies):** MEDIUM priority - Custom archetype extensibility, Bootstrap grid layouts, multi-page detail pages within single-page theme paradigm. Research should address: Can Hugo Resume support full-page case study detail views? What's best way to extend project archetype with custom frontmatter fields?

**Phases with standard patterns (skip research-phase):**
- **Phase 1 (Theme Setup):** Well-documented Hugo Module management and config consolidation
- **Phase 2 (Content Migration):** Standard Hugo content transformation and CSS customization patterns
- **Phase 3 (Deployment):** Established GitHub Pages deployment verification procedures

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Hugo Resume requirements verified from official repo, JSON schemas inspected, Hugo version compatibility confirmed |
| Features | HIGH | Official theme docs + portfolio best practices from multiple sources, clear table stakes vs. competitive features |
| Architecture | HIGH | Core architecture documented in official repo, data flow patterns clear, migration path well-defined |
| Pitfalls | MEDIUM | Based on Hugo community experiences and theme-specific documentation; Hugo Resume has limited recent docs, some assumptions based on general Hugo patterns |

**Overall confidence:** MEDIUM-HIGH

Strong confidence in technical migration path (stack, architecture, features) but moderate confidence in pitfall coverage due to Hugo Resume's limited recent community documentation. Most pitfall sources are general Hugo migration experiences, not Hugo Resume-specific.

### Gaps to Address

**Architectural fit uncertainty (HIGH priority):**
- Hugo Resume's single-page layout may conflict with "decision portfolio" positioning emphasizing case studies
- Research doesn't answer: Will single-page navigation feel constrained for portfolio use case?
- **Resolution strategy:** Phase 1 validation gate must explicitly assess this fit; be prepared to abandon migration if layout doesn't support positioning

**CSS migration strategy ambiguity (MEDIUM priority):**
- No documentation found on Hugo Resume's SCSS variable exposure for customization
- Unknown whether hybrid CSS variable approach (Option C) is feasible
- **Resolution strategy:** Inspect theme source during Phase 1; start with clean-slate approach (Option A), defer full port decision until V2 scope confirmed

**Case study archetype extensibility (MEDIUM priority):**
- Unclear how much custom frontmatter Hugo Resume's project archetype supports
- Unknown whether multi-page case study detail views work within single-page theme paradigm
- **Resolution strategy:** Defer to Phase 4 research; only address if Phase 1 validates architectural fit

**Dark mode implementation (LOW priority):**
- Hugo Resume lacks built-in dark mode (noted as gap in features research)
- Standard UX expectation in 2026, but not critical for MVP
- **Resolution strategy:** Defer to V2+ scope; implement via custom CSS if needed

**Theme maintenance risk (LOW priority):**
- Hugo Resume has 308 stars, 263 forks, but no official releases published
- Active development status unclear (8 open issues, 3 PRs)
- **Resolution strategy:** Be prepared to fork theme if customizations needed; accept maintenance burden as part of migration decision

## Sources

### Primary (HIGH confidence)

**Hugo Resume Theme (Official):**
- [Hugo Resume GitHub Repository](https://github.com/eddiewebb/hugo-resume) - Theme architecture, features, installation
- [Hugo Resume exampleSite](https://github.com/eddiewebb/hugo-resume/tree/master/exampleSite) - Directory structure reference
- [Hugo Resume README](https://github.com/eddiewebb/hugo-resume/blob/master/README.md) - Content structure, archetypes, migration tips
- [experience.json Schema](https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/data/experience.json) - JSON structure for experience data
- [skills.json Schema](https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/data/skills.json) - JSON structure for skills data
- [config.toml Example](https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/config.toml) - Configuration parameters
- [theme.toml](https://github.com/eddiewebb/hugo-resume/blob/master/theme.toml) - Minimum Hugo version (0.62)

**Hugo Documentation (Official):**
- [Hugo Front matter](https://gohugo.io/content-management/front-matter/)
- [Hugo mod clean command](https://gohugo.io/commands/hugo_mod_clean/)
- [Hugo Modules](https://gohugo.io/commands/hugo_mod/)
- [Template lookup order](https://gohugo.io/templates/lookup-order/)
- [Hugo Data Files](https://bwaycer.github.io/hugo_tutorial.hugo/extras/datafiles/)

### Secondary (MEDIUM confidence)

**Professional Portfolio Best Practices (2026):**
- [How to Create a Software Engineer Portfolio in 2026](https://zencoder.ai/blog/how-to-create-software-engineer-portfolio)
- [UX Portfolio Guide: How Senior Designers Get Hired in 2026](https://uxplaybook.org/articles/senior-ux-designer-portfolio-get-hired-2026)
- [Building a Portfolio That Gets Hired: 2026 Developer Guide](https://www.hakia.com/skills/building-portfolio/)
- [Best Web Developer Portfolio Examples from Top Developers in 2026](https://elementor.com/blog/best-web-developer-portfolio-examples/)

**Portfolio Anti-Patterns:**
- [Common mistakes when creating a portfolio](https://www.wix.com/blog/common-portfolio-mistakes)
- [12 Things You Should Remove From Your Portfolio Website Immediately](https://mattolpinski.com/articles/fix-your-portfolio/)
- [Five development portfolio anti-patterns](https://nitor.com/en/articles/five-development-portfolio-anti-patterns-and-how-to-avoid-them)

**Hugo Migration Experiences:**
- [JeffGeerling.com Migrated to Hugo (2026)](https://www.jeffgeerling.com/blog/2026/migrated-to-hugo/)
- [Hugo Theme Change blog post](https://andrewfitzy.github.io/posts/hugo-theme-change/)
- [Some notes on upgrading Hugo](https://jvns.ca/blog/2024/10/07/some-notes-on-upgrading-hugo/)
- [Hugo Modules vs Git Submodules comparison](https://drmowinckels.io/blog/2025/submodules/)

**Hugo Community Resources:**
- [Hugo Theme Customization Guide](https://bwaycer.github.io/hugo_tutorial.hugo/themes/customizing/)
- [How to override CSS in Hugo](https://discourse.gohugo.io/t/how-to-override-css-classes-with-hugo/3033)
- [Using Hugo Structured Data to Build a Resume Page](https://aldra.co/blog/hugo_structured_data/)
- [Hugo Hosting on GitHub Pages](https://bwaycer.github.io/hugo_tutorial.hugo/tutorials/github-pages-blog/)

**Community Pitfalls & Gotchas:**
- [Most common Hugo pitfalls and their solutions](https://geo.rocks/post/hugotricks/)
- [Hugo Discourse: Deployed Hugo on GitHub Pages, theme & images missing](https://discourse.gohugo.io/t/deployed-hugo-on-github-pages-theme-images-are-missing/53986)
- [Hugo Discourse: Managing Hugo themes with modules](https://discourse.gohugo.io/t/managing-hugo-themes-with-modules-for-new-those-new-to-hugo/47799)

### Tertiary (LOW confidence)

**Inferred from theme code inspection:**
- Frontend library versions (jQuery 3.3.1, Fuse.js 3.2.0, Mark.js 8.11.1) - Mentioned in search results but not confirmed in official docs
- Theme maintenance status - No recent release dates visible; inferred from repository statistics
- CSS customization approach - Requires inspecting theme source for SCSS variables

---
*Research completed: 2026-02-04*
*Ready for roadmap: yes*
