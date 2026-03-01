# Phase 15: Intelligence Skills - Research

**Researched:** 2026-03-01
**Domain:** Claude Code skills — Slack scanner (MCP), Outlook scanner (Graph API), atomic splitting, theme matching, synthesis
**Confidence:** HIGH (scanners, splitting, theme matching) / MEDIUM (Slack MCP parameter names)

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SCAN-01 | Slack scanner extracts full message content from starred items and specified channels via MCP tools | Slack MCP exists via Claude Code tools; starred items use `slack_get_starred_items` or equivalent; full message text available (not just URLs) |
| SCAN-02 | Slack scanner preserves conversational context (sender, channel, thread replies, reason for starring) | All provenance fields are available from Slack API responses; SCHEMA.md defines the target frontmatter |
| SCAN-03 | Outlook scanner extracts email subject and body content (not just URLs) via Graph API | Existing scan-outlook.sh uses Graph API but only captures URLs; replacement uses `$select=subject,body,from,receivedDateTime` to pull full body |
| SCAN-04 | Both scanners perform incremental scanning (only new content since last run) | State file pattern established in goodlinks-state.json (`last_scan_ts` + `seen_ids`); apply same pattern to Slack/Outlook |
| ATOM-01 | Splitting skill decomposes source notes into single-concept atomic notes | Claude Code subagent reads source note, outputs N atoms per SCHEMA.md; straightforward agentic task |
| ATOM-04 | Splitting preserves why-it-matters context from the original source | Splitting prompt must explicitly instruct: "For each atom, write 2–3 sentences explaining why this concept matters in the context of the original source" |
| THEME-01 | Matching skill connects new atomic notes to existing vault content via tags and titles (grep-based) | grep vault/atoms/*.md for tag overlap; grep vault/themes/ for title similarity; no embeddings needed at current vault scale |
| THEME-02 | Each connection includes written justification for why the link exists | Matching prompt must require a one-sentence justification per wikilink, written into the atom note body |
| THEME-03 | Maximum 3 theme connections per atomic note to prevent hub-and-spoke sprawl | Hard constraint in matching prompt: "Add at most 3 wikilinks. Stop after 3 even if more seem relevant." |
| SYNTH-01 | Synthesis workflow clusters related atomic notes by theme | Clustering = grouping atoms that share a theme tag or theme wikilink; grep-based, no ML |
| SYNTH-02 | Produces draft blog posts with inline citations to source atomic notes | Draft body includes `[[atom-title]]` wikilinks as inline citations; `source_atoms:` frontmatter lists all cited atoms |
| SYNTH-03 | Drafts do not introduce claims beyond what source notes support | Synthesis prompt must include: "Write only from the atom content provided. Do not introduce claims, examples, or statistics not present in the atoms." |

</phase_requirements>

---

## Summary

Phase 15 builds five standalone Claude Code skills that implement the intelligence pipeline. Each skill is a Claude Code command (markdown file in `.claude/commands/` or a skill in `.claude/skills/`) that agents execute against the vault.

The key architectural insight: all five skills are **purely agentic** — they read from and write to the Obsidian vault at the iCloud path. No new dependencies. No databases. No APIs beyond what already exists (Slack MCP, Microsoft Graph API).

**Critical discovery on ANM routing:** The Phase 14 ANM configuration uses **tag-based routing** (not pattern-based), matching `#type/source/slack` Obsidian tags. The SCHEMA.md documents this dual-field pattern: `type: atom` (YAML field for Dataview) + `tags: [type/atom]` (Obsidian tag for ANM). Every scanner must include both fields or notes will not auto-route.

**Critical finding on existing scanners:** The current `scan-slack.sh` and `scan-outlook.sh` extract URLs only and call `capture-web.sh`. They do NOT produce vault source notes with full message text. Phase 15 builds replacement skills that produce content-rich source notes matching SCHEMA.md, using either:
- Slack: Claude Code Slack MCP tools (primary approach) or direct Slack API calls (fallback)
- Outlook: Microsoft Graph API `$select=subject,body,...` to pull full email body

**Slack MCP confidence note:** Slack MCP parameter names are MEDIUM confidence. Plan an interactive debugging session as Task 1 of the Slack scanner plan before writing the final subagent prompt.

**Synthesis voice caveat:** ChatGPT Deep Research Voice & Style Guide is not yet available. The synthesis skill prompt should carry a `TODO: inject voice guide here` placeholder.

**Primary recommendation:** Build all 5 skills in a single parallel wave. Each skill is a CLAUDE.md skill or `.claude/commands/` markdown command. Slack scanner requires a debugging pre-step. Synthesis carries a voice TODO flag.

---

## Standard Stack

### Core

| Component | Version/Location | Purpose | Why This |
|-----------|-----------------|---------|----------|
| Claude Code subagent | Current session | Execute each skill | Established pattern from Phase 6/7 |
| Obsidian vault | `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/` | Read source notes, write atoms/themes/drafts | Already set up with ANM routing |
| SCHEMA.md | `model-citizen/vault/SCHEMA.md` | Frontmatter contract for all note types | Phase 14 deliverable |
| State files | `~/.model-citizen/{slack,outlook}-intelligence-state.json` | Incremental scan tracking | Same pattern as `goodlinks-state.json` |
| Slack MCP | Available in Claude Code session | Fetch starred messages with full text | Native MCP; no shell scripting needed |
| Microsoft Graph API | `https://graph.microsoft.com/v1.0/me/messages` | Fetch email subject + body | Credentials in `~/.model-citizen/env` |
| bash | macOS system | Skill wrapper scripts | Already used for all scanners |

### Supporting

| Component | Version/Location | Purpose | When to Use |
|-----------|-----------------|---------|-------------|
| `jq` | macOS system | Parse JSON from Graph API responses | Outlook scanner body extraction |
| `python3` | `/opt/homebrew/bin/python3.12` | State file manipulation | If bash JSON handling is fragile |
| ANM plugin | Obsidian | Auto-route notes to correct folders | Triggered when notes are saved to vault root or target folder |
| Dataview | Obsidian | Audit notes after creation | Verification only; not part of skill execution |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Slack MCP | Direct Slack API (curl) | MCP is cleaner for Claude Code; curl is fallback if MCP param names wrong |
| Graph API full body | Existing scan-outlook.sh (URL-only) | Existing script does not capture email body; rewrite required |
| grep-based theme matching | Vector embeddings | Embeddings deferred per PROJECT.md; grep is sufficient at current vault scale |
| Claude Code command (.md) | Python script | Skills as markdown commands align with established project pattern |

---

## Architecture Patterns

### Recommended Skill File Locations

```
.claude/commands/
├── scan-slack-intelligence.md    # Slack scanner skill
├── scan-outlook-intelligence.md  # Outlook scanner skill
├── split-source.md               # Atomic splitting skill
├── match-themes.md               # Theme matching skill
└── synthesize-draft.md           # Synthesis skill
```

Each command file is a markdown prompt that Claude Code executes as an agentic task.

**Vault paths:**
```
~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/
├── sources/slack/      # Slack scanner writes here
├── sources/outlook/    # Outlook scanner writes here
├── atoms/              # Splitting skill writes here
├── themes/             # Theme matching creates/updates here
└── drafts/             # Synthesis skill writes here
```

**State files:**
```
~/.model-citizen/
├── slack-intelligence-state.json   # {last_scan_ts, seen_ids: []}
└── outlook-intelligence-state.json # {last_scan_ts, seen_ids: []}
```

### Pattern 1: Scanner Skill (Slack)

**What:** Claude Code command that uses Slack MCP tools to fetch starred messages and write vault source notes.

**When to use:** User invokes `/scan-slack-intelligence` or skill is called from scan-all.sh integration.

**Flow:**
1. Read `~/.model-citizen/slack-intelligence-state.json` (create if absent, default `last_scan_ts: 0`)
2. Call Slack MCP `slack_get_starred_items` (or equivalent) — get full message text, sender, channel, timestamp
3. For each message: check if `ts` is in `seen_ids` — if yes, skip (idempotency)
4. For each new message: write vault source note matching SCHEMA.md source/slack format
5. Note filename: `Slack - {YYYY-MM-DD} - {sanitized-title}.md`
6. Note goes to vault root or `sources/slack/` directly — ANM routes to `sources/slack/` via `#type/source/slack` tag
7. Update state file: set `last_scan_ts` to now, append new `ts` values to `seen_ids`

**Critical:** Note must include BOTH:
- `type: source/slack` (YAML frontmatter — for Dataview)
- `tags: [type/source/slack]` (Obsidian tag array — for ANM routing)

**Example output note:**
```yaml
---
title: "Slack: Adoption curve framing from Duminda"
type: source/slack
created: 2026-03-01
content_status: raw
publishability: private
provenance:
  channel: product-analytics
  sender: duminda.wijesinghe
  timestamp: "1708579200.000000"
  thread_ts: "1708579100.000000"
  permalink: "https://montai.slack.com/archives/C123/p1708579200000000"
  starred_reason: "Good framing of the adoption curve problem"
tags: [type/source/slack]
---

[Full message text captured verbatim]
```

### Pattern 2: Scanner Skill (Outlook)

**What:** Claude Code command that uses Microsoft Graph API to fetch emails with full body text.

**When to use:** User invokes `/scan-outlook-intelligence` or called from scan-all.sh.

**Flow:**
1. Read `~/.model-citizen/outlook-intelligence-state.json`
2. Get OAuth token via client credentials (same as existing `scan-outlook.sh`)
3. Fetch messages: `GET /v1.0/me/messages?$select=id,subject,body,from,receivedDateTime&$filter=receivedDateTime ge {last_scan_iso}&$top=50`
4. For each message: check `id` against `seen_ids` — skip if present
5. Extract body: `body.content` (may be HTML — strip tags or use `body.contentType` check)
6. Write vault source note matching SCHEMA.md source/outlook format
7. Update state file

**HTML body stripping:** Use Python's `html.parser` or `sed` to strip HTML tags from `body.content`. Alternatively, request `text/plain` body via `$select=body` with `Prefer: outlook.body-content-type="text"` header (Graph API supports this).

**Example Graph API request:**
```bash
curl -s -X GET \
  "https://graph.microsoft.com/v1.0/me/messages?\$select=id,subject,body,from,receivedDateTime&\$top=50" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Prefer: outlook.body-content-type=\"text\""
```

### Pattern 3: Atomic Splitting Skill

**What:** Claude Code command that reads one source note, decomposes it into atomic notes.

**When to use:** User invokes `/split-source <note-path>` or automation runs it on all `content_status: raw` source notes.

**Flow:**
1. Read the source note from the vault
2. Agentic decomposition: identify N distinct concepts in the source note body
3. For each concept: write an atom note to `atoms/` with all required SCHEMA.md fields
4. Atom note body: the concept + 2–3 sentences explaining why it matters (ATOM-04)
5. Atom filename: `{sanitized-concept-title}.md`
6. Update source note `content_status` from `raw` to `processed`

**Splitting prompt core instruction:**
```
Read the source note. Identify each distinct concept, claim, or insight.
For each concept:
- Write a title that states the concept as a declarative sentence
- Write 2-3 sentences: the concept itself, then why it matters in context
- Assign split_index (1, 2, 3...) for ordering
Do NOT combine two concepts into one atom. Each atom = one idea.
```

**Required atom frontmatter fields:**
- `title`: Declarative sentence (the concept)
- `type: atom`
- `created`: Today's date
- `content_status: raw`
- `publishability: private`
- `atom_of`: Wikilink to parent source note
- `split_index`: Integer (1-based)
- `source_type`: `slack` or `outlook`
- `tags: [type/atom]`

### Pattern 4: Theme Matching Skill

**What:** Claude Code command that finds related vault content for a new atom and adds wikilinks.

**When to use:** User invokes `/match-themes <atom-path>` after splitting.

**Flow:**
1. Read the target atom note
2. grep `atoms/` for notes with overlapping tags
3. grep `themes/` for existing theme titles that match atom content
4. grep `atoms/` for title keywords from the target atom
5. Select top 3 candidates (THEME-03: max 3 connections)
6. For each connection: write a one-sentence justification into the atom body
7. If a matching theme note exists: add the atom wikilink to the theme's "## Related atoms" section
8. If no matching theme exists: create a new theme note per SCHEMA.md theme format

**grep commands for matching:**
```bash
# Find atoms with overlapping tags
grep -l "$(grep '^tags:' "$ATOM_PATH" | head -1)" "$VAULT/atoms/"*.md

# Find themes whose title words appear in the atom
grep -i "$(grep '^title:' "$ATOM_PATH" | sed 's/title: //')" "$VAULT/themes/"*.md
```

**Max 3 connections enforcement:** After finding candidates, take at most the top 3 by relevance (title keyword overlap count). Do not add a 4th connection even if it seems relevant.

**Written justification format in atom body:**
```markdown
## Theme connections

- [[User adoption psychology]] — This atom describes the plateau behavior that defines the adoption psychology theme
- [[Product-market fit signals]] — The 40% ceiling is a quantitative signal for fit limits
```

### Pattern 5: Synthesis Skill

**What:** Claude Code command that clusters atoms by theme and produces a draft blog post.

**When to use:** User invokes `/synthesize-draft <theme-or-topic>` interactively.

**Flow:**
1. Accept a theme name or topic as input
2. Find all atoms in `atoms/` that reference this theme (by tag or theme wikilink)
3. Read all matching atoms
4. Generate draft blog post: title, outline, body with inline `[[atom]]` citations
5. Write draft note to `drafts/` per SCHEMA.md draft format
6. `source_atoms:` frontmatter lists all atoms cited

**Synthesis prompt constraints (SYNTH-03):**
```
Write only from the atom content provided.
Do not introduce examples, statistics, or claims not present in the atoms.
Every paragraph should be traceable to at least one cited atom.
```

**Voice placeholder (pending Deep Research):**
```
TODO: Voice & Style Guide not yet available.
When available, inject Athan's signature patterns here.
For now: write in clear, direct prose. No hedging. No passive voice.
```

**Draft frontmatter:**
```yaml
---
title: "Why Adoption Curves Always Plateau"
type: draft
created: 2026-03-01
modified: 2026-03-01
content_status: draft
publishability: private
source_atoms:
  - "[[Adoption curves have a predictable plateau at ~40% active users]]"
tags: [type/draft]
---
```

### Anti-Patterns to Avoid

- **URL-only output:** The existing scan-slack.sh and scan-outlook.sh output URLs, not full content. The new intelligence scanners must capture message text and email bodies.
- **Missing routing tag:** Every note must include both `type:` (YAML field) AND `tags: [type/...]` (Obsidian tag). The ANM config uses tag-based routing (`#type/source/slack`), not pattern-based routing.
- **Full provenance on atoms:** Atoms backlink to source via `atom_of`. Do not copy `provenance.*` fields to atoms — two sources of truth that will diverge.
- **More than 3 theme connections:** Hard cap at 3 per THEME-03. The prompt must enforce this, not leave it to judgment.
- **Synthesis introducing new claims:** Every claim in a draft must trace to a cited atom. This is a prompt constraint, not a post-hoc check.
- **Overwriting existing state:** State file updates must be atomic — read → compute → write new content. Don't `echo "ts" >> state.json` (corrupts JSON).

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Semantic similarity for theme matching | Custom embedding comparison | grep on titles and tags | REQUIREMENTS.md explicitly defers embeddings; grep sufficient at current vault scale |
| HTML stripping from email bodies | Custom HTML parser | Python `html.parser` or Graph API `Prefer: text` header | Proven approaches; custom parser misses edge cases |
| Note routing logic | Custom folder router | ANM plugin (already configured) | ANM handles routing; skill just writes the note with correct frontmatter |
| Duplicate detection | Hash comparison | `seen_ids` set in state JSON | Simple ID-based deduplication; hashing adds complexity without benefit |
| Markdown generation | Custom template engine | f-string/heredoc in bash or Python | Frontmatter + body is simple enough for string interpolation |

---

## Common Pitfalls

### Pitfall 1: ANM Routing Requires Tags (Not YAML type Field)

**What goes wrong:** Scanner writes a note with `type: source/slack` in frontmatter but no `tags:` array. Note sits in `sources/` root (or vault root) and never routes to `sources/slack/`.

**Why it happens:** The Phase 14 ANM configuration uses **tag-based routing** — it matches `#type/source/slack` in the Obsidian tags array, not the `type:` YAML field. The pattern-based approach was researched in Phase 14 but the actual ANM config ended up using tags (verified: `Rule 0: folder=700 Model Citizen/sources/slack, tag=#type/source/slack, pattern=`).

**How to avoid:** Every note written by a scanner or skill MUST include `tags: [type/source/slack]` (or the appropriate type tag). This is the routing mechanism. The `type:` field is for Dataview queries only.

**Warning signs:** Notes appear in vault root instead of their target folder after creation.

### Pitfall 2: Slack MCP Parameter Names Are MEDIUM Confidence

**What goes wrong:** Subagent prompt uses wrong parameter names for Slack MCP tools (e.g., `channel_id` vs `channelId`). Tool call fails silently or with unhelpful error.

**Why it happens:** Slack MCP tool schema was not directly inspected during research — parameter names inferred from patterns.

**How to avoid:** Plan the Slack scanner with an explicit debugging Task 1: "Run a minimal Slack MCP tool call and inspect the response schema before writing the full subagent prompt." This is documented in STATE.md as a known concern.

**Warning signs:** `Tool not found` or parameter validation errors on first Slack MCP call.

### Pitfall 3: Email Body Is HTML

**What goes wrong:** Outlook scanner captures email body as raw HTML, including `<div>`, `<p>`, `<a href="...">` tags. Note body is unreadable in Obsidian.

**Why it happens:** Graph API returns `body.content` as HTML by default when emails are HTML-formatted.

**How to avoid:** Add `Prefer: outlook.body-content-type="text"` header to Graph API request. This converts HTML body to plain text before delivery. If the header doesn't work (some tenants restrict it), strip HTML with Python: `from html.parser import HTMLParser`.

**Warning signs:** Vault note body contains `<div>`, `<p>`, or `<style>` tags.

### Pitfall 4: Incremental State Race Condition

**What goes wrong:** Two scanner runs overlap. Both read the same `seen_ids`, both process the same messages, both write duplicate notes.

**Why it happens:** State file is read at start and written at end. If a second run starts before the first finishes writing, both see the same state.

**How to avoid:** For Phase 15 (individual skills, no automation), this is low risk — skills are run interactively. Phase 16 adds a `pipeline.lock` file for concurrent execution protection. Document this as a Phase 16 concern, not Phase 15.

### Pitfall 5: Atom Splitting Loses "Why It Matters" Context

**What goes wrong:** Splitting skill creates atoms with only the concept title and a single-sentence body. The "why it matters" context from the original Slack message or email is not preserved (violates ATOM-04).

**Why it happens:** Default LLM behavior is to extract and compress. Without explicit instruction, atoms become telegraphic.

**How to avoid:** Splitting prompt must explicitly require: "For each atom: (1) state the concept, (2) explain in 2-3 sentences why this matters in the context of the original source." Test with one real source note before shipping the skill.

### Pitfall 6: Synthesis Hallucination

**What goes wrong:** Synthesis draft introduces statistics, examples, or claims not present in the source atoms. Draft cites `[[atom]]` but the atom doesn't actually contain the claim.

**Why it happens:** LLMs generalize. Without strong guardrails, the synthesis prompt will produce plausible but unsupported claims.

**How to avoid:** Synthesis prompt must include: "Write ONLY from the atom content provided in this prompt. Do not add examples, statistics, or claims not present in the atoms. If you cannot support a paragraph with an atom citation, do not write that paragraph."

---

## Code Examples

### State File Format (shared pattern from goodlinks-state.json)

```json
{
  "last_scan_ts": 1709251200.0,
  "seen_ids": [
    "1708579200.000000",
    "1708500100.000000"
  ]
}
```

This is the established pattern from GoodLinks scanner. Slack scanner uses message `ts` as ID. Outlook scanner uses email `id` (GUID string from Graph API).

### Vault Note Writer (bash pattern)

```bash
VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen"
DATE=$(date +%Y-%m-%d)
FILENAME="Slack - ${DATE} - ${SANITIZED_TITLE}.md"
TARGET="${VAULT}/sources/slack/${FILENAME}"

cat > "$TARGET" << EOF
---
title: "${TITLE}"
type: source/slack
created: ${DATE}
content_status: raw
publishability: private
provenance:
  channel: ${CHANNEL}
  sender: ${SENDER}
  timestamp: "${TS}"
  thread_ts: "${THREAD_TS}"
  permalink: "${PERMALINK}"
  starred_reason: "${STARRED_REASON}"
tags: [type/source/slack]
---

${MESSAGE_TEXT}
EOF
```

**Note:** Write directly to `sources/slack/` (not vault root) since ANM triggers on save in Obsidian, not on filesystem write. Writing to the target folder directly is more reliable than relying on ANM to move the file.

### Graph API Request for Full Email Body (plain text)

```bash
ACCESS_TOKEN="..."
LAST_SCAN_ISO="2026-02-01T00:00:00Z"

curl -s -X GET \
  "https://graph.microsoft.com/v1.0/me/messages?\$select=id,subject,body,from,receivedDateTime&\$filter=receivedDateTime ge ${LAST_SCAN_ISO}&\$top=50&\$orderby=receivedDateTime desc" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Prefer: outlook.body-content-type=\"text\""
```

Response `body.content` will be plain text when the `Prefer` header is honored.

### Theme Matching grep Pattern

```bash
VAULT_ATOMS="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/atoms"
VAULT_THEMES="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/themes"

# Extract keywords from atom title
ATOM_TITLE=$(grep '^title:' "$ATOM_PATH" | sed 's/^title: //' | tr -d '"')
KEYWORDS=$(echo "$ATOM_TITLE" | tr ' ' '\n' | grep -E '.{5,}' | head -5)

# Find themes with title overlap
for kw in $KEYWORDS; do
  grep -li "$kw" "$VAULT_THEMES"/*.md 2>/dev/null
done | sort -u | head -3
```

---

## State of the Art

| Old Approach | Current Approach | Impact |
|--------------|------------------|--------|
| scan-slack.sh captures URLs only | Intelligence scanner captures full message text + provenance | Source notes become content-rich, not just link bookmarks |
| scan-outlook.sh captures URLs only | Intelligence scanner captures full email subject + body | Email content enters pipeline, not just links |
| Capture-web.sh creates web source notes | Scanners create source/slack and source/outlook notes per SCHEMA.md | Notes route correctly via ANM + queryable via Dataview |
| No splitting — all content stays in source notes | split-source skill decomposes into atoms | Single concepts become individually linkable and synthesizable |
| No theme graph | match-themes skill creates theme nodes | Vault builds a concept graph over time |
| No automated drafts | synthesize-draft produces citation-backed posts | Closes the loop from raw content to publishable output |

**Deprecated/not applicable:**
- `capture-web.sh`: Not used by intelligence scanners. Intelligence scanners write vault notes directly, bypassing the web capture pipeline.
- URL extraction pattern from existing scan-slack.sh and scan-outlook.sh: Replaced entirely. URL-only approach was Phase 10 design; Phase 15 design captures full message content.

---

## Open Questions

1. **Slack MCP tool parameter names**
   - What we know: Slack MCP is available in Claude Code. Tool names likely include `slack_get_starred_items`, `slack_get_channel_history`, etc.
   - What's unclear: Exact parameter names (e.g., `oldest` vs `oldest_ts`, `channel` vs `channel_id`)
   - Recommendation: Slack scanner plan's Task 1 = interactive debugging session to verify tool schema before writing subagent prompt. Document verified names in the plan.

2. **Write to target folder directly vs. vault root + ANM**
   - What we know: ANM routes notes when Obsidian detects a file change (save event). Filesystem writes may not trigger Obsidian's file watcher reliably.
   - What's unclear: Does iCloud sync trigger Obsidian's file watcher for files written from bash?
   - Recommendation: Write directly to the target folder (`sources/slack/`, `sources/outlook/`, `atoms/`, `themes/`, `drafts/`). Skip ANM for programmatically created notes. This is deterministic and doesn't depend on Obsidian being open.

3. **Synthesis voice placeholder scope**
   - What we know: ChatGPT Deep Research Voice & Style Guide is not available. Synthesis output will not match Athan's authentic voice.
   - What's unclear: Whether to build synthesis now (with placeholder) or defer.
   - Recommendation: Build synthesis now with a `TODO: Voice & Style Guide` placeholder. The structural pipeline (clustering, citation, draft format) is valuable even without voice. Voice injection is a prompt update, not a structural change.

4. **Splitting skill invocation model (manual vs. automated)**
   - What we know: Phase 15 builds standalone skills. Phase 16 wires them into scan-all.sh.
   - What's unclear: Whether splitting should run automatically after scanning (Phase 15) or only in Phase 16.
   - Recommendation: Phase 15 splitting skill = manual invocation only (`/split-source <path>`). Phase 16 adds auto-invocation in scan-all.sh. This keeps Phase 15 skills testable in isolation.

---

## Parallelization Map

All 5 plans can run in a single parallel wave. No inter-skill dependencies:

| Plan | Skill | Parallel? | Dependencies |
|------|-------|-----------|--------------|
| 15-01 | Slack scanner (intelligence) | Yes | Phase 14 schema, Slack MCP access |
| 15-02 | Outlook scanner (intelligence) | Yes | Phase 14 schema, Graph API credentials |
| 15-03 | Atomic splitting | Yes | Phase 14 schema (reads source notes) |
| 15-04 | Theme matching | Yes | Phase 14 schema (reads/writes atoms + themes) |
| 15-05 | Synthesis | Yes | Phase 14 schema (reads atoms, writes drafts) |

**Wave structure:** One wave, 5 plans. Plans can be executed sequentially or in parallel — no blocking dependencies between them during development. Integration testing (real content through full pipeline) is Phase 16.

---

## Sources

### Primary (HIGH confidence)
- Direct inspection of `model-citizen/scripts/scan-slack.sh` — confirmed URL-only output, Slack API approach, state file location
- Direct inspection of `model-citizen/scripts/scan-outlook.sh` — confirmed URL-only output, Graph API auth flow, client credentials
- Direct inspection of `model-citizen/vault/SCHEMA.md` — confirmed all frontmatter fields for all note types
- Direct inspection of ANM `data.json` — **confirmed tag-based routing** (not pattern-based): Rules 0-4 use `tag=#type/source/slack` etc.
- Direct inspection of `~/.model-citizen/goodlinks-state.json` — confirmed incremental state pattern (`last_scan_ts`, `seen_ids` array)
- Direct inspection of `.planning/phases/14-vault-schema/14-01-SUMMARY.md` — confirmed Phase 14 deliverables

### Secondary (MEDIUM confidence)
- Microsoft Graph API `Prefer: outlook.body-content-type="text"` header — documented behavior for plain text body retrieval; not tested against this specific tenant
- Slack MCP tool availability in Claude Code — confirmed by MCP configuration pattern; exact tool names MEDIUM confidence

### Tertiary (LOW confidence)
- Slack MCP exact parameter names (`oldest`, `channel_id`, etc.) — inferred from Slack API conventions; must verify in debugging session

---

## Metadata

**Confidence breakdown:**
- Slack scanner architecture: HIGH — existing script inspected; MCP approach is standard
- Slack MCP parameter names: LOW — must verify interactively
- Outlook scanner architecture: HIGH — existing script inspected; Graph API body retrieval is documented
- Splitting skill: HIGH — agentic pattern is straightforward; prompt design is the key variable
- Theme matching: HIGH — grep-based approach is simple and sufficient at current vault scale
- Synthesis: HIGH (structure) / LOW (voice) — structural approach is clear; voice requires Deep Research

**Research date:** 2026-03-01
**Valid until:** 2026-04-01 (Graph API and Slack API are stable; MCP tool names may change with server updates)
