# content-strategist

Interactive co-creation session for Model Citizen content pipeline.

Guides you through: selecting unmatched atoms → matching themes → synthesizing a draft post.

## Vault Configuration

```
VAULT_DIR: ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen
ATOMS_DIR: $VAULT_DIR/atoms
THEMES_DIR: $VAULT_DIR/themes
DRAFTS_DIR: $VAULT_DIR/drafts
LOCK_DIR: ~/.model-citizen/pipeline.lock
```

## Step 1: Check Pipeline Lock

Before doing anything, check whether the daily scan has acquired the pipeline lock:

```bash
LOCK_DIR="$HOME/.model-citizen/pipeline.lock"
if [[ -d "$LOCK_DIR" ]]; then
  LOCK_AGE=$(( $(date +%s) - $(stat -f %m "$LOCK_DIR" 2>/dev/null || echo "0") ))
  echo "⚠ pipeline.lock is active (${LOCK_AGE}s old)."
  echo "The daily scan-all.sh is running and writing to the vault."
  echo "Wait for it to complete (check ~/.model-citizen/daily-scan.log), then retry."
  exit 1
fi
```

If no pipeline.lock exists, acquire it for this interactive session:

```bash
mkdir "$LOCK_DIR" 2>/dev/null
trap 'rm -rf "$LOCK_DIR"' EXIT INT TERM
```

Inform the user: "Pipeline lock acquired for this session. The daily scan will defer its intelligence run until you exit."

## Step 2: Surface Cluster Proposals

Find all atom notes that have NOT been theme-matched yet (missing "## Theme connections" section):

```bash
ATOMS_DIR="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/atoms"
grep -rL "## Theme connections" "$ATOMS_DIR"/*.md 2>/dev/null
```

For each unmatched atom, read its frontmatter to extract:
- `source_type:` field (e.g., source/slack, source/outlook)
- `created:` field (date)
- `title:` field

Group the unmatched atoms by source_type and present a numbered list, for example:

```
Unmatched atoms available for development:

1. [source/slack] 2026-02-28 — "Metric theater in product reviews" (atoms/2026-02-28-metric-theater.md)
2. [source/slack] 2026-02-27 — "Adoption curve framing" (atoms/2026-02-27-adoption-curve.md)
3. [source/outlook] 2026-02-26 — "Decision velocity vs accuracy tradeoff" (atoms/2026-02-26-decision-velocity.md)

Enter a number to develop that atom, 'all' to develop all unmatched atoms, or 'q' to quit:
```

If there are no unmatched atoms, print:
"No unmatched atoms found. All existing atoms have been theme-matched. Run /split-source on a new source note to create atoms, then return here."
Then exit cleanly (release pipeline.lock via EXIT trap).

## Step 3: Match Themes for Selected Atom(s)

After the user selects a number (or 'all'):

1. Read the selected atom file(s).
2. For each selected atom, run the following theme-matching logic (same as match-themes.md):

   **Extract keywords from atom title:**
   ```bash
   KEYWORDS=$(echo "$ATOM_TITLE" | tr ' ' '\n' | grep -E '^.{5,}$' | head -5)
   ```

   **Pass A — Title keywords vs themes/ folder:**
   ```bash
   VAULT_THEMES="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/themes"
   for kw in $KEYWORDS; do
     grep -li "$kw" "$VAULT_THEMES"/*.md 2>/dev/null || true
   done | sort | uniq -c | sort -rn | head -5
   ```

   **Pass B — Tag overlap vs atoms/ folder:**
   ```bash
   VAULT_ATOMS="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/atoms"
   for tag in "${ATOM_TAGS[@]}"; do
     grep -l "$tag" "$VAULT_ATOMS"/*.md 2>/dev/null || true
   done | grep -v "$(basename $ATOM_PATH)" | sort -u | head -10
   ```

   **Pass C — Title keywords vs atoms/ folder:**
   ```bash
   for kw in $KEYWORDS; do
     grep -li "$kw" "$VAULT_ATOMS"/*.md 2>/dev/null || true
   done | grep -v "$(basename $ATOM_PATH)" | sort | uniq -c | sort -rn | head -5
   ```

   - Add at most 3 wikilinks with justifications to the atom's "## Theme connections" section
   - Update the atom file with the connections
   - If candidate targets are theme notes (Pass A), update those theme notes' "## Related atoms" sections

3. Report: "Theme matching complete. Found X connections for [atom title]."

Then ask: "Ready to synthesize a draft from these atoms? Enter a theme or topic (e.g. 'metric theater in product management'), 'skip' to exit without synthesizing, or 'q' to quit:"

## Step 4: Synthesize Draft (Human-Confirmed)

Only if the user provides a theme (not 'skip' or 'q'):

Run the synthesis logic from synthesize-draft.md:

**Find related atoms (two grep passes):**

```bash
VAULT_ATOMS="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/atoms"
THEME="<user-provided theme>"

# Pass A — Wikilink match in Theme connections section
grep -ril "\[\[$THEME" "$VAULT_ATOMS"/*.md 2>/dev/null | head -20

# Pass B — Title keyword match
KEYWORDS=$(echo "$THEME" | tr ' ' '\n' | grep -E '^.{5,}$' | head -5)
for kw in $KEYWORDS; do
  grep -li "$kw" "$VAULT_ATOMS"/*.md 2>/dev/null || true
done | sort | uniq -c | sort -rn | head -10
```

If fewer than 2 atoms found, print:
"Insufficient atoms for synthesis on topic: {theme}. Found N atom(s). Run /match-themes on more source atoms first."
Then ask for a different theme or 'q' to quit.

If >= 2 atoms found:

1. Read all matched atom files (title, body content, split_index)
2. Write a draft post to vault/drafts/ with:
   - Inline `[[atom-title]]` citations in body paragraphs
   - `source_atoms:` frontmatter listing only actually-cited atoms
   - EXACT frontmatter:
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
     ```
   - NOTE at top of body: "TODO: Apply Voice & Style Guide before publishing — ChatGPT Deep Research pending"

3. Write draft to: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/drafts/{sanitized-title}.md`

4. Report: "Draft created at drafts/{filename}. Review it in Obsidian before publishing. publishability is set to private — change manually when ready."

## Step 5: Release Lock

The EXIT trap releases the pipeline.lock automatically. When the session ends (after synthesis or after any 'q' exit), also print:
"Session complete. Pipeline lock released — daily scan can proceed."

## CRITICAL Constraints

- DO NOT generate any synthesis output before the user confirms the theme in Step 4
- DO NOT skip the pipeline.lock check in Step 1
- DO NOT acquire the pipeline.lock if one already exists (fail fast, print warning)
- The theme matching (Step 3) and synthesis (Step 4) steps use the EXACT same logic as match-themes.md and synthesize-draft.md — do not invent new approaches
- All atoms and drafts written in this session must have correct dual frontmatter: `type: X` AND `tags: [type/X]`
- Synthesis drafts must include the voice TODO flag: "TODO: Apply Voice & Style Guide before publishing — ChatGPT Deep Research pending"
- `publishability` is ALWAYS `private` for new drafts — never set to public
- Include quit/skip path ('q' or 'skip') at BOTH the atom selection step and the synthesis confirmation step
