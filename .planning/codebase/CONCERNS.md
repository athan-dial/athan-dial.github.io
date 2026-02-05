# Codebase Concerns

**Analysis Date:** 2026-02-04

## Content Authenticity & Voice

**Critical Issue: AI-generated content lacking authentic voice**
- Issue: Current portfolio case studies are fabricated/generic and do NOT sound like Athan, undermining the "decision evidence, not achievements" brand positioning
- Files: `content/case-studies/*.md` (7 Montai case studies, 2 older studies)
- Impact: Portfolio fails core value proposition — credibility and hiring goal severely compromised when voice doesn't match actual work quality
- Fix approach:
  1. Wait for ChatGPT Deep Research outputs (Voice & Style Guide + Montai Work Archaeology)
  2. Apply authentic vocabulary, sentence patterns, and technical preferences to all writing
  3. Replace generic AI language ("I helped...", "I implemented...") with factual project details, real metrics, stakeholder names
  4. Include authentic tradeoff framing and limitation acknowledgment
  5. Do NOT write new case studies until research data is available

**Before Deep Research available:**
- Cannot write new case studies (lack factual details, real project context)
- Cannot rewrite resume content (lack authentic voice + project details)
- Cannot write About page origin story (lack authentic narrative)
- Can do structural work (scaffolding, templates, design improvements)
- Can do technical improvements (SEO, performance, asset generation)

**Blocking factor:** Deep Research files located at `/Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/000 System/01 Inbox` (not yet checked in)

---

## Design System Brittleness

**Heavy CSS overrides fragile to theme updates:**
- Issue: `assets/css/custom.css` (1216 lines) extensively overrides Blowfish theme with heavy `!important` usage
- Files: `assets/css/custom.css`
- Impact: Theme updates (`hugo mod get -u`) risk visual regressions. No automated testing to catch CSS conflicts
- Fix approach:
  1. Audit all `!important` declarations — some are necessary (override theme), others may be working around missing overrides
  2. Create visual regression test checklist for light/dark modes and responsive breakpoints (mobile/tablet/desktop)
  3. Maintain separate test page with all component states
  4. Document CSS override rationale inline (why each override exists, what it prevents)
  5. Plan incremental theme upgrade strategy (test in branch before merging)

**Specific fragile areas:**
- Typography forcing (Inter everywhere with `!important`) — will break if font loading fails silently
- Border radius forcing (`--radius-2xl: 32px` globally) — assumes all cards use full borders; won't degrade gracefully if theme changes card structure
- Spacing overrides on proof tiles and case study cards — tightly coupled to layout assumptions
- Dark mode color system — separate CSS block for `html.dark`, not using CSS cascade effectively

---

## Content Asset Generation Debt

**Manual asset creation plan not executed:**
- Issue: `ASSET_GENERATION_PLAN.md` outlines 32-35 SVG assets (icons, hero images, patterns, diagrams) to be generated but has NOT been executed
- Files: `ASSET_GENERATION_PLAN.md` (plan), `/static/images/icons/`, `/static/images/case-studies/`
- Impact:
  - Some assets exist (hero images for case studies, navigation icons) but coverage incomplete
  - Missing diagrams referenced in case studies could be generated
  - No central asset registry or versioning strategy
- Fix approach:
  1. Audit existing assets in `/static/images/` — what exists vs what's planned
  2. Prioritize critical path (hero images for published case studies)
  3. Generate remaining icons and diagrams programmatically
  4. Create asset manifest documenting what each file is used for
  5. Set up Hugo asset pipeline to prevent dead assets

**Status tracker needed:**
- [ ] Verify all 12 navigation icons present and used in templates
- [ ] Verify 3 proof signal icons (compass, circuit, mountain) exist
- [ ] Verify 8 category icons for case study types
- [ ] Verify 7 case study hero images (scaling, stat6, learning agenda, xtalpi, shiny, metric theater, pipeline latency)
- [ ] Generate missing background patterns and diagram templates
- [ ] Create asset inventory document

---

## Theme Update Risk

