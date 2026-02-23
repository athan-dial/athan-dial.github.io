# Architecture Research

**Domain:** Content Intelligence Pipeline — v1.3 upgrade adding Claude Code skills, Slack MCP, Outlook content scanning, atomic note creation, theme matching, and draft synthesis
**Researched:** 2026-02-22
**Confidence:** HIGH (based on verified codebase + confirmed stack research in STACK.md)

---

## Standard Architecture

### System Overview: v1.3 Intelligence Tier on Top of v1.2

The existing system has three layers (scan → vault → Quartz publish). v1.3 inserts an **intelligence tier** between the scan layer and the vault. Bash scanners remain as URL-capture fallbacks. Claude Code agents run alongside them, doing content-level work rather than URL extraction.

```
┌─────────────────────────────────────────────────────────────────┐
│                      PUBLIC (Quartz Site)                        │
│              https://athan-dial.github.io/model-citizen/         │
│  publish-sync.sh syncs approved vault notes → GitHub → Pages     │
└───────────────────────────────▲─────────────────────────────────┘
                                │ approved notes only (dual gate)
┌───────────────────────────────┴─────────────────────────────────┐
│                    PRIVATE (Obsidian Vault)                       │
│  inbox/         → raw captures                                    │
│  sources/       → normalized source notes (URL + content)        │
│  atoms/         → atomic concept notes (ONE idea per note) [NEW] │
│  themes/        → theme index + backlink clusters          [NEW] │
│  enriched/      → AI-enriched sources (existing)                 │
│  ideas/         → blog angles (existing)                         │
│  drafts/        → synthesized blog post drafts             [NEW] │
│  publish_queue/ → approved for publication (existing)            │
└───────────────────────────────▲─────────────────────────────────┘
                                │ writes notes
┌───────────────────────────────┴─────────────────────────────────┐
│          INTELLIGENCE TIER (Claude Code)                [NEW]    │
│                                                                   │
│  ┌──────────────────┐   ┌────────────────────────────────────┐  │
│  │  slack-scanner   │   │  scan-outlook-content.py           │  │
│  │  subagent        │   │  (msgraph-sdk, Python)             │  │
│  │  (Slack MCP)     │   │  → full email body, not URLs only  │  │
│  └────────┬─────────┘   └────────────────┬───────────────────┘  │
│           └──────────────────┬───────────┘                       │
│                              ▼                                    │
│              vault/sources/*.md  (content-rich notes)            │
│                              │                                    │
│                              ▼                                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │   split-atomic skill  (claude -p per note)                │  │
│  │   → splits multi-concept sources into vault/atoms/*.md    │  │
│  └───────────────────────────┬───────────────────────────────┘  │
│                              ▼                                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │   match-themes skill  (claude -p per atom)                │  │
│  │   → finds related atoms, updates vault/themes/*.md        │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │   content-strategist subagent  (interactive only)         │  │
│  │   → clusters atoms → draft blog posts with citations      │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                │ URL stubs (unchanged)
┌───────────────────────────────┴─────────────────────────────────┐
│                SCAN LAYER (Bash Scripts — unchanged)             │
│  scan-all.sh  → orchestrator (launchd daily)                     │
│  scan-slack.sh  → Slack REST API → URLs → capture-web.sh        │
│  scan-outlook.sh → Graph API → URLs → capture-web.sh            │
│  ingest-goodlinks.sh → SQLite → notes                            │
│  capture-queue.sh → manual web clips                             │
└─────────────────────────────────────────────────────────────────┘
```

**Critical design principle:** v1.3 does not replace the bash layer. Bash scanners continue running as the URL-capture fallback. The intelligence tier adds a parallel path producing richer content. Both paths write to the vault. The vault is the integration point. URL normalization (v1.2) prevents the same URL from creating two notes.

---

## Component Responsibilities

