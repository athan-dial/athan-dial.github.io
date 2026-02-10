# Phase 10: Content Ingestion - Research

**Researched:** 2026-02-10
**Domain:** Multi-source content ingestion, API integration, scheduling automation
**Confidence:** MEDIUM-HIGH

## Summary

This phase requires building a multi-source content ingestion system that captures web articles, YouTube videos, Slack saved items/DMs, and Outlook emails into an Obsidian vault. The technical domain spans five major areas: web scraping and article extraction, macOS/iOS capture automation, third-party API integration (Slack, Microsoft Graph), scheduled task execution, and deduplication/normalization.

The standard stack centers on @mozilla/readability for article extraction, native macOS Shortcuts app for share sheet integration, official SDKs for Slack and Microsoft Graph, launchd for scheduled execution, and file-based queuing for batch processing. This is a well-trodden domain with mature libraries, though API authentication complexity and rate limiting require careful handling.

The primary architectural challenge is maintaining a clean separation between capture (queue population), scanning (API pulls), and enrichment (Phase 7 pipeline). The user's decision to track source types via frontmatter rather than folder structure simplifies normalization and keeps the enrichment pipeline generic.

**Primary recommendation:** Build separate Node.js scripts for each source type (web-capture, slack-scan, outlook-scan), unified by a shared queue directory and deduplication layer. Use launchd for daily scheduling, Shortcuts for manual capture, and implement scan as a Claude Code slash command via .claude/commands/.

## User Constraints (from CONTEXT.md)

<user_constraints>

### Locked Decisions

#### Content Sources
- **YouTube videos** — already working from Phase 5; extend or keep as-is
- **Web articles/blogs** — full text extraction + original URL preserved as vault note
- **Slack** — saved items + DMs from boss; extract URLs AND surrounding context ("read this because...")
- **Outlook (M365 work)** — boss's emails with links; capture URL + commentary context
- **Read-later app** — currently uses GoodLinks (macOS + iOS); open to researcher recommending better alternatives or replacing with direct vault capture. Criteria: free or one-time purchase, macOS + iOS

#### Capture Workflow
- **Primary gesture:** Share sheet / keyboard shortcut — instant capture from any app (browser, iOS)
- **Share sheet behavior:** Adds to a queue (not instant ingest); next scan/batch processes the queue
- **Optional quick note** at capture time — one-liner like "boss recommended" or "for Model Citizen idea" but not required
- **Slack/Outlook scan mode:** On-demand pull that grabs recently delivered materials with links
  - Slack: scan saved items + DMs from boss
  - Outlook: scan boss's emails for links
- **Scan as Claude skill** — user wants this invocable as a Claude Code skill (e.g., `/scan`)

#### Normalization Rules
- **Article content:** Full text extraction into markdown note + original URL preserved (Reader-mode style)
- **Source type tracking:** Frontmatter field `source_type: article|youtube|slack|email` (not subfolders)
- **All sources → enrichment pipeline:** Same Phase 7 pipeline (summarize, tag, generate ideas) regardless of source type
- **Dedup behavior:** If same URL arrives from multiple sources, merge context into existing note (append "also shared by boss via email") rather than skipping or creating duplicate

#### Trigger & Scheduling
- **Daily auto-scan:** Scheduled scan of Slack saved items, boss DMs, and Outlook emails
- **Manual trigger:** Also invocable on-demand (Claude skill or CLI)
- **Scan timing:** Claude's discretion (reasonable default)

### Claude's Discretion
- Whether scan + enrichment runs as single pipeline or separate steps
- Daily scan timing
- Share sheet technical implementation (Shortcuts app, bookmarklet, etc.)
- Read-later app recommendation (keep GoodLinks, switch, or eliminate aggregator)
- Queue mechanism for share sheet captures

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope

