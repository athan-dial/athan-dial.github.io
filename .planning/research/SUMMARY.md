# Project Research Summary

**Project:** v1.3 Content Intelligence Pipeline
**Domain:** Personal Knowledge Management — Slack/Email content scanning, atomic note creation, theme matching, draft synthesis
**Researched:** 2026-02-22
**Confidence:** HIGH

## Executive Summary

The v1.3 milestone upgrades an existing, working bash pipeline (URL capture → Obsidian vault → Quartz publish) with a content intelligence tier built on Claude Code skills and subagents. The core insight: the v1.2 pipeline captures URLs but discards the message context that makes those URLs worth saving. v1.3 fixes this by reading Slack messages and emails as content, splitting multi-concept captures into atomic notes, and eventually synthesizing draft blog posts from themed clusters. The recommended approach is additive — the intelligence tier layers on top of the bash infrastructure, which stays as a reliable fallback. The vault remains the single integration point for all components.

The recommended stack is tightly scoped to what already exists on this machine: Claude Code skills and subagents (official extension mechanisms), the official Slack MCP server (GA since Feb 17, 2026), msgraph-sdk Python for Outlook body extraction, and python-frontmatter for vault schema compliance. No new orchestration frameworks (LangChain, n8n) and no vector databases — both are explicitly deferred per the existing PROJECT.md scope decisions. The intelligence tier runs inside the same launchd daily job as the bash scanners, calling `claude -p` sequentially per note.

The most significant risks are operational rather than technical. MCP tool context overhead can exhaust the token budget before any useful work begins if multiple MCP servers load in a single session. Slack's 2025 rate limit changes (15 messages/minute for non-Marketplace apps) silently corrupt incremental scan state if not handled. Atomic splitting without provenance metadata produces decontextualized fragments that match nothing in the vault and degrade synthesis quality. These are all avoidable with explicit design decisions made before implementation begins — but they must be addressed before implementation begins, not discovered during integration testing.

---

## Key Findings

### Recommended Stack

The stack adds minimal new dependencies on top of the existing bash + Claude Code infrastructure. The Slack MCP server replaces fragile bash REST + grep parsing with structured tool calls. msgraph-sdk Python replaces bash URL scraping of Outlook JSON with typed email body extraction. Claude Code skills (SKILL.md format) and subagents (.claude/agents/) are the official extension mechanisms — no custom orchestration needed.

**Core technologies:**
- **Claude Code skills** (`split-atomic`, `match-themes`): Reusable instruction prompts invoked via `claude -p "/skill-name args"` from bash automation — the right primitive for per-note transformations
- **Claude Code subagents** (`slack-scanner`, `content-strategist`): Isolated context windows for multi-step sessions; subagents support `mcpServers` frontmatter for direct MCP access
- **Official Slack MCP server** (`@slack/mcp-server`, GA 2026-02-17): Structured Slack access inside Claude Code; replaces bash REST calls for content extraction; invoked via `npx`, no permanent install
- **msgraph-sdk Python 1.54.0**: Typed Graph API client for full Outlook email bodies; replaces bash `curl` + `sed` JSON parsing that only captured URLs
- **python-frontmatter 1.1.0**: YAML frontmatter parsing for vault notes; avoids fragile string manipulation on note metadata
- **claude -p (headless)**: Non-interactive invocation pattern for launchd automation; already used in v1.2 enrichment pipeline

See `.planning/research/STACK.md` for full version table, configuration examples, and alternatives considered.

### Expected Features

The v1.3 feature set has a clear dependency chain: content extraction enables atomic splitting, splitting enables theme matching, theme matching enables clustering, clustering enables synthesis. Nothing in the chain can be skipped.

**Must have (table stakes for v1.3 to produce value):**
- **Slack content extraction via MCP** — replaces URL-only scanning with full message text + thread context
- **Email body extraction per-message** — fixes existing scanner that grabs all URLs from the entire API response body rather than per-email
- **Atomic note creation** (`split-to-atoms` skill) — splits multi-concept source notes into one-idea-per-note format; the load-bearing feature all downstream work requires
- **Vault theme matching** (grep-based) — finds related existing vault notes, adds wikilinks and shared tags; no vector DB at current vault scale (<200 notes)
- **Draft blog post synthesis** — clusters atoms by shared tags, writes draft markdown to `drafts/` folder with citations; terminal output of the pipeline
- **Daily automation integration** — new skills callable from existing launchd job; no new scheduling infrastructure