| Component | Responsibility | Type | New / Modified / Unchanged |
|-----------|----------------|------|---------------------------|
| `scan-all.sh` | Orchestrates daily scan, all sources | Bash | Modified — add step to call `run-intelligence.sh` |
| `scan-slack.sh` | Extracts URLs from Slack saved items + boss DMs | Bash | Unchanged (URL-only fallback) |
| `scan-outlook.sh` | Extracts URLs from Outlook emails | Bash | Unchanged (URL-only fallback) |
| `ingest-goodlinks.sh` | Scans GoodLinks SQLite → full content notes | Bash | Unchanged |
| `capture-queue.sh` | Processes manual web clips | Bash | Unchanged |
| `slack-scanner` subagent | Scans Slack via MCP, writes source notes with full message content | Claude Code subagent | New |
| `scan-outlook-content.py` | Fetches email bodies via msgraph-sdk, writes source notes | Python | New |
| `run-intelligence.sh` | Bash orchestrator: invokes intelligence tier steps in sequence | Bash | New |
| `split-atomic` skill | Splits multi-concept source notes into one-idea atoms | Claude Code skill | New |
| `match-themes` skill | Finds related vault atoms, adds backlinks to theme index | Claude Code skill | New |
| `content-strategist` subagent | Interactive: clusters atoms, writes draft blog posts with citations | Claude Code subagent | New |
| `enrich-vault.sh` | Runs enrichment (summaries, tags, quotes) | Bash + `claude -p` | Modified — trigger `split-atomic` after enrichment |
| Vault `atoms/` folder | One-idea atomic concept notes | Obsidian folder | New |
| Vault `themes/` folder | Theme index files, backlink clusters | Obsidian folder | New |
| `vault/SCHEMA.md` | Canonical frontmatter schema for all note types | Markdown doc | New |
| `~/.claude/settings.json` | Global Claude Code config | JSON | Modified — add Slack MCP server |
| Vault frontmatter schema | Frontmatter YAML conventions | Schema | Extended — add `type: atom`, `atom_of`, `theme` |

---

## Recommended Project Structure

New files v1.3 adds, relative to existing repo layout:

```
model-citizen/                         # git repo
├── scripts/
│   ├── scan-all.sh                    # existing — minor: add intelligence step
│   ├── scan-slack.sh                  # existing — unchanged
│   ├── scan-outlook.sh                # existing — unchanged
│   ├── scan-outlook-content.py        # NEW — Python Graph API content scanner
│   └── run-intelligence.sh            # NEW — invokes Claude Code skills in sequence
│
└── .claude/
    ├── agents/
    │   ├── slack-scanner.md           # NEW — subagent + Slack MCP config
    │   └── content-strategist.md      # NEW — interactive synthesis subagent
    └── skills/
        ├── split-atomic/
        │   └── SKILL.md               # NEW — atomic splitting instructions
        └── match-themes/
            └── SKILL.md               # NEW — theme matching instructions

vault/                                 # Obsidian vault, iCloud-synced
├── inbox/                             # existing — raw captures
├── sources/                           # existing — normalized source notes
├── atoms/                             # NEW — atomic concept notes
├── themes/                            # NEW — theme index notes
├── enriched/                          # existing — AI-enriched sources
├── ideas/                             # existing — blog angles
├── drafts/                            # existing — blog post drafts
├── publish_queue/                     # existing — approved for publication
└── SCHEMA.md                          # NEW — canonical frontmatter schema
```

### Structure Rationale

- **`atoms/`**: Kept separate from `sources/` because atoms are derivative — they are split from sources. Co-location would blur the three-layer model. Obsidian Auto Note Mover can route notes tagged `#atom` here automatically.
- **`themes/`**: Index-style notes (one per recurring theme) that aggregate backlinks. These are the theme-matching target. Quartz renders backlinks visually, so theme notes double as knowledge graph entry points.
- **`.claude/agents/` and `.claude/skills/`**: Committed to the `model-citizen` repo so skills and subagents are version-controlled and reproducible. Not just in `~/.claude/` user-level config.
- **`vault/SCHEMA.md`**: Subagents need to know the vault's frontmatter conventions. A committed schema file is more reliable than embedding the schema inline in every agent prompt.

