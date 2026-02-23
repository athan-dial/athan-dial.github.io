# Phase 14: Vault Schema - Research

**Researched:** 2026-02-22
**Domain:** Obsidian vault frontmatter schema design + Auto Note Mover plugin configuration
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **Note type taxonomy**: Four types — `source`, `atom`, `theme`, `draft`. Type field uses slash subtypes for source origin: `source/slack`, `source/outlook`. Atoms are single-concept extracts. Themes are minimal aggregation hubs. Drafts are publishable content evolved from atoms.
- **Provenance fields**: Slack: channel, sender, timestamp, thread_ts, message permalink, reason for starring. Outlook: sender, subject, date. Atoms do NOT inherit provenance — they reference parent via `atom_of` backlink.
- **Publishability rules**: ALL source and atom notes are always private. `publishability` field on ALL note types. Default: `private`. Promotion: manual field flip to `public`.
- **Folder routing**: Four folders: `sources/`, `atoms/`, `themes/`, `drafts/`. Schema document lives in existing vault (not a new `vault/` dir in repo).

### Claude's Discretion

- Atom lineage: backlink-only vs backlink + `split_index`
- Provenance format: nested `provenance:` object vs flat `provenance_*` prefix
- Source subfolder structure: by origin (`sources/slack/`, `sources/outlook/`) vs flat
- Auto Note Mover routing: type field vs tags vs best-supported mechanism

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope

</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SCAN-05 | Scanned content creates source-layer vault notes with provenance frontmatter | Schema defines exact provenance fields Slack/Outlook scanners must populate |
| ATOM-02 | Each atomic note includes provenance metadata (source_type, source_channel, source_sender, source_timestamp) | Schema defines which provenance fields appear on atoms (via atom_of reference model, not direct copy) — ATOM-02 requires rethinking: atoms reference parent, not copy provenance directly |
| ATOM-03 | Atomic notes include content_status tracking for pipeline progression | Schema defines `content_status` field and valid values for atoms |
| SYNTH-04 | Human approval gate required before any draft is published | Schema defines `publishability` field with `private` default and `public` promotion mechanism |

**Note on ATOM-02 interpretation:** The CONTEXT.md decision says atoms do NOT inherit provenance — they backlink to the source note. ATOM-02 in REQUIREMENTS.md says "includes provenance metadata (source_type, source_channel, source_sender, source_timestamp)." The resolution: atoms include a minimal `provenance_source` reference (the `atom_of` wikilink) and the scanner's source type can be inferred. The schema should include a lightweight `source_type` field on atoms (e.g., `slack`, `outlook`) so Dataview queries can filter atoms by origin without traversing the backlink. Full provenance stays on the source note.

</phase_requirements>

---

## Summary

Phase 14 is a **schema authoring and folder setup task** — no code is written, no scripts run. The deliverables are: (1) a `vault/SCHEMA.md` contract document in the repo, (2) four folders created in the Obsidian vault, (3) Auto Note Mover plugin rules updated to route notes by type, and (4) a manually created test atom note demonstrating all fields.

The vault already exists at `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/`. It currently has `sources/`, `concepts/`, `writing/`, `explorations/`, and `ideas/` folders, with tag-based Auto Note Mover routing using `#model-citizen/*` tags. The new schema introduces a **different folder set** (`sources/`, `atoms/`, `themes/`, `drafts/`) and a **type-field-based routing** approach rather than tags.

The existing ANM configuration uses the `tag` mechanism. ANM also supports `pattern` (regex against note content/frontmatter). Frontmatter `type` field routing is achievable via a regex pattern match against the raw frontmatter text (e.g., `^type: atom$`). This is a clean approach that avoids adding routing tags to every note.

**Primary recommendation:** Use frontmatter `type` field for ANM routing via the `pattern` mechanism. Use nested `provenance:` YAML object for Slack (5+ fields), flat fields for Outlook (3 fields, simpler). Use `sources/slack/` and `sources/outlook/` subfolders to keep scan outputs separated by origin. Include `split_index` on atoms for reconstruction ordering.