**Should have (differentiators, add after v1.3 P1 is stable):**
- **Content strategist mode** — interactive Claude session surfacing clusters and requesting direction before synthesizing; keeps human in the loop for editorial decisions
- **On-demand slash commands** (`/scan-slack`, `/split-atoms`, `/synthesize-drafts`) — callable anytime from Claude Code, complementary to launchd schedule
- **Thread context preservation** — Slack thread structure (who said what, in response to what) preserved in source notes for richer citation context

**Defer to v2+:**
- Semantic search / embeddings for theme matching — only when vault exceeds ~500 notes and grep produces too many false positives
- Automated draft publishing — non-negotiable defer; human approval gate is a core design principle
- Broader Slack channel scope — only if starred + boss DMs consistently produce low signal

See `.planning/research/FEATURES.md` for full dependency graph, MVP definition, and feature prioritization matrix.

### Architecture Approach

The architecture inserts an intelligence tier between the existing bash scan layer and the Obsidian vault. It does not replace the bash layer. Both paths write to the vault; the vault's folder structure and frontmatter schema is the only contract between components. Two new vault folders (`atoms/`, `themes/`) and a `vault/SCHEMA.md` are the foundation that every subsequent component depends on.

**Major components:**
1. **`slack-scanner` subagent** — Claude Code subagent with Slack MCP access; scans starred items + boss DMs for message content; writes content-rich source notes to `vault/sources/`
2. **`scan-outlook-content.py`** — Python msgraph-sdk script; fetches full Outlook email bodies per message; writes source notes to `vault/sources/`
3. **`run-intelligence.sh`** — bash orchestrator; calls skills in sequence (split → match) per new note; integrates into existing `scan-all.sh` as final step
4. **`split-atomic` skill** — Claude Code skill invoked via `claude -p`; splits multi-concept source notes into atomic notes in `vault/atoms/`
5. **`match-themes` skill** — Claude Code skill; grep-based vault scan; adds wikilinks to `vault/themes/` index notes
6. **`content-strategist` subagent** — interactive-only; clusters atoms across sources; writes draft blog posts to `vault/drafts/` with inline citations
7. **`vault/SCHEMA.md`** — committed frontmatter contract; all subagent system prompts reference it as the single source of truth

The build order is strictly dependency-driven: vault schema → Outlook scanner → Slack scanner → atomic split → theme match → orchestrator → content strategist. Each phase is independently testable.

See `.planning/research/ARCHITECTURE.md` for system diagram, data flow, component table, and anti-patterns.

### Critical Pitfalls

1. **MCP context exhaustion before useful work begins** — Multiple MCP servers load all tool definitions into context on the first message (51K–67K tokens for a five-server setup). Design separate, scoped Claude sessions: one for scanning, one for splitting, one for synthesis. Never run a mega-session with all tools loaded. Test with `claude --debug` before deploying automation.

2. **Slack rate limits silently drop messages and corrupt scan state** — As of May 2025, non-Marketplace apps are capped at 15 messages/request, 1 req/min for `conversations.history`. The existing bash scanner silently advances `LAST_SCAN_FILE` on `429` errors, permanently losing that window. The MCP skill must treat `429` as a hard failure and must not advance the last-scan timestamp until all paginated results are confirmed received.

3. **Atomic splitting without provenance destroys the insight** — LLMs strip context to produce clean standalone statements. A Slack message about "reconsidering rollout timeline given the Copilot adoption curve" becomes "rollout timeline reconsideration" — a note that matches nothing in the vault and provides no synthesis value. Every atomic note must include: (1) the claim in one sentence, (2) original conversational context in 1–2 sentences, (3) why it was flagged. Add `provenance` frontmatter with `source_type`, `source_channel`, `source_sender`, `source_message_ts`.

4. **Theme matching accumulates false positives that collapse vault graph quality** — Grep-based matching finds vocabulary overlap, not meaning. Cap at 3 automated links per new atom note; require the model to explain *why* the connection is valid (not just that terms overlap); distinguish topic similarity (tags only) from conceptual connection (hard wikilink).

5. **Draft synthesis hallucination corrupts the "decision evidence" brand** — LLMs fill synthesis gaps with plausible-sounding content attributed to real notes that don't contain the claimed claim. The synthesis prompt must require inline citations to specific atom note IDs and prohibit claims not directly supported by source notes. Atomic notes need a `publishability` field (`public` vs `private`) to prevent private Slack content from appearing in published drafts.

