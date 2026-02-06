# Phase 8: Review & Approval Dashboard - Research

**Researched:** 2026-02-06
**Domain:** Workflow documentation and vault-native approval UX
**Confidence:** HIGH

## Summary

Phase 8 implements the human approval gate between content enrichment and publishing. The core insight is that this phase is about **workflow documentation and UX clarity**, not building complex custom dashboards. The user needs a simple, explicit way to signal "I approve this content for publication" that prevents accidental publishing while keeping the approval process friction-free.

Research reveals that the best practices for content approval workflows emphasize clarity of intent, minimal friction, and explicit rather than implicit approval. The folder-based approach (moving files) and frontmatter-based approach (setting status flags) both have strong precedents in digital asset management systems, where metadata triggers workflow actions and file locations signal intent.

The vault itself (Obsidian) serves as the approval interface, leveraging native features like Dataview for dashboards, folder navigation for organization, and frontmatter editing for status changes. This avoids building custom web UIs while providing a professional, Git-tracked approval audit trail.

**Primary recommendation:** Document the dual approval workflow (folder-based OR frontmatter-based), create a simple Dataview dashboard showing pending drafts, and implement an approval checklist template that guides review before publishing. No custom web UI needed for v1.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Approval Methods:**
- Method 1 (Primary): Folder-based - User moves draft from `/drafts/` to `/publish_queue/`
- Method 2 (Secondary): Frontmatter-based - User sets `status: publish` in frontmatter
- Both methods work together: Either action triggers publishing

**Review Workflow:**
1. User checks `/drafts/` folder for new drafts from Claude Code
2. Reads draft + related source notes
3. Can refine, edit, remove sections
4. When satisfied: moves to `/publish_queue/` OR sets `status: publish`
5. Publish sync runs (automatic or manual)

**Publishing Rules:**
- Content is included in publish sync if it's in `/publish_queue/` folder AND/OR frontmatter has `status: publish`
- Everything else stays in Vault (private)

**Approval Checkpoints (pre-publish verification):**
- [ ] Draft is complete and well-written
- [ ] Sources/citations are accurate
- [ ] No sensitive information (private thoughts, confidential details)
- [ ] Title is clear and compelling
- [ ] Related links back to source vault notes are correct

**Comms to n8n:**
- n8n respects the publish gate: never moves drafts to `/publish_queue/` automatically
- n8n only moves to `/publish_queue/` if user explicitly asks (future feature, not Phase 8)
- Default: drafts stay in `/drafts/` until human decision

**No custom dashboard yet:** Phase 8 documents the process using native Vault (Obsidian) as the interface.

### Claude's Discretion

- Whether to create a visual dashboard or keep vault-only review
- How to format approval checklists
- Whether to notify user when new drafts are ready (email, log message, etc.)
- How long to keep unpublished drafts before archiving

### Deferred Ideas (OUT OF SCOPE)

- Custom approval dashboard (web UI showing pending drafts, sources, approval status)
- Automated approval rules (e.g., auto-publish if idea score > 8)
- Approval workflows with multiple reviewers
- Draft preview in Quartz before final publish
- Email notifications on new drafts

</user_constraints>

## Standard Stack

The established tools for vault-native approval workflows:

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| Obsidian | Latest | Vault interface and review workspace | Native markdown editor with frontmatter support, folder navigation, plugins |
| Dataview Plugin | Latest | Dynamic dashboard queries | Most popular Obsidian dashboard plugin, SQL-like queries for frontmatter filtering |
| YAML Frontmatter | N/A | Structured metadata format | Universal markdown metadata standard, Git-trackable, human-readable |
| File System Operations | N/A | Folder-based approval (move/copy) | OS-level safety, Git-trackable, no abstraction layer needed |

### Supporting
| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| Markdown Templates | N/A | Checklist templates for review | Standardize approval criteria across all drafts |
| Git Logs | N/A | Audit trail for file moves and edits | Track who approved what and when (via commit history) |
| Dataview JS | Latest | Complex dashboard logic if needed | When table/list queries insufficient for dashboard needs |
| Obsidian Tasks Plugin | Latest | Task management for review todos | If approval requires multi-step review process |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Vault-native UI | Custom web dashboard | Web UI adds complexity, breaks vault-centric workflow, requires separate auth |
| Dual approval (folder + frontmatter) | Single method only | Dual approach gives flexibility: folder for visual organization, frontmatter for programmatic filtering |
| Manual file moves | Automated approval rules | Manual preserves editorial control, prevents accidental publication |
| Dataview dashboards | Obsidian Graph View | Graph shows connections but not actionable review queue |