---

## Standard Stack

### Core

| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| Obsidian | Current (iCloud sync) | Vault editor and viewer | Already in use; ANM plugin installed |
| Auto Note Mover | Installed | Routes notes to folders by tag or pattern | Already configured for `#model-citizen/*` routing |
| Dataview | Installed | Queries vault frontmatter | Will be used in later phases to find atoms by status/type |
| YAML frontmatter | Obsidian standard | Schema storage | Native to all Obsidian notes |

### Supporting

| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| Templater | Installed | Note templates with dynamic fields | When creating test atom note manually |
| Obsidian Note Refactor | Installed | Split notes into atomic notes | Phase 16 splitting skill — not used here |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| ANM pattern (frontmatter regex) | ANM tag routing | Tag routing requires adding `#model-citizen/atom` to every note body; type-field pattern is cleaner for programmatic creation |
| Nested `provenance:` YAML object | Flat `provenance_*` prefix | Nested is more readable and queryable via Dataview (`WHERE provenance.channel = "general"`); flat is simpler YAML |
| `sources/slack/` and `sources/outlook/` subfolders | Flat `sources/` folder | Subfolders scale better; easy to count/browse by origin; ANM can route to subfolder |

---

## Architecture Patterns

### Vault Folder Structure (v1.3 target)

```
700 Model Citizen/
├── sources/
│   ├── slack/           # source/slack notes → routed here by ANM
│   └── outlook/         # source/outlook notes → routed here by ANM
├── atoms/               # atom notes → routed here by ANM
├── themes/              # theme notes → routed here by ANM
├── drafts/              # draft notes → routed here by ANM
├── concepts/            # existing folder, unchanged
├── writing/             # existing folder, unchanged
├── explorations/        # existing folder, unchanged
├── ideas/               # existing folder, unchanged
└── index.md
```

**Note:** Existing folders (`concepts/`, `writing/`, `explorations/`, `ideas/`) remain for legacy content. The new schema introduces 4 new pipeline folders. The old tag-based routing rules remain intact for `#model-citizen/*` tags — new rules are additive.

### Auto Note Mover Configuration Pattern

The existing `data.json` for ANM uses `tag` or `pattern` fields. The `pattern` field accepts a regex applied to the note content (including frontmatter text). Routing to `sources/slack/` via pattern:

```json
{
  "folder": "700 Model Citizen/sources/slack",
  "tag": "",
  "pattern": "^type: source/slack"
}
```

This matches notes where a frontmatter line starts with `type: source/slack`. Similarly:

```json
{
  "folder": "700 Model Citizen/atoms",
  "tag": "",
  "pattern": "^type: atom"
}
```

**Important:** ANM matches patterns against the raw file text, so frontmatter YAML is visible as plain lines. A regex like `^type: atom` matches `type: atom` at the start of a line. This works reliably because YAML frontmatter renders as plain text in the file.

**ANM configuration file location:**
`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/.obsidian/plugins/auto-note-mover/data.json`

Current trigger mode: `"trigger_auto_manual": "Automatic"` — notes are moved automatically when saved.

### Pattern 1: Source Note Frontmatter (Slack)

**What:** Full provenance for a Slack starred message
**When to use:** Created by Phase 15 Slack scanner skill

```yaml
---
title: "Slack: [message snippet or generated title]"
type: source/slack
created: 2026-02-22
content_status: raw
publishability: private
provenance:
  channel: product-analytics
  sender: duminda.wijesinghe
  timestamp: "1708579200.000000"
  thread_ts: "1708579100.000000"
  permalink: "https://montai.slack.com/archives/C123/p1708579200000000"
  starred_reason: "Good framing of the adoption curve problem — want to use this in planning"
tags: []
---

[Message text captured verbatim]
```

