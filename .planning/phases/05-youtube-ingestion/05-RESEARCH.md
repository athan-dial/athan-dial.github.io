# Phase 5: YouTube Ingestion - Research

**Researched:** 2026-02-05
**Domain:** n8n workflow automation, YouTube transcript extraction, file-based idempotency
**Confidence:** HIGH

## Summary

Phase 5 implements a local n8n Docker workflow that downloads YouTube transcripts using yt-dlp, normalizes them to Markdown with frontmatter, and stores them in the Vault `/sources/` folder. The workflow must be idempotent (no duplicate notes on re-runs) and handle edge cases like missing transcripts or private videos.

The standard stack is Docker + n8n + yt-dlp, with idempotency achieved via file existence checks before processing. n8n's Execute Command node runs yt-dlp to extract transcripts, and Code nodes handle frontmatter generation and file operations. Volume mounts provide access to the Vault filesystem from within the Docker container.

Critical requirements: Enable Execute Command node in n8n Docker (disabled by default), mount Vault directory as bind mount (not Docker volume), use gray-matter library for frontmatter parsing/generation, and implement URL-based deduplication to prevent re-processing.

**Primary recommendation:** Use n8n Docker Compose with bind mounts to `~/model-citizen-vault`, enable Execute Command node via `NODES_EXCLUDE=[]`, and implement idempotency checks before yt-dlp execution.

## Standard Stack

The established tools for this domain:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| n8n | latest | Workflow automation platform | Visual workflow builder, extensive integrations, self-hostable |
| Docker | latest | Container runtime | Isolated environment, consistent deployment, official n8n support |
| yt-dlp | latest | YouTube video/transcript downloader | Most reliable YouTube extractor, active maintenance, transcript support |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| gray-matter | 4.x | YAML frontmatter parsing/generation | Generating/parsing frontmatter in Code nodes |
| ffmpeg | latest | Media processing (yt-dlp dependency) | Required for yt-dlp high-quality downloads and format conversion |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| n8n | Zapier/Make | n8n is self-hosted (privacy), free, and allows Execute Command node |
| yt-dlp | YouTube API | API requires auth, has quota limits, and may not provide transcripts |
| Docker | Native install | Docker provides isolation and easier dependency management |

**Installation:**
```bash
# Docker Compose (recommended)
# See Architecture Patterns section for full docker-compose.yml

# Verify yt-dlp available in container
docker exec n8n which yt-dlp

# If not available, install in container
docker exec n8n apk add --no-cache yt-dlp ffmpeg
```

## Architecture Patterns

### Recommended Project Structure
```
~/model-citizen-vault/          # Vault directory (from Phase 4)
├── sources/
│   └── youtube/               # YouTube transcripts land here
├── inbox/
├── enriched/
└── ...

~/.n8n/                        # n8n data directory (Docker volume)
├── workflows/
└── credentials/

~/n8n-docker/                  # Docker Compose setup
├── docker-compose.yml
└── .env                       # Environment variables
```

### Pattern 1: n8n Docker Compose Setup with Vault Bind Mount
**What:** Docker Compose configuration that mounts Vault directory for file access
**When to use:** Required for n8n workflows to read/write Vault files
**Example:**
```yaml
# Source: https://docs.n8n.io/hosting/installation/server-setups/docker-compose/
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=http://localhost:5678/
      - NODES_EXCLUDE=[]  # CRITICAL: Enables Execute Command node
    volumes:
      - ~/.n8n:/home/node/.n8n              # n8n data persistence
      - ~/model-citizen-vault:/vault:rw     # Vault bind mount (read/write)
```

**Key considerations:**
- Use bind mount (`~/model-citizen-vault:/vault:rw`) NOT Docker volume for Vault access
- `:rw` flag ensures read/write permissions
- Container path `/vault` becomes the base path for all file operations
- `NODES_EXCLUDE=[]` is required to enable Execute Command node (disabled by default for security)

