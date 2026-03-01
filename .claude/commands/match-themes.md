# match-themes

Find related vault content for a new atom and add wikilinks with written justifications.

## Usage

```
/match-themes <path-to-atom-note>
```

Example:
```
/match-themes ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/2B-new/700\ Model\ Citizen/atoms/adoption-curves-plateau-at-40-percent.md
```

## Your Task

You are a theme matcher. Read the target atom, find related vault content using grep-based search, and add at most 3 wikilinks with written justifications to the atom body.

**ABSOLUTE HARD CAP: Add at most 3 wikilinks. If you find 4 or more candidates, pick the 3 most relevant by keyword overlap count. Stop after 3 even if more seem relevant.**

### Step 1: Read the target atom

Read the file at the provided path. Extract:

1. **Title** — from `title:` in frontmatter
2. **Tags** — from `tags:` array in frontmatter
3. **Body text** — everything after the frontmatter block
4. **Current state** — check if a `## Theme connections` section already exists

If `## Theme connections` already exists with 3 or more entries, report "Atom already has 3 theme connections. Skipping." and stop.

### Step 2: Extract search keywords

From the atom title, extract keywords for grep matching:

```bash
# Get atom title and extract significant words (5+ characters)
ATOM_TITLE="<title from frontmatter>"
KEYWORDS=$(echo "$ATOM_TITLE" | tr ' ' '\n' | grep -E '^.{5,}$' | head -5)
```

Examples:
- Title: "Adoption curves have a predictable plateau at 40 percent"
- Keywords: adoption, curves, predictable, plateau, percent

### Step 3: Run grep-based candidate discovery

**Vault paths:**
- Atoms: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/atoms/`
- Themes: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/themes/`

Run three grep passes to discover candidates:

**Pass A — Title keywords vs themes/ folder:**
For each keyword, grep theme files case-insensitively:
```bash
VAULT_THEMES=~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/2B-new/700\ Model\ Citizen/themes
for kw in $KEYWORDS; do
  grep -li "$kw" "$VAULT_THEMES"/*.md 2>/dev/null || true
done | sort | uniq -c | sort -rn | head -5
```
Score each match by how many keywords overlap.

**Pass B — Tag overlap vs atoms/ folder:**
For each tag in the atom's frontmatter tags array:
```bash
VAULT_ATOMS=~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/2B-new/700\ Model\ Citizen/atoms
for tag in "${ATOM_TAGS[@]}"; do
  grep -l "$tag" "$VAULT_ATOMS"/*.md 2>/dev/null || true
done | grep -v "$(basename $ATOM_PATH)" | sort -u | head -10
```
These are atoms with overlapping tags — potential thematic siblings.

**Pass C — Title keywords vs atoms/ folder:**
```bash
for kw in $KEYWORDS; do
  grep -li "$kw" "$VAULT_ATOMS"/*.md 2>/dev/null || true
done | grep -v "$(basename $ATOM_PATH)" | sort | uniq -c | sort -rn | head -5
```

Merge all results. Deduplicate by filename.

### Step 4: Select at most 3 candidates

**Ranking priority:**
1. Theme files with highest keyword overlap count (prefer themes over atoms — themes aggregate)
2. Atom files with highest keyword overlap count
3. If tied, prefer theme files

**Hard selection rule:** Take the top 3 by score. Do not add a 4th even if it seems relevant. If fewer than 3 candidates found, that is fine — 0, 1, or 2 connections are valid results.

For each candidate, read its full content to understand the connection conceptually.

### Step 5: Write justifications and update atom

For each selected candidate (up to 3), write a one-sentence justification explaining WHY this atom connects to that theme or atom.

**Justification rules:**
- Must be specific to the content — not "this atom is related to this theme"
- Must explain the conceptual connection: what specifically overlaps?
- Good example: "This atom describes the plateau behavior that defines user adoption psychology as a domain"
- Bad example: "This atom is related to the adoption theme"

**Check for existing Theme connections section:**
If `## Theme connections` section exists in atom body, append to it.
If it does not exist, add it at the end of the atom body.

**Format to add/append:**
```markdown
## Theme connections

- [[Theme Or Atom Title]] — {one-sentence justification}
- [[Another Theme Title]] — {one-sentence justification}
```

Update the atom file by appending the `## Theme connections` section (or entries within it).

### Step 6: Update theme notes

For each connection that points to an existing theme note (Pass A candidates):

1. Read the theme note
2. Find the `## Related atoms` section. If absent, add it.
3. Check if `- [[Atom Title]]` is already in the section — if yes, skip.
4. If not present, add `- [[{atom title}]]` to the Related atoms list.
5. Write the updated theme file.

### Step 7: Create missing theme notes

For each connection where the target is a new theme (a concept inferred from keyword matching but no file exists in themes/):

**Only create a theme note if:**
- The concept is broad enough to aggregate 2+ atoms eventually (not hyper-specific)
- The keyword match was conceptually meaningful, not coincidental

**Create the theme note at:** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/themes/{sanitized-theme-title}.md`

```markdown
---
title: "{Theme title as noun phrase}"
type: theme
created: {TODAY in YYYY-MM-DD}
publishability: private
tags: [type/theme]
---

# {Theme title}

## Related atoms

- [[{atom title}]]
```

**CRITICAL:** Theme notes MUST have `tags: [type/theme]` for ANM routing.

### Step 8: Report results

Print a summary:
```
Theme Matching Complete
────────────────────────
Atom: {title}
Connections added: {N} (hard cap: 3)

Connections:
  1. [[{theme-or-atom-title}]] — {justification}
  2. [[{theme-or-atom-title}]] — {justification}

Theme notes updated: {list of updated theme files}
Theme notes created: {list of new theme files, if any}
No connections found: {if N=0, explain why}
```

If 0 candidates found after all grep passes:
```
No theme connections found for: {title}
This is a valid result — the atom may be early in the vault's concept graph.
Run again after more atoms exist in vault/atoms/.
```
