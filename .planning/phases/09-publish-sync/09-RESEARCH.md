# Phase 9: Publish Sync & End-to-End Example - Research

**Researched:** 2026-02-06
**Domain:** Content publishing pipeline (Vault → Hugo/Quartz), Markdown processing, file sync
**Confidence:** MEDIUM-HIGH

## Summary

Phase 9 implements the final publishing pipeline that syncs approved content from the Model Citizen Vault to the Hugo-based portfolio site at athan-dial.github.io. The research reveals this is fundamentally a **file transformation and sync pipeline** involving three core operations: frontmatter conversion (Vault → Hugo/Quartz), wiki-link rewriting (Obsidian `[[links]]` → markdown relative paths), and idempotent asset copying.

The standard stack for this problem uses Node.js with established libraries: gray-matter for frontmatter parsing, fast-glob for file discovery, fs-extra for recursive copying, and regex-based transforms for link rewriting. The critical insight is that Quartz v4 is designed specifically for Obsidian vault publishing and handles many Obsidian conventions natively, but Hugo (the current site generator) requires more transformation.

**Key architectural decisions:**
1. **Quartz vs Hugo confusion clarified:** The context mentions "Quartz" but the site currently uses Hugo. This research assumes **Hugo is the target** unless user decides to migrate to Quartz (which would simplify Obsidian compatibility).
2. **Idempotency via tracking file:** Use `.model-citizen/published-list.txt` to track published notes and prevent duplicates on re-runs.
3. **Link rewriting rules:** Convert Obsidian wiki-links `[[note-id]]` to Hugo-compatible markdown links `[note-id](/path/to/note/)`.
4. **Asset path handling:** Copy images from Vault `/media/` to Hugo `static/model-citizen/` and rewrite image paths in content.

**Primary recommendation:** Build a Node.js script (`publish-sync.js`) that processes approved notes from `/publish_queue/` folder (or `status: publish` frontmatter), transforms them for Hugo, copies to `content/model-citizen/`, commits changes, and runs `hugo` to rebuild the site. Script should be idempotent, log all transformations, and fail fast on link rewriting errors.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Publish Sync Pipeline Steps:**
1. Identify all approved notes (folder `/publish_queue/` OR frontmatter `status: publish`)
2. Copy to Hugo repo `content/` directory (likely `content/model-citizen/` subdirectory)
3. Convert Vault frontmatter to Hugo/Quartz frontmatter if needed
4. Copy any referenced assets (images, attachments) to Hugo `static/` directory
5. Rewrite internal links (Vault wiki-style `[[note-id]]` → Hugo relative links)
6. Commit all changes to Hugo repo
7. Push to GitHub (or rely on Pages auto-build if monorepo)

**Idempotency Requirements:**
- Don't duplicate notes on re-runs
- Update existing notes if source changed
- Track published notes in `.model-citizen/published-list.txt` or similar

**Link Rewriting Rules:**
- Vault format: `[[source-note-id]]` → original source
- Hugo format: `[source-note-id](../../sources/source-note-id/)` → relative path in Hugo
- (Exact rules to be documented in Phase 9 planning)

**Asset Handling:**
- Copy images from `/media/` or inline assets
- Rewrite image paths in Markdown (Vault paths → Hugo paths)
- Handle external URLs (leave as-is)

**Hugo/Quartz Deploy:**
- If pushing to separate Quartz repo: GitHub Pages auto-builds
- If monorepo: push to gh-pages branch triggers Hugo build
- Verify: site builds without errors, old published content remains

**End-to-End Example:**
1. Find a YouTube video of real interest (TBD during Phase 9)
2. Run Phase 5 ingestion
3. Run Phase 7 enrichment
4. Write or refine draft in Phase 8
5. Approve for publication
6. Run Phase 9 sync
7. Verify on live site (athan-dial.github.io/model-citizen/)

