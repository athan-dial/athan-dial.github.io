# Stack Research

**Domain:** GoodLinks ingestion pipeline (macOS read-later app to existing bash enrichment pipeline)
**Researched:** 2026-02-19
**Confidence:** HIGH — database structure verified by direct inspection of live GoodLinks installation on this machine

---

## What Was Verified Directly

The following was confirmed by reading the actual GoodLinks container on this machine (not inferred from documentation).

**Primary database — confirmed exists and is readable:**
```
~/Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite
```

**`link` table schema (confirmed, GoodLinks v3.1.1):**
```
id (TEXT)           UUID, matches article directory names in the Containers path
url (TEXT)          canonical URL
originalURL (TEXT)  pre-redirect URL if different from url
title (TEXT)        article title
summary (TEXT)      short description (often null)
author (TEXT)       author name (often null)
preview (TEXT)      thumbnail image URL
tags (TEXT)         comma-separated string, e.g. "product,metrics" — or NULL if untagged
starred (BOOLEAN)   1 if starred
readAt (DOUBLE)     Unix timestamp float, null if unread
addedAt (DOUBLE)    Unix timestamp float when saved — use as ingestion cursor
modifiedAt (DOUBLE)
fetchStatus (INTEGER)
status (INTEGER)    0 = active; non-zero = deleted/trash — always filter WHERE status = 0
publishedAt (DOUBLE)
deletedAt (DOUBLE)  non-null means soft-deleted — filter WHERE deletedAt IS NULL
folderID (TEXT)
```

**`content` table schema (confirmed):**
```
id (TEXT)           same UUID as link.id
content (TEXT)      PLAIN TEXT already extracted by GoodLinks — no HTML parsing needed
wordCount (INTEGER)
videoDuration (INTEGER)
```

**`highlight` table schema (confirmed, useful for enriched notes):**
```
id (TEXT)
linkID (TEXT)       foreign key to link.id
content (TEXT)      highlighted text excerpt
note (TEXT)         user annotation on the highlight
color (INTEGER)
time (DOUBLE)       timestamp of highlight
```

**Live data on this machine at time of research:**
- 92 total links in `link` table
- 87 have rows in `content` table (5 pending fetch — network fetch not yet complete)
- Status distribution: all 92 have status = 0 (active)
- Tags observed: `app, bjj, frameworks, manual, metrics, product, scrum, strudel, templates`

**Key insight:** `content.content` is already-extracted plain text. The article HTML at
`~/Library/Containers/com.ngocluu.goodlinks/Data/Library/Application Support/articles/{id}/index.html`
is the formatted reader view (~32KB per file). Use the `content` table instead — same text, no parsing.

---

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Python 3.12 (Homebrew) | 3.12.11 at `/opt/homebrew/bin/python3.12` | Query SQLite, emit Markdown source notes | `sqlite3` is stdlib — zero new dependencies. Already installed. 3.12 preferred over system 3.9 for match_text and walrus operator support, but 3.9 also works. |
| SQLite 3 (system) | 3.51.0 at `/usr/bin/sqlite3` | GoodLinks data store | GoodLinks stores all link metadata in a standard SQLite file at a stable, documented path. Direct read is safe (read-only), fast, and requires no API or sandbox workaround. |
| bash | system zsh-compat | Orchestration, idempotency state file, pipeline hand-off | Every other capture script in the pipeline is bash (`ingest-youtube.sh`, `enrich-source.sh`). Consistency matters for a headless launchd job. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `sqlite3` (Python stdlib) | included | Query `data.sqlite` | Always — it is the only access method needed |
| `datetime` (Python stdlib) | included | Convert GoodLinks Unix timestamp floats to ISO-8601 dates | Always — `addedAt` is a float epoch (e.g. `1740017877.438`) |
| `json` (Python stdlib) | included | Read/write `.seen-goodlinks-ids.json` state file for idempotency | Always |
| `hashlib` (Python stdlib) | included | Optional: hash the link UUID for shorter state keys | Only if state file format requires it |
| `jq` | 1.7.1 (already installed at `/usr/bin/jq`) | Inspect JSON state file from bash orchestration script | Only if the bash wrapper needs to read the seen-IDs file |