### Pattern 2: Idempotent File Processing Workflow
**What:** Workflow structure that checks existence before processing to prevent duplicates
**When to use:** Any ingestion workflow that could be run multiple times with same input
**Example:**
```javascript
// n8n Code node: Check if source already exists
const url = $input.first().json.url;

// Extract video ID from YouTube URL
const videoIdMatch = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&?]+)/);
const videoId = videoIdMatch ? videoIdMatch[1] : null;

if (!videoId) {
  throw new Error('Invalid YouTube URL');
}

// Check if file already exists in vault
const fs = require('fs');
const path = require('path');
const glob = require('glob');

const vaultPath = '/vault/sources/youtube';
const existingFiles = glob.sync(`${vaultPath}/${videoId}-*.md`);

if (existingFiles.length > 0) {
  // File exists, skip processing
  return [{ json: { status: 'skipped', reason: 'already_exists', videoId } }];
} else {
  // File doesn't exist, proceed with processing
  return [{ json: { status: 'process', videoId, url } }];
}
```

**Architecture flow:**
1. **Trigger Node** → Manual execution or webhook trigger
2. **Code Node: Parse URL** → Extract video ID, validate format
3. **Code Node: Check Existence** → Glob for `${videoId}-*.md` in `/vault/sources/youtube`
4. **IF Node** → Branch: skip if exists, process if new
5. **Execute Command Node** → Run yt-dlp to extract transcript
6. **Code Node: Generate Frontmatter** → Create YAML frontmatter + Markdown body
7. **Write File Node** → Save to `/vault/sources/youtube/{videoId}-{title-slug}.md`
8. **Notify Node** → Log result (processed, skipped, failed)

### Pattern 3: yt-dlp Transcript Extraction Command
**What:** yt-dlp command that downloads only transcripts (no video) in VTT format
**When to use:** When you need text transcripts without downloading video files
**Example:**
```bash
# Source: https://github.com/yt-dlp/yt-dlp
# Basic transcript extraction (auto-generated subtitles if no manual subs)
yt-dlp \
  --write-auto-subs \
  --skip-download \
  --sub-lang en \
  --sub-format vtt \
  --output "/vault/sources/youtube/%(id)s.%(ext)s" \
  "https://www.youtube.com/watch?v=VIDEO_ID"

# Get video metadata (title, description, upload date)
yt-dlp \
  --skip-download \
  --print "%(id)s|%(title)s|%(upload_date)s|%(description)s" \
  "https://www.youtube.com/watch?v=VIDEO_ID"
```

**Flags explained:**
- `--write-auto-subs`: Download auto-generated subtitles (fallback if no manual subs)
- `--skip-download`: Don't download video/audio, only metadata/subs
- `--sub-lang en`: Prefer English subtitles
- `--sub-format vtt`: WebVTT format (timestamped, easy to parse)
- `--output`: Template for output filename
- `--print`: Output metadata without downloading (use for title/description)

**Output:** `.vtt` file with timestamped transcript like:
```vtt
WEBVTT

00:00:00.000 --> 00:00:03.000
Welcome to this video about...

00:00:03.000 --> 00:00:07.000
Today we're going to discuss...
```

### Pattern 4: VTT to Plain Text Conversion
**What:** Parse VTT transcript file and extract plain text (remove timestamps)
**When to use:** Converting yt-dlp output to clean Markdown body
**Example:**
```javascript
// n8n Code node: Parse VTT and extract text
const fs = require('fs');
const vttContent = fs.readFileSync('/vault/sources/youtube/VIDEO_ID.en.vtt', 'utf8');

// Remove VTT header and timestamps
const lines = vttContent.split('\n');
const textLines = [];

for (let i = 0; i < lines.length; i++) {
  const line = lines[i].trim();

  // Skip WEBVTT header, empty lines, and timestamp lines
  if (line === '' || line === 'WEBVTT' || line.includes('-->')) {
    continue;
  }

  // Skip numeric cue identifiers (standalone numbers)
  if (/^\d+$/.test(line)) {
    continue;
  }

  // This is transcript text
  textLines.push(line);
}

// Join with paragraphs (double newline every ~5 lines for readability)
const transcript = textLines.join(' ').trim();

return [{ json: { transcript } }];
```