</user_constraints>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| @mozilla/readability | 0.5.0+ | Web article extraction | Same algorithm as Firefox Reader View; industry standard for clean article content extraction with title, author, byline, excerpt |
| jsdom | 25.0+ | HTML parsing for Readability | Required companion to @mozilla/readability; provides DOM API in Node.js |
| @slack/web-api | 7.0+ | Slack API client | Official Slack SDK for Node.js; supports bookmarks, conversations, and authentication |
| @microsoft/microsoft-graph-client | 3.0+ | Microsoft Graph API client | Official Microsoft SDK for accessing Outlook emails via Graph API |
| @azure/msal-node | 2.0+ | Microsoft authentication | Required for OAuth 2.0 authentication to Microsoft Graph; confidential client application pattern |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| turndown | 7.2+ | HTML to Markdown conversion | Alternative to using Readability's HTML output directly; provides cleaner markdown with configurable rules |
| node-html-markdown | 2.0+ | HTML to Markdown (faster) | Alternative to turndown; 37% faster on large documents; use if performance issues arise |
| gray-matter | 4.0+ | Frontmatter parsing/writing | Standard library for YAML frontmatter manipulation in markdown files |
| dotenv | 16.0+ | Environment variable management | Secure storage of API tokens, client secrets, and configuration |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| GoodLinks (current) | Direct vault capture | Eliminates intermediary app; reduces friction. Tradeoff: lose GoodLinks' iOS reading experience and cross-device sync. **Recommend keeping GoodLinks** for its privacy-first design and one-time $9.99 purchase model. |
| file-based queue | Redis/Bull | Redis offers better performance and distributed queue features. Tradeoff: adds infrastructure dependency. File-based sufficient for single-user daily batches. |
| launchd | node-cron | node-cron keeps scheduling logic in Node.js code. Tradeoff: requires Node process always running; launchd is macOS-native and more reliable for daemon-style tasks. |

**Installation:**
```bash
npm install @mozilla/readability jsdom @slack/web-api @microsoft/microsoft-graph-client @azure/msal-node
npm install turndown gray-matter dotenv
```

## Architecture Patterns

### Recommended Project Structure
```
model-citizen/
├── ingest/
│   ├── sources/
│   │   ├── web-capture.js       # Readability-based article extraction
│   │   ├── slack-scan.js        # Slack bookmarks + boss DMs
│   │   ├── outlook-scan.js      # Outlook emails with links
│   │   └── youtube-extend.js    # Extend Phase 5 YouTube ingest
│   ├── shared/
│   │   ├── queue.js             # Queue directory operations
│   │   ├── dedup.js             # URL-based deduplication logic
│   │   ├── normalize.js         # Frontmatter + markdown generation
│   │   └── vault-writer.js      # Write to vault with dedup check
│   ├── scan.js                  # Main orchestrator: process queue + scan APIs
│   └── config.js                # API tokens, boss user IDs, vault paths
├── .queue/                      # Staging area for captured items
│   ├── web-{timestamp}.json
│   ├── slack-{timestamp}.json
│   └── outlook-{timestamp}.json
├── .env                         # Secrets: SLACK_TOKEN, MS_CLIENT_ID, etc.
└── package.json
```

### Pattern 1: Queue-Based Capture
**What:** Share sheet and manual captures write JSON files to `.queue/` directory; scan process reads and processes them in batch.

**When to use:** Separates capture (instant, no API calls) from processing (batched, rate-limited). Ensures capture never blocks on slow operations.

**Example:**
```javascript
// sources/web-capture.js - called by Shortcuts
import fs from 'fs/promises';
import { QUEUE_DIR } from '../config.js';

export async function captureURL(url, note = '') {
  const queueItem = {
    type: 'web',
    url,
    note,
    timestamp: new Date().toISOString(),
    processed: false
  };

  const filename = `web-${Date.now()}.json`;
  await fs.writeFile(
    `${QUEUE_DIR}/${filename}`,
    JSON.stringify(queueItem, null, 2)
  );
}
```

### Pattern 2: Source-Specific Scanners
**What:** Each content source (Slack, Outlook, web queue) has dedicated scanner with its own API client and error handling.

**When to use:** APIs have different authentication, rate limits, and data structures. Separation prevents cascading failures.

**Example:**
```javascript
// sources/slack-scan.js
import { WebClient } from '@slack/web-api';

export async function scanSlackSources(config) {
  const client = new WebClient(config.slackToken);

  // Scan bookmarks (saved items)
  const bookmarks = await client.bookmarks.list({
    channel_id: config.slackChannelId
  });

  // Scan DMs from boss
  const dms = await client.conversations.history({
    channel: config.bossDmId,
    oldest: config.lastScanTimestamp
  });

  return [...extractLinksFromBookmarks(bookmarks), ...extractLinksFromDms(dms)];
}
```