**No third-party Python packages are needed. All required libraries are Python stdlib.**

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `sqlite3` CLI at `/usr/bin/sqlite3` | Manual schema inspection during development | `sqlite3 "$HOME/Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite"` |
| `plutil` | Inspect GoodLinks preferences plist | Tags list is also cached in `com.ngocluu.goodlinks.plist` preferences |

---

## Installation

No new installations required. Everything is already on this machine.

Sanity-check command to run once before implementation:

```bash
/opt/homebrew/bin/python3.12 - <<'EOF'
import sqlite3, os
db = os.path.expanduser(
    "~/Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite"
)
conn = sqlite3.connect(db)
count = conn.execute("SELECT COUNT(*) FROM link WHERE status = 0").fetchone()[0]
content_count = conn.execute("SELECT COUNT(*) FROM content").fetchone()[0]
print(f"Active links: {count}")
print(f"Links with content: {content_count}")
conn.close()
EOF
```

---

## Integration Point With Existing Pipeline

The new script follows the same pattern as `ingest-youtube.sh`:

```
ingest-goodlinks.sh (new bash script)
    calls: goodlinks-query.py (new Python script — queries SQLite, emits Markdown)
    outputs to: sources/goodlinks/   (new subfolder, same schema as sources/youtube/)
    feeds into: enrich-source.sh (existing — unchanged)
```

**Frontmatter the new script must emit** (from vault `SCHEMA.md`):

```yaml
---
title: "Article Title"
date: 2026-02-19
status: "inbox"
tags: []                        # GoodLinks tags become initial tags; enrichment adds more
source: "GoodLinks"
source_url: "https://..."
goodlinks_id: "uuid-here"       # Store for idempotency and traceability
starred: false
author: "Author Name"           # from link.author, may be empty string
---

Article body here (from content.content plain text)
```

**Idempotency mechanism:** maintain a state file at
`~/.model-citizen/seen-goodlinks-ids.json` (same directory as other pipeline state).
On each run: load seen IDs, query only links where `addedAt > last_run_timestamp`,
write new source notes, append new IDs and update timestamp.

**Cursor field:** use `addedAt` (Unix float). Store the max `addedAt` seen in state file.
This handles the common case of incremental daily runs.

---

## Data Access Pattern (Concrete)

```python
#!/usr/bin/env /opt/homebrew/bin/python3.12
"""
goodlinks-query.py — emit new GoodLinks links as Markdown source notes

Usage: python3 goodlinks-query.py --since <unix-timestamp> --output-dir <path>
"""
import sqlite3, os, datetime, json, sys

DB_PATH = os.path.expanduser(
    "~/Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite"
)

def get_new_links(since_timestamp: float = 0.0):
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    rows = conn.execute("""
        SELECT
            l.id, l.url, l.title, l.summary, l.author,
            l.tags, l.starred, l.addedAt, l.publishedAt,
            c.content, c.wordCount
        FROM link l
        LEFT JOIN content c ON l.id = c.id
        WHERE l.status = 0
          AND l.deletedAt IS NULL
          AND l.addedAt > ?
        ORDER BY l.addedAt ASC
    """, (since_timestamp,)).fetchall()
    conn.close()
    return [dict(r) for r in rows]

def tags_from_string(raw: str | None) -> list[str]:
    if not raw:
        return []
    return [t.strip() for t in raw.split(",") if t.strip()]

def added_at_to_date(ts: float) -> str:
    return datetime.datetime.fromtimestamp(ts).strftime("%Y-%m-%d")
```

**Tags field format:** comma-separated string (e.g. `"product,metrics,frameworks"`) or `NULL`.
Split with `tags.split(",")` when non-null.

**Content availability:** ~94% of links have content. For the ~6% without content (fetch pending),
write the source note with URL + title only, no body. The enrichment pipeline already handles
minimal-content notes via the readability-based web capture fallback.

