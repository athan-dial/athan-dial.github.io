# Codebase Structure

**Analysis Date:** 2026-02-04

## Directory Layout

```
athan-dial.github.io/
├── config/                 # Hugo configuration for site and theme
│   └── _default/
│       ├── hugo.toml       # Main Hugo settings, baseURL, publishDir
│       ├── params.toml     # Blowfish theme parameters
│       ├── languages.en.toml  # Site metadata, author info
│       ├── menus.en.toml   # Navigation menu structure
│       ├── module.toml     # Hugo modules dependencies
│       └── markup.toml     # Markdown rendering configuration
├── content/                # Markdown content files (source of truth)
│   ├── _index.md          # Homepage
│   ├── about.md           # About page
│   ├── advisory.md        # Advisory/consulting page
│   ├── consulting.md      # Consulting redirect (deprecated)
│   ├── resume.md          # Resume page
│   ├── writing.md         # Writing/resources page
│   └── case-studies/      # Case study articles
│       ├── _index.md      # Case studies overview and index
│       ├── scaling-ai-nominations-montai.md
│       ├── stat6-data-crisis-response-montai.md
│       ├── learning-agenda-framework-montai.md
│       ├── xtalpi-build-vs-buy-analysis-montai.md
│       ├── shiny-framework-standardization-montai.md
│       ├── preventing-metric-theater-drug-discovery-ml.md
│       └── reducing-pipeline-latency-decision-velocity.md
├── layouts/                # Hugo templates (override Blowfish defaults)
│   ├── case-studies/
│   │   └── list.html      # Grid template for case studies index
│   └── partials/          # Reusable components
│       ├── case-study-card.html         # Card component for gallery
│       ├── case-study-section.html      # Section component for detail pages
│       └── proof-tile.html              # Proof signal tile component
├── assets/                 # CSS, JavaScript (compiled to docs/)
│   └── css/
│       └── custom.css     # Complete design system, overrides theme
├── static/                 # Non-content assets (copied to docs/ as-is)
│   ├── fonts/             # Self-hosted TikTok Sans (and other fonts)
│   ├── images/            # Social, brand images
│   └── resume.pdf         # Resume PDF for download
├── resources/              # Cache directory (Hugo module resources)
├── docs/                   # Build output (GitHub Pages publishDir)
│   └── [compiled HTML, CSS, images]
├── go.mod                  # Hugo modules (Blowfish theme v2.96.0)
├── go.sum                  # Module dependencies hash
├── CLAUDE.md              # Claude Code instructions (context)
└── .planning/              # GSD planning documents
    └── codebase/           # Codebase analysis documents
        ├── ARCHITECTURE.md
        └── STRUCTURE.md
```

## Directory Purposes

**`config/_default/`:**
- Purpose: All Hugo and Blowfish theme configuration
- Contains: TOML configuration files
- Key files:
  - `hugo.toml` - Sets baseURL, publishDir (docs), build behavior
  - `params.toml` - Blowfish settings (layout, header style, article display)
  - `languages.en.toml` - Site title, description, author metadata
  - `menus.en.toml` - Navigation menu (Home, Decision Systems, Advisory, Resume, About)
- Notes: Changes here affect site-wide behavior and appearance

**`content/`:**
- Purpose: All content pages as markdown files
- Contains: `.md` files with YAML frontmatter metadata
- Key files:
  - `_index.md` - Homepage with title, description, proof signals section
  - `about.md`, `advisory.md`, `resume.md` - Standalone pages
  - `case-studies/` - Directory for all case study articles
- Convention: Single file per page; Hugo generates one HTML per markdown file
- Build behavior: Only markdown in `content/` is converted to pages

**`content/case-studies/`:**
- Purpose: Case study articles demonstrating decision frameworks
- Contains: Individual markdown files for each case study
- File naming: Hyphenated lowercase (`scaling-ai-nominations-montai.md`)
- Frontmatter structure (consistent across all case studies):
  ```
  ---
  title: "Human-readable title"
  date: 2023-06-01
  description: "One-sentence summary for card preview"
  problem_type: "product-strategy|technical-architecture|incident-response|etc"
  scope: "team|organization|individual"
  complexity: "high|medium|low"
  tags: ["tag1", "tag2", "tag3"]
  ---
  ```
