# Stack Research

**Domain:** Content Intelligence Pipeline — Claude Code skills for Slack scanning (MCP), Outlook scanning (Graph API), atomic note splitting, theme matching, and draft synthesis
**Researched:** 2026-02-22
**Confidence:** HIGH for Claude Code skills/subagents (docs fetched directly), MEDIUM for Slack MCP (GA as of 2026-02-17, official docs sparse on tool params), HIGH for Graph API (existing implementation verified in codebase)

---

## Context: What Already Exists (Do Not Re-Research)

The v1.2 pipeline already has:
- `scan-slack.sh` — bash REST calls to Slack API, URL extraction only
- `scan-outlook.sh` — bash OAuth + Graph API calls, URL extraction only
- `enrich-source.sh` — Claude Code SSH agent for enrichment via `claude -p`
- State files at `~/.model-citizen/` (last-scan timestamps, seen-IDs)
- Vault schema with frontmatter, tags, `content_status` field

The v1.3 stack adds new capabilities **on top of** this — it does not replace the bash infrastructure.

---

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Claude Code skills (`~/.claude/skills/`) | Current (anthropics/claude-code) | Define reusable skill prompts for Slack scanning, atomic splitting, theme matching, synthesis | Skills are the official Claude Code extension mechanism. They inject domain instructions into Claude's context, can invoke tools (Bash, Read, Grep, Glob), and are invoked with `/skill-name` or automatically by Claude. Lighter than subagents for prompt-driven workflows that don't need isolated context. |
| Claude Code subagents (`.claude/agents/`) | Current | Orchestrate multi-step content intelligence sessions with isolated context | Subagents run in their own context window. Use for the content strategist workflow that needs to hold the vault state across many tool calls without polluting the main conversation context. Supports `mcpServers` field to give a subagent direct MCP access. |
| Slack MCP Server (Official) | GA 2026-02-17 | Real-time Slack message search and retrieval inside Claude Code | Officially released by Slack as part of their agentic platform strategy. Provides search, message history, thread retrieval, channel discovery — all respecting workspace permissions. No external data storage. Claude Code subagents can reference it via the `mcpServers` frontmatter field. |
| Microsoft Graph API (existing) | v1.0 | Outlook email scanning | Already implemented in `scan-outlook.sh` with OAuth client credentials. The v1.3 upgrade replaces the fragile bash JSON parsing with a Python helper that calls Graph API and returns structured content, not just URLs. |
| `msgraph-sdk` (Python) | 1.54.0 | Typed Python wrapper for Graph API calls | Current version (Feb 2026). Replaces manual `curl` + `sed` parsing in `scan-outlook.sh`. Provides proper pagination, OData filter support, and typed response objects. Required for body content extraction (full email text, not just href scraping). |
| `msal` (Python) | 1.31.0 | Microsoft OAuth token acquisition | Already referenced in outlook scan. The SDK approach uses `msal.ConfidentialClientApplication` for client credentials flow. |
| Claude Code headless (`claude -p`) | Current | Non-interactive invocation from launchd/cron | Already used in `enrich-source.sh`. v1.3 extends this pattern to invoke skills non-interactively: `claude -p "/skill-name arguments"`. The `-p` flag runs a single prompt and exits, ideal for automation. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `python-frontmatter` | 1.1.0 | Parse and write Obsidian vault note frontmatter | During atomic split: read existing note YAML frontmatter cleanly, write new atomic notes with correct schema. Avoids manual YAML string manipulation. |
| `jq` | 1.7.1 (already installed) | Parse JSON in bash wrappers around Python scripts | When bash orchestration scripts need to read Python output or state files. Already on this machine. |
| `msal` | 1.31.0 | OAuth token for Graph API | Already in use conceptually; needs explicit pip install for Python-based outlook scanner |
| `msgraph-sdk` | 1.54.0 | Graph API typed client | New for v1.3 — replaces bash curl calls in outlook scanner |
| Python `re`, `textwrap`, `pathlib`, `hashlib`, `json`, `datetime` | stdlib | Atomic splitting, file ops, idempotency | No new installs — all stdlib |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `/agents` command in Claude Code | Create and manage subagent files interactively | Use to create the content-strategist subagent; saves to `.claude/agents/` |
| `~/.claude/skills/<skill-name>/SKILL.md` | Skill file location for user-level skills | Available across all projects; good for vault-wide skills |
| `.claude/skills/<skill-name>/SKILL.md` | Project-level skill location | Commit into model-citizen repo for reproducibility |
| `claude agents` CLI | List configured agents without interactive session | Verify agent files loaded correctly |

---

## Installation

```bash
# Python packages for Outlook content scanner (upgrade from bash)
pip install msgraph-sdk==1.54.0 msal==1.31.0 python-frontmatter==1.1.0

# Slack MCP Server — configure in Claude Code settings
# Add to ~/.claude/settings.json mcpServers block (see Integration Points below)
```

