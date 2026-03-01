# split-source

Decompose a vault source note into single-concept atom notes in the Model Citizen intelligence pipeline.

## Usage

```
/split-source <path-to-source-note>
```

Example:
```
/split-source ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/2B-new/700\ Model\ Citizen/sources/slack/Slack\ -\ 2026-03-01\ -\ Adoption-curve-framing.md
```

## Your Task

You are an atomic splitter. Read the source note, identify every distinct concept it contains, and write one atom note per concept to the vault's `atoms/` folder.

### Step 1: Read the source note

Read the file at the provided path. Extract:

1. **Title** — from the `title:` field in YAML frontmatter
2. **Source type** — derive from the `type:` field:
   - `source/slack` → `source_type: slack`
   - `source/outlook` → `source_type: outlook`
   - `source/goodlinks` → `source_type: goodlinks`
   - `source/youtube` → `source_type: youtube`
3. **Body text** — everything after the closing `---` of the frontmatter block

If the source note has `content_status: processed`, report "Note already processed. Skipping." and stop.

### Step 2: Identify distinct concepts

Read the body text and identify every distinct concept, claim, insight, or observation.

**A distinct concept is:**
- A single claim that can stand alone as a declarative sentence
- Independently meaningful without the other concepts in the source
- Expressible in 10-15 words as a declarative statement

**NOT a distinct concept:**
- Two ideas combined: "Adoption curves plateau AND users resist new UI patterns" → split into 2 atoms
- A process step that requires the previous step to make sense → this is still one concept, just keep it self-contained
- Background context that merely supports a concept → do NOT create an atom for pure background

**Rule of thumb:** If you can remove it from the source note and the remaining concepts still make complete sense on their own, it is a distinct concept.

Number each concept sequentially (1, 2, 3...). There is no minimum or maximum — if the source has 1 concept, write 1 atom. If it has 8, write 8.

### Step 3: Write atom notes

For each concept (assigned `split_index` starting at 1):

**Write a title** — a declarative sentence stating the concept. 10–15 words, present tense, no hedging.
Example: "Adoption curves have a predictable plateau at approximately 40% active users"

**Write the atom body** — 2 to 3 sentences:

```
CRITICAL — ATOM-04 constraint:
For each atom: write a title as a declarative sentence. Then write 2–3 sentences:
  - Sentence 1: Restate the concept with any necessary context from the source
  - Sentences 2–3: Explain why this matters in the context of the original source material

Do NOT write atoms as telegraphic bullet points.
Do NOT strip the "why it matters" context from the atom.
Do NOT write only the fact — always include why it matters for the source's domain.
```

Example of a BAD atom body:
```
Adoption curves plateau at 40%.
```

Example of a GOOD atom body:
```
Product adoption rarely progresses beyond 40% of the target user base without active behavioral intervention.
This plateau appears because early adopters' usage patterns rarely transfer to mainstream users, who have different workflows and higher switching costs.
Understanding this ceiling is critical for setting realistic activation targets — assuming 70% adoption as a goal produces resource allocation errors that compound over time.
```

**Generate the atom filename:** `{sanitized-title-slug}.md`
- Lowercase
- Spaces → hyphens
- Remove special chars (keep alphanumeric and hyphens)
- Truncate at 60 characters

**Vault atoms folder:** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/atoms/`

**Write each atom with this EXACT frontmatter:**
```markdown
---
title: "{concept as declarative sentence}"
type: atom
created: {TODAY in YYYY-MM-DD}
content_status: raw
publishability: private
atom_of: "[[{source note title}]]"
split_index: {1-based integer}
source_type: {slack|outlook|goodlinks|youtube}
tags: [type/atom]
---

{Concept restated with context. Sentence 1.}

{Why this matters in the context of the original source. Sentences 2-3.}
```

**CRITICAL CONSTRAINTS:**
- Every atom MUST have `tags: [type/atom]` — this is the ANM routing tag for the atoms/ folder
- `atom_of` MUST be a wikilink to the parent source note title: `[[Title of source note]]`
- `publishability` is ALWAYS `private` for all atoms — never auto-publish
- `content_status` is ALWAYS `raw` for newly created atoms
- `split_index` must be sequential starting from 1 — used for reconstruction ordering
- DO NOT copy `provenance` fields from source note to atom — the wikilink in `atom_of` is sufficient provenance
- DO NOT combine two concepts into one atom — if in doubt, split further
- Write to `atoms/` directly, NOT to vault root
- Use today's date (the current date when the command runs)

### Step 4: Mark source note as processed

After writing all atoms, update the source note's `content_status` field:

Change:
```yaml
content_status: raw
```

To:
```yaml
content_status: processed
```

Use the Read tool to get current content, then use the Edit tool to replace `content_status: raw` with `content_status: processed` in the frontmatter. If multiple lines match, only change the one inside the frontmatter block (between the first `---` and second `---`).

### Step 5: Report results

Print a summary:
```
Atomic Split Complete
──────────────────────
Source note: {title}
Atoms created: {N}

Atoms:
  1. {atom-filename-1} — "{atom-title-1}"
  2. {atom-filename-2} — "{atom-title-2}"
  ...

Source note marked: content_status → processed
```

If the note was already marked `content_status: processed`, report:
```
Skipped: {title} (already processed)
```