- Content structure: Context → Ownership → Decision Frame → Outcome → Reflection
- Each case study renders to `docs/case-studies/[slug]/index.html`

**`layouts/`:**
- Purpose: Override and customize Blowfish theme templates
- Contains: HTML/Go templates for page structure
- Key files:
  - `case-studies/list.html` - Renders grid of case study cards
  - `partials/case-study-card.html` - Card component (accepts page object)
  - `partials/case-study-section.html` - Section component (accepts title, content)
  - `partials/proof-tile.html` - Proof tile component (rarely used via partial; mostly inline in homepage)
- Lookup order: Hugo checks `layouts/` first before falling back to Blowfish theme
- Notes: Most pages use Blowfish defaults; only case studies have custom templates

**`assets/css/`:**
- Purpose: Custom design system and CSS overrides
- Contains: Single `custom.css` file with all styling
- Hugo compiles to: `docs/css/main.bundle.min.[hash].css` (fingerprinted)
- Structure:
  - `:root` CSS variables for light mode (colors, typography, spacing)
  - `html.dark` CSS variables for dark mode
  - Component styles (proof tiles, case study cards, navigation)
  - Blowfish theme overrides (`!important` flags to ensure precedence)
- Notes:
  - All fonts use `!important` to force Inter/JetBrains Mono over theme defaults
  - Colors are Apple-inspired (blacks, grays, blues)
  - Spacing uses 8-point grid system (0.5rem base increment)
  - Border radius: 32px on large cards, 6px on tags, 980px on navigation pills

**`static/`:**
- Purpose: Static assets copied directly to build output
- Contains:
  - `fonts/` - Self-hosted TikTok Sans (custom.css imports from `/fonts/`)
  - `images/` - Social media images, brand assets
  - `resume.pdf` - Resume PDF (linked from resume.md)
- Behavior: Files in `static/` copy to `docs/` root during build (no processing)
- Notes: CSS references `/fonts/` (not `static/fonts/`) due to Hugo routing

**`resources/`:**
- Purpose: Hugo module cache and resource compilation
- Generated: Hugo creates automatically
- Committed: No (gitignore)
- Notes: Safe to delete; Hugo regenerates on next build

**`docs/`:**
- Purpose: Build output for GitHub Pages
- Generated: Hugo creates from `content/`, `layouts/`, `assets/`
- Committed: Yes (GitHub Pages publishes from this directory)
- Structure mirrors site hierarchy:
  - `docs/index.html` - Homepage
  - `docs/resume/index.html` - Resume page
  - `docs/case-studies/index.html` - Case studies grid
  - `docs/case-studies/[slug]/index.html` - Individual case studies
  - `docs/css/main.bundle.min.[hash].css` - Compiled custom CSS
  - `docs/images/`, `docs/fonts/` - Static assets
- Warning: Do NOT edit directly; regenerate with `hugo`

## Key File Locations

**Entry Points:**
- `content/_index.md` - Homepage rendering
- `layouts/partials/proof-tile.html` + inline HTML in `_index.md` - Proof signals section
- `config/_default/menus.en.toml` - Navigation menu

**Configuration:**
- `config/_default/hugo.toml` - Site baseURL (`https://athan-dial.github.io/`), publishDir (`docs`)
- `config/_default/params.toml` - Blowfish theme behavior (header layout, article display, search)
- `config/_default/languages.en.toml` - Site title, description, author metadata
- `go.mod` - Blowfish theme version (`v2.96.0`)

**Core Logic:**
- `layouts/case-studies/list.html` - Case study grid template (loops through pages, calls case-study-card partial)
- `layouts/partials/case-study-card.html` - Card rendering (extracts frontmatter, generates icons, creates tags)
- `assets/css/custom.css` - All styling (colors, typography, spacing, component styles)

**Content:**
- `content/case-studies/_index.md` - Case study overview and featured index
- `content/case-studies/*.md` - Individual case study articles
- `content/about.md`, `content/advisory.md`, `content/resume.md` - Standalone pages