---

## Architectural Patterns

### Pattern 1: Dual-Path Scanning

**What:** Bash URL scanners and Claude Code content scanners run independently. Bash produces URL-stub notes; Claude Code produces content-rich notes. URL normalization (v1.2) prevents duplicate notes for the same URL.

**When to use:** Always in v1.3. Bash runs reliably even when Claude Code invocation fails. Claude Code runs for richer output when available.

**Trade-offs:** Two parallel paths create two note schemas initially. The existing `content_status: pending` stub handling is the reconciliation mechanism — Claude Code notes overwrite stubs if the URL was already captured by bash.

```bash
# scan-all.sh ordering: bash scan first (always), intelligence tier after
./scan-slack.sh              # produces URL stubs → sources/
./scan-outlook.sh            # produces URL stubs → sources/
./ingest-goodlinks.sh        # produces full notes → sources/
./capture-queue.sh           # processes web clips → sources/
./run-intelligence.sh        # enriches stubs, creates atoms via Claude Code
```

### Pattern 2: Pipeline as Skill Chain

**What:** Each transformation step (source → atom → theme match) is an independent Claude Code skill invoked sequentially via bash. Each step reads from one vault folder and writes to the next.

**When to use:** Single-person vault with no concurrent writers. Sequential pipeline is simpler and debuggable — any single step can be re-run without re-running the full pipeline.

**Trade-offs:** No parallelism across steps. Acceptable for one person's vault volume (estimated <50 new notes/day).

```bash
# run-intelligence.sh pattern (simplified)
# Step 1: Slack content scan
claude --agent slack-scanner "scan Slack since $SINCE_ISO, write to vault/sources/"

# Step 2: Outlook content scan
python3 scan-outlook-content.py --since "$SINCE_ISO"

# Step 3: Split new sources into atoms
for note in vault/sources/slack-*.md vault/sources/email-*.md; do
  claude -p "/split-atomic $note"
done

# Step 4: Match themes for new atoms
for atom in vault/atoms/$(date +%Y-%m-%d)-*.md; do
  claude -p "/match-themes $atom"
done
```

### Pattern 3: Stateful Subagent for Interactive Synthesis

**What:** The `content-strategist` subagent uses `memory: local` to accumulate knowledge about the vault's recurring themes and which atoms have been drafted. Interactive sessions build on this persistent context.

**When to use:** Weekly synthesis sessions — propose blog post clusters, write drafts. Not for automated daily runs; requires human direction.

**Trade-offs:** Local memory is machine-specific. If you switch machines, the strategist loses memory. Acceptable for macOS-primary workflow.

```
User: "What are the 3 most clusterable themes in atoms/ from the last 2 weeks?"
Strategist: [reads atoms/, compares to theme index, proposes clusters]
User: "Draft a post on Decision Velocity, cite 5 atoms."
Strategist: [writes vault/drafts/decision-velocity-draft.md with [[backlinks]]]
```

### Pattern 4: Vault as Integration Point

**What:** All components write markdown files to the vault. No direct component-to-component calls. The vault's folder structure and frontmatter schema is the contract.

**When to use:** Always — this is the existing system's core design decision. The intelligence tier follows the same pattern rather than introducing direct pipes.

**Trade-offs:** Everything must be file-based. No streaming, no webhooks. Appropriate for a local personal system; would not scale to multi-user use.

---

## Data Flow

### Daily Automated Flow (Unattended, launchd at 08:00)

