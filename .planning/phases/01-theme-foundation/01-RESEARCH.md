# Phase 1: Theme Foundation - Research

**Researched:** 2026-02-04
**Domain:** Hugo theme migration and module management
**Confidence:** HIGH

## Summary

Hugo Resume theme (eddiewebb/hugo-resume) is a Bootstrap-based single-page resume template with left-hand navigation and auto-scrolling sections. Installation requires Hugo Modules setup, theme import via config, and migration of content from Blowfish's multi-page structure to Hugo Resume's single-page data-driven approach.

The critical difference between Blowfish and Hugo Resume is content architecture: Blowfish uses markdown files in content/ directories with frontmatter, while Hugo Resume uses JSON data files (experience.json, skills.json, education.json) plus content/_index.md for biography. This is not a simple theme swap — it requires content restructuring.

Theme removal is straightforward using Hugo's module system: update module.toml imports, run hugo mod tidy to clean go.mod/go.sum, then verify with hugo mod graph. The validation gate is visual: does the single-page layout support senior leadership positioning (scope/impact visibility) or does it feel like an entry-level template?

**Primary recommendation:** Use Hugo Modules for theme installation (not git submodules), preserve Blowfish config files as backup before migration, and validate theme fit with minimal content before committing to Phase 2 styling work.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Hugo | 0.154.3+ extended | Static site generator | Current version used in project, extended required for SCSS |
| Hugo Resume theme | master branch | Single-page resume template | MIT licensed, actively maintained, Bootstrap-based |
| Hugo Modules | Go 1.25.5+ | Theme dependency management | Official Hugo method, replaces git submodules |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Bootstrap | (via theme) | Responsive framework | Built into Hugo Resume theme |
| Fuse.js | (via theme) | Client-side search | Included in theme for /search endpoint |
| Font Awesome | (via theme) | Social icons | Dev icons and social handles |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Hugo Resume (eddiewebb) | Modern Hugo Resume (cjshearer) | More modern, but requires Nix tooling |
| Hugo Resume | Hugo DevResume | Developer-focused branding vs general professional |
| Hugo Modules | Git submodules | Submodules older method, modules easier to update |

**Installation:**
```bash
# Initialize Hugo modules (if not already done)
hugo mod init github.com/athan-dial/athan-dial.github.io

# Theme installed via module.toml imports, not manual install
# Dependencies resolved automatically with: hugo mod get
```

## Architecture Patterns

### Hugo Resume Content Structure
```
content/
└── _index.md           # Biography/summary section

data/
├── experience.json     # Work history with company, role, dates
├── education.json      # Degrees and certifications
└── skills.json         # Skills inventory for homepage

creations/              # Projects you originated
└── project-name.md

contributions/          # Projects you collaborated on
└── project-name.md

publications/           # Papers, talks, articles
└── publication-name.md

blog/                   # Blog posts (not posts/)
└── post-name.md
```

### Current Blowfish Structure (to migrate from)
```
content/
├── _index.md           # Homepage
├── about.md
├── resume.md
├── consulting.md
├── writing.md
└── case-studies/       # Multiple markdown files
    ├── study1.md
    └── study2.md
```

### Pattern 1: Hugo Modules Theme Installation
**What:** Modern Hugo approach using Go modules instead of git submodules
**When to use:** All new Hugo sites, theme replacements
**Example:**
```toml
# config/_default/module.toml
[[imports]]
  path = "github.com/eddiewebb/hugo-resume"

# Then run:
# hugo mod get
# hugo mod tidy
```
**Source:** https://gohugo.io/hugo-modules/use-modules/