**Installation:**
```bash
# Obsidian with Dataview plugin (community plugin)
# Install via Obsidian Settings → Community Plugins → Browse → Dataview

# No additional dependencies - uses existing vault structure
```

## Architecture Patterns

### Recommended Project Structure
```
~/model-citizen-vault/
├── drafts/                    # Drafts awaiting review
│   ├── draft-topic-1.md       # Each draft has checklist in frontmatter
│   └── draft-topic-2.md
├── publish_queue/             # Approved drafts ready to publish
│   └── approved-draft.md      # Moved here after review
├── sources/                   # Source material for reference during review
│   └── youtube/
├── ideas/                     # Idea cards that inspired drafts
│   └── idea-card-*.md
├── .templates/                # Obsidian templates
│   ├── draft-template.md      # Includes approval checklist
│   └── review-dashboard.md    # Dataview dashboard template
└── .enrichment/
    └── logs/                  # Daily enrichment logs (from Phase 7)
        └── .enrichment-daily-*.md
```

### Pattern 1: Dual Approval Mechanism
**What:** Support both folder-based and frontmatter-based approval signals
**When to use:** Always - gives users flexibility in workflow preference
**Example:**

**Method 1 - Folder-based approval:**
```bash
# User action in Obsidian file explorer
mv ~/model-citizen-vault/drafts/my-draft.md ~/model-citizen-vault/publish_queue/

# Or in Obsidian: Drag file from /drafts/ to /publish_queue/ folder
```

**Method 2 - Frontmatter-based approval:**
```yaml
---
title: "My Draft"
date: 2026-02-06
status: publish  # Changed from "draft" to "publish"
reviewed_at: 2026-02-06T14:30:00Z
reviewed_by: human
---
```

**Combined check in publish sync (Phase 9):**
```bash
# Publish sync should check BOTH conditions:
# 1. Is file in /publish_queue/ folder?
# 2. Does frontmatter have status: publish?
# If EITHER is true → include in publish sync
```

### Pattern 2: Approval Checklist Template
**What:** Frontmatter-embedded checklist that guides pre-publish review
**When to use:** Every draft created by enrichment pipeline
**Example:**

```markdown
---
title: "Draft Title"
date: 2026-02-06
status: draft
source_note: "[[source-youtube-video]]"
idea_card: "[[idea-card-1]]"
approval_checklist:
  - "[ ] Draft is complete and well-written"
  - "[ ] Sources/citations are accurate"
  - "[ ] No sensitive information exposed"
  - "[ ] Title is clear and compelling"
  - "[ ] Related links to vault notes work"
ready_to_publish: false
---

# Draft Content

[Content here]

## Review Notes
<!-- User adds review comments here before approving -->
```

### Pattern 3: Dataview Review Dashboard
**What:** Dynamic list of pending drafts with review status
**When to use:** As vault home screen or pinned note for daily review
**Example:**

**File:** `~/model-citizen-vault/_review-dashboard.md`
```markdown
# Content Review Dashboard

## Pending Drafts (Awaiting Review)

```dataview
TABLE
  date as "Created",
  source_note as "Source",
  approval_checklist as "Checklist"
FROM "drafts"
WHERE status = "draft"
SORT date DESC
```

## Approved for Publishing

```dataview
TABLE
  date as "Created",
  reviewed_at as "Approved"
FROM "publish_queue"
SORT reviewed_at DESC
LIMIT 10
```

## Recent Enrichment Activity

```dataview
TABLE
  date as "Created",
  status as "Status"
FROM "sources"
WHERE status = "enriched" AND date > date(today) - dur(7 days)
SORT date DESC
```
```

**Obsidian will render this as three interactive tables showing review queue status.**

### Pattern 4: Approval Workflow Documentation
**What:** Clear written instructions for approval process
**When to use:** In vault README or workflow documentation
**Example:**

