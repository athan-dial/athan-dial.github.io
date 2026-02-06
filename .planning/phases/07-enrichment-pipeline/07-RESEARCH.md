# Phase 7: Enrichment & Idea Generation - Research

**Researched:** 2026-02-06
**Domain:** AI-powered content enrichment, prompt engineering, workflow orchestration
**Confidence:** HIGH

## Summary

Phase 7 implements AI-powered enrichment tasks (summarization, tagging, idea generation, draft scaffolding) using Claude Code, orchestrated through n8n workflows established in Phase 6. The research reveals that successful enrichment pipelines require three critical components: (1) **structured prompt chaining** for multi-step synthesis tasks, (2) **YAML frontmatter manipulation** for metadata persistence, and (3) **graceful degradation** patterns for partial failures.

The 2026 landscape shows mature tooling: Claude's prompt chaining capabilities enable reliable multi-step workflows, python-frontmatter provides battle-tested metadata handling, and n8n's webhook-based synchronization supports hybrid orchestration (summary first, then parallel tasks). The key insight: **ideas are the output, not summaries** — enrichment value comes from blog angle discovery, not just metadata extraction.

Quality control research emphasizes **light validation with quality flags** over strict enforcement. Generic language detectors identify vague patterns ("interesting", "explores", "discusses"), but the user should decide whether to act on flagged content. Partial enrichment is preferable to blocking the entire pipeline on single-task failures.

**Primary recommendation:** Use Claude's prompt chaining pattern (separate prompts per task) with python-frontmatter for metadata, n8n's Execute Workflow + Wait nodes for parallel orchestration, and quality flags (not enforcement) for generic language detection.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Enrichment Tasks:**
- Task 1: Summarization (2-3 sentences, writes to `summary` frontmatter field)
- Task 2: Tagging & Metadata (5-10 tags, 2-3 quotes, 3-5 takeaways in frontmatter)
- Task 3: Idea Card Generation (2-3 blog angles with title, outline, rationale, vault-aware synthesis)
- Task 4: Draft Scaffolding (optional, manual trigger only)

**Execution Order:**
- Hybrid orchestration: Summary first, then parallel execution
- Summarization runs first (quick context)
- Tagging + Idea Generation run in parallel (both read source + summary)
- Draft scaffolding only if manually requested

**Workflow Orchestration:**
- n8n checks `status: enriched` (skip if already processed)
- Triggers summarization, waits for completion
- Triggers tagging + idea generation in parallel
- Updates frontmatter with `status: enriched`
- Logs to `.enrichment-daily-YYYY-MM-DD.md`
- Backfill: manual trigger only (prevents quota exhaustion)

**Output Quality Control:**
- Light validation: check required fields exist (`summary`, `tags`, `quotes`, `ideas`)
- Quality flags: Add `needs_review: true` for generic language, low information density, broad tags
- Failure handling: Retry once automatically, skip task if still fails, log error
- Partial enrichment acceptable (better some data than blocking pipeline)

### Claude's Discretion

- Exact prompt engineering for summaries (length, detail level, style)
- Prompt structure: single vs modular, examples vs instruction-only
- Source material handling: inline vs file path reference
- Tag taxonomy (consistent vocab across all notes)
- Idea angle balance (practical vs synthesis vs contrarian)
- Draft outline depth (outline vs full draft)
- Multi-part video handling (summarize whole or by section)

### Deferred Ideas (OUT OF SCOPE)

- Automatic draft writing (full first draft, not just outline)
- Sentiment analysis or controversy detection
- Source clustering (finding related sources automatically)
- Personalized idea scoring based on past writing
- Auto-tagging consistency checking (flag contradictory tags)
- Real-time enrichment (trigger on ingestion instead of scheduled batch)
</user_constraints>

## Standard Stack