**Blowfish v2.96.0 — vulnerability and maintenance unknown:**
- Issue: Theme version locked in `go.mod` but no clear patch/update strategy; Blowfish maintainability status unknown
- Files: `go.mod` (requires `github.com/nunocoracao/blowfish/v2 v2.96.0`)
- Impact: Security vulnerabilities in Hugo module dependency may not be caught; major version updates could break site
- Fix approach:
  1. Research Blowfish maintenance status (GitHub stars, recent commits, community)
  2. Monitor Go module security advisories (use `go list -m all` periodically)
  3. Create theme update procedure: test in branch, verify all CSS overrides still work
  4. Plan contingency for unmaintained theme (fork or migrate to alternative)
  5. Consider lighter fork of Blowfish with fewer features to reduce maintenance surface

---

## Publisher Directory Handling

**Automated build output checked into Git**
- Issue: `/docs/` directory (Hugo publishDir) is committed to Git and auto-updated by `hugo` command
- Files: `docs/` (entire directory with 35+ HTML files)
- Impact:
  - Large commit diffs on every build, pollutes Git history
  - Risk of manual edits in `/docs/` being overwritten by next build
  - Hard to distinguish source content changes from build output changes in Git blame
- Fix approach:
  1. Add `/docs/` to `.gitignore` (only commit source files)
  2. Configure GitHub Pages to build Hugo automatically (remove manual build step) OR
  3. Set up CI/CD workflow (GitHub Actions) to build and push to `/docs/` on push to main
  4. Use `publishDir = "public"` instead (convention) if moving away from `/docs/`
  5. Educate team: never manually edit `/docs/` files

**Current state:** `/docs/` is tracked and modified, creating false positive diffs

---

## Configuration Smell: Analytics Placeholder

**Unhooked analytics setup:**
- Issue: Google Analytics ID commented out in `config/_default/hugo.toml` (line 21: `# googleAnalytics = "G-XXXXXXXXX"`)
- Files: `config/_default/hugo.toml`
- Impact: Site traffic not being tracked; no visibility into audience, page performance, or referral sources
- Fix approach:
  1. Set up Google Analytics 4 property
  2. Add real GA4 ID to Hugo config
  3. Verify tracking initializes (check browser console for GA script)
  4. Create analytics dashboard for case study engagement tracking
  5. Use data to inform content priorities

**Secondary:** Firebase config also commented out in `config/_default/params.toml` (lines 139-145) — determine if needed

---

## Missing Fire Analytics Dashboard

**No visibility into case study engagement:**
- Issue: No analytics setup means unable to measure which case studies resonate, what visitors read, conversion funnel
- Files: None (feature not implemented)
- Impact:
  - Can't validate hiring/advisory goal (e.g., "case study X drove 3 advisory conversations")
  - Can't iterate content based on evidence (e.g., "this problem type gets 10% engagement")
  - Decisions about future case studies are uninformed
- Fix approach:
  1. Hook Google Analytics 4 (standard pageview + engagement tracking)
  2. Add custom event tracking for key interactions (case study clicks, newsletter signup, contact form)
  3. Create monthly dashboard: top pages, engagement rate, referral sources
  4. Use data to refine portfolio strategy

---

## Scaling Assumption: Static Git-Hosted Site

**GitHub Pages hosting limits portfolio growth:**
- Issue: Site deployed to GitHub Pages (static HTML), no backend infrastructure
- Files: Entire site, deployed to `gh-pages` branch via `/docs/` directory
- Impact:
  - Can't implement contact forms (no server-side email)
  - Can't track authenticated interactions (e.g., logged-in advisory requests)
  - Can't A/B test case study framing without code changes
  - Newsletter signup requires third-party integration (no data control)
  - Future needs (e.g., advisor booking, project filter) will require architectural shift
- Fix approach:
  1. Use GitHub Pages for static content (current approach is fine for now)
  2. Integrate Formspree or equivalent for contact form (free tier available)
  3. Use Mailchimp/Substack for newsletter (if needed later)
  4. Document current limitations and upgrade path if needed
  5. Evaluate if future features justify moving to Vercel/Netlify with serverless functions

---

## Employer Safety Risk: Advisory vs Consulting Language

**Positioning between "advisory" and consulting service:**
- Issue: Site uses "Advisory" framing (CLAUDE.md specifies safe language patterns), but some pages/content could be misinterpreted as active consulting business
- Files: `content/advisory.md`, `content/consulting.md` (now "advisory"), header navigation
- Impact: Could violate Montai employment terms if interpreted as running active consulting business while employed
- Fix approach:
  1. Audit all public-facing text for consulting language (remove: pricing, timeframes, engagement types)
  2. Use consistently: "Advisory & Thought Partnership", "I occasionally advise...", "Topics I Think About"
  3. Avoid: "Discovery calls", "Engagement booking", "Investment" framing
  4. Clarify hiring goal (case studies demonstrate capability for future roles) vs advisory business
  5. Add disclaimer on advisory page: informal thought partnership, not active consulting practice
  6. Review with Montai if uncertain about boundaries

