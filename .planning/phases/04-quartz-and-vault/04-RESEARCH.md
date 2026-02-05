# Phase 4: Quartz & Vault Schema - Research

**Researched:** 2026-02-05
**Domain:** Quartz static site generator, Obsidian vault architecture, GitHub Pages project site deployment
**Confidence:** HIGH

## Summary

This phase requires setting up Quartz v4 (a Node.js-based static site generator optimized for Obsidian vaults) deployed to GitHub Pages as a project site at `/model-citizen/` path, plus documenting a public Obsidian vault folder structure with consistent markdown frontmatter schema.

Quartz v4 is the current standard for publishing Obsidian vaults as static websites. It provides batteries-included features (full-text search, graph view, wikilinks, backlinks, syntax highlighting) with minimal configuration. The tool natively supports Obsidian markdown conventions and deploys seamlessly to GitHub Pages via GitHub Actions.

The vault architecture follows a workflow-based folder structure (inbox → sources → enriched → ideas → drafts → publish_queue → published) that separates thinking from publishing. Frontmatter schema enables workflow state tracking, source attribution, and automated filtering for selective publication.

**Primary recommendation:** Use Quartz v4 with GitHub Actions deployment workflow, configure baseUrl for project site path, implement ExplicitPublish plugin for safety guardrail, and document vault folder taxonomy before building automation.

## Standard Stack

The established libraries/tools for this domain:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Quartz | v4.0.8+ | Static site generator for Obsidian vaults | Official tool by jackyzha0, designed specifically for digital gardens and knowledge management |
| Node.js | v22+ | JavaScript runtime for Quartz | Required minimum version for Quartz v4 |
| npm | v10.9.2+ | Package manager | Required minimum version for Quartz v4 |
| GitHub Actions | N/A | CI/CD for automated deployment | Official GitHub Pages deployment method |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| actions/checkout | v4 | Repository checkout in workflow | Every GitHub Actions workflow |
| actions/configure-pages | v5 | GitHub Pages setup in workflow | Project site deployments requiring base path configuration |
| actions/upload-pages-artifact | v3 | Upload static files for deployment | Standard GitHub Pages workflow step |
| actions/deploy-pages | v4 | Deploy artifact to GitHub Pages | Standard GitHub Pages workflow step |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Quartz v4 | Jekyll/Hugo | Less Obsidian-native features, more manual wikilink/backlink handling |
| GitHub Pages | Cloudflare Pages | Better trailing slash handling, but requires additional account setup |
| GitHub Actions | Manual deployment | More control but loses automation and consistency |

**Installation:**
```bash
# Clone Quartz repository (or fork it first)
git clone https://github.com/jackyzha0/quartz.git
cd quartz

# Install dependencies
npm i

# Initialize Quartz with content
npx quartz create

# Verify Node/npm versions
node --version  # Should be v22+
npm --version   # Should be v10.9.2+
```

## Architecture Patterns

### Recommended Project Structure

**Decision Point:** User context indicates flexibility on separate repo vs monorepo subdirectory. Both approaches are viable.

**Option A: Separate Repositories (Recommended)**
```
model-citizen-vault/          # Public GitHub repo
├── inbox/
├── sources/
├── enriched/
├── ideas/
├── drafts/
├── publish_queue/
└── published/

model-citizen-quartz/         # Separate repo with Quartz
├── content/                  # Symlinked or copied from vault
├── quartz.config.ts
├── quartz.layout.ts
├── .github/workflows/
└── public/                   # Build output
```

**Option B: Monorepo Subdirectories**
```
model-citizen/
├── vault/                    # Obsidian vault
│   ├── inbox/
│   ├── sources/
│   └── ...
├── site/                     # Quartz installation
│   ├── content/              # Points to ../vault/publish_queue
│   ├── quartz.config.ts
│   └── quartz.layout.ts
└── .github/workflows/        # Single workflow handles both
```

**Tradeoff:** Separate repos provide cleaner separation (vault can be cloned independently, different access patterns), while monorepo simplifies GitHub Actions workflow (single repo, easier file copying between vault and site).

### Pattern 1: Vault Folder Taxonomy (Workflow States)

**What:** Folders represent workflow stages rather than topic categories

**When to use:** Public knowledge management vaults where human approval gates publishing