The established libraries/tools for AI-powered content enrichment workflows:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Claude API | Sonnet 4.5 | Content synthesis, summarization, idea generation | State-of-art reasoning, long context (200K tokens), structured outputs |
| python-frontmatter | 1.1.0+ | YAML frontmatter parsing/writing | Community standard for markdown metadata, battle-tested |
| n8n | Latest | Workflow orchestration, parallel execution | Built-in webhook synchronization, visual workflow builder |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Pydantic | 2.0+ | JSON validation, structured output | When strict schema enforcement needed (NOT for light validation) |
| jq | 1.7+ | JSON manipulation in shell scripts | Quick field extraction in wrapper scripts |
| grep/regex | - | Generic language pattern detection | Quality flag detection (vague words, low density) |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| python-frontmatter | Manual YAML parsing | Loses community patterns, edge case handling, and metadata proxying |
| Claude API | OpenAI GPT-5 | Less reliable for long context (100K vs 200K), weaker citation extraction |
| n8n parallel | Sequential tasks | Slower (2x time), but simpler workflow logic |

**Installation:**
```bash
# Python dependencies (in Claude Code wrapper script environment)
pip install python-frontmatter pydantic

# System dependencies (already installed in Phase 6)
brew install jq coreutils
```

## Architecture Patterns

### Recommended Project Structure
```
vault/
├── .enrichment/           # Enrichment pipeline internals
│   ├── prompts/           # Claude prompt templates
│   │   ├── summarize.md   # Summarization instructions
│   │   ├── tagging.md     # Tagging & metadata extraction
│   │   ├── ideas.md       # Idea card generation
│   │   └── draft.md       # Draft scaffolding (optional)
│   ├── logs/              # Daily enrichment logs
│   │   └── .enrichment-daily-*.md
│   └── quality/           # Quality validation patterns
│       └── generic-patterns.txt
├── inbox/                 # Raw ingested sources
├── enriched/              # Sources with metadata added
├── ideas/                 # Generated blog angle cards
└── drafts/                # Draft scaffolds (optional)
```

### Pattern 1: Prompt Chaining for Multi-Step Synthesis
**What:** Break enrichment into separate prompts (summarize → tag → ideate) instead of single mega-prompt
**When to use:** Complex synthesis tasks with multiple transformations, citations, or instructions
**Why:** Each subtask gets Claude's full attention, prevents dropped steps, enables targeted debugging

**Example:**
```typescript
// Source: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/chain-prompts
// Prompt 1: Summarization
{
  role: "user",
  content: `Summarize this video transcript in 2-3 sentences capturing key insights.

<transcript>
{{TRANSCRIPT}}
</transcript>

Output only the summary, no preamble.`
}

// Prompt 2: Tagging (uses summary from Prompt 1)
{
  role: "user",
  content: `Extract metadata from this transcript.

<summary>
{{SUMMARY}}
</summary>

<transcript>
{{TRANSCRIPT}}
</transcript>

Extract:
- 5-10 topic tags (specific, not generic like "technology")
- 2-3 key quotes worth highlighting
- 3-5 key takeaways

Output as YAML:
tags: [tag1, tag2, ...]
quotes: ["quote1", "quote2", ...]
takeaways: ["takeaway1", "takeaway2", ...]`
}

// Prompt 3: Idea Generation (vault-aware)
{
  role: "user",
  content: `Generate 2-3 blog angles from this source.

<summary>
{{SUMMARY}}
</summary>

<related_notes>
{{VAULT_SEARCH_RESULTS}}
</related_notes>

For each angle:
- Suggested title
- Outline (3-5 bullets)
- Supporting sources (reference specific quotes/timestamps)
- Rationale: Why worth pursuing (unique perspective, shareability, fills gap)
- Vault connections: Related notes to synthesize with

Prioritize: practical application, cross-domain insights, context-appropriate angles.

Output as markdown idea cards.`
}
```

### Pattern 2: YAML Frontmatter Manipulation
**What:** Read markdown, parse frontmatter, update fields, write back atomically
**When to use:** Persisting enrichment metadata to source files

**Example:**
```python
# Source: https://python-frontmatter.readthedocs.io/
import frontmatter
from pathlib import Path

# Read existing file
post = frontmatter.load("vault/inbox/source.md")

# Access/modify frontmatter like dict
post['summary'] = "Generated summary text"
post['tags'] = ["ai", "productivity", "knowledge-management"]
post['status'] = "enriched"

# Write back atomically (temp + rename pattern)
temp_path = Path("vault/inbox/source.md.tmp")
final_path = Path("vault/inbox/source.md")

with temp_path.open('w') as f:
    f.write(frontmatter.dumps(post))

temp_path.rename(final_path)  # Atomic operation
```

