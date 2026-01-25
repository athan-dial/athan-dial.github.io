# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal portfolio website built with **Hugo** (v0.154.3+extended) using the **Blowfish theme** (v2.96.0). The site showcases a data science and product leadership portfolio with a clean, minimal, Apple-inspired design aesthetic. It is deployed to GitHub Pages from the `docs/` directory.

**Key characteristics:**
- Focus on "decision evidence, not achievements" - case studies demonstrate product judgment, technical depth, and execution leadership
- Custom design system based on TikTok Sans font with near-monochromatic colors
- Minimal, borderless card-based UI with no background textures
- Responsive design with dark mode support

## Build & Development Commands

### Local Development
```bash
# Serve site locally with live reload on http://localhost:1313
hugo server -D

# Serve with drafts and watch for changes
hugo server --buildDrafts --watch
```

### Build for Production
```bash
# Build site to docs/ directory (GitHub Pages publishDir)
hugo

# Build with drafts included
hugo -D

# Clean and rebuild
rm -rf docs/ && hugo
```

### Theme Management
```bash
# Update Blowfish theme
hugo mod get -u github.com/nunocoracao/blowfish/v2

# Verify module dependencies
hugo mod graph
```

## Architecture

### Content Structure
- `content/_index.md` - Homepage with "Proof Signals" tiles
- `content/resume.md` - Resume page
- `content/case-studies/` - Case study articles demonstrating decision-making and outcomes

### Layouts & Partials
- `layouts/case-studies/list.html` - Grid view for case studies listing
- `layouts/partials/proof-tile.html` - Reusable component for decision evidence cards
- `layouts/partials/case-study-card.html` - Card component for case study previews
- `layouts/partials/case-study-section.html` - Section component for case study detail pages

### Custom Styling System
- `assets/css/custom.css` - Complete custom design system that overrides Blowfish theme
- Self-hosted TikTok Sans fonts in `static/fonts/`
- CSS variables for colors, typography, spacing, and effects
- Separate light/dark mode color systems

