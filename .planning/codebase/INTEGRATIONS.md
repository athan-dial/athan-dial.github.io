# External Integrations

**Analysis Date:** 2026-02-04

## APIs & External Services

**Google Calendar:**
- Service: Google Calendar scheduling widget
- What it's used for: Booking calls (advisory/consulting inquiries)
- Location: `content/consulting.md` - Embedded calendar link for scheduling
- Implementation: Direct iframe/link to Google Calendar booking page
- URL: `https://calendar.app.google/Skaryd6X15GjQEcG7`
- Auth: None (public calendar)

**Google Fonts:**
- Service: Google Fonts CDN for typography
- What it's used for: Delivers Inter (sans-serif) and JetBrains Mono (monospace) fonts
- Location: `assets/css/custom.css` - @import statement
- URLs:
  - `https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600`
  - `https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500`
- Auth: None (public CDN)
- Fallback: System fonts (-apple-system, BlinkMacSystemFont, Segoe UI, sans-serif)

## Data Storage

**Databases:**
- Not applicable - Static site only
- No persistent data storage required

**File Storage:**
- Local filesystem only - All assets served statically
- Content: Markdown files in `content/` directory
- Static assets: Images, fonts, CSS in `static/` directory
- Generated output: Built HTML in `docs/` directory

**Caching:**
- Browser caching: CSS/JS files use SHA-512 fingerprinting for cache busting
- Fingerprinting enabled via `fingerprintAlgorithm = "sha512"` in `config/_default/params.toml`
- Output: Hashed filenames like `main.bundle.min.[hash].css`
- No server-side caching required

## Authentication & Identity

**Auth Provider:**
- None - Site is public read-only
- No user accounts, login, or personalization required
- No API authentication tokens

## Monitoring & Observability

**Error Tracking:**
- Not configured
- No error tracking service integrated (Sentry, Rollbar, etc.)

**Analytics:**
- Not configured
- Google Analytics commented out in `config/_default/hugo.toml`:
  - `# googleAnalytics = "G-XXXXXXXXX"`
- Available but disabled analytics frameworks via Blowfish theme:
  - Firebase Analytics (optional)
  - Fathom Analytics (optional)
  - Umami Analytics (optional)
  - Seline Analytics (optional)
- Robots: Enabled (`enableRobotsTXT = true`) for SEO

**Logs:**
- No remote logging
- Hugo build output only (local console during development)
- No structured logging infrastructure

## CI/CD & Deployment

**Hosting:**
- GitHub Pages - Serves content from `docs/` directory on gh-pages branch
- Base URL: `https://athan-dial.github.io/`
- CNAME: Custom domain configured for GitHub Pages
- No additional hosting services

**CI Pipeline:**
- Not detected - Site builds locally and commits `docs/` directory to git
- Potential for GitHub Actions but no workflow files found in `.github/workflows/`
- Manual deployment: Developer runs `hugo` locally, commits `docs/`, pushes to gh-pages branch

**Build Process:**
- Local: `hugo` command generates static files to `docs/`
- Publishing: Direct push to GitHub Pages via `gh-pages` branch
- No Docker, containers, or build infrastructure

## Environment Configuration

**Required env vars:**
- None - All configuration is static TOML files
- No `.env` file required

**Secrets location:**
- No secrets used
- Public site with no sensitive credentials
- Calendar widget uses public Google Calendar ID (not sensitive)

## Webhooks & Callbacks

**Incoming:**
- None

**Outgoing:**
- None

## SEO & Discovery

**Sitemap:**
- Enabled: `[sitemap]` configuration in `config/_default/hugo.toml`
- Filename: `sitemap.xml`
- Change frequency: daily
- Default priority: 0.5
- Excluded: Taxonomy and term pages (RSS index pages)
- Location: Generates at site root: `https://athan-dial.github.io/sitemap.xml`

**RSS Feed:**
- Enabled - HTML output format includes RSS
- Generated from homepage via `[outputs]` configuration
- Feed location: Auto-generated at site root

**Robots:**
- Enabled: `enableRobotsTXT = true` generates `robots.txt`
- Allows search engine crawling

## Content Delivery

**Static Assets:**
- Images: `static/images/` directory
  - SVG diagrams: `patterns/`, `diagrams/`, `case-studies/`
  - PNG icons: Social media, navigation icons
  - Favicon: Standard favicon.ico and Apple touch icons

- Fonts: Via Google Fonts CDN (no local fonts)
  - Previously referenced self-hosted TikTok Sans (per CLAUDE.md historical notes)
  - Currently: Google Fonts (Inter, JetBrains Mono)

- CSS: Google Fonts imports via @import in custom.css
  - No additional CDN dependencies for stylesheets

---

*Integration audit: 2026-02-04*