```
launchd → scan-all.sh
  → scan-slack.sh       → vault/sources/slack-*.md     (URL stubs)
  → scan-outlook.sh     → vault/sources/email-*.md     (URL stubs)
  → ingest-goodlinks.sh → vault/sources/gl-*.md        (full content)
  → capture-queue.sh    → vault/sources/web-*.md       (web clips)
  → run-intelligence.sh
      → slack-scanner subagent [Slack MCP]
          reads Slack channels since last-scan timestamp
          writes vault/sources/slack-content-*.md     (full message context)
      → scan-outlook-content.py [msgraph-sdk]
          reads Outlook emails since last-scan timestamp
          writes vault/sources/email-content-*.md     (full email body)
      → split-atomic skill [claude -p, per new source]
          reads vault/sources/*content*.md
          writes vault/atoms/YYYY-MM-DD-concept-*.md  (one idea each)
          updates source note: atom_count: N
      → match-themes skill [claude -p, per new atom]
          reads vault/atoms/ (new atoms), vault/themes/ (existing index)
          updates vault/themes/theme-name.md          (adds backlinks)
          creates new theme file if theme is novel
```

### Weekly Interactive Flow (Human-Directed)

```
User opens Claude Code
  → invokes content-strategist subagent
      reads vault/atoms/ (last 30 days)
      reads vault/themes/ (all theme index notes)
      proposes 2-3 blog post cluster options

User approves cluster
  → strategist writes vault/drafts/post-slug.md
      includes [[atom-note]] citations throughout
      includes sources frontmatter listing source notes

User reviews in Obsidian
  → edits draft as needed
  → moves to vault/publish_queue/ OR adds status: publish

User runs publish-sync.sh
  → Quartz repo updated → GitHub Actions → Pages live
```

### Frontmatter Schema: New Fields for v1.3

Existing vault frontmatter is extended with new fields:

```yaml
---
title: "One Concept Title"
created: 2026-02-22
modified: 2026-02-22
type: "atom"                          # NEW: atom | source | draft | theme-index
atom_of: "[[source-note-title]]"      # NEW: backlink to source note this split from
atom_count: 3                         # NEW: on source notes — how many atoms derived
theme: ["decision-velocity", "measurement"]   # NEW: which themes this atom belongs to
source: "Slack"                       # existing
tags: [decision-velocity, metrics]    # existing
status: "draft"                       # existing
---
```

**`vault/SCHEMA.md`**: Committed to vault root. Subagent system prompts reference it as a single source of truth. This avoids embedding the schema inline in every agent file and keeps it in sync automatically.

---

## Integration Points

### External Services

| Service | Integration Pattern | Connection Point | Notes |
|---------|---------------------|-----------------|-------|
| Slack (MCP) | `@slack/mcp-server` via `npx`, in `~/.claude/settings.json` | `slack-scanner` subagent's `mcpServers: ["slack"]` frontmatter field | Requires existing `SLACK_BOT_TOKEN` in `~/.model-citizen/env`. MCP server auto-started by Claude Code when subagent is invoked. |
| Microsoft Graph | `msgraph-sdk` Python OAuth client credentials | `scan-outlook-content.py` | Reuses `MS_GRAPH_*` credentials from `~/.model-citizen/env`. Python script called from `run-intelligence.sh`. |
| Claude Code headless | `claude -p "/skill-name args"` subprocess | `run-intelligence.sh` bash script | Existing pattern from `enrich-vault.sh`. Each skill invocation is a separate process. |
| Obsidian iCloud sync | iCloud Drive folder at known path | All scripts write to iCloud path | No change from v1.2. Vault path constant. |

### Internal Boundaries

| Boundary | Communication Pattern | Notes |
|----------|-----------------------|-------|
| Bash scanners → vault | File writes to `vault/sources/` | Unchanged from v1.2 |
| `slack-scanner` subagent → vault | File writes to `vault/sources/` | Same frontmatter schema as bash scanner output |
| `scan-outlook-content.py` → vault | File writes to `vault/sources/` | Schema-compatible with existing source notes |
| `split-atomic` skill → `vault/atoms/` | File writes; does NOT delete or modify source | Source note gets `atom_count: N` field updated |
| `match-themes` skill → `vault/themes/` | Appends backlinks to existing theme index; creates new theme file if novel | Non-destructive |
| `content-strategist` → `vault/drafts/` | File writes with `[[wiki-link]]` citations to atom notes | Obsidian wiki-link syntax for backlinks |
| `run-intelligence.sh` → Claude Code | `claude -p` subprocess, blocking, sequential | Exit codes propagate to `scan-all.sh` for failure tracking |