### Pattern 3: n8n Parallel Execution with Wait-For-All
**What:** Execute multiple sub-workflows in parallel, wait for all completions before proceeding
**When to use:** Independent tasks (tagging, idea generation) that can run concurrently

**Key nodes:**
- **Execute Workflow**: Set "Wait For Sub-workflow Completion" = false (async)
- **Wait**: Configure "Resume: On Webhook Call" with unique suffix per task
- **Webhook**: Sub-workflows call back to `$execution.resumeUrl` when done

**Flow:**
```
[Summarization Complete]
    |
    ├── Execute Workflow (Tagging) [async]
    |       └── Wait (webhook: /tagging-{{sourceId}})
    |
    └── Execute Workflow (Idea Gen) [async]
            └── Wait (webhook: /ideas-{{sourceId}})

[Both complete] → [Update status: enriched] → [Log to daily summary]
```

### Pattern 4: Quality Flag Detection (Non-Blocking)
**What:** Detect generic language patterns, set `needs_review: true`, but don't block pipeline
**When to use:** Light validation without strict enforcement

**Example:**
```bash
# Source: Generic language detection patterns
GENERIC_PATTERNS=(
  "interesting"
  "explores"
  "discusses"
  "in this video"
  "talks about"
  "covers"
)

# Check summary for generic patterns
summary=$(cat enriched/source.md | grep "^summary:" | cut -d: -f2-)
needs_review=false

for pattern in "${GENERIC_PATTERNS[@]}"; do
  if echo "$summary" | grep -qi "$pattern"; then
    needs_review=true
    break
  fi
done

if [ "$needs_review" = true ]; then
  # Add flag to frontmatter (non-blocking)
  python add_frontmatter_flag.py enriched/source.md "needs_review" true
fi
```

### Anti-Patterns to Avoid

- **Mega-prompt anti-pattern:** Single prompt for all tasks (summarize + tag + ideate) leads to dropped steps and shallow synthesis. Use prompt chaining instead.
- **Synchronous orchestration:** Running tagging and idea generation sequentially wastes time (2x duration). Use parallel execution for independent tasks.
- **Strict validation blocking:** Enforcing perfect output quality blocks pipeline on edge cases. Use quality flags + human review batch instead.
- **Inline content in prompts:** Passing full transcripts inline (not file paths) hits token limits, slows processing. Use file path references when possible.
- **No citation links:** Ideas without source quotes/timestamps can't be verified. Always include specific references.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| YAML frontmatter parsing | Custom regex parsers | python-frontmatter | Edge cases (multiline strings, escaping, nested structures), community standard |
| Generic language detection | Custom NLP models | Regex pattern matching | Over-engineered for simple pattern detection, regex sufficient for flags |
| Parallel task synchronization | Custom queue + polling | n8n Execute Workflow + Wait nodes | Built-in webhook callbacks, no polling overhead, visual debugging |
| Markdown code fence stripping | Manual string manipulation | `sed '1d;$d'` or jq | Handles nested fences, consistent behavior across edge cases |
| Atomic file writes | Direct overwrites | Temp + rename pattern | Prevents partial writes on crashes, filesystem guarantees atomicity |
| Retry logic | Manual sleep + loop | n8n "Retry On Fail" settings | Exponential backoff, jitter, max attempts built-in |
| JSON schema validation | String parsing + checks | Pydantic models | Type coercion, nested validation, clear error messages |

**Key insight:** Enrichment pipelines have well-established patterns (prompt chaining, frontmatter manipulation, parallel orchestration). Don't reinvent — use proven libraries and patterns that handle edge cases.

## Common Pitfalls