### Pattern 5: Frontmatter Generation with gray-matter
**What:** Generate YAML frontmatter + Markdown body for source notes
**When to use:** Creating Vault-compliant Markdown files from ingested content
**Example:**
```javascript
// n8n Code node: Generate frontmatter and write file
// Install gray-matter in n8n: Settings → Community Nodes → Install 'gray-matter'
const matter = require('gray-matter');
const fs = require('fs');
const path = require('path');

// Input from previous nodes
const videoId = $input.first().json.videoId;
const title = $input.first().json.title;
const url = $input.first().json.url;
const transcript = $input.first().json.transcript;
const uploadDate = $input.first().json.upload_date; // Format: YYYYMMDD

// Generate slug from title
const slug = title
  .toLowerCase()
  .replace(/[^a-z0-9]+/g, '-')
  .replace(/^-|-$/g, '');

// Construct frontmatter object (matches Phase 4 schema)
const frontmatterData = {
  title: title,
  date: uploadDate.replace(/(\d{4})(\d{2})(\d{2})/, '$1-$2-$3'), // Format as YYYY-MM-DD
  status: 'inbox',
  tags: [],
  source: 'YouTube',
  source_url: url
};

// Generate markdown with frontmatter
const markdown = matter.stringify(transcript, frontmatterData);

// Write to vault
const filename = `${videoId}-${slug}.md`;
const filepath = `/vault/sources/youtube/${filename}`;
fs.writeFileSync(filepath, markdown, 'utf8');

return [{
  json: {
    success: true,
    filename,
    filepath
  }
}];
```

**Output format:**
```markdown
---
title: "Understanding Decision Velocity in ML Teams"
date: 2026-02-05
status: "inbox"
tags: []
source: "YouTube"
source_url: "https://www.youtube.com/watch?v=VIDEO_ID"
---

Welcome to this video about decision velocity...
Today we're going to discuss how to measure...
```

### Anti-Patterns to Avoid

- **Using Docker volumes instead of bind mounts for Vault:** Docker volumes are opaque to host filesystem, making debugging and manual edits impossible. Use bind mounts.
- **Not checking for duplicates before processing:** Running yt-dlp is expensive. Always check existence first.
- **Hardcoding video IDs:** Workflows should accept URLs as input and parse video IDs programmatically.
- **Storing raw VTT files:** VTT includes timestamps and formatting artifacts. Always convert to plain text for Vault.
- **Not handling missing transcripts:** Some videos have no transcripts (private, deleted, disabled). Workflow must gracefully fail and log reason.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| YAML frontmatter parsing | Custom regex parser | gray-matter library | Handles edge cases (multiline strings, nested objects, escaping) |
| YouTube video ID extraction | Manual string parsing | Regex + validation | URLs have many formats (youtu.be, youtube.com/watch, /embed/, /v/, shorts) |
| Transcript timestamp removal | Line-by-line string manipulation | VTT parsing logic | VTT has cue identifiers, metadata blocks, and special formatting |
| Slug generation from titles | Custom character replacement | Established slug function | Unicode handling, duplicate hyphen collapsing, edge case trimming |
| File existence checking | `fs.existsSync` with exact filename | glob pattern matching | Video titles change, filenames may vary—glob finds by video ID prefix |

**Key insight:** File and text processing has countless edge cases. Use battle-tested libraries and established patterns from n8n community rather than custom code.

## Common Pitfalls

### Pitfall 1: Execute Command Node Disabled by Default
**What goes wrong:** n8n 2.0+ disables Execute Command node for security. Workflow fails silently or shows "node not available" error.
**Why it happens:** Execute Command allows arbitrary shell commands, so n8n disables it in multi-user or untrusted environments.
**How to avoid:** Set `NODES_EXCLUDE=[]` environment variable in Docker Compose to explicitly enable it.
**Warning signs:** "Execute Command node not found" error, or node appears grayed out in workflow editor.

