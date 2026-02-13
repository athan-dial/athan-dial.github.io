# Model Citizen Content Scanner

Run the Model Citizen content scanner to pull new content from Slack, Outlook, and the capture queue.

## Execution

Execute: `/Users/adial/Documents/GitHub/athan-dial.github.io/model-citizen/scripts/scan-all.sh`

## Report After Scanning

After scanning completes, report:
- How many new URLs were captured from each source (Slack, Outlook, queue)
- Any errors or skipped items (missing credentials, API failures)
- Status of each scanner (SUCCESS, FAILED, SKIPPED)

## Show New Vault Notes

List the new notes created in the vault inbox:
- Path: `/Users/adial/Library/Mobile Documents/iCloud~md~obsidian/Documents/2B-new/000 System/01 Inbox/`
- Show files modified in the last 5 minutes

## Enrichment Prompt

After showing results, ask:
"Would you like to run enrichment on the new notes?"

If yes, execute the enrichment process for new inbox notes (future: call enrichment workflow).
