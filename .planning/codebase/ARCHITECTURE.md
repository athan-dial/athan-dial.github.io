# Architecture

**Analysis Date:** 2026-02-04

## Pattern Overview

**Overall:** Static site generator with component-based layout system using Hugo (v0.154.3+extended) and Blowfish theme (v2.96.0).

**Key Characteristics:**
- Content-driven architecture: Markdown files with structured frontmatter define page metadata and relationships
- Theme override pattern: Custom CSS extensively overrides Blowfish defaults rather than extending through Hugo templating
- Component-based partials: Reusable layout components (`proof-tile`, `case-study-card`, `case-study-section`) composed on pages
- Taxonomic organization: Content organized by tags, categories, authors, and series for discovery and filtering
- GitHub Pages deployment: Built output publishes to `docs/` directory on `gh-pages` branch

## Layers

**Content Layer:**
- Purpose: Define pages, case studies, and metadata
- Location: `content/`
- Contains: Markdown files with YAML frontmatter (`title`, `date`, `description`, `problem_type`, `scope`, `complexity`, `tags`)
- Depends on: None (source of truth)
- Used by: Hugo rendering engine to generate HTML

**Configuration Layer:**
- Purpose: Site-wide settings, theme parameters, and navigation
- Location: `config/_default/`
- Contains:
  - `hugo.toml` - Site settings (baseURL, publishDir, taxonomies, outputs)
  - `params.toml` - Blowfish theme parameters (layout, search, analytics stubs)
  - `languages.en.toml` - Metadata and author info
  - `menus.en.toml` - Navigation menu structure
  - `module.toml` - Hugo modules (Blowfish theme)
  - `markup.toml` - Markdown rendering rules
- Depends on: Blowfish theme defaults
- Used by: Hugo engine during build and render pipeline

**Template Layer (Layouts):**
- Purpose: Define page structure and render logic
- Location: `layouts/`
- Contains:
  - `case-studies/list.html` - Grid template for case study index
  - Partials in `layouts/partials/` for components
- Depends on: Content layer (frontmatter, pages), configuration layer (settings)
- Used by: Hugo engine to render HTML from markdown

**Styling Layer:**
- Purpose: Visual design system and presentation
- Location: `assets/css/custom.css`
- Contains:
  - CSS custom properties for colors, typography, spacing, effects
  - Light mode and dark mode color systems
  - Component-specific styles (proof tiles, cards, navigation)
  - Overrides for Blowfish theme defaults
- Depends on: Blowfish CSS (overridden)
- Used by: All HTML pages via compiled CSS bundles

**Static Assets:**
- Purpose: Non-content files (fonts, images, PDFs)
- Location: `static/`
- Contains:
  - Fonts in `static/fonts/` (TikTok Sans, self-hosted)
  - Images in `static/images/`
  - Resume PDF in `static/resume.pdf`
- Depends on: None
- Used by: CSS and HTML for visual presentation

## Data Flow

**Homepage Render Flow:**

1. Hugo reads `content/_index.md` (title, description, HTML content)
2. Applies `index.html` template (or Blowfish default)
3. Renders HTML with:
   - Proof signals section (manual HTML with `proof-signals-container` div)
   - Three proof tiles using inline HTML (Product Judgment, Technical Depth, Execution Leadership)
   - Links to case studies and advisory pages
4. CSS from `custom.css` styles proof tiles with colors (`--accent-product`, `--accent-technical`, `--accent-execution`)
5. Outputs to `docs/index.html`

**Case Studies List Flow:**

1. Hugo reads `content/case-studies/_index.md` (overview content)
2. Hugo reads all markdown files in `content/case-studies/` directory
3. Applies `layouts/case-studies/list.html` template
4. Template loops through pages and calls `partial "case-study-card"` for each
5. `case-study-card.html` partial:
   - Renders article element with class `case-study-card`
   - Extracts frontmatter fields: `title`, `description`, `problem_type`, `scope`, `complexity`
   - Generates icon SVG based on `problem_type` (product-strategy, technical-architecture, etc.)
   - Creates metadata tags from `problem_type`, `scope`, `complexity`
   - Links to case study detail page
6. CSS applies grid layout (`case-studies-grid` class)
7. Outputs to `docs/case-studies/index.html`

**Case Study Detail Flow:**

1. Hugo reads individual `content/case-studies/[name].md`
2. Frontmatter defines: title, date, description, problem_type, scope, complexity, tags
3. Applies Blowfish article template (from theme)
4. Content sections: Context → Ownership → Decision Frame → Outcome → Reflection
5. Custom CSS renders sections with consistent spacing and typography
6. Outputs to `docs/case-studies/[name]/index.html`

**State Management:**
- No JavaScript state: Static HTML generated at build time
- Navigation state: Browser's URL and back button
- Theme preference: `defaultAppearance = "dark"` with `autoSwitchAppearance = true` in params
- Dark mode CSS: `html.dark` selector in `custom.css` overrides color variables
- Search state: Handled by Blowfish theme JavaScript (if enabled, currently disabled)

## Key Abstractions

