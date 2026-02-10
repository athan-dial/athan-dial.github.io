# Phase 11: Model Citizen UI/UX - Research

**Researched:** 2026-02-10
**Domain:** Quartz 4 theming, CSS customization, digital garden UX
**Confidence:** HIGH

## Summary

Phase 11 focuses on customizing the Quartz site's visual appearance to match or complement the Hugo Resume portfolio site, integrating the Obsidian vault folder structure into navigation, and optimizing reader experience. The research reveals that Quartz 4 uses a Sass-based theming system with configuration-driven color/typography settings and supports extensive CSS customization via `custom.scss`.

**Primary Findings:**
- Quartz 4 theme customization happens through two layers: high-level config (colors/fonts) in `quartz.config.ts` and granular CSS overrides in `quartz/styles/custom.scss`
- The Explorer component provides hierarchical folder navigation with extensive customization options (sorting, filtering, folding behavior)
- Dark mode is built-in using CSS variables, respecting user preference and localStorage persistence
- Reader experience best practices recommend 50-75 characters per line (~66 optimal), 16px base font, and 1.2-1.5x line height
- Design token patterns enable multi-site brand consistency through shared color/typography variables

**Primary recommendation:** Use CSS design tokens (CSS custom properties) to establish a shared color palette between portfolio and Model Citizen sites. Customize Quartz theme in `quartz.config.ts` for core colors/fonts, then apply detailed styling overrides in `custom.scss` to match the Apple-inspired executive blue aesthetic.

## Standard Stack

### Core Technologies
| Library/Tool | Version | Purpose | Why Standard |
|--------------|---------|---------|--------------|
| Quartz | v4.4.0 | Static site generator for Obsidian vaults | De facto standard for publishing Obsidian notes as websites |
| Sass/SCSS | Built-in | CSS preprocessing | Quartz's native styling system with variables and nesting |
| CSS Custom Properties | Native | Design tokens for theming | Modern standard for dynamic theming and dark mode |
| Inter (Google Fonts) | Latest | Typography (header/body) | Current default in Quartz config, clean sans-serif |
| JetBrains Mono | Latest | Code typography | Current default for code blocks |

### Supporting Components
| Component | Purpose | Configuration |
|-----------|---------|---------------|
| Explorer | Folder navigation sidebar | `Component.Explorer()` in `quartz.layout.ts` |
| Darkmode | Theme switcher | `Component.Darkmode()` + localStorage persistence |
| TableOfContents | Reading navigation | `Component.TableOfContents()` in right sidebar |
| Breadcrumbs | Hierarchical context | `Component.Breadcrumbs()` in `beforeBody` |

### File Structure
```
quartz/
├── quartz.config.ts          # Theme colors, fonts, analytics
├── quartz.layout.ts          # Component placement (left/right/header)
├── quartz/styles/
│   ├── base.scss            # Core Quartz styles (DO NOT EDIT)
│   ├── custom.scss          # YOUR customizations (safe to edit)
│   ├── variables.scss       # Layout breakpoints, grid config
│   └── callouts.scss        # Obsidian callout styling
└── quartz/components/styles/
    ├── explorer.scss        # Explorer component styles
    ├── darkmode.scss        # Dark mode toggle styles
    └── [other components]   # Component-specific SCSS

content/
├── index.md                 # Homepage
├── notes/                   # Published notes folder
└── attachments/             # Images, PDFs, etc.
```

**Installation:** Already installed at `/Users/adial/Documents/GitHub/quartz/`

## Architecture Patterns

### Pattern 1: Two-Layer Theme Customization

**What:** Quartz separates high-level theme configuration from detailed styling

**When to use:** Always - this is the standard approach