See `.planning/research/PITFALLS.md` for 7 critical pitfalls with recovery strategies and a "looks done but isn't" verification checklist.

---

## Implications for Roadmap

Based on research, the build order is strictly determined by component dependencies. Each phase produces a testable output before the next phase begins. The architecture research defines a 7-phase build sequence that maps directly to roadmap phases.

### Phase 1: Vault Schema and Folder Structure
**Rationale:** Every subsequent component reads vault schema and writes to new vault folders. Schema must exist before any code is written. `vault/SCHEMA.md` is the contract all subagents reference — without it, each agent embeds its own schema assumptions, which diverge.
**Delivers:** `vault/atoms/`, `vault/themes/`, `vault/SCHEMA.md` with extended frontmatter fields (`type: atom`, `atom_of`, `atom_count`, `theme`, `publishability`, `provenance.*`)
**Addresses:** Sets the contract that prevents Pitfall 3 (decontextualized atoms) and Pitfall 5 (publishability leakage) before either can happen
**Avoids:** Schema drift across agents, which compounds into unfixable inconsistency
**Test:** Create a manual test atom note, verify Obsidian Auto Note Mover routes it to `atoms/` correctly

### Phase 2: Outlook Content Scanner
**Rationale:** No Claude Code dependency. Tests that Graph API content extraction works against known credentials before building intelligence layer on top. Lower-risk entry point than Slack MCP — the credential and auth flow already exist in `scan-outlook.sh`.
**Delivers:** `scan-outlook-content.py` using msgraph-sdk; per-email body extraction with subject/sender context; schema-compliant `vault/sources/email-content-*.md` notes
**Uses:** msgraph-sdk 1.54.0, msal 1.31.0, existing `MS_GRAPH_*` credentials from `~/.model-citizen/env`
**Avoids:** Graph API delegated vs. app auth confusion — personal mailbox requires delegated auth (device code flow), not client credentials
**Test:** Run against one week of emails; verify output note format matches `vault/SCHEMA.md`

### Phase 3: Slack Scanner Subagent
**Rationale:** Slack MCP is the newer, less-proven component. Isolating it lets you validate MCP connectivity and Slack permissions before wiring into automation. Failure here is recoverable (bash fallback exists); failure in automation is silent.
**Delivers:** `.claude/agents/slack-scanner.md` subagent with Slack MCP config in `~/.claude/settings.json`; full-text source notes from starred items + boss DMs
**Uses:** Official Slack MCP server (`@slack/mcp-server` via npx); haiku model (fast, cheap for extraction)
**Avoids:** MCP context exhaustion (Pitfall 1) — scanner session loads only Slack MCP tools, not synthesis tools; Pitfall 2 — `429` handling with backoff, state file updated only on confirmed scan completion
**Research flag:** Slack MCP tool parameter details are sparsely documented (MEDIUM confidence per STACK.md). Plan for an interactive debugging session to confirm exact tool parameter names and response shapes before writing the system prompt.

### Phase 4: Atomic Split Skill
**Rationale:** Depends on Phase 1 (atoms/ folder + schema defined) and real source notes from Phases 2–3 to test against. Atomic splitting is the load-bearing feature — theme matching, clustering, and synthesis all require atoms to exist.
**Delivers:** `.claude/skills/split-atomic/SKILL.md`; atomic notes with provenance metadata in `vault/atoms/`; source notes updated with `atom_count`
**Implements:** Provenance requirements from Pitfall 3 — every atom embeds conversational context (who said it, in what context, why flagged), not just the isolated claim
**Test:** Split one real source note; verify atoms have provenance frontmatter, `atom_of` backlink, and source note `atom_count` update

### Phase 5: Theme Match Skill
**Rationale:** Requires atoms to exist (Phase 4 output). The matching logic is only testable with real content at the current scale; synthetic test cases will not catch false-positive patterns.
**Delivers:** `.claude/skills/match-themes/SKILL.md`; `vault/themes/` index notes with backlinks to related atoms
**Avoids:** Pitfall 4 (false positive accumulation) — matching prompt requires written justification of each connection, caps at 3 links per atom, distinguishes topic similarity (tags only) from conceptual connection (wikilink)
**Test:** Run on 5 atoms from the same topic; verify a coherent theme note is created with non-vocabulary-overlap justifications for each link