**Proof Tile Component:**
- Purpose: Showcase decision evidence signals (Product Judgment, Technical Depth, Execution Leadership)
- Examples: `layouts/partials/proof-tile.html`, rendered inline in `content/_index.md`
- Pattern:
  - Accepts optional icon, title, content, outcome, link via partial parameters
  - Icon SVG (compass, circuit, mountain) indicates category
  - Manual HTML in homepage markdown applies BEM classes (`proof-tile`, `proof-tile__title`, `proof-tile__content`)
  - CSS in `custom.css` defines styling with category-specific accent colors

**Case Study Card Component:**
- Purpose: Preview card for case study gallery/index
- Examples: `layouts/partials/case-study-card.html`
- Pattern:
  - Accepts page object (Hugo .Page context)
  - Extracts metadata from frontmatter (title, description, problem_type, scope, complexity)
  - Generates thumbnail: user-provided image OR category-based icon SVG
  - Renders metadata tags from frontmatter fields
  - Links to full case study page via `.RelPermalink`
  - CSS creates card appearance with border-radius, hover states, truncated text

**Case Study Section Component:**
- Purpose: Consistent section rendering within case study detail pages
- Examples: `layouts/partials/case-study-section.html`
- Pattern:
  - Accepts title, content (markdown text), optional id
  - Auto-generates section ID from title if not provided
  - Renders `<section>` with BEM class naming
  - Markdownifies content for rich formatting
  - CSS handles spacing, typography, visual hierarchy

**Navigation Component:**
- Purpose: Main menu and site navigation
- Configuration: `config/_default/menus.en.toml` (Home, Decision Systems, Advisory, Resume, About)
- Pattern: Defined in TOML, rendered by Blowfish theme header template
- Rendered as pill-shaped buttons with hover states (CSS in `custom.css`)

## Entry Points

**Homepage:**
- Location: `content/_index.md` (renders to `docs/index.html`)
- Triggers: User visits `https://athan-dial.github.io/`
- Responsibilities:
  - Hero content: Title, tagline, description
  - Proof signals grid: Three cards demonstrating decision judgment, technical depth, execution
  - CTAs: "How I Can Help" section with links to Resume, Advisory, Case Studies, Writing
  - Proves brand positioning: "Decision evidence, not achievements"

**Case Studies Index:**
- Location: `content/case-studies/_index.md` (renders to `docs/case-studies/index.html`)
- Triggers: User visits `/case-studies/`
- Responsibilities:
  - Overview: Explain case study format and philosophy
  - Grid layout: Display all case study cards in responsive grid
  - Filtering: Cards tagged with `problem_type`, `scope`, `complexity` for discoverability
  - Links: Each card links to full case study detail page

**Case Study Detail Pages:**
- Location: `content/case-studies/[case-name].md` (renders to `docs/case-studies/[case-name]/index.html`)
- Triggers: User visits `/case-studies/[case-name]/`
- Responsibilities:
  - Frontmatter metadata: Title, date, description, problem type, scope, complexity, tags
  - Five-section structure: Context → Ownership → Decision Frame → Outcome → Reflection
  - Decision evidence: Explain problem, options considered, rationale, constraints
  - Outcomes: Metrics, impacts, guardrails, second-order effects, limitations
  - Reflection: Hindsight, lessons learned, future implications

**Resume Page:**
- Location: `content/resume.md` (renders to `docs/resume/index.html`)
- Triggers: User visits `/resume/`
- Responsibilities: Professional history, skills, educational background

**Advisory Page:**
- Location: `content/advisory.md` (renders to `docs/advisory/index.html`)
- Triggers: User visits `/advisory/`
- Responsibilities: Explain advisory approach, topics, how to connect

**About Page:**
- Location: `content/about.md` (renders to `docs/about/index.html`)
- Triggers: User visits `/about/`
- Responsibilities: Origin story, personal background, contact info

## Error Handling

**Strategy:** Static site generation — no runtime errors. All errors occur at build time.

**Patterns:**
- Missing page reference: Hugo fails build with clear error message
- Invalid frontmatter: Hugo fails with YAML parse error
- Missing template: Hugo fails with template not found error
- Broken link in markdown: No error; link renders as-is (requires manual testing)
- Missing image: No error; image tag renders but image 404s at runtime (requires manual QA)
- Invalid CSS syntax: CSS compilation succeeds but styles won't apply (requires visual testing)

## Cross-Cutting Concerns

**Logging:** None - static site has no runtime logs. Use Hugo's verbose build output (`hugo --verbose`) for debugging.

**Validation:**
- Frontmatter validation: Implicit (only defined fields used)
- Link validation: Manual (no automated link checker in build)
- Image optimization: Hugo's `disableImageOptimization = false` handles responsive images
- Markdown rendering: `markup.toml` configures parser behavior

**Authentication:** None required - public static site. No user state or identity.

**Deployment:**
- Build target: `docs/` directory (configured in `hugo.toml` `publishDir = "docs"`)
- CI/CD: GitHub Pages automatically deploys `docs/` from `gh-pages` branch
- Build command: `hugo` (with optional `-D` flag to include drafts)
- Cleanup: `rm -rf docs/ && hugo` for clean rebuild

---

*Architecture analysis: 2026-02-04*