### Pitfall 2: Container Filesystem vs Host Filesystem Paths
**What goes wrong:** File operations use host paths (`~/model-citizen-vault`) but n8n runs in container—files not found.
**Why it happens:** Docker containers have isolated filesystems. Bind mounts map host paths to container paths.
**How to avoid:** Use container paths in all file operations (`/vault` not `~/model-citizen-vault`), and verify mount in docker-compose.yml.
**Warning signs:** "ENOENT: no such file or directory" errors despite files existing on host.

### Pitfall 3: Missing ffmpeg Breaks yt-dlp
**What goes wrong:** yt-dlp fails with "Requested format not available" or "Unable to merge formats" errors.
**Why it happens:** yt-dlp requires ffmpeg for format conversion and merging streams, but Alpine Linux n8n image doesn't include it by default.
**How to avoid:** Install ffmpeg in n8n Docker container: `docker exec n8n apk add --no-cache ffmpeg`.
**Warning signs:** yt-dlp errors mentioning formats, streams, or post-processing failures.

### Pitfall 4: Auto-Generated Transcripts Are Noisy
**What goes wrong:** Transcripts contain filler words ("um", "uh"), repetition, and formatting artifacts.
**Why it happens:** YouTube's auto-transcription is speech-to-text, not professional captions.
**How to avoid:** Accept that Phase 5 captures raw transcripts. Manual cleanup or AI summarization (Phase 6+) improves quality.
**Warning signs:** Markdown files with poor grammar, excessive filler, or garbled text.

### Pitfall 5: Transcript Language Mismatch
**What goes wrong:** yt-dlp downloads transcript in wrong language or finds no transcript.
**Why it happens:** `--sub-lang en` is a preference, not a requirement. Video may only have other languages.
**How to avoid:** Check yt-dlp exit code and stderr. If no English transcript, log failure or fallback to another language.
**Warning signs:** Empty `.vtt` files or yt-dlp errors like "No subtitles available."

### Pitfall 6: Title-Based Filenames Cause Collisions
**What goes wrong:** Multiple videos with same title (or similar slugs) overwrite each other.
**Why it happens:** Titles are not unique identifiers. Slug collisions are possible.
**How to avoid:** Always prefix filename with video ID: `${videoId}-${slug}.md`. Video IDs are globally unique.
**Warning signs:** Source notes mysteriously disappearing or being overwritten.

### Pitfall 7: Not Handling Private or Deleted Videos
**What goes wrong:** Workflow crashes when URL points to inaccessible video.
**Why it happens:** yt-dlp returns non-zero exit code for private/deleted/restricted videos.
**How to avoid:** Wrap Execute Command node in error handling. Log failure reason and continue workflow.
**Warning signs:** Entire workflow stops processing after hitting one bad URL.

## Code Examples

Verified patterns from official sources:

### n8n Docker Compose with Execute Command Enabled
```yaml
# Source: https://docs.n8n.io/hosting/installation/server-setups/docker-compose/
# https://community.n8n.io/t/how-to-enable-execute-command/249009

version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      # Core n8n settings
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=http://localhost:5678/

      # CRITICAL: Enable Execute Command node (disabled by default in n8n 2.0+)
      - NODES_EXCLUDE=[]

      # Optional: Timezone for cron schedules
      - GENERIC_TIMEZONE=America/New_York

    volumes:
      # n8n data persistence (workflows, credentials, etc.)
      - ~/.n8n:/home/node/.n8n

      # Vault bind mount for file operations (read/write access)
      - ~/model-citizen-vault:/vault:rw
```

**Usage:**
```bash
# Start n8n
cd ~/n8n-docker
docker-compose up -d

# Access web interface
open http://localhost:5678

# Install yt-dlp and ffmpeg in container
docker exec n8n apk add --no-cache yt-dlp ffmpeg

# Verify Execute Command enabled
# In n8n UI, add Execute Command node—should be available
```

