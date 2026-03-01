# synthesize-draft

Cluster atoms by theme and generate a draft blog post with inline citations.

## Usage

```
/synthesize-draft "<theme-or-topic>"
```

Examples:
```
/synthesize-draft "User adoption psychology"
/synthesize-draft "product-market fit signals"
/synthesize-draft "data-driven product decisions"
```

## Your Task

You are a synthesis engine. Find all atoms related to the given theme or topic, read them, and generate a draft blog post that is fully grounded in the atom content.

# TODO: Voice & Style Guide
# ChatGPT Deep Research Voice & Style Guide is not yet available.
# When available, inject Athan's signature vocabulary and sentence patterns here.
# For now: write in clear, direct prose. No hedging. No passive voice. No "I helped..." constructions.
# Favor declarative sentences. State the claim, then support it with atom content.
# Do not use academic hedge words: "arguably", "it seems", "it appears", "one might say".

### Step 1: Find related atoms

**Vault atoms path:** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/atoms/`

Run two grep passes to find atoms related to the input theme or topic:

**Pass A — Wikilink match in Theme connections section:**
Search for atoms that reference the given theme in their `## Theme connections` section:
```bash
VAULT_ATOMS=~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/2B-new/700\ Model\ Citizen/atoms
THEME="$1"
grep -ril "\[\[$THEME" "$VAULT_ATOMS"/*.md 2>/dev/null | head -20
```

**Pass B — Title keyword match:**
Extract significant keywords from the theme/topic input (5+ character words):
```bash
KEYWORDS=$(echo "$THEME" | tr ' ' '\n' | grep -E '^.{5,}$' | head -5)
for kw in $KEYWORDS; do
  grep -li "$kw" "$VAULT_ATOMS"/*.md 2>/dev/null || true
done | sort | uniq -c | sort -rn | head -10
```

Merge and deduplicate results from both passes.

**Minimum atoms check:** If fewer than 2 atoms found after both passes:
```
Insufficient atoms for synthesis on topic: "{theme}"
Found: {N} atom(s)

Run /match-themes on more source atoms first to build the concept graph.
Synthesis requires at least 2 atoms to produce a coherent draft.
```
Stop — do not generate an uncited draft.

### Step 2: Read all matched atoms

Read each matched atom file. For each atom, capture:
- `title` (from frontmatter)
- `split_index` (for potential ordering reference)
- Full body content

Group atoms mentally by the concepts they contain. Identify 2-4 through-lines that could form the backbone of a blog post.

### Step 3: Generate the draft blog post

**CRITICAL SYNTH-03 CONSTRAINT — embed this as a hard rule:**

Write ONLY from the atom content loaded in Step 2. Do not add examples, statistics, or claims not present in the atoms. Every paragraph must be traceable to at least one cited atom wikilink. If you cannot support a paragraph with an atom citation, do not write that paragraph. Do not generalize beyond what the atoms state.

**Structure to follow:**

1. **Title** — derive from the theme + the strongest through-line across atoms. Should be specific enough to be meaningful, broad enough to cover all cited atoms. 8-12 words.

2. **Introduction paragraph** — frame the question or problem that this collection of atoms addresses. Ground it in what the atoms collectively say. Include at least one `[[atom-title]]` citation.

3. **Body paragraphs (2–4)** — each paragraph makes one claim, supported by cited atoms. Format:
   - State the claim clearly
   - Support with 1-2 specific details from the atoms
   - End with the implication or "so what"
   - Include `[[atom-title]]` inline citations where claims derive from atoms

4. **Closing paragraph** — synthesize the key takeaway from the atoms. What is the single most important thing the reader should remember? Ground it in atom content.

**Inline citation format:** Use `[[Atom Title As Written In Frontmatter]]` wherever a claim derives from an atom. Readers can follow the wikilink back to the atom and its source.

Example of a properly cited paragraph:
```
Product adoption rarely follows a linear growth curve. [[Adoption curves have a predictable plateau at approximately 40% active users]] — and this ceiling is not accidental. It reflects the structural difference between early adopters, who actively seek novelty, and mainstream users, who optimize for workflow continuity [[Early adopters and mainstream users have fundamentally different switching cost calculations]].
```

### Step 4: Build source_atoms list

After writing the draft, collect all atoms that were actually cited with `[[atom-title]]` wikilinks in the body.

List these as the `source_atoms` frontmatter array — only atoms cited in the body, not all atoms found in Step 1.

### Step 5: Write the draft note

**Vault drafts path:** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/drafts/`

**Generate filename:** `{sanitized-title}.md`
- Lowercase, spaces → hyphens, strip special chars, truncate at 60 chars

**Write with this EXACT frontmatter:**
```markdown
---
title: "{Blog post title}"
type: draft
created: {TODAY in YYYY-MM-DD}
modified: {TODAY in YYYY-MM-DD}
content_status: draft
publishability: private
source_atoms:
  - "[[{Atom title 1}]]"
  - "[[{Atom title 2}]]"
tags: [type/draft]
---

{Introduction paragraph}

{Body paragraphs with inline [[atom]] citations}

{Closing paragraph}
```

**CRITICAL CONSTRAINTS:**
- Write directly to `drafts/` folder — NOT to vault root
- Draft MUST have `tags: [type/draft]` for ANM routing
- `publishability` is ALWAYS `private` — the human approval gate requires manual promotion
- `content_status` is ALWAYS `draft` for newly created drafts
- `source_atoms` must list ONLY atoms actually cited in the body — not all matched atoms
- Write ONLY from atom content — do not introduce claims not in the atoms

### Step 6: Report results

```
Synthesis Complete
───────────────────
Topic: "{input theme}"
Draft title: "{generated title}"

Atoms synthesized: {N}
Draft written to: drafts/{filename}

Source atoms cited:
  • [[{atom-title-1}]]
  • [[{atom-title-2}]]

Note: publishability is set to private.
To publish: manually change publishability to public in the draft frontmatter
after review (SYNTH-04 approval gate).
```