### Phase 6: Intelligence Orchestrator
**Rationale:** Integration step — wires Phases 2–5 into existing daily automation. Build after each prior phase is working in isolation so you are integrating working components, not debugging two problems at once.
**Delivers:** `run-intelligence.sh` bash orchestrator; `scan-all.sh` updated to call intelligence tier as final step; state file compatibility with existing bash scanners verified
**Avoids:** Pitfall 6 (scheduled/interactive session conflict) — schedule at 4–6am not 8am; implement `pipeline.lock` file pattern; Pitfall 7 (state file corruption) — MCP skill reads same `slack-last-scan` file format as old bash scanner
**Test:** Full daily scan with intelligence tier enabled; inspect log for each step completing without errors; check vault note count is stable (no unexpected duplication)

### Phase 7: Content Strategist Subagent
**Rationale:** Interactive capstone. Requires all prior phases producing quality input. Validates the full three-layer model end-to-end. Do not build until atoms and theme matching are proven stable.
**Delivers:** `.claude/agents/content-strategist.md` with `memory: local`; draft blog posts in `vault/drafts/` with atomic note citations
**Avoids:** Pitfall 5 (hallucinated citations) — synthesis prompt requires inline citations to specific atom note IDs, prohibits unsupported claims; `publishability` gate enforced before synthesis runs on any note
**Research flag:** Voice consistency for synthesis drafts requires the ChatGPT Deep Research Voice & Style Guide (not yet available). Treat Phase 7 synthesis prompts as incomplete until that research delivers. Flag with `// TODO: add voice characteristics` placeholder.
**Test:** Request cluster proposals from atoms created in Phases 4–5; request a draft; verify citations are traceable to specific atom note IDs and draft respects publishability frontmatter

### Phase Ordering Rationale

- **Schema before code:** `vault/SCHEMA.md` is the contract. Subagent system prompts reference it directly — it must exist before any agent file is written.
- **Extraction before transformation:** Phases 2–3 (scanners) must run before Phase 4 (splitting) because atomic splitting requires real source notes, not synthetic test cases.
- **Lower-risk before higher-risk:** Outlook (Phase 2) before Slack MCP (Phase 3) — the Outlook stack is already partly implemented; MCP is the new unknown.
- **Atomic before thematic:** Phase 4 (splitting) before Phase 5 (matching) because theme matching cannot run without atoms to match.
- **Automation before interactive:** Phase 6 (orchestrator) before Phase 7 (content strategist) because daily automation provides the steady supply of atoms the content strategist needs to propose meaningful clusters.
- **No parallelism between phases:** Each phase produces the input the next phase tests against. Parallel execution would require synthetic test data and miss real-content integration bugs.

### Research Flags

Phases likely needing deeper exploration during implementation:
- **Phase 3 (Slack MCP):** MCP tool parameter names and exact response shapes are only partially documented in official Slack developer docs (MEDIUM confidence in STACK.md). Plan for an interactive debugging session to confirm `conversations_history` naming, pagination cursor field names, and rate limit response format before writing the subagent system prompt.
- **Phase 4 (Atomic split prompt design):** No established best practice for provenance-preserving atomic splitting. Expect 3+ test-refine cycles with representative Slack and email source notes before considering the skill stable for automation.
- **Phase 7 (Synthesis voice):** Voice consistency requires the ChatGPT Deep Research Voice & Style Guide. Flag the synthesis prompt as incomplete until that research is available; treat all Phase 7 output as raw material requiring complete rewrite until voice guide is integrated.

Phases with standard patterns (skip additional research):
- **Phase 1 (Vault schema):** Straightforward YAML schema design; no research needed beyond what ARCHITECTURE.md specifies.
- **Phase 2 (Outlook scanner):** msgraph-sdk is well-documented (HIGH confidence); existing OAuth credentials already working.
- **Phase 6 (Orchestrator):** Bash pipeline patterns are established in the existing codebase; low-risk integration work.

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Claude Code docs fetched directly; msgraph-sdk PyPI verified at v1.54.0; Slack MCP GA announcement confirmed. Only gap: exact Slack MCP tool parameter names (MEDIUM for that specific detail). |
| Features | HIGH | Existing codebase examined directly; feature dependencies verified against PROJECT.md scope decisions; MCP rate limits confirmed from official Slack May 2025 changelog. |
| Architecture | HIGH | Based on verified codebase (`scan-all.sh`, `scan-slack.sh`, `scan-outlook.sh`) + ARCHITECTURE.md in model-citizen repo. Vault structure and data flow are established fact, not inference. |
| Pitfalls | HIGH (API/integration), MEDIUM (design quality) | Slack rate limits, MCP token overhead, and state file pitfalls are documented in official sources and measured GitHub issues. Atomic splitting quality and theme matching false-positive management are derived from community patterns and first principles — no single authoritative source. |