---

## Dependency Version Constraint

**Go version requirement aggressive:**
- Issue: `go.mod` requires Go 1.25.5+ (very recent version as of analysis date)
- Files: `go.mod` (line 3: `go 1.25.5`)
- Impact:
  - Contributors or CI/CD with older Go versions will fail to build
  - Hugo module resolution may break with Go version mismatches
  - Reduces portability across machines and environments
- Fix approach:
  1. Check minimum Go version required by Blowfish v2.96.0
  2. Consider lowering to Go 1.22 or 1.23 for broader compatibility
  3. Document Go version requirement in README or CLAUDE.md
  4. Set up `.nvmrc` equivalent (use `tool-versions` or similar) for version pinning

---

## Test Coverage Gaps

**No testing infrastructure:**
- Issue: No test framework, no validation tests for content, no theme integration tests
- Files: None (no test files exist)
- Impact:
  - CSS changes risk visual regressions uncaught
  - Content schema changes (frontmatter) won't be validated
  - Theme updates could break layouts without warning
  - Dead links in case studies won't be detected
- Fix approach (low priority, high effort):
  1. Use `hugo server` with local validation (manual for now)
  2. Consider htmlhint for HTML validation in CI
  3. Set up link checker (e.g., `htmlproofer`, `lychee`) to catch broken references
  4. Create visual regression test (screenshot comparisons) for key pages
  5. Document manual testing checklist (light/dark modes, responsive, all pages load)

---

## Content Gaps & Incomplete Sections

**Resume page potentially stale or generic:**
- Issue: `content/resume.md` exists but uncertain if it reflects current role/experience with authentic voice
- Files: `content/resume.md`
- Impact: Resume may not sell decision-making authority or hiring candidacy effectively
- Fix approach:
  1. Audit resume content against Montai Work Archaeology (if available in Deep Research)
  2. Add quantitative outcomes and decision frameworks (not just skills list)
  3. Match voice and terminology to case studies (consistency)
  4. Highlight PhD→Product skill transfers explicitly

**About page missing or generic:**
- Issue: `content/about.md` exists but likely lacks authentic origin story or context
- Files: `content/about.md`
- Impact: Visitor can't understand Athan's perspective or why decisions/case studies matter
- Fix approach:
  1. Wait for Deep Research Voice & Style Guide
  2. Write authentic origin narrative (how did PhD lead to product?)
  3. Position "decision evidence over achievements" philosophy
  4. Keep it brief (2-3 paragraphs max)

---

## Performance & SEO Baseline Unknown