### Pitfall 1: Prompt Chaining Without Context Preservation
**What goes wrong:** Later prompts (tagging, idea generation) lack context from earlier prompts (summary), producing shallow results
**Why it happens:** Treating each prompt as isolated, not passing forward outputs from previous steps
**How to avoid:**
- Always pass summary to tagging and idea generation prompts via XML tags: `<summary>{{SUMMARY}}</summary>`
- Include original source reference: `<transcript>{{TRANSCRIPT}}</transcript>` or `<source_file>{{FILE_PATH}}</source_file>`
- For idea generation, include vault search results: `<related_notes>{{VAULT_SEARCH}}</related_notes>`
**Warning signs:**
- Tags don't align with summary themes
- Ideas feel generic, could apply to any source
- No connections to existing vault notes

### Pitfall 2: Blocking Pipeline on Quality Validation
**What goes wrong:** Strict validation (e.g., "summary must not contain 'interesting'") blocks entire pipeline when single task produces generic output
**Why it happens:** Treating validation as pass/fail gate instead of quality signal
**How to avoid:**
- Use quality flags (`needs_review: true`) instead of blocking execution
- Accept partial enrichment: better to have summary + tags but flagged ideas than no enrichment at all
- Implement batch review workflow: user periodically checks flagged items, refines manually
- Retry once automatically, but skip task (not workflow) if still fails
**Warning signs:**
- Many sources stuck in "pending enrichment" status
- Logs show repeated validation failures for same source
- User manually re-running enrichment frequently

### Pitfall 3: Vault-Unaware Idea Generation
**What goes wrong:** Generated ideas don't connect to existing notes, producing isolated suggestions instead of synthesis opportunities
**Why it happens:** Idea generation prompt doesn't search vault for related content
**How to avoid:**
- Before idea generation: search vault with summary keywords (using Obsidian search, grep, or semantic embeddings)
- Pass top 3-5 related notes to idea prompt: `<related_notes>{{NOTES}}</related_notes>`
- Prompt explicitly: "Suggest connections to existing vault notes, identify synthesis opportunities"
- Include vault connections in idea card output format
**Warning signs:**
- Ideas feel repetitive across different sources
- No backlinks or references to existing vault notes
- User manually adding connections after enrichment

### Pitfall 4: Race Conditions in Parallel Execution
**What goes wrong:** Tagging and idea generation both try to update same source file simultaneously, causing data loss or corruption
**Why it happens:** Parallel tasks writing to same file without coordination
**How to avoid:**
- Separate output files: tagging updates source, idea generation creates new files in `/ideas/`
- If both must update source: use n8n wait-for-all pattern to serialize final write
- Atomic writes with temp + rename pattern: prevents partial corruption
- n8n execution context isolation: ensure each sub-workflow has unique resume URL suffix
**Warning signs:**
- Frontmatter fields randomly missing after enrichment
- Idea cards with incomplete metadata
- n8n logs show overlapping execution timestamps

### Pitfall 5: Token Limit Exceeded on Long Transcripts
**What goes wrong:** Full transcript + prompt instructions exceed Claude's 200K token context window (or budget limits)
**Why it happens:** Passing entire multi-hour transcript inline instead of chunking or summarizing
**How to avoid:**
- Estimate tokens before processing: ~1 token per 0.75 words (English)
- For transcripts >100K tokens: summarize in sections first, then synthesize section summaries
- Use file path references when Claude Code supports: `<file_path>{{PATH}}</file_path>` instead of inline content
- Mark as user discretion: decide whole vs section summarization strategy
**Warning signs:**
- Enrichment failures with "context window exceeded" errors
- Very long processing times (>60s for summarization)
- Claude output truncated mid-sentence

### Pitfall 6: No Citation Verification Path
**What goes wrong:** Generated ideas reference quotes or insights that don't exist in source material
**Why it happens:** Claude hallucinating details, no verification mechanism for generated citations
**How to avoid:**
- Prompt with explicit citation format: "Quote exact text from transcript with timestamp: [HH:MM:SS] 'quoted text'"
- Store source file path in idea card frontmatter: `source: vault/enriched/source-name.md`
- Include backlink to source in idea card body: `Source: [[enriched/source-name]]`
- User review step: check flagged ideas for citation accuracy before drafting
**Warning signs:**
- Quotes in idea cards don't appear in source transcript
- Timestamps reference non-existent time ranges
- User frequently editing idea cards to fix citations

