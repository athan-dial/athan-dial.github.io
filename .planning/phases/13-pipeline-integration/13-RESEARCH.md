# Phase 13: Pipeline Integration - Research

**Researched:** 2026-02-20
**Domain:** Shell scripting, URL normalization, pipeline orchestration
**Confidence:** HIGH

## Summary

Phase 13 wires the GoodLinks scanner (Phase 12) into the existing daily automation (`scan-all.sh`), adds cross-source URL normalization for deduplication, and validates end-to-end flow. The existing infrastructure is well-understood — `scan-all.sh` follows a continue-on-failure pattern with per-source status tracking, and `enrich-source.sh` handles the enrichment pipeline.

Key integration points: (1) Add GoodLinks as a 4th scanner in `scan-all.sh` (located at `/Users/adial/Documents/GitHub/athan-dial.github.io/model-citizen/scripts/scan-all.sh`), (2) Create a shared `normalize-url.py` utility, (3) Add dedup checking before enrichment, (4) Add macOS notification on failure.

**Primary recommendation:** Three tasks — URL normalization utility, scan-all.sh integration with dedup, and end-to-end validation. Single wave since tasks are sequential dependencies.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### URL Normalization
- Sample 10-15 real GoodLinks URLs from live DB first, then decide which tracking params to strip
- Canonicalize domains: strip www., resolve mobile/amp subdomains to canonical form
- Apply retroactively to all existing vault notes (Slack, Outlook, YouTube) — one-time migration ensures dedup catches old+new overlaps
- Shared utility: standalone normalize-url script/function that all scanners import (single source of truth)

#### Failure Behavior
- Continue-on-failure pattern (consistent with existing scan-all.sh) — one source failing doesn't block others
- macOS notification on any scanner failure (all sources, not just GoodLinks) — retrofit existing sources
- One retry with short delay before declaring failure and notifying

#### Dedup Strategy
- Dedup check happens before enrichment (no wasted Claude calls on duplicates)
- URL-only matching (normalized URL, no fuzzy title matching)
- On duplicate: merge tags from GoodLinks into existing note, don't create new note
- Multi-source field: change `source` from single string to array (e.g., `['slack', 'goodlinks']`) to show provenance

#### Validation
- Build dry-run mode (--dry-run flag shows what WOULD happen without creating notes or calling enrichment)
- Also validate with real data: save article in GoodLinks, trigger manual scan, verify enriched note in vault
- Trust dedup logic at unit level (no explicit cross-source integration test required)
- Auto-enable in scan-all.sh once validation passes (no manual switch)
- Run summary after each daily scan: X notes from Slack, Y from GoodLinks, Z skipped (dedup) — logged for observability

### Claude's Discretion
- URL normalization param strip list (after sampling real URLs)
- Retry delay duration
- Exact run summary format and location
- Migration script approach for retroactive URL normalization

### Deferred Ideas (OUT OF SCOPE)
None
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| INTG-01 | GoodLinks scanner is wired into scan-all.sh orchestrator | scan-all.sh pattern understood; add as 4th scanner section after web capture queue |
| INTG-02 | URL normalization prevents duplicates across GoodLinks, web capture, Slack, and Outlook sources | normalize-url.py utility + dedup check before enrichment; sampled 15 real URLs to inform param strip list |
| INTG-03 | GoodLinks notes flow through existing Claude enrichment pipeline (summaries, tags, ideas) | enrich-source.sh already handles any source .md file; GoodLinks notes have compatible frontmatter |
</phase_requirements>

## Standard Stack

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| Python 3.12 | /opt/homebrew/bin/python3.12 | URL normalization, dedup, migration | Matches existing goodlinks-query.py |
| Bash | system | scan-all.sh orchestration | Matches existing pipeline scripts |
| osascript | system | macOS notification on failure | Native, no dependencies |

### Supporting
| Tool | Purpose | When to Use |
|------|---------|-------------|
| urllib.parse | URL normalization (stdlib) | Parsing and reconstructing URLs |
| re | Regex for param stripping | Pattern matching tracking params |

## Architecture Patterns

### scan-all.sh Integration Pattern
The existing scan-all.sh follows a consistent pattern for each scanner:
1. Print colored banner
2. Check credentials/prerequisites (skip if missing)
3. Run scanner with `tee` to temp log
4. Extract count from log output
5. Track status (SUCCESS/FAILED/SKIPPED)
6. Continue on failure

GoodLinks scanner needs no credentials (local SQLite), so the credential check step is replaced by a DB existence check.

### URL Normalization Pipeline
```
raw_url → lowercase scheme+host → strip www. → strip tracking params → strip fragment → sort remaining params → canonical URL
```

### Dedup Flow
```
new note created → normalize source_url → check all existing vault notes for matching normalized URL → if match: merge tags, skip note creation → if no match: proceed to enrichment
```

### Real URL Analysis (15 sampled from live DB)

**Tracking params found:**
- Reddit iOS share: `share_id`, `utm_content`, `utm_medium`, `utm_name`, `utm_source`, `utm_term` (6/15 URLs)
- General UTM: `utm_source`, `utm_medium`, `utm_campaign`, `utm_content`, `utm_term`

**Domain canonicalization needed:**
- `www.` prefix on ~60% of URLs (reddit, anthropic, demellospirituality)
- No AMP or mobile subdomains seen in sample

