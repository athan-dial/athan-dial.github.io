# Athan Dial Portfolio Site

## What This Is

Personal/professional portfolio website for Athan Dial — a landing page for future employers and networking contacts. Built with Hugo, deployed to GitHub Pages. Targeting senior tech roles at the intersection of data science and product management.

## Core Value

**Demonstrate strategic credibility through the site itself.** The site is not just a container for a resume — it's evidence of communication quality, strategic thinking, and decision science rigor. Every element should signal "this person operates at a senior level."

## Requirements

### Validated

- ✓ Hugo static site generator configured — existing
- ✓ GitHub Pages deployment (docs/ directory) — existing
- ✓ Basic content structure (pages, case studies scaffolded) — existing
- ✓ Git version control on gh-pages branch — existing

### Active (v1)

- [ ] Theme migration from Blowfish to Hugo Resume
- [ ] Resume content migrated and structured for new theme
- [ ] Basic about/profile section populated
- [ ] Contact information and social links configured
- [ ] Site builds and deploys successfully with new theme

### v2 (Deferred)

- [ ] Voice and positioning documentation (brand guide)
- [ ] 2-3 polished case studies demonstrating decision science
- [ ] Thought leadership / writing section
- [ ] Skills inventory with appropriate depth
- [ ] Portfolio/projects showcase

### Out of Scope

- Blog/frequent posting — Focus is portfolio, not content marketing
- Complex JavaScript interactions — Static site, minimal dependencies
- Custom theme development — Using Hugo Resume as-is with configuration
- Case study rewrites in v1 — Deferred to v2 after theme is stable

## Context

**Target Audience:**
- Hiring managers and recruiters for senior PM/DS roles
- Peers and potential collaborators for networking
- Anyone evaluating professional credibility

**Target Positioning:**
- PhD → Product leader (technical credibility + business sense)
- Decision science framing (systematic approach to high-stakes choices, not intuition)
- AI-native practitioner (actually building agentic systems, not just talking about AI)
- Translator-strategist-decision architect (generalist strength, multi-faceted view)

**Current Role:**
- Head of Decision Science & Product (Associate Director) at Montai Therapeutics
- Looking for steps up in strategy, impact, demonstrating strategic foresight

**Voice Anti-Patterns (what NOT to sound like):**
- Generic PM speak: "Drove cross-functional alignment to deliver value"
- Academic/dry: Inaccessible to business readers
- Hype-driven AI bro: Buzzwords without substance

**Voice Target:**
- Substantive but accessible
- Shows work without overwhelming
- Confident without arrogant
- Technical depth that serves the reader, not signals the author

**New Theme:**
- Hugo Resume (https://github.com/eddiewebb/hugo-resume)
- StartBootstrap port, professional portfolio layout
- Integrated Netlify CMS (optional), social handles, skills inventory, work history, portfolio sections

**Existing Assets:**
- Resume PDF at external path (source of truth for work history)
- 7 case study drafts (to be rewritten in v2)
- Codebase documentation in .planning/codebase/

## Constraints

- **Platform**: Hugo static site generator (already configured, stay with Hugo)
- **Hosting**: GitHub Pages from docs/ directory on gh-pages branch
- **Theme**: Hugo Resume — use as primary theme, migrate away from Blowfish
- **Timeline**: v1 focused on working theme + resume (not full content)
- **Content**: Case studies and thought leadership deferred to v2

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Hugo Resume over custom theme | Purpose-built for professional portfolios; faster than building from scratch | — Pending |
| v1 = theme + resume only | Ship working site fast, iterate on content with stable foundation | — Pending |
| Full case study rewrite in v2 | Existing drafts are placeholders; need proper voice/positioning work first | — Pending |
| Defer voice/branding to v2 | Theme migration is prerequisite; can't polish content without stable structure | — Pending |

---
*Last updated: 2026-02-04 after initialization*