---

## Integration Points

### Slack MCP Server Configuration

Add to `~/.claude/settings.json` (or project `.claude/settings.json`):

```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["-y", "@slack/mcp-server"],
      "env": {
        "SLACK_BOT_TOKEN": "xoxb-your-token-here"
      }
    }
  }
}
```

The Slack MCP server provides tools for:
- **Search**: messages and files, filter by date/user/type
- **Retrieve**: channel history, thread history, full message content
- **Discover**: channel list, user info, workspace members

A subagent with `mcpServers: ["slack"]` in its frontmatter gets these tools automatically.

### Subagent File: Slack Scanner

Store at `.claude/agents/slack-scanner.md`:

```yaml
---
name: slack-scanner
description: Scans Slack for knowledge signals — substantive threads, shared resources, boss/peer recommendations. Produces structured source notes ready for atomic splitting.
mcpServers: ["slack"]
tools: Read, Write, Bash
model: haiku
permissionMode: acceptEdits
---

[system prompt body — see FEATURES.md for behavior spec]
```

**Why haiku for scanning**: Fast, cheap, adequate for extraction. Reserve sonnet/opus for synthesis.

### Subagent File: Content Strategist

Store at `.claude/agents/content-strategist.md`:

```yaml
---
name: content-strategist
description: Reviews vault content, clusters atomic notes into themes, and synthesizes draft blog posts with citations. Invoke for weekly synthesis sessions.
tools: Read, Write, Grep, Glob, Bash
model: inherit
permissionMode: acceptEdits
memory: local
---

[system prompt body — see FEATURES.md for behavior spec]
```

**Why `memory: local`**: Builds up knowledge about vault structure and recurring themes across sessions without committing memory to version control (sensitive personal vault).

### Skill Files: Atomic Splitting and Theme Matching

Store at `.claude/skills/split-atomic/SKILL.md`:

```yaml
---
name: split-atomic
description: Split a long source note into multiple atomic concept notes, each covering one idea with proper frontmatter and backlinks. Use when a source note contains more than 2-3 distinct concepts.
disable-model-invocation: true
allowed-tools: Read, Write, Grep
---

[instructions for atomic splitting — see FEATURES.md]
```

Store at `.claude/skills/match-themes/SKILL.md`:

```yaml
---
name: match-themes
description: Given a new note or set of notes, identify related existing vault notes and suggest connections, tags, and backlinks. Use after creating new atomic notes.
allowed-tools: Read, Grep, Glob
---

[instructions for theme matching — see FEATURES.md]
```

### Outlook Scanner: Python Upgrade

Replace bash `scan-outlook.sh` URL scraping with a Python script using `msgraph-sdk`:

```python
# scan-outlook-content.py — replaces URL-only extraction
from msgraph import GraphServiceClient
from azure.identity import ClientSecretCredential

credential = ClientSecretCredential(tenant_id, client_id, client_secret)
client = GraphServiceClient(credential)

# Get messages with full body content (not just body.preview)
messages = await client.me.messages.get(
    request_configuration={
        "query_parameters": {
            "filter": f"from/emailAddress/address eq '{boss_email}' and receivedDateTime ge {since_iso}",
            "select": ["subject", "body", "from", "receivedDateTime"],
            "top": 50
        }
    }
)
```

**Why**: The bash implementation uses `grep -oE 'https?://...'` on raw JSON. This extracts URLs but discards message context, threading, and body text. The Python SDK returns typed objects with `message.body.content` (full HTML or text body), enabling content analysis not just URL harvesting.

---

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Official Slack MCP server (`@slack/mcp-server`) | `korotovsky/slack-mcp-server` (community) | Community server has more permissive scope options and supports GovSlack. Use if the official server lacks a needed tool (e.g., DM access). Official is preferred for stability since it's GA from Slack itself. |
| Claude Code skills + subagents | Full Python agent framework (LangChain, LangGraph) | If the pipeline needed to run without Claude Code or required complex multi-agent state. Current setup runs on macOS with Claude Code installed — no reason to add a Python agent framework. |
| `msgraph-sdk` Python | bash `curl` + `sed` JSON parsing | Keep bash-only if staying with URL extraction only. Once you need message body content, bash parsing of Graph API JSON responses is brittle (nested HTML in JSON strings, character escaping). |
| `python-frontmatter` | Manual YAML string manipulation | Manual string manipulation for frontmatter is fragile when content contains colons, quotes, or multiline strings. `python-frontmatter` handles these edge cases correctly. |
| Claude Code headless (`claude -p`) | Dedicated enrichment API (Anthropic Messages API directly) | Use Messages API directly if you need to control token costs precisely or if Claude Code is not available. The `claude -p` pattern reuses the existing enrichment infrastructure and has no code to write. |