**Recommended strip list:**
```python
STRIP_PARAMS = {
    # UTM tracking
    'utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term',
    # Reddit iOS sharing
    'share_id',
    # Common analytics
    'ref', 'source', 'fbclid', 'gclid', 'mc_cid', 'mc_eid',
    # Newsletter/email tracking
    'mkt_tok', 'trk', 'trkCampaign',
}
```

This is conservative — strips known tracking params without touching content-bearing params. Can always expand if new patterns emerge.

### Enrichment Compatibility

GoodLinks notes already emit compatible frontmatter:
```yaml
status: inbox          # enrich-source.sh checks for "enriched" to skip
source: GoodLinks      # will become source array for multi-source
source_url: "..."      # normalization target
tags: [...]            # merge target for dedup
```

`enrich-source.sh` reads `status` field — `inbox` notes will be picked up for enrichment. No changes needed to enrichment pipeline itself.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| URL parsing | Custom regex | `urllib.parse.urlparse` | Handles edge cases (ports, auth, unicode) |
| macOS notifications | AppleScript from scratch | `osascript -e 'display notification'` | One-liner, native |
| YAML frontmatter parsing | Full YAML parser | `grep`/`awk` for field extraction | Existing scripts use this pattern |

## Common Pitfalls

### Pitfall 1: Enrichment Trigger Missing
**What goes wrong:** GoodLinks notes created but never enriched because no trigger exists
**Why it happens:** scan-all.sh scans for URLs but doesn't trigger enrichment
**How to avoid:** After GoodLinks scan creates notes, iterate new notes and call `enrich-source.sh --source <path>` for each. Or let the existing daily enrichment sweep pick them up.
**Resolution:** The existing pipeline uses `enrich-source.sh` per-file. scan-all.sh currently doesn't trigger enrichment for any source — enrichment is a separate step. Check if there's a separate enrichment trigger in the launchd schedule or if it's manual.

### Pitfall 2: Source Field Migration Breaking Existing Notes
**What goes wrong:** Changing `source: "slack"` to `source: ["slack"]` breaks grep-based filters
**Why it happens:** Existing scripts/queries expect string, not array
**How to avoid:** Migration script must update both format AND any scripts that read the field. Or: keep `source` as primary source string, add `sources` (plural) as array field.

### Pitfall 3: Dedup Race Condition
**What goes wrong:** Two scanners run in parallel, both find same URL, both create notes
**Why it happens:** scan-all.sh runs scanners sequentially but capture-web.sh is async
**How to avoid:** Dedup check at note creation time (before write), not just at scan time

### Pitfall 4: GoodLinks DB Path Not Found
**What goes wrong:** Scanner fails on machines without GoodLinks installed
**Why it happens:** Hardcoded DB path doesn't exist
**How to avoid:** Check DB existence before running, use SKIPPED status (like Slack credential check)

## Code Examples

### macOS Notification
```bash
osascript -e 'display notification "GoodLinks scan failed" with title "Model Citizen" sound name "Basso"'
```

### URL Normalization (Python)
```python
from urllib.parse import urlparse, parse_qs, urlencode, urlunparse

def normalize_url(url: str) -> str:
    parsed = urlparse(url)
    host = parsed.hostname.lower() if parsed.hostname else ''
    if host.startswith('www.'):
        host = host[4:]
    params = parse_qs(parsed.query, keep_blank_values=False)
    cleaned = {k: v for k, v in params.items() if k not in STRIP_PARAMS}
    sorted_query = urlencode(sorted(cleaned.items()), doseq=True)
    return urlunparse(('https', host, parsed.path.rstrip('/'), '', sorted_query, ''))
```

### Dedup Check Pattern
```python
import glob, re

def find_existing_note(normalized_url: str, vault_sources_dir: str) -> str | None:
    for md_file in glob.glob(f"{vault_sources_dir}/**/*.md", recursive=True):
        with open(md_file) as f:
            for line in f:
                if line.startswith('source_url:'):
                    existing_url = line.split(':', 1)[1].strip().strip('"')
                    if normalize_url(existing_url) == normalized_url:
                        return md_file
    return None
```

### Tag Merge Pattern
```python
def merge_tags(existing_file: str, new_tags: list[str]):
    # Read existing tags from frontmatter
    # Union with new_tags
    # Update frontmatter using update-frontmatter.py
    pass
```

## Open Questions

1. **Enrichment trigger mechanism**
   - What we know: `enrich-source.sh` enriches a single file. `scan-all.sh` doesn't trigger enrichment.
   - What's unclear: Is there a separate launchd job or manual step that triggers enrichment for new `inbox` status notes?
   - Recommendation: Check if enrichment is triggered separately. If not, add enrichment loop to scan-all.sh (for ALL sources, not just GoodLinks).

## Sources

### Primary (HIGH confidence)
- Live codebase inspection: `scan-all.sh`, `enrich-source.sh`, `goodlinks-query.py`, `ingest-goodlinks.sh`
- Live GoodLinks SQLite database: 15 URLs sampled for normalization analysis
- `~/.model-citizen/` directory structure and launchd plist

### Secondary (MEDIUM confidence)
- Python `urllib.parse` stdlib documentation (well-known, stable API)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — existing codebase fully inspected
- Architecture: HIGH — patterns derived from live running code
- Pitfalls: HIGH — based on actual code analysis, not theoretical

**Research date:** 2026-02-20
**Valid until:** 2026-03-20 (stable local infrastructure, no external dependencies)
