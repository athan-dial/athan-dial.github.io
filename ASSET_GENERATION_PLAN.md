# Asset Generation Sub-Project Plan

**Project:** Generate all visual assets for portfolio rebranding
**Parent Project:** Portfolio Website Rebranding (Editorial Data Intelligence)
**Executor:** Claude Agent with code generation + SVG creation capabilities
**Timeline:** 1-2 work sessions

---

## Executive Summary

This plan details the creation of 35+ visual assets for the portfolio rebranding. All assets should be generated programmatically using SVG/code where possible. The agent should create all files in the appropriate directories and follow the design system specifications.

**Critical Constraint:** Do NOT wait for user approval between asset types. Generate all assets in this plan autonomously, then present the complete set for review.

---

## Design System Reference

### Color Palette

```css
/* Primary Accents */
--accent-primary: #2E5C8A;        /* Teal-blue - primary actions */
--accent-product: #C17A47;        /* Terracotta - product judgment */
--accent-technical: #4A7C59;      /* Sage - technical depth */
--accent-execution: #8B6F9E;      /* Purple - execution leadership */

/* Data Visualization */
--data-positive: #5A9367;         /* Success green */
--data-negative: #C17A47;         /* Warning terracotta */
--data-neutral: #8B857E;          /* Neutral gray */

/* Neutrals (Light Mode) */
--bg-primary: #FDFCFA;
--bg-secondary: #F7F5F2;
--text-primary: #2A2520;
--text-secondary: #5C5550;
```

### Icon Specifications
- **Size:** 24×24px viewBox
- **Stroke:** 2px width, round caps, round joins
- **Style:** Outlined, geometric, minimal
- **Color:** `stroke="currentColor"` (CSS will control color)
- **Export:** Inline-ready SVG (no XML declarations needed)

### Hero Image Specifications
- **Dimensions:** 1200×600px (2:1 ratio)
- **Format:** SVG (preferred for scalability)
- **Style:** Abstract data visualization, editorial illustration
- **Colors:** Category accent + neutral gradients
- **Complexity:** Simple geometric shapes, not photorealistic

---

## Phase 1: Navigation Icons (12 icons)

**Directory:** `/static/images/icons/`

Generate 12 SVG icon files with consistent 24×24px viewBox, 2px stroke:

### 1. home.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M9 22V12h6v10" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 2. case-studies.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2V3z" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7V3z" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 3. resume.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M14 2v6h6M16 13H8M16 17H8M10 9H8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 4. advisory.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="10" stroke-width="2"/>
  <path d="M9.09 9a3 3 0 015.83 1c0 2-3 3-3 3M12 17h.01" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 5. writing.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 19l7-7 3 3-7 7-3-3z" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M18 13l-1.5-7.5L2 2l3.5 14.5L13 18l5-5zM2 2l7.586 7.586" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 6. external-link.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6M15 3h6v6M10 14L21 3" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 7. download.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 8. theme-toggle.svg (sun/moon)
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <path d="M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 9. menu.svg (hamburger)
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <path d="M3 12h18M3 6h18M3 18h18" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 10. close.svg (X)
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <path d="M18 6L6 18M6 6l12 12" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 11. arrow-right.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <path d="M5 12h14M12 5l7 7-7 7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 12. arrow-left.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <path d="M19 12H5M12 19l-7-7 7-7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

**Verification:**
- [ ] All 12 files created in `/static/images/icons/`
- [ ] All use `viewBox="0 0 24 24"`
- [ ] All use `stroke="currentColor"`
- [ ] All use `stroke-width="2"`

---

## Phase 2: Proof Signal Icons (3 icons)

**Directory:** `/static/images/icons/`

These icons are already implemented inline in the proof-tile.html partial, but should also exist as standalone files for flexibility.