### Pattern 3: Deduplication by URL Hash
**What:** Generate SHA-256 hash of normalized URL; check if hash exists in vault frontmatter before creating new note.

**When to use:** Same content arrives from multiple sources (e.g., boss sends via Slack AND email). Append provenance rather than duplicate.

**Example:**
```javascript
// shared/dedup.js
import crypto from 'crypto';
import matter from 'gray-matter';

export function normalizeURL(url) {
  // Remove fragments, normalize protocol, strip tracking params
  const parsed = new URL(url);
  parsed.hash = '';
  ['utm_source', 'utm_medium', 'utm_campaign'].forEach(p => parsed.searchParams.delete(p));
  return parsed.toString();
}

export function urlHash(url) {
  return crypto.createHash('sha256').update(normalizeURL(url)).digest('hex').slice(0, 16);
}

export async function findExistingNote(vaultPath, url) {
  const hash = urlHash(url);
  const files = await glob(`${vaultPath}/**/*.md`);

  for (const file of files) {
    const content = await fs.readFile(file, 'utf8');
    const { data } = matter(content);
    if (data.url_hash === hash) {
      return { file, frontmatter: data };
    }
  }
  return null;
}
```

### Pattern 4: Shared Enrichment Pipeline
**What:** All sources produce normalized markdown with consistent frontmatter structure; Phase 7 enrichment doesn't care about source type.

**When to use:** Keeps enrichment logic generic and prevents special-casing. source_type field provides metadata without affecting workflow.

**Example:**
```javascript
// shared/normalize.js
export function createMarkdownNote(extracted, metadata) {
  return matter.stringify(extracted.textContent || extracted.content, {
    title: extracted.title,
    url: metadata.url,
    url_hash: urlHash(metadata.url),
    source_type: metadata.sourceType,  // 'article' | 'youtube' | 'slack' | 'email'
    captured_at: new Date().toISOString(),
    provenance: metadata.provenance,    // e.g., "boss via Slack DM"
    status: 'captured'                   // Phase 7 changes to 'enriched'
  });
}
```

### Pattern 5: Reusable JSDOM Instance
**What:** Create single JSDOM instance, update innerHTML for each article; prevents memory leaks from repeated instantiation.

**When to use:** Processing multiple articles in batch (daily scan). JSDOM has documented memory leak issues when creating new instances repeatedly.

**Example:**
```javascript
// sources/web-capture.js
import { JSDOM } from 'jsdom';
import { Readability } from '@mozilla/readability';

let dom = null;

export async function extractArticle(html, url) {
  if (!dom) {
    dom = new JSDOM('<html><body></body></html>', { url });
  }

  dom.window.document.body.innerHTML = html;
  const reader = new Readability(dom.window.document);
  const article = reader.parse();

  return article;
}
```

### Anti-Patterns to Avoid
- **Polling APIs continuously:** Use launchd daily schedule instead of constant background process; reduces rate limit risk and battery usage
- **Hardcoding user IDs:** Boss's Slack/email user ID should be in config, not code; enables reuse and testing
- **Instant enrichment on capture:** Capture should be fast (write to queue); enrichment can happen later in batch
- **Skipping duplicates silently:** Log and merge provenance; user wants to know content arrived from multiple sources

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Article extraction from HTML | Custom HTML parser with heuristics for article detection | @mozilla/readability | Mozilla's Reader View algorithm has years of refinement for handling edge cases (paywalls, galleries, multi-page articles, ad removal). 5000+ GitHub stars, battle-tested on millions of sites. |
| OAuth 2.0 flow for Microsoft Graph | Custom token refresh logic with fetch() | @azure/msal-node | Microsoft's official library handles token caching, automatic refresh, certificate credentials, and confidential client patterns. OAuth 2.0 has subtle timing and security requirements. |
| HTML to Markdown conversion | Regex-based HTML tag replacement | turndown or node-html-markdown | HTML has complex nesting, entities, and edge cases (tables, code blocks, nested lists). Turndown has configurable rules; node-html-markdown is 37% faster. Both handle escaping properly. |
| Scheduled task execution | setInterval() in long-running Node process | launchd (macOS native) | launchd integrates with macOS power management, runs tasks even if computer was asleep at scheduled time, and doesn't require Node.js process always running. More reliable for daily automation. |
| URL normalization | Simple URL string comparison | URL API + hash-based dedup | URLs have protocol variants (http/https), trailing slashes, query param ordering, fragments, and tracking parameters. Hash-based dedup prevents false positives while enabling cross-source matching. |

