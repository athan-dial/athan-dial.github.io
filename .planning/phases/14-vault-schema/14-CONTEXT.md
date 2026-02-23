# Phase 14: Vault Schema - Context

**Gathered:** 2026-02-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Define and commit a frontmatter schema contract for the Obsidian vault that every component in the content intelligence pipeline reads and respects. Includes note type definitions, provenance metadata, publishability rules, and folder routing via Auto Note Mover. The vault already exists — this phase documents the contract and sets up folder structure + routing config.

</domain>

<decisions>
## Implementation Decisions

### Note type taxonomy
- Four note types: `source`, `atom`, `theme`, `draft`
- Type field uses slash subtypes for source origin: `source/slack`, `source/outlook`
- Atoms are single-concept extracts from source notes
- Themes are minimal aggregation hubs (type + backlinks to atoms, no description or confidence fields)
- Drafts are publishable content evolved from atoms

### Atom lineage
- Claude's Discretion: decide whether atoms use `atom_of` backlink only or include `split_index` for reconstruction ordering

### Provenance fields
- Slack provenance: channel, sender, timestamp, thread_ts, message permalink, reason for starring (full context)
- Outlook provenance: sender, subject, date (basic identification)
- Atoms do NOT inherit provenance — they reference parent source note via `atom_of` backlink; follow the link for provenance
- Claude's Discretion: nested `provenance:` object vs flat `provenance_*` prefix — pick what works best with Obsidian/Dataview

### Publishability rules
- ALL source and atom notes are **always private** — Slack and Outlook content never defaults to public, no exceptions
- `publishability` field exists on ALL note types (source, atom, theme, draft) for consistent queryability
- Default value: `private` for all note types
- Promotion mechanism: manual field flip — user edits `publishability: public` in frontmatter

### Folder routing
- Four top-level folders: `sources/`, `atoms/`, `themes/`, `drafts/`
- Claude's Discretion: whether `sources/` has subfolders by origin (`sources/slack/`, `sources/outlook/`) or stays flat — pick what scales better with Auto Note Mover
- Claude's Discretion: Auto Note Mover routing mechanism — frontmatter `type` field vs tags vs whatever ANM supports best
- Schema lives in existing Obsidian vault (not a new `vault/` directory in the repo)

### Claude's Discretion
- Atom lineage detail (backlink only vs backlink + split_index)
- Provenance field format (nested vs flat prefix)
- Source subfolder structure (by origin vs flat)
- Auto Note Mover routing mechanism (type field vs tags)

</decisions>

<specifics>
## Specific Ideas

- Slack provenance should capture "reason for starring" — why the user saved the message, not just that they did
- Schema must produce a `vault/SCHEMA.md` document that serves as the contract other phases reference
- Test atom note should demonstrate all required fields working together

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 14-vault-schema*
*Context gathered: 2026-02-22*
