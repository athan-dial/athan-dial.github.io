# Phase 12: GoodLinks Scanner - Research

**Researched:** 2026-02-19
**Domain:** GoodLinks SQLite ingestion → Obsidian vault notes (bash/Python pipeline extension)
**Confidence:** HIGH — GoodLinks database verified by direct inspection on this machine; pipeline patterns verified from existing working scripts

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| DATA-01 | Scanner can read GoodLinks SQLite database in read-only mode | DB path confirmed at `~/Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite`; `sqlite3.connect(db)` in Python opens read-only by default (no `PRAGMA` needed); confirmed schema in STACK.md |
| DATA-02 | Scanner tracks last-scan timestamp for incremental processing | State file pattern: JSON at `~/.model-citizen/seen-goodlinks-ids.json`; cursor field is `addedAt` (Unix float); query filter: `WHERE addedAt > ?` |
| DATA-03 | Scanner uses lookback buffer to handle iCloud sync lag | Store `last_scan_ts`; query `addedAt > (last_scan_ts - LOOKBACK_SECONDS)`; LOOKBACK = 3600 (1 hr) is safe default; hash-based idempotency prevents duplicate notes |
| INGS-01 | Scanner creates vault notes with standard frontmatter (title, url, source, date, tags, status) | SCHEMA.md defines required fields; source notes need: `title`, `date`, `status: inbox`, `tags`, `source: GoodLinks`, `source_url`; output dir: `sources/goodlinks/` |
| INGS-02 | Scanner passes GoodLinks tags through as initial note tags | `tags` column is comma-separated string (e.g., `"product,metrics"`) or NULL; split on comma, strip whitespace; already lowercase bare words (no kebab conversion needed in observed data) |
| INGS-03 | Scanner extracts pre-stored article content from GoodLinks content table | `content` table has `content` (plain text) column keyed by same UUID as `link.id`; LEFT JOIN in SQL query; 94% of links have content rows |
| INGS-04 | Scanner falls back to web fetch for links without pre-extracted content | ~6% have no `content` row; write stub note with `content_status: pending` in frontmatter; enrichment pipeline already handles minimal-content notes |
</phase_requirements>

---

## Summary

Phase 12 adds GoodLinks as a new content source to the existing Model Citizen ingestion pipeline. The implementation follows an established pattern: a bash orchestration script (`ingest-goodlinks.sh`) calls a Python helper (`goodlinks-query.py`) that queries the GoodLinks SQLite database and writes Markdown vault notes to `sources/goodlinks/`. This is the same architecture as the working YouTube ingestion (`ingest-youtube.sh` + yt-dlp).

All critical data access questions are resolved. The GoodLinks SQLite database has been inspected directly on this machine (GoodLinks v3.1.1, 92 active links, 87 with content). The schema is confirmed: `link` table holds metadata, `content` table holds pre-extracted plain text. The database path is stable and readable without any special permissions. No third-party libraries are needed — Python stdlib `sqlite3`, `datetime`, `json` cover all requirements.

The main implementation decisions are: (1) the state file format for tracking the `since_timestamp` cursor with lookback buffer, (2) filename slug generation from title+date matching existing vault conventions, and (3) the `content_status: pending` stub pattern for the ~6% of links without content rows. The first-run bootstrap decision is already locked: start `since_timestamp = now - 30 days` to avoid flooding the enrichment queue.

**Primary recommendation:** Write `goodlinks-query.py` as the Python core (SQLite query → Markdown emission), wrap in `ingest-goodlinks.sh` (state file management, directory setup, error handling). Follow `ingest-youtube.sh` as the structural template. Phase 12 does NOT wire into `scan-all.sh` (that is Phase 13).

---

## Standard Stack

### Core

| Technology | Version | Purpose | Why Standard |
|------------|---------|---------|--------------|
| Python 3.12 (Homebrew) | 3.12.11 at `/opt/homebrew/bin/python3.12` | Query SQLite, emit Markdown vault notes | stdlib `sqlite3` — zero new dependencies; already installed; preferred over system 3.9 |
| SQLite 3 (bundled with Python) | 3.51.0 | Read GoodLinks data store | GoodLinks stores all metadata in a stable SQLite file; direct read is safe, fast, no API needed |
| bash (system) | zsh-compat | Orchestration shell script, state file management, directory setup | All other pipeline scripts are bash (`ingest-youtube.sh`, `enrich-source.sh`, `scan-all.sh`); consistency for launchd |