**Key insight:** Content ingestion at scale has unexpected edge cases (malformed HTML, API rate limits, OAuth token expiry, duplicate detection). Mature libraries have already hit and fixed these issues. Custom solutions will rediscover them the hard way.

## Common Pitfalls

### Pitfall 1: JSDOM Memory Leaks
**What goes wrong:** Creating new JSDOM instance for each article causes memory to grow unbounded; eventual OOM crash.

**Why it happens:** JSDOM constructor calls process.nextTick() and retains window object references even after window.close(). Documented issue since 2014 (jsdom/jsdom#1665).

**How to avoid:** Create single JSDOM instance at module initialization; update document.body.innerHTML for each new article. Use async/await to prevent nextTick overflow.

**Warning signs:** Heap usage grows linearly with articles processed; doesn't stabilize after GC. Monitor with `process.memoryUsage()`.

### Pitfall 2: Slack Rate Limits on conversations.history
**What goes wrong:** Scanning boss's DMs hits rate limit (1 request/minute for non-Marketplace apps as of May 2025; further reduced March 2026 to 15 messages max per call).

**Why it happens:** conversations.history is heavily rate-limited to prevent abuse. Default limit of 100 messages was reduced to 15 in 2026 for apps outside Slack Marketplace.

**How to avoid:** Use oldest parameter to only fetch messages since last scan timestamp (stored in config). Implement exponential backoff on 429 responses. Consider caching boss's DM channel ID rather than calling conversations.list each time.

**Warning signs:** 429 Too Many Requests responses; scan fails intermittently. Log rate limit headers (X-Rate-Limit-Remaining).

### Pitfall 3: Microsoft Graph Token Expiry Mid-Scan
**What goes wrong:** MSAL access token expires during Outlook email scan; subsequent Graph API calls fail with 401 Unauthorized.

**Why it happens:** Confidential client application tokens expire after 60-90 minutes. Long-running scans may outlive token lifetime.

**How to avoid:** Use MSAL's acquireTokenSilent() which automatically refreshes expired tokens. Implement retry logic on 401 responses. Store token in MSAL cache rather than as plain text.

**Warning signs:** Scan succeeds initially but fails partway through email list; 401 errors after ~60 minutes of execution.

### Pitfall 4: Readability Returning Null on Paywalled Content
**What goes wrong:** Readability.parse() returns null for paywalled articles, causing crash if result is not null-checked.

**Why it happens:** Readability has charThreshold (default 500 chars) to filter out non-article pages. Paywalls often show <500 chars of preview text.

**How to avoid:** Check if article is null before accessing properties. Log failed extractions with URL for manual review. Consider capturing raw HTML as fallback.

**Warning signs:** TypeError: Cannot read property 'title' of null on paywalled sites (NY Times, WSJ, Medium members-only).

### Pitfall 5: Duplicate URLs with Different Fragments
**What goes wrong:** https://example.com/article#section1 and https://example.com/article#section2 treated as separate articles.

**Why it happens:** URL fragments are client-side navigation; server returns same content. Direct string comparison sees them as different.

**How to avoid:** Normalize URLs by stripping hash fragments and tracking parameters (utm_*, fbclid) before hashing. Use URL API rather than string manipulation.

**Warning signs:** Multiple vault notes for same article with different #fragments; dedup fails to merge provenance.

### Pitfall 6: Slack Bookmarks API Scope Confusion
**What goes wrong:** Bot token lacks permission to access bookmarks.list; returns 403 Forbidden despite valid authentication.

**Why it happens:** Bookmarks API requires specific bookmarks:read scope (or legacy read scope). Bot tokens need explicit scope grant during OAuth installation.

**How to avoid:** Request bookmarks:read, channels:read, and im:read scopes during Slack app installation. Test with API tester before building scanner.

**Warning signs:** 403 missing_scope error; Slack returns "The token used is not granted the specific scope permissions required to complete this request."

## Code Examples

Verified patterns from official sources and documentation:

### Article Extraction with Readability + JSDOM
```javascript
// Source: https://webcrawlerapi.com/blog/how-to-extract-article-or-blogpost-content-in-js-using-readabilityjs
import { JSDOM } from "jsdom";
import { Readability } from "@mozilla/readability";

function extractArticleContent(url, html) {
  try {
    const dom = new JSDOM(html, {
      url: url,
      contentType: "text/html",
    });

    const document = dom.window.document;

    // Optional: Clean unwanted elements first
    const unwantedElements = document.querySelectorAll(
      "script, style, noscript, iframe, footer, header, nav, .advertisement, .sidebar, .menu"
    );
    unwantedElements.forEach((element) => element.remove());

    const reader = new Readability(document);
    const article = reader.parse();

    if (!article) {
      return null;
    }

    return {
      title: article.title || "",
      content: article.content || "",          // Clean HTML
      textContent: article.textContent || "",  // Plain text
      length: article.length || 0,
      excerpt: article.excerpt || "",
      byline: article.byline || "",
      siteName: article.siteName || "",
      lang: article.lang || "",
    };
  } catch (error) {
    console.error("Error extracting article content:", error.message);
    return null;
  }
}
```

### Slack Bookmarks API with Node SDK
```javascript
// Source: Slack API docs - bookmarks.list method
import { WebClient } from '@slack/web-api';

const client = new WebClient(process.env.SLACK_BOT_TOKEN);

async function listBookmarks(channelId) {
  try {
    const result = await client.bookmarks.list({
      channel_id: channelId
    });

    // Result contains bookmarks array; conversations limited to 100 bookmarks
    return result.bookmarks.filter(b => b.type === 'link').map(b => ({
      title: b.title,
      url: b.link,
      created: b.date_created
    }));
  } catch (error) {
    if (error.data?.error === 'missing_scope') {
      console.error('Bot token missing bookmarks:read scope');
    }
    throw error;
  }
}
```

### Microsoft Graph Email Filtering
```javascript
// Source: https://learn.microsoft.com/en-us/graph/api/user-list-messages
import { Client } from '@microsoft/microsoft-graph-client';
import { ConfidentialClientApplication } from '@azure/msal-node';

// MSAL confidential client setup
const msalClient = new ConfidentialClientApplication({
  auth: {
    clientId: process.env.MS_CLIENT_ID,
    authority: `https://login.microsoftonline.com/${process.env.MS_TENANT_ID}`,
    clientSecret: process.env.MS_CLIENT_SECRET
  }
});

