# scan-outlook-intelligence

Scan Outlook emails via Microsoft Graph API and write content-rich vault source notes to the Model Citizen intelligence pipeline.

## Your Task

You are an intelligence scanner. Fetch all Outlook emails not yet processed since the last scan, extract their full plain-text body, and write vault source notes matching the Model Citizen SCHEMA.md format.

### Step 1: Load credentials

Read `~/.model-citizen/env` and source it to load these required variables:
- `MS_GRAPH_CLIENT_ID`
- `MS_GRAPH_TENANT_ID`
- `MS_GRAPH_CLIENT_SECRET`

If any are missing, stop and report:
```
Error: Missing Microsoft Graph credentials in ~/.model-citizen/env
Required: MS_GRAPH_CLIENT_ID, MS_GRAPH_TENANT_ID, MS_GRAPH_CLIENT_SECRET
See existing scan-outlook.sh for setup instructions.
```

### Step 2: Acquire OAuth access token

Use the client credentials flow (same as existing scan-outlook.sh):

```bash
source ~/.model-citizen/env

TOKEN_RESPONSE=$(curl -s -X POST \
  "https://login.microsoftonline.com/${MS_GRAPH_TENANT_ID}/oauth2/v2.0/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=${MS_GRAPH_CLIENT_ID}" \
  -d "client_secret=${MS_GRAPH_CLIENT_SECRET}" \
  -d "scope=https://graph.microsoft.com/.default" \
  -d "grant_type=client_credentials")

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('access_token',''))")

if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "Auth failed: $(echo "$TOKEN_RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('error_description','unknown error'))")"
  exit 1
fi
```

### Step 3: Load scan state

Read `~/.model-citizen/outlook-intelligence-state.json`. If absent, initialize it:
```json
{"last_scan_ts": 0, "seen_ids": []}
```

Parse `last_scan_ts` (Unix timestamp float) and `seen_ids` (array of message ID strings).

Convert `last_scan_ts` to ISO 8601 for the Graph API filter:
```python
import datetime
if last_scan_ts > 0:
    dt = datetime.datetime.utcfromtimestamp(last_scan_ts)
    last_scan_iso = dt.strftime("%Y-%m-%dT%H:%M:%SZ")
else:
    last_scan_iso = "2024-01-01T00:00:00Z"  # Floor to avoid pulling all mail
```

### Step 4: Fetch emails from Graph API

```bash
RESPONSE=$(curl -s -X GET \
  "https://graph.microsoft.com/v1.0/me/messages?\$select=id,subject,body,from,receivedDateTime&\$filter=receivedDateTime%20ge%20${LAST_SCAN_ISO}&\$top=50&\$orderby=receivedDateTime%20desc" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Prefer: outlook.body-content-type=\"text\"")
```

The `Prefer: outlook.body-content-type="text"` header requests plain text body content. If the header is honored, `body.content` will be plain text. If not honored (some tenants), strip HTML in Step 5.

Parse the response:
```python
import json
data = json.loads(response_text)
messages = data.get("value", [])
```

Filter messages: skip any whose `id` is already in `seen_ids`.

If 0 new messages after filtering, report "0 new emails since last scan" and stop.

### Step 5: Extract and clean email body

For each new message:

```python
body_content = message["body"]["content"]
body_type = message["body"]["contentType"]  # "text" or "html"

if body_type == "html" or "<" in body_content:
    # Strip HTML tags using Python html.parser
    from html.parser import HTMLParser

    class TextExtractor(HTMLParser):
        def __init__(self):
            super().__init__()
            self.text_parts = []
        def handle_data(self, data):
            self.text_parts.append(data)
        def get_text(self):
            return " ".join(self.text_parts).strip()

    extractor = TextExtractor()
    extractor.feed(body_content)
    plain_text = extractor.get_text()
    # Clean up excessive whitespace
    import re
    plain_text = re.sub(r'\s+', ' ', plain_text).strip()
else:
    plain_text = body_content.strip()
```

Also extract:
- `sender_email = message["from"]["emailAddress"]["address"]`
- `subject = message["subject"]`
- `received_date = message["receivedDateTime"][:10]`  # YYYY-MM-DD

### Step 6: Write vault source notes

**Vault base path:** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/700 Model Citizen/`
**Target folder:** `sources/outlook/` (write directly — do not rely on ANM to move files)

**Generate filename:** `Email - {YYYY-MM-DD} - {sanitized-subject}.md`
- Date: `received_date` (YYYY-MM-DD)
- Sanitized subject: lowercase, strip special chars, spaces→hyphens, truncate at 60 chars

**Write the note with this EXACT frontmatter format:**
```markdown
---
title: "Email: {subject}"
type: source/outlook
created: {YYYY-MM-DD}
content_status: raw
publishability: private
provenance:
  sender: {sender_email}
  subject: "{subject}"
  date: "{received_date}"
tags: [type/source/outlook]
---

{plain_text email body}
```

**CRITICAL CONSTRAINTS:**
- Notes MUST include BOTH `type: source/outlook` (YAML field) AND `tags: [type/source/outlook]` (Obsidian routing tag)
- `publishability` is ALWAYS `private` — no exceptions for source notes
- `content_status` is ALWAYS `raw` for newly created source notes
- Email body in vault notes must contain NO HTML tags — strip before writing
- Write to `sources/outlook/` directly, not vault root

### Step 7: Update state file atomically

After processing ALL messages, build a complete new JSON state object:

```python
import json, time, os

state_path = os.path.expanduser("~/.model-citizen/outlook-intelligence-state.json")

with open(state_path) as f:
    state = json.load(f)

new_ids = list(set(state["seen_ids"] + [msg["id"] for msg in processed_messages]))
new_state = {
    "last_scan_ts": time.time(),
    "seen_ids": new_ids
}

with open(state_path, "w") as f:
    json.dump(new_state, f, indent=2)
```

DO NOT append to the state file. Always read → compute → write a complete new JSON object.

### Step 8: Report results

Print a summary:
```
Outlook Intelligence Scan Complete
────────────────────────────────────
New notes created: {N}
  • {note-filename-1}
  • {note-filename-2}
Already seen (skipped): {M}
Errors: {0 or error description}

State updated: ~/.model-citizen/outlook-intelligence-state.json
```

If N=0: "No new emails since last scan. State not updated."
