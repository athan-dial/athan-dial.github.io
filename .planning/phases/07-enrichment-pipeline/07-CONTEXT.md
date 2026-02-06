# Phase 7: Enrichment & Idea Generation - Context

**Gathered:** 2026-02-05
**Updated:** 2026-02-06
**Status:** Ready for planning

<domain>

## Phase Boundary

Implement the AI-powered enrichment tasks using Claude Code: summarization, tagging, quote extraction, and idea card generation. Using the handoff pattern from Phase 6, n8n can now invoke these specific synthesis workflows.

This phase turns raw ingested content into **idea-generation-ready material**: summaries, structured metadata, blog angles, and draft outlines.

</domain>

<decisions>

## Implementation Decisions

### Enrichment Tasks

**Task 1: Summarization**
- Claude Code reads full transcript
- Produces 2-3 sentence summary capturing key insights
- Writes to frontmatter: `summary` field
- Output: Markdown with summary added

**Task 2: Tagging & Metadata**
- Extract 5-10 topic tags from content
- Identify key quotes (2-3) worth highlighting
- Extract key takeaways (3-5 bullet points)
- Writes to frontmatter: `tags`, `quotes`, `takeaways`
- Output: Markdown with enhanced frontmatter

**Task 3: Idea Card Generation**
- Generate 2-3 blog angles from the source
- For each angle: suggested title, outline (3-5 bullets), supporting sources to reference
- **Include rationale**: Why this angle is worth pursuing (unique perspective, shareability, fills gap)
- **Vault-aware synthesis**: Search existing notes for related content, suggest connections
- Prioritize: practical application, cross-domain insights, and context-appropriate angles
- Creates new file in `/ideas/` folder with this structure

**Task 4: Draft Scaffolding (Optional)**
- If user requests, Claude Code can create first draft outline
- Includes: title, intro hook, main sections, conclusion
- Uses citations/backlinks to original source
- Saves to `/drafts/` for user to refine

### Execution Order

**Hybrid orchestration**: Summary first, then parallel execution
1. Summarization runs first (quick context)
2. Tagging + Idea Generation run in parallel (both read source + summary)
3. Draft scaffolding only if manually requested

### Workflow Orchestration

**For each new ingested source:**
1. n8n checks if source has `status: enriched` (skip if already processed)
2. If not enriched: triggers Claude Code summarization task
3. Waits for summary completion
4. Triggers tagging + idea generation tasks **in parallel**
5. Updates source frontmatter with `status: enriched`
6. Logs completion to daily summary note (`.enrichment-daily-YYYY-MM-DD.md`)

**For backfill sources:**
- Manual trigger only (batch process old content as needed)
- Prevents quota exhaustion on large backfills

### Output Quality Control

**Light validation approach:**
- Check required fields exist: `summary`, `tags`, `quotes`, `ideas`
- Don't enforce strict format/quality (trust Claude, but verify basics)

**Quality flags:**
- Add `needs_review: true` flag if any of these detected:
  - **Generic language patterns**: Summary uses vague words ('interesting', 'explores', 'discusses') without specifics
  - **Low information density**: Summary could apply to many videos, doesn't capture unique insights
  - **Tag/quote issues**: Tags too broad (e.g., 'technology'), no quotes extracted, required fields empty
- User can batch-review flagged items later

**Failure handling:**
- If enrichment task fails validation: retry once automatically
- If still fails after retry: skip task, log error, continue workflow
- Partial enrichment is acceptable (better some data than blocking pipeline)

### Claude's Discretion

- Exact prompt engineering for summaries (length, detail level, style)
- Prompt structure: single vs modular, examples vs instruction-only
- Source material handling: inline vs file path reference
- Tag taxonomy (consistent vocab across all notes)
- Idea angle balance (when to favor practical vs synthesis vs contrarian)
- Draft outline depth (outline vs full draft)
- How to handle multi-part videos or long transcripts (summarize whole or by section)

</decisions>

<specifics>

## Specific Ideas

- **Ideas are the output:** The real value of enrichment is generating blog angles you wouldn't have seen. The summary is just supporting context.

- **You review and refine:** These AI-generated outputs are starting points. You'll read the ideas, pick the ones that resonate, and refine them before drafting.

- **Citations matter:** When Claude Code generates ideas or outlines, it should reference specific quotes/timestamps from the source so you can verify.

- **Vault synthesis is key:** Don't treat each source in isolation — find connections to existing notes, suggest synthesis opportunities, build on previous ideas.

</specifics>

<deferred>

## Deferred Ideas

- Automatic draft writing (full first draft, not just outline)
- Sentiment analysis or controversy detection
- Source clustering (finding related sources automatically)
- Personalized idea scoring based on your past writing
- Auto-tagging consistency checking (flag contradictory tags across notes)
- Real-time enrichment (trigger on ingestion instead of scheduled batch)

</deferred>

---

*Phase: 07-enrichment-pipeline*
*Context gathered: 2026-02-05*
*Context updated: 2026-02-06*