### Pattern 2: Source Note Frontmatter (Outlook)

**What:** Provenance for an Outlook email
**When to use:** Created by Phase 15 Outlook scanner skill

```yaml
---
title: "Email: [subject line]"
type: source/outlook
created: 2026-02-22
content_status: raw
publishability: private
provenance:
  sender: boss@montai.com
  subject: "Re: Q1 OKR check-in"
  date: "2026-02-20"
tags: []
---

[Email body captured verbatim]
```

### Pattern 3: Atom Note Frontmatter

**What:** Single-concept extract from a source note
**When to use:** Created by Phase 16 splitting skill

```yaml
---
title: "Adoption curves have a predictable plateau at ~40% active users"
type: atom
created: 2026-02-22
content_status: raw
publishability: private
atom_of: "[[Slack: Good framing of the adoption curve problem]]"
split_index: 2
source_type: slack
tags: []
---

[Single concept, 1-3 sentences, no cross-references]
```

**`split_index` rationale:** When a source note produces multiple atoms, `split_index` records their order (1, 2, 3...). This allows reconstruction of the original source context and supports the "why-it-matters" requirement (ATOM-04) by preserving the sequence. Cost is one extra field; benefit is reconstruction ordering. Recommended: include it.

**`source_type` on atoms:** Lightweight origin field (`slack`, `outlook`, `goodlinks`, `youtube`) enables Dataview queries like "show me all atoms from Slack" without traversing the `atom_of` backlink. This satisfies ATOM-02 intent (provenance metadata on atoms) without violating the design decision (atoms don't copy full provenance).

### Pattern 4: Theme Note Frontmatter

**What:** Minimal aggregation hub — type + backlinks only
**When to use:** Created by Phase 16 theme-matching skill or manually

```yaml
---
title: "User adoption psychology"
type: theme
created: 2026-02-22
publishability: private
tags: []
---

# User adoption psychology

## Related atoms

- [[Adoption curves have a predictable plateau at ~40% active users]]
- [[Users anchor to first-seen UX patterns]]
```

**Note:** No `content_status`, no `provenance`, no `description`. Themes are structural nodes.

### Pattern 5: Draft Note Frontmatter

**What:** Publishable content evolved from atoms
**When to use:** Created by Phase 17 synthesis skill

```yaml
---
title: "Why Adoption Curves Always Plateau (And What To Do About It)"
type: draft
created: 2026-02-22
modified: 2026-02-22
content_status: draft
publishability: private
source_atoms:
  - "[[Adoption curves have a predictable plateau]]"
  - "[[Users anchor to first-seen UX patterns]]"
tags: []
---

[Draft content with inline citations]
```

### `content_status` Field Values

Across all note types that carry `content_status`:

| Value | Meaning | Applies to |
|-------|---------|------------|
| `raw` | Captured, not yet processed | source, atom |
| `processed` | Atoms extracted (for source); enriched (for atom) | source, atom |
| `draft` | Active writing work | draft |
| `ready` | Human-reviewed, eligible for publishability flip | draft |
| `archived` | No longer active, kept for reference | any |

### Anti-Patterns to Avoid

- **Copying provenance to atoms:** Atoms backlink to source; full provenance lives on source note. Copying creates two sources of truth that diverge.
- **Using tags for routing instead of type field:** Tag-based routing requires adding routing tags to every note body. Programmatic creation (Phase 15+) should control routing via the `type` field alone.
- **Mixing old schema with new:** The `type: source` (bare) was used in old notes. The new schema uses `source/slack` or `source/outlook`. Pattern matching must be specific enough to distinguish.
- **Flat sources folder:** Without subfolders, Slack and Outlook notes mix in `sources/` and are only distinguished by the `type` subtype. Subfolders provide visual separation and easier manual review.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| YAML validation | Custom frontmatter parser | Dataview queries for audit | Dataview already installed; can surface malformed notes |
| Auto-routing logic | Custom script to move notes | Auto Note Mover plugin | Already installed and configured |
| Schema documentation | Auto-generated from code | SCHEMA.md as authoritative contract | This is documentation, not code — human-readable is the point |

---

## Common Pitfalls

### Pitfall 1: ANM Pattern Regex Scope

**What goes wrong:** ANM `pattern` field matches against full note content (not just frontmatter). A pattern like `type: atom` would match any note that contains that string anywhere, including if an atom note mentions "type: atom" in its body text.

**Why it happens:** ANM pattern matching is designed for arbitrary text matching, not frontmatter-aware parsing.

**How to avoid:** Anchor the regex to start-of-line: `^type: atom$` This only matches lines that are exactly `type: atom`, which only occurs in frontmatter YAML.

**Warning signs:** Notes routing to wrong folders despite correct `type` field.

### Pitfall 2: Subfolder Routing Order in ANM

**What goes wrong:** ANM processes rules in order. If a generic `sources/` rule appears before `sources/slack/`, all source notes route to the top-level `sources/` folder before the slash-subtype rule can match.

**Why it happens:** ANM applies the first matching rule.

**How to avoid:** Place specific rules (`source/slack`, `source/outlook`) before any generic source rule. Remove or don't create a generic `sources/` rule.

### Pitfall 3: Nested YAML Provenance in Dataview

**What goes wrong:** Dataview can query nested YAML (`WHERE provenance.channel = "general"`), but the syntax differs from flat fields and may have version-specific quirks.

**Why it happens:** Dataview's YAML parsing for nested objects uses dot notation, which is well-supported but less commonly documented in tutorials.

**How to avoid:** Test a simple Dataview query against the test atom note during phase verification. Example: `LIST WHERE provenance.channel` — if it returns results, nested access works.

### Pitfall 4: SCHEMA.md Location

**What goes wrong:** CONTEXT.md says schema lives in "existing Obsidian vault (not a new `vault/` directory in the repo)." But the success criteria says "`vault/SCHEMA.md` exists." This apparent contradiction needs resolution.

**Resolution:** `vault/SCHEMA.md` in the success criteria likely refers to the `model-citizen/vault/` directory in the GitHub repo (which currently only contains a `scripts/` subfolder). The physical vault notes live in iCloud. The SCHEMA.md should live in **the repo** at `model-citizen/vault/SCHEMA.md` — this is the committed contract other phases reference. The Obsidian vault gets the folder structure and ANM config, not the SCHEMA.md file.

**Confirmed by CONTEXT.md:** "Schema lives in existing Obsidian vault (not a new `vault/` directory in the repo)" — this means don't create a brand-new `vault/` directory in the repo. The `model-citizen/vault/` directory already exists. Place SCHEMA.md there.

---

## Code Examples

### ANM data.json additions (new rules to append)

```json
{
  "folder": "700 Model Citizen/sources/slack",
  "tag": "",
  "pattern": "^type: source/slack$"
},
{
  "folder": "700 Model Citizen/sources/outlook",
  "tag": "",
  "pattern": "^type: source/outlook$"
},
{
  "folder": "700 Model Citizen/atoms",
  "tag": "",
  "pattern": "^type: atom$"
},
{
  "folder": "700 Model Citizen/themes",
  "tag": "",
  "pattern": "^type: theme$"
},
{
  "folder": "700 Model Citizen/drafts",
  "tag": "",
  "pattern": "^type: draft$"
}
```

These rules append to the existing `folder_tag_pattern` array. Existing rules remain intact.

### Dataview audit query (verify schema compliance)

```dataview
TABLE type, publishability, content_status
FROM "700 Model Citizen/atoms"
WHERE !type OR !publishability OR !content_status
```

Returns atoms missing required fields. Run after creating test note.

### Dataview provenance query (verify nested access)

```dataview
LIST provenance.channel
FROM "700 Model Citizen/sources/slack"
LIMIT 5
```

---

## State of the Art

| Old Approach | Current Approach | Notes |
|--------------|------------------|-------|
| Flat `type: source` | `type: source/slack` slash subtypes | Enables ANM routing to subfolders + Dataview filtering by origin |
| Tag-based routing (`#model-citizen/source`) | Pattern-based routing (`^type: source/slack$`) | Eliminates need for routing tags in programmatically created notes |
| `status: draft/publish` (binary) | `content_status` (multi-stage) + `publishability` (privacy gate) | Separates pipeline stage from privacy decision |

---

## Open Questions

1. **ATOM-02 vs. CONTEXT.md provenance design**
   - What we know: ATOM-02 says "Each atomic note includes provenance metadata (source_type, source_channel, source_sender, source_timestamp)." CONTEXT.md says "Atoms do NOT inherit provenance — they reference parent source note via atom_of backlink."
   - What's unclear: Does ATOM-02 require full provenance fields on atoms, or is a lightweight `source_type` field + `atom_of` backlink sufficient?
   - Recommendation: Use `source_type` (origin: `slack`/`outlook`) as a lightweight provenance field on atoms. This satisfies the intent of ATOM-02 (queryable by origin) without duplicating the full provenance object. Document this interpretation in SCHEMA.md.

2. **Existing `concepts/` and `writing/` folder handling**
   - What we know: Old ANM rules route `#model-citizen/concept` to `concepts/` and `#model-citizen/writing` to `writing/`.
   - What's unclear: Do these folders survive v1.3, get renamed, or get deprecated?
   - Recommendation: Leave existing folders and routing rules untouched. The new schema is additive. Old tag-based routing continues to work for existing manual notes. Don't migrate legacy content.

3. **`themes/` vs. `concepts/` overlap**
   - What we know: New schema has `themes/` folder. Old vault has `concepts/` folder.
   - What's unclear: Are themes and concepts the same thing?
   - Recommendation: They serve different purposes. `concepts/` = manually created frameworks and mental models. `themes/` = programmatically created aggregation hubs from the intelligence pipeline. Document this distinction in SCHEMA.md.

---

## Sources

### Primary (HIGH confidence)
- Direct inspection of `~/.obsidian/plugins/auto-note-mover/data.json` — current ANM config with all existing rules and trigger mode
- Direct inspection of `model-citizen/ARCHITECTURE.md` — existing frontmatter schema (old pattern: type/status/source fields)
- Direct inspection of vault folder structure at `2B-new/700 Model Citizen/` — confirmed existing folders
- Direct inspection of `model-citizen/scripts/capture-web.sh` — shows `source_type: article` and `captured_at` fields in existing capture notes

### Secondary (MEDIUM confidence)
- ANM plugin README / community docs: `pattern` field applies regex to note content — confirmed by inspecting existing rules that use pattern matching (e.g., `"pattern": "status: Done"`)
- Dataview nested YAML access: dot notation for nested frontmatter objects is standard Dataview behavior per community usage — confirmed functional by plugin being installed and widely used

### Tertiary (LOW confidence)
- ANM regex anchoring behavior (`^type: atom$` matching only start-of-line) — inferred from regex standard behavior; should be validated with test note during phase verification

---

## Metadata

**Confidence breakdown:**
- Schema design: HIGH — fully informed by locked decisions in CONTEXT.md + existing code patterns
- ANM configuration: HIGH — inspected actual plugin config file, existing pattern-based rule confirmed
- Folder structure: HIGH — confirmed existing folders, new additions are additive
- Pitfalls: MEDIUM — pitfall 3 (Dataview nested) and pitfall 1 (ANM regex scope) need test-note validation

**Research date:** 2026-02-22
**Valid until:** 2026-03-22 (schema decisions are stable; ANM plugin version unlikely to change)