### Supporting (Python stdlib — no installs)

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `sqlite3` | stdlib | Connect and query GoodLinks `data.sqlite` | Always |
| `datetime` | stdlib | Convert `addedAt` Unix float → ISO-8601 date string | Always |
| `json` | stdlib | Read/write state file (`seen-goodlinks-ids.json`) | Always |
| `pathlib` | stdlib | Path construction for output directory and state file | Preferred over `os.path` for clarity |
| `re` | stdlib | Generate filename slug from title | For slug sanitization |

### Alternatives Considered

| Recommended | Alternative | Why Not |
|-------------|-------------|---------|
| Direct SQLite read (`sqlite3` stdlib) | Apple Shortcuts CLI (`shortcuts run`) | Shortcuts requires GUI session; silently fails in launchd headless context (macOS architecture constraint) |
| `content` table plain text | Parse `articles/{id}/index.html` | Same text already extracted; HTML files are 32KB each; parser dependency adds complexity with no benefit |
| Python 3.12 (Homebrew) | System Python 3.9 (`/usr/bin/python3`) | 3.9 also works for this task; use 3.12 for consistency with other pipeline scripts; fall back to 3.9 only if launchd PATH issue arises |
| JSON state file | SQLite state file | JSON is simpler for single-value timestamp + seen-IDs set; matches patterns in existing pipeline state |

**Installation:** None required. All tools already on this machine.

---

## Architecture Patterns

### Recommended Script Structure

```
model-citizen/scripts/
├── ingest-goodlinks.sh       # NEW: bash orchestrator (state file, dir setup, calls Python)
├── goodlinks-query.py        # NEW: Python core (SQLite query → Markdown emission)
├── ingest-youtube.sh         # EXISTING: reference template
└── scan-all.sh               # EXISTING: NOT modified in Phase 12

~/.model-citizen/
├── goodlinks-state.json      # NEW: state file {last_scan_ts, seen_ids}
└── ...existing state files...

sources/goodlinks/            # NEW output directory
└── {slug}.md                 # Generated vault notes
```

### Pattern 1: State File for Incremental Scan + Lookback Buffer

**What:** Store `last_scan_ts` (Unix float) in a JSON state file. On each run, query `addedAt > (last_scan_ts - LOOKBACK_SECONDS)`. After writing notes, update `last_scan_ts = now`. Check `seen_ids` set to skip already-processed links despite the lookback window.

**When to use:** Always — prevents re-processing while catching late-arriving iCloud-synced items.

**LOOKBACK_SECONDS:** 3600 (1 hour) is safe. The v1.2 roadmap decisions confirm this pattern.

```python
# Source: STACK.md pattern + PITFALLS.md iCloud sync analysis
import json, time, pathlib

STATE_FILE = pathlib.Path.home() / ".model-citizen" / "goodlinks-state.json"
LOOKBACK_SECONDS = 3600  # 1 hour buffer for iCloud sync lag

def load_state():
    if STATE_FILE.exists():
        return json.loads(STATE_FILE.read_text())
    # First run: 30 days back (per prior decisions)
    return {"last_scan_ts": time.time() - (30 * 86400), "seen_ids": []}

def save_state(state):
    STATE_FILE.write_text(json.dumps(state, indent=2))

state = load_state()
since_ts = state["last_scan_ts"] - LOOKBACK_SECONDS
seen_ids = set(state.get("seen_ids", []))
```

### Pattern 2: SQLite Query with LEFT JOIN for Content

**What:** Single query joining `link` and `content` tables. `LEFT JOIN` means links without content rows still appear (content will be NULL). Filter `status = 0` AND `deletedAt IS NULL` to exclude trash/soft-deleted items.

```python
# Source: STACK.md — schema verified by direct DB inspection
import sqlite3, os

DB_PATH = os.path.expanduser(
    "~/Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite"
)

def get_new_links(since_ts: float) -> list[dict]:
    conn = sqlite3.connect(f"file:{DB_PATH}?mode=ro", uri=True)
    conn.row_factory = sqlite3.Row
    rows = conn.execute("""
        SELECT
            l.id, l.url, l.title, l.summary, l.author,
            l.tags, l.starred, l.addedAt,
            c.content, c.wordCount
        FROM link l
        LEFT JOIN content c ON l.id = c.id
        WHERE l.status = 0
          AND l.deletedAt IS NULL
          AND l.addedAt > ?
        ORDER BY l.addedAt ASC
    """, (since_ts,)).fetchall()
    conn.close()
    return [dict(r) for r in rows]
```

