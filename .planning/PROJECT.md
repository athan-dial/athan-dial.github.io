# Athan Dial Portfolio Site

## What This Is

Personal/professional portfolio website and automated content publishing system for Athan Dial. Two interconnected sites: a Hugo Resume portfolio at athan-dial.github.io and a Quartz digital garden (Model Citizen) at athan-dial.github.io/model-citizen/. Content flows from multiple sources through an AI enrichment pipeline into a curated knowledge base.

## Core Value

**Demonstrate strategic credibility through the site itself.** The portfolio signals senior-level communication quality and decision science rigor. Model Citizen demonstrates AI-native thinking by actually building an automated knowledge system.

## Requirements

### Validated

- ✓ Hugo Resume theme installed, configured, deployed — v1.0
- ✓ Complete professional profile (experience, skills, education, bio, contact) — v1.0
- ✓ Executive blue color system with dark mode — v1.0
- ✓ GitHub Pages deployment verified — v1.0
- ✓ Mobile responsive validated — v1.0
- ✓ Quartz site scaffolded and deployed at /model-citizen/ — v1.1
- ✓ YouTube transcript ingestion pipeline — v1.1
- ✓ Claude Code SSH agent integration — v1.1
- ✓ Enrichment pipeline (summaries, tags, ideas, drafts) — v1.1
- ✓ Obsidian review/approval workflow — v1.1
- ✓ Publish sync with idempotency — v1.1
- ✓ Multi-source ingestion (web, Slack, Outlook) — v1.1
- ✓ Brand-consistent Quartz theming — v1.1

### Active

## Current Milestone: v1.2 GoodLinks Ingestion

**Goal:** Add GoodLinks as an automated content source feeding the Model Citizen enrichment pipeline, turning saved articles into blog fodder.

**Target features:**
- GoodLinks data extraction (discover export/sync format, build parser)
- Article content fetching and vault note creation
- Integration with existing enrichment pipeline (summaries, tags, ideas)
- Automated daily scanning alongside Slack/Outlook sources

### Out of Scope

- Blog/frequent posting — Focus is portfolio, not content marketing
- Custom theme development — Using Hugo Resume with configuration
- Case study rewrites — Need voice/positioning research first (ChatGPT Deep Research)
- n8n full orchestration — Host scripts for v1; n8n workflow orchestration deferred
- Podcast ingestion — YouTube only for now
- Semantic search/embeddings — Grep-based for v1

## Context

**Current State (v1.1 shipped 2026-02-14):**
- Portfolio: Hugo Resume, 13 requirements delivered, live at athan-dial.github.io
- Model Citizen: Quartz + Obsidian vault + enrichment pipeline, 21 requirements delivered
- Tech stack: Hugo, Quartz, n8n (Docker), Claude Code (SSH), bash scripts, Python helpers
- Two GitHub repos: athan-dial.github.io (portfolio) and model-citizen (Quartz site)
- Vault: iCloud Obsidian directory (2B-new/700 Model Citizen/)

**Target Audience:**
- Hiring managers/recruiters for senior PM/DS roles
- Peers and collaborators
- Anyone evaluating professional credibility

**Target Positioning:**
- PhD → Product leader (technical credibility + business sense)
- Decision science framing (systematic approach, not intuition)
- AI-native practitioner (actually building agentic systems)

## Constraints

- **Platform**: Hugo (portfolio) + Quartz (Model Citizen)
- **Hosting**: GitHub Pages from two repos
- **Content**: Case studies deferred until ChatGPT Deep Research outputs available
- **Employer Safety**: Cannot appear to run active consulting (use "Advisory" language)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Hugo Resume over custom theme | Purpose-built for professional portfolios | ✓ Good — clean single-page layout works |
| Executive blue (#1E3A5F) palette | Professional executive positioning, Apple aesthetic | ✓ Good — consistent across both sites |
| Separate repos (portfolio + model-citizen) | Cleaner separation, independent deployment | ✓ Good — avoids cross-contamination |
| Host-side yt-dlp (not container) | Hardened n8n image lacks Python | ✓ Good — simpler architecture |
| Claude Code SSH agent pattern | Automation with AI synthesis | ✓ Good — reliable with timeout/idempotency |
| Tag-based content curation | More flexible than folder-based routing | ✓ Good — works with Obsidian Auto Note Mover |
| Explicit publish gate | Safety — daily runs never auto-publish | ✓ Good — non-negotiable design principle |
| Public vault strategy | Entire vault public; Quartz gates rendering | ⚠️ Revisit — consider if sensitive content enters pipeline |

---
*Last updated: 2026-02-19 after v1.2 milestone start*