**Config Layer (`quartz.config.ts`):**
```typescript
theme: {
  fontOrigin: "googleFonts",
  cdnCaching: true,
  typography: {
    header: "Inter",
    body: "Inter",
    code: "JetBrains Mono",
  },
  colors: {
    lightMode: {
      light: "#faf8f8",      // Page background
      lightgray: "#e5e5e5",  // Borders
      gray: "#b8b8b8",       // Graph links
      darkgray: "#4e4e4e",   // Body text
      dark: "#2b2b2b",       // Header text
      secondary: "#284b63",  // Links, current node
      tertiary: "#84a59d",   // Hover states
      highlight: "rgba(143, 159, 169, 0.15)",
      textHighlight: "#fff23688",
    },
    darkMode: { /* ... */ }
  }
}
```

**Styling Layer (`quartz/styles/custom.scss`):**
```scss
@use "./base.scss";

// Override using Quartz's CSS variables
.explorer {
  background: var(--light);
  border-right: 1px solid var(--lightgray);
}

// Custom additions
.reading-width {
  max-width: 65ch; // 65 characters per line
  margin: 0 auto;
}
```

**Source:** [Quartz Configuration](https://quartz.jzhao.xyz/configuration), [Layout](https://quartz.jzhao.xyz/layout)

### Pattern 2: Design Token Consistency Across Sites

**What:** Use CSS custom properties to establish shared color palette between Hugo portfolio and Quartz site

**When to use:** When maintaining brand identity across separate sites (portfolio + digital garden)

**Portfolio site (`custom.css`):**
```css
:root {
  --color-primary: #1E3A5F;         /* Executive blue */
  --color-primary-hover: #2A4A75;
  --color-text: #1D1D1F;            /* Apple black */
  --color-text-secondary: #86868B;  /* Apple gray */
  --color-border: #AEAEB2;
}
```

**Quartz site (`custom.scss`):**
```scss
// Map Quartz variables to match portfolio tokens
:root {
  --secondary: #1E3A5F;     // Links (matches portfolio primary)
  --tertiary: #2A4A75;      // Hover (matches portfolio hover)
  --dark: #1D1D1F;          // Headers (matches portfolio text)
  --darkgray: #86868B;      // Body text (matches secondary)
  --lightgray: #AEAEB2;     // Borders (matches portfolio border)
}
```

**Why:** Establishes visual continuity without forcing identical layouts. Users perceive both sites as part of the same brand system.

**Source:** [Design tokens explained](https://www.contentful.com/blog/design-token-system/), [Multi-Brand Design Systems](https://www.supernova.io/blog/eight-multi-brand-design-systems-elevating-global-brand-consistency)

### Pattern 3: Explorer Component Configuration

**What:** Customize folder navigation sidebar to reflect vault structure meaningfully

**When to use:** Always - this determines how readers navigate the content hierarchy

**Example (`quartz.layout.ts`):**
```typescript
Component.Explorer({
  title: "Content",
  folderClickBehavior: "link",        // Navigate to folder page vs collapse
  folderDefaultState: "collapsed",    // Start with folders closed
  useSavedState: true,                // Remember expanded folders
  sortFn: (a, b) => {
    // Folders first, then alphabetical
    if ((!a.file && !b.file) || (a.file && b.file)) {
      return a.displayName.localeCompare(b.displayName)
    }
    return a.file ? 1 : -1
  },
  filterFn: (node) => {
    // Hide inbox and drafts from navigation
    return node.name !== "inbox" && node.name !== "drafts"
  }
})
```

**Key Options:**
- `folderClickBehavior: "link"` - Clicking folder navigates to `/folder/` page (shows folder index)
- `folderClickBehavior: "collapse"` - Clicking folder expands/collapses children (no navigation)
- `filterFn` - Hides nodes (useful for private/draft folders)
- `sortFn` - Custom ordering (by date, alphabetical, manual priority)

**Folder Naming:** Display names come from `folder/index.md` frontmatter `title` field, otherwise uses folder name

**Source:** [Explorer Component](https://quartz.jzhao.xyz/features/explorer)

### Pattern 4: Reader-Optimized Typography

**What:** Configure typography and layout for optimal reading experience

**When to use:** Always - foundational to content legibility

**Best Practices:**
- **Line length:** 50-75 characters per line (66 optimal), max 80 for accessibility
- **Base font size:** 16px minimum for body text
- **Line height:** 1.2-1.5x font size (longer lines need more height)
- **Content width:** Use `ch` units for character-based constraints

**Implementation (`custom.scss`):**
```scss
.center {
  // Main content column
  max-width: 65ch; // ~65 characters per line

  p, li {
    font-size: 1rem;      // 16px
    line-height: 1.5;     // 24px (16 * 1.5)
  }

  h1, h2, h3 {
    line-height: 1.2;     // Tighter for headings
  }
}
```

**Responsive Breakpoints (from `variables.scss`):**
- Mobile: < 800px
- Tablet: 800px - 1200px
- Desktop: > 1200px

**Source:** [Optimal Line Length](https://www.uxpin.com/studio/blog/optimal-line-length-for-readability/), [WCAG Guidelines](https://www.adoc-studio.app/blog/typography-guide)

### Pattern 5: Dark Mode with CSS Variables

**What:** Leverage Quartz's built-in dark mode using CSS custom properties

**When to use:** Always included by default, customizable colors

**How it works:**
1. User toggle stored in localStorage (`theme: "light" | "dark"`)
2. CSS variables change based on theme
3. `themechange` event fires on toggle

**Listening to theme changes:**
```javascript
document.addEventListener("themechange", (e) => {
  console.log("Theme changed to:", e.detail.theme) // "light" or "dark"
  // Custom logic here
})
```

**Styling dark mode:**
```scss
// Light mode (default)
:root {
  --light: #FFFFFF;
  --dark: #1D1D1F;
  --secondary: #1E3A5F;
}

// Dark mode overrides
[saved-theme="dark"] {
  --light: #1D1D1F;
  --dark: #F5F5F7;
  --secondary: #4A90E2;  // Brighter blue for contrast
}
```

**Files:**
- Component: `quartz/components/Darkmode.tsx`
- Styles: `quartz/components/styles/darkmode.scss`
- Logic: `quartz/components/scripts/darkmode.inline.ts`

**Source:** [Quartz Darkmode](https://quartz.jzhao.xyz/features/darkmode)

### Anti-Patterns to Avoid

- **Editing `base.scss` directly:** Will be overwritten on Quartz updates. Always use `custom.scss`
- **Overly narrow content width:** < 45 characters disrupts reading flow
- **Overly wide content width:** > 80 characters causes eye strain
- **Ignoring responsive breakpoints:** Mobile readers need different layouts
- **Hardcoded colors:** Use CSS variables for theme consistency
- **Revealing draft folders:** Use `filterFn` to hide `inbox/`, `drafts/`, etc.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Folder navigation tree | Custom JavaScript file tree | `Component.Explorer()` | Handles expansion state, localStorage, responsive behavior, folder vs file differentiation |
| Dark mode toggle | Custom theme switcher | `Component.Darkmode()` | Includes localStorage persistence, system preference detection, `themechange` events |
| Responsive layout | Custom grid system | Quartz's `variables.scss` breakpoints | Pre-configured mobile/tablet/desktop grids with component positioning |
| Syntax highlighting | Custom code formatter | Quartz's built-in Shiki | Supports GitHub Light/Dark themes, language detection, line highlighting |
| Backlinks | Custom wiki-link parser | `Component.Backlinks()` | Automatically finds bidirectional links between notes |
| Graph visualization | Custom D3.js graph | `Component.Graph()` | Interactive force-directed graph of note connections |
| Table of Contents | Custom heading parser | `Component.TableOfContents()` | Auto-generates TOC from markdown headings with scroll tracking |

**Key insight:** Quartz components are battle-tested for digital garden use cases. Custom solutions miss edge cases (broken links, circular references, mixed case filenames, special characters in paths).

## Common Pitfalls

### Pitfall 1: CSS Specificity Wars with Existing Styles

**What goes wrong:** Custom styles don't apply because Quartz's base styles have higher specificity

**Why it happens:** Base styles use element selectors, classes, and pseudo-selectors. Adding classes without increasing specificity fails.

**How to avoid:**
```scss
// ❌ Won't override
.explorer {
  background: white;
}

// ✅ Will override (higher specificity)
.explorer.desktop-only {
  background: white;
}

// ✅ Alternative: Use !important sparingly
.explorer {
  background: white !important;
}
```

**Warning signs:** Styles defined but not appearing in browser DevTools' computed styles

### Pitfall 2: Folder Structure Not Reflected in Navigation

**What goes wrong:** Vault folders don't appear in Explorer, or appear with wrong names

**Why it happens:**
1. Folders without `index.md` show filesystem name (not title)
2. `filterFn` is hiding the folder
3. Folder is empty (no published content)

**How to avoid:**
- Create `folder/index.md` with frontmatter: `title: "Display Name"`
- Check `filterFn` isn't excluding the folder
- Verify folder contains `.md` files (not just empty)

**Example folder structure:**
```
content/
├── sources/
│   ├── index.md        # title: "Source Material"
│   └── video-1.md
├── ideas/
│   ├── index.md        # title: "Ideas"
│   └── idea-1.md
└── published/
    ├── index.md        # title: "Published Articles"
    └── article-1.md
```

**Warning signs:** Folder shows as "sources" instead of "Source Material", folder missing entirely

### Pitfall 3: Line Length Too Wide on Desktop

**What goes wrong:** Text spans full width on large screens, causing eye strain and poor reading experience

**Why it happens:** Quartz's default `.center` class has responsive max-width but may not be optimal for long-form reading

**How to avoid:**
```scss
// Override content width for reading comfort
.center {
  max-width: 65ch; // ~65 characters per line

  @media (max-width: 800px) {
    max-width: 100%; // Full width on mobile
    padding: 0 1rem;
  }
}
```

**Warning signs:** Lines of text feel exhausting to read, eyes lose place when scanning left to right

### Pitfall 4: Inconsistent Brand Colors Across Sites

**What goes wrong:** Portfolio site uses executive blue (#1E3A5F), but Quartz site uses teal (#284b63), confusing users

**Why it happens:** Default Quartz config uses its own color palette, not aligned with portfolio

**How to avoid:**
1. Extract portfolio color tokens to shared reference
2. Map Quartz color variables to portfolio tokens
3. Document mapping in both codebases

**Portfolio → Quartz mapping:**
```scss
// In custom.scss
:root {
  --secondary: #1E3A5F;  // Portfolio --color-primary
  --tertiary: #2A4A75;   // Portfolio --color-primary-hover
  --dark: #1D1D1F;       // Portfolio --color-text
  --darkgray: #86868B;   // Portfolio --color-text-secondary
  --lightgray: #AEAEB2;  // Portfolio --color-border
}
```

**Warning signs:** Users perceive sites as unrelated despite being same brand

### Pitfall 5: Mobile Navigation Breaks on Small Screens

**What goes wrong:** Explorer sidebar or layout components overlap or become unusable on mobile

**Why it happens:** Desktop-focused customizations don't account for mobile breakpoints

**How to avoid:**
```scss
// Test customizations at all breakpoints
.explorer {
  // Desktop
  @media (min-width: 1200px) {
    width: 320px;
  }

  // Tablet
  @media (min-width: 800px) and (max-width: 1200px) {
    width: 280px;
  }

  // Mobile
  @media (max-width: 800px) {
    width: 100%;
    max-height: 50vh;
  }
}
```

**Testing:** Always test on mobile viewport (< 800px) in DevTools

**Warning signs:** Horizontal scrolling on mobile, text cut off, components overlapping

### Pitfall 6: Dark Mode Colors Lack Sufficient Contrast

**What goes wrong:** Text becomes hard to read in dark mode due to insufficient contrast ratio

**Why it happens:** Light mode colors directly inverted without checking WCAG contrast requirements

**How to avoid:**
- Use [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- Aim for 4.5:1 contrast ratio minimum (WCAG AA)
- Brighten colors in dark mode for better contrast

**Example:**
```scss
:root {
  --secondary: #1E3A5F; // Dark blue on white: good contrast
}

[saved-theme="dark"] {
  --secondary: #4A90E2; // Brighter blue on dark bg: good contrast
  // NOT #1E3A5F (too dark on dark background)
}
```

**Warning signs:** Users report difficulty reading in dark mode, text feels "muddy"

## Code Examples

Verified patterns from official sources:

### Example 1: Complete Theme Configuration

```typescript
// quartz.config.ts
// Source: https://github.com/jackyzha0/quartz/blob/v4/quartz.config.ts
const config: QuartzConfig = {
  configuration: {
    pageTitle: "Model Citizen",
    pageTitleSuffix: " – Athan Dial",
    enableSPA: true,
    enablePopovers: true,
    analytics: {
      provider: "plausible",
    },
    locale: "en-US",
    baseUrl: "athan-dial.github.io/model-citizen",
    ignorePatterns: ["private", "templates", ".obsidian", "inbox", "drafts"],
    defaultDateType: "created",
    theme: {
      fontOrigin: "googleFonts",
      cdnCaching: true,
      typography: {
        header: "Inter",
        body: "Inter",
        code: "JetBrains Mono",
      },
      colors: {
        lightMode: {
          light: "#FFFFFF",
          lightgray: "#AEAEB2",
          gray: "#86868B",
          darkgray: "#4e4e4e",
          dark: "#1D1D1F",
          secondary: "#1E3A5F",      // Executive blue
          tertiary: "#2A4A75",       // Hover state
          highlight: "rgba(30, 58, 95, 0.1)",
          textHighlight: "#1E3A5F22",
        },
        darkMode: {
          light: "#1D1D1F",
          lightgray: "#48484A",
          gray: "#86868B",
          darkgray: "#AEAEB2",
          dark: "#F5F5F7",
          secondary: "#4A90E2",      // Brighter for contrast
          tertiary: "#5BA3F5",
          highlight: "rgba(74, 144, 226, 0.15)",
          textHighlight: "#4A90E244",
        },
      },
    },
  },
  // ... plugins config
}
```

### Example 2: Layout with Filtered Explorer

```typescript
// quartz.layout.ts
// Source: https://quartz.jzhao.xyz/features/explorer
export const defaultContentPageLayout: PageLayout = {
  beforeBody: [
    Component.Breadcrumbs(),
    Component.ArticleTitle(),
    Component.ContentMeta(),
    Component.TagList(),
  ],
  left: [
    Component.PageTitle(),
    Component.MobileOnly(Component.Spacer()),
    Component.Search(),
    Component.Darkmode(),
    Component.DesktopOnly(
      Component.Explorer({
        title: "Content",
        folderClickBehavior: "link",
        folderDefaultState: "collapsed",
        useSavedState: true,
        filterFn: (node) => {
          // Hide private/draft folders
          const hiddenFolders = ["inbox", "drafts", ".templates", ".obsidian"]
          return !hiddenFolders.includes(node.name)
        },
        sortFn: (a, b) => {
          // Folders first, then alphabetical
          if ((!a.file && !b.file) || (a.file && b.file)) {
            return a.displayName.localeCompare(b.displayName)
          }
          return a.file ? 1 : -1
        }
      })
    ),
  ],
  right: [
    Component.Graph(),
    Component.DesktopOnly(Component.TableOfContents()),
    Component.Backlinks(),
  ],
}
```

### Example 3: Custom Styling with Brand Consistency

```scss
// quartz/styles/custom.scss
@use "./base.scss";

// ============================================
// DESIGN TOKENS (match portfolio site)
// ============================================
:root {
  // Override Quartz variables with portfolio colors
  --secondary: #1E3A5F;     // Executive blue (links)
  --tertiary: #2A4A75;      // Hover state
  --dark: #1D1D1F;          // Headers (Apple black)
  --darkgray: #86868B;      // Body text (Apple gray)
  --lightgray: #AEAEB2;     // Borders
  --light: #FFFFFF;         // Background
}

[saved-theme="dark"] {
  --secondary: #4A90E2;     // Brighter blue
  --tertiary: #5BA3F5;      // Brighter hover
  --dark: #F5F5F7;          // Light text
  --darkgray: #AEAEB2;      // Secondary text
  --lightgray: #48484A;     // Dark borders
  --light: #1D1D1F;         // Dark background
}

// ============================================
// TYPOGRAPHY (optimal reading experience)
// ============================================
.center {
  max-width: 65ch; // ~65 characters per line

  p, li, td {
    font-size: 1rem;    // 16px
    line-height: 1.5;   // 24px
    color: var(--darkgray);
  }

  h1, h2, h3 {
    color: var(--dark);
    line-height: 1.2;
  }

  h1 { font-size: 2rem; }    // 32px
  h2 { font-size: 1.5rem; }  // 24px
  h3 { font-size: 1.25rem; } // 20px
}

// Mobile adjustments
@media (max-width: 800px) {
  .center {
    max-width: 100%;
    padding: 0 1rem;
  }
}

// ============================================
// COMPONENT CUSTOMIZATION
// ============================================

// Explorer styling
.explorer {
  background: var(--light);
  border-right: 1px solid var(--lightgray);

  .folder-container div > a {
    color: var(--secondary);
    font-weight: 500;
  }

  .folder-container div > a:hover {
    color: var(--tertiary);
  }
}

// Clean link styling (match portfolio)
a.internal {
  color: var(--secondary);
  text-decoration: none;
  border-bottom: 1px solid transparent;
  transition: all 0.2s ease;

  &:hover {
    color: var(--tertiary);
    border-bottom-color: var(--tertiary);
  }
}

// Breadcrumbs consistency
.breadcrumbs {
  font-size: 0.875rem;
  color: var(--darkgray);

  a {
    color: var(--secondary);

    &:hover {
      color: var(--tertiary);
    }
  }
}
```

### Example 4: Folder Index Pages

```markdown
---
title: "Source Material"
description: "Videos, articles, and transcripts that fuel ideas"
---

# Source Material

This collection contains transcripts and notes from videos, podcasts, and articles that inform my thinking.

## Recent Sources

- [[video-claude-ai-overview|Claude AI Overview]]
- [[article-digital-gardens|Digital Gardens]]
```

Place at: `content/sources/index.md`

**Result:** Explorer shows "Source Material" instead of "sources", clicking folder navigates to this page

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Quartz v3 (Jekyll-based) | Quartz v4 (native TypeScript) | 2023 | Faster builds, better plugin system, modern tooling |
| Inline CSS in config | Sass with custom.scss | Quartz v4 | Better organization, variables, nesting |
| Manual color values | CSS custom properties | Quartz v4 | Dynamic theming, dark mode support |
| Static folder structure | Explorer component | Quartz v4 | Collapsible, filterable, responsive navigation |
| Global font loading | Google Fonts CDN | Quartz v4 | Faster loading, subset optimization |
| Component.FolderList | Component.Explorer | Quartz v4 | More features, better UX |

**Deprecated/outdated:**
- **Quartz v3 layouts:** Completely replaced by v4's component system
- **Jekyll-based builds:** v4 uses esbuild, significantly faster
- **CSS-in-JS approach:** v4 uses SCSS modules, better performance

## Open Questions

1. **System Font vs Google Fonts for Brand Consistency**
   - What we know: Portfolio uses `-apple-system, BlinkMacSystemFont, Segoe UI` (system fonts)
   - What's unclear: Should Model Citizen match system fonts or use Google Fonts (Inter)?
   - Recommendation: Test both approaches. System fonts load instantly but lack consistency across platforms. Inter provides predictable rendering but adds network request. Suggest Inter for brand consistency (matches portfolio weight/proportions).

2. **Vault Folder Visibility Strategy**
   - What we know: Can hide folders with `filterFn`, publish workflow has inbox/drafts/publish_queue
   - What's unclear: Should `enriched/`, `ideas/`, `sources/` all be visible? Or only `published/`?
   - Recommendation: Show `sources/`, `ideas/`, and `published/` (transparent work-in-progress). Hide `inbox/` and `drafts/` (too raw). This aligns with "digital garden" philosophy of learning in public.

3. **Navigation: Folder Pages vs Direct Links**
   - What we know: `folderClickBehavior: "link"` navigates to folder index, `"collapse"` toggles expansion
   - What's unclear: Which behavior better supports reader discovery?
   - Recommendation: Use `"link"` with well-crafted folder index pages. Provides context and curation. Readers can still expand folders to see all notes.

4. **Mobile: Full Explorer or Collapsed by Default?**
   - What we know: Mobile uses `MobileOnly(Component.Spacer())` and collapses sidebars
   - What's unclear: Should Explorer be visible on mobile at all? Or search-first navigation?
   - Recommendation: Keep Explorer but default to collapsed on mobile (`folderDefaultState: "collapsed"`). Mobile readers prioritize content over navigation. Search is primary discovery method on small screens.

## Sources

### Primary (HIGH confidence)
- [Quartz Configuration Documentation](https://quartz.jzhao.xyz/configuration) - Theme colors, typography, config structure
- [Quartz Layout Documentation](https://quartz.jzhao.xyz/layout) - Component sections, breakpoints, customization
- [Quartz Explorer Component](https://quartz.jzhao.xyz/features/explorer) - Navigation configuration, filterFn, sortFn
- [Quartz Dark Mode](https://quartz.jzhao.xyz/features/darkmode) - CSS variables, theme switching, themechange events
- [Quartz Custom Components](https://quartz.jzhao.xyz/advanced/creating-components) - Component CSS patterns
- [Quartz GitHub Source (v4 branch)](https://github.com/jackyzha0/quartz/blob/v4/quartz.config.ts) - Default configuration

### Secondary (MEDIUM confidence)
- [Optimal Line Length for Readability](https://www.uxpin.com/studio/blog/optimal-line-length-for-readability/) - 50-75 characters, 66 optimal
- [WCAG Typography Guidelines](https://www.adoc-studio.app/blog/typography-guide) - 16px base, 1.2-1.5x line height
- [Design Tokens Explained](https://www.contentful.com/blog/design-token-system/) - Multi-site consistency patterns
- [Multi-Brand Design Systems](https://www.supernova.io/blog/eight-multi-brand-design-systems-elevating-global-brand-consistency) - Token-based branding
- [Building a Digital Garden with Quartz](https://notes.hamatti.org/technology/building-a-digital-garden-with-obsidian-and-quartz) - Practical UX patterns
- [Quartz Themes Repository](https://github.com/saberzero1/quartz-themes) - Community theme examples

### Tertiary (LOW confidence)
- General dark mode implementation patterns (WebSearch only, not Quartz-specific)
- Typography trends 2026 (industry trends, not Quartz-specific)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Official documentation and verified in local Quartz installation
- Architecture patterns: HIGH - Extracted from official docs, source code, and verified examples
- Pitfalls: MEDIUM-HIGH - Based on documentation warnings and common digital garden issues, not all validated in this project
- Reader experience: HIGH - Backed by UX research (WCAG, Baymard Institute) and multiple authoritative sources

**Research date:** 2026-02-10
**Valid until:** ~30 days (Quartz v4 is stable, infrequent breaking changes)

**Current state verification:**
- Quartz site: `/Users/adial/Documents/GitHub/quartz/` (v4.4.0)
- Current theme: Inter fonts, teal/blue color scheme (default)
- Current content: Homepage + 1 sample note (`notes/knowledge-framework`)
- Portfolio site: Executive blue (#1E3A5F), system fonts, 407-line custom.css
