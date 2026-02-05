# Coding Conventions

**Analysis Date:** 2026-02-04

## Naming Patterns

**Files:**
- Hugo templates: kebab-case (e.g., `case-study-card.html`, `proof-tile.html`)
- CSS classes: Double-underscore Block Element Modifier (BEM) pattern
  - Block: `.case-study-card`
  - Element: `.case-study-card__title`, `.case-study-card__link`
  - Modifier: `.case-study-card__thumbnail--placeholder`
- Content/markdown: kebab-case with descriptive names (e.g., `xtalpi-build-vs-buy-analysis-montai.md`)

**Hugo Template Patterns:**
- Conditional checks: `{{ if .Condition }}` / `{{ else if }}` / `{{ end }}`
- Variable access: `.FieldName` (dot notation for frontmatter fields)
- Loops: `{{ range .Items }}...{{ end }}`
- Functions: `{{ functionName .Param }}`

**CSS Class Naming:**
- Follow BEM strictly for components (`.component__element--modifier`)
- Use kebab-case for all class names
- Examples in `assets/css/custom.css`:
  - `.proof-tile` (block)
  - `.proof-tile__icon` (element)
  - `.proof-tile__link` (element)
  - `.case-study-card` (block)
  - `.case-study-card__thumbnail--placeholder` (element with modifier)

**Variables:**
- CSS custom properties use double-dash prefix: `--text-primary`, `--space-lg`, `--accent-primary`
- Frontmatter fields: lowercase with hyphens (e.g., `problem_type`, `hero_image`, `case-study-card__thumbnail`)

**Types/Data Structures:**
- Hugo frontmatter uses snake_case: `problem_type`, `scope`, `complexity`, `hero_image`
- Content parameters in shortcodes: camelCase or lowercase simple strings

## Code Style

**Formatting:**
- Hugo templates: 2-space indentation (observed in `layouts/partials/*.html`)
- CSS: 2-space indentation in `assets/css/custom.css`
- Comments in templates use Hugo comment syntax: `{{/* Comment text */}}`
- Comments in CSS use standard syntax: `/* Comment */` with section dividers using multiple lines

**Linting:**
- No explicit linter config detected in Hugo/CSS files
- Style enforced through CSS variable system and template patterns
- Responsive design enforced via `@media` queries at 768px breakpoint minimum

**CSS Variables System:**
The entire design system is based on CSS custom properties (variables) organized in semantic groups:
- Colors: `--bg-primary`, `--text-primary`, `--accent-primary`, `--border-light`
- Typography: `--font-sans`, `--text-base`, `--text-lg`, `--weight-medium`
- Spacing: `--space-xs` (0.5rem) to `--space-3xl` (8rem)
- Effects: `--transition-fast` (0.2s), `--radius-2xl` (32px)

**Dark Mode:**
Light mode defaults in `:root`, dark mode overrides in `html.dark` selector. All color variables redefined with appropriate dark palette values.

## Import Organization

**Hugo Templates:**
Templates use Hugo's built-in layout system with:
1. `{{ define "main" }}` at top level
2. Conditionals for content inclusion
3. Partial includes: `{{ partial "component-name" . }}`
4. Data access via context dot: `.FieldName`, `.Params.field_name`

**CSS:**
- Google Fonts imports at top: `@import url('...')`
- Variable definitions first (`:root` and `html.dark`)
- Layout styles after variables
- Component-specific styles follow base styles

No path aliases detected in this Hugo project.

## Error Handling

**Patterns:**
- Hugo templates use conditional checks for optional fields
  - `{{ if .Params.field }}...{{ else }}...{{ end }}`
  - Fallback to placeholder content when field missing (e.g., fallback icon in `case-study-card.html`)
- No explicit error handling framework (static site generation, errors caught at build time)
- Graceful degradation through template conditionals: missing hero image triggers placeholder SVG

Example from `case-study-card.html` (lines 4-29):
```html
{{ if .Params.hero_image }}
  <img src="{{ .Params.hero_image }}" ... />
{{ else }}
  {{/* Fallback placeholder */}}
  <div class="case-study-card__thumbnail--placeholder" data-category="{{ .Params.problem_type }}">
    {{/* Category-specific SVG icon */}}
  </div>
{{ end }}
```

## Logging

**Framework:** Not applicable for static site

Logging happens during Hugo build phase via CLI output. No runtime logging framework detected.

**Build-time Monitoring:**
- Hugo reports build errors to stdout during `hugo` or `hugo server` commands
- CSS and template errors caught during compilation
- No custom logging decorators or levels in codebase

## Comments

**When to Comment:**
- Component purpose: Brief description at top of template (e.g., `{{/* Case Study Index Card Component - For gallery/grid browsing */}}`)
- Non-obvious logic: Explain conditional fallbacks
- Section dividers: Multiple-line CSS comment headers separating major sections

**JSDoc/TSDoc:**
Not applicable (not a TypeScript/JavaScript codebase). Hugo templates don't use JSDoc.

**Template Comments Pattern:**
```html
{{/* Component Name — Brief description of purpose */}}
<article class="component">
  {{/* Conditional section — explain when this renders */}}
  {{ if .Condition }}
    ...
  {{ end }}
</article>
```

**CSS Comments Pattern:**
```css
/* ============================================
   SECTION NAME — What this section contains
   ============================================ */
```

## Function Design

**Size:** Template partials kept focused on single responsibility
- `proof-tile.html`: Only renders proof signal card (11 lines, excluding comments)
- `case-study-card.html`: Only renders case study preview card (51 lines, including SVGs)
- `case-study-section.html`: Only renders case study section wrapper (7 lines)

**Parameters:** Hugo partial syntax passes entire context or specific values
```html
{{ partial "component-name" . }}                    /* Pass full context */
{{ partial "component-name" .Params }}              /* Pass specific object */
```

**Return Values:** Partials render HTML directly. No explicit return pattern since Hugo partials output to page.

## Module Design

**Exports:** Hugo partials are "exported" implicitly via template names in `layouts/partials/`

**Barrel Files:** Not applicable (Hugo doesn't use barrel files)

**Component Composition:**
- Major sections: `case-studies/list.html` (layout) includes `partials/case-study-card.html` (component)
- Reusable components: `partials/proof-tile.html` embedded directly in markdown via HTML in `content/_index.md`
- No shared template logic utilities detected

## CSS Architecture Principles

**Cascading Layers:**
1. **Variables layer**: `:root` and `html.dark` define all design tokens
2. **Base styles**: HTML elements (body, h1-h6, p, a, lists)
3. **Layout layer**: Main container, .prose, responsive grid
4. **Component layer**: `.proof-signals-container`, `.case-study-card`, `.proof-tile`
5. **Override layer**: Heavy use of `!important` to override Blowfish theme defaults

**Specificity Management:**
- Uses `!important` deliberately to override theme (e.g., `font-family: var(--font-sans) !important;`)
- Lower-specificity selectors for base elements
- Higher-specificity for component overrides

**Responsive Design Pattern:**
Single breakpoint at 768px for tablet/desktop distinction
```css
@media (min-width: 768px) {
  /* Desktop/tablet styles */
}
```

---

*Convention analysis: 2026-02-04*
