# Vault Schema — Content Intelligence Pipeline

**Version:** 1.0
**Created:** 2026-02-23
**Applies to:** 700 Model Citizen vault (v1.3+)

This document is the authoritative frontmatter contract for all notes in the content intelligence pipeline. Every scanner (Phase 15), splitter (Phase 16), and synthesis skill (Phase 17) reads and respects this schema.

---

## Note Types

The pipeline has four note types, distinguished by the `type` field in frontmatter:

| Type | Folder | Purpose |
|------|--------|---------|
| `source/slack` | `sources/slack/` | Slack starred messages captured verbatim |
| `source/outlook` | `sources/outlook/` | Outlook emails captured verbatim |
| `atom` | `atoms/` | Single-concept extracts from source notes |
| `theme` | `themes/` | Structural aggregation hubs linking related atoms |
| `draft` | `drafts/` | Publishable content evolved from atoms |

Routing to folders is automatic via Auto Note Mover (ANM) tag matching. Notes require a routing tag (e.g., `#type/atom`) in addition to the `type:` frontmatter field — ANM matches Obsidian tags, not YAML key-value pairs.

---

## Source Notes

Source notes capture raw content verbatim. They are **always private** — Slack and Outlook content is never published.

### type: source/slack

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
tags: [type/source/slack]
---

[Message text captured verbatim]
```

**Fields:**

| Field | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `title` | string | yes | — | Format: "Slack: [snippet]" |
| `type` | string | yes | — | Always `source/slack` |
| `created` | date | yes | — | ISO 8601 (YYYY-MM-DD) |
| `content_status` | string | yes | `raw` | See content_status values |
| `publishability` | string | yes | `private` | Always `private` — no exceptions |
| `provenance.channel` | string | yes | — | Slack channel name |
| `provenance.sender` | string | yes | — | Slack username or display name |
| `provenance.timestamp` | string | yes | — | Slack message timestamp (epoch string) |
| `provenance.thread_ts` | string | no | — | Thread root timestamp if threaded |
| `provenance.permalink` | string | yes | — | Full Slack permalink URL |
| `provenance.starred_reason` | string | yes | — | Why the message was starred (intent capture) |
| `tags` | array | yes | `[type/source/slack]` | Must include routing tag `type/source/slack`; add topic tags manually |

### type: source/outlook

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
tags: [type/source/outlook]
---

[Email body captured verbatim]
```

**Fields:**

| Field | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `title` | string | yes | — | Format: "Email: [subject]" |
| `type` | string | yes | — | Always `source/outlook` |
| `created` | date | yes | — | ISO 8601 (YYYY-MM-DD) |
| `content_status` | string | yes | `raw` | See content_status values |
| `publishability` | string | yes | `private` | Always `private` — no exceptions |
| `provenance.sender` | string | yes | — | Sender email address |
| `provenance.subject` | string | yes | — | Original subject line |
| `provenance.date` | string | yes | — | Email date (YYYY-MM-DD) |
| `tags` | array | yes | `[type/source/outlook]` | Must include routing tag `type/source/outlook`; add topic tags manually |

**Note on provenance format:** Slack uses a nested `provenance:` YAML object (5+ fields) for readability and Dataview queryability (`WHERE provenance.channel = "general"`). Outlook uses the same nested format with 3 fields for consistency.

---

## Atom Notes

Atoms are single-concept extracts from source notes. Each atom contains one idea that stands alone.

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
tags: [type/atom]
---

[Single concept, 1-3 sentences, no cross-references]
```

**Fields:**

| Field | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `title` | string | yes | — | The concept stated as a declarative sentence |
| `type` | string | yes | — | Always `atom` |
| `created` | date | yes | — | ISO 8601 (YYYY-MM-DD) |
| `content_status` | string | yes | `raw` | See content_status values |
| `publishability` | string | yes | `private` | Default private; can be flipped manually |
| `atom_of` | wikilink | yes | — | Parent source note (backlink for provenance) |
| `split_index` | integer | yes | — | Position in split sequence (1-based). Enables reconstruction ordering of atoms from the same source |
| `source_type` | string | yes | — | Origin: `slack`, `outlook`, `goodlinks`, `youtube`. Lightweight provenance for Dataview queries without traversing the backlink |
| `tags` | array | yes | `[type/atom]` | Must include routing tag `type/atom`; add topic tags manually |

**Provenance design:** Atoms do NOT copy the full provenance object from the source note. They carry `atom_of` (wikilink to parent) and `source_type` (origin label). Full provenance (channel, sender, timestamp, permalink) lives on the source note — follow the backlink to retrieve it. This avoids two sources of truth that diverge.

**ATOM-02 resolution:** `source_type` satisfies the intent of ATOM-02 (provenance metadata on atoms) by enabling origin-based Dataview queries (`FROM "atoms" WHERE source_type = "slack"`) without duplicating the full provenance object.

---

## Theme Notes

Themes are minimal structural aggregation hubs. They group related atoms but carry no description, confidence, or content_status — they are structural nodes, not content.

```yaml
---
title: "User adoption psychology"
type: theme
created: 2026-02-22
publishability: private
tags: [type/theme]
---

# User adoption psychology

## Related atoms