**File:** `~/model-citizen-vault/README.md` (excerpt)
```markdown
## Approval Workflow

### How to Approve Content for Publishing

1. **Review new drafts:**
   - Open `_review-dashboard.md` to see pending drafts
   - OR check `/drafts/` folder manually

2. **Read draft and verify:**
   - [ ] Draft is complete and well-written
   - [ ] Sources/citations are accurate (click [[links]] to verify)
   - [ ] No sensitive information exposed
   - [ ] Title is clear and compelling
   - [ ] Related links back to vault notes work

3. **Refine if needed:**
   - Edit draft content directly
   - Add review notes at bottom of file
   - Update frontmatter metadata if needed

4. **Approve via ONE of these methods:**

   **Option A - Folder-based (Visual):**
   - Drag draft from `/drafts/` to `/publish_queue/` in file explorer

   **Option B - Frontmatter-based (Programmatic):**
   - Change frontmatter: `status: draft` → `status: publish`
   - Add `reviewed_at: [current timestamp]`
   - Add `reviewed_by: human`

5. **Publish sync runs:**
   - Manual: Run publish sync script (Phase 9)
   - Automatic: Daily n8n workflow (Phase 10+)
```

### Pattern 5: Audit Trail via Git Commits
**What:** Git history as approval audit trail
**When to use:** Always - automatic with vault Git repo
**Example:**

```bash
# Example git log showing approval actions:

commit abc123...
Author: Athan Dial <email>
Date:   2026-02-06 14:30:00

    docs: approve draft for publication

    Moved drafts/ai-workflow-systems.md to publish_queue/
    - Verified sources and citations
    - Confirmed no sensitive info
    - Ready for Quartz publish

commit def456...
Author: Athan Dial <email>
Date:   2026-02-06 14:15:00

    content: refine draft before approval

    - Clarified technical section
    - Added timestamp to key quote
    - Fixed wikilink to source note
```

**Querying approval history:**
```bash
# Show all approvals (moves to publish_queue)
git log --all --oneline --grep="publish_queue"

# Show approvals in last 7 days
git log --since="7 days ago" --grep="publish_queue" --format="%h %ad %s" --date=short

# Show what was approved
git log --stat -- publish_queue/
```

### Anti-Patterns to Avoid

