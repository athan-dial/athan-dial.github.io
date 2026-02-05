# Model Citizen: Content Generation & Publishing Engine

## What This Is

A public knowledge/content system deployed at `athan-dial.github.io/model-citizen/` combining:
1. **Public Obsidian Vault** (Repo A) — Raw sources, enriched notes, idea cards, drafts
2. **Quartz Publishing Site** (Repo B) — Published articles only, deployed as GitHub Pages project site
3. **n8n Automation** — Daily workflow orchestration: ingest sources → enrich → generate ideas → draft → publish gate
4. **Claude Code Integration** — AI-driven synthesis and drafting via SSH invocation from n8n

## Core Value

**Make knowledge capture and publishing frictionless with explicit human control.** The system continuously collects and synthesizes ideas (YouTube, email, web), but nothing goes public without explicit approval. The vault is public — let people see how you think.

## Requirements

### v1: MVP (GitHub Pages + n8n + Basic Publishing)

- [ ] MC-01: Quartz site scaffold with GitHub Pages deploy pipeline
- [ ] MC-02: Vault folder structure and Markdown schema documented
- [ ] MC-03: n8n YouTube ingestion working (download transcripts, normalize to Markdown)
- [ ] MC-04: Claude Code agent invocation pattern (n8n → SSH → workflow)
- [ ] MC-05: Summary/tagging enrichment working (Claude-powered)
- [ ] MC-06: Idea card generation (blog angles, outlines)
- [ ] MC-07: Human review/approval dashboard (Vault-based approval screen)
- [ ] MC-08: Publish sync pipeline (approved content → Quartz)
- [ ] MC-09: End-to-end example (YouTube → published post)

### v2 (Deferred)

- [ ] Multi-source ingestion (email, web links, podcasts)
- [ ] Draft preview in Quartz before publication
- [ ] Automated related-links and backlinks
- [ ] Search and tagging on Quartz site
- [ ] Analytics and engagement tracking

## Architecture

### Two Repos

**Repo A: athan-dial.github.io/model-citizen/** (public)
- Obsidian vault structure
- Folders: inbox/, sources/, enriched/, ideas/, drafts/, publish_queue/
- All content is Git-tracked (every thought is version-controlled)
- Automation writes into this repo

**Repo B: athan-dial.github.io-quartz/** (separate repo or subdirectory)
- Standard Quartz repo
- Content lives in content/ directory
- Deployed as GitHub Pages project site: `athan-dial.github.io/model-citizen/`

### n8n Workflow

**Local Docker instance** running daily or on-demand:
- Ingest YouTube: download transcript, normalize to Markdown with frontmatter
- Ingest email/web: similar normalization
- Enrich: invoke Claude Code via SSH to summarize, tag, extract quotes
- Ideate: generate blog angles and outlines
- Store: commit to Vault
- Wait: human approval (move to publish_queue or set status: publish)
- Sync: export approved content to Quartz
- Deploy: GitHub Actions rebuilds Quartz site

### Claude Code Integration

n8n doesn't have native Claude integration for complex synthesis. Instead:
- n8n prepares input data (transcript, article, structured prompt)
- Commits to Vault in a temp folder
- SSHes into your machine and invokes Claude Code / Cursor Agent
- Agent reads input, writes enrichment/draft
- Commits result back to Vault
- n8n continues orchestration

## Constraints

- **Safety**: No raw inbox content can be published without explicit human gate
- **Idempotency**: Re-running daily doesn't duplicate content
- **Traceability**: Every published post links back to its source notes
- **Public Vault**: All of Repo A is public (no private credentials or content)
- **Low friction**: "Daily run" completes in <5 min; publishing is 1-click approval

## Key Decisions

| Decision | Rationale | Status |
|----------|-----------|--------|
| Separate vault (Repo A) + publishing (Repo B) | Decouples thinking space from public surface; allows iterating on ideas without affecting site | — Pending |
| n8n instead of custom code | Visual workflow builder, easier to maintain; non-developers can understand the flow | — Pending |
| Public vault | Transparency about sources and thinking; differentiates from polished blog | — Pending |
| Claude Code for synthesis | Consistent with existing toolkit; agentic capability for complex drafting | — Pending |
| Explicit publish gate | Nothing goes public without human intent signal; trust but verify | — Pending |
| Quartz for publishing site | Lightweight static notes; links and backlinks fit knowledge capture aesthetic | — Pending |

---

*Project initialized: 2026-02-05*