**Build Output:**
- `docs/index.html` - Compiled homepage
- `docs/case-studies/index.html` - Compiled case studies grid
- `docs/css/main.bundle.min.[hash].css` - Compiled and minified CSS

## Naming Conventions

**Files:**
- Content markdown: lowercase with hyphens (`scaling-ai-nominations-montai.md`)
- Layout templates: lowercase with hyphens (`case-study-card.html`, `case-study-section.html`)
- CSS classes: BEM format with double underscore (`proof-tile`, `proof-tile__title`, `proof-tile__content`)
- Config files: lowercase with periods (`.toml` extension)

**Directories:**
- Hugo special directories: lowercase (`content`, `layouts`, `assets`, `static`, `config`)
- Subdirectories: lowercase, meaningful names (`case-studies`, `_default`, `partials`)
- Build output: `docs` (GitHub Pages convention)

**Frontmatter Fields:**
- Metadata keys: lowercase with hyphens (`problem_type`, `case_type`)
- Values: lowercase with hyphens (`product-strategy`, `technical-architecture`, `team`, `organization`)
- Tag format: lowercase with hyphens (`data-pipelines`, `ml-systems`, `decision-frameworks`)

## Where to Add New Code

**New Case Study:**
1. Create new markdown file: `content/case-studies/[name].md`
2. Use frontmatter template:
   ```markdown
   ---
   title: "Case Study Title"
   date: YYYY-MM-DD
   description: "One sentence summary for card preview"
   problem_type: "product-strategy|technical-architecture|incident-response|etc"
   scope: "team|organization|individual"
   complexity: "high|medium|low"
   tags: ["tag1", "tag2"]
   ---
   ```
3. Follow section structure: Context → Ownership → Decision Frame → Outcome → Reflection
4. Use markdown headers (## for sections)
5. Run `hugo server -D` to preview
6. Run `hugo` to build output to `docs/`

**New Standalone Page:**
1. Create new markdown file: `content/[page-name].md`
2. Add minimal frontmatter: `title`, `date`, `description`
3. Write content as markdown
4. Add to navigation: Update `config/_default/menus.en.toml` with [[main]] entry
5. Run `hugo server -D` to preview

**New Component/Partial:**
1. Create HTML file: `layouts/partials/[component-name].html`
2. Use Hugo template syntax with `.` context object
3. Include BEM class naming for styling
4. Call from templates: `{{ partial "component-name" . }}`
5. Add styles to `assets/css/custom.css` using `.component-name` and `.component-name__element` selectors

**New Styling:**
1. Edit `assets/css/custom.css`
2. Add CSS variables to `:root` and `html.dark` sections for color system consistency
3. Add component styles after base styles section
4. Use existing CSS variables: `var(--text-primary)`, `var(--accent-primary)`, `var(--space-lg)`, etc.
5. Test light and dark modes: `hugo server`, toggle theme in browser
6. Run `hugo` to compile CSS

**Updating Theme Configuration:**
1. Edit `config/_default/params.toml` for Blowfish-specific settings
2. Edit `config/_default/languages.en.toml` for site metadata
3. Edit `config/_default/menus.en.toml` for navigation menu
4. Run `hugo server` to preview changes

## Special Directories

**`.planning/codebase/`:**
- Purpose: GSD codebase analysis documents
- Generated: By `/gsd:map-codebase` command
- Committed: Yes (reference for future implementations)
- Files: ARCHITECTURE.md, STRUCTURE.md, STACK.md, etc.
- Notes: Should be updated when architecture or structure changes

**`_bmad/`:**
- Purpose: Agent workflow system (unrelated to Hugo portfolio)
- Status: Separate system, ignore for portfolio work
- Committed: Yes

**`_bmad-output/`:**
- Purpose: Generated output from _bmad workflows
- Status: Generated directory
- Committed: No (should be gitignored)

**`resources/`:**
- Purpose: Hugo module cache (internal)
- Generated: Hugo creates automatically
- Committed: No (should be gitignored)

---

*Structure analysis: 2026-02-04*