### 1. compass.svg (Product Judgment)
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="10" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M12 2L12 6M12 18L12 22M2 12L6 12M18 12L22 12" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M12 8L14 14L8 12Z" fill="currentColor" stroke="none"/>
</svg>
```

### 2. circuit.svg (Technical Depth)
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <circle cx="4" cy="4" r="2" stroke-width="2"/>
  <circle cx="20" cy="4" r="2" stroke-width="2"/>
  <circle cx="4" cy="20" r="2" stroke-width="2"/>
  <circle cx="20" cy="20" r="2" stroke-width="2"/>
  <rect x="10" y="10" width="4" height="4" stroke-width="2"/>
  <path d="M6 4L10 10M14 10L18 4M6 20L10 14M14 14L18 20" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 3. mountain.svg (Execution Leadership)
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <path d="M2 20L8 8L12 14L18 4L22 12L22 20L2 20Z" stroke-width="2" stroke-linejoin="round"/>
  <path d="M18 4L18 2L20 2" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

**Verification:**
- [ ] 3 files created in `/static/images/icons/`
- [ ] Match inline SVGs in proof-tile.html
- [ ] Use category accent colors when rendered

---

## Phase 3: Case Study Category Icons (8 icons)

**Directory:** `/static/images/icons/`

### 1. product-strategy.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="3" stroke-width="2"/>
  <path d="M12 1v6m0 6v6M1 12h6m6 0h6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 2. technical-architecture.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <rect x="3" y="3" width="7" height="7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="14" y="3" width="7" height="7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="3" y="14" width="7" height="7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="14" y="14" width="7" height="7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 3. execution-leadership.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 15l8-8 8 8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M4 21V15h16v6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M12 7L12 3M10 3h4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 4. strategic-analysis.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <circle cx="11" cy="11" r="8" stroke-width="2"/>
  <path d="M21 21l-4.35-4.35" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M7 11l2 2 4-4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 5. incident-response.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 2L2 7l10 5 10-5-10-5z" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M2 17l10 5 10-5M2 12l10 5 10-5" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M12 22V12" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### 6. data-quality.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="10" stroke-width="2"/>
  <circle cx="12" cy="12" r="6" stroke-width="2"/>
  <circle cx="12" cy="12" r="2" fill="currentColor" stroke="none"/>
</svg>
```

### 7. decision-frameworks.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 2v20M5 9l7-7 7 7M5 15l7 7 7-7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="12" cy="12" r="3" stroke-width="2"/>
</svg>
```

### 8. phd-transfer.svg
```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg">
  <path d="M22 10v6M2 10l10-5 10 5-10 5z" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M6 12v5c3 2 6 2 9 0v-5" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

**Verification:**
- [ ] 8 files created in `/static/images/icons/`
- [ ] All follow consistent 24×24 style
- [ ] Icons are semantically appropriate for categories

---

## Phase 4: Case Study Hero Images (7 images)

**Directory:** `/static/images/case-studies/`

Create 7 hero images as **SVG files** (1200×600 viewBox). Use simple geometric shapes and data visualization aesthetics.

### General SVG Template
```svg
<svg viewBox="0 0 1200 600" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="gradient1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:[accent-color];stop-opacity:1" />
      <stop offset="100%" style="stop-color:[accent-color-tint];stop-opacity:0.3" />
    </linearGradient>
  </defs>
  <!-- Geometric shapes and patterns here -->
</svg>
```

### 1. scaling-ai-nominations-hero.svg

**Concept:** Grid expansion from 250 → 7000 nodes