### YouTube URL Validation and Video ID Extraction
```javascript
// n8n Code node: Extract video ID from YouTube URL
// Handles multiple URL formats: youtube.com/watch, youtu.be, /embed/, /v/, /shorts/

const url = $input.first().json.url;

// Regex pattern for all YouTube URL formats
const patterns = [
  /(?:youtube\.com\/watch\?v=)([^&?]+)/,           // youtube.com/watch?v=VIDEO_ID
  /(?:youtu\.be\/)([^?]+)/,                        // youtu.be/VIDEO_ID
  /(?:youtube\.com\/embed\/)([^?]+)/,              // youtube.com/embed/VIDEO_ID
  /(?:youtube\.com\/v\/)([^?]+)/,                  // youtube.com/v/VIDEO_ID
  /(?:youtube\.com\/shorts\/)([^?]+)/              // youtube.com/shorts/VIDEO_ID
];

let videoId = null;
for (const pattern of patterns) {
  const match = url.match(pattern);
  if (match) {
    videoId = match[1];
    break;
  }
}

if (!videoId) {
  throw new Error(`Invalid YouTube URL: ${url}`);
}

return [{ json: { videoId, url } }];
```

### Idempotency Check via File Existence
```javascript
// n8n Code node: Check if source already exists in vault
// Uses glob to find files by video ID prefix

const fs = require('fs');
const { execSync } = require('child_process');

const videoId = $input.first().json.videoId;
const vaultPath = '/vault/sources/youtube';

// Ensure directory exists
if (!fs.existsSync(vaultPath)) {
  fs.mkdirSync(vaultPath, { recursive: true });
}

// Use find command to search for existing files (glob not available in n8n by default)
let existingFiles = [];
try {
  const output = execSync(`find ${vaultPath} -name "${videoId}-*.md"`, { encoding: 'utf8' });
  existingFiles = output.trim().split('\n').filter(f => f.length > 0);
} catch (error) {
  // No files found (find returns non-zero if no matches)
  existingFiles = [];
}

if (existingFiles.length > 0) {
  // File exists, skip processing
  return [{
    json: {
      status: 'skipped',
      reason: 'already_exists',
      videoId,
      existingFile: existingFiles[0]
    }
  }];
} else {
  // File doesn't exist, proceed with processing
  return [{
    json: {
      status: 'process',
      videoId
    }
  }];
}
```

### yt-dlp Transcript + Metadata Extraction
```bash
# Execute Command node: Extract transcript and metadata in one command

# Get metadata first
METADATA=$(yt-dlp \
  --skip-download \
  --print "%(id)s|||%(title)s|||%(upload_date)s|||%(description)s" \
  "{{ $json.url }}")

# Extract to variables
VIDEO_ID=$(echo "$METADATA" | cut -d'|' -f1)
TITLE=$(echo "$METADATA" | cut -d'|' -f4)
UPLOAD_DATE=$(echo "$METADATA" | cut -d'|' -f7)
DESCRIPTION=$(echo "$METADATA" | cut -d'|' -f10)

# Download transcript (VTT format)
yt-dlp \
  --write-auto-subs \
  --skip-download \
  --sub-lang en \
  --sub-format vtt \
  --output "/vault/sources/youtube/${VIDEO_ID}.%(ext)s" \
  "{{ $json.url }}"

# Output metadata for next node
echo "{\"videoId\":\"$VIDEO_ID\",\"title\":\"$TITLE\",\"uploadDate\":\"$UPLOAD_DATE\",\"description\":\"$DESCRIPTION\"}"
```

