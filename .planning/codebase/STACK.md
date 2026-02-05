# Technology Stack

**Analysis Date:** 2026-02-04

## Languages

**Primary:**
- Go 1.25.5 - Hugo module configuration via `go.mod`

**Secondary:**
- Markdown - Content files for case studies, pages, and posts
- HTML - Hugo templates and layout overrides
- CSS - Custom design system and theme overrides
- TOML - Site configuration (Hugo, theme parameters, taxonomy definitions)

## Runtime

**Environment:**
- Hugo v0.154.3+extended with withdeploy capability
  - Extended variant required for CSS processing and advanced features
  - Runs on macOS/arm64 (verified: Homebrew installation)
  - Built 2026-01-06

**Package Manager:**
- Hugo Modules - Replaces traditional theme directories
- No npm/yarn dependencies; static site without JavaScript dependencies

## Frameworks

**Core:**
- Hugo 0.154.3+extended - Static site generator for portfolio site
  - Purpose: Renders Markdown content to static HTML
  - Configuration: `config/_default/hugo.toml`
- Blowfish v2.96.0 - Hugo theme providing base styling and layouts
  - Purpose: Theming foundation for portfolio design
  - Module path: `github.com/nunocoracao/blowfish/v2`
  - Imported via: `config/_default/module.toml`

**Templating:**
- Hugo's built-in templating engine - Processes `.html` partials and layouts
- Goldmark - Markdown parser with support for:
  - Attribute blocks for extended Markdown syntax
  - Passthrough mode for LaTeX math notation
  - Unsafe HTML rendering in Markdown

**Build/Asset Processing:**
- Hugo's built-in CSS/asset pipeline
  - Fingerprinting algorithm: SHA-512 for cache busting
  - Processes custom.css with variable expansion and compilation
  - Output: `docs/css/main.bundle.min.[hash].css` (minified and hashed)

## Key Dependencies

**Critical:**
- Blowfish Theme v2.96.0 - Provides base layout components, UI patterns, and styling defaults
  - Location in imports: `github.com/nunocoracao/blowfish/v2` (v2.96.0)
  - Git reference: `go.sum` contains hash `h1:+1mIvQ61ZEQMUKd/o3SvC8YFlkqD/KYRXhgPs9baopY=`

**Frontend:**
- Inter Font (Google Fonts) - Primary sans-serif typeface for body and interface
  - Weights: 300, 400, 500, 600
  - CDN: `https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600`
  - Used: Throughout site via CSS variable `--font-sans`
- JetBrains Mono (Google Fonts) - Monospace font for code blocks
  - Weights: 400, 500
  - CDN: `https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500`
  - Used: Code blocks and technical content via CSS variable `--font-mono`

## Configuration

**Environment:**
- No `.env` files required for production
- Analytics: Optional (Google Analytics ID commented out in `config/_default/hugo.toml`)
- All configuration is static TOML; no runtime environment variables

**Build:**
- `config/_default/hugo.toml` - Core Hugo settings:
  - Base URL: `https://athan-dial.github.io/`
  - Publish directory: `docs/` (for GitHub Pages on gh-pages branch)
  - Language: English (en-us)
  - Taxonomies: tags, categories, authors, series
  - Sitemap: Enabled with daily changefreq
  - Output formats: HTML, RSS, JSON

- `config/_default/params.toml` - Blowfish theme parameters:
  - Color scheme: blowfish
  - Dark mode: Default appearance with auto-switching
  - Structured data: Breadcrumbs disabled
  - Header layout: fixed-fill-blur
  - Footer: Shows menu, copyright, theme attribution, appearance switcher
  - Fingerprinting: SHA-512 algorithm

- `config/_default/languages.en.toml` - Site metadata:
  - Title: "Athan Dial - Portfolio"
  - Language code: en
  - Author name: Athan Dial
  - Date format: "2 January 2006"
  - Bio: "Data science + product leader..."

- `config/_default/markup.toml` - Markdown processing:
  - Goldmark parser: Enabled attribute blocks for extended syntax
  - Renderer: Unsafe HTML allowed (for custom HTML in Markdown)
  - Passthrough: LaTeX math notation support with delimiters
  - Code highlighting: CSS classes mode (not inline styles)
  - Table of Contents: Levels 2-4

- `config/_default/menus.en.toml` - Navigation menu structure (defines site navigation)

**Theme Overrides:**
- `assets/css/custom.css` - Complete custom design system overriding Blowfish defaults
  - Imports: Google Fonts (Inter, JetBrains Mono)
  - CSS variables for colors, typography, spacing, effects
  - Separate light (`:root`) and dark (`html.dark`) mode color systems
  - Uses `!important` extensively to override theme defaults

## Platform Requirements

**Development:**
- Hugo 0.154.3+extended or later (macOS, Linux, Windows)
- Git for version control
- Text editor or IDE (VS Code, Cursor, etc.)
- No additional build tools required (Hugo is self-contained)
- No Node.js, npm, or package managers needed

**Production:**
- Deployment target: GitHub Pages (gh-pages branch)
- Static hosting: Published from `docs/` directory
- DNS: Custom domain `athan-dial.github.io`
- No server-side processing required
- No database, API backend, or runtime services

## Build Commands

**Local Development:**
```bash
hugo server -D              # Serve locally with drafts on http://localhost:1313
hugo server --buildDrafts --watch  # With watch for file changes
```

**Production Build:**
```bash
hugo                        # Build to docs/ directory
hugo -D                     # Build with draft content included
rm -rf docs/ && hugo        # Clean rebuild
```

**Theme Management:**
```bash
hugo mod get -u github.com/nunocoracao/blowfish/v2   # Update Blowfish theme
hugo mod graph              # Verify module dependencies
```

---

*Stack analysis: 2026-02-04*
