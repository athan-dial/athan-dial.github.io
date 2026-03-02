---
created: 2026-03-02T14:04:37.385Z
title: Convert outlook_email_search to MCP method
area: tooling
files:
  - .claude/commands/scan-outlook-intelligence.md
---

## Problem

The `scan-outlook-intelligence` skill was originally written to use a `outlook_email_search` MCP tool and `read_resource(uri: "mail:///...")` that don't exist in the current setup. The skill has been updated to use the AppleScript MCP as a workaround, but a proper Outlook/Microsoft 365 MCP server would be a cleaner solution.

Options to explore:
1. Add the Microsoft 365 MCP server to `~/.claude/mcp.json` (requires M365 app registration or token)
2. Use the Anthropic knowledge-work-plugins Outlook connector (seen referenced by William Hayes in #team-schema)
3. Keep the AppleScript approach but verify it works end-to-end with Outlook running

## Solution

If a proper M365 MCP becomes available, update `scan-outlook-intelligence.md` to replace the AppleScript steps (Steps 2–3) with direct `outlook_email_search` and `read_resource` calls. The filtering, vault writing, and state management steps (4–7) can remain unchanged.