async function getAccessToken() {
  const result = await msalClient.acquireTokenByClientCredential({
    scopes: ['https://graph.microsoft.com/.default']
  });
  return result.accessToken;
}

async function listBossEmails(bossSenderEmail, sinceDate) {
  const token = await getAccessToken();
  const client = Client.init({
    authProvider: (done) => done(null, token)
  });

  // Filter messages from boss with links
  const messages = await client
    .api('/me/messages')
    .filter(`from/emailAddress/address eq '${bossSenderEmail}' and receivedDateTime ge ${sinceDate}`)
    .select('subject,bodyPreview,receivedDateTime,body')
    .orderby('receivedDateTime desc')
    .get();

  return messages.value;
}
```

### launchd Plist for Daily Scan
```xml
<!-- Source: https://alvinalexander.com/mac-os-x/launchd-plist-examples-startinterval-startcalendarinterval/ -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.modelcitizen.daily-scan</string>

  <key>ProgramArguments</key>
  <array>
    <string>/usr/local/bin/node</string>
    <string>/path/to/model-citizen/ingest/scan.js</string>
  </array>

  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>9</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>

  <key>StandardOutPath</key>
  <string>/tmp/modelcitizen-scan.log</string>

  <key>StandardErrorPath</key>
  <string>/tmp/modelcitizen-scan.err</string>
</dict>
</plist>
```

### URL-Based Deduplication
```javascript
// Source: https://transloadit.com/devtips/efficient-file-deduplication-with-sha-256-and-node-js/
import crypto from 'crypto';

function normalizeURL(url) {
  const parsed = new URL(url);

  // Remove fragment
  parsed.hash = '';

  // Remove tracking parameters
  const trackingParams = ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content',
                          'utm_term', 'fbclid', 'gclid', 'mc_cid', 'mc_eid'];
  trackingParams.forEach(param => parsed.searchParams.delete(param));

  // Normalize protocol
  parsed.protocol = 'https:';

  // Sort query params for consistent ordering
  parsed.searchParams.sort();

  return parsed.toString().toLowerCase();
}

