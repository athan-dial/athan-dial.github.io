# Feature Research

**Domain:** Content Intelligence Pipeline — Slack/Email scanning, atomic notes, theme matching, draft synthesis
**Researched:** 2026-02-22
**Confidence:** HIGH (existing codebase examined, MCP ecosystem verified via official Slack docs and Anthropic docs)

---

## Context: What Already Exists

Before features, this context shapes every decision. The v1.3 milestone adds intelligence on top of a working pipeline.

**Existing pipeline (shipped, do not rebuild):**
- `scan-slack.sh` — Slack REST API, extracts URLs from starred items + boss DMs, calls `capture-web.sh`
- `scan-outlook.sh` — Graph API, extracts URLs from boss emails, calls `capture-web.sh`
- `capture-web.sh` — readability extraction, URL deduplication, YAML frontmatter output
- Enrichment pipeline — Claude Code via SSH: summaries, tags, idea cards, draft outlines
- Obsidian review gate — explicit human approval before publish
- Publish sync — Quartz deployment

**What the existing scanners lack:**
- No content analysis — only URL extraction
- No MCP integration — raw REST API bash scripts with fragile grep/sed JSON parsing
- No atomic splitting — source notes stay as monolithic captures
- No theme matching — no connection to existing vault content
- No synthesis — no draft blog post generation from clustered content

**The gap v1.3 fills:** Replace URL-extraction-only scanners with content-intelligent ones that understand what they're reading and connect it to what's already in the vault.

---

## Feature Landscape

### Table Stakes (Must Have for v1.3 to Work at All)

Features missing from this list = the new milestone produces no value over v1.2.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Slack content extraction (not just URLs) | Current scanner sees "message has a URL, go get it" — v1.3 must read the message itself as content worth analyzing | MEDIUM | Use Slack MCP server (`conversations.history`, `conversations.replies`) instead of raw REST bash; message text, thread context, sender preserved |
| Email body extraction (not just URLs) | Current Outlook scanner is broken for multi-message context — it grabs all URLs from the entire API response body, not per-email | MEDIUM | Graph API `/messages?$select=subject,bodyPreview,body` with HTML-to-text stripping; per-message context preserved |
| Atomic concept note creation | Long source captures (a Slack thread, an email) must be split into 1-idea-per-note format before enrichment | HIGH | Claude reads source note, identifies discrete concepts, creates separate markdown files with wikilinks back to source; this is the core new capability |
| Source note → atom link registry | Each atom note must link back to its source note; source note must list its atoms | LOW | Wikilinks in frontmatter (`source_note`, `atoms` fields); enables navigation and prevents orphan notes |
| Vault theme matching | New atoms must connect to existing notes in the vault — a new atom about "decision velocity" should link to existing notes on that theme | HIGH | Requires grep-based tag/title scan of vault; Claude identifies overlapping concepts and adds wikilinks + shared tags |
| Incremental scan (content-based) | Daily runs must not re-process already-extracted content | LOW | Per-source state files already exist for slack/outlook; extend with message IDs or timestamps for new content extraction |
| Existing pipeline integration | New atoms must flow into the existing enrichment pipeline (same frontmatter schema, same inbox folder, same Claude enrichment step) | LOW | Output format identical to `capture-web.sh` output; no pipeline changes needed downstream |

### Differentiators (What Makes v1.3 Worth Building)

These are the features that justify the milestone. The pipeline technically works without them, but they're the point of v1.3.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Draft blog post synthesis | Claude clusters related atoms from multiple sources (Slack + email + GoodLinks) around a theme, then writes a full draft with inline citations back to source notes | HIGH | Terminal output of the entire pipeline; justifies "Content Intelligence Pipeline" name; requires atomic splitting and theme matching to be complete first |
| Content strategist mode (conversational co-creation) | Interactive mode where Claude surfaces clusters and asks "should I write this up?" — keeps human in the loop for synthesis decisions | MEDIUM | Claude Code interactive session using `--continue` flag; presents clusters with topic summaries, awaits direction; not fully automated |
| Message-level context preservation | Slack thread structure preserved in atom notes — who said what, in what channel, in response to what — provides richer citation context | MEDIUM | Slack MCP `conversations.replies` for thread context; `users.info` for display names; stored as note metadata |
| On-demand invocation | `claude /synthesize-drafts` and `claude /scan-slack` as slash commands callable anytime, not just daily cron | LOW | Claude Code slash commands + skills; composable with existing launchd daily job |
| Cross-source theme clustering | Atoms from Slack + email + GoodLinks + YouTube that share themes get clustered together before draft synthesis | HIGH | Requires shared tag vocabulary and grep-based vault scan; Claude identifies theme clusters, not a vector DB (grep-based for v1 per PROJECT.md scope decision) |

