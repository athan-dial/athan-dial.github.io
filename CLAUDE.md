# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal portfolio website built with **Hugo** (v0.154.3+extended), **themeless** (no external theme dependency). The site showcases a data science and product leadership portfolio using the **"Clinical Architect"** design system — a high-impact, editorial aesthetic designed in Google Stitch. It is deployed to GitHub Pages from the `docs/` directory.

**Key characteristics:**
- Focus on "decision evidence, not achievements" - case studies demonstrate product judgment, technical depth, and execution leadership
- "Clinical Architect" design system: Deep Teal (#0D9488), Manrope + Space Grotesk, extralight headlines, uppercase monospaced labels
- Soft-card UI with teal-tinted borders, generous spacing, glassmorphic navigation
- Light-first design with dark mode toggle

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

## Architecture

### Content Structure
- `content/_index.md` - Homepage intro text
- `content/about.md` - About page
- `content/advisory.md` - Advisory & Thought Partnership (alias /consulting)
- `content/resume.md` - Resume page
- `content/writing.md` - Writing page
- `content/case-studies/` - Case study articles demonstrating decision-making and outcomes

### Layouts & Partials
- `layouts/_default/baseof.html` - Base HTML shell (Google Fonts, Hugo Pipes CSS, dark mode script)
- `layouts/_default/single.html` - Default page layout
- `layouts/_default/list.html` - Default list layout
- `layouts/index.html` - Homepage with hero + case study grid
- `layouts/case-studies/single.html` - Case study detail with back link + tags
- `layouts/case-studies/list.html` - Case study grid listing
- `layouts/partials/nav.html` - Glassmorphic fixed navigation
- `layouts/partials/footer.html` - Footer with uppercase monospaced links
- `layouts/partials/case-study-card.html` - Card component (category/title/excerpt/arrow)

### Design System: "The Clinical Architect"

**Source of truth**: `assets/css/main.css` (~400 lines, zero `!important`)

**Fonts** (Google Fonts CDN):
- `Manrope` — Headlines (weight 200 extralight) and body (weight 300-400)
- `Space Grotesk` — Labels, navigation, tags, metadata (always uppercase, wide tracking)

**Color Palette (Light Mode Default)**:
```css
--color-primary: #0D9488;        /* Deep Teal */
--color-primary-hover: #0F766E;  /* Darker teal */
--color-bg: #F8F9FA;             /* Soft off-white */
--color-surface: #FFFFFF;         /* White cards */
--color-text: #1F2937;           /* Dark gray */
--color-text-secondary: #4B5563; /* Medium gray */
--color-text-muted: #94A3B8;     /* Light gray (labels) */
```

**Dark Mode** (`html.dark`):
```css
--color-primary: #2DD4BF;  /* Bright teal */
--color-bg: #0F172A;       /* Deep navy */
--color-surface: #1E293B;  /* Dark slate */
--color-text: #F1F5F9;     /* Near-white */
```

**Key Design Principles:**
1. **Extralight headlines (200 weight)** — Display and section titles use Manrope extralight, uppercase
2. **Uppercase monospaced labels** — All section labels, nav links, tags use Space Grotesk 11px, uppercase, 0.2em+ tracking
3. **Soft-card pattern** — White bg, 1px teal-tinted border (10% opacity), hover intensifies to 30% + shadow
4. **Glassmorphic nav** — Fixed position, `backdrop-filter: blur(20px)`, semi-transparent bg
5. **Generous padding** — Cards use 3rem padding, sections have 10rem vertical padding
6. **No-line rule** — Depth via background tonal shifts, not 1px borders (except soft-card borders)
7. **Airy gradient** — Subtle radial teal gradients on body background

**Spacing:**
```css
--space-xs: 0.5rem;   --space-sm: 1rem;    --space-md: 1.5rem;
--space-lg: 2.5rem;   --space-xl: 4rem;    --space-2xl: 6rem;
--space-3xl: 10rem;
```

### Configuration Files
- `config/_default/hugo.toml` - Main Hugo settings, baseURL, taxonomies
- `config/_default/params.toml` - Site parameters (name, email, social handles)
- `config/_default/languages.en.toml` - Site metadata and author info
- `config/_default/menus.en.toml` - Navigation menu structure
- `config/_default/module.toml` - Empty (no theme imports)

## Case Study Content Format

Case studies follow a structured format with frontmatter metadata:

```markdown
---
title: "Title"
date: 2026-01-09
description: "Brief summary"
problem_type: "product-strategy" | "technical-architecture" | "decision-systems" | "execution-leadership"
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

2. **Themeless Architecture**: No Hugo theme dependency. All layouts are custom in `layouts/`. The only external dependency is Google Fonts (Manrope + Space Grotesk) loaded via CDN in baseof.html.

3. **Design System Source**: The "Clinical Architect" design was created in Google Stitch (project ID: `615008401046984188`). The canonical reference screen is "Landing Page: Clinical Architect Master Cut (Final Sync)".

4. **Content Philosophy**: All content emphasizes:
   - Decision systems over one-off analyses
   - Measurable outcomes over activity metrics
   - Product judgment + technical depth + execution leadership
   - Candid reflection on trade-offs and limitations

5. **Content Authenticity Constraint**: Current portfolio content is fabricated/generic and does NOT sound like Athan. All future content creation must be informed by ChatGPT Deep Research outputs (Voice & Style Guide + Montai Work Archaeology). Do NOT write new case studies or major content without this research data.

6. **Employer Safety**: Portfolio must not appear to be running an active consulting business while employed at Montai. Use "Advisory" language, avoid pricing/timeframes, frame as informal thought partnership.

## Content Authenticity & Voice

**Critical Problem**: AI-generated content lacks Athan's authentic voice and factual basis, undermining the "decision evidence, not achievements" brand positioning.

### ChatGPT Deep Research Integration

Two comprehensive research prompts have been created to extract authentic content:

**Location**: `/Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/000 System/01 Inbox`

1. **Voice & Style Guide** (`ChatGPT Deep Research - Voice and Style Guide.md`)
2. **Montai Work Archaeology** (`ChatGPT Deep Research - Montai Work Archaeology.md`)

### Content Creation Workflow

**Before Deep Research Results**:
- Do NOT write new case studies (lack factual details)
- Do NOT rewrite resume content (lack authentic voice + project details)
- CAN do structural work (scaffolding, templates, design)
- CAN do technical improvements (SEO, analytics, performance)

**After Deep Research Results**:
1. Apply Voice & Style Guide to all writing
2. Reference factual project details from Work Archaeology
3. Avoid generic AI patterns ("I helped...", "I implemented...")

## Employer Safety Guidelines

**Constraint**: Cannot appear to be running active consulting business while employed at Montai.

### Safe Language Patterns
- "Advisory & Thought Partnership" (not "Consulting Services")
- "I occasionally advise teams..." (informal, infrequent)
- "Let's Connect" (networking)

### Avoid
- Explicit pricing, timeframes, engagement types with deliverables
- "Discovery call", "Booking", "Investment"

## Common Tasks

### Adding a New Case Study
1. Create markdown file in `content/case-studies/`
2. Use the frontmatter structure shown above
3. Follow the section structure: Context -> Ownership -> Decision Frame -> Outcome -> Reflection
4. Build and preview: `hugo server -D`

### Updating Styles
1. Edit `assets/css/main.css`
2. Use CSS variables defined in `:root` (light) and `html.dark` (dark)
3. Test both light and dark modes
4. Rebuild: `hugo`

### Updating Navigation
1. Edit `config/_default/menus.en.toml`
2. Hugo will automatically generate nav from menu items

### Updating the Design
The design was created in Google Stitch. To iterate:
1. Use the Stitch MCP (`mcp__stitch__*` tools) to pull or edit screens
2. Project ID: `615008401046984188`
3. Map Stitch HTML/CSS changes to `assets/css/main.css` and Hugo layouts
