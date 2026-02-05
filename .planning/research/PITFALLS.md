# Hugo Theme Migration Pitfalls

**Domain:** Hugo theme migration (Blowfish v2.96.0 → Hugo Resume)
**Researched:** 2026-02-04
**Confidence:** MEDIUM

## Critical Pitfalls

### Pitfall 1: Custom CSS Lost During Migration

**What goes wrong:**
Custom CSS stored in `assets/css/custom.css` or `static/` gets silently ignored by the new theme. The site builds successfully but loses all custom styling, typography, spacing, and design system overrides. With extensive custom CSS (like the Blowfish → Hugo Resume migration), this results in a completely different visual appearance.

**Why it happens:**
Different themes have different asset pipelines and CSS loading mechanisms. Blowfish auto-loads `assets/css/custom.css` via its pipeline. Hugo Resume may not have this automatic loading, requiring manual integration into theme templates. Developers assume custom CSS "just works" across themes because Hugo's file hierarchy suggests project-level files override theme files, but CSS loading is template-driven, not automatic.

**How to avoid:**
1. Before migration: Audit how the current theme loads custom CSS (check `layouts/partials/head.html` or similar)
2. After migration: Verify new theme's CSS loading mechanism in its documentation
3. Add explicit `<link>` tags or Hugo Pipes calls in custom layout overrides if new theme doesn't auto-load custom CSS
4. Test locally with `hugo server` before deployment to catch styling loss early
5. Consider extracting custom CSS into a theme-agnostic approach (e.g., separate stylesheet linked in custom `<head>` partial)

**Warning signs:**
- New theme documentation doesn't mention `assets/css/custom.css` support
- Hugo build completes without errors but local preview looks drastically different
- CSS changes to `custom.css` don't reflect in browser (indicates theme isn't loading it)
- Browser DevTools shows theme's default styles but not your custom overrides

**Phase to address:**
Phase 1 (Theme Setup & Configuration) - Must verify CSS loading mechanism before proceeding with content migration.