- **Implicit approval:** Never auto-publish without explicit human signal (defeats safety gate purpose)
- **Scattered approval state:** Don't use tags, notes, external databases - folder + frontmatter is sufficient
- **Complex multi-stage workflows:** v1 should be simple: draft → approve → publish (no intermediate review states)
- **Approval without context:** Always link draft back to source notes and idea cards for verification
- **Silent failures:** If draft has broken links or missing sources, flag for human attention (don't auto-approve)

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Dynamic dashboards in markdown | Custom JavaScript widgets | Dataview plugin queries | Battle-tested, maintainable, community-supported, no custom code |
| Approval notification system | Custom email/webhook integration | Git commit hooks + daily review dashboard | Simpler, Git-native, no external dependencies |
| File move automation | Custom scripts to move files | Manual file operations + Git tracking | Prevents accidental approval, maintains human-in-loop |
| Approval audit trail | Custom database or log files | Git commit history | Immutable, distributed, standard tooling, free |
| Dashboard UI rendering | Custom React/Vue dashboard | Obsidian native UI + Dataview | No build step, no deployment, works offline |

**Key insight:** Vault-native workflows avoid the complexity, maintenance burden, and authentication overhead of custom web dashboards. The approval interface IS the vault interface - leveraging Obsidian's mature ecosystem.

## Common Pitfalls

### Pitfall 1: Over-Engineering the Approval UI
**What goes wrong:** Building custom web dashboards, complex approval systems, multi-reviewer workflows before they're needed
**Why it happens:** Assumption that "professional workflow" requires separate tooling from content creation
**How to avoid:**
- Start with vault-native approach (Dataview dashboards, folder moves)
- Only build custom UI if vault workflow proves insufficient (measure: 50+ drafts pending, multiple reviewers, etc.)
- Remember: Phase 8 is about **documenting workflow**, not building infrastructure
**Warning signs:**
- Spending more than 1 day on Phase 8 implementation
- Introducing authentication, databases, or web frameworks
- Creating tools the user will use less than once per week

### Pitfall 2: Approval Without Context
**What goes wrong:** User reviews draft but can't easily verify sources, check related idea cards, or trace back to original material
**Why it happens:** Draft files are isolated from their lineage (source notes, idea cards, enrichment metadata)
**How to avoid:**
- Always include frontmatter links: `source_note`, `idea_card`, `related_notes`
- Use Obsidian wikilinks `[[note-name]]` for one-click navigation
- Approval checklist should prompt verification of sources/citations
- Consider adding "Review Context" section at top of draft template
**Warning signs:**
- User has to search vault to find source material
- Draft lacks backlinks to originating notes
- Approval checklist doesn't mention source verification

### Pitfall 3: Conflicting Approval Signals
**What goes wrong:** Draft is in `/publish_queue/` but frontmatter says `status: draft`, or vice versa
**Why it happens:** Dual approval methods (folder + frontmatter) can get out of sync
**How to avoid:**
- Publish sync treats conditions as OR not AND: `if (in_publish_queue OR status==publish) → publish`
- Document that either method is sufficient (user doesn't need both)
- Optionally: Add helper script that syncs frontmatter status when file moved to `/publish_queue/`
**Warning signs:**
- User confusion about "which method to use"
- Publish sync logic gets complicated with edge case handling
- Drafts in `/publish_queue/` don't publish because status field wasn't updated

### Pitfall 4: No Approval Audit Trail
**What goes wrong:** Can't answer "Who approved this?" or "When was this approved?" or "What changed before approval?"
**Why it happens:** File moves and edits happen without Git commits
**How to avoid:**
- Commit vault changes regularly (manual or via Git auto-commit plugin)
- Commit message conventions: `docs: approve [draft-name] for publication`
- Add frontmatter fields: `reviewed_at`, `reviewed_by` (timestamp and human identifier)
- Consider Git pre-commit hook that adds review metadata automatically
**Warning signs:**
- Git history shows large batch commits with generic messages
- Can't trace approval decisions back to specific changes
- No timestamp tracking for approval events

### Pitfall 5: Approval Checklist Theater
**What goes wrong:** Checklist exists but user doesn't actually complete it before approving
**Why it happens:** Checklist is buried in frontmatter or template, no enforcement mechanism
**How to avoid:**
- Make checklist visible and interactive (use Obsidian task syntax: `- [ ]`)
- Consider adding `approval_checklist_completed: false` frontmatter field
- Publish sync could warn (but not block) if checklist incomplete
- Keep checklist short (5 items max) so it's not burdensome
**Warning signs:**
- Checklist always blank or unchecked in published content
- User skips checklist step entirely
- Checklist has 20+ items that take 30+ minutes to complete

## Code Examples

Verified patterns from research and prior phases:

### Example 1: Draft Template with Approval Checklist
**File:** `~/model-citizen-vault/.templates/draft-template.md`
```markdown
---
title: "{{title}}"
date: {{date}}
status: draft
source_note: "[[{{source}}]]"
idea_card: "[[{{idea}}]]"
author: Model Citizen
approval_checklist:
  complete: false
  items:
    - "[ ] Draft is complete and well-written"
    - "[ ] Sources/citations are accurate"
    - "[ ] No sensitive information exposed"
    - "[ ] Title is clear and compelling"
    - "[ ] Related links to vault notes work"
reviewed_at: null
reviewed_by: null
tags: [draft, pending-review]
---

# {{title}}

<!-- Generated from idea card: [[{{idea}}]] -->
<!-- Source material: [[{{source}}]] -->

## Introduction

[Hook and context]

## Main Content

[Core argument/insights]

## Takeaways

[Key points]

## References

- Source: [[{{source}}]]
- Related: [[{{related}}]]

---

## Review Notes (Human)

<!-- Add review comments here before approving -->

**Pre-publish checklist:**
- [ ] Draft is complete and well-written
- [ ] Sources/citations are accurate
- [ ] No sensitive information exposed
- [ ] Title is clear and compelling
- [ ] Related links to vault notes work

**Approval action:**
- [ ] Move to `/publish_queue/` OR
- [ ] Set `status: publish` in frontmatter
```

### Example 2: Dataview Dashboard for Pending Reviews
**File:** `~/model-citizen-vault/_review-dashboard.md`
```markdown
# Content Review Dashboard

Last updated: `= date(today)`

## 📝 Pending Drafts (Action Required)

Drafts awaiting human review and approval:

```dataview
TABLE
  date as "Created",
  source_note as "Source",
  idea_card as "Idea",
  file.mtime as "Modified"
FROM "drafts"
WHERE status = "draft"
SORT date DESC
```

## ✅ Approved & Ready to Publish

Content in publish queue:

```dataview
TABLE
  date as "Created",
  reviewed_at as "Approved",
  reviewed_by as "Reviewer"
FROM "publish_queue"
WHERE status = "publish" OR contains(file.folder, "publish_queue")
SORT reviewed_at DESC
LIMIT 10
```

## 🔄 Recent Enrichment Activity

Sources enriched in last 7 days:

```dataview
TABLE
  date as "Created",
  status as "Status",
  file.mtime as "Enriched"
FROM "sources"
WHERE status = "enriched" AND date >= date(today) - dur(7 days)
SORT date DESC
LIMIT 15
```

## 💡 Idea Cards Generated (Not Yet Drafted)

```dataview
LIST
FROM "ideas"
WHERE !contains(file.outlinks, "drafts")
SORT date DESC
LIMIT 10
```

---

## How to Approve Content

1. Click a draft title above to open it
2. Review content and complete checklist
3. Approve via:
   - **Method A:** Move file to `/publish_queue/` folder
   - **Method B:** Change frontmatter `status: draft` → `status: publish`
4. Publish sync will export to Quartz (Phase 9)

See [[Approval Workflow Documentation]] for details.
```

### Example 3: Publish Sync Filter Logic (Phase 9 Preview)
```bash
#!/bin/bash
# publish-sync.sh - Export approved content to Quartz
# Phase 9 implementation preview

VAULT_DIR="$HOME/model-citizen-vault"
QUARTZ_DIR="$HOME/quartz-site"

# Find all approved content (dual condition check)
find_approved_content() {
  local approved_files=()

  # Method 1: Files in /publish_queue/ folder
  while IFS= read -r -d '' file; do
    approved_files+=("$file")
  done < <(find "$VAULT_DIR/publish_queue" -name "*.md" -print0)

  # Method 2: Files with status: publish in frontmatter (any folder)
  while IFS= read -r file; do
    if grep -q "^status: publish" "$file"; then
      approved_files+=("$file")
    fi
  done < <(find "$VAULT_DIR" -name "*.md" -not -path "*/publish_queue/*")

  # Return unique list
  printf '%s\n' "${approved_files[@]}" | sort -u
}

# Main sync logic
main() {
  echo "Checking for approved content..."

  approved_content=$(find_approved_content)

  if [[ -z "$approved_content" ]]; then
    echo "No approved content found. Nothing to publish."
    exit 0
  fi

  echo "Found approved content:"
  echo "$approved_content"

  # Phase 9 will implement actual sync logic here
  # For now, just list what would be published
}

main "$@"
```

### Example 4: Helper Script - Sync Approval State
```bash
#!/bin/bash
# sync-approval-state.sh - Ensure frontmatter matches folder location
# Optional utility to keep dual approval methods in sync

VAULT_DIR="$HOME/model-citizen-vault"

# Update frontmatter when file moved to publish_queue
sync_approval_state() {
  local file="$1"
  local folder=$(dirname "$file")

  if [[ "$folder" == *"/publish_queue"* ]]; then
    # File is in publish queue - ensure frontmatter reflects this
    python3 "$VAULT_DIR/scripts/update-frontmatter.py" \
      --source "$file" \
      --field "status" \
      --value "publish" \
      --field "reviewed_at" \
      --value "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --field "reviewed_by" \
      --value "human"

    echo "✓ Synced approval state for: $(basename "$file")"
  fi
}

# Process all files in publish_queue
while IFS= read -r -d '' file; do
  sync_approval_state "$file"
done < <(find "$VAULT_DIR/publish_queue" -name "*.md" -print0)
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Custom web dashboards for content approval | Vault-native UI with Dataview queries | 2024-2025 | Reduced complexity, better integration with writing workflow |
| Database-backed approval state | Frontmatter + Git history as audit trail | 2023-2024 | Eliminated external dependencies, Git-native versioning |
| Single approval method (folder OR metadata) | Dual approval (folder AND/OR metadata) | 2025-2026 | User flexibility, accommodates different workflow preferences |
| Manual checklist enforcement | Template-embedded checklists | 2025+ | Standardization, reduced human error, better consistency |

**Deprecated/outdated:**
- Separate approval tools: Modern approach embeds approval in content management system itself
- Implicit approval via automation: Best practices now emphasize explicit human signals (safety gates)
- Complex multi-stage approval: Simple draft → approve → publish workflow sufficient for individual creators

## Open Questions

Things that couldn't be fully resolved:

1. **Notification mechanism for new drafts**
   - What we know: User needs to be alerted when enrichment pipeline creates drafts requiring review
   - What's unclear: Best notification method (email, Obsidian plugin, daily dashboard check, git hook)
   - Recommendation: Start with manual dashboard check (open `_review-dashboard.md` daily). Add notifications only if user misses drafts frequently. LOW priority for Phase 8.

2. **Draft archival strategy**
   - What we know: Unpublished drafts accumulate in `/drafts/` folder over time
   - What's unclear: How long to keep unpublished drafts, where to archive, whether to delete
   - Recommendation: Manual archival for v1. Add `draft_age_days` field to dashboard query. User moves stale drafts to `/archive/` folder when needed. Automation deferred to v2.

3. **Approval undo/revision workflow**
   - What we know: User might approve draft, then realize it needs changes after publish
   - What's unclear: Should there be explicit "unpublish" action, or just edit + recommit?
   - Recommendation: Edit published content directly in `/publish_queue/`, commit changes, re-run publish sync. No formal "unpublish" workflow needed - Git history tracks revisions naturally.

4. **Collaborative approval (future)**
   - What we know: Phase 8 assumes single user/reviewer
   - What's unclear: How to support multiple reviewers, approval voting, role-based permissions
   - Recommendation: Out of scope for Phase 8. Vault-native approach (Git collaboration, PR-based review) sufficient for future multi-user scenarios. Defer to v2+.

## Sources

### Primary (HIGH confidence)

- [Content Approval Workflow Best Practices - Planable](https://planable.io/blog/content-approval-workflow/) - Approval workflow design principles
- [How to Implement an Editorial QA Checklist - EasyContent](https://easycontent.io/resources/how-to-implement-an-editorial-qa-checklist/) - Checklist design patterns
- [Audit Trail Requirements - Inscope](https://www.inscopehq.com/post/audit-trail-requirements-guidelines-for-compliance-and-best-practices) - Audit trail best practices
- [Append-Only Logs - Medium](https://medium.com/@komalshehzadi/append-only-logs-the-immutable-diary-of-data-58c36a871c7c) - Immutable audit log patterns
- [File Move vs Metadata Workflows - FileHold](https://www.filehold.com/blog/audit-records-document-version-changes-workflow-vs-metadata) - Dual approval mechanism research

### Secondary (MEDIUM confidence)

- [Obsidian Dataview Dashboards - XDA Developers](https://www.xda-developers.com/used-obsidians-dataview-plugin-live-dashboard/) - Dataview dashboard implementation
- [Obsidian Templates and Automation - dzhg.dev](https://dzhg.dev/posts/obsidian-templates-automation/) - Template best practices
- [Publishing Obsidian Vault with Quartz - Brandon Boswell](https://brandonkboswell.com/blog/Publishing-your-Obsidian-Vault-Online-with-Quartz) - Vault publishing patterns
- [Documentation-First Workflow Design - Medium](https://medium.com/@vishalmv211/how-to-design-your-workflow-automation-for-maximum-impact-in-2026-30673435978a) - Design before automation principle
- [Workflow Redesign Before Digitization - Quixy](https://quixy.com/blog/workflow-redesign-before-digitization) - Process design foundations

### Tertiary (LOW confidence)

- Web search results on Obsidian folder workflows, markdown frontmatter practices, and content review systems - Cross-referenced with official documentation where possible

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Obsidian + Dataview are established tools with mature ecosystems
- Architecture patterns: HIGH - Dual approval (folder + frontmatter) has precedent in digital asset management, Git audit trails are industry standard
- Pitfalls: MEDIUM - Based on general workflow design research and Phase 7 learnings, not Phase 8-specific experience
- Code examples: HIGH - Templates and Dataview queries follow documented patterns, frontmatter utility from Phase 7 is working

**Research date:** 2026-02-06
**Valid until:** 90 days (stable domain - approval workflows don't change rapidly)