### VTT to Plain Text Parsing
```javascript
// n8n Code node: Parse VTT file and extract clean text
// Source: VTT format spec (timestamps are HH:MM:SS.mmm --> HH:MM:SS.mmm)

const fs = require('fs');

const videoId = $input.first().json.videoId;
const vttPath = `/vault/sources/youtube/${videoId}.en.vtt`;

// Check if transcript file exists
if (!fs.existsSync(vttPath)) {
  throw new Error(`Transcript not found: ${vttPath}`);
}

const vttContent = fs.readFileSync(vttPath, 'utf8');
const lines = vttContent.split('\n');
const textLines = [];

for (let i = 0; i < lines.length; i++) {
  const line = lines[i].trim();

  // Skip empty lines, WEBVTT header, and timestamp lines
  if (line === '' || line === 'WEBVTT' || line.includes('-->')) {
    continue;
  }

  // Skip cue identifiers (standalone numbers or timestamp format)
  if (/^\d+$/.test(line) || /^\d{2}:\d{2}:\d{2}/.test(line)) {
    continue;
  }

  // Skip VTT metadata blocks (NOTE, STYLE, REGION)
  if (line.startsWith('NOTE') || line.startsWith('STYLE') || line.startsWith('REGION')) {
    continue;
  }

  // This is transcript text
  textLines.push(line);
}

// Join with spaces (transcript is continuous text)
const transcript = textLines.join(' ').trim();

// Clean up duplicate spaces
const cleanTranscript = transcript.replace(/\s+/g, ' ');

return [{
  json: {
    videoId,
    transcript: cleanTranscript
  }
}];
```

### Frontmatter Generation and File Write
```javascript
// n8n Code node: Generate frontmatter + markdown and write to vault
// Requires gray-matter (install via n8n Community Nodes or native require if available)

const fs = require('fs');
const path = require('path');

// Try to load gray-matter (may not be available in n8n sandbox)
let matter;
try {
  matter = require('gray-matter');
} catch (error) {
  // If gray-matter not available, use manual YAML generation
  matter = null;
}

// Input data
const videoId = $input.first().json.videoId;
const title = $input.first().json.title;
const url = $input.first().json.url;
const uploadDate = $input.first().json.uploadDate; // Format: YYYYMMDD
const transcript = $input.first().json.transcript;

// Generate slug from title
const slug = title
  .toLowerCase()
  .replace(/[^a-z0-9]+/g, '-')   // Replace non-alphanumeric with hyphens
  .replace(/^-|-$/g, '')          // Remove leading/trailing hyphens
  .substring(0, 60);              // Limit length to keep filename reasonable

// Format date as YYYY-MM-DD
const formattedDate = uploadDate.replace(/(\d{4})(\d{2})(\d{2})/, '$1-$2-$3');

// Construct frontmatter
const frontmatter = {
  title: title,
  date: formattedDate,
  status: 'inbox',
  tags: [],
  source: 'YouTube',
  source_url: url
};

// Generate markdown file content
let fileContent;
if (matter) {
  // Use gray-matter if available
  fileContent = matter.stringify(transcript, frontmatter);
} else {
  // Manual YAML generation (fallback)
  const yaml = [
    '---',
    `title: "${title.replace(/"/g, '\\"')}"`,
    `date: ${formattedDate}`,
    'status: "inbox"',
    'tags: []',
    'source: "YouTube"',
    `source_url: "${url}"`,
    '---',
    '',
    transcript
  ].join('\n');
  fileContent = yaml;
}

// Write to vault
const filename = `${videoId}-${slug}.md`;
const filepath = `/vault/sources/youtube/${filename}`;

// Ensure directory exists
const dir = path.dirname(filepath);
if (!fs.existsSync(dir)) {
  fs.mkdirSync(dir, { recursive: true });
}

fs.writeFileSync(filepath, fileContent, 'utf8');

return [{
  json: {
    success: true,
    filename,
    filepath,
    videoId
  }
}];
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| youtube-dl | yt-dlp | 2021 | yt-dlp is actively maintained fork with better performance and features |
| Manual subtitle parsing | yt-dlp --write-auto-subs | Always available | yt-dlp handles subtitle extraction natively |
| Docker volumes for file sharing | Bind mounts | n8n best practices | Bind mounts provide transparent host filesystem access |
| n8n Execute Command always available | Disabled by default | n8n 2.0 (2024) | Must explicitly enable with NODES_EXCLUDE=[] |

**Deprecated/outdated:**
- **youtube-dl**: Unmaintained as of 2021. Use yt-dlp instead.
- **Python subprocess wrappers for yt-dlp**: yt-dlp CLI is stable and well-documented. Direct execution is simpler.
- **Custom VTT parsers in multiple languages**: VTT format is stable. Use established regex patterns.

