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

- ✓ GoodLinks SQLite scanner with incremental state and iCloud sync buffer — v1.2
- ✓ Vault notes with frontmatter, tags, and extracted article content — v1.2
- ✓ URL normalization prevents cross-source duplicates — v1.2
- ✓ GoodLinks wired into daily automation with enrichment pipeline — v1.2

### Active

**v1.3 Content Intelligence Pipeline:**
- [ ] Claude Code skills for Slack scanning (via MCP tools) and Outlook scanning (via Graph API)
- [ ] Scheduled daily scans + on-demand invocation
- [ ] Intelligent splitting of source content into atomic concept notes
- [ ] Theme-matching: connecting new atoms to existing vault content
- [ ] Synthesis workflow: clustering related atoms into draft blog posts with source citations
- [ ] Content strategist mode: conversational co-creation of crystallized insights

### Out of Scope

- Blog/frequent posting — Focus is portfolio, not content marketing
- Custom theme development — Using Hugo Resume with configuration
- Case study rewrites — Need voice/positioning research first (ChatGPT Deep Research)
- n8n full orchestration — Host scripts for v1; n8n workflow orchestration deferred
- Podcast ingestion — YouTube only for now
- Semantic search/embeddings — Grep-based for v1

## Current Milestone: v1.3 Content Intelligence Pipeline

**Goal:** Replace bash-script URL scrapers with Claude Code-powered content intelligence — scanning Slack/Email, splitting into atomic notes, connecting to vault themes, and synthesizing draft blog posts.

**Target features:**
- Claude Code skills for Slack (MCP) and Outlook (Graph API) scanning
- Three-layer content model: source captures → atomic concept notes → synthesized drafts
- Content strategist workflow: Claude connects new content to existing themes and co-creates writing
- Scheduled daily automation + interactive on-demand processing
- Draft blog posts as the terminal output, with citations back to source notes

## Context

**Current State (v1.2 shipped 2026-02-20):**
- Portfolio: Hugo Resume, live at athan-dial.github.io
- Model Citizen: Quartz + Obsidian vault + enrichment pipeline, 4 content sources (YouTube, web, Slack/Outlook, GoodLinks)
- Tech stack: Hugo, Quartz, Claude Code (SSH), bash scripts, Python helpers
- Two GitHub repos: athan-dial.github.io (portfolio) and model-citizen (Quartz site)
- Vault: iCloud Obsidian directory (2B-new/700 Model Citizen/)
- 3 milestones shipped, 13 phases, 28 plans delivered
- Existing Slack/Outlook scanners are bash scripts that extract URLs only — no content analysis, no MCP integration

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
| Two-phase GoodLinks approach | Scanner first (manual), then integration (automated) | ✓ Good — bugs caught before automation wiring |
| URL normalization as shared infra | Phase 13 not 12; cross-source utility | ✓ Good — retroactive migration covered all 46 existing notes |
| Stub notes for missing content | content_status: pending instead of web fetch fallback | ⚠️ Revisit — premature enrichment tech debt |

---
*Last updated: 2026-02-22 after v1.3 milestone started*