---

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Direct SQLite read (`group.com.ngocluu.goodlinks`) | GoodLinks JSON export (File > Export) | Only if macOS App Sandbox permissions ever block Group Containers access. Export requires manual trigger — not automatable from launchd. |
| Direct SQLite read | GoodLinks URL scheme (`goodlinks://x-callback-url/`) | URL scheme is designed for iOS/Shortcuts, not shell scripts. Cannot enumerate all links — only open/save individual ones. Not useful for bulk ingestion. |
| Plain text from `content` table | Parse `articles/{id}/index.html` | Use HTML only if you need article images or structured HTML output. For text enrichment, plain text is sufficient and avoids a parser dependency. |
| Python stdlib `sqlite3` | Third-party ORM (`dataset`, `sqlalchemy`) | Schema is read-only and simple. An ORM adds an install requirement that will cause `import` failures in launchd's minimal PATH environment. |

---

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| GoodLinks public API | Does not exist. GoodLinks has no REST or GraphQL API. | Direct SQLite read |
| CloudKit database at `~/Library/Containers/com.ngocluu.goodlinks/Data/CloudKit/cloudd_db/db` | Payloads are NSKeyedArchiver BLOBs, not readable SQL. RecordCache table was empty (0 rows) at time of inspection. | `group.com.ngocluu.goodlinks/Data/data.sqlite` |
| `articles/{id}/index.html` as content source | 32KB formatted HTML per file, requires HTML parsing, and the same text is already extracted to `content.content` as plain string. | `content.content` column in SQLite |
| n8n for this ingestion | No GoodLinks node exists. Would require a custom HTTP node calling a local Flask server, adding infrastructure for a task a 50-line Python script handles. | Direct SQLite via Python |
| AppleScript | GoodLinks has no AppleScript dictionary. | Direct SQLite read |
| `~/Library/Containers/com.ngocluu.goodlinks` (app sandbox container, NOT group container) | Contains article HTML files only. No metadata: no URL, no title, no tags. | `~/Library/Group Containers/group.com.ngocluu.goodlinks` for the SQLite DB |

---

## Stack Patterns by Variant

**If GoodLinks adds more articles than expected (batch >500/day):**
- Add `LIMIT 100` clause with pagination loop by `addedAt` cursor
- Pattern matches YouTube ingest script's batch handling

**If tags need normalization (pipeline convention is kebab-case):**
- Add normalization: `tag.lower().replace(" ", "-")`
- Tags observed on this machine are already lowercase bare words, no spaces

**If content is missing for a link (`content` table has no row for that ID):**
- Write source note with URL + title only, set `content_status: pending` in frontmatter
- Optionally invoke existing readability-based web capture as fallback (already in pipeline)

**If highlights should be included:**
- Join `highlight` on `linkID = link.id` and append them as a `## Highlights` section
- Fields: `content` (text), `note` (user annotation), `color` (int 0-4 representing color)

---

## Version Compatibility

| Component | Version | Compatibility Notes |
|-----------|---------|---------------------|
| Python 3.12 (`/opt/homebrew/bin/python3.12`) | 3.12.11 | Fully compatible — stdlib `sqlite3` available |
| Python 3.9 (system `/usr/bin/python3`) | 3.9.6 | Also compatible — use if Homebrew Python causes launchd PATH issues |
| SQLite 3 (system) | 3.51.0 | GoodLinks DB uses SQLite 3.x — no WAL complications observed (WAL files present but 0 bytes) |
| GoodLinks app | 3.1.1 | Schema verified at this version. The `link` and `content` tables have been stable across all v3.x versions per community scripts going back to 2021. |

---

## Sources

- Direct filesystem inspection of `~/Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite` — HIGH confidence (ground truth, primary database read on this machine)
- [cychong47/goodlinks GitHub](https://github.com/cychong47/goodlinks) — Python script independently confirms DB path `~/Library/Group Containers/group.com.ngocluu.goodlinks/Data/data.sqlite` and schema field names
- [GoodLinks JSON export gist (vascobrown)](https://gist.github.com/vascobrown/479bb47d3f0138a3f595143d93afa658) — confirms JSON export fields (url, tags, addedAt, starred) match DB schema
- [GoodLinks URL Scheme docs](https://goodlinks.app/url-scheme/) — confirmed no enumerate/export capability via URL scheme; only open/save individual links
- Model Citizen vault `SCHEMA.md` and `scripts/ingest-youtube.sh` — direct read for integration pattern and frontmatter requirements

---
*Stack research for: GoodLinks ingestion pipeline addition to Model Citizen*
*Researched: 2026-02-19*