- [[Adoption curves have a predictable plateau at ~40% active users]]
- [[Users anchor to first-seen UX patterns]]
```

**Fields:**

| Field | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `title` | string | yes | — | Theme label (noun phrase) |
| `type` | string | yes | — | Always `theme` |
| `created` | date | yes | — | ISO 8601 (YYYY-MM-DD) |
| `publishability` | string | yes | `private` | Default private; flip manually |
| `tags` | array | yes | `[type/theme]` | Must include routing tag `type/theme`; add topic tags manually |

**Note:** Themes deliberately omit `content_status` and `provenance` — they are structural aggregation hubs, not pipeline content. The "## Related atoms" section in the body contains wikilinks to constituent atoms.

**Concepts vs. Themes distinction:** `concepts/` folder = manually created frameworks, mental models, reference material. `themes/` folder = programmatically created aggregation hubs from the intelligence pipeline. These serve different purposes and should not be merged.

---

## Draft Notes

Drafts are publishable content evolved from atoms. They represent the synthesis phase output (Phase 17).

```yaml
---
title: "Why Adoption Curves Always Plateau (And What To Do About It)"
type: draft
created: 2026-02-22
modified: 2026-02-22
content_status: draft
publishability: private
source_atoms:
  - "[[Adoption curves have a predictable plateau at ~40% active users]]"
  - "[[Users anchor to first-seen UX patterns]]"
tags: [type/draft]
---

[Draft content with inline citations]
```

**Fields:**

| Field | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `title` | string | yes | — | Publication-ready title |
| `type` | string | yes | — | Always `draft` |
| `created` | date | yes | — | ISO 8601 (YYYY-MM-DD) |
| `modified` | date | yes | — | Updated on each revision |
| `content_status` | string | yes | `draft` | See content_status values |
| `publishability` | string | yes | `private` | **Human approval gate** — must be manually flipped to `public` (SYNTH-04) |
| `source_atoms` | array | yes | `[]` | Wikilinks to source atoms used in this draft |
| `tags` | array | yes | `[type/draft]` | Must include routing tag `type/draft`; add topic tags manually |

---

## content_status Values

`content_status` tracks pipeline progression. Not all note types use this field.

| Value | Meaning | Applies to |
|-------|---------|------------|
| `raw` | Captured, not yet processed | source, atom |
| `processed` | Atoms extracted (source); enriched/linked (atom) | source, atom |
| `draft` | Active writing work in progress | draft |
| `ready` | Human-reviewed, eligible for publishability flip to `public` | draft |
| `archived` | No longer active, kept for reference | any |

**Pipeline flow:** `raw` → `processed` → `draft` → `ready` → `archived`

---

## publishability Rules

`publishability` controls the privacy gate across all note types.

| Default | `private` for ALL note types |
|---------|------------------------------|
| Promotion | Manual edit of `publishability: public` in frontmatter |
| Source notes | **Always `private`** — Slack and Outlook content is never published, no exceptions |
| Atom notes | **Default `private`** — can be promoted manually if the concept is shareable |
| Theme notes | **Default `private`** — can be promoted if the aggregation is shareable |
| Draft notes | **Default `private`** — requires `content_status: ready` before promotion (SYNTH-04 approval gate) |

**SYNTH-04 compliance:** No draft is published without a human manually flipping `publishability: private` to `publishability: public`. This is the approval gate — there is no automatic promotion.

---

## Folder Routing

Notes are routed to folders automatically by Auto Note Mover (ANM) using **Obsidian tag matching**. ANM matches the `tag` field in its rules against `#hashtag` style tags in note frontmatter — it does not read YAML key-value pairs like `type: atom`.

Each note type requires a dedicated routing tag in its `tags:` array:

| Folder | Routing tag | Note type |
|--------|-------------|-----------|
| `sources/slack/` | `#type/source/slack` | source/slack notes |
| `sources/outlook/` | `#type/source/outlook` | source/outlook notes |
| `atoms/` | `#type/atom` | atom notes |
| `themes/` | `#type/theme` | theme notes |
| `drafts/` | `#type/draft` | draft notes |

**Dual-field pattern:** `type: atom` (frontmatter YAML field) enables Dataview queries. `tags: [type/atom]` (Obsidian tag) enables ANM routing. Both are required.

**ANM configuration:** Rules are prepended to the `folder_tag_pattern` array at positions 0–4 so specific source sub-type rules match before any generic `#model-citizen/source` rule.

**Existing folders unchanged:** `concepts/`, `writing/`, `explorations/`, `ideas/` remain with their existing tag-based routing rules. The new pipeline folders are additive.

---

## Dataview Audit Queries

### Atoms missing required fields

```dataview
TABLE type, publishability, content_status, source_type
FROM "700 Model Citizen/atoms"
WHERE !type OR !publishability OR !content_status OR !source_type
```

### All atoms by origin

```dataview
TABLE title, source_type, content_status, created
FROM "700 Model Citizen/atoms"
SORT created DESC
```

### Drafts ready for publication review

```dataview
TABLE title, content_status, modified
FROM "700 Model Citizen/drafts"
WHERE content_status = "ready"
SORT modified DESC
```

### Source provenance query (nested YAML access)

```dataview
LIST provenance.channel
FROM "700 Model Citizen/sources/slack"
LIMIT 10
```

---

*Schema version: 1.0*
*Last updated: 2026-02-23*
*Next phases: 15 (Scanners), 16 (Intelligence Skills), 17 (Synthesis)*