function urlHash(url) {
  const normalized = normalizeURL(url);
  return crypto.createHash('sha256').update(normalized).digest('hex').slice(0, 16);
}
```

### Apple Shortcuts Share Sheet Integration
```javascript
// Shortcut structure (pseudocode - actual shortcut built in Shortcuts app):
// 1. Receive "URLs" from Share Sheet
// 2. Get "Text" from Share Sheet (optional note)
// 3. Run Shell Script:
//    node /path/to/web-capture.js --url "$URL" --note "$TEXT"
// 4. Show notification "Captured to Model Citizen queue"

// web-capture.js CLI interface
import { captureURL } from './sources/web-capture.js';
import { Command } from 'commander';

const program = new Command();
program
  .requiredOption('--url <url>', 'URL to capture')
  .option('--note <note>', 'Optional context note', '')
  .parse(process.argv);

const { url, note } = program.opts();
await captureURL(url, note);
console.log('Queued for processing');
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| cron for macOS scheduling | launchd with plist files | macOS 10.4 (2005) | launchd handles power management, runs missed jobs on wake, integrates with system security. Apple deprecated cron for user-level tasks. |
| Basic Auth for Microsoft Graph | OAuth 2.0 via MSAL | Removed Feb 2026 | Microsoft permanently removed basic authentication and app passwords. All Graph API access now requires OAuth 2.0 with token refresh handling. |
| Slack Legacy OAuth scopes | Granular resource scopes | Ongoing since 2019 | Modern scopes like bookmarks:read, im:read are more specific; bot tokens preferred over user tokens for automation. Rate limits tightened significantly in 2025-2026. |
| to-markdown library | turndown | Renamed 2017 | to-markdown became turndown with plugin architecture; faster alternatives like node-html-markdown emerged (37% faster for large docs). |
| Readability standalone | @mozilla/readability npm | Npm package 2016+ | Mozilla's official npm package with JSDOM integration; previous versions required browser environment or complex setup. |

**Deprecated/outdated:**
- **cron for user-level macOS tasks:** Still works but deprecated; launchd is Apple's recommended approach with better integration
- **Slack conversations.list for DMs:** Rate limited heavily in 2026; cache DM channel IDs instead of enumerating on each scan
- **Creating new JSDOM instances per article:** Causes memory leaks; reuse single instance and update innerHTML
- **Polling-based content capture:** Share sheet + queue-based approach is more responsive and battery-efficient than background polling

## Open Questions

1. **GoodLinks API/Export Capability**
   - What we know: GoodLinks is privacy-first, one-time purchase ($9.99), macOS + iOS. User open to alternatives.
   - What's unclear: Does GoodLinks have export API or file-system sync? Could we auto-import from GoodLinks on scan?
   - Recommendation: Test if GoodLinks stores data in accessible SQLite database (common pattern for macOS apps). If yes, direct import possible. If no, **keep GoodLinks as-is** and rely on share sheet for vault capture. GoodLinks meets criteria (free/one-time, macOS+iOS) and adds no engineering burden.

2. **Slack "Later" vs Bookmarks vs Saved Items Terminology**
   - What we know: Feature renamed multiple times (Saved Items → Bookmarks → Later). API still uses bookmarks.list.
   - What's unclear: Will API endpoint change? Is there separate "Later" API coming?
   - Recommendation: Use bookmarks.list; it's current stable API. Monitor Slack changelog for deprecation notices.

3. **Boss-Specific DM Channel ID Discovery**
   - What we know: conversations.history requires channel ID. DMs have IDs starting with 'D'.
   - What's unclear: Best practice for discovering boss's DM channel ID during setup.
   - Recommendation: One-time setup script that calls conversations.list with types=im, filters by boss's user ID, and stores DM channel ID in config. Reduces ongoing API calls.

4. **Enrichment Pipeline Trigger Strategy**
   - What we know: User wants scan invocable as Claude skill. Phase 7 enrichment exists.
   - What's unclear: Should scan immediately trigger enrichment, or run as separate step?
   - Recommendation: **Separate steps.** Scan populates vault with `status: captured`. User or scheduled job later runs enrichment which changes status to `enriched`. Allows bulk capture without enrichment latency; user can review captured content before enriching.