**Key design principles:**
- Typography: Light weights (300) as default, medium (400-500) for emphasis
- Colors: Near-monochromatic with subtle Apple-style grays (#1D1D1F, #86868B, #AEAEB2)
- Spacing: 8-point grid system (0.5rem to 8rem scale) - **favor generous spacing**
- Layout: Max-width 980px for main content, 680px for prose
- Cards: **Full rounded borders (32px)** with subtle hover states, no shadows or dramatic transforms
- Navigation: Pill-shaped buttons (980px border-radius) with comfortable padding

### Configuration Files
- `config/_default/hugo.toml` - Main Hugo settings, baseURL, taxonomies
- `config/_default/params.toml` - Blowfish theme parameters, layout settings
- `config/_default/languages.en.toml` - Site metadata and author info
- `config/_default/menus.en.toml` - Navigation menu structure
- `go.mod` - Hugo module dependencies (Blowfish theme)

### Theme Overrides
Custom CSS extensively overrides Blowfish theme defaults:
- Forces TikTok Sans on all elements with `!important`
- Removes centered alignment, keeps everything left-aligned except hero
- Eliminates background colors/textures (transparent backgrounds)
- Customizes proof tiles and case study cards with borderless design
- Implements custom navigation and footer styling

## Case Study Content Format

Case studies follow a structured format with frontmatter metadata:

```markdown
---
title: "Title"
date: 2026-01-09
description: "Brief summary"
problem_type: "product-strategy" | "technical-architecture" | etc.
scope: "team" | "organization" | "individual"
complexity: "high" | "medium" | "low"
tags: ["tag1", "tag2"]
---

## Context
[Problem space and stakes]

## Ownership
[What you owned vs influenced]

## Decision Frame
[Problem statement, options, decision rationale, constraints]

## Outcome
[Primary outcomes, guardrails, second-order effects, limitations]

## Reflection
[What you'd do differently, lessons learned, future implications]
```

## Important Notes

1. **GitHub Pages Deployment**: Site builds to `docs/` directory (configured in hugo.toml), which is the publishDir for GitHub Pages on the `gh-pages` branch

2. **Font Loading**: TikTok Sans fonts must remain in `static/fonts/` and are referenced as `/fonts/` in CSS due to Hugo's static asset handling

3. **Theme Customization**: Heavy CSS overrides mean theme updates should be tested carefully. The custom.css file is the source of truth for styling.

4. **Content Philosophy**: All content emphasizes:
   - Decision systems over one-off analyses
   - Measurable outcomes over activity metrics
   - Product judgment + technical depth + execution leadership
   - Candid reflection on trade-offs and limitations

5. **BMAD System**: The `_bmad/` directory contains an agent workflow system (unrelated to the Hugo site) - ignore this when working on the portfolio site itself

6. **Content Authenticity Constraint**: Current portfolio content is fabricated/generic and does NOT sound like Athan. All future content creation must be informed by ChatGPT Deep Research outputs (Voice & Style Guide + Montai Work Archaeology). Do NOT write new case studies or major content without this research data.

7. **Employer Safety**: Portfolio must not appear to be running an active consulting business while employed at Montai. Use "Advisory" language, avoid pricing/timeframes, frame as informal thought partnership.

## Content Authenticity & Voice

**Critical Problem**: AI-generated content lacks Athan's authentic voice and factual basis, undermining the "decision evidence, not achievements" brand positioning.

### ChatGPT Deep Research Integration

Two comprehensive research prompts have been created to extract authentic content:

**Location**: `/Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/000 System/01 Inbox`

1. **Voice & Style Guide** (`ChatGPT Deep Research - Voice and Style Guide.md`)
   - Extracts signature vocabulary, sentence patterns, tone from Slack/Email/Confluence
   - Identifies anti-patterns (words/phrases Athan never uses)
   - Provides context-specific style guides (Slack vs Email vs Documentation)
   - Outputs 50+ example quotes showing authentic voice

2. **Montai Work Archaeology** (`ChatGPT Deep Research - Montai Work Archaeology.md`)
   - Documents factual project details from 2023-2026 (decisions, metrics, stakeholders)
   - Extracts 5-10 decision system case studies with real context
   - Provides 30+ quantitative outcomes with before/after data
   - Maps PhD → Product skill transfer examples

### Content Creation Workflow

**Before Deep Research Results**:
- ❌ Do NOT write new case studies (lack factual details)
- ❌ Do NOT rewrite resume content (lack authentic voice + project details)
- ❌ Do NOT write About page origin story (lack authentic narrative)
- ✅ CAN do structural work (scaffolding, templates, design)
- ✅ CAN do technical improvements (SEO, analytics, performance)

**After Deep Research Results**:
1. Apply Voice & Style Guide to all writing
2. Use signature vocabulary and sentence patterns from research
3. Reference factual project details from Work Archaeology
4. Include real metrics, stakeholders, decision contexts
5. Avoid generic AI patterns ("I helped...", "I implemented...")

### Authentic Voice Indicators
When Deep Research completes, look for:
- Signature phrases Athan uses repeatedly (e.g., "decision velocity", "metric theater")
- Technical terminology preferences
- Sentence structure patterns (fragments, parallel structure, emphasis techniques)
- Tradeoff framing style ("X vs Y" structures)
- How he expresses uncertainty and limitations

## Design System Refinements

### Apple-Inspired Aesthetic Principles

**Updated from implementation learnings** (Commit: 4647c51):

1. **Generous Padding**: Never default to minimal spacing - Apple designs breathe
   - Navigation pills: 0.625rem/1.25rem (not 0.5rem/1rem)
   - Card padding: var(--space-lg) horizontal + vertical (not zero padding)
   - Tag spacing: 0.75rem gaps, 0.375rem/0.75rem padding

2. **Border Radius Consistency**:
   - Large cards: 32px (desktop), 24px (mobile)
   - Navigation pills: 980px (full pill shape)
   - Tags: 6px (subtle rounding)

3. **Typography Hierarchy**:
   - Use full type scale progression (don't skip sizes)
   - Card titles: text-2xl (24px), not text-xl (20px)
   - Body text: text-base (16px) minimum for readability
   - Small text: text-sm (14px) for metadata only

4. **Subtle State Changes**:
   - Hover: Border color + background color (no shadows)
   - Transform: Maximum 2px translateY (no dramatic effects)
   - Transitions: 0.2-0.3s ease (fast and responsive)

5. **Full Borders Over Partial**:
   - Rounded cards need complete borders (1.5px solid)
   - Border-top-only approach doesn't match Apple aesthetic
   - Use subtle border colors (--border-light, --border-medium)

### Design System Files

**Primary**: `assets/css/custom.css`
- CSS variables in `:root` (light mode) and `html.dark` (dark mode)
- Heavy use of `!important` to override Blowfish theme
- Hugo compiles to `docs/css/main.bundle.min.[hash].css`

**Key CSS Variables**:
```css
--space-xs: 0.5rem;
--space-sm: 1rem;
--space-md: 1.5rem;
--space-lg: 2.5rem;
--space-xl: 4rem;
--space-2xl: 6rem;
--space-3xl: 8rem;

--text-xs: 0.75rem;   /* 12px */
--text-sm: 0.875rem;  /* 14px */
--text-base: 1rem;    /* 16px */
--text-lg: 1.125rem;  /* 18px */
--text-xl: 1.25rem;   /* 20px */
--text-2xl: 1.5rem;   /* 24px */
--text-3xl: 2rem;     /* 32px */
```

### When to Update Styles
- **Minor tweaks** (spacing, colors): Edit `custom.css` directly
- **Major changes** (layout, structure): Consider if Hugo templates need updates
- **Always test**: Light + dark mode, mobile + desktop
- **Rebuild**: Run `hugo` to compile changes to `docs/`

## Employer Safety Guidelines

**Constraint**: Cannot appear to be running active consulting business while employed at Montai.

### Safe Language Patterns
✅ **Use**:
- "Advisory & Thought Partnership" (not "Consulting Services")
- "I occasionally advise teams..." (informal, infrequent)
- "Topics I Think About" (intellectual interest)
- "Let's Connect" (networking)
- "Conversation" or "Chat" (casual)

❌ **Avoid**:
- Explicit pricing ($18k-25k, etc.)
- Timeframes (4-6 weeks, etc.)
- "Engagement Types" with deliverables
- "I take on X engagements per quarter"
- FAQ about equity, retainer, implementation
- "Discovery call", "Booking", "Investment"

### Strategic Balance
- Door remains open for advisory opportunities (not burning bridges)
- Positioned as thought partnership, not consulting firm
- Hiring goal intact (case studies demonstrate capability)
- Montai employer risk minimized

## Common Tasks

### Adding a New Case Study
1. Create markdown file in `content/case-studies/`
2. Use the frontmatter structure shown above
3. Follow the section structure: Context → Ownership → Decision Frame → Outcome → Reflection
4. Build and preview: `hugo server`

### Updating Styles
1. Edit `assets/css/custom.css`
2. Use CSS variables defined in `:root` and `html.dark`
3. Test both light and dark modes
4. Verify responsive behavior (mobile, tablet, desktop)

### Modifying Homepage Proof Tiles
1. Edit `content/_index.md`
2. Tiles are defined in HTML within the markdown
3. Use classes: `proof-tile`, `proof-tile__title`, `proof-tile__content`, `proof-tile__intro`
4. Grid adapts: 3 columns (desktop), 2 columns (tablet), 1 column (mobile)

### Updating Navigation
1. Edit `config/_default/menus.en.toml`
2. Hugo will automatically generate nav from menu items

### Theme Configuration Changes
1. For layout/display settings: `config/_default/params.toml`
2. For site metadata: `config/_default/hugo.toml` or `config/_default/languages.en.toml`
