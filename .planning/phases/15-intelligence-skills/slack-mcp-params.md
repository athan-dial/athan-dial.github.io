# Slack MCP Parameter Verification

**Date:** 2026-03-01
**Investigated by:** Phase 15-01 executor

## Discovery Result

**Slack MCP server is NOT configured in this Claude Code environment.**

Checked: `~/Library/Application Support/Claude/claude_desktop_config.json`
MCP servers found: `obsidian`, `things` — no `slack` server.

## Verified Tool Availability

| Tool | Available | Notes |
|------|-----------|-------|
| mcp__slack__* | No | No Slack MCP server configured |
| Slack REST API via curl | Yes | Requires SLACK_BOT_TOKEN in ~/.model-citizen/env |

## Fallback Strategy

Since `slack_get_starred_items` MCP tool is not available, the scanner uses the Slack REST API directly via `curl`.

**Verified Slack REST API endpoints and parameters:**

### Starred Items (Saved Items)
```
GET https://slack.com/api/stars.list
Authorization: Bearer {SLACK_BOT_TOKEN}
```

Parameters:
- `count` (integer): Number of items to return, max 100
- `page` (integer): Page number (1-based)
- No timestamp filter — must filter by `date_create` in response

Response shape:
```json
{
  "ok": true,
  "items": [
    {
      "type": "message",
      "message": {
        "type": "message",
        "text": "full message text here",
        "user": "U1234567",
        "ts": "1708579200.000000",
        "thread_ts": "1708579100.000000",
        "permalink": "https://workspace.slack.com/archives/C123/p1708579200000000"
      },
      "channel": "C1234567890",
      "date_create": 1708580000
    }
  ],
  "paging": {
    "count": 100,
    "total": 5,
    "page": 1,
    "pages": 1
  }
}
```

**Note:** `stars.list` does not support `oldest_ts` filtering. The scanner must:
1. Fetch all starred items (paginated with `count=100`)
2. Filter locally: `date_create > last_scan_ts`
3. Or use `seen_ids` set to skip already-processed message timestamps

### User Display Name Resolution
```
GET https://slack.com/api/users.info?user={user_id}
Authorization: Bearer {SLACK_BOT_TOKEN}
```

Response: `user.profile.display_name` or `user.profile.real_name`

### Channel Name Resolution
```
GET https://slack.com/api/conversations.info?channel={channel_id}
Authorization: Bearer {SLACK_BOT_TOKEN}
```

Response: `channel.name`

## Key Field Mappings

| SCHEMA.md Field | Slack API Field | Notes |
|-----------------|-----------------|-------|
| `provenance.channel` | `conversations.info channel.name` | Resolve from channel ID |
| `provenance.sender` | `users.info user.profile.display_name` | Resolve from user ID |
| `provenance.timestamp` | `items[].message.ts` | Already epoch string format |
| `provenance.thread_ts` | `items[].message.thread_ts` | May be absent for non-threaded |
| `provenance.permalink` | `items[].message.permalink` | Direct from API |
| `provenance.starred_reason` | Not available from API | Use empty string `""` |

## Idempotency Strategy

Use `message.ts` as the unique ID stored in `seen_ids`:
- Check `ts` against `seen_ids` before processing
- Skip if already in `seen_ids`
- Append `ts` to `seen_ids` after successful note write

## Required Environment Variable

The scanner command must instruct Claude to read `SLACK_BOT_TOKEN` from `~/.model-citizen/env`.

If `SLACK_BOT_TOKEN` is absent, the command should report an error with setup instructions:
```
Error: SLACK_BOT_TOKEN not found in ~/.model-citizen/env
Add it with: echo "SLACK_BOT_TOKEN=xoxb-..." >> ~/.model-citizen/env
Get token from: https://api.slack.com/apps → Your App → OAuth & Permissions
Required scopes: stars:read, users:read, channels:read
```