## Code Examples

Verified patterns from official sources and real-world implementations:

### Summarization Task (Claude Prompt)
```markdown
# Source: Anthropic prompt engineering best practices
# https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/be-clear-and-direct

You are a content synthesizer. Your task is to summarize YouTube video transcripts for a knowledge vault.

<transcript>
{{TRANSCRIPT_CONTENT}}
</transcript>

Write a 2-3 sentence summary capturing the key insights. Focus on:
- Main argument or thesis
- Novel insights or frameworks presented
- Practical takeaways or applications

Output only the summary, no preamble or commentary.
```

### Tagging & Metadata Extraction (Claude Prompt)
```markdown
# Source: YAML structured output pattern
# https://www.improvingagents.com/blog/best-nested-data-format/

You are a metadata extraction specialist. Extract structured metadata from this content.

<summary>
{{SUMMARY}}
</summary>

<transcript>
{{TRANSCRIPT_CONTENT}}
</transcript>

Extract the following:

1. **Tags** (5-10): Specific topic keywords. Avoid generic terms like "technology" or "interesting". Use concrete domains like "prompt-engineering", "knowledge-management", "obsidian".

2. **Quotes** (2-3): Direct quotes worth highlighting. Include timestamp if available. Format: [HH:MM:SS] "exact quote text"

3. **Takeaways** (3-5): Actionable insights or key learnings. Be specific, not vague.

Output as YAML:
```yaml
tags:
  - tag1
  - tag2
  - tag3
quotes:
  - "[00:15:30] 'exact quote text here'"
  - "[00:42:15] 'another exact quote'"
takeaways:
  - "Specific actionable insight 1"
  - "Specific actionable insight 2"
  - "Specific actionable insight 3"
```

Do not include markdown code fences in your output. Output raw YAML only.
```

### Idea Card Generation (Claude Prompt)
```markdown
# Source: Vault-aware synthesis pattern
# https://gist.github.com/naushadzaman/164e85ec3557dc70392249e548b423e9

You are a blog idea generator. Generate 2-3 potential blog angles from this source.

<summary>
{{SUMMARY}}
</summary>

<source_file>
{{SOURCE_FILE_PATH}}
</source_file>

<related_vault_notes>
{{RELATED_NOTES}}
</related_vault_notes>

For each blog angle, provide:

1. **Title**: Compelling, specific (not generic)
2. **Outline**: 3-5 bullet points covering main sections
3. **Supporting Sources**: Specific quotes/timestamps from this source
4. **Rationale**: Why this angle is worth pursuing
   - Unique perspective offered
   - Shareability potential
   - Gap it fills in existing content
5. **Vault Connections**: Related notes to synthesize with

Prioritize:
- Practical application (how to apply insights)
- Cross-domain insights (connecting different fields)
- Context-appropriate angles (matches vault theme)

Output format (markdown):
```markdown
## Idea 1: [Title]

**Outline:**
- Section 1: [description]
- Section 2: [description]
- Section 3: [description]

**Supporting Sources:**
- [00:15:30] "exact quote supporting this angle"
- [00:42:15] "another relevant quote"

**Rationale:**
[Why this angle is worth pursuing - unique perspective, shareability, fills gap]

**Vault Connections:**
- [[note-name-1]] - [how it connects]
- [[note-name-2]] - [synthesis opportunity]

---
```

Create idea cards that inspire writing, not just summarize content.
```