**Sources:**
- [How to add custom CSS with Hugo modules](https://github.com/hugo-themes/toha/discussions/832)
- [Styling your Hugo website](https://www.brycewray.com/posts/2023/03/styling-hugo-site/)
- [Hugo Themes - How to Use and Customize](https://tangenttechnologies.ca/blog/hugo-themes/)

---

### Pitfall 2: Content Schema Mismatch (Frontmatter Incompatibility)

**What goes wrong:**
Themes define different frontmatter schemas. Blowfish content uses frontmatter fields like `showDate`, `showAuthor`, `groupByYear`, etc. Hugo Resume expects different fields (`profile`, `skills`, `experience`). Content renders incorrectly or not at all because the new theme doesn't recognize old frontmatter variables. Case studies might appear as blank pages or missing critical metadata.

**Why it happens:**
Hugo doesn't enforce frontmatter schemas - themes define their own conventions. Blowfish is a blog/portfolio theme with rich content types. Hugo Resume is a single-page resume theme with structured data expectations (JSON files in `data/` instead of markdown frontmatter for some sections). Migration tools don't exist because schemas are theme-specific, not standardized.

**How to avoid:**
1. Map frontmatter fields between themes before migrating content:
   - Document Blowfish fields used in your content
   - Document Hugo Resume expected fields
   - Create mapping table (e.g., Blowfish `description` → Hugo Resume `summary`)
2. Hugo Resume requires JSON data files (`data/skills.json`, `data/experience.json`) - decide if case studies should convert to this format or remain as markdown
3. Write a migration script or manually update frontmatter in batches
4. Test with 1-2 representative content files before migrating all content
5. Check if Hugo Resume supports standard Hugo fields (`title`, `date`, `description`) for fallback behavior

**Warning signs:**
- Theme documentation shows completely different frontmatter examples than your content
- Content renders but with missing sections or incorrect layout
- Theme expects data files (`.json`, `.yaml`) but your content is in markdown frontmatter
- Preview shows "undefined" or blank spaces where content should appear

**Phase to address:**
Phase 2 (Content Structure Mapping) - Must happen after theme setup, before bulk content migration.

**Sources:**
- [Hugo Front matter documentation](https://gohugo.io/content-management/front-matter/)
- [Hugo Resume theme GitHub](https://github.com/eddiewebb/hugo-resume) (mentions no `posts` folder support, requires `blog` instead)
- [Schema/data incompatibility in theme migration](https://www.jeffgeerling.com/blog/2026/migrated-to-hugo/)

---

### Pitfall 3: Hugo Modules Cleanup Failure

**What goes wrong:**
Attempting to remove Blowfish (installed as Hugo module) while switching to Hugo Resume (traditional install) results in Hugo trying to fetch both themes, build failures, or the old theme's templates still being used. Running `hugo` attempts to download missing modules, fails with network errors, or silently uses cached Blowfish templates.

**Why it happens:**
Hugo modules leave artifacts in `go.mod`, `go.sum`, and module cache (`$TMPDIR/hugo_cache/modules`). Simply changing the theme in config isn't enough - Hugo still sees module imports. Developers expect changing `theme = "hugo-resume"` to be sufficient, but Hugo's module system requires explicit cleanup steps.

**How to avoid:**
1. **Complete cleanup sequence:**
   ```bash
   # Remove module config from hugo.toml
   # Delete [module] section entirely

   # Clean module cache
   hugo mod clean --all

   # Remove module files
   rm go.mod go.sum

   # Initialize fresh (if staying with modules)
   # hugo mod init github.com/username/repo
   ```
2. Verify `config/_default/hugo.toml` has no `[module]` or `module.imports` sections
3. Check that `themes/` directory is empty (modules don't use this)
4. After cleanup, install Hugo Resume traditionally (not as module) to avoid confusion
5. Test with `hugo server --disableFastRender` to force full rebuild

**Warning signs:**
- `hugo server` shows "downloading modules" despite changing theme
- Build errors mentioning Blowfish paths when Hugo Resume should be active
- `hugo mod graph` still shows Blowfish module
- Local preview shows mix of old/new theme elements
- CI/CD builds fail with "module not found" errors

**Phase to address:**
Phase 1 (Theme Setup & Configuration) - Critical blocker before installing new theme.

**Sources:**
- [hugo mod clean command documentation](https://gohugo.io/commands/hugo_mod_clean/)
- [Hugo Theme Change blog post](https://andrewfitzy.github.io/posts/hugo-theme-change/)
- [Managing Hugo themes with modules](https://discourse.gohugo.io/t/managing-hugo-themes-with-modules-for-new-those-new-to-hugo/47799)

---

### Pitfall 4: GitHub Pages Deployment Breakage

**What goes wrong:**
After successful local migration, site deploys to GitHub Pages but shows only unstyled HTML. CSS, JavaScript, and images return 404 errors. The site builds in CI/CD without errors but is broken in production. This happens even though `publishDir = "docs"` is configured and worked with the old theme.

**Why it happens:**
Asset paths in Hugo themes often assume root-level deployment. When deploying to GitHub Pages with a custom domain vs. `username.github.io/repo-name`, themes may generate different asset URLs. Additionally:
- Some themes use relative URLs (`/css/style.css`) that break with baseURL subpaths
- Build process might output to `public/` instead of `docs/` if config isn't fully migrated
- New theme might require Hugo extended version but CI uses standard version
- GitHub Pages caches old site structure, serving stale 404s

**How to avoid:**
1. **Verify config consistency:**
   ```toml
   baseURL = "https://yourdomain.com/"  # Or "https://username.github.io/" for root deployment
   publishDir = "docs"  # Must match GitHub Pages source setting
   ```
2. **Test actual deployment structure:**
   - Run `hugo` (not `hugo server`) locally
   - Check `docs/` directory structure matches expectations
   - Verify asset paths in `docs/index.html` are correct for your baseURL
3. **CI/CD requirements:**
   - Ensure GitHub Actions workflow uses Hugo extended if theme requires it
   - Pin Hugo version to match local environment
   - Add `--gc --minify` flags if theme expects minified assets
4. **Clear GitHub Pages cache:**
   - Push an empty commit after fixing asset paths
   - Check "Pages" settings in GitHub repo to verify source is still `docs/` folder
5. **Local production simulation:**
   - Build with `hugo --baseURL "https://your-actual-domain.com/"`
   - Serve `docs/` directory with simple HTTP server to test paths

**Warning signs:**
- Local `hugo server` works but `hugo` build → opening `docs/index.html` shows unstyled page
- Browser DevTools shows 404s for `/css/`, `/js/`, `/images/` with incorrect paths
- GitHub Actions build succeeds but deployed site is broken
- Asset URLs in HTML source show wrong domain or missing path segments
- Theme documentation mentions "extended" version requirement but you're using standard Hugo

**Phase to address:**
Phase 3 (Deployment Verification) - Test deployment structure before pushing to production. Should have smoke tests for asset loading.

**Sources:**
- [Hugo Hosting on GitHub Pages](https://bwaycer.github.io/hugo_tutorial.hugo/tutorials/github-pages-blog/)
- [Deployed Hugo on GitHub pages, theme & images are missing](https://discourse.gohugo.io/t/deployed-hugo-on-github-pages-theme-images-are-missing/53986)
- [Hugo baseURL issues on GitHub Pages](https://discourse.gohugo.io/t/baseurl-not-updating-to-hugo-toml-value/53708)

---

### Pitfall 5: Layout Override Conflicts

**What goes wrong:**
Custom layout overrides from Blowfish theme (e.g., `layouts/_default/single.html`, `layouts/partials/head.html`) persist in the project after migration. These overrides were designed for Blowfish's template structure and break Hugo Resume's rendering. Pages render with corrupted layouts, missing sections, or cryptic template errors like "can't evaluate field X in type Y".

**Why it happens:**
Hugo's lookup order prioritizes project-level layouts over theme layouts. This is *intentional* for customization, but becomes a trap during migration. Developers forget they created overrides months ago. Hugo Resume expects its own template structure, but project overrides execute first, calling Blowfish-specific partials or using Blowfish-specific variables that don't exist in Hugo Resume.

**How to avoid:**
1. **Audit existing overrides before migration:**
   ```bash
   find layouts/ -type f -name "*.html"
   ```
2. **Temporarily move (don't delete) overrides:**
   ```bash
   mv layouts/ layouts.blowfish.backup/
   ```
3. **Test new theme without overrides first** - Establish baseline behavior
4. **Reintroduce overrides selectively:**
   - Only restore overrides that are truly theme-agnostic
   - Rewrite theme-specific overrides for Hugo Resume
   - Consider if override is still needed (theme might have built-in solution)
5. **Document why each override exists** - Future migrations will thank you

**Warning signs:**
- Template execution errors mentioning missing partials (e.g., `partial "blowfish/article-meta.html" not found`)
- Partial rendering of pages - headers work but content section is blank
- Hugo error logs show "can't evaluate field" or "nil pointer" in templates
- New theme preview looks nothing like theme demo (overrides hijacking render)
- Mix of old theme styling and new theme styling on same page

**Phase to address:**
Phase 1 (Theme Setup & Configuration) - Clean slate check before installing new theme. Critical for preventing mysterious template errors.

**Sources:**
- [Hugo Themes - How to Use and Customize](https://tangenttechnologies.ca/blog/hugo-themes/)
- [Hugo - Customizing a Theme](https://bwaycer.github.io/hugo_tutorial.hugo/themes/customizing/)
- [Template lookup order documentation](https://gohugo.io/templates/lookup-order/)

---

## Moderate Pitfalls

### Pitfall 6: Data File Structure Mismatch

**What goes wrong:**
Hugo Resume theme expects structured data in JSON files (`data/skills.json`, `data/experience.json`) while current Blowfish content may use different formats (YAML in frontmatter, separate markdown files). Migration requires restructuring data that's scattered across multiple files.

**How to avoid:**
1. Review Hugo Resume's `data/` directory requirements in theme documentation
2. Extract data from existing content structure (frontmatter, separate files)
3. Create JSON schema matching theme expectations
4. Use a script to automate data extraction/transformation if content volume is high
5. Validate JSON files before testing theme (syntax errors cause silent failures)

**Warning signs:**
- Sections render empty despite having content
- Theme demo shows skills/experience but yours doesn't
- Console errors about missing data files
- JSON syntax errors in build output

**Phase to address:**
Phase 2 (Content Structure Mapping) - Happens alongside frontmatter migration. Can be partially automated.

---

### Pitfall 7: Navigation/Menu Configuration Differences

**What goes wrong:**
Blowfish's menu structure (defined in `config/_default/menus.en.toml`) uses different menu identifiers than Hugo Resume. Navigation breaks or shows wrong links after migration. Main menu might disappear entirely.

**How to avoid:**
1. Compare menu structure in both themes' documentation
2. Check Hugo Resume's expected menu identifiers (`main`, `footer`, etc.)
3. Update menu configuration to match new theme's expectations
4. Test all navigation links after migration (automated link checker helpful)
5. Verify mobile navigation works (often separate template/config)

**Warning signs:**
- Navigation renders but links point to wrong pages
- Menu items appear in wrong order or wrong menu
- Dropdown/nested menus don't work despite being configured
- Menu renders on desktop but not mobile (or vice versa)

**Phase to address:**
Phase 2 (Content Structure Mapping) - After basic theme setup, before content migration.

---

### Pitfall 8: Asset Pipeline Differences (Hugo Pipes)

**What goes wrong:**
Blowfish uses Hugo Pipes for asset processing (SCSS compilation, minification, fingerprinting). Hugo Resume might use a simpler approach or require different asset organization. Pre-processed assets from Blowfish might not work with new theme.

**How to avoid:**
1. Check if Hugo Resume requires Hugo Extended (for SCSS processing)
2. Review how theme loads assets (Pipes vs. static files)
3. Verify `resources/` directory is cleared (cached Pipes output)
4. Test asset changes reflect in preview (indicates Pipes working)
5. Check browser for correct asset fingerprints in production (cache busting)

**Warning signs:**
- CSS changes don't appear despite rebuilding
- Assets have no fingerprints/cache busting in production
- SCSS compilation errors in build output
- `resources/` directory accumulates stale files

**Phase to address:**
Phase 1 (Theme Setup & Configuration) - Foundational requirement, affects all asset handling.

---

### Pitfall 9: Shortcode Incompatibility

**What goes wrong:**
Custom shortcodes used in Blowfish content (e.g., `{{< alert >}}`, `{{< gallery >}}`) don't exist in Hugo Resume. Content with shortcodes renders broken HTML or shows raw shortcode syntax.

**How to avoid:**
1. Audit content for shortcode usage:
   ```bash
   grep -r "{{<" content/
   ```
2. Check which shortcodes are Blowfish-specific vs. built-in Hugo shortcodes
3. Options for each shortcode:
   - Port shortcode to new theme (copy to `layouts/shortcodes/`)
   - Rewrite content using Hugo Resume's shortcodes
   - Replace with standard HTML/markdown
4. Test content rendering for shortcode-heavy pages

**Warning signs:**
- Literal `{{< shortcode >}}` text appears on rendered pages
- Broken HTML structure where shortcodes were used
- Build warnings about unknown shortcodes
- Pages with special formatting now look plain

**Phase to address:**
Phase 2 (Content Structure Mapping) - Identify before bulk content migration. May require Phase 4 (Custom Shortcode Migration) if many custom shortcodes exist.

---

### Pitfall 10: SEO Metadata Loss

**What goes wrong:**
SEO-related frontmatter fields (Open Graph, Twitter Cards, structured data) configured for Blowfish don't transfer to Hugo Resume. Search engines and social media previews break. Existing search rankings may suffer if metadata significantly degrades.

**How to avoid:**
1. Compare SEO metadata implementation in both themes
2. Check Hugo Resume's support for:
   - Open Graph tags
   - Twitter Card tags
   - JSON-LD structured data
   - Meta descriptions and keywords
3. Create fallback metadata in config if theme lacks per-page support
4. Test with social media debuggers (Facebook, Twitter, LinkedIn)
5. Use Google's Rich Results Test for structured data validation

**Warning signs:**
- Social media preview shows generic/missing images
- Meta description in page source is default/missing
- Google Search Console shows structured data errors
- Link previews on Slack/Discord show broken formatting

**Phase to address:**
Phase 2 (Content Structure Mapping) - Critical for maintaining search visibility. Should verify SEO metadata in sample pages before full migration.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Copy all Blowfish layouts to project | Old site keeps working | Future theme updates impossible; migration never truly completes | Never - defeats purpose of migration |
| Inline CSS in layout files | Quick fix for styling issues | Unmaintainable CSS scattered across templates; hard to update | Only for tiny theme-specific tweaks (<10 lines) |
| Skip frontmatter migration | Faster initial migration | Content doesn't render properly; SEO breaks; manual fixes later | Never for production migration |
| Keep both themes installed | Gradual migration possible | Confusion about which theme is active; bloated repo; slow builds | Only during development/testing phase |
| Disable Hugo Modules without cleanup | Theme switches immediately | Go.mod conflicts; mysterious build issues; cache bloat | Never - cleanup is quick and prevents future pain |
| Use `--ignoreCache` permanently | Fixes weird caching issues | Much slower builds; masks underlying config problems | Only for debugging, never in CI/CD |
| Hard-code asset paths | Assets load in production | Breaks local development; prevents CDN use; fragile to URL changes | Never - use relURL/absURL |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Google Analytics | Hard-coding GA script in custom partial | Use Hugo's built-in analytics config in hugo.toml; check theme's analytics support |
| Comments (Disqus, Giscus) | Copying old theme's comment partial | Check Hugo Resume docs for comment system integration; use theme's built-in support if available |
| Search functionality | Assuming search "just works" | Hugo Resume has client-side search (fuse.js) but theme doesn't link to `/search` - must add manually |
| Custom fonts | Loading fonts via CDN in custom CSS | Check if theme has font configuration in config; self-host in `static/fonts/` to avoid GDPR issues |
| Syntax highlighting | Relying on Blowfish's highlight.js setup | Verify Hugo Resume's syntax highlighting approach (Chroma vs. client-side); may need config changes |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Unoptimized images in `static/` | Slow page loads; large docs/ output | Use Hugo's image processing (`resources.Get` + `.Resize`) in theme partials | >10 high-res images per page |
| No asset fingerprinting | Browser caches old CSS/JS after updates | Verify theme uses `resources.Fingerprint` for assets; check Hugo Pipes enabled | After first CSS update in production |
| Rebuilding all content on every change | Slow `hugo server` after migration | Use `--disableFastRender` only for debugging; ensure content frontmatter is valid | >100 content files |
| Large `resources/` cache | Slow builds; repo bloat | Add `resources/` to `.gitignore`; run `hugo --gc` periodically | After multiple theme iterations |
| Not minifying HTML/CSS/JS in production | Slower page loads; higher bandwidth | Add `--minify` to production build command; verify CI/CD uses it | Site-wide; affects all users |

## "Looks Done But Isn't" Checklist

- [ ] **Custom CSS**: Theme loads it? Verify DevTools shows custom styles, not just theme defaults
- [ ] **Frontmatter fields**: All content metadata displays? Check dates, descriptions, tags render
- [ ] **Asset paths**: All images/files load in production? Test `docs/` build, not just `hugo server`
- [ ] **Navigation**: All menu links work? Click every link, check mobile menu
- [ ] **SEO metadata**: Open Graph tags present? Test with social media debuggers
- [ ] **Syntax highlighting**: Code blocks styled? View a post with code samples
- [ ] **Dark mode**: Works if theme supports it? Toggle and verify all elements adapt
- [ ] **RSS feed**: Generated and valid? Check `/index.xml` or `/feed.xml`
- [ ] **Sitemap**: Generated and accurate? Check `/sitemap.xml` includes all pages
- [ ] **404 page**: Custom or generic? Test non-existent URL shows branded error page
- [ ] **Mobile responsiveness**: Layout adapts? Test on actual mobile device, not just DevTools
- [ ] **Search functionality**: Works if theme has it? Hugo Resume has search at `/search` but no UI link
- [ ] **Comments**: Load if enabled? Check comment system appears and functions
- [ ] **Analytics**: Tracking code present? Verify in page source and analytics dashboard
- [ ] **Performance**: Lighthouse score acceptable? Run audit, check for unoptimized assets

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Custom CSS lost | LOW | 1. Create `layouts/partials/extend-head.html` in project<br>2. Add `<link rel="stylesheet" href="{{ "css/custom.css" | relURL }}">`<br>3. Verify theme loads custom partials |
| Frontmatter incompatible | MEDIUM | 1. Document field mapping between themes<br>2. Write Python/Node script to batch update frontmatter<br>3. Test with sample files before bulk migration |
| Hugo Modules conflict | LOW | 1. Run `hugo mod clean --all`<br>2. Delete `go.mod` and `go.sum`<br>3. Remove `[module]` from config<br>4. Rebuild with traditional theme install |
| Deployment broken | LOW-MEDIUM | 1. Verify `publishDir = "docs"` in config<br>2. Check `baseURL` matches actual domain<br>3. Test local build of `docs/` directory<br>4. Clear GitHub Pages cache with empty commit<br>5. Verify CI uses Hugo Extended if required |
| Layout overrides conflict | MEDIUM | 1. Move `layouts/` to backup<br>2. Test theme without overrides<br>3. Rewrite overrides for new theme structure<br>4. Document why each override is needed |
| Data files wrong format | MEDIUM | 1. Create JSON schema matching theme expectations<br>2. Extract data from old content structure<br>3. Write conversion script<br>4. Validate JSON syntax |
| Shortcodes broken | MEDIUM | 1. Grep content for shortcode usage<br>2. Port critical shortcodes to `layouts/shortcodes/`<br>3. Rewrite content for less critical ones<br>4. Test shortcode-heavy pages |
| SEO metadata lost | HIGH | 1. Compare SEO implementation in both themes<br>2. Add fallback metadata in config<br>3. Test with social debuggers<br>4. Update sitemap/robots.txt if needed<br>5. Monitor Search Console for errors |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Custom CSS lost | Phase 1: Theme Setup | DevTools shows custom styles loaded; visual inspection matches old site |
| Content schema mismatch | Phase 2: Content Mapping | Sample content renders with all metadata; no "undefined" fields |
| Hugo Modules cleanup failure | Phase 1: Theme Setup | `hugo mod graph` shows only new theme; no Blowfish references |
| GitHub Pages deployment breakage | Phase 3: Deployment | Production site loads assets; Lighthouse runs successfully |
| Layout override conflicts | Phase 1: Theme Setup | No template execution errors; pages render like theme demo |
| Data file structure mismatch | Phase 2: Content Mapping | Skills/experience sections populate; no empty sections |
| Navigation configuration differences | Phase 2: Content Mapping | All menu links clickable and correct; mobile menu works |
| Asset pipeline differences | Phase 1: Theme Setup | CSS changes reflect immediately; fingerprints in production |
| Shortcode incompatibility | Phase 2: Content Mapping | No raw shortcode syntax in rendered content |
| SEO metadata loss | Phase 2: Content Mapping | Social media previews render correctly; structured data validates |

## Sources

### Official Hugo Documentation
- [Hugo Front matter](https://gohugo.io/content-management/front-matter/)
- [hugo mod clean command](https://gohugo.io/commands/hugo_mod_clean/)
- [Hugo Modules](https://gohugo.io/commands/hugo_mod/)
- [Template lookup order](https://gohugo.io/templates/lookup-order/)

### Hugo Theme Migration Experiences
- [JeffGeerling.com Migrated to Hugo (2026)](https://www.jeffgeerling.com/blog/2026/migrated-to-hugo/)
- [Hugo Theme Change blog post](https://andrewfitzy.github.io/posts/hugo-theme-change/)
- [Some notes on upgrading Hugo](https://jvns.ca/blog/2024/10/07/some-notes-on-upgrading-hugo/)

### Community Discussions & Gotchas
- [Most common Hugo pitfalls and their solutions](https://geo.rocks/post/hugotricks/)
- [Hugo Discourse: Deployed Hugo on GitHub Pages, theme & images missing](https://discourse.gohugo.io/t/deployed-hugo-on-github-pages-theme-images-are-missing/53986)
- [Hugo Discourse: Managing Hugo themes with modules](https://discourse.gohugo.io/t/managing-hugo-themes-with-modules-for-new-those-new-to-hugo/47799)
- [Hugo Discourse: baseURL not updating](https://discourse.gohugo.io/t/baseurl-not-updating-to-hugo-toml-value/53708)

### Theme-Specific Documentation
- [Blowfish Advanced Customisation](https://blowfish.page/docs/advanced-customisation/)
- [Hugo Resume theme GitHub](https://github.com/eddiewebb/hugo-resume)
- [Hugo Resume theme demo site](https://themes.gohugo.io/themes/hugo-resume/)

### Asset & Styling Management
- [Styling your Hugo website](https://www.brycewray.com/posts/2023/03/styling-hugo-site/)
- [Hugo Themes - How to Use and Customize](https://tangenttechnologies.ca/blog/hugo-themes/)
- [How to add custom CSS with Hugo modules](https://github.com/hugo-themes/toha/discussions/832)
- [Hugo - Customizing a Theme](https://bwaycer.github.io/hugo_tutorial.hugo/themes/customizing/)

### Deployment & GitHub Pages
- [Hugo Hosting on GitHub Pages](https://bwaycer.github.io/hugo_tutorial.hugo/tutorials/github-pages-blog/)
- [Hugo Discourse: Hugo styles not showing on GitHub Pages](https://discourse.gohugo.io/t/hugo-styles-not-showing-up-on-github-pages-though-it-loads-locally-issue-seems-not-due-to-baseurl/49245)

---
*Pitfalls research for: Hugo theme migration (Blowfish → Hugo Resume)*
*Researched: 2026-02-04*
*Confidence: MEDIUM - Based on Hugo community documentation and theme-specific sources. Hugo Resume theme has limited recent documentation; some assumptions based on general Hugo patterns.*