### Slack MCP State Management

The MCP server does not maintain scan state. State stays in bash:

```bash
# run-intelligence.sh: read state, pass as argument to subagent
LAST_SCAN=$(cat ~/.model-citizen/slack-last-scan 2>/dev/null || date -v-24H +%s)
SINCE_ISO=$(date -u -r "$LAST_SCAN" +"%Y-%m-%dT%H:%M:%SZ")

claude --agent slack-scanner \
  "Scan Slack for messages since $SINCE_ISO. Write source notes to vault/sources/. \
   Focus on: links shared, substantive threads, recommendations from boss."

# Update timestamp after successful scan
date +%s > ~/.model-citizen/slack-last-scan
```

Bash remains the state authority. The subagent is stateless per invocation.

---

## New vs Modified Components

### New Components

| Component | File Path | What It Does |
|-----------|-----------|--------------|
| Slack scanner subagent | `.claude/agents/slack-scanner.md` | System prompt + Slack MCP config for content-level scanning |
| Outlook content scanner | `model-citizen/scripts/scan-outlook-content.py` | Python msgraph-sdk caller extracting full email bodies |
| Atomic split skill | `.claude/skills/split-atomic/SKILL.md` | Instructions for splitting multi-concept sources into atomic notes |
| Theme match skill | `.claude/skills/match-themes/SKILL.md` | Instructions for finding related vault content and adding backlinks |
| Content strategist subagent | `.claude/agents/content-strategist.md` | Interactive synthesis agent with persistent vault memory |
| Intelligence orchestrator | `model-citizen/scripts/run-intelligence.sh` | Bash wrapper invoking Claude Code skills in order |
| Vault schema doc | `vault/SCHEMA.md` | Canonical frontmatter schema for subagent reference |
| `atoms/` vault folder | Obsidian vault | Landing zone for atomic concept notes |
| `themes/` vault folder | Obsidian vault | Landing zone for theme index notes |

### Modified Components

| Component | File Path | What Changes |
|-----------|-----------|-------------|
| `scan-all.sh` | `model-citizen/scripts/scan-all.sh` | Add step 5: call `run-intelligence.sh` after bash scans complete |
| `~/.claude/settings.json` | Global Claude Code config | Add `slack` MCP server entry under `mcpServers` |
| Vault frontmatter schema | Used by all scripts and subagents | Add `type: atom`, `atom_of`, `atom_count`, `theme` fields |
| `enrich-vault.sh` | Enrichment script | After enrichment, trigger `split-atomic` on the enriched note |

### Unchanged Components

- `scan-slack.sh` — URL extraction fallback remains
- `scan-outlook.sh` — URL extraction fallback remains
- `ingest-goodlinks.sh` — working, no changes needed
- `capture-queue.sh` — working, no changes needed
- `publish-sync.sh` — working, no changes needed
- Quartz site configuration — no changes needed
- Hugo portfolio site — completely separate, no changes

---

## Build Order (Dependency-Driven)

Dependencies flow: vault schema → content scanners → splitting → matching → orchestration → synthesis. Each phase is independently testable before the next begins.

### Phase 1: Foundation — Vault Folders + Schema

**Build:**
- Create `vault/atoms/` folder
- Create `vault/themes/` folder
- Write `vault/SCHEMA.md` with all frontmatter field definitions (existing + new fields)
- Update Obsidian Auto Note Mover rules: notes tagged `#atom` → `atoms/`, tagged `#theme-index` → `themes/`

**Why first:** Every subsequent component references the schema and writes to these folders. Build the landing zones and the contract before the components that use them.

**Test:** Create a manual test atom note, verify Auto Note Mover routes it correctly.

### Phase 2: Outlook Content Scanner

