# scan-slack-intelligence

Scan Slack starred messages and write content-rich vault source notes to the Model Citizen intelligence pipeline.

## Your Task

You are an intelligence scanner. Fetch all starred Slack messages not yet processed, and write vault source notes matching the Model Citizen SCHEMA.md format.

### Step 1: Load credentials and state

Read `~/.model-citizen/env` to load `SLACK_BOT_TOKEN`. If the file doesn't exist or the token is missing, stop and report:

```
Error: SLACK_BOT_TOKEN not found in ~/.model-citizen/env
Add it with: echo "SLACK_BOT_TOKEN=xoxb-..." >> ~/.model-citizen/env
Required scopes: stars:read, users:read, channels:read, groups:read
```

Read `~/.model-citizen/slack-intelligence-state.json`. If absent, initialize it:
```json
{"last_scan_ts": 0, "seen_ids": []}
```

Parse `last_scan_ts` (Unix timestamp float) and `seen_ids` (array of strings).

### Step 2: Fetch starred messages

Call the Slack REST API to get all starred items:

```bash
source ~/.model-citizen/env

# Fetch starred items (paginate if needed)
RESPONSE=$(curl -s "https://slack.com/api/stars.list?count=100&page=1" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN")

echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print('ok:', d.get('ok'), '| total:', d.get('paging',{}).get('total',0))"
```

If `ok` is false, report the API error and stop.

Parse the `items` array. Filter to items where:
- `type == "message"` (skip file stars, channel stars)
- `date_create > last_scan_ts` OR `message.ts` is NOT in `seen_ids`

If no new items after filtering, report "0 new starred messages since last scan" and stop (do not update state).

### Step 3: Resolve names for each message

For each new starred message, resolve:

**Channel name** (from channel ID):
```bash
CHANNEL_RESP=$(curl -s "https://slack.com/api/conversations.info?channel=$CHANNEL_ID" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN")
CHANNEL_NAME=$(echo "$CHANNEL_RESP" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('channel',{}).get('name','unknown'))")
```

**Sender display name** (from user ID):
```bash
USER_RESP=$(curl -s "https://slack.com/api/users.info?user=$USER_ID" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN")
SENDER=$(echo "$USER_RESP" | python3 -c "import sys,json; d=json.load(sys.stdin); p=d.get('user',{}).get('profile',{}); print(p.get('display_name') or p.get('real_name','unknown'))")
```

Cache results to avoid repeated API calls for the same channel/user.

### Step 4: Write vault source notes

For each new starred message, write a vault source note.

**Vault base path:** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/`
**Target folder:** `sources/slack/` (write directly — do not rely on ANM to move files)

**Generate title:** Take the first 60 characters of `message.text`, sanitize:
- Strip newlines, replace with space
- Strip special chars (keep alphanumeric, spaces, hyphens)
- Truncate at 60 chars

**Generate filename:** `Slack - {YYYY-MM-DD} - {sanitized-title-hyphenated}.md`
- Date from `message.ts` converted to local date
- Title: lowercase, spaces→hyphens, truncated at 60 chars

**Write the note file with this EXACT frontmatter format:**
```markdown
---
title: "Slack: {first 80 chars of message text, sanitized}"
type: source/slack
created: {YYYY-MM-DD from message.ts}
content_status: raw
publishability: private
provenance:
  channel: {channel_name}
  sender: {sender_display_name}
  timestamp: "{message.ts}"
  thread_ts: "{message.thread_ts or empty string}"
  permalink: "{message.permalink}"
  starred_reason: ""
tags: [type/source/slack]
---

{Full message.text verbatim}
```

**CRITICAL CONSTRAINTS:**
- Notes MUST include BOTH `type: source/slack` (YAML field) AND `tags: [type/source/slack]` (Obsidian routing tag)
- `publishability` is ALWAYS `private` — no exceptions for source notes
- `content_status` is ALWAYS `raw` for newly created source notes
- Write to `sources/slack/` directly, not vault root
- `starred_reason` is `""` (empty string) — Slack stars.list API does not return a reason

### Step 5: Update state file atomically

After processing ALL messages (not after each one), build a new complete JSON object and write it:

```python
import json, time

# Read current state
with open(os.path.expanduser("~/.model-citizen/slack-intelligence-state.json")) as f:
    state = json.load(f)

# Build updated state
new_ids = state["seen_ids"] + [msg["ts"] for msg in processed_messages]
new_state = {
    "last_scan_ts": time.time(),
    "seen_ids": list(set(new_ids))  # deduplicate
}

# Write atomically
with open(os.path.expanduser("~/.model-citizen/slack-intelligence-state.json"), "w") as f:
    json.dump(new_state, f, indent=2)
```

DO NOT append to the state file. DO NOT use `echo "..." >> state.json`. Always read → compute → write a complete new JSON object.

### Step 6: Report results

Print a summary:
```
Slack Intelligence Scan Complete
─────────────────────────────────
New notes created: {N}
  • {note-filename-1}
  • {note-filename-2}
Already seen (skipped): {M}
Errors: {0 or error description}

State updated: ~/.model-citizen/slack-intelligence-state.json
```

If N=0: "No new starred messages since last scan. State not updated."

## Notes on Setup

If this is the first run, the scanner will create `~/.model-citizen/slack-intelligence-state.json` automatically with `{"last_scan_ts": 0, "seen_ids": []}`.

The Slack bot token must have these scopes:
- `stars:read` — to list starred messages
- `users:read` — to resolve user display names
- `channels:read` — to resolve public channel names
- `groups:read` — to resolve private channel names (if starred messages are from private channels)