---

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Slack Web API REST calls (bash `curl`) for content scanning | The existing `scan-slack.sh` extracts URLs only. Expanding it to extract full message content + threading via raw REST calls requires complex JSON parsing across paginated responses. MCP handles this natively with proper tool descriptions that Claude understands semantically. | Official Slack MCP server |
| Slack Legacy Stars API (`stars.list`) | Current `scan-slack.sh` uses `stars.list`. This API is deprecated per Slack's 2023 migration to Saved Items. New Slack workspaces may return empty results. | Slack Saved Items via MCP search tool or bookmark/reaction-based signals |
| OpenAI embeddings for theme matching | Adds a paid API dependency and requires local vector storage. Overkill for a single-person vault at this scale. | Grep-based theme matching in Claude Code (already established as the v1 approach per PROJECT.md out-of-scope decision) |
| LangChain/LangGraph | Heavyweight orchestration framework. The whole pipeline is bash + Python + Claude Code. No reason to introduce a Python agent framework for what skills and subagents handle natively. | Claude Code skills + subagents |
| n8n orchestration | Deferred to a future version per PROJECT.md. Building n8n workflows now adds infrastructure complexity before the core intelligence layer is validated. | Bash + launchd scheduling (existing) |
| `microsoft-graph-api` (PyPI, unofficial) | Unmaintained, last release 2019. | `msgraph-sdk` (official Microsoft SDK, actively maintained, v1.54.0 Feb 2026) |

---

## Stack Patterns by Variant

**If you want fully automated daily runs (no interaction):**
- Use `claude -p "/skill-name arguments"` in launchd job
- Skills with `disable-model-invocation: true` won't auto-trigger; invoke explicitly
- Output goes to stdout; redirect to log file

**If you want interactive content co-creation sessions:**
- Start Claude Code interactively, invoke content-strategist subagent explicitly
- Use `memory: local` on the subagent so it remembers vault structure across sessions
- The strategist's system prompt should reference vault SCHEMA.md and existing themes

**If Slack MCP token scopes are insufficient for some channels:**
- Fall back to existing `scan-slack.sh` bash REST calls for those specific channels
- Both approaches can coexist: MCP for richer content, REST for URL-only fallback

**If Graph API requires delegated (user) auth instead of app auth:**
- Use MSAL device code flow for first-time auth: `msal.PublicClientApplication.acquire_token_by_device_flow()`
- Cache the resulting token to `~/.model-citizen/ms-token-cache.json`
- Existing `scan-outlook.sh` already documents this fallback path

---

## Version Compatibility

| Package | Compatible With | Notes |
|---------|-----------------|-------|
| `msgraph-sdk==1.54.0` | Python >=3.9 | Works with Homebrew Python 3.12.11 at `/opt/homebrew/bin/python3.12` |
| `msal==1.31.0` | Python >=3.7 | Compatible with system Python 3.9 and Homebrew 3.12 |
| `python-frontmatter==1.1.0` | Python >=3.7 | Depends on PyYAML; no conflicts with existing stack |
| Slack MCP server `@slack/mcp-server` | Node.js (any recent LTS) | Invoked via `npx` — no permanent install needed |
| Claude Code skills | Current Claude Code | SKILL.md format is stable; skills and subagents were merged in current version |

---

## Sources

- [Claude Code Sub-agents docs](https://code.claude.com/docs/en/sub-agents) — HIGH confidence, fetched directly; confirmed frontmatter fields, `mcpServers` field, `skills` field, `memory` field, model aliases
- [Claude Code Skills docs](https://code.claude.com/docs/en/skills) — HIGH confidence, fetched directly; confirmed `SKILL.md` format, `disable-model-invocation`, `context: fork`, `allowed-tools`, skill locations
- [Slack MCP Server announcement](https://docs.slack.dev/changelog/2026/02/17/slack-mcp/) — MEDIUM confidence (GA announcement confirmed, tool list categories confirmed; individual tool parameters not detailed in public docs)
- [Slack MCP Server docs](https://docs.slack.dev/ai/slack-mcp-server/) — MEDIUM confidence; tool categories confirmed (search, retrieve messages, canvases, users); OAuth scopes required
- [msgraph-sdk PyPI](https://pypi.org/project/msgraph-sdk/) — HIGH confidence; v1.54.0 released 2026-02-06, Python >=3.9 requirement confirmed
- Direct codebase inspection — HIGH confidence; `scan-slack.sh` and `scan-outlook.sh` verified to confirm what already exists and what is missing (content extraction vs URL-only)
- [Claude Code headless docs](https://code.claude.com/docs/en/headless) — HIGH confidence; `-p` flag confirmed for non-interactive use

---

*Stack research for: v1.3 Content Intelligence Pipeline — Claude Code skills, Slack MCP, Outlook content, atomic splitting, synthesis*
*Researched: 2026-02-22*