**Build:** `scan-outlook-content.py`

- Python script using `msgraph-sdk` to fetch full email bodies (not URL scraping)
- Writes `vault/sources/email-content-YYYYMMDD-*.md` with full content
- Uses existing `MS_GRAPH_*` credentials from `~/.model-citizen/env`
- Standalone test: `python3 scan-outlook-content.py --since 2026-02-20 --dry-run`

**Why second:** No Claude Code dependency. Tests that Graph API content extraction works before building intelligence layer on top. Known credentials, known API — lower risk than Slack MCP.

**Test:** Run against one week of emails, verify output note format matches vault schema.

### Phase 3: Slack Scanner Subagent

**Build:** `.claude/agents/slack-scanner.md` + Slack MCP config in `~/.claude/settings.json`

- Configure `@slack/mcp-server` in global Claude Code settings
- Write subagent system prompt defining scanning behavior and output note format
- Test interactively: `claude --agent slack-scanner "scan yesterday's messages"`
- Verify output notes match vault schema

**Why third:** Slack MCP is the newer, less-proven component. Isolating it lets you validate MCP connectivity and Slack permissions before wiring into automation.

**Test:** Invoke subagent interactively, inspect one output note for schema compliance.

### Phase 4: Atomic Split Skill

**Build:** `.claude/skills/split-atomic/SKILL.md`

- Write skill instructions for splitting multi-concept sources into one-idea atoms
- Define output schema for atom notes (`type: atom`, `atom_of`, `theme`, `tags`)
- Test on an existing enriched source note: `claude -p "/split-atomic vault/sources/some-note.md"`
- Validate output notes appear in `vault/atoms/`

**Why fourth:** Depends on Phase 1 (atoms/ folder exists + schema defined). Build after Phases 2-3 so realistic source notes exist to test splitting against.

**Test:** Split one real source note, verify: (1) atoms appear in `vault/atoms/`, (2) `atom_of` backlink is correct, (3) source note gets `atom_count` updated.

### Phase 5: Theme Match Skill

**Build:** `.claude/skills/match-themes/SKILL.md`

- Write skill instructions for finding related atoms and updating theme index
- Define behavior: update existing theme note vs. create new theme note
- Test on output from Phase 4: `claude -p "/match-themes vault/atoms/some-atom.md"`
- Validate backlinks appear in `vault/themes/`

**Why fifth:** Requires atoms to exist (Phase 4 output). The theme matcher reads `atoms/` and `themes/` — both must contain real content to verify matching logic is meaningful.

**Test:** Run on 5 atoms from same topic, verify a coherent theme note is created or updated.

### Phase 6: Intelligence Orchestrator

**Build:** `model-citizen/scripts/run-intelligence.sh` + integration into `scan-all.sh`

- Write bash script invoking Phases 2-5 in sequence with error handling
- Continue on individual step failure (same pattern as `scan-all.sh` existing scanners)
- Log to `~/.model-citizen/intelligence.log`
- Test standalone: `./run-intelligence.sh --dry-run`
- Add as final step in `scan-all.sh`

**Why sixth:** Integration step — wires everything from Phases 2-5 into existing daily automation. Building last avoids integrating components that aren't working yet.

**Test:** Run full daily scan with intelligence tier enabled, check log for each step completing.

### Phase 7: Content Strategist Subagent

**Build:** `.claude/agents/content-strategist.md`

- Write subagent system prompt for interactive synthesis
- Reference `vault/SCHEMA.md` and key vault folders
- Configure `memory: local` so vault pattern knowledge persists across sessions
- Test interactively: open Claude Code, invoke strategist, verify atom clustering and draft output

**Why last:** The strategist is the interactive capstone. It requires all prior components producing quality input. Validating it last confirms the full three-layer model works end-to-end.

**Test:** Ask strategist to propose blog post clusters from atoms created in Phases 4-5, then draft one. Verify draft has valid backlinks and matches vault schema.

---

## Anti-Patterns