### Anti-Features (Commonly Tempting, Reliably Problematic)

| Feature | Why Tempting | Why Problematic | Alternative |
|---------|--------------|-----------------|-------------|
| Semantic search / embeddings for theme matching | "The right way" to find related notes by meaning, not just keywords | PROJECT.md explicitly defers this: "Semantic search/embeddings — Grep-based for v1"; adds infrastructure complexity (vector DB, embedding model, index maintenance) with unclear value over grep-based matching at current vault scale (< 200 notes) | Grep vault for shared tags, title keywords, and explicit wikilinks — sufficient for v1 |
| Fully automated draft publishing | "Just ship it" — skip the human review gate | Breaks the core design principle: "Nothing goes public without explicit human approval"; AI-synthesized drafts need human voice layer before publication | Always output to `drafts/` folder with `status: draft`; human moves to publish queue |
| Per-message atom creation | Every Slack message becomes an atom note | Creates hundreds of low-signal notes; most messages are not worth preserving as independent concepts | Atomic splitting at the concept level, not the message level; a 10-message thread might yield 2-3 atoms |
| Real-time Slack scanning | "Capture ideas instantly" | Adds always-on process complexity; daily scan at 7AM is functionally equivalent for this use case | Stay on launchd schedule; on-demand invocation via Claude Code slash command covers urgent needs |
| Rewriting existing bash scanners from scratch | "Clean slate" — replace `scan-slack.sh` with a Claude Code skill entirely | Existing scripts handle OAuth, rate limits, error handling, and state management correctly; MCP adds a transport layer, not a replacement | Layer MCP tools on top of existing scan patterns; keep bash for auth/scheduling, use MCP for content extraction |
| Global Slack channel scanning | "More data" — scan all channels | Rate limits (15 messages/min for non-marketplace apps per Slack 2025 policy), privacy concerns, signal-to-noise collapse | Maintain current scope: starred items + boss DMs only |
| Separate enrichment pass for atoms | "Atoms might need different prompts" | Fragments the pipeline; existing Claude enrichment handles any note with proper frontmatter | Atoms use the same frontmatter schema and flow through the same enrichment pipeline |

---

## Feature Dependencies

```
[Slack content extraction via MCP]
    └──requires──> [Slack MCP server configured, bot token with channels:history scope]
    └──produces──> [Source note: full message text + thread context + sender]
    └──feeds──> [Atomic note creation]

[Email body extraction via Graph API]
    └──requires──> [Existing MS Graph auth (already working)]
    └──produces──> [Source note: subject + body + sender per email]
    └──feeds──> [Atomic note creation]

[Atomic note creation]
    └──requires──> [Source note with extractable content (not just URL)]
    └──requires──> [Claude Code skill: split-to-atoms]
    └──produces──> [Atom notes in inbox/ with source_note wikilink]
    └──feeds──> [Vault theme matching]
    └──feeds──> [Existing enrichment pipeline]

[Vault theme matching]
    └──requires──> [Atomic notes exist]
    └──requires──> [Vault grep index (tag list, title index)]
    └──produces──> [Wikilinks added to atom notes, shared tags applied]
    └──feeds──> [Cross-source theme clustering]

[Cross-source theme clustering]
    └──requires──> [Vault theme matching complete on new atoms]
    └──requires──> [Shared tag vocabulary consistent across sources]
    └──produces──> [Cluster manifest: theme → [atom notes] mapping]
    └──feeds──> [Draft blog post synthesis]

[Draft blog post synthesis]
    └──requires──> [Cross-source theme clustering]
    └──requires──> [Claude Code skill: synthesize-draft]
    └──produces──> [Draft markdown in drafts/ with citations]
    └──feeds──> [Existing publish pipeline (human approval gate)]

[Content strategist mode]
    └──requires──> [Cross-source theme clustering]
    └──enhances──> [Draft blog post synthesis]
    └──note──> [Optional interaction layer; synthesis works without it]

[On-demand slash commands]
    └──requires──> [Claude Code skills installed]
    └──enhances──> [All above features]
    └──note──> [Independent of launchd; complementary]
```