### Pattern 2: Config Migration Strategy
**What:** Copy example config, manually port settings (don't blindly replace)
**When to use:** Theme changes with different configuration schemas
**Example:**
```bash
# 1. Backup current config
cp config/_default/hugo.toml config/_default/hugo.toml.blowfish.bak

# 2. Copy theme example config
# (from theme exampleSite/config.toml)

# 3. Manually port these settings:
# - baseURL (keep existing)
# - publishDir (keep "docs" for GitHub Pages)
# - title, languageCode
# - Author/contact params (from languages.en.toml)
```
**Source:** https://discourse.gohugo.io/t/migrate-hugo-theme/46140

### Pattern 3: Module Cleanup Workflow
**What:** Proper sequence to remove old theme and verify new one
**When to use:** Every theme replacement
**Example:**
```bash
# 1. Update module.toml (remove Blowfish, add Hugo Resume)
# 2. Clean module cache
hugo mod clean

# 3. Tidy dependencies (removes Blowfish from go.mod/go.sum)
hugo mod tidy

# 4. Verify dependency graph
hugo mod graph

# 5. Download new theme
hugo mod get

# 6. Test locally
hugo server
```
**Source:** https://gohugo.io/commands/hugo_mod_clean/

### Anti-Patterns to Avoid
- **Don't blindly replace config files:** Theme schemas differ; manually port settings to avoid losing baseURL, publishDir, etc.
- **Don't skip hugo mod tidy:** Leaving old theme references in go.mod causes module resolution errors
- **Don't assume data schema compatibility:** Blowfish uses frontmatter in markdown, Hugo Resume uses JSON data files — content must be restructured, not just copied
- **Don't test with hugo build first:** Always test with hugo server -D to catch rendering errors before building to docs/

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Theme dependency management | Manual theme updates via git clone | Hugo Modules (hugo mod get) | Handles transitive dependencies, version pinning, and updates automatically |
| Config file merging | Shell scripts to merge TOML files | Manual review and porting | Theme config schemas are unique; automated merging breaks site |
| Module cleanup | Manual deletion of go.mod entries | hugo mod tidy command | Ensures checksums in go.sum match, removes orphaned dependencies |
| Theme validation | Custom scripts to check theme loaded | hugo mod graph + visual inspection | Official command shows dependency tree, visual check confirms rendering |

**Key insight:** Hugo Modules is the official dependency system and handles edge cases (transitive dependencies, version conflicts, cache invalidation) that manual approaches miss. Don't reinvent it.

## Common Pitfalls

### Pitfall 1: Content Schema Mismatch
**What goes wrong:** Copy Blowfish content/ files to Hugo Resume site, theme doesn't render work history or skills
**Why it happens:** Hugo Resume expects JSON files in data/ directory (experience.json, skills.json), not markdown frontmatter
**How to avoid:** Review theme's exampleSite/ directory to understand required data schema before migrating content
**Warning signs:** Hugo server runs without errors but sections are empty; no work experience or skills display

### Pitfall 2: Module Import Location Conflict
**What goes wrong:** Theme imported in both hugo.toml and module.toml, causing "module already imported" errors
**Why it happens:** Hugo supports multiple config methods; using both creates conflicts
**How to avoid:** Use ONLY module.toml for theme imports (recommended), not theme = "name" in hugo.toml
**Warning signs:** hugo mod graph shows duplicate entries; build fails with module resolution errors

### Pitfall 3: Incomplete Blowfish Removal
**What goes wrong:** Hugo Resume theme installed but Blowfish CSS/layouts still render
**Why it happens:** Blowfish reference remains in go.mod even after removing from module.toml
**How to avoid:** Run hugo mod tidy after updating module.toml to clean go.mod/go.sum
**Warning signs:** hugo mod graph shows Blowfish still listed; page source shows Blowfish CSS links

### Pitfall 4: baseURL and publishDir Reset
**What goes wrong:** Site builds to public/ instead of docs/, breaks GitHub Pages deployment
**Why it happens:** Copying example config.toml from theme resets these critical settings
**How to avoid:** Manually port config settings; never wholesale replace hugo.toml
**Warning signs:** docs/ directory not updated after hugo build; GitHub Pages shows 404

### Pitfall 5: Hugo Version Incompatibility
**What goes wrong:** Theme renders locally but breaks on GitHub Pages deployment
**Why it happens:** Local Hugo version differs from GitHub Actions version; theme requires features from newer Hugo
**How to avoid:** Check theme's minimum Hugo version requirement; pin Hugo version in deployment workflow if needed
**Warning signs:** hugo server works locally, but GitHub Actions build fails with template errors

### Pitfall 6: Blog Content Directory Mismatch
**What goes wrong:** Blog posts in posts/ directory don't appear on Hugo Resume site
**Why it happens:** Hugo Resume theme expects blog/ directory, not posts/
**How to avoid:** Review theme documentation for expected directory names
**Warning signs:** Blog posts exist but don't render; no blog section on site

## Code Examples

Verified patterns from official sources:

### Installing Theme via Hugo Modules
```bash
# Source: https://gohugo.io/hugo-modules/use-modules/

# 1. Initialize module (if not already done)
hugo mod init github.com/athan-dial/athan-dial.github.io

# 2. Create/update config/_default/module.toml
cat > config/_default/module.toml << 'EOF'
[[imports]]
  path = "github.com/eddiewebb/hugo-resume"
EOF

# 3. Download theme
hugo mod get

# 4. Verify installation
hugo mod graph
# Should show: github.com/athan-dial/athan-dial.github.io github.com/eddiewebb/hugo-resume@<version>
```

### Removing Old Theme (Blowfish)
```bash
# Source: https://gohugo.io/commands/hugo_mod_clean/

# 1. Update module.toml (remove Blowfish import)
# [[imports]]
#   path = "github.com/nunocoracao/blowfish/v2"  # DELETE THIS

# 2. Clean module cache
hugo mod clean

# 3. Remove from go.mod/go.sum
hugo mod tidy

# 4. Verify removal
hugo mod graph
# Should NOT show: github.com/nunocoracao/blowfish/v2
```

### Config Migration Template
```toml
# Source: https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/config.toml

# Preserve from Blowfish config:
baseURL = "https://athan-dial.github.io/"  # KEEP THIS
publishDir = "docs"                         # KEEP THIS
languageCode = "en-us"
defaultContentLanguage = "en"
enableRobotsTXT = true

# Hugo Resume specific:
title = "Athan Dial"
PygmentsCodeFences = true
PygmentsCodeFencesGuessSyntax = true
PygmentsStyle = "monokai"

[params]
  firstName = "Athan"
  lastName = "Dial"
  address = "Location"
  email = "email@example.com"
  phone = "555-555-5555"
  profileImage = "img/profile.jpg"
  favicon = "/favicon.ico"
  showQr = false
  showContact = true

[[params.handles]]
  name = "LinkedIn"
  link = "https://www.linkedin.com/in/example/"

[[params.handles]]
  name = "GitHub"
  link = "https://github.com/example"
```

### Verification Commands
```bash
# Source: https://gohugo.io/commands/hugo_mod/

# Check dependency graph (should show only Hugo Resume)
hugo mod graph

# Start local server with drafts
hugo server -D

# Check page source for theme CSS
curl http://localhost:1313/ | grep -i "blowfish\|resume"
# Should see "resume" references, NOT "blowfish"

# Build to docs/ for GitHub Pages
hugo
ls -la docs/
# Verify docs/ directory updated with fresh build
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Git submodules for themes | Hugo Modules | Hugo 0.56+ (2019) | Easier updates, dependency resolution, no git submodule complexity |
| theme = "name" in hugo.toml | [[imports]] in module.toml | Hugo 0.56+ (2019) | Cleaner separation, supports multiple module imports |
| Manual config merging | Copy example + manual port | Always recommended | Prevents accidental loss of critical settings like baseURL, publishDir |
| Centralized config.toml | Split config in config/_default/ | Hugo 0.53+ (2018) | Better organization for complex sites |

**Deprecated/outdated:**
- **Git submodules:** Still works but Hugo Modules is now recommended approach
- **Single config.toml file:** Works but config/_default/ directory structure is modern practice
- **theme = "name" syntax:** Still supported but module.toml imports are preferred

## Open Questions

Things that couldn't be fully resolved:

1. **Hugo Resume minimum version requirement**
   - What we know: Theme uses Bootstrap framework, Fuse.js search, standard Hugo features
   - What's unclear: No explicit minimum Hugo version in theme.toml or README
   - Recommendation: Test with current Hugo 0.154.3; if errors occur, check theme issues for version requirements

2. **Single-page layout suitability for senior leadership positioning**
   - What we know: Hugo Resume is single-page with auto-scrolling sections; content is displayed vertically
   - What's unclear: Whether single-page format allows sufficient depth for senior leader scope/impact (team size, budget, multi-year outcomes)
   - Recommendation: This is the Phase 1 validation gate — install theme with minimal content, assess if layout supports positioning, decide go/no-go for Phase 2

3. **Case studies integration path**
   - What we know: Hugo Resume supports creations/ and contributions/ for projects; blog/ for posts
   - What's unclear: Whether case studies should map to projects or blog posts, and if single-page layout can surface them effectively
   - Recommendation: Deferred to v2 per CONTEXT.md; Phase 1 focuses only on resume working

4. **Custom CSS preservation strategy**
   - What we know: Current site has 1200+ lines of custom.css overriding Blowfish
   - What's unclear: How much custom CSS is Blowfish-specific vs portable to Hugo Resume
   - Recommendation: Phase 2 problem; Phase 1 accepts default Hugo Resume styling

## Sources

### Primary (HIGH confidence)
- Hugo Modules documentation: https://gohugo.io/hugo-modules/use-modules/
- Hugo Module commands: https://gohugo.io/commands/hugo_mod/
- Hugo Resume theme repository: https://github.com/eddiewebb/hugo-resume
- Hugo Resume example config: https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/config.toml
- Hugo Modules cleanup: https://gohugo.io/commands/hugo_mod_clean/

### Secondary (MEDIUM confidence)
- Hugo Discourse on theme migration: https://discourse.gohugo.io/t/migrate-hugo-theme/46140
- Hugo Discourse on module best practices: https://discourse.gohugo.io/t/best-practices-for-theme-development-hugo-modules/30568
- Hugo Blox update guide: https://docs.hugoblox.com/reference/update/
- Nick Gracilla's Hugo Modules guide: https://www.nickgracilla.com/posts/master-hugo-modules-managing-themes-as-modules/

### Tertiary (LOW confidence)
- Hugo Resume themes comparison: https://gethugothemes.com/hugo-portfolio-themes
- Theme rendering troubleshooting: https://discourse.gohugo.io/t/solved-new-theme-not-rendering/13319

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Hugo Modules and Hugo Resume theme are well-documented with official sources
- Architecture: HIGH - Theme structure verified from official repository and Hugo documentation
- Pitfalls: HIGH - Common issues documented in Hugo Discourse with official solutions
- Validation: MEDIUM - Visual assessment criteria are subjective; "acceptable" threshold requires human judgment
- Content migration: MEDIUM - Data schema differences are clear, but specific mapping for case studies unclear

**Research date:** 2026-02-04
**Valid until:** 2026-03-04 (30 days - Hugo and theme are stable, unlikely to change rapidly)

## Additional Notes

**Critical context from CONTEXT.md:**
- This is a validation phase — not content population or full styling
- Acceptance threshold is "not embarrassing" not "production ready"
- Go/No-Go gate: proceed to Phase 2 only if single-page layout supports senior leadership positioning
- Case studies explicitly deferred to v2
- Full CSS port deferred to Phase 2

**User decisions that constrain planning:**
- Technical approach to Blowfish removal is Claude's discretion (recommend: backup customizations before cleaning)
- Config migration details are Claude's discretion (recommend: manual port, not wholesale replace)
- Verification approach is Claude's discretion (recommend: hugo mod graph + visual inspection + curl page source)
