---
phase: 10-content-ingestion
plan: 03
subsystem: content-ingestion
tags: [slack-api, microsoft-graph, oauth, launchd, automation, bash]

# Dependency graph
requires:
  - phase: 10-01
    provides: "Vault structure with 700 Model Citizen/ and tag-based routing"
  - phase: 10-02
    provides: "capture-web.sh tool for URL ingestion with readability extraction"
provides:
  - "Slack saved items and boss DM scanner"
  - "Outlook email scanner via Microsoft Graph API"
  - "scan-all.sh orchestrator with resilient error handling"
  - "/scan Claude Code command for on-demand scanning"
  - "Daily 7 AM automated scanning via launchd"
affects: [enrichment-pipeline, content-curation]

# Tech tracking
tech-stack:
  added: [slack-web-api, microsoft-graph-api, launchd, jq]
  patterns:
    - "OAuth client credentials flow for Microsoft Graph"
    - "Incremental scanning with timestamp tracking"
    - "Graceful credential handling with skip-on-missing pattern"
    - "Color-coded logging with summary reports"

key-files:
  created:
    - "model-citizen/scripts/scan-slack.sh"
    - "model-citizen/scripts/scan-outlook.sh"
    - "model-citizen/scripts/scan-all.sh"
    - ".claude/commands/scan.md"
    - "~/Library/LaunchAgents/com.model-citizen.daily-scan.plist"
  modified: []

key-decisions:
  - "OAuth client credentials flow for Microsoft Graph (requires admin consent but no interactive login)"
  - "Incremental scanning via ~/.model-citizen/*-last-scan timestamp files"
  - "Continue-on-failure pattern in scan-all.sh (one source failure doesn't block others)"
  - "Dry-run mode for testing without API calls"
  - "Daily 7 AM execution via launchd (not cron)"

patterns-established:
  - "Scanner pattern: fetch → extract URLs → capture context → call capture-web.sh"
  - "Graceful credential handling: check env vars, skip with warning if missing"
  - "Color-coded logging: green success, yellow warnings, red errors, blue info"
  - "Summary reports: X URLs from Slack, Y from Outlook, Z from queue"

# Metrics
duration: 3min
completed: 2026-02-13
---

# Phase 10 Plan 03: Automated Slack and Outlook Content Scanning

**Slack and Outlook scanners extract boss-recommended URLs with context, orchestrated by scan-all.sh, triggered via /scan command or daily 7 AM launchd schedule**

## Performance

- **Duration:** 3 min
- **Started:** 2026-02-13T10:20:00Z
- **Completed:** 2026-02-13T10:23:53Z
- **Tasks:** 3 (2 auto + 1 human checkpoint)
- **Files created:** 5

## Accomplishments

- **Slack scanner** fetches saved items and boss DMs via Slack Web API, extracts URLs with surrounding message context
- **Outlook scanner** fetches boss emails via Microsoft Graph API, extracts URLs from HTML body with email subject/context
- **scan-all.sh orchestrator** runs all scanners with continue-on-failure resilience, produces summary report
- **/scan Claude Code command** provides on-demand scanning with optional enrichment workflow
- **Daily launchd schedule** automates scanning at 7 AM with logging to ~/.model-citizen/

## Task Commits

Each task was committed atomically:

1. **Task 1: Create Slack and Outlook scanners** - `d782a43` (feat)
2. **Task 2: Create /scan Claude command and launchd daily schedule** - `d02f524` (feat)
3. **Task 3: Verify complete ingestion system end-to-end** - User checkpoint approved ✓

## Files Created/Modified

**Created:**
- `model-citizen/scripts/scan-slack.sh` (218 lines) - Slack API scanner for saved items and boss DMs
- `model-citizen/scripts/scan-outlook.sh` (216 lines) - Microsoft Graph API scanner for boss emails
- `model-citizen/scripts/scan-all.sh` (173 lines) - Orchestrator with resilient error handling
- `.claude/commands/scan.md` (27 lines) - Claude Code slash command for on-demand scanning
- `~/Library/LaunchAgents/com.model-citizen.daily-scan.plist` (1418 bytes) - Daily 7 AM launchd schedule
- `model-citizen/scripts/env.example` - Documentation of all required credentials

**Total additions:** 607+ lines of scanner logic

## Decisions Made

1. **OAuth client credentials flow for Microsoft Graph**: Requires admin consent for Mail.Read application permission, but no interactive login needed. Documented device code flow alternative in comments for orgs that restrict app permissions.

2. **Incremental scanning with timestamps**: Each scanner tracks last scan time in `~/.model-citizen/{slack,outlook}-last-scan` files. Reduces API calls and avoids duplicate captures.

3. **Continue-on-failure pattern**: `scan-all.sh` runs all scanners even if one fails. Slack failure doesn't block Outlook, and vice versa. Resilient for automation.

4. **Graceful credential handling**: Scripts check for required env vars, skip with warning if missing. Allows dry-run testing without configured credentials.