**Example:**
```
vault/
├── inbox/              # Raw captures - unprocessed
│   └── 2026-02-05-youtube-video.md
├── sources/            # Normalized sources - transcripts, articles
│   └── 2026-02-05-youtube-transcript.md
├── enriched/           # Enriched with summaries, tags, quotes
│   └── 2026-02-05-source-enriched.md
├── ideas/              # Blog angles, outlines, supporting references
│   └── idea-decision-frameworks.md
├── drafts/             # First outlines and full drafts
│   └── draft-metric-theater.md
├── publish_queue/      # Approved for publishing (explicit move)
│   └── published-post.md
└── published/          # Archive of published content (optional)
    └── 2026-02-metric-theater.md
```

**Rationale:** Separates thinking (vault) from publishing (Quartz). Automation writes to early stages (sources, enriched), human explicitly moves to publish_queue. Nothing goes public without human intent signal.

### Pattern 2: Quartz Configuration for Project Sites

**What:** Configure baseUrl for GitHub Pages project site deployment

**When to use:** Any non-root GitHub Pages deployment (username.github.io/repo-name)

**Example:**
```typescript
// quartz.config.ts
const config: QuartzConfig = {
  configuration: {
    pageTitle: "Model Citizen",
    baseUrl: "athan-dial.github.io/model-citizen", // NO protocol, NO trailing slash
    enableSPA: true,
    enablePopovers: true,
    analytics: null,
    locale: "en-US",
    ignorePatterns: ["private/**", ".obsidian"],
    defaultDateType: "modified",
  },
  plugins: {
    transformers: [
      Plugin.FrontMatter(),
      Plugin.CreatedModifiedDate({
        priority: ["frontmatter", "git", "filesystem"],
      }),
      Plugin.SyntaxHighlighting({
        theme: {
          light: "github-light",
          dark: "github-dark",
        },
      }),
      Plugin.ObsidianFlavoredMarkdown({ enableInHtmlEmbed: false }),
      Plugin.GitHubFlavoredMarkdown(),
      Plugin.TableOfContents(),
      Plugin.CrawlLinks({ markdownLinkResolution: "shortest" }),
      Plugin.Description(),
      Plugin.Latex({ renderEngine: "katex" }),
    ],
    filters: [
      Plugin.RemoveDrafts(),
      Plugin.ExplicitPublish(), // Safety guardrail - only publish if status: publish in frontmatter
    ],
    emitters: [
      Plugin.AliasRedirects(),
      Plugin.ComponentResources(),
      Plugin.ContentPage(),
      Plugin.FolderPage(),
      Plugin.TagPage(),
      Plugin.ContentIndex({
        enableSiteMap: true,
        enableRSS: true,
      }),
      Plugin.Assets(),
      Plugin.Static(),
      Plugin.NotFoundPage(),
    ],
  },
}
```

**Key configuration notes:**
- `baseUrl`: Include subpath, exclude protocol and slashes
- `ignorePatterns`: Exclude .obsidian directory and private folders
- `ExplicitPublish` plugin in filters array provides safety guardrail
- `enableSiteMap` and `enableRSS` require baseUrl to be set

### Pattern 3: Markdown Frontmatter Schema

**What:** Consistent YAML frontmatter structure across all vault notes

**When to use:** Every note in the vault (enforced by automation and templates)

**Example:**
```yaml
---
title: "Understanding Metric Theater in ML Teams"
date: 2026-02-05
source: "YouTube"
source_url: "https://youtube.com/watch?v=..."
status: "enriched"  # inbox|enriched|idea|draft|publish|published
tags: ["ml-systems", "decision-frameworks", "product-strategy"]
summary: "How teams fall into reporting metrics that don't drive decisions, and frameworks for evaluating metric quality."
# Optional fields:
idea_angles:
  - "Blog: 5 questions to detect metric theater"
  - "Case study: Montai dashboard consolidation"
related:
  - "[[decision-velocity]]"
  - "[[evaluation-frameworks]]"
---
```