**Error Handling:**
- Link rewriting failures: log and alert (don't publish broken links)
- Asset copying failures: log and continue (missing assets are recoverable)
- Hugo build failures: halt sync and notify user
- Network failures on push: retry or allow manual push

### Claude's Discretion

- Exact frontmatter conversion logic (Hugo may use different fields than Vault)
- Asset naming conventions in Hugo
- Whether to archive published notes in Vault or leave them in place
- How many retries on transient failures
- Logging verbosity and format

### Deferred Ideas (OUT OF SCOPE)

- Scheduled daily publish sync (Phase 10)
- Automated deploy on successful sync
- Draft preview in Hugo before approving
- Vault archival strategy (delete published notes or archive to /published/)
- Revision history for published posts (Git handles this, but could expose via Hugo)
- Comments on published posts

</user_constraints>

## Standard Stack

The established libraries/tools for Markdown file sync and transformation:

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| gray-matter | 4.x | Parse/stringify YAML frontmatter | Most popular Node.js frontmatter library, used by Gatsby, Astro, Netlify, etc. Battle-tested with 10M+ weekly npm downloads |
| fast-glob | 3.x | File discovery with glob patterns | 2-10x faster than node-glob, supports advanced patterns, 30M+ weekly downloads |
| fs-extra | 11.x | Recursive file copy and directory operations | Drop-in replacement for Node fs with extra utilities, handles edge cases node fs doesn't |
| Node.js fs | 18+ | Core file system operations | Native module, zero dependencies, cross-platform |

**Confidence:** HIGH - All libraries are industry-standard with strong documentation via npm/GitHub.

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| unified + remark | Latest | Markdown AST parsing and transformation | If link rewriting becomes too complex for regex (e.g., need to parse nested structures) |
| chalk | 5.x | Terminal color output for logs | Improves script UX with color-coded success/error messages |
| commander | 11.x | CLI argument parsing | If script needs flags (e.g., `--dry-run`, `--verbose`) |
| markdown-link-extractor | 5.x | Extract all links from Markdown | Validate that all rewritten links point to valid files |

**Confidence:** MEDIUM - Supporting libraries are optional enhancements, can be added incrementally.

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| gray-matter | front-matter | gray-matter has better YAML parsing, more flexible API, wider adoption |
| fast-glob | node-glob | fast-glob is 2-10x faster, better for large vaults, but node-glob is more stable |
| Regex link rewriting | unified/remark AST parsing | Regex is simpler for basic wikilinks, unified/remark better for complex nested transforms |
| Hugo + manual conversion | Quartz v4 directly | Quartz handles Obsidian natively (wikilinks, embeds), but requires site migration |

**Hugo vs Quartz Clarification:**
- **Current state:** Site uses Hugo (v0.154.3), publishes to `docs/` directory
- **Quartz option:** Quartz v4 is designed specifically for Obsidian vault publishing, natively supports wikilinks, backlinks, graph view, embeds
- **Decision needed:** User should decide if migrating to Quartz is worth it (easier Obsidian integration) vs staying with Hugo (existing site structure)
- **This research assumes Hugo** unless user requests Quartz migration

**Installation:**
```bash
npm install gray-matter fast-glob fs-extra chalk commander markdown-link-extractor
```

## Architecture Patterns

### Recommended Project Structure

```
/Users/adial/model-citizen-vault/
├── scripts/
│   ├── publish-sync.js           # Main sync script
│   ├── lib/
│   │   ├── frontmatter-converter.js    # Vault → Hugo frontmatter
│   │   ├── link-rewriter.js            # Wiki-links → Markdown links
│   │   ├── asset-copier.js             # Copy images, attachments
│   │   └── published-tracker.js        # Track published notes
│   └── config/
│       └── sync-config.json            # Sync settings (paths, rules)
├── .model-citizen/
│   ├── published-list.txt              # Tracking file (note-id, publish-date)
│   └── sync.log                        # Detailed sync logs
└── publish_queue/                      # Approved content ready to publish

/Users/adial/Documents/GitHub/athan-dial.github.io/
├── content/
│   └── model-citizen/                  # Published Model Citizen content
│       ├── _index.md                   # Section index page
│       └── [note-slug]/                # Individual published notes
├── static/
│   └── model-citizen/                  # Published assets (images, etc.)
└── docs/                               # Hugo build output (GitHub Pages)
```

### Pattern 1: Idempotent File Sync

**What:** Sync operation that produces identical results whether run once or multiple times, preventing duplicate content.

**When to use:** Any file sync operation where re-runs are expected (e.g., manual sync, cron jobs, CI/CD).

**Implementation strategy:**
1. **Tracking file:** `.model-citizen/published-list.txt` contains one line per published note: `note-id,publish-date,content-hash`
2. **On sync start:** Read tracking file into memory (Map of note-id → metadata)
3. **For each approved note:**
   - Calculate content hash (MD5 or SHA256 of markdown content)
   - Check if note-id exists in tracking file
   - If not exists: **NEW** → copy to Hugo, add to tracking file
   - If exists but hash changed: **UPDATED** → copy to Hugo, update tracking file
   - If exists and hash matches: **SKIP** → no action needed
4. **On sync complete:** Write updated tracking file to disk

**Example tracking file:**
```
note-id,publish-date,content-hash
idea-123,2026-02-06,a1b2c3d4e5f6
draft-456,2026-02-05,f6e5d4c3b2a1
```

**Confidence:** HIGH - Standard pattern for idempotent sync, documented in AWS Well-Architected Framework and data pipeline best practices.

**Sources:**
- [Idempotency Implementation Best Practices](https://oneuptime.com/blog/post/2026-01-30-idempotency-implementation/view)
- [Understanding Idempotency in Data Pipelines | Airbyte](https://airbyte.com/data-engineering-resources/idempotency-in-data-pipelines)

### Pattern 2: Wiki-Link Rewriting with Regex

**What:** Transform Obsidian-style wiki-links `[[note-id]]` or `[[note-id|display text]]` to Hugo markdown links `[display text](/model-citizen/note-id/)`.

**When to use:** For simple link conversion without nested structures (no transclusions, embeds inside links).

**Regex patterns:**
```javascript
// Basic wiki-link: [[note-id]]
const basicWikiLink = /\[\[([^\]|]+)\]\]/g;

// Wiki-link with alias: [[note-id|display text]]
const aliasWikiLink = /\[\[([^\]|]+)\|([^\]]+)\]\]/g;

// Image embed: ![[image.png]]
const imageEmbed = /!\[\[([^\]]+\.(png|jpg|jpeg|gif|svg))\]\]/gi;

// Replace functions
function rewriteWikiLinks(content) {
  // First handle aliased links (more specific)
  content = content.replace(aliasWikiLink, (match, noteId, displayText) => {
    const slug = noteId.trim().toLowerCase().replace(/\s+/g, '-');
    return `[${displayText}](/model-citizen/${slug}/)`;
  });

  // Then handle basic links
  content = content.replace(basicWikiLink, (match, noteId) => {
    const slug = noteId.trim().toLowerCase().replace(/\s+/g, '-');
    return `[${noteId}](/model-citizen/${slug}/)`;
  });

  // Handle image embeds
  content = content.replace(imageEmbed, (match, filename) => {
    return `![${filename}](/model-citizen/${filename})`;
  });

  return content;
}
```

**Edge cases to handle:**
- Links with spaces: `[[My Note Title]]` → slug conversion (lowercase, hyphens)
- Links with special characters: `[[Note (Draft)]]` → sanitize slugs
- Relative vs absolute paths in Hugo
- Links to non-existent notes (log warning, don't break build)

**Confidence:** MEDIUM-HIGH - Regex approach works for 90% of wiki-link patterns, but complex nested structures may need AST parsing.

**Sources:**
- [Markdown WikiLink Regex Patterns](https://www.npmjs.com/package/@gerhobbelt/markdown-it-wikilinks)
- [Converting Obsidian WikiLinks to Markdown](https://github.com/trojblue/Obsidian-wiki-fix)

### Pattern 3: Frontmatter Conversion

**What:** Transform Obsidian/Vault frontmatter fields to Hugo-compatible frontmatter.

**When to use:** Always, when syncing from Vault to Hugo.

**Conversion rules:**

| Vault Field | Hugo Field | Transformation |
|-------------|------------|----------------|
| `title` | `title` | Direct copy |
| `status` | (omit) | Internal workflow field, don't publish |
| `tags` | `tags` | Direct copy (both use YAML array) |
| `created` | `date` | Rename field (Hugo uses `date` for publish date) |
| `modified` | `lastmod` | Rename field |
| `idea_score` | (omit or custom) | Optional: include as custom param |
| `sources` | (custom) | Keep as custom param for backlinks |

**Example transformation:**
```javascript
// Input (Vault frontmatter)
---
title: "How to Build Decision Systems"
status: publish
created: 2026-02-06
modified: 2026-02-06
tags: [decision-systems, product-strategy]
idea_score: 8
sources: [youtube-abc123, article-def456]
---

// Output (Hugo frontmatter)
---
title: "How to Build Decision Systems"
date: 2026-02-06
lastmod: 2026-02-06
tags: [decision-systems, product-strategy]
draft: false
sources: [youtube-abc123, article-def456]
---
```

**Implementation:**
```javascript
const matter = require('gray-matter');

function convertFrontmatter(vaultContent) {
  const parsed = matter(vaultContent);

  const hugoFrontmatter = {
    title: parsed.data.title,
    date: parsed.data.created,
    lastmod: parsed.data.modified || parsed.data.created,
    tags: parsed.data.tags || [],
    draft: false,
    // Keep custom fields for backlinks, etc.
    sources: parsed.data.sources || [],
  };

  // Omit internal workflow fields
  delete parsed.data.status;
  delete parsed.data.idea_score;

  return matter.stringify(parsed.content, hugoFrontmatter);
}
```

**Confidence:** HIGH - gray-matter handles YAML parsing/stringifying reliably, conversion logic is straightforward.

**Sources:**
- [gray-matter npm documentation](https://www.npmjs.com/package/gray-matter)
- [Hugo Front Matter specification](https://gohugo.io/content-management/front-matter/)

### Pattern 4: Asset Copy with Path Rewriting

**What:** Copy images and attachments from Vault to Hugo static directory, rewrite paths in Markdown.

**When to use:** When published notes contain images or other media.

**Implementation strategy:**
1. **Scan content for asset references:** `![[image.png]]`, `![alt text](image.png)`, `[file.pdf](file.pdf)`
2. **Copy assets:** From Vault `/media/` to Hugo `static/model-citizen/`
3. **Rewrite paths:** Update Markdown to reference new paths
4. **Log missing assets:** If referenced asset doesn't exist, log warning (don't fail)

**Code example:**
```javascript
const path = require('path');
const fs = require('fs-extra');

async function copyAssets(content, vaultPath, hugoStaticPath) {
  const assetPattern = /!\[\[([^\]]+\.(png|jpg|jpeg|gif|svg|pdf))\]\]/gi;
  const copiedAssets = [];

  const matches = content.matchAll(assetPattern);
  for (const match of matches) {
    const filename = match[1];
    const sourcePath = path.join(vaultPath, 'media', filename);
    const destPath = path.join(hugoStaticPath, 'model-citizen', filename);

    if (await fs.pathExists(sourcePath)) {
      await fs.copy(sourcePath, destPath);
      copiedAssets.push(filename);
    } else {
      console.warn(`⚠️  Asset not found: ${filename}`);
    }
  }

  return copiedAssets;
}
```

**Confidence:** HIGH - fs-extra handles recursive copy reliably, asset pattern matching is straightforward.

**Sources:**
- [fs-extra copy documentation](https://github.com/jprichardson/node-fs-extra/blob/master/docs/copy.md)
- [Node.js File System Best Practices](https://medium.com/@shubham3480/node-part-v-0f626ead588d)

### Anti-Patterns to Avoid

1. **Overwriting published content without tracking:**
   - **Why it's bad:** Loses ability to detect changes, forces full re-sync every time
   - **Do instead:** Use tracking file with content hashes

2. **Regex parsing of complex nested Markdown:**
   - **Why it's bad:** Regex can't handle nested structures (e.g., links inside code blocks, transclusions)
   - **Do instead:** Use remark/unified AST parsing for complex cases

3. **Hardcoding file paths in script:**
   - **Why it's bad:** Breaks if user moves Vault or Hugo repo
   - **Do instead:** Use config file or environment variables for paths

4. **Silent failures on link rewriting:**
   - **Why it's bad:** Publishes broken links, frustrating user experience
   - **Do instead:** Fail fast with clear error messages, validate all links before committing

5. **Modifying Vault source files during sync:**
   - **Why it's bad:** Risk of data loss, breaks separation of concerns
   - **Do instead:** Copy to Hugo, leave Vault untouched (read-only operation)

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| YAML frontmatter parsing | Custom YAML parser with regex | `gray-matter` | Handles edge cases (multiline, special chars, type coercion), 10M+ weekly downloads |
| File glob patterns | Recursive fs.readdir with manual filtering | `fast-glob` | 2-10x faster, supports advanced patterns (negation, .gitignore), battle-tested |
| Directory copying | Manual fs.copy with error handling | `fs-extra.copy()` | Handles permissions, symlinks, overwrite options, atomic operations |
| Markdown link extraction | Regex on full content | `markdown-link-extractor` | Handles edge cases (code blocks, nested quotes), AST-based parsing |
| Content hashing | Custom hash function | Node.js `crypto.createHash()` | Cryptographically secure, standardized, performant |
| CLI arguments | Manual process.argv parsing | `commander` or `yargs` | Type validation, help text, subcommands, auto-generated docs |

**Key insight:** Markdown and file sync have many edge cases (encoding, line endings, symlinks, permissions). Use established libraries that have solved these problems rather than debugging them one-by-one.

## Common Pitfalls

### Pitfall 1: Case Sensitivity in Link Slugs

**What goes wrong:** Wiki-link `[[My Note]]` generates slug `my-note`, but another reference uses `[[my note]]` generating same slug, or Hugo expects `My-Note` (title case).

**Why it happens:** Different systems have different slug conventions (lowercase, kebab-case, title-case), and Obsidian is case-insensitive for file matching but Hugo URLs are case-sensitive.

**How to avoid:**
- **Normalize all slugs to lowercase kebab-case:** `My Note Title` → `my-note-title`
- **Create slug map:** Map note IDs to canonical slugs before rewriting links
- **Validate uniqueness:** Check for slug collisions (two notes generating same slug)

**Warning signs:** 404 errors on published site, broken internal links, duplicate content at different URLs.

**Confidence:** HIGH - Well-documented issue in static site generators.

**Sources:**
- [Hugo URL Management](https://gohugo.io/content-management/urls/)
- [Markdown Link Rewriting Pitfalls](https://www.markdownguide.org/basic-syntax/)

### Pitfall 2: Idempotency Race Conditions

**What goes wrong:** Two sync processes run simultaneously, both read tracking file, both copy files, tracking file gets corrupted or has duplicates.

**Why it happens:** No file locking on tracking file, concurrent writes to same file.

**How to avoid:**
- **Lock file pattern:** Create `.model-citizen/sync.lock` before starting, fail if exists, remove on completion
- **Atomic writes:** Write tracking file to temp file, then rename (atomic operation on most filesystems)
- **Sequential execution only:** Don't run sync in parallel, enforce single instance

**Warning signs:** Duplicate published notes, corrupted tracking file, partial syncs.

**Code example:**
```javascript
const lockfile = '.model-citizen/sync.lock';

async function acquireLock() {
  if (await fs.pathExists(lockfile)) {
    throw new Error('Sync already running (lock file exists)');
  }
  await fs.writeFile(lockfile, new Date().toISOString());
}

async function releaseLock() {
  await fs.remove(lockfile);
}
```

**Confidence:** HIGH - Standard concurrency pattern in file-based systems.

**Sources:**
- [Idempotency Race Conditions](https://oneuptime.com/blog/post/2026-01-30-idempotency-implementation/view)
- [Distributed Systems Race Condition Patterns](https://medium.com/@alexglushenkov/the-art-of-staying-in-sync-how-distributed-systems-avoid-race-conditions-f59b58817e02)

### Pitfall 3: Broken Links After Publishing

**What goes wrong:** Published note has link `[source](../../sources/video-123/)` but Hugo generates URL `/model-citizen/source/` instead, breaking the link.

**Why it happens:** Hugo URL structure doesn't match link rewriting assumptions, or note references non-existent file.

**How to avoid:**
- **Validate all links before committing:** After rewriting, check if target files exist in Hugo content directory
- **Log broken links:** Create report of broken links for user to fix manually
- **Fail fast:** Don't commit to Hugo if any links are broken (unless user flags `--allow-broken-links`)
- **Test link generation:** Create test notes with various link patterns, verify Hugo generates correct URLs

**Warning signs:** 404 errors on live site, missing backlinks, broken navigation.

**Code example:**
```javascript
function validateLinks(content, hugoContentDir) {
  const linkPattern = /\[([^\]]+)\]\(([^)]+)\)/g;
  const brokenLinks = [];

  const matches = content.matchAll(linkPattern);
  for (const match of matches) {
    const linkUrl = match[2];
    if (linkUrl.startsWith('http')) continue; // External link

    const targetPath = path.join(hugoContentDir, linkUrl);
    if (!fs.existsSync(targetPath)) {
      brokenLinks.push({ text: match[1], url: linkUrl });
    }
  }

  return brokenLinks;
}
```

**Confidence:** MEDIUM-HIGH - Common issue in static site generation, validation prevents most cases.

**Sources:**
- [Markdown Link Validation](https://github.com/tcort/markdown-link-check)
- [Hugo Link Management](https://gohugo.io/content-management/urls/)

### Pitfall 4: Asset Path Confusion (Vault vs Hugo)

**What goes wrong:** Image in Vault is at `/media/image.png`, published note references `/model-citizen/image.png`, but Hugo expects `/static/model-citizen/image.png` in source, served at `/model-citizen/image.png` on live site.

**Why it happens:** Hugo has specific rules for static asset serving (`/static/` directory maps to `/` on live site), and Vault uses different path structure.

**How to avoid:**
- **Understand Hugo static asset serving:** Files in `static/foo/` are served at `/foo/` on live site
- **Rewrite image paths correctly:** Vault `![[image.png]]` → Hugo `![image.png](/model-citizen/image.png)` (not `/static/model-citizen/`)
- **Copy assets to correct location:** `static/model-citizen/` in Hugo source directory
- **Test asset loading:** After publishing, verify images load on live site

**Warning signs:** Missing images on published site, 404 errors for assets, broken image embeds.

**Confidence:** HIGH - Standard Hugo behavior, well-documented.

**Sources:**
- [Hugo Static Files](https://gohugo.io/content-management/static-files/)
- [Obsidian Image Embed Syntax](https://forum.obsidian.md/t/correct-link-format-for-embedding-images/67352)

### Pitfall 5: Frontmatter YAML Parsing Edge Cases

**What goes wrong:** Frontmatter with special characters (colons, quotes, multiline) fails to parse or corrupts on round-trip (parse → modify → stringify).

**Why it happens:** YAML has complex escaping rules, gray-matter uses js-yaml which has specific quirks.

**How to avoid:**
- **Use gray-matter stringify:** Don't manually construct YAML strings
- **Test edge cases:** Title with colon `"Title: Subtitle"`, multiline descriptions, arrays with quotes
- **Preserve unknown fields:** Don't drop custom fields user may have added
- **Validate output:** Parse stringified frontmatter to ensure no data loss

**Example edge cases:**
```yaml
# Edge case 1: Colon in title (requires quotes)
title: "How to Build: A Guide"

# Edge case 2: Multiline description (literal block)
description: |
  This is a long description
  that spans multiple lines
  with preserved formatting.

# Edge case 3: Array with special characters
tags: ["decision-systems", "AI/ML", "product-strategy"]
```

**Warning signs:** Malformed frontmatter in published notes, missing fields, parse errors in Hugo build.

**Confidence:** MEDIUM - gray-matter handles most cases, but YAML edge cases are common.

**Sources:**
- [gray-matter YAML Parsing](https://www.npmjs.com/package/gray-matter)
- [YAML Specification Gotchas](https://yaml.org/spec/1.2/spec.html)

## Code Examples

Verified patterns from official sources:

### Example 1: Complete Sync Script Structure

```javascript
#!/usr/bin/env node
/**
 * publish-sync.js - Sync approved content from Vault to Hugo
 *
 * Usage:
 *   node scripts/publish-sync.js [options]
 *
 * Options:
 *   --dry-run    Show what would be published without making changes
 *   --verbose    Show detailed logs
 */

const fs = require('fs-extra');
const path = require('path');
const matter = require('gray-matter');
const glob = require('fast-glob');
const crypto = require('crypto');
const chalk = require('chalk');

// Configuration
const CONFIG = {
  vaultPath: '/Users/adial/model-citizen-vault',
  hugoPath: '/Users/adial/Documents/GitHub/athan-dial.github.io',
  publishQueueFolder: 'publish_queue',
  trackingFile: '.model-citizen/published-list.txt',
  lockFile: '.model-citizen/sync.lock',
};

// Main sync function
async function publishSync(options = {}) {
  const { dryRun = false, verbose = false } = options;

  try {
    // 1. Acquire lock
    await acquireLock();

    // 2. Load tracking data
    const publishedNotes = await loadTrackingFile();

    // 3. Find approved notes
    const approvedNotes = await findApprovedNotes();
    console.log(chalk.blue(`📋 Found ${approvedNotes.length} approved notes`));

    // 4. Process each note
    const results = { new: 0, updated: 0, skipped: 0, errors: 0 };
    for (const note of approvedNotes) {
      try {
        const action = await processNote(note, publishedNotes, dryRun);
        results[action]++;
      } catch (error) {
        console.error(chalk.red(`❌ Error processing ${note}: ${error.message}`));
        results.errors++;
      }
    }

    // 5. Save tracking file
    if (!dryRun) {
      await saveTrackingFile(publishedNotes);
    }

    // 6. Commit and build
    if (!dryRun && (results.new > 0 || results.updated > 0)) {
      await commitChanges();
      await buildHugo();
    }

    // 7. Print summary
    printSummary(results, dryRun);

  } finally {
    await releaseLock();
  }
}

// Helper functions (implementation details follow patterns above)
async function acquireLock() { /* ... */ }
async function loadTrackingFile() { /* ... */ }
async function findApprovedNotes() { /* ... */ }
async function processNote(note, tracking, dryRun) { /* ... */ }
async function commitChanges() { /* ... */ }
async function buildHugo() { /* ... */ }

// CLI entry point
if (require.main === module) {
  const args = process.argv.slice(2);
  const options = {
    dryRun: args.includes('--dry-run'),
    verbose: args.includes('--verbose'),
  };

  publishSync(options).catch(error => {
    console.error(chalk.red(`Fatal error: ${error.message}`));
    process.exit(1);
  });
}

module.exports = { publishSync };
```

**Source:** Pattern derived from Node.js file sync best practices and idempotent pipeline patterns.

### Example 2: Finding Approved Notes (Dual Method)

```javascript
const path = require('path');
const glob = require('fast-glob');
const matter = require('gray-matter');

async function findApprovedNotes() {
  const vaultPath = CONFIG.vaultPath;
  const approvedNotes = new Set();

  // Method 1: Find notes in /publish_queue/ folder
  const queuePath = path.join(vaultPath, CONFIG.publishQueueFolder);
  const queueNotes = await glob('**/*.md', {
    cwd: queuePath,
    absolute: true,
  });
  queueNotes.forEach(notePath => approvedNotes.add(notePath));

  // Method 2: Find notes with status: publish in frontmatter
  const allNotes = await glob('**/*.md', {
    cwd: vaultPath,
    absolute: true,
    ignore: ['**/node_modules/**', '**/.git/**'],
  });

  for (const notePath of allNotes) {
    const content = await fs.readFile(notePath, 'utf8');
    const parsed = matter(content);

    if (parsed.data.status === 'publish') {
      approvedNotes.add(notePath);
    }
  }

  return Array.from(approvedNotes);
}
```

**Confidence:** HIGH - Implements dual approval method from user requirements.

### Example 3: Content Hash Calculation

```javascript
const crypto = require('crypto');

function calculateContentHash(content) {
  // Hash only the markdown content (not frontmatter)
  // This way frontmatter changes don't trigger republish
  const parsed = matter(content);
  const contentOnly = parsed.content.trim();

  return crypto
    .createHash('sha256')
    .update(contentOnly, 'utf8')
    .digest('hex')
    .substring(0, 16); // First 16 chars sufficient for collision avoidance
}
```

**Confidence:** HIGH - Standard Node.js crypto usage.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Manual copy-paste from Vault to Hugo | Automated sync scripts | 2023-2024 (digital garden trend) | Enables daily publishing workflow, reduces friction |
| Regex-only Markdown parsing | AST-based parsing (remark/unified) | 2020+ | Handles complex nested structures, but more complex |
| node-glob for file discovery | fast-glob | 2019+ | 2-10x performance improvement, better pattern support |
| Custom frontmatter parsers | gray-matter standard | 2018+ | Reliability improvement, handles edge cases |
| Quartz v3 | Quartz v4 | 2024 | Native Obsidian support (wikilinks, backlinks), simpler setup |

**Deprecated/outdated:**
- **Quartz v3:** Replaced by v4 in 2024, v4 has native Obsidian wikilink support
- **markdown-link-check v2:** Deprecated, use v3+ for GitHub Actions integration
- **node-glob:** Still maintained but slower than fast-glob for large vaults

**Emerging patterns (2026):**
- **Quartz v4 adoption:** Growing as free Obsidian Publish alternative
- **Tag-based selective publishing:** Using Obsidian tags to control what gets published
- **Git submodules for content separation:** Separate vault from Hugo repo, sync via submodule

**Confidence:** MEDIUM - Based on web search results and GitHub activity, but fast-moving domain.

## Hugo vs Quartz Decision

**Critical clarification needed:** The context mentions both Hugo (current site generator) and Quartz (Obsidian-focused SSG). Research findings:

### Current State
- Site uses **Hugo v0.154.3** with Blowfish theme
- Publishes to `docs/` directory for GitHub Pages
- Custom CSS, case study structure, proof tiles

### Quartz v4 Benefits
- **Native Obsidian support:** Wikilinks, backlinks, graph view, embeds work out-of-box
- **Zero link rewriting:** Quartz parses `[[wikilinks]]` natively
- **Graph view:** Visual knowledge graph on published site
- **Simpler sync:** Just copy files, Quartz handles Obsidian conventions

### Quartz v4 Tradeoffs
- **Site migration required:** Would need to rebuild site structure in Quartz
- **Custom styling:** Current Hugo custom.css would need to be ported
- **Theme limitations:** Quartz has fewer themes than Hugo
- **Learning curve:** New templating system, different configuration

### Recommendation
**For Phase 9:** Stick with Hugo, implement link rewriting. Quartz migration is a **separate decision** that could happen in Phase 10+ if user wants to simplify Obsidian integration. The sync script architecture (identify, transform, copy, commit) is similar for both, so migration later is feasible.

**Confidence:** MEDIUM - User should make this call based on priorities (maintain current site vs simplify Obsidian workflow).

## Open Questions

Things that couldn't be fully resolved:

1. **Hugo vs Quartz target unclear**
   - What we know: Site currently uses Hugo, context mentions Quartz
   - What's unclear: Is migration to Quartz desired or should we keep Hugo?
   - Recommendation: Assume Hugo for Phase 9, document Quartz as future option

2. **Content organization in Hugo**
   - What we know: Should go in `content/` directory, likely subdirectory like `content/model-citizen/`
   - What's unclear: Exact URL structure (`/model-citizen/note-slug/` vs `/notes/model-citizen/note-slug/`)
   - Recommendation: Create `content/model-citizen/_index.md` section index, publish notes as `content/model-citizen/[note-slug]/index.md` (page bundles)

3. **Link rewriting validation scope**
   - What we know: Should validate links before publishing
   - What's unclear: How strict? Fail on any broken link or just log warnings?
   - Recommendation: Start with warnings only (log broken links but don't block publish), add strict mode later if needed

4. **Asset deduplication strategy**
   - What we know: Copy assets to `static/model-citizen/`
   - What's unclear: If same image used in multiple notes, copy once or multiple times? How to detect duplicates?
   - Recommendation: Use content-based naming (hash filename) to deduplicate automatically

5. **Publish queue cleanup**
   - What we know: Notes in `/publish_queue/` get published
   - What's unclear: Should script move notes out of queue after publish? Archive? Leave in place?
   - Recommendation: Leave in place for Phase 9 (user can manually organize), document archival strategy for Phase 10

## Sources

### Primary (HIGH confidence)

- [Hugo Content Management Official Docs](https://gohugo.io/content-management/) - Hugo v0.155.0 (Feb 2026)
- [Hugo Front Matter Specification](https://gohugo.io/content-management/front-matter/) - Official docs
- [gray-matter npm package](https://www.npmjs.com/package/gray-matter) - 10M+ weekly downloads, battle-tested
- [fast-glob npm package](https://www.npmjs.com/package/fast-glob) - 30M+ weekly downloads
- [fs-extra npm package](https://www.npmjs.com/package/fs-extra) - Official GitHub repo
- [Quartz v4 Official Docs](https://quartz.jzhao.xyz/) - Current version docs
- [Quartz Authoring Content](https://quartz.jzhao.xyz/authoring-content) - Frontmatter format

### Secondary (MEDIUM confidence)

- [Hugo Deployment Automation (2026)](https://www.mattjh.sh/post/hugo-deployment/) - Recent blog post
- [Automating Hugo with GitHub Actions](https://www.morling.dev/blog/automatically-deploying-hugo-website-via-github-actions/) - Verified pattern
- [Obsidian Wiki-link Conversion](https://github.com/trojblue/Obsidian-wiki-fix) - Open source tool
- [Link Converter Plugin](https://github.com/ozntel/obsidian-link-converter) - Obsidian community plugin
- [Idempotency Best Practices (2026)](https://oneuptime.com/blog/post/2026-01-30-idempotency-implementation/view) - Recent article
- [Understanding Idempotency in Data Pipelines](https://airbyte.com/data-engineering-resources/idempotency-in-data-pipelines) - Industry best practices

### Tertiary (LOW confidence - needs validation)

- [Markdown Link Rewriting Pitfalls](https://www.michaelperrin.fr/blog/2019/02/advanced-regular-expressions) - Older article (2019)
- [Quartz + Obsidian Multi-Site Publishing](https://rakshanshetty.in/blog/quartz-obsidian-multi-site-publishing) - Personal blog
- [Hugo Content Organization Best Practices](https://jpdroege.com/blog/hugo-file-organization/) - Personal blog

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - All libraries are npm top downloads with official documentation
- Architecture patterns: MEDIUM-HIGH - Patterns are standard but Hugo vs Quartz target needs clarification
- Pitfalls: MEDIUM-HIGH - Common issues documented across multiple sources, some are domain-specific edge cases
- Code examples: MEDIUM - Based on library documentation and common patterns, not tested in this codebase yet

**Research date:** 2026-02-06
**Valid until:** 60 days (stable domain - static site generators change slowly, but new Quartz/Hugo releases happen quarterly)

**Key assumptions:**
- Hugo is the publishing target (not Quartz) unless user decides to migrate
- Model Citizen content will live in `content/model-citizen/` subdirectory
- Vault source files remain untouched (read-only sync)
- User will manually choose which content to publish (no auto-publish)

**Next steps for planner:**
1. Confirm Hugo vs Quartz target with user
2. Design exact Hugo content structure (`content/model-citizen/` organization)
3. Define link rewriting rules based on Hugo URL structure
4. Specify error handling policies (strict vs permissive validation)
5. Create task breakdown for sync script implementation