### Python Frontmatter Update Script
```python
# Source: python-frontmatter documentation
# https://python-frontmatter.readthedocs.io/

import frontmatter
import sys
from pathlib import Path

def update_enrichment_metadata(source_path: str, summary: str, tags: list, quotes: list, takeaways: list):
    """
    Update source file frontmatter with enrichment metadata.
    Uses atomic write pattern (temp + rename) to prevent corruption.
    """
    source = Path(source_path)

    # Read existing file
    post = frontmatter.load(source)

    # Update frontmatter fields
    post['summary'] = summary
    post['tags'] = tags
    post['quotes'] = quotes
    post['takeaways'] = takeaways
    post['status'] = 'enriched'
    post['enriched_at'] = datetime.now().isoformat()

    # Atomic write: temp + rename
    temp_path = source.with_suffix('.md.tmp')
    try:
        with temp_path.open('w', encoding='utf-8') as f:
            f.write(frontmatter.dumps(post))

        # Atomic rename (POSIX guarantee)
        temp_path.rename(source)
        print(f"✓ Updated {source_path}")
    except Exception as e:
        # Cleanup temp file on error
        if temp_path.exists():
            temp_path.unlink()
        raise e

if __name__ == "__main__":
    source_path = sys.argv[1]
    summary = sys.argv[2]
    # ... parse other args
    update_enrichment_metadata(source_path, summary, tags, quotes, takeaways)
```

### Generic Language Detection (Bash)
```bash
# Source: Quality validation patterns
# Simple regex-based generic language detection

#!/bin/bash

detect_generic_language() {
    local summary="$1"

    # Generic patterns to flag
    local patterns=(
        "interesting"
        "explores"
        "discusses"
        "in this video"
        "talks about"
        "covers"
        "deep dive"
        "comprehensive"
        "robust"
        "holistic"
    )

    # Check for generic patterns (case-insensitive)
    for pattern in "${patterns[@]}"; do
        if echo "$summary" | grep -qi "$pattern"; then
            echo "true"
            return 0
        fi
    done

    # Check information density (word count)
    word_count=$(echo "$summary" | wc -w | tr -d ' ')
    if [ "$word_count" -lt 20 ]; then
        echo "true"  # Too short, likely low density
        return 0
    fi

    echo "false"
    return 0
}

# Usage in enrichment pipeline
summary=$(python extract_summary.py "$source_file")
needs_review=$(detect_generic_language "$summary")

if [ "$needs_review" = "true" ]; then
    # Add flag to frontmatter (non-blocking)
    python update_frontmatter.py "$source_file" "needs_review" true
    echo "⚠ Flagged for review: generic language detected"
fi
```