**Field specifications:**
- `title`: Human-readable note title (required)
- `date`: Creation date YYYY-MM-DD format (required)
- `source`: Source type enum - YouTube/Email/Web/Manual (required for automated notes)
- `source_url`: Original source URL (required if source != Manual)
- `status`: Workflow state enum (required, drives filtering)
- `tags`: Array of strings, lowercase-kebab-case (required)
- `summary`: 1-2 sentence summary (required for enriched+ stages)
- `idea_angles`: Array of blog post angles (optional, used in ideas/ folder)
- `related`: Array of wikilinks to related notes (optional)

### Pattern 4: Publishing Safety Guardrail

**What:** Dual-signal publishing rules prevent accidental publication

**When to use:** Any public vault where not all notes should be published

**Implementation:**
```typescript
// quartz.config.ts - filters section
filters: [
  Plugin.RemoveDrafts(),
  Plugin.ExplicitPublish(), // Only publish if frontmatter has status: publish
]
```

**Publishing logic (either condition triggers publication):**
1. Note is in `/publish_queue/` folder, OR
2. Frontmatter has `status: publish`

**Safety rationale:** Automation can move notes through workflow stages (inbox → sources → enriched) but cannot auto-publish. Human must explicitly move note to publish_queue folder OR change status to "publish" in frontmatter.

### Pattern 5: GitHub Actions Workflow for Quartz

**What:** Automated build and deploy on push to main branch

**When to use:** Every Quartz deployment to GitHub Pages

**Example:**
```yaml
# .github/workflows/deploy.yml
name: Deploy Quartz site to GitHub Pages

on:
  push:
    branches:
      - main  # or v4, depending on your branch name

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Fetch all history for git-based dates

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 22

      - name: Install Dependencies
        run: npm ci

      - name: Build Quartz
        run: npx quartz build

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: public

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

**Workflow notes:**
- `fetch-depth: 0` enables git-based modification dates
- `npm ci` for reproducible builds (uses package-lock.json)
- `npx quartz build` outputs to `public/` directory
- Requires `pages: write` and `id-token: write` permissions

### Pattern 6: Quartz Layout Configuration

**What:** Customize component placement in page layout

**When to use:** After basic Quartz setup, to tailor sidebar/header/footer

**Example:**
```typescript
// quartz.layout.ts
import { PageLayout, SharedLayout } from "./quartz/cfg"
import * as Component from "./quartz/components"

export const sharedPageComponents: SharedLayout = {
  head: Component.Head(),
  header: [
    Component.PageTitle(),
    Component.Search(),
    Component.Darkmode(),
  ],
  afterBody: [],
  footer: Component.Footer({
    links: {
      GitHub: "https://github.com/username/model-citizen-vault",
    },
  }),
}