**Read-only mode:** Use `?mode=ro` URI parameter to ensure the connection is read-only. This prevents accidental writes and avoids WAL file contention with the running GoodLinks app.

### Pattern 3: Vault Note Emission with Frontmatter

**What:** Write YAML frontmatter matching `SCHEMA.md` source note spec + GoodLinks-specific fields. Filename slug from title, lowercase-kebab-case, max 60 chars.

```python
# Source: SCHEMA.md frontmatter spec + ingest-youtube.sh filename pattern
import datetime, re

def make_slug(title: str) -> str:
    slug = title.lower()
    slug = re.sub(r'[^a-z0-9\s-]', '', slug)
    slug = re.sub(r'[\s]+', '-', slug.strip())
    slug = re.sub(r'-+', '-', slug)
    return slug[:60].rstrip('-')

def ts_to_date(ts: float) -> str:
    return datetime.datetime.fromtimestamp(ts).strftime("%Y-%m-%d")

def tags_from_string(raw: str | None) -> list[str]:
    if not raw:
        return []
    return [t.strip() for t in raw.split(",") if t.strip()]

def emit_note(link: dict, output_dir: pathlib.Path) -> pathlib.Path:
    slug = make_slug(link["title"] or link["id"])
    filename = f"{slug}.md"
    outfile = output_dir / filename

    tags = tags_from_string(link.get("tags"))
    date = ts_to_date(link["addedAt"])
    content = link.get("content") or ""
    has_content = bool(content.strip())

    frontmatter_extra = ""
    if not has_content:
        frontmatter_extra = "\ncontent_status: pending"

    note = f"""---
title: {json.dumps(link['title'] or link['url'])}
date: {date}
status: inbox
tags: {json.dumps(tags)}
source: GoodLinks
source_url: {json.dumps(link['url'])}
goodlinks_id: {json.dumps(link['id'])}
starred: {str(bool(link.get('starred'))).lower()}{frontmatter_extra}
---

{content if has_content else f"[Content pending — article body not yet extracted by GoodLinks]"}
"""
    outfile.write_text(note.strip() + "\n")
    return outfile
```

### Pattern 4: Bash Orchestration (ingest-goodlinks.sh)

**What:** Thin bash wrapper handling directory creation, Python invocation, and exit codes. Matches `ingest-youtube.sh` structure exactly for pipeline consistency.

```bash
#!/usr/bin/env bash
# ingest-goodlinks.sh
# Queries GoodLinks SQLite and creates vault source notes in sources/goodlinks/
# Usage: ./ingest-goodlinks.sh [--dry-run]

set -euo pipefail

VAULT_DIR="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/model-citizen-vault"
OUTPUT_DIR="$VAULT_DIR/sources/goodlinks"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON="/opt/homebrew/bin/python3.12"

mkdir -p "$OUTPUT_DIR"

DRY_RUN=""
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN="--dry-run"
fi

"$PYTHON" "$SCRIPT_DIR/goodlinks-query.py" \
  --output-dir "$OUTPUT_DIR" \
  $DRY_RUN

echo "GoodLinks scan complete"
```

### Anti-Patterns to Avoid