### n8n Parallel Execution Workflow (JSON config)
```json
{
  "nodes": [
    {
      "name": "Summarization Complete",
      "type": "n8n-nodes-base.noOp",
      "position": [250, 300]
    },
    {
      "name": "Execute Tagging",
      "type": "n8n-nodes-base.executeWorkflow",
      "parameters": {
        "workflowId": "{{TAGGING_WORKFLOW_ID}}",
        "waitForSubWorkflow": false,
        "source": {
          "sourceId": "{{$json.sourceId}}",
          "summary": "{{$json.summary}}",
          "transcriptPath": "{{$json.transcriptPath}}",
          "resumeUrl": "{{$execution.resumeUrl}}/tagging-{{$json.sourceId}}"
        }
      },
      "position": [450, 250]
    },
    {
      "name": "Wait for Tagging",
      "type": "n8n-nodes-base.wait",
      "parameters": {
        "resume": "webhook",
        "options": {
          "suffix": "tagging-{{$json.sourceId}}"
        }
      },
      "position": [650, 250]
    },
    {
      "name": "Execute Ideas",
      "type": "n8n-nodes-base.executeWorkflow",
      "parameters": {
        "workflowId": "{{IDEAS_WORKFLOW_ID}}",
        "waitForSubWorkflow": false,
        "source": {
          "sourceId": "{{$json.sourceId}}",
          "summary": "{{$json.summary}}",
          "transcriptPath": "{{$json.transcriptPath}}",
          "resumeUrl": "{{$execution.resumeUrl}}/ideas-{{$json.sourceId}}"
        }
      },
      "position": [450, 350]
    },
    {
      "name": "Wait for Ideas",
      "type": "n8n-nodes-base.wait",
      "parameters": {
        "resume": "webhook",
        "options": {
          "suffix": "ideas-{{$json.sourceId}}"
        }
      },
      "position": [650, 350]
    },
    {
      "name": "Merge Results",
      "type": "n8n-nodes-base.merge",
      "parameters": {
        "mode": "mergeByIndex"
      },
      "position": [850, 300]
    },
    {
      "name": "Update Status",
      "type": "n8n-nodes-base.function",
      "parameters": {
        "functionCode": "items[0].json.status = 'enriched';\nreturn items;"
      },
      "position": [1050, 300]
    }
  ],
  "connections": {
    "Summarization Complete": {
      "main": [
        [{"node": "Execute Tagging"}, {"node": "Execute Ideas"}]
      ]
    },
    "Execute Tagging": {
      "main": [
        [{"node": "Wait for Tagging"}]
      ]
    },
    "Execute Ideas": {
      "main": [
        [{"node": "Wait for Ideas"}]
      ]
    },
    "Wait for Tagging": {
      "main": [
        [{"node": "Merge Results", "input": 0}]
      ]
    },
    "Wait for Ideas": {
      "main": [
        [{"node": "Merge Results", "input": 1}]
      ]
    },
    "Merge Results": {
      "main": [
        [{"node": "Update Status"}]
      ]
    }
  }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Single mega-prompt for all tasks | Prompt chaining (separate prompts per task) | 2025 H2 | Each subtask gets full attention, easier debugging, better quality |
| JSON structured outputs | YAML for markdown context | 2025 H1 | Better LLM understanding (+17.7% accuracy), cleaner frontmatter integration |
| Python regex for frontmatter | python-frontmatter library | Established (pre-2023) | Handles edge cases, community standard, less maintenance burden |
| Manual tag vocabularies | AI-extracted tags with generic pattern filtering | 2025 H2 | Faster tagging, but requires quality flags to prevent generic terms |
| Sequential enrichment (sum→tag→idea) | Hybrid: summary first, then parallel | 2026 Q1 | 2x faster for tagging+ideas, maintains context dependency |
| Pydantic strict validation | Light validation + quality flags | 2026 Q1 | Prevents pipeline blocking, accepts partial enrichment, batch review workflow |
| Direct file overwrites | Atomic writes (temp + rename) | Best practice (pre-2020) | Prevents corruption on crashes, filesystem atomic guarantee |
| Claude Opus 3 (100K context) | Claude Sonnet 4.5 (200K context) | 2025 Q4 | Handles longer transcripts, better cost/performance ratio |

**Deprecated/outdated:**
- **Mega-prompts for multi-step synthesis**: Modern prompt engineering uses chaining (separate prompts) for complex tasks. Mega-prompts lead to dropped steps and shallow synthesis.
- **Strict schema validation for enrichment**: 2026 best practice is light validation + quality flags. Strict enforcement blocks pipelines on edge cases.
- **Sequential task orchestration**: Parallel execution (Execute Workflow + Wait nodes) is standard for independent tasks. Sequential wastes time.

## Open Questions

Things that couldn't be fully resolved:

1. **Semantic similarity for vault search**
   - What we know: Smart Connections plugin uses embeddings for semantic search, multiple Obsidian plugins support this
   - What's unclear: Whether to use embeddings (complex setup, API costs) or keyword search (simpler, faster) for vault-aware synthesis
   - Recommendation: Start with keyword-based vault search (grep/Obsidian search API), upgrade to semantic embeddings in Phase 8 if needed. Test if keyword search produces sufficient related notes.

2. **Optimal retry count and backoff strategy**
   - What we know: n8n supports 3-5 retries with exponential backoff (1s, 2s, 5s, 13s) + jitter
   - What's unclear: Optimal settings for Claude API specifically (rate limits, transient failures)
   - Recommendation: Start with 3 retries, 5s initial delay, 2x backoff. Monitor logs for rate limit vs. transient errors, adjust accordingly.

3. **Tag taxonomy enforcement**
   - What we know: AI-extracted tags need consistency, but strict vocabularies are brittle
   - What's unclear: Whether to use controlled vocabulary (pre-defined tag list) or emergent taxonomy (AI-generated, filtered for generic terms)
   - Recommendation: Emergent taxonomy with generic pattern filtering for Phase 7. Monitor tag distribution, create controlled vocabulary in Phase 8 if needed (marked as Claude's discretion).

4. **Idea generation prompt: examples vs. instruction-only**
   - What we know: Few-shot prompting (with examples) improves consistency, but adds token overhead
   - What's unclear: Whether example idea cards in prompt (3-4 examples = ~500 tokens) improve quality enough to justify cost
   - Recommendation: Start instruction-only (marked as Claude's discretion). If generated ideas lack specificity, add 2-3 example idea cards to prompt.

5. **Multi-part video handling strategy**
   - What we know: Very long transcripts (>100K tokens) may need section-by-section summarization
   - What's unclear: Token threshold for switching strategies, how to structure section summaries
   - Recommendation: Estimate tokens (1 token ≈ 0.75 words). If >150K tokens: summarize in 30-minute sections, then synthesize section summaries. Mark as Claude's discretion for planner to decide strategy.

## Sources

### Primary (HIGH confidence)
- [Claude Prompt Engineering Overview](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview) - Prompt chaining patterns, best practices for synthesis tasks
- [Claude Prompt Chaining Documentation](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/chain-prompts) - Multi-step workflows, context preservation
- [python-frontmatter Documentation](https://python-frontmatter.readthedocs.io/) - YAML frontmatter parsing/writing API
- [n8n Error Handling Documentation](https://docs.n8n.io/flow-logic/error-handling/) - Retry logic, error workflows, failure handling
- [n8n Wait Node Documentation](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.wait/) - Webhook-based synchronization patterns

### Secondary (MEDIUM confidence)
- [Which Nested Data Format Do LLMs Understand Best?](https://www.improvingagents.com/blog/best-nested-data-format/) - YAML vs. JSON performance research (YAML +17.7% accuracy)
- [Mastering LLM Output: JSON Schema Validation](https://www.penbrief.com/json-schema-llm-output-validation/) - Structured output validation patterns
- [Ultimate Guide to AI Document Ingestion and Processing](https://spiralscout.com/blog/ai-document-ingestion-processing) - Content enrichment pipeline architecture
- [Advanced n8n Error Handling and Recovery Strategies](https://www.wednesday.is/writing-articles/advanced-n8n-error-handling-and-recovery-strategies) - Retry patterns, exponential backoff
- [Knowledge Vault: Claude Code + Obsidian](https://gist.github.com/naushadzaman/164e85ec3557dc70392249e548b423e9) - Real-world vault-aware enrichment implementation

### Tertiary (LOW confidence)
- [Claude Prompt Engineering Best Practices (2026)](https://promptbuilder.cc/blog/claude-prompt-engineering-best-practices-2026) - General guidance, not verified with official docs
- [AI Content Quality Control: Complete Guide for 2026](https://koanthic.com/en/ai-content-quality-control-complete-guide-for-2026-2/) - Quality validation patterns (claims not verified)
- [67 Free AI Prompts for Transcript Analysis](https://brasstranscripts.com/blog/ai-prompts-github-repository-announcement) - Example prompts (not Claude-specific)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Claude API, python-frontmatter, n8n are established tools with official documentation
- Architecture: HIGH - Prompt chaining, parallel execution, atomic writes are verified patterns from official sources
- Pitfalls: MEDIUM-HIGH - Based on best practices research and real-world implementations, not all tested in this specific context
- Quality validation: MEDIUM - Generic language detection patterns identified, but effectiveness depends on testing against real enrichment output

**Research date:** 2026-02-06
**Valid until:** 30 days (stable domain: prompt engineering patterns and libraries change slowly)

**Key research gaps:**
- No direct testing of Claude's performance on specific enrichment tasks (summarization quality, tag consistency)
- Vault search strategy (keyword vs. semantic) requires experimentation
- Idea generation prompt engineering (examples vs. instruction-only) needs A/B testing
- Tag taxonomy (controlled vs. emergent) depends on monitoring actual distribution

**Planner guidance:**
Use the locked decisions from CONTEXT.md as constraints. For areas marked "Claude's Discretion" (prompt structure, tag taxonomy, idea angle balance), create tasks that allow flexibility and iteration based on output quality. Prioritize getting the pipeline working end-to-end with simple approaches, then refine prompts in later tasks.
