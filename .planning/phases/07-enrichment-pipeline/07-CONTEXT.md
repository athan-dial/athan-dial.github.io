# Phase 7: Enrichment & Idea Generation - Context

**Gathered:** 2026-02-05
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
- Includes why each angle is interesting/valuable
- Creates new file in `/ideas/` folder with this structure

**Task 4: Draft Scaffolding (Optional)**
- If user requests, Claude Code can create first draft outline
- Includes: title, intro hook, main sections, conclusion
- Uses citations/backlinks to original source
- Saves to `/drafts/` for user to refine

### Execution Order
1. Summarization first (base output)
2. Tagging second (depends on summary)
3. Idea generation (can run in parallel with tagging)
4. Draft scaffolding only if requested

### n8n Workflow

For each ingested YouTube video:
1. n8n checks if source has `status: enriched` (already processed)
2. If not: triggers Claude Code summarization task
3. Waits for completion
4. Triggers tagging task
5. Triggers idea generation task
6. Updates source status to `enriched`
7. Logs completion in daily summary note

### Claude's Discretion

- Exact prompt engineering for summaries (length, detail level, style)
- Tag taxonomy (consistent vocab across all notes)
- Idea angle selection (what makes a good blog angle)
- Draft outline depth (outline vs full draft)
- How to handle multi-part videos or long transcripts (summarize whole or by section)

</decisions>

<specifics>

## Specific Ideas

- **Ideas are the output:** The real value of enrichment is generating blog angles you wouldn't have seen. The summary is just supporting context.

- **You review and refine:** These AI-generated outputs are starting points. You'll read the ideas, pick the ones that resonate, and refine them before drafting.

- **Citations matter:** When Claude Code generates ideas or outlines, it should reference specific quotes/timestamps from the source so you can verify.

</specifics>

<deferred>

## Deferred Ideas

- Automatic draft writing (full first draft, not just outline)
- Sentiment analysis or controversy detection
- Source clustering (finding related sources automatically)
- Personalized idea scoring based on your past writing
- Auto-tagging consistency checking (flag contradictory tags across notes)

</deferred>

---

*Phase: 07-enrichment-pipeline*
*Context gathered: 2026-02-05*