**Implementation:**
```svg
<svg viewBox="0 0 1200 600" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="techGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#4A7C59;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#4A7C59;stop-opacity:0.3" />
    </linearGradient>
  </defs>
  <rect width="1200" height="600" fill="url(#techGradient)"/>

  <!-- Small grid (left side) -->
  <g opacity="0.6">
    <circle cx="100" cy="200" r="8" fill="#FDFCFA"/>
    <circle cx="150" cy="200" r="8" fill="#FDFCFA"/>
    <circle cx="200" cy="200" r="8" fill="#FDFCFA"/>
    <circle cx="100" cy="250" r="8" fill="#FDFCFA"/>
    <circle cx="150" cy="250" r="8" fill="#FDFCFA"/>
    <circle cx="200" cy="250" r="8" fill="#FDFCFA"/>
    <circle cx="100" cy="300" r="8" fill="#FDFCFA"/>
    <circle cx="150" cy="300" r="8" fill="#FDFCFA"/>
    <circle cx="200" cy="300" r="8" fill="#FDFCFA"/>
    <line x1="100" y1="200" x2="150" y2="200" stroke="#FDFCFA" stroke-width="2"/>
    <line x1="150" y1="200" x2="200" y2="200" stroke="#FDFCFA" stroke-width="2"/>
  </g>

  <!-- Arrow -->
  <path d="M 350 300 L 500 300" stroke="#FDFCFA" stroke-width="4" fill="none"/>
  <path d="M 480 285 L 500 300 L 480 315" stroke="#FDFCFA" stroke-width="4" fill="none"/>

  <!-- Large grid (right side) - many more nodes -->
  <g opacity="0.4">
    <!-- Generate many circles programmatically -->
    <!-- X from 600 to 1100, Y from 100 to 500, spacing 30px -->
  </g>

  <text x="150" y="400" font-family="Inter, sans-serif" font-size="48" font-weight="600" fill="#FDFCFA">250</text>
  <text x="900" y="550" font-family="Inter, sans-serif" font-size="72" font-weight="600" fill="#FDFCFA">7000</text>
</svg>
```