### Dependency Notes

- **Atomic splitting is the load-bearing feature:** All downstream features (theme matching, clustering, synthesis) require it. If atoms aren't created, the pipeline produces nothing new.
- **Theme matching must precede clustering:** Clustering requires shared vocabulary and wikilinks; theme matching creates that shared vocabulary.
- **Draft synthesis is the terminal output, not a foundation:** Build it last; it depends on everything else working correctly.
- **Content extraction (Slack/Email) must produce full text, not URLs:** This is the critical break from v1.2; the MCP-based Slack scan produces message content, not just embedded URLs.
- **Existing enrichment pipeline is unchanged:** Atom notes use identical frontmatter to `capture-web.sh` output; nothing downstream changes.

---

## MVP Definition

### v1.3 Launch With

Minimum needed for the Content Intelligence Pipeline to produce materially different output than v1.2.

- [ ] **Slack content extraction via MCP** — Claude Code skill reads Slack message content (not just URLs) from starred items + boss DMs using Slack MCP server; produces source notes with full text
- [ ] **Email body extraction per-message** — Fix existing Outlook scanner to extract per-email body text with subject/sender context; source notes include readable email content
- [ ] **Atomic note creation skill** — Claude Code skill `split-to-atoms`: reads source note, identifies discrete concepts, creates atom notes with source wikilinks; respects 1-idea-per-note constraint
- [ ] **Vault theme matching** — Grep-based vault scan; Claude identifies overlapping tags/titles in existing notes and adds wikilinks; no vector DB required
- [ ] **Draft blog post synthesis** — Claude Code skill `synthesize-draft`: clusters atoms by shared tags, writes draft markdown to `drafts/` folder with citations; human approval gate unchanged
- [ ] **Daily automation integration** — New skills callable from existing launchd daily job; no new scheduling infrastructure

### Add After Validation (v1.3.x)

Features to add once atoms are flowing and synthesis is producing useful drafts.

- [ ] **Content strategist mode** — Interactive Claude session that surfaces clusters and asks for direction before synthesizing; add when draft quality validates the pipeline
- [ ] **On-demand slash commands** — `/scan-slack`, `/split-atoms`, `/synthesize-drafts` as Claude Code slash commands; add when daily automation is stable and on-demand need emerges
- [ ] **Thread context preservation** — Full Slack thread structure (replies, reactions, sender display names) in source notes; add when message-level context proves valuable in drafts
- [ ] **Cross-source cluster manifest** — Explicit cluster → source mapping file for debugging and traceability; add if cluster quality is hard to diagnose

### Defer to v2+

- [ ] **Semantic/embedding-based theme matching** — Only when vault exceeds ~500 notes and grep-based matching produces too many false positives/negatives
- [ ] **Automated draft publishing** — Non-negotiable defer; human approval gate is a core design principle, not a convenience
- [ ] **Broader Slack scope (additional channels)** — Only if starred + boss DMs consistently produce low signal; requires re-evaluating privacy/rate limit constraints

---

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Slack content extraction via MCP | HIGH | MEDIUM | P1 |
| Email body extraction (per-message fix) | HIGH | LOW | P1 |
| Atomic note creation (split-to-atoms skill) | HIGH | HIGH | P1 |
| Vault theme matching (grep-based) | HIGH | MEDIUM | P1 |
| Draft blog post synthesis | HIGH | HIGH | P1 |
| Daily automation integration | HIGH | LOW | P1 |
| Content strategist mode (interactive) | MEDIUM | MEDIUM | P2 |
| On-demand slash commands | MEDIUM | LOW | P2 |
| Thread context preservation | MEDIUM | MEDIUM | P2 |
| Cross-source cluster manifest | LOW | LOW | P2 |
| Semantic search / embeddings | LOW | HIGH | P3 (deferred) |

