# Visual Assets Directory Structure

This directory contains all visual assets for the portfolio rebranding.

## Directory Organization

### `/icons/`
**Purpose:** SVG icons for navigation, proof signals, and case study categories

**Required Icons (23 total):**
- **Navigation (12):** home, case-studies, resume, advisory, writing, external-link, download, theme-toggle, menu, close, arrow-right, arrow-left
- **Proof Signals (3):** compass (product judgment), circuit (technical depth), mountain (execution leadership)
- **Case Study Categories (8):** product-strategy, technical-architecture, execution-leadership, strategic-analysis, incident-response, data-quality, decision-frameworks, phd-transfer

**Specifications:**
- Format: SVG (inline-ready)
- Size: 24×24px artboard
- Style: 2px stroke, outlined, minimal
- Colors: Inherit via CSS `stroke: currentColor`

### `/case-studies/`
**Purpose:** Hero/thumbnail images for case study cards and detail pages

**Required Images (7):**
1. `scaling-ai-nominations-hero.svg/png` - Grid expansion visualization (250 → 7000 nodes)
2. `stat6-crisis-hero.svg/png` - Pipeline break/repair diagram
3. `learning-agenda-hero.svg/png` - Decision tree with hypothesis branches
4. `xtalpi-build-buy-hero.svg/png` - Balance scale/Venn diagram
5. `shiny-standardization-hero.svg/png` - Fragmented → unified framework
6. `metric-theater-hero.svg/png` - Evaluation funnel (offline → online)
7. `pipeline-latency-hero.svg/png` - Timeline acceleration (3 days → same day)

**Specifications:**
- Dimensions: 1200×600px (2:1 ratio)
- Format: SVG (preferred) or PNG
- Style: Abstract data visualization, editorial illustration
- Colors: Category accent colors + warm neutrals
- Usage: `hero_image: /images/case-studies/filename.svg` in frontmatter

### `/diagrams/`
**Purpose:** In-content diagrams for case study storytelling

**Types:**
- Decision trees (options → evaluation → choice)
- Before/after comparisons
- Process flow diagrams
- Data visualizations (bar charts, line charts, timelines)
- Stakeholder maps
- ROI models

**Specifications:**
- Format: SVG (scalable, accessible)
- Style: Muted earth tones + data accent colors
- Typography: Inter for labels
- Grid: Align to 8px spacing
- Accessibility: Include alt text in markdown

### `/patterns/`
**Purpose:** Background patterns and decorative elements

**Required Patterns:**
1. `hero-pattern.svg` - Abstract data viz nodes + connections (subtle, 5% opacity)
2. `divider-pattern.svg` - Geometric pattern for ornamental dividers

**Specifications:**
- Format: SVG (optimized for performance)
- Style: Subtle, non-distracting
- Usage: Referenced via CSS `background-image`

## Usage in Hugo Templates

### Proof Tiles with Icons
```html
{{ partial "proof-tile.html" (dict
  "icon" "compass"
  "title" "Product Judgment"
  "content" "..."
) }}
```

### Case Study Cards with Hero Images
Frontmatter in case study markdown:
```yaml
hero_image: /images/case-studies/scaling-ai-nominations-hero.svg
```

### In-Content Diagrams
Markdown in case study:
```markdown
![Decision framework](/images/diagrams/learning-agenda-tree.svg)
```

## Asset Generation Status

**TODO:** Create asset generation sub-project plan for Claude agent to execute.

- [ ] Icons (23 SVG files)
- [ ] Hero images (7 files)
- [ ] Diagrams (10-15 files)
- [ ] Patterns (2 SVG files)

## Design System References

**Colors:**
- Product: `#C17A47` (terracotta)
- Technical: `#4A7C59` (sage)
- Execution: `#8B6F9E` (purple)
- Primary Accent: `#2E5C8A` (teal-blue)

**Typography:**
- Diagrams/labels: Inter (variable sans)
- Icons: 2px stroke weight
- Spacing: 8px grid system