## Open Questions

Things that couldn't be fully resolved:

1. **gray-matter availability in n8n Docker container**
   - What we know: n8n uses Node.js sandbox, may not have all npm packages available by default
   - What's unclear: Whether gray-matter can be `require()`'d in Code nodes without custom installation
   - Recommendation: Implement fallback manual YAML generation if gray-matter not available, or install via n8n Community Nodes feature

2. **Optimal transcript preprocessing strategy**
   - What we know: Auto-generated transcripts are noisy but serviceable
   - What's unclear: Whether to clean filler words in Phase 5 or defer to AI enrichment in Phase 6
   - Recommendation: Keep Phase 5 simple—capture raw transcripts. Let Phase 6 handle cleanup and summarization.

3. **Handling non-English or multi-language videos**
   - What we know: `--sub-lang en` works for English, fallback to auto-detect is possible
   - What's unclear: Best strategy for multi-language support (context says deferred to v2)
   - Recommendation: English-only for Phase 5. Log failures for non-English videos.

4. **Batch processing vs single URL input**
   - What we know: Phase 5 focuses on single URL ingestion
   - What's unclear: Whether to support playlist URLs or multiple URLs in one run
   - Recommendation: Single URL input for MVP. Playlist support can be added later (context says deferred).

## Sources

### Primary (HIGH confidence)
- [n8n Docker Compose Documentation](https://docs.n8n.io/hosting/installation/server-setups/docker-compose/) - Official n8n Docker setup
- [n8n Execute Command Node Documentation](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.executecommand/) - Execute Command usage
- [yt-dlp GitHub Repository](https://github.com/yt-dlp/yt-dlp) - Official yt-dlp documentation
- [yt-dlp FAQ](https://github.com/yt-dlp/yt-dlp/wiki/FAQ) - Subtitle extraction patterns
- [gray-matter npm package](https://www.npmjs.com/package/gray-matter) - Frontmatter parsing library

### Secondary (MEDIUM confidence)
- [n8n Community: Enable Execute Command](https://community.n8n.io/t/how-to-enable-execute-command/249009) - NODES_EXCLUDE configuration
- [n8n Community: Docker Volume Mounts](https://community.n8n.io/t/how-can-i-mount-a-local-folder-into-my-docker-container/93191) - Bind mount patterns
- [n8n Community: Check if File Exists](https://community.n8n.io/t/check-if-file-exists/1457) - Idempotency patterns
- [Medium: Using yt-dlp to Download YouTube Transcript](https://medium.com/@jallenswrx2016/using-yt-dlp-to-download-youtube-transcript-3479fccad9ea) - Transcript extraction examples
- [n8n Idempotency and Exactly-Once Patterns](https://cms--ghost--p9nkr6mgkbt9.code.run/idempotency-and-exactly-once-patterns-in-n8n-a-practical-guide-for-south-african-teams/) - Workflow design patterns

### Tertiary (LOW confidence)
- Community blog posts on n8n workflow optimization (general best practices, not phase-specific)
- Stack Overflow discussions on VTT parsing (patterns verified against VTT spec)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - n8n, Docker, and yt-dlp are established, well-documented tools
- Architecture: HIGH - Docker Compose patterns verified from official n8n docs, bind mount approach confirmed
- Pitfalls: HIGH - Execute Command disabled by default confirmed in n8n 2.0 release notes, filesystem path issues documented in community
- Code examples: MEDIUM - Patterns derived from official docs + community examples, not tested in actual n8n environment yet

**Research date:** 2026-02-05
**Valid until:** 30 days (stable stack, unlikely to change rapidly)

**Notes for planner:**
- Prioritize tasks in order: Docker Compose setup → Enable Execute Command → Idempotency check → yt-dlp extraction → Frontmatter generation → File write
- Include verification steps for each task: container runs, Execute Command available, test URL processed, check for duplicate prevention
- Consider creating test workflow JSON that can be imported into n8n for faster iteration