**Instructions for Agent:**
- Generate the large grid programmatically with many circles (simulate 7000 nodes visually with ~50-100 circles)
- Use sage green gradient (#4A7C59)
- Keep it abstract and simple

### 2. stat6-crisis-hero.svg

**Concept:** Pipeline break/repair visualization

```svg
<svg viewBox="0 0 1200 600" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="crisisGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#C17A47;stop-opacity:1" />
      <stop offset="50%" style="stop-color:#5A9367;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#5A9367;stop-opacity:0.3" />
    </linearGradient>
  </defs>
  <rect width="1200" height="600" fill="url(#crisisGradient)"/>

  <!-- Pipeline left (working) -->
  <rect x="50" y="280" width="300" height="40" rx="20" fill="#FDFCFA" opacity="0.8"/>

  <!-- Break/alert icon -->
  <circle cx="500" cy="300" r="60" fill="#C17A47" stroke="#FDFCFA" stroke-width="4"/>
  <text x="485" y="330" font-family="Inter, sans-serif" font-size="64" font-weight="700" fill="#FDFCFA">!</text>

  <!-- Arrow to fixed -->
  <path d="M 600 300 L 700 300" stroke="#FDFCFA" stroke-width="4" fill="none"/>
  <path d="M 680 285 L 700 300 L 680 315" stroke="#FDFCFA" stroke-width="4" fill="none"/>

  <!-- Pipeline right (fixed + monitoring) -->
  <rect x="750" y="280" width="400" height="40" rx="20" fill="#FDFCFA" opacity="0.8"/>
  <circle cx="950" cy="300" r="40" fill="#5A9367" stroke="#FDFCFA" stroke-width="4"/>
  <path d="M 930 300 L 945 315 L 970 285" stroke="#FDFCFA" stroke-width="4" fill="none" stroke-linecap="round" stroke-linejoin="round"/>

  <text x="50" y="200" font-family="Inter, sans-serif" font-size="36" font-weight="600" fill="#FDFCFA">Data Pipeline Failure</text>
  <text x="750" y="200" font-family="Inter, sans-serif" font-size="36" font-weight="600" fill="#FDFCFA">6-Week Recovery</text>
</svg>
```

### 3. learning-agenda-hero.svg

**Concept:** Decision tree with hypothesis branches

```svg
<svg viewBox="0 0 1200 600" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="primaryGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#2E5C8A;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#2E5C8A;stop-opacity:0.3" />
    </linearGradient>
  </defs>
  <rect width="1200" height="600" fill="url(#primaryGradient)"/>

  <!-- Root question node -->
  <circle cx="600" cy="100" r="50" fill="#FDFCFA" stroke="#2E5C8A" stroke-width="3"/>
  <text x="585" y="115" font-family="Inter, sans-serif" font-size="48" font-weight="700" fill="#2E5C8A">?</text>

  <!-- Branches -->
  <line x1="600" y1="150" x2="300" y2="300" stroke="#FDFCFA" stroke-width="3"/>
  <line x1="600" y1="150" x2="600" y2="300" stroke="#FDFCFA" stroke-width="3"/>
  <line x1="600" y1="150" x2="900" y2="300" stroke="#FDFCFA" stroke-width="3"/>

  <!-- Test nodes -->
  <rect x="250" y="300" width="100" height="60" rx="10" fill="#FDFCFA" opacity="0.9"/>
  <text x="280" y="340" font-family="Inter, sans-serif" font-size="20" font-weight="600" fill="#2E5C8A">Test A</text>

  <rect x="550" y="300" width="100" height="60" rx="10" fill="#FDFCFA" opacity="0.9"/>
  <text x="580" y="340" font-family="Inter, sans-serif" font-size="20" font-weight="600" fill="#2E5C8A">Test B</text>

  <rect x="850" y="300" width="100" height="60" rx="10" fill="#FDFCFA" opacity="0.9"/>
  <text x="880" y="340" font-family="Inter, sans-serif" font-size="20" font-weight="600" fill="#2E5C8A">Test C</text>

  <!-- Outcomes -->
  <line x1="300" y1="360" x2="250" y2="480" stroke="#FDFCFA" stroke-width="2"/>
  <line x1="300" y1="360" x2="350" y2="480" stroke="#FDFCFA" stroke-width="2"/>
  <circle cx="250" cy="480" r="20" fill="#5A9367"/>
  <circle cx="350" cy="480" r="20" fill="#C17A47"/>

  <text x="450" y="560" font-family="Inter, sans-serif" font-size="28" font-weight="600" fill="#FDFCFA">Pivot</text>
  <text x="800" y="560" font-family="Inter, sans-serif" font-size="28" font-weight="600" fill="#FDFCFA">Scale</text>
</svg>
```

### 4-7. Similar approach for remaining images

**Agent Instructions:**
- Follow the same pattern for XtalPi (balance/Venn diagram), Shiny (fragmented → unified grid), Metric Theater (funnel), Pipeline Latency (timeline)
- Use appropriate accent colors per category
- Keep geometric and abstract
- Include minimal text labels with Inter font
- Save as SVG files in `/static/images/case-studies/`

**Verification:**
- [ ] 7 SVG files created in `/static/images/case-studies/`
- [ ] Each is 1200×600 viewBox
- [ ] Uses category accent colors
- [ ] Simple, abstract data visualization style

---

## Phase 5: Background Patterns (2 patterns)

**Directory:** `/static/images/patterns/`

### 1. hero-pattern.svg

**Purpose:** Subtle background for hero section (5% opacity overlay)

```svg
<svg viewBox="0 0 800 800" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <pattern id="nodes" x="0" y="0" width="100" height="100" patternUnits="userSpaceOnUse">
      <circle cx="50" cy="50" r="2" fill="#2A2520" opacity="0.3"/>
      <line x1="50" y1="50" x2="100" y2="50" stroke="#2A2520" stroke-width="1" opacity="0.2"/>
      <line x1="50" y1="50" x2="50" y2="100" stroke="#2A2520" stroke-width="1" opacity="0.2"/>
    </pattern>
  </defs>
  <rect width="800" height="800" fill="url(#nodes)"/>
</svg>
```

### 2. divider-pattern.svg

**Purpose:** Ornamental section dividers

```svg
<svg viewBox="0 0 100 20" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="10" r="2" fill="#8B857E"/>
  <line x1="0" y1="10" x2="45" y2="10" stroke="#8B857E" stroke-width="1"/>
  <line x1="55" y1="10" x2="100" y2="10" stroke="#8B857E" stroke-width="1"/>
</svg>
```

**Verification:**
- [ ] 2 SVG files created in `/static/images/patterns/`
- [ ] Subtle, minimal patterns
- [ ] Optimized for CSS background usage

---

## Phase 6: In-Content Diagrams (Optional - Generate 2-3 examples)

**Directory:** `/static/images/diagrams/`

**Agent Discretion:** Generate 2-3 example diagrams that could be used in case studies. These don't need to match specific case studies perfectly - they serve as templates.

### Example 1: Before/After Comparison
```svg
<svg viewBox="0 0 800 400" xmlns="http://www.w3.org/2000/svg">
  <text x="100" y="40" font-family="Inter, sans-serif" font-size="24" font-weight="600" fill="#2A2520">Before</text>
  <rect x="50" y="100" width="300" height="200" rx="12" fill="#EBE8E3" stroke="#8B857E" stroke-width="2"/>
  <!-- Add fragmented elements inside -->

  <text x="550" y="40" font-family="Inter, sans-serif" font-size="24" font-weight="600" fill="#2A2520">After</text>
  <rect x="500" y="100" width="300" height="200" rx="12" fill="#EBE8E3" stroke="#5A9367" stroke-width="2"/>
  <!-- Add unified elements inside -->
</svg>
```

Save as: `before-after-template.svg`

### Example 2: Decision Tree
Simple decision tree with 3 options and outcomes.

Save as: `decision-tree-template.svg`

### Example 3: Timeline
Timeline showing progression over weeks.

Save as: `timeline-template.svg`

**Verification:**
- [ ] 2-3 example diagrams created
- [ ] Use design system colors
- [ ] Simple, reusable patterns

---

## Final Verification Checklist

**Icon Files (23):**
- [ ] 12 navigation icons
- [ ] 3 proof signal icons
- [ ] 8 category icons

**Hero Images (7):**
- [ ] scaling-ai-nominations-hero.svg
- [ ] stat6-crisis-hero.svg
- [ ] learning-agenda-hero.svg
- [ ] xtalpi-build-buy-hero.svg
- [ ] shiny-standardization-hero.svg
- [ ] metric-theater-hero.svg
- [ ] pipeline-latency-hero.svg

**Patterns (2):**
- [ ] hero-pattern.svg
- [ ] divider-pattern.svg

**Example Diagrams (2-3):**
- [ ] 2-3 reusable diagram templates

**Total Assets:** 32-35 files

---

## Execution Notes for Agent

1. **Autonomy:** Generate all assets without stopping for approval between phases. Present the complete set at the end.

2. **SVG Optimization:** Ensure all SVG files are clean (no unnecessary attributes, consistent formatting).

3. **File Naming:** Use kebab-case for all filenames (e.g., `product-strategy.svg`, not `ProductStrategy.svg`).

4. **Color Accuracy:** Use exact hex codes from design system reference.

5. **Testing:** After generation, verify files exist in correct directories using `ls` commands.

6. **Build Verification:** Run `hugo` after asset creation to ensure no build errors.

---

## Success Criteria

- [ ] All 32-35 asset files exist in correct directories
- [ ] All icons follow 24×24 viewBox standard
- [ ] All hero images use 1200×600 viewBox
- [ ] All SVGs use design system colors
- [ ] Hugo build succeeds without errors
- [ ] No XML declarations or unnecessary SVG attributes

**End of Asset Generation Plan**
