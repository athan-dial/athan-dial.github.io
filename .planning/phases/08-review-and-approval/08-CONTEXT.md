# Phase 8: Review & Approval Dashboard - Context

**Gathered:** 2026-02-05
**Status:** Ready for planning

<domain>

## Phase Boundary

Document and implement the explicit approval workflow for publishing content. Users must consciously move drafts to the publish queue (or set frontmatter status) before content becomes public. This is the **safety gate** preventing accidental publication.

Phase 8 is about **workflow documentation and UX**, not building complex dashboards yet. It establishes how approval actually happens.

</domain>

<decisions>

## Implementation Decisions

### Approval Methods

**Method 1: Folder-based (Primary)**
- User moves draft from `/drafts/` to `/publish_queue/`
- This is the explicit intent signal
- Publish sync watches `/publish_queue/` and exports on-demand

**Method 2: Frontmatter-based (Secondary)**
- User can also set `status: publish` in frontmatter
- Publish sync recognizes this and includes in export
- Allows approval without moving file

**Both work together:** Either action triggers publishing. User chooses which feels more natural.

### Review Workflow

**Vault-based review:**
1. User checks `/drafts/` folder for new drafts from Claude Code
2. Reads draft + related source notes
3. Can refine, edit, remove sections
4. When satisfied:
   - Either moves to `/publish_queue/`
   - Or sets `status: publish` in frontmatter
5. Publish sync runs (automatic or manual)

**No custom dashboard yet.** Phase 8 documents the process using native Vault (Obsidian) as the interface. Phase 8+ could add a custom approval UI if needed.

### Publishing Rules (from Phase 4)

Content is included in publish sync if:
- It's in `/publish_queue/` folder, **AND/OR**
- Frontmatter has `status: publish`

Everything else stays in Vault (private).

### Approval Checkpoints

Before publishing, user should verify:
- [ ] Draft is complete and well-written
- [ ] Sources/citations are accurate
- [ ] No sensitive information (private thoughts, confidential details)
- [ ] Title is clear and compelling
- [ ] Related links back to source vault notes are correct

**Checklist can be added to draft template in Phase 8.**

### Comms to n8n

- n8n respects the publish gate: never moves drafts to `/publish_queue/` automatically
- n8n only moves to `/publish_queue/` if **you explicitly ask** (future feature, not Phase 8)
- Default: drafts stay in `/drafts/` until human decision

### Claude's Discretion

- Whether to create a visual dashboard or keep vault-only review
- How to format approval checklists
- Whether to notify user when new drafts are ready (email, log message, etc.)
- How long to keep unpublished drafts before archiving

</decisions>

<specifics>

## Specific Ideas

- **Explicit beats implicit:** The friction of moving a file or updating frontmatter is intentional. It prevents accidents.

- **Vault is your control center:** Everything stays in one place (Vault). You're not context-switching between multiple tools.

- **Approval is editorial, not technical:** This is where you decide what represents you, not where you fix code.

</specifics>

<deferred>

## Deferred Ideas

- Custom approval dashboard (web UI showing pending drafts, sources, approval status)
- Automated approval rules (e.g., auto-publish if idea score > 8)
- Approval workflows with multiple reviewers
- Draft preview in Quartz before final publish
- Email notifications on new drafts

</deferred>

---

*Phase: 08-review-and-approval*
*Context gathered: 2026-02-05*