**No performance metrics or SEO audit:**
- Issue: No visibility into Core Web Vitals, Lighthouse scores, SEO ranking, page load times
- Files: None (no monitoring)
- Impact:
  - May rank poorly in Google (case studies won't be discovered)
  - Slow pages hurt user experience and conversion
  - Missing meta tags or structured data reduce search visibility
- Fix approach:
  1. Use Google PageSpeed Insights to check Core Web Vitals (Largest Contentful Paint, etc.)
  2. Use Lighthouse CI in GitHub Actions for automated performance testing
  3. Audit on-page SEO (meta descriptions, keywords, heading hierarchy)
  4. Set target: Lighthouse score ≥ 90 for all pages
  5. Monitor search console for indexing issues

---

## Cleanup Tasks: Stale Files

**Deprecated Jekyll remnants still in Git:**
- Issue: Old Jekyll config and blog posts deleted from filesystem but still in Git history
- Files: Deleted (visible in `git status`): `Gemfile`, `_config.yml`, `_data/`, `_posts/`, old project markdown
- Impact:
  - Git clone downloads deleted files (unnecessary storage)
  - Historical context unclear without commit messages
  - Site successfully migrated to Hugo, but cleanup is incomplete
- Fix approach:
  1. Verify these files are NOT needed (confirmed: Hugo-based site active)
  2. Force-push or squash history if concerned about repository size (or accept it)
  3. Document migration in README: "Site migrated from Jekyll to Hugo on [date]"
  4. Note: Low priority, doesn't affect current functionality

---

## Font Loading Strategy Fragile

**Fallback chain assumes TikTok Sans availability:**
- Issue: CLAUDE.md mentions "TikTok Sans fonts must remain in `static/fonts/`", but custom.css imports Inter + JetBrains Mono from Google (no TikTok Sans)
- Files: `assets/css/custom.css`, CLAUDE.md documentation mismatch
- Impact:
  - Documentation claims TikTok Sans; CSS uses Inter (contradiction)
  - If Inter font loading fails, fallback to system sans-serif may look wrong
  - Self-hosted font strategy mentioned but not implemented
- Fix approach:
  1. Clarify font strategy: Are we using Inter (current) or TikTok Sans (documented)?
  2. If using Inter from Google Fonts: ensure font-display: swap for fast text rendering
  3. If planning TikTok Sans: self-host in `/static/fonts/` and update CSS
  4. Test font loading failure scenario (no network) — does site still read well?
  5. Update CLAUDE.md to match actual implementation

---

## Dark Mode Color Consistency

**Dark mode color palette may not be AA-compliant:**
- Issue: Dark mode text colors set in `custom.css` (lines 115-136) but contrast ratios not verified
- Files: `assets/css/custom.css` (dark mode CSS variables)
- Impact: Text may fail WCAG AA contrast requirement (4.5:1 for normal text) in dark mode
- Fix approach:
  1. Use WebAIM contrast checker to verify:
     - `--text-primary: #FFFFFF` on `--bg-primary: #000000` (should pass: 21:1)
     - `--text-secondary: #AEAEB2` on `--bg-primary: #000000` (check: likely fails)
     - `--text-tertiary: #8E8E93` on `--bg-secondary: #1C1C1E` (check: likely fails)
  2. If failing, adjust secondary/tertiary colors to lighter values
  3. Test on actual site in dark mode (screenshots of difficult text)
  4. Document accessibility targets in design system

---

## .gitignore Incomplete

**Uncommitted tracking ignored inconsistently:**
- Issue: `.gitignore` modified (per git status) but unclear what patterns are added/removed
- Files: `.gitignore`
- Impact:
  - Sensitive files (env vars, API keys) could be accidentally committed
  - Generated files (`/resources/`, build artifacts) shouldn't be committed
- Fix approach:
  1. Review `.gitignore` to ensure:
     - `.env`, `.env.local`, and other secret files are ignored
     - Build output (if not in `/docs/`) is ignored
     - IDE temp files (`.vscode/`, `.DS_Store`) are ignored
     - `go.sum` is NOT ignored (should be committed)
  2. Add standard Hugo patterns:
     ```
     /resources/_gen/
     /public/
     /docs/  # if switching away from docs/ as publishDir
     ```
  3. Commit improved `.gitignore`

---

## Project Organization Confusion

**Multiple workflow/automation systems in one repo:**
- Issue: BMAD system (`/_bmad/`) is separate agent workflow tool for planning/design, but lives in portfolio repo
- Files: `/_bmad/` (1000+ files, entirely separate system)
- Impact:
  - Large repo (unnecessary bulk for portfolio clone)
  - Unclear what belongs to portfolio vs automation system
  - Potential namespace collision if future case studies reference BMAD concepts
- Fix approach:
  1. Move BMAD to separate repository (if not internal-only)
  2. Or: Document BMAD as "unrelated to portfolio site" in README (current workaround)
  3. Add top-level `.gitignore` entry: `_bmad/**` (if keeping it isolated)
  4. Clarify in CLAUDE.md section 5: "BMAD System is NOT part of the Hugo site"

---

## Summary of Priority Tiers

**Critical (blocks hiring goal):**
- Content authenticity lacking (awaiting Deep Research)
- Employer safety language gaps

**High (functional risk):**
- Analytics not wired up (can't measure success)
- CSS design system brittleness (theme update risk)
- Test coverage gaps (regressions undetected)

**Medium (quality improvement):**
- Asset generation incomplete (visual gaps)
- Font loading strategy unclear (consistency issue)
- Dark mode accessibility (WCAG compliance)
- Content gaps (resume, about page voice)

**Low (housekeeping):**
- Deprecated Jekyll files in Git history
- BMAD system organization
- .gitignore improvements
- Dependency version constraints

---

*Concerns audit: 2026-02-04*