- **Hard cursor without lookback:** `WHERE addedAt > last_scan_ts` (no buffer) permanently loses items saved from iPhone during iCloud sync lag. Always subtract `LOOKBACK_SECONDS`.
- **Write-mode SQLite connection:** `sqlite3.connect(DB_PATH)` opens read-write by default. Use `?mode=ro` URI parameter to prevent accidental writes and WAL contention.
- **Tag removal as "processed" signal:** Not applicable here (we don't use tags as queue). State file tracks seen IDs.
- **Shortcuts CLI:** `shortcuts run` silently fails in launchd headless context. Not used here; direct SQLite read is the chosen approach.
- **Filename collisions:** Slug-only filenames can collide if two articles have similar titles. Append short UUID suffix if `outfile.exists()`. Or use `{slug}-{goodlinks_id[:8]}.md` always.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| SQLite access | Custom file reader | Python stdlib `sqlite3` | Handles WAL, row factory, type coercion |
| Date formatting | String manipulation of Unix epoch | `datetime.datetime.fromtimestamp(ts).strftime(...)` | Handles timezone, DST correctly |
| State persistence | Custom binary format | `json.dumps`/`json.loads` to file | Already used by pipeline; readable; diff-friendly |
| Tag normalization | Complex regex pipeline | `raw.split(",")` + `strip()` | GoodLinks tags are already lowercase bare words |
| Read-only DB access | `PRAGMA query_only = ON` | `?mode=ro` URI parameter | URI mode is the idiomatic Python sqlite3 pattern |

---

## Common Pitfalls

### Pitfall 1: iCloud Sync Lag Loses iPhone-Saved Items

**What goes wrong:** Scanner runs at 7 AM; user saved article on iPhone at 6:55 AM; iCloud hasn't synced yet; scanner records `last_scan_ts = now`; article syncs at 7:05 AM; next 7 AM run queries `addedAt > yesterday-7AM`; article `addedAt` is yesterday-6:55 AM — caught. Wait — this only works if lookback reaches back. If lookback is only 1 hour, a 23-hour-old article missed yesterday is NOT caught. **Solution:** Lookback of 1 hour is sufficient for iCloud sync lag (max observed delay is ~20 min per community reports). The real gap is: article syncs AFTER today's 7 AM scan. It will be caught tomorrow with 1-hour lookback since it was added <24h ago relative to tomorrow's scan.

**How to avoid:** LOOKBACK = 3600 covers all realistic iCloud sync delays. Combine with `seen_ids` set so lookback doesn't re-create notes.

### Pitfall 2: Filename Collision on Similar Titles

**What goes wrong:** Two GoodLinks articles with similar titles (e.g., "Product Strategy" x2) generate the same slug → second write overwrites first.

**How to avoid:** Check `outfile.exists()` before writing. If collision, append `goodlinks_id[:8]` suffix: `{slug}-{short_id}.md`.

### Pitfall 3: First-Run Flooding

**What goes wrong:** State file missing → `load_state()` defaults to `since_ts = 0` → all 92 historical links ingested → enrichment queue flooded.

**How to avoid:** Default `since_ts = time.time() - (30 * 86400)` in `load_state()` when no state file exists. This is a locked prior decision.

### Pitfall 4: Tags Field NULL in SQL vs. Empty String in Python

**What goes wrong:** SQLite returns Python `None` for NULL columns. `None.split(",")` raises `AttributeError`. Tags are NULL for untagged links.

**How to avoid:** Guard with `if not raw: return []` in `tags_from_string()` before any string operation.

### Pitfall 5: WAL File Contention with Running GoodLinks App

**What goes wrong:** GoodLinks app is open and writing to the DB (WAL mode). Concurrent scanner read may see dirty data or WAL checkpoint errors.

**How to avoid:** `?mode=ro` URI parameter + sqlite3's WAL-compatible read isolation means this is safe. SQLite WAL allows concurrent readers. Direct observation: WAL files were present but 0 bytes at time of research — GoodLinks does not hold the WAL open persistently.

### Pitfall 6: content Column Returns None for ~6% of Links

**What goes wrong:** `LEFT JOIN` returns `None` for `content.content` when no content row exists. Writing `None` to note body produces literal "None" string in Markdown.

**How to avoid:** Check `has_content = bool(content and content.strip())`. When false, write placeholder text and `content_status: pending` frontmatter field.

---

## Code Examples

### Complete Python Script Skeleton

```python
#!/usr/bin/env /opt/homebrew/bin/python3.12
"""
goodlinks-query.py — emit new GoodLinks links as vault Markdown source notes

Usage: python3 goodlinks-query.py --output-dir <path> [--dry-run]
"""
import sqlite3, os, datetime, json, re, time, pathlib, argparse

DB_PATH = pathlib.Path.home() / "Library" / "Group Containers" \
          / "group.com.ngocluu.goodlinks" / "Data" / "data.sqlite"
STATE_FILE = pathlib.Path.home() / ".model-citizen" / "goodlinks-state.json"
LOOKBACK_SECONDS = 3600

def load_state() -> dict:
    if STATE_FILE.exists():
        return json.loads(STATE_FILE.read_text())
    return {"last_scan_ts": time.time() - (30 * 86400), "seen_ids": []}

def save_state(state: dict):
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps(state, indent=2))

def get_new_links(since_ts: float) -> list[dict]:
    conn = sqlite3.connect(f"file:{DB_PATH}?mode=ro", uri=True)
    conn.row_factory = sqlite3.Row
    rows = conn.execute("""
        SELECT l.id, l.url, l.title, l.summary, l.author,
               l.tags, l.starred, l.addedAt,
               c.content, c.wordCount
        FROM link l
        LEFT JOIN content c ON l.id = c.id
        WHERE l.status = 0 AND l.deletedAt IS NULL AND l.addedAt > ?
        ORDER BY l.addedAt ASC
    """, (since_ts,)).fetchall()
    conn.close()
    return [dict(r) for r in rows]

def make_slug(title: str) -> str:
    s = re.sub(r'[^a-z0-9\s-]', '', title.lower())
    s = re.sub(r'[\s]+', '-', s.strip())
    return re.sub(r'-+', '-', s)[:60].rstrip('-')

def emit_note(link: dict, output_dir: pathlib.Path, dry_run: bool) -> str:
    slug = make_slug(link["title"] or link["id"])
    filename = f"{slug}.md"
    outfile = output_dir / filename
    if outfile.exists():
        filename = f"{slug}-{link['id'][:8]}.md"
        outfile = output_dir / filename

    tags = [t.strip() for t in (link["tags"] or "").split(",") if t.strip()]
    date = datetime.datetime.fromtimestamp(link["addedAt"]).strftime("%Y-%m-%d")
    content = (link.get("content") or "").strip()
    has_content = bool(content)

    extras = "\ncontent_status: pending" if not has_content else ""
    body = content if has_content else "[Content pending — not yet extracted by GoodLinks]"

    note = f"""---
title: {json.dumps(link['title'] or link['url'])}
date: {date}
status: inbox
tags: {json.dumps(tags)}
source: GoodLinks
source_url: {json.dumps(link['url'])}
goodlinks_id: {json.dumps(link['id'])}
starred: {str(bool(link.get('starred'))).lower()}{extras}
---

{body}
"""
    if not dry_run:
        outfile.write_text(note.strip() + "\n")
    return filename

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    output_dir = pathlib.Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    state = load_state()
    since_ts = state["last_scan_ts"] - LOOKBACK_SECONDS
    seen_ids = set(state.get("seen_ids", []))

    links = get_new_links(since_ts)
    new_links = [l for l in links if l["id"] not in seen_ids]

    print(f"Found {len(links)} links since lookback window, {len(new_links)} new")

    created = []
    for link in new_links:
        filename = emit_note(link, output_dir, args.dry_run)
        created.append(filename)
        print(f"  {'[DRY RUN] ' if args.dry_run else ''}Created: {filename}")

    if not args.dry_run and new_links:
        state["last_scan_ts"] = time.time()
        state["seen_ids"] = list(seen_ids | {l["id"] for l in new_links})
        save_state(state)

    print(f"GoodLinks scan complete: {len(created)} notes created")

if __name__ == "__main__":
    main()
```

### State File Format

```json
{
  "last_scan_ts": 1740017877.438,
  "seen_ids": [
    "uuid-1",
    "uuid-2"
  ]
}
```

### Verification Query (Run Before Implementation)

```bash
/opt/homebrew/bin/python3.12 - <<'EOF'
import sqlite3, os, pathlib
db = pathlib.Path.home() / "Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite"
conn = sqlite3.connect(f"file:{db}?mode=ro", uri=True)
print("Active links:", conn.execute("SELECT COUNT(*) FROM link WHERE status=0 AND deletedAt IS NULL").fetchone()[0])
print("With content:", conn.execute("SELECT COUNT(*) FROM content").fetchone()[0])
print("Tags sample:", conn.execute("SELECT tags FROM link WHERE tags IS NOT NULL LIMIT 5").fetchall())
conn.close()
EOF
```

---

## State of the Art

| Old Approach | Current Approach | Impact |
|--------------|------------------|--------|
| Apple Shortcuts CLI for GoodLinks data | Direct SQLite read | Headless-safe; no GUI session required |
| Full re-scan every run | Timestamp cursor + lookback buffer | Incremental; handles iCloud lag without duplicates |
| Cursor without buffer | `since_ts - LOOKBACK_SECONDS` | Catches late-arriving iPhone-saved items |

**Deprecated/outdated (per PITFALLS.md):**
- Direct SQLite read was considered "fragile" in 2021-era advice — but the `group.com.ngocluu.goodlinks` Group Container path has been stable across all GoodLinks v3.x versions per community tooling. Use it; document the path as the known-stable access method.

---

## Open Questions

1. **State file seen_ids growth over time**
   - What we know: 92 links currently; ~5-10 new per week (estimated)
   - What's unclear: Over 2+ years, seen_ids list could grow to 1000+ entries. JSON array linear scan is fine at this scale; no issue.
   - Recommendation: Use list (not set) in JSON for serializability; convert to set in-memory for O(1) lookup.

2. **Filename collision handling**
   - What we know: Slug collisions possible if two articles have identical or near-identical titles.
   - What's unclear: Frequency in real GoodLinks data with 92 links is unknown.
   - Recommendation: Check `outfile.exists()` before write; append `link['id'][:8]` on collision. Low-risk fallback.

3. **Content encoding edge cases**
   - What we know: `content.content` is plain text extracted by GoodLinks. Japanese, Arabic, emoji are possible.
   - What's unclear: Whether GoodLinks stores UTF-8 consistently.
   - Recommendation: Python `str.write_text()` defaults to UTF-8 on macOS. SQLite returns Python `str` (decoded). Should work transparently; add `encoding='utf-8'` to `write_text()` explicitly as defensive measure.

4. **INGS-04: Web fetch fallback — scope for Phase 12**
   - What we know: INGS-04 says "falls back to web fetch for links without pre-extracted content." Phase 12 success criteria do not require the fallback to actually fetch — only to handle the ~6% stub case.
   - What's unclear: Does the planner interpret INGS-04 as "write the web-fetch fallback logic" or "note the ~6% as pending"?
   - Recommendation: **Phase 12 implementation of INGS-04 = write stub note with `content_status: pending`.** Actual web fetch is enrichment-pipeline territory, not scanner territory. Confirm with planner.

---

## Sources

### Primary (HIGH confidence)

- Direct inspection of `~/Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite` (GoodLinks v3.1.1 on this machine) — schema, row counts, tag formats all verified live
- `STACK.md` in `.planning/research/` — full schema documentation from live DB inspection
- `FEATURES.md` in `.planning/research/` — feature landscape and MVP definition
- `PITFALLS.md` in `.planning/research/` — iCloud sync lag, Shortcuts CLI headless failure, tag deletion pitfalls
- `model-citizen-vault/scripts/ingest-youtube.sh` — structural template for bash wrapper
- `model-citizen-vault/SCHEMA.md` — frontmatter requirements for source notes
- `model-citizen/scripts/scan-all.sh` — integration pattern (Phase 13 target; not touched in Phase 12)
- `~/.model-citizen/` — confirmed state directory exists and is the correct home for new state file

### Secondary (MEDIUM confidence)

- [cychong47/goodlinks GitHub](https://github.com/cychong47/goodlinks) — independently confirms DB path and schema field names (cross-source verification)
- [GoodLinks URL Scheme docs](https://goodlinks.app/url-scheme/) — confirmed no bulk enumerate capability; SQLite is the right approach

### Tertiary (LOW confidence)

- iCloud sync delay estimates (seconds to 20+ min) from community reports — not an official SLA. LOOKBACK_SECONDS = 3600 is conservative and safe.

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all tools verified on this machine; no installs needed
- Architecture: HIGH — pattern directly cloned from working `ingest-youtube.sh`; differences are SQLite vs. yt-dlp
- SQLite schema: HIGH — verified by direct DB inspection (ground truth)
- Pitfalls: HIGH (iCloud sync, filename collision, NULL content) / MEDIUM (WAL contention — theoretical but safe with `?mode=ro`)
- INGS-04 scope interpretation: MEDIUM — minor ambiguity resolved by recommendation above

**Research date:** 2026-02-19
**Valid until:** 2026-04-19 (stable — GoodLinks schema has been unchanged across v3.x; Python stdlib APIs are stable)