**Priority key:**
- P1: Must have for v1.3 to deliver value
- P2: Add after P1 is stable and producing useful drafts
- P3: Deferred; reconsider at v2

---

## Implementation Notes by Feature

### Slack MCP vs Raw REST API

The existing `scan-slack.sh` uses raw REST API with bash grep/sed JSON parsing — this is fragile and does not extract message content reliably. The Slack MCP server (official: `docs.slack.dev/ai/slack-mcp-server`) provides structured tool calls:

- `conversations_history` — fetches messages as structured objects, not raw JSON to parse
- `conversations_replies` — thread context without ad-hoc grep
- MCP rate limits (2025): 15 messages/request, 1 req/min for non-marketplace apps — workable for daily starred scan

A Claude Code skill wraps the MCP calls and produces source notes. The existing bash script can be kept for auth/scheduling; the Claude skill replaces the content extraction logic.

### Atomic Note Creation Heuristics

"Atomic" = one claim, one concept, one transferable idea. Not every sentence. A 10-message Slack thread should produce 2-4 atoms, not 10.

Claude splitting heuristics:
1. Each H2/H3 heading in a source → candidate atom
2. Each distinct argument, framework, or decision → atom
3. Each named tool, method, or concept referenced → atom if non-trivial
4. Filler (pleasantries, logistics, scheduling) → discard

Atom note frontmatter should add: `source_note: [[original-source-filename]]`, `atom_of: [source title]`.

### Vault Theme Matching Approach (Grep-Based)

No vector DB. Matching strategy:
1. Extract tags from new atom note
2. Grep vault for existing notes with overlapping tags
3. Grep vault for notes whose titles contain keywords from atom title
4. Claude reviews candidate matches, confirms relevance, adds wikilinks

At current vault scale (< 200 notes), grep completes in < 1 second. Sufficient for v1.

### Draft Synthesis Output Contract

Draft note must include:
- `status: draft` (never auto-publish)
- `synthesis_sources: [list of atom note filenames]` for traceability
- Inline wikilinks to source atoms within body text
- Standard section structure: introduction → body → implications → questions raised

---

## Sources

- [Slack MCP Server — Official Slack Developer Docs](https://docs.slack.dev/ai/slack-mcp-server/) — Confirmed tool capabilities: `conversations.history`, `conversations.replies`, rate limits
- [Slack conversations.history method](https://docs.slack.dev/reference/methods/conversations.history/) — API details; 2025 rate limits for non-marketplace apps
- [Claude Code Skills — Anthropic](https://www.anthropic.com/news/skills) — Skills folder structure, `SKILL.md` format, `--continue --print` for non-interactive automation
- [Claude Code Common Workflows](https://code.claude.com/docs/en/common-workflows) — Slash commands, hooks, non-interactive invocation patterns
- [Atomizer Obsidian Plugin](https://www.obsidianstats.com/plugins/note-atomizer) — Community pattern for AI-driven atomic splitting; confirms concept viability and expected output structure
- [dsebastien.net — How to Split Long Notes into Atomic Notes](https://www.dsebastien.net/how-to-split-long-notes-into-atomic-notes-a-comprehensive-guide/) — Heuristics for what makes an atomic note; "one idea, linkable, titlable as a claim"
- [korotovsky/slack-mcp-server](https://github.com/korotovsky/slack-mcp-server) — Community MCP implementation with smart history pagination, DM support, no-admin-approval path
- [blog.lmorchard.com — Topic clustering with gen AI](https://blog.lmorchard.com/2024/04/27/topic-clustering-gen-ai/) — Practical pattern: extract cluster representatives, synthesize with LLM; confirms grep-then-LLM approach is standard for this scale

---

*Feature research for: Content Intelligence Pipeline (v1.3 milestone — atomic notes, theme matching, draft synthesis)*
*Researched: 2026-02-22*