5. **Daily 7 AM schedule via launchd**: Native macOS scheduling (not cron). Includes PATH for Homebrew binaries and logging to `~/.model-citizen/daily-scan.log`.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None. All scripts validated with `bash -n`, launchd plist validated with `plutil -lint`, dry-run mode tested successfully.

## User Setup Required

**External services require manual configuration.** The following credentials must be added to `~/.model-citizen/env`:

### Slack API
- `SLACK_BOT_TOKEN` - From Slack App admin page → OAuth & Permissions → Bot User OAuth Token (xoxb-...)
- `SLACK_BOSS_USER_ID` - From boss's Slack profile → More → Copy member ID
- **Setup:** Create Slack App with bot scopes: `stars:read`, `im:history`, `im:read`, `users:read`
- **Location:** https://api.slack.com/apps → Create New App

### Microsoft Graph API
- `MS_GRAPH_CLIENT_ID` - Azure AD → App registrations → Application (client) ID
- `MS_GRAPH_TENANT_ID` - Azure AD → App registrations → Directory (tenant) ID
- `MS_GRAPH_CLIENT_SECRET` - Azure AD → App registrations → Certificates & secrets → New client secret
- `MS_BOSS_EMAIL` - Boss's email address
- **Setup:** Register app in Azure AD with Mail.Read delegated permission (requires admin consent)
- **Location:** https://portal.azure.com → Azure Active Directory → App registrations

### Install Daily Automation
```bash
# Load launchd agent
launchctl load ~/Library/LaunchAgents/com.model-citizen.daily-scan.plist

# Test manually
launchctl start com.model-citizen.daily-scan

# View logs
tail -f ~/.model-citizen/daily-scan.log
```

## Technical Architecture

### Scanner Pattern
All scanners follow the same pattern:
1. **Fetch** - API call to retrieve recent content (saved items, DMs, emails)
2. **Filter** - Only process items since last scan (incremental)
3. **Extract URLs** - Regex for `http[s]://...` in message/email text
4. **Capture context** - Surrounding message/subject as "Boss said: ..."
5. **Call capture-web.sh** - For each URL with `--note` containing context
6. **Update timestamp** - Store scan time for next run

### Resilient Orchestration
`scan-all.sh` provides:
- **Continue-on-failure**: `|| true` pattern ensures one scanner failure doesn't block others
- **Credential isolation**: Each scanner checks its own env vars independently
- **Summary reporting**: Aggregates results (X URLs from Slack, Y from Outlook)
- **Dry-run mode**: `--dry-run` flag for testing without API calls

### OAuth Flow Notes
**Microsoft Graph client credentials flow:**
- **Pros**: No interactive login, works in automation
- **Cons**: Requires admin consent for application permission
- **Alternative**: Device code flow (interactive auth, token cached) - documented in comments if org restricts app permissions

## Human Verification Results

User verified complete ingestion system end-to-end:
1. ✅ 700 Model Citizen/ vault structure visible in Obsidian
2. ✅ Tag-based routing works (test note with #model-citizen/concept routed to 700 Model Citizen/concepts/)
3. ✅ Web capture works (`capture-web.sh "https://example.com"` created note in inbox)
4. ✅ Slack scanner syntax valid and credential handling graceful
5. ✅ /scan command available in Claude Code

**User approved checkpoint - all tests passed.**

## Next Phase Readiness

**Complete ingestion pipeline now operational:**
- ✅ Plan 01: Vault structure with tag-based routing
- ✅ Plan 02: Web article capture with share sheet queue
- ✅ Plan 03: Slack + Outlook scanners with daily automation

**Phase 10 objectives achieved:**
- Boss-recommended content (highest signal) can be captured automatically from Slack and Outlook
- Web articles can be captured manually via CLI or share sheet queue
- All content lands in vault inbox with proper metadata
- Tag-based routing moves content to appropriate 700 Model Citizen/ sections
- Daily automation ensures consistent scanning without manual intervention

**Ready for:**
- Phase 11: Model Citizen UI/UX (theming, vault integration, viewer experience)
- Enrichment pipeline integration (enrich newly captured notes after scanning)
- Content curation workflows (review inbox, tag, route to sections)

**Blockers:** None - full pipeline operational pending user credential configuration.

## Self-Check: PASSED

All claimed artifacts verified:

**Files:**
- ✓ `model-citizen/scripts/scan-slack.sh`
- ✓ `model-citizen/scripts/scan-outlook.sh`
- ✓ `model-citizen/scripts/scan-all.sh`
- ✓ `.claude/commands/scan.md`
- ✓ `~/Library/LaunchAgents/com.model-citizen.daily-scan.plist`

**Commits:**
- ✓ `d782a43` - feat(10-03): create Slack and Outlook scanners with scan-all orchestrator
- ✓ `d02f524` - feat(10-03): create /scan Claude command and launchd daily schedule

---
*Phase: 10-content-ingestion*
*Completed: 2026-02-13*