5. **YouTube Ingest Extension Strategy**
   - What we know: Phase 5 already has YouTube ingestion working.
   - What's unclear: Extent of changes needed to align with queue-based architecture.
   - Recommendation: Audit Phase 5 implementation. If already writes to vault directly, add dedup check and source_type frontmatter. If needs refactoring, create youtube-scan.js that uses same queue/normalize pattern as other sources.

## Read-Later App Recommendation

**Keep GoodLinks.** Rationale:

1. **Meets criteria perfectly:** $9.99 one-time purchase (not subscription), macOS + iOS native apps, privacy-first (no accounts/tracking)
2. **iOS reading experience:** Eliminates need to build custom iOS reader; GoodLinks handles offline sync, typography, highlighting
3. **Share sheet integration:** GoodLinks already appears in share sheet; captures work seamlessly. User can share to GoodLinks for reading, share to Model Citizen for vault ingestion, or both.
4. **No lock-in:** Even if GoodLinks data isn't directly accessible, share sheet provides universal escape hatch
5. **Reduces scope:** Building iOS reading app is massive scope increase; GoodLinks solves this for $9.99

**Alternative only if:** User wants to eliminate all intermediary apps and own entire stack. Then build direct share-to-vault Shortcut that writes to queue. But loses reading experience and cross-device sync that GoodLinks provides.

## Sources

### Primary (HIGH confidence)
- [@mozilla/readability npm package](https://www.npmjs.com/package/@mozilla/readability) - Article extraction API, configuration options
- [Slack API bookmarks.list documentation](https://docs.slack.dev/reference/methods/bookmarks.list/) - API methods, scopes, rate limits
- [Microsoft Graph user-list-messages API](https://learn.microsoft.com/en-us/graph/api/user-list-messages) - Email filtering, authentication
- [Apple launchd scheduling documentation](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/ScheduledJobs.html) - StartCalendarInterval, plist structure
- [@azure/msal-node documentation](https://learn.microsoft.com/en-us/entra/msal/javascript/node/faq) - Confidential client applications, token refresh

### Secondary (MEDIUM confidence)
- [WebCrawler API Readability tutorial](https://webcrawlerapi.com/blog/how-to-extract-article-or-blogpost-content-in-js-using-readabilityjs) - Complete extraction example with JSDOM
- [Alvin Alexander launchd examples](https://alvinalexander.com/mac-os-x/launchd-plist-examples-startinterval-startcalendarinterval/) - Verified plist syntax
- [Apple Shortcuts x-callback-url support](https://support.apple.com/guide/shortcuts/use-x-callback-url-apdcd7f20a6f/ios) - Share sheet automation patterns
- [Readless read-later app comparison 2026](https://www.readless.app/blog/best-read-later-apps-comparison) - GoodLinks vs alternatives
- [Claude Code slash commands documentation](https://code.claude.com/docs/en/slash-commands) - Custom command creation patterns

### Tertiary (LOW confidence - needs validation)
- [JSDOM memory leak issue tracking](https://github.com/jsdom/jsdom/issues/1665) - Community-reported workarounds; not official solution
- [file-queue GitHub project](https://github.com/threez/file-queue) - File-based queue implementation; archived project, last updated 2014
- [Transloadit SHA-256 deduplication article](https://transloadit.com/devtips/efficient-file-deduplication-with-sha-256-and-node-js/) - Pattern validated but not specific to URL dedup

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Official SDKs and widely-adopted libraries with active maintenance
- Architecture: MEDIUM-HIGH - Patterns well-established for multi-source ingestion; queue + dedup strategies validated
- Pitfalls: MEDIUM - Some based on GitHub issues (JSDOM memory leaks) and recent API changes (Slack rate limits 2026); requires testing to confirm current behavior
- API integration: MEDIUM - Authentication patterns verified from official docs; specific scope combinations need testing with user's Slack/Microsoft tenants

**Research date:** 2026-02-10
**Valid until:** 2026-04-10 (60 days) - API rate limits and authentication patterns change frequently; launchd and library APIs stable

**Notes for planner:**
- Phase 7 enrichment pipeline already exists; this phase focuses on getting content INTO vault with proper normalization
- Boss's user IDs (Slack, email) will need to be discovered during implementation via one-time setup
- Daily scan timing recommendation: 9:00 AM (after work day starts, before heavy email volume)
- Scan + enrichment should be separate operations for performance; user can trigger enrichment manually after reviewing captures