export const defaultContentPageLayout: PageLayout = {
  beforeBody: [
    Component.Breadcrumbs(),
    Component.ArticleTitle(),
    Component.ContentMeta(),
    Component.TagList(),
  ],
  left: [
    Component.DesktopOnly(Component.Explorer()),
  ],
  right: [
    Component.Graph(),
    Component.DesktopOnly(Component.TableOfContents()),
    Component.Backlinks(),
  ],
}
```

**Layout sections:**
- `head`: HTML metadata (single component)
- `header`: Horizontal bar (array, laid out horizontally)
- `beforeBody`: Above main content (array, vertical)
- `afterBody`: Below main content (array, vertical)
- `left`: Left sidebar (array, vertical on desktop/tablet, horizontal on mobile)
- `right`: Right sidebar (array, vertical on desktop, horizontal on tablet/mobile)
- `footer`: Bottom section (single component)

**Responsive behavior:**
- Desktop (>1200px): Both sidebars vertical
- Tablet (800-1200px): Left vertical, right horizontal
- Mobile (<800px): Both horizontal
- Breakpoints configurable in `variables.scss`

### Anti-Patterns to Avoid

- **Folder-as-category organization:** Don't organize vault by topic categories (Product, Engineering, Leadership). Use workflow stages (inbox, enriched, drafts) + tags for categorization. Folders are for workflow state, tags are for topics.

- **Nesting publish_queue:** Don't create subfolders inside publish_queue (e.g., publish_queue/2026/february/). Keep it flat for simple filtering. Quartz will organize by date/tag on the public site.

- **Auto-publishing without human review:** Don't configure automation to move notes directly to publish_queue. Human must explicitly approve by moving file or changing frontmatter status.

- **Inconsistent frontmatter:** Don't allow optional frontmatter fields for required metadata. Enforce schema with templates and validation. Automation depends on consistent structure.

- **Forgetting baseUrl configuration:** Don't skip baseUrl setting or use wrong format. GitHub Pages project sites require `username.github.io/repo-name` format (no protocol, no slashes). This breaks RSS/sitemap generation.

- **Using trailing slashes in URLs:** Don't expect GitHub Pages to redirect `/page/` to `/page.html`. Quartz generates `file.html` (not `file/index.html`), and GitHub Pages doesn't auto-redirect. Link to pages without trailing slashes.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Static site generator for markdown | Custom Node.js build script with markdown-it | Quartz v4 | Quartz provides graph view, backlinks, wikilink resolution, search, syntax highlighting, and Obsidian compatibility out of box. Building this from scratch takes weeks. |
| Obsidian wikilink parsing | Regex-based link parser | Quartz's ObsidianFlavoredMarkdown plugin | Edge cases include aliases (`[[page\|display text]]`), headers (`[[page#section]]`), blocks (`[[page^block-id]]`), embeds (`![[page]]`). Regex approach breaks on nested brackets. |
| Frontmatter validation | Manual parsing with js-yaml | Obsidian templates + linter plugins | Linting plugins (dataview, linter) validate frontmatter on save in Obsidian UI. Manual validation scripts miss interactive feedback. |
| Markdown metadata extraction | Custom frontmatter parser | Quartz's FrontMatter plugin | Handles YAML parsing, date extraction, git-based dates, filesystem dates with priority ordering. Replicating this introduces bugs. |
| Graph visualization | D3.js custom graph | Quartz's Graph component | Interactive graph with force-directed layout, node filtering, hover states, and backlink integration. Custom implementation requires complex D3.js code. |
| Full-text search | ElasticSearch or Algolia integration | Quartz's ContentIndex emitter with built-in search | Client-side search using FlexSearch index (no server required). ElasticSearch/Algolia add hosting costs and complexity for marginal benefit. |

**Key insight:** Quartz v4 is batteries-included for Obsidian vault publishing. Custom solutions underestimate complexity of wikilink resolution, graph generation, and search indexing. Use Quartz's plugin system for customization instead of forking or rebuilding.

## Common Pitfalls

### Pitfall 1: Incorrect baseUrl Format for Project Sites

**What goes wrong:** Site deploys but RSS feeds, sitemaps, and canonical URLs break. Internal links may also fail.

**Why it happens:** baseUrl configuration requires specific format without protocol or slashes. Easy to copy full URL from browser (`https://athan-dial.github.io/model-citizen/`) instead of correct format (`athan-dial.github.io/model-citizen`).

**How to avoid:**
- Use format: `username.github.io/repo-name` (no `https://`, no trailing slash)
- Test RSS feed URL after deployment to verify baseUrl is correct
- Review quartz.config.ts against official Quartz example config

**Warning signs:**
- RSS feed returns 404 or empty feed
- Canonical URLs in `<head>` are missing or malformed
- Sitemap.xml has incorrect URLs

### Pitfall 2: Trailing Slash Link Breakage

**What goes wrong:** Existing links with trailing slashes (e.g., `/about/`) return 404 on GitHub Pages but work locally.

**Why it happens:** Quartz generates `file.html` instead of `file/index.html`. Local dev server redirects `/about/` to `/about.html`, but GitHub Pages doesn't perform this redirect.

**How to avoid:**
- Link to pages without trailing slashes: `[About](/about)` not `[About](/about/)`
- Don't migrate from Quartz v3 or Jekyll if preserving existing URLs with trailing slashes is critical
- If critical, use Cloudflare Pages instead of GitHub Pages (supports auto-redirect)

**Warning signs:**
- Links work in `npx quartz build --serve` but break on deployed site
- 404 errors for pages that exist
- External links to your site with trailing slashes return 404

### Pitfall 3: Forgetting to Enable GitHub Actions for Pages

**What goes wrong:** Workflow runs successfully but site doesn't update. Old content persists.

**Why it happens:** GitHub Pages has two source modes: "Branch" (legacy, deploys from gh-pages branch) and "GitHub Actions" (new, deploys from workflow artifact). Default is Branch mode.

**How to avoid:**
1. Go to repo Settings → Pages
2. Under "Build and deployment" → "Source", select "GitHub Actions"
3. Verify workflow has `pages: write` and `id-token: write` permissions
4. Push a commit to trigger workflow

**Warning signs:**
- Workflow shows green checkmark but site content is stale
- GitHub Pages settings show "Source: Branch" instead of "GitHub Actions"
- `deploy_pages` step in workflow shows warning about Pages not enabled

### Pitfall 4: Node Version Mismatch

**What goes wrong:** `npx quartz build` fails with cryptic errors about ESM imports or missing features.

**Why it happens:** Quartz v4 requires Node v22+. Many developers have older Node LTS versions installed (v18, v20).

**How to avoid:**
- Check Node version: `node --version` (must be v22+)
- Use nvm (Node Version Manager) to install v22: `nvm install 22 && nvm use 22`
- Add Node version to GitHub Actions workflow: `node-version: 22`
- Document required Node version in repository README

**Warning signs:**
- Build fails with "SyntaxError: Unexpected token" on import statements
- Error messages about missing ECMAScript features
- Build works on one machine but fails on another

### Pitfall 5: Inconsistent Frontmatter Breaking Filters

**What goes wrong:** Some notes appear on site when they shouldn't (or vice versa). ExplicitPublish filter doesn't work as expected.

**Why it happens:** Frontmatter fields are inconsistent (e.g., `status: "publish"` vs `publish: true`). Quartz filters depend on exact field names and values. YAML parsing is strict about types.

**How to avoid:**
- Define canonical schema in documentation (this RESEARCH.md)
- Create Obsidian templates for each folder (inbox, sources, enriched, etc.)
- Use Obsidian Linter plugin to validate frontmatter on save
- Test ExplicitPublish filter with sample notes before deploying

**Warning signs:**
- Notes in `drafts/` folder appear on public site
- Notes in `publish_queue/` don't appear after deployment
- Inconsistent frontmatter formats across notes
- Tags rendering as strings instead of arrays

### Pitfall 6: Git Case-Sensitivity Issues

**What goes wrong:** Quartz build fails or shows duplicate files with same name but different casing (e.g., `README.md` and `readme.md`).

**Why it happens:** Git by default treats filenames as case-insensitive on macOS/Windows but case-sensitive on Linux (GitHub Actions). If you rename `Inbox/` to `inbox/` without proper git commands, both may exist in git history.

**How to avoid:**
- Run `git config core.ignorecase false` in vault repository
- Use `git mv` for renaming files/folders: `git mv Inbox inbox`
- Avoid manual filesystem renames that bypass git
- Check for case-duplicates: `git ls-tree -r HEAD --name-only | sort -f | uniq -di`

**Warning signs:**
- Build succeeds locally (macOS/Windows) but fails in GitHub Actions (Linux)
- Error messages about conflicting filenames
- Mysterious duplicate content in Quartz output

## Code Examples

Verified patterns from official sources:

### Complete quartz.config.ts for Project Site

```typescript
// Source: https://quartz.jzhao.xyz/configuration
// Adapted for Model Citizen project site deployment

import { QuartzConfig } from "./quartz/cfg"
import * as Plugin from "./quartz/plugins"

const config: QuartzConfig = {
  configuration: {
    pageTitle: "Model Citizen",
    pageTitleSuffix: " | Athan Dial", // Appears in browser tab
    enableSPA: true, // Single-page app navigation (faster)
    enablePopovers: true, // Hover previews for internal links
    analytics: null, // Add Google Analytics, Plausible, etc. later
    locale: "en-US",
    baseUrl: "athan-dial.github.io/model-citizen", // CRITICAL: No protocol, no trailing slash
    ignorePatterns: [
      "private/**",
      ".obsidian/**",
      "inbox/**", // Don't publish raw captures
      "sources/**", // Don't publish raw sources
      "enriched/**", // Don't publish enriched (not yet ready)
      "ideas/**", // Don't publish idea cards
      "drafts/**", // Don't publish drafts
    ],
    defaultDateType: "modified", // Use last modified date for sorting
    theme: {
      fontOrigin: "googleFonts",
      cdnCaching: true,
      typography: {
        header: "Inter",
        body: "Inter",
        code: "IBM Plex Mono",
      },
      colors: {
        lightMode: {
          light: "#faf8f8",
          lightgray: "#e5e5e5",
          gray: "#b8b8b8",
          darkgray: "#4e4e4e",
          dark: "#2b2b2b",
          secondary: "#284b63",
          tertiary: "#84a59d",
          highlight: "rgba(143, 159, 169, 0.15)",
          textHighlight: "#fff23688",
        },
        darkMode: {
          light: "#161618",
          lightgray: "#393639",
          gray: "#646464",
          darkgray: "#d4d4d4",
          dark: "#ebebec",
          secondary: "#7b97aa",
          tertiary: "#84a59d",
          highlight: "rgba(143, 159, 169, 0.15)",
          textHighlight: "#b3aa0288",
        },
      },
    },
  },
  plugins: {
    transformers: [
      Plugin.FrontMatter(), // Parse YAML frontmatter
      Plugin.CreatedModifiedDate({
        priority: ["frontmatter", "git", "filesystem"], // Date source priority
      }),
      Plugin.SyntaxHighlighting({
        theme: {
          light: "github-light",
          dark: "github-dark",
        },
        keepBackground: false,
      }),
      Plugin.ObsidianFlavoredMarkdown({ enableInHtmlEmbed: false }),
      Plugin.GitHubFlavoredMarkdown(),
      Plugin.TableOfContents(),
      Plugin.CrawlLinks({ markdownLinkResolution: "shortest" }),
      Plugin.Description(), // Extract description from content
      Plugin.Latex({ renderEngine: "katex" }),
    ],
    filters: [
      Plugin.RemoveDrafts(), // Remove anything with draft: true in frontmatter
      Plugin.ExplicitPublish(), // SAFETY: Only publish if status: publish
    ],
    emitters: [
      Plugin.AliasRedirects(),
      Plugin.ComponentResources(),
      Plugin.ContentPage(),
      Plugin.FolderPage(),
      Plugin.TagPage(),
      Plugin.ContentIndex({
        enableSiteMap: true, // Requires baseUrl
        enableRSS: true, // Requires baseUrl
      }),
      Plugin.Assets(),
      Plugin.Static(),
      Plugin.NotFoundPage(),
    ],
  },
}

export default config
```

### Obsidian Template: Enriched Note

```yaml
---
# Source: User-defined schema for Model Citizen vault
# Template: enriched-note.md (place in vault/.templates/)

title: "{{title}}"
date: {{date:YYYY-MM-DD}}
source: "{{source:YouTube|Email|Web}}"
source_url: "{{source_url}}"
status: "enriched"
tags: []
summary: "TODO: Add 1-2 sentence summary"
idea_angles: []
related: []
---

## Source Context

[Original source title/context]

## Key Points

-
-
-

## Quotes

>

## Ideas

-

## Links

-
```

### GitHub Actions Workflow with Content Copying

```yaml
# Source: Adapted from https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages
# For monorepo approach: Copy vault/publish_queue to site/content before build

name: Deploy Quartz to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: 'npm'
          cache-dependency-path: site/package-lock.json

      - name: Copy publish_queue to content
        run: |
          rm -rf site/content/*
          cp -r vault/publish_queue/* site/content/
          # Optional: Copy assets
          if [ -d vault/.attachments ]; then
            cp -r vault/.attachments site/content/attachments
          fi

      - name: Install dependencies
        working-directory: site
        run: npm ci

      - name: Build Quartz
        working-directory: site
        run: npx quartz build

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: site/public

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-22.04
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### Quartz Layout: Knowledge Garden Style

```typescript
// Source: https://quartz.jzhao.xyz/layout
// Knowledge garden aesthetic: prominent backlinks, graph, explorer

import { PageLayout, SharedLayout } from "./quartz/cfg"
import * as Component from "./quartz/components"

export const sharedPageComponents: SharedLayout = {
  head: Component.Head(),
  header: [
    Component.PageTitle(),
    Component.Search(),
    Component.Darkmode(),
  ],
  afterBody: [],
  footer: Component.Footer({
    links: {
      "Source Vault": "https://github.com/username/model-citizen-vault",
      "About": "/about",
    },
  }),
}

export const defaultContentPageLayout: PageLayout = {
  beforeBody: [
    Component.Breadcrumbs(),
    Component.ArticleTitle(),
    Component.ContentMeta(), // Date, reading time
    Component.TagList(),
  ],
  left: [
    Component.DesktopOnly(Component.Explorer({
      folderDefaultState: "collapsed",
      folderClickBehavior: "link",
      useSavedState: true,
    })),
  ],
  right: [
    Component.Graph({
      localGraph: {
        depth: 1,
        enableDrag: true,
        enableZoom: true,
        showTags: false,
      },
      globalGraph: {
        depth: -1,
        enableDrag: true,
        enableZoom: true,
        showTags: false,
      },
    }),
    Component.DesktopOnly(Component.TableOfContents()),
    Component.Backlinks(), // Prominent backlinks for knowledge garden
  ],
}

export const defaultListPageLayout: PageLayout = {
  beforeBody: [Component.Breadcrumbs(), Component.ArticleTitle(), Component.ContentMeta()],
  left: [
    Component.DesktopOnly(Component.Explorer({
      folderDefaultState: "collapsed",
    })),
  ],
  right: [],
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Quartz v3 (Hugo-based) | Quartz v4 (Node.js-based) | August 2023 (v4.0.0 release) | Complete rewrite. Better error messages, JSX support, improved plugin system. Migration guide required for v3 users. |
| Jekyll for GitHub Pages | Quartz v4 or Hugo | 2020-2023 gradual shift | Obsidian ecosystem moved away from Jekyll due to poor wikilink support. Quartz provides native Obsidian integration. |
| Manual wikilink parsing | ObsidianFlavoredMarkdown plugin | Quartz v4 launch | Wikilink resolution, aliases, embeds, transclusions handled automatically. Custom regex parsers obsolete. |
| Branch-based GitHub Pages | GitHub Actions deployment | 2022 (Actions became default) | Eliminates need for gh-pages branch. Workflow uploads artifact directly. Better control over build process. |
| Flat vault structure | Workflow-based folder taxonomy | 2024-2025 shift in community | Digital gardens increasingly use workflow stages (inbox → publish) instead of topic categories. Better for public vaults. |

**Deprecated/outdated:**
- **Quartz v3 (Hugo):** Replaced by Quartz v4 in August 2023. Documentation exists but not recommended for new projects. Migration path available but full rewrite is cleaner.
- **Jekyll with Obsidian:** Possible but requires custom plugins for wikilinks. Community has moved to Quartz or Hugo with Obsidian plugins.
- **GitHub Pages deploy from branch:** Still works but GitHub Actions is now recommended approach. Better CI/CD integration and environment control.
- **Separate repo for Quartz fork:** Early Quartz workflow involved forking jackyzha0/quartz repo. Current best practice is `npx quartz create` for cleaner separation and easier updates.

## Open Questions

Things that couldn't be fully resolved:

1. **Separate repos vs monorepo subdirectories**
   - What we know: Both approaches are viable. User context indicates flexibility. Separate repos provide cleaner separation; monorepo simplifies GitHub Actions workflow.
   - What's unclear: User preference for Model Citizen project. No strong technical constraint either way.
   - Recommendation: Default to **separate repos** for cleaner separation and independent cloning of vault. Can pivot to monorepo if workflow complexity becomes issue. Decision can be made during planning phase.

2. **Archive strategy for published notes**
   - What we know: User context defines `published/` folder in vault taxonomy. Unclear if notes should move to published/ after Quartz publishes them, or remain in publish_queue.
   - What's unclear: Whether published/ folder is archive (notes move there post-publish) or just documentation placeholder.
   - Recommendation: **Keep notes in publish_queue/** after publishing. published/ folder can be optional archive for removed content. Moving notes post-publish adds workflow complexity with unclear benefit.

3. **Nested subfolder structure within workflow folders**
   - What we know: User context lists flat folders (sources/, enriched/, etc.). Unclear if nested subfolders are allowed (e.g., sources/youtube/, sources/email/).
   - What's unclear: Whether automation should create date-based or type-based subfolders for organization.
   - Recommendation: **Start with flat structure** within each workflow folder. Add nested folders only if scale requires it (e.g., 100+ notes in sources/). Flat is simpler for filtering and automation.

4. **Quartz theme customization timing**
   - What we know: User context marks "Exact Quartz theme configuration (colors, fonts, sidebar layout)" as Claude's discretion. Research shows theme is configurable in quartz.config.ts.
   - What's unclear: Whether theme customization happens in Phase 4 (scaffolding) or later phase (polish).
   - Recommendation: **Phase 4 uses Quartz defaults** (minimal theme config). Theme customization can be separate task/phase after scaffolding validates. Keep Phase 4 focused on deployment + schema documentation.

5. **ExplicitPublish vs folder-based filtering**
   - What we know: Quartz's ExplicitPublish plugin filters by frontmatter field. User context defines dual-signal publishing (folder location OR status field). ignorePatterns in quartz.config.ts can exclude folders.
   - What's unclear: Whether ExplicitPublish plugin is sufficient or custom logic needed for dual-signal approach.
   - Recommendation: **Use ignorePatterns for folder exclusion** (ignore inbox/, sources/, enriched/, ideas/, drafts/) and only deploy publish_queue/ folder. ExplicitPublish provides additional safety but may not be necessary if folder-based filtering is sufficient. Test both approaches during implementation.

## Sources

### Primary (HIGH confidence)
- Quartz v4 Official Documentation - https://quartz.jzhao.xyz/ - Full feature set, installation, configuration
- Quartz v4 Configuration Docs - https://quartz.jzhao.xyz/configuration - Complete config options, plugin architecture
- Quartz v4 Layout Docs - https://quartz.jzhao.xyz/layout - Layout structure, component placement
- Quartz v4 Hosting Docs - https://quartz.jzhao.xyz/hosting - GitHub Pages deployment, baseUrl configuration
- Quartz v4 GitHub Repository - https://github.com/jackyzha0/quartz - Current version (v4.0.8), quick start, example config
- GitHub Actions Official Docs - https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages - Workflow patterns for Pages deployment

### Secondary (MEDIUM confidence)
- [GitHub - jackyzha0/quartz: Static-site generator](https://github.com/jackyzha0/quartz) - Verified current version v4.0.8, TypeScript-based
- [Build Quartz for GitHub Pages - GitHub Marketplace](https://github.com/marketplace/actions/build-quartz-for-github-pages) - Community GitHub Action for Quartz
- [My Quartz + Obsidian Note Publishing Setup](https://oliverfalvai.com/evergreen/my-quartz-+-obsidian-note-publishing-setup) - Real-world implementation pattern
- [How I use Obsidian — Steph Ango](https://stephango.com/vault) - Obsidian vault organization philosophy (minimal folders)
- [Obsidian Markdown Cheatsheet (2026)](https://desktopcommander.app/blog/2026/02/03/obsidian-markdown-cheatsheet-every-syntax-you-actually-need/) - Current markdown syntax best practices
- [peaceiris/actions-gh-pages](https://github.com/peaceiris/actions-gh-pages) - Popular GitHub Actions deployment tool (alternative approach)

### Tertiary (LOW confidence)
- [How I Organize my Obsidian Vault](https://www.excellentphysician.com/post/how-i-organize-my-obsidian-vault) - Individual's organizational approach (not universal pattern)
- [How I use Folders in Obsidian - Obsidian Rocks](https://obsidian.rocks/how-i-use-folders-in-obsidian/) - Folder organization opinions (varies by user)
- WebSearch results for "Obsidian public vault workflow PARA method" - Community patterns, not official guidance

## Metadata

**Confidence breakdown:**
- Standard stack: **HIGH** - Quartz v4 is the current version (v4.0.8, August 2023 release), Node v22 requirement verified in official docs, GitHub Actions is standard deployment method
- Architecture: **HIGH** - Patterns verified against official Quartz documentation (quartz.config.ts structure, layout system, plugin architecture), frontmatter schema follows established YAML conventions
- Pitfalls: **MEDIUM** - Trailing slash issue and baseUrl format verified in official hosting docs, other pitfalls derived from community reports and WebSearch (Node version, case-sensitivity are real issues but not exhaustively documented)

**Research date:** 2026-02-05
**Valid until:** 2026-03-07 (30 days - Quartz v4 is stable, Node.js ecosystem is slow-moving, patterns are established)
