# Testing Patterns

**Analysis Date:** 2026-02-04

## Test Framework

**Runner:**
- Not detected - This is a static site generator project using Hugo, not a code application with unit tests

**Assertion Library:**
- Not applicable

**Run Commands:**
```bash
hugo server -D              # Local development with live reload
hugo                        # Build production site
hugo -D                     # Build with draft content included
rm -rf docs/ && hugo        # Clean rebuild
```

## Test File Organization

**Location:**
- No test files found (`.test.js`, `.spec.js`, `.test.ts`, etc.)
- No test directories (`__tests__`, `tests/`, `test/`)

**Naming:**
- Not applicable

**Structure:**
- Not applicable

## Test Structure

**Suite Organization:**
This codebase has no automated test suite. Testing is manual and performed during development via Hugo's live server.

**Patterns:**
- Local verification: `hugo server -D` runs on `http://localhost:1313` with live reload for manual testing
- Build verification: `hugo` command compiles all templates, CSS, and markdown to `docs/` directory
- Failures: Hugo outputs errors to CLI during build, halting the build process

## Mocking

**Framework:** Not applicable

**Patterns:**
Not applicable

**What to Mock:**
Not applicable

**What NOT to Mock:**
Not applicable

## Fixtures and Factories

**Test Data:**
Not applicable for static site

**Content Development:**
Content files in `content/` serve as test data:
- `content/case-studies/*.md` — Case study fixtures for layout testing
- `content/_index.md` — Homepage layout fixture
- `content/resume.md` — Resume page fixture
- `content/consulting.md` — Consulting page fixture

**Location:**
- Actual content: `content/` directory
- Drafts for testing: Set `draft: true` in frontmatter to exclude from production builds, keep in `hugo server -D`

## Coverage

**Requirements:** None enforced

**View Coverage:**
Not applicable - no test coverage metrics exist

## Test Types

**Unit Tests:**
Not present in this codebase

**Integration Tests:**
Manual integration testing occurs during `hugo server` development:
- Template rendering with actual markdown content
- CSS cascade with theme overrides
- Link integrity between pages
- Asset loading (fonts, images, SVG icons)

**E2E Tests:**
Not automated. Manual verification performed by:
1. Running `hugo server` locally
2. Navigating all pages in browser
3. Testing responsive breakpoints (desktop, tablet, mobile)
4. Verifying dark/light mode toggle
5. Checking link functionality

No framework detected (no Playwright, Cypress, Puppeteer config).

## Testing Strategy & Verification Approach

**Build-Time Verification:**
Hugo's build process catches:
- Template syntax errors (stops build)
- Broken variable references (stops build)
- Invalid markdown (processed but warns)
- Missing assets referenced in templates

Example: If a partial references `.Params.undefined_field`, Hugo renders empty string (no error), but visual inspection catches missing content.

**Runtime Verification (Local):**
During `hugo server` development:
- Live reload catches template/CSS changes immediately (3-5 second compilation)
- Browser console shows JavaScript errors (if any added)
- Network inspector shows CSS/image loading
- Manual dark mode toggle tests theme variable overrides

**Production Verification:**
Before deploying to `gh-pages` branch:
1. Run `hugo` to verify clean build
2. Check `docs/` directory generated correctly
3. Visual spot-check of generated HTML files for correct structure
4. Verify CSS bundle generated with correct hash-based filename

## Common Patterns

**Content Validation:**

Case study frontmatter validation (observed pattern in `content/case-studies/xtalpi-build-vs-buy-analysis-montai.md`):
```markdown
---
title: "Build vs Buy: Strategic Analysis"
date: 2025-11-15
description: "Short summary"
problem_type: "product-strategy"      # Must match enum: product-strategy, technical-architecture, etc.
scope: "organization"                  # Must match enum: team, organization, individual
complexity: "high"                     # Must match enum: high, medium, low
tags: ["tag1", "tag2"]
---
```

No automated validation detected. Human review ensures correct enum values and metadata completeness.

**Template Conditional Testing:**

Test template conditionals by toggling fields in markdown:
- Missing `hero_image`: Placeholder SVG renders instead of image
- Missing `problem_type`: No category tag displays
- Empty `description`: No excerpt renders

Verify these paths using `hugo server` and inspecting rendered HTML.

**CSS Testing:**

Manual testing of CSS patterns:
1. Light mode (default): Colors use `:root` variables
2. Dark mode: Toggle `html.dark` class, colors switch to dark palette
3. Responsive: Resize browser window, verify layout shifts at 768px breakpoint
4. Spacing: Use browser DevTools to inspect computed padding/margin matches `--space-*` variables

**Build Artifact Verification:**

After `hugo` build, verify `docs/` contains:
- `index.html` (homepage)
- `case-studies/` directory with subdirectories for each case study
- `css/main.bundle.min.[hash].css` (fingerprinted CSS with theme overrides)
- All assets loaded correctly (fonts in `/fonts/`, images in expected paths)

## Manual Testing Checklist

While no automated tests exist, use this checklist for development verification:

**Template Changes:**
- [ ] Run `hugo server -D` and navigate all template partials
- [ ] Check both case study card grid and detail pages render
- [ ] Verify conditional content (hero image fallback, metadata tags) renders correctly

**CSS Changes:**
- [ ] Verify light mode appearance
- [ ] Toggle dark mode, check all colors update
- [ ] Resize to tablet (768px) and mobile, verify layout shifts
- [ ] Check that overridden theme styles apply (font family, spacing)

**Content Changes:**
- [ ] Add case study with all fields populated → verify renders
- [ ] Add case study with missing optional fields → verify graceful fallback
- [ ] Verify new content appears in grid view and detail pages

**Production Build:**
- [ ] Run `hugo` (non-draft build)
- [ ] Verify no errors in output
- [ ] Check `docs/` directory contains all expected files
- [ ] Spot-check generated HTML for correct structure

---

*Testing analysis: 2026-02-04*