**Overall confidence:** HIGH for implementation sequence; MEDIUM for synthesis quality and voice consistency (pending Voice & Style Guide research).

### Gaps to Address

- **Slack MCP tool parameter names:** Official docs confirm tool categories (search, retrieve, canvas, users) but are sparse on exact parameter names. Resolve during Phase 3 with an interactive debugging session before writing the subagent system prompt.
- **Atomic splitting prompt design:** No established best practice for provenance-preserving splitting. Resolve with 3+ test-refine cycles against real Slack/email samples in Phase 4 before wiring into automation.
- **Voice consistency in synthesis:** Cannot write Phase 7 synthesis prompt correctly until ChatGPT Deep Research Voice & Style Guide is available. Flag synthesis prompt as `// TODO: add voice characteristics after deep research` and treat Phase 7 drafts as raw material requiring complete rewrite until resolved.
- **Slack app classification (Marketplace vs. internal):** Determines whether May 2025 rate limit changes apply. Verify before Phase 3 implementation — if the app is internal/admin-installed, the harsher limits may not apply and pagination design can be relaxed.

---

## Sources

### Primary (HIGH confidence)
- [Claude Code Sub-agents docs](https://code.claude.com/docs/en/sub-agents) — frontmatter fields, mcpServers, memory, model aliases
- [Claude Code Skills docs](https://code.claude.com/docs/en/skills) — SKILL.md format, disable-model-invocation, allowed-tools
- [Claude Code headless docs](https://code.claude.com/docs/en/headless) — `-p` flag, non-interactive invocation
- [msgraph-sdk PyPI](https://pypi.org/project/msgraph-sdk/) — v1.54.0, Python >=3.9 confirmed
- [Slack rate limit changes (May 2025)](https://docs.slack.dev/changelog/2025/05/29/rate-limit-changes-for-non-marketplace-apps/) — 15 messages/request, 1 req/min for non-Marketplace apps
- [Claude Code MCP token overhead — GitHub issue #3406](https://github.com/anthropics/claude-code/issues/3406) — tool definition context consumption measured
- Direct codebase inspection — `scan-slack.sh`, `scan-outlook.sh`, `scan-all.sh`, state file patterns, model-citizen ARCHITECTURE.md

### Secondary (MEDIUM confidence)
- [Slack MCP Server docs](https://docs.slack.dev/ai/slack-mcp-server/) — tool categories confirmed; individual parameter names not fully documented
- [Slack MCP Server GA announcement](https://docs.slack.dev/changelog/2026/02/17/slack-mcp/) — GA status confirmed
- [Atomizer Obsidian plugin](https://www.obsidianstats.com/plugins/note-atomizer) — AI-driven atomic splitting pattern confirmed viable
- [dsebastien.net atomic notes guide](https://www.dsebastien.net/how-to-split-long-notes-into-atomic-notes-a-comprehensive-guide/) — heuristics for what constitutes an atomic note
- [Claude Code MCP context bloat reduction](https://medium.com/@joe.njenga/claude-code-just-cut-mcp-context-bloat-by-46-9-51k-tokens-down-to-8-5k-with-new-tool-search-ddf9e905f734) — Tool Search feature measured impact

### Tertiary (LOW confidence / needs validation)
- [LLM citation accuracy — PMC 2025](https://pmc.ncbi.nlm.nih.gov/articles/PMC12037895/) — citation hallucination risk in synthesis tasks; confirms the problem but specific mitigation strategies are practitioner-derived
- [blog.lmorchard.com topic clustering](https://blog.lmorchard.com/2024/04/27/topic-clustering-gen-ai/) — grep-then-LLM approach confirmed as standard pattern for this vault scale; single source

---
*Research completed: 2026-02-22*
*Ready for roadmap: yes*