### Anti-Pattern 1: Replacing Bash Scanners with Intelligence Tier

**What people do:** Replace `scan-slack.sh` with the MCP scanner; delete the bash script.

**Why it's wrong:** Bash is a reliable URL-capture fallback. If MCP connectivity fails (Slack token expired, `npx` not in PATH in launchd environment), you lose all Slack scanning. Dual-path ensures capture always happens regardless of Claude Code availability.

**Do this instead:** Keep both. MCP scanner produces rich notes; bash scanner produces URL stubs. URL normalization prevents duplicates. The bash layer is the reliability layer.

### Anti-Pattern 2: Stateful Skills

**What people do:** Build last-scan tracking (timestamps, seen-atom IDs) inside Claude Code skill prompts.

**Why it's wrong:** Skills run as ephemeral `claude -p` processes. They don't persist state between invocations. State written to a file in one run may not be read reliably in the next.

**Do this instead:** Keep all state in bash-managed files under `~/.model-citizen/` (existing pattern). Pass state as arguments to skills: `claude -p "/split-atomic --since 2026-02-21 vault/sources/note.md"`.

### Anti-Pattern 3: Atomic Notes Without Source Backlinks

**What people do:** `split-atomic` creates atoms but doesn't add `atom_of: [[source]]` backlinks.

**Why it's wrong:** Without backlinks, you can't trace a claim in an atom back to its source. The synthesis workflow relies on citation chains: draft → atom → source. Broken chains undermine the "decision evidence, not achievements" brand positioning.

**Do this instead:** Enforce `atom_of` as a required field in `vault/SCHEMA.md`. The `split-atomic` skill system prompt should treat missing `atom_of` as invalid output and retry.

### Anti-Pattern 4: Running Content Strategist in Automation

**What people do:** Add content-strategist to `run-intelligence.sh` so it runs daily unattended.

**Why it's wrong:** The strategist produces draft blog posts — content requiring editorial judgment. Automating it means drafts appear without human review, violating the system's explicit publish gate principle.

**Do this instead:** The strategist is interactive-only. Daily automation stops at theme matching. Draft creation requires explicit human invocation.

---

## Scaling Considerations

This is a single-person system. Scaling concerns are about content volume, not user volume.

| Scale | Architecture Adjustment |
|-------|------------------------|
| < 50 source notes/month | Sequential pipeline; `claude -p` per note — no changes needed |
| 50-200 notes/month | Batch split-atomic: pass a folder path to skill instead of per-note invocation |
| 200+ notes/month | `claude -p` startup overhead (2-5s/invocation) becomes significant; add sleep/throttle in orchestrator or switch to batch mode |
| Multiple machines | `.claude/agents/` and `.claude/skills/` are git-tracked and portable; `~/.claude/settings.json` needs manual sync |

**First bottleneck:** Serial `claude -p` invocations. At high volume, startup overhead accumulates. Mitigation: modify skills to accept a list of file paths and process them in a single Claude invocation rather than one invocation per file.

---

## Sources

- Verified codebase: `scan-slack.sh`, `scan-outlook.sh`, `scan-all.sh` — confirmed URL-only extraction, state file patterns, bash orchestration (HIGH confidence)
- `model-citizen/ARCHITECTURE.md` — verified vault folder structure, dual-gate approval, existing data flows (HIGH confidence)
- `.planning/research/STACK.md` (same milestone) — Claude Code subagent/skill frontmatter fields, Slack MCP config, msgraph-sdk (HIGH confidence)
- `.planning/PROJECT.md` — confirmed v1.3 feature list, explicit out-of-scope decisions (n8n deferred, embeddings deferred) (HIGH confidence)
- `~/.model-citizen/env.example` — confirmed existing credential structure, state file location patterns (HIGH confidence)

---

*Architecture research for: v1.3 Content Intelligence Pipeline — Claude Code skills + Slack MCP + Outlook content scanning + atomic notes + theme matching + synthesis*
*Researched: 2026-02-22*
