# Pitfalls Research

**Domain:** Content Intelligence Pipeline — adding MCP scanning, atomic notes, theme matching, and draft synthesis to an existing Obsidian vault + bash pipeline
**Researched:** 2026-02-22
**Confidence:** HIGH for integration and API pitfalls (verified against official docs and GitHub issues); MEDIUM for atomic note design and synthesis quality pitfalls (community patterns + reasoning from first principles)

---

## Critical Pitfalls

### Pitfall 1: MCP Tool Definitions Consume Massive Token Budget Before Any Work Begins

**What goes wrong:**
When Claude Code loads an MCP-heavy session (Slack MCP server, Graph API tools, vault tools, synthesis tools), all tool definitions load into context immediately — before any conversation or work starts. A five-server setup consumes 51K–67K tokens (33% of a 200K context budget) just for tool definitions. A single large Slack channel history scan response can exhaust another 25K tokens (the default `MAX_MCP_OUTPUT_TOKENS` cap). The actual synthesis work — reading vault notes, generating atomic notes, drafting posts — then runs in a depleted context and produces truncated, low-quality output.

**Why it happens:**
Claude Code loads ALL MCP tool descriptions into context on the first user message, regardless of which tools the session will actually use. This is a known architectural behavior documented in GitHub issue #3406 and #11364. Most developers discover this only after noticing poor performance on long sessions.

**How to avoid:**
- Design the v1.3 Claude Code skill as separate, scoped scripts — one for Slack scanning, one for atomic splitting, one for synthesis — rather than a single mega-session with all tools loaded.
- Set `MAX_MCP_OUTPUT_TOKENS` explicitly in the environment to cap runaway scan responses.
- Use Claude Code's Tool Search feature (if available) so only needed tools load on demand.
- Return minimal payloads from Slack/Graph MCP calls: channel ID, message timestamp, sender, raw text only. Do not return full message threads or HTML bodies through MCP unless required.
- Test context consumption with `claude --debug` before deploying any scheduled automation.

**Warning signs:**
- Claude Code sessions timeout or produce incomplete output on long scans.
- Synthesis drafts are truncated mid-sentence, suggesting context exhaustion.
- `claude --debug` shows >40K tokens consumed before any actual processing.

**Phase to address:**
MCP skill architecture phase — context budget must be the first constraint designed around, not discovered during integration testing.

---

### Pitfall 2: Slack conversations.history Rate Limits Silently Break Incremental Scanning

**What goes wrong:**
The existing `scan-slack.sh` uses `conversations.history` with no rate-limit handling. As of May 2025, non-Marketplace Slack apps are limited to 1 request per minute for `conversations.history` and `conversations.replies`, with a maximum of 15 objects per response (down from 100+). The bash scanner silently receives a `HTTP 429` with a `Retry-After` header, the script interprets this as "no new messages," updates the last-scan timestamp, and the gap is never recovered. Messages from that window are permanently lost.

**Why it happens:**
The 2025 Slack API rate limit change is a major breaking change for non-Marketplace scanning apps. The existing bash scanner was written before this change and has no `429` handling or exponential backoff. The silent update of `LAST_SCAN_FILE` on any scan completion (including failed ones) closes the window permanently.

**How to avoid:**
- The new MCP-based Slack skill must check HTTP response codes and treat `429` as a hard failure, not a success with empty results.
- Do not update `LAST_SCAN_FILE` until all paginated results for that window are confirmed received.
- Build in cursor-based pagination: Slack's `conversations.history` returns a `next_cursor` field; the skill must follow all pages before marking the window complete.
- For a custom/internal Slack app (which this likely is), verify whether the new rate limits apply — internal apps are exempt from the 2025 non-Marketplace limits and retain 50+ requests/minute.
- Add a `Retry-After` header check and sleep before retry on any `429` response.

**Warning signs:**
- Scan logs show zero new messages for periods you know were active in Slack.
- API logs or `scan.log` contain response codes other than `200` that are being silently ignored.
- `LAST_SCAN_FILE` timestamp advances even when the API returned errors.

**Phase to address:**
Slack MCP skill implementation — pagination and error handling are not optional features; build them into the first working version.

---

### Pitfall 3: Atomic Splitting Destroys Conversational Context That Made the Insight Valuable

**What goes wrong:**
A Slack message that reads "We should probably reconsider the rollout timeline given what happened with the Copilot adoption curve" gets split into an atomic note titled "Rollout timeline reconsideration." The atomic note loses the Slack thread context (what was the Copilot adoption curve? who said it? in response to what?), the reasoning chain (why did this message connect these ideas?), and the signal about why Athan's boss shared it. The note becomes a decontextualized fragment that matches no vault themes and provides no synthesis value. The note sits in the vault forever and degrades overall vault signal quality.

**Why it happens:**
Atomic splitting prompts optimize for "one idea per note" without specifying that the conversational provenance is the idea. LLMs naturally strip context to produce clean, standalone statements. Without explicit instructions to preserve conversation metadata and decision context in atomic notes, the model produces legible-sounding but hollow notes.

**How to avoid:**
- The atomic splitting prompt must require three things in every atomic note: (1) the claim or idea in one sentence, (2) the original conversational context in 1–2 sentences (who said it, in what context, in response to what), (3) why it was flagged (starred, from boss, in a specific channel).
- Add a `provenance` frontmatter field: `source_type`, `source_channel`, `source_sender`, `source_message_ts`.
- Do not split aggressively: a Slack thread is usually one atomic note (the core insight from the whole thread), not one note per message. Email threads are one note per decision, not one note per paragraph.
- Include a "minimum viable atom" check: if the note cannot be understood without the original conversation, it is not atomic — it is just a fragment.

**Warning signs:**
- Atomic notes have titles but bodies of 1–2 sentences with no context.
- Notes cannot be understood without opening the source link.
- Theme-matching phase generates zero connections for new atomic notes (because they lack content to match against).

**Phase to address:**
Atomic splitting design phase — the splitting schema and prompt must be fully specified and manually tested on representative Slack/email examples before automation runs.

---

### Pitfall 4: Theme Matching Produces Spurious Connections That Dilute Vault Graph Quality

**What goes wrong:**
The theme-matching skill compares new atomic notes against existing vault content using keyword or embedding similarity. It finds that a note about "decision velocity in product sprints" matches an existing note about "sprint planning ceremonies" (both contain "sprint," "decision," "team"). It creates a link between them. Over time, the vault accumulates hundreds of low-signal connections between superficially similar notes. The graph view becomes useless — everything connects to everything. Actual thematic clusters (decision science, AI-native thinking, PhD-to-product) are buried in noise.

**Why it happens:**
Grep-based or shallow semantic matching (the v1 approach) matches vocabulary, not meaning. Two notes that use the same words in different contexts ("model" in machine learning vs. "model" in role model) create false connections. At small scale this is tolerable; at the scale where daily automation adds 5–10 notes per day, false positives compound faster than true positives.

**How to avoid:**
- Require a minimum connection confidence threshold: the matching prompt must explain *why* two notes are connected, not just that they share terms. If the reason is only vocabulary overlap, do not create the link.
- Limit automated linking to a maximum of 3 theme matches per new atomic note. Force the model to rank and select the strongest connections.
- Distinguish between "topic similarity" (same subject, different angle) and "conceptual connection" (one note's idea extends or challenges another's). Only the latter warrants a hard Obsidian link; the former can be a tag.
- Review automated links in the Obsidian review workflow before they become permanent. Do not auto-commit theme matches.
- Log rejected matches with their rejection reason — this trains future prompt tuning.

**Warning signs:**
- Every new note gets connected to 10+ existing notes.
- Graph view shows hub-and-spoke patterns where one generic note (e.g., "Decision Making") links to everything.
- Theme-match explanations contain "both discuss" or "share the topic of" as the primary rationale.

**Phase to address:**
Theme-matching design phase — define what a valid connection means before writing the matching prompt. The quality bar must be set by manual examples, not discovered from bad automation output.

---

### Pitfall 5: Draft Blog Posts Lose Voice Consistency and Attribute Fabricated Insights to Real Sources

**What goes wrong:**
The synthesis skill clusters 8 atomic notes about AI-native workflows and generates a draft blog post. The draft is coherent, but: (1) it attributes specific claims to notes that don't actually contain those claims (hallucinated citations), (2) it writes in generic "thought leadership" voice that sounds nothing like Athan, and (3) it combines observations from a private Slack message with public GoodLinks content without flagging which parts should not be published. The draft appears ready but requires complete rewriting to be publishable.

**Why it happens:**
LLMs under synthesis pressure default to: filling gaps with plausible-sounding content (hallucination), averaging toward a generic writing style when no style guide is embedded in the prompt, and treating all input notes as equally publishable regardless of sensitivity metadata. All three failure modes are well-documented in LLM citation accuracy research (2025).

**How to avoid:**
- The synthesis prompt must include Athan's voice characteristics (from the ChatGPT Deep Research Voice & Style Guide when available, or a placeholder voice profile). Without voice constraints, every draft will be generic.
- Each claim in the draft must include an inline citation pointing to a specific atomic note ID. The synthesis prompt must be instructed: "only state claims that appear in the source notes; do not add claims the notes do not support."
- Atomic notes must carry a `publishability` frontmatter field: `public` (from GoodLinks/web), `private` (from Slack/email). The synthesis skill must refuse to include private-sourced claims in drafts without explicit override.
- Treat drafts as raw material, never as ready-to-publish output. The Obsidian review gate must be mandatory before any draft enters the publish pipeline.

**Warning signs:**
- Draft citations point to notes by title, but the notes don't contain the claimed content.
- Draft tone shifts register between paragraphs (some casual, some formal — different source styles bleeding through).
- Draft includes observations that could only have come from private Slack context, without any attribution tag.

**Phase to address:**
Synthesis workflow design phase and content strategy mode design phase. Both must address voice consistency, citation integrity, and publishability gating before any synthesis automation runs.

---

### Pitfall 6: Scheduled Daily Automation and Interactive On-Demand Sessions Corrupt Shared State

**What goes wrong:**
A launchd daily scan runs at 8am and writes new atomic notes to the vault. At 8:30am, an interactive Claude Code "content strategist" session starts and reads the vault to cluster themes. While the interactive session is running, the daily scan's enrichment pipeline overwrites a note the interactive session is currently referencing. The interactive session completes with stale data; the enriched note has a different `content_hash` than expected; the synthesis draft references a note ID that now has different content. The resulting draft has silent data integrity problems.

**Why it happens:**
Bash pipelines and Claude Code interactive sessions both write to the same Obsidian vault directory (iCloud-synced) with no locking mechanism. iCloud can further interleave writes from multiple processes. This is a classic shared-mutable-state problem. It does not manifest in small vaults with infrequent automation, but becomes a real problem when daily automation runs overlap with interactive use.

**How to avoid:**
- Use a write-lock file pattern: daily automation creates `~/.model-citizen/pipeline.lock` on start and removes it on completion. Interactive sessions check for the lock file and either wait or abort.
- Alternatively, design the pipeline so daily automation only writes to a staging area (e.g., `600 Inbox/`) and the interactive session reads from the main vault. Promotion from staging to main vault is a separate manual step in the review workflow.
- Never run the daily scan during likely interactive hours. Schedule for 4–6am rather than 8am.
- Add a session-start vault snapshot hash check: if vault state has changed since the session started, warn before committing any synthesis output.

**Warning signs:**
- Interactive session output references notes that have different content than expected.
- Two `scan.log` entries show overlapping start/end timestamps.
- iCloud Obsidian shows "sync conflict" files (duplicate notes with conflict suffix).

**Phase to address:**
Scheduling and automation design phase — the schedule and lock mechanism must be designed before wiring daily automation into launchd.

---

### Pitfall 7: Converting Bash REST Scanners to MCP Skills Breaks Existing Idempotency State

**What goes wrong:**
The existing `scan-slack.sh` maintains state in `~/.model-citizen/slack-last-scan` (a Unix timestamp file). The new MCP-based Claude Code skill uses its own state management (perhaps a different file path, different format, or session-scoped memory). During cutover, the MCP skill does not read the existing `slack-last-scan` file, so it rescans the last N days of Slack history, creating duplicate notes for content already in the vault. Or it reads the file correctly but cannot write to it from within the Claude Code MCP context, so it always rescans from scratch.

**Why it happens:**
When replacing a bash pipeline component, developers focus on replicating functionality and forget that state files are part of the pipeline contract. The MCP context (running inside Claude Code) has different filesystem access patterns than the bash context. State file paths hardcoded in bash may not be writable or readable from within a Claude Code `--print` invocation.

**How to avoid:**
- Before decommissioning `scan-slack.sh`, read its exact state file path, format, and update logic. The MCP skill must read that file on startup and write to it on successful completion — same path, same format.
- Do not run the new MCP skill and the old bash scanner in parallel even temporarily. One replaces the other; the cutover must be a hard switch.
- Add a post-migration validation: after first MCP skill run, compare vault note count and timestamps against pre-migration baseline. Unexpected note inflation signals duplicate creation.
- The URL hash deduplication (already in the pipeline) is the last line of defense — verify it is working before cutover.

**Warning signs:**
- Vault note count increases sharply (30%+) immediately after first MCP skill run.
- Notes with `source: slack` appear with dates that predate the cutover — content already processed is being reprocessed.
- `scan.log` shows MCP scan starting from a much earlier date than expected.

**Phase to address:**
Migration planning phase — state file compatibility must be documented and tested before any cutover, not discovered by seeing vault inflation.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Single mega Claude Code session for all tasks (scan + split + match + synthesize) | One script to maintain | Context exhaustion on long sessions; poor quality on later tasks; impossible to debug which step failed | Never — separate into scoped skills |
| Skip `publishability` frontmatter on atomic notes | Faster to implement | Private Slack content leaks into synthesis drafts and potentially into published posts | Never — add from day one |
| Use generic synthesis prompt without voice guide | Works for MVP | Every draft sounds like AI-generated content, not Athan; defeats the purpose of the system | Only if voice guide is unavailable AND drafts are clearly marked as needing complete rewrite |
| Keep bash scanners running alongside MCP skills | Low-risk cutover | Duplicate notes; competing state files; no clear ownership of scan results | Never longer than one run for validation |
| Hard-code theme match threshold as "similarity > X" | Simple implementation | False positives compound daily; vault graph becomes noise | Only in prototype phase with manual review of every connection |
| Allow synthesis skill to run without existing atomic notes | Demonstrates capability quickly | Synthesis from thin source material produces hallucinated content attributed to real notes | Never in production; require minimum 5 source notes per synthesis |

---

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Slack `conversations.history` | Assuming 100-message pages | As of May 2025, non-Marketplace apps get max 15 messages/page; use cursor pagination and check if your app is internal/Marketplace-exempt |
| Slack MCP server | Returning full message objects through MCP | Extract only needed fields (ts, text, user, channel) before returning; full objects waste 5–10K tokens per call |
| Microsoft Graph API (Outlook) | Using `client_credentials` grant for personal mailbox | Client credentials flow requires admin consent and accesses org mailbox; personal inbox requires delegated auth (device code flow) |
| Claude Code MCP tools | Loading all MCP servers for every session | Split into purpose-scoped scripts; a synthesis-only session should not load the Slack MCP server |
| Obsidian vault + iCloud | Treating iCloud writes as synchronous | iCloud writes propagate asynchronously; do not read a file immediately after writing it in an automation context |
| Atomic note IDs | Using generated titles as stable identifiers | Titles change during editing; use a stable `id` frontmatter field (e.g., UUID or `YYYYMMDD-slug`) as the citation key |

---

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Fetching full Slack thread history on every daily scan | Scan takes 10+ minutes; hits rate limits | Use `oldest` parameter with last-scan timestamp; paginate only forward | After 30 days of daily scanning if oldest param is ignored |
| Running atomic splitting on every source note in vault | First run takes hours; vault note count explodes | Only split newly ingested notes (check `content_status: processed` frontmatter) | First run if there are 50+ existing source notes |
| Theme matching against entire vault on each new note | Matching gets slower as vault grows | Match against theme index (a summary of existing clusters), not every note individually | After ~200 vault notes if doing full pairwise comparison |
| Synthesis from too many source notes | Output becomes incoherent; context budget exceeded | Cap synthesis at 8–12 source notes per draft; cluster before synthesizing | Above 15 source notes in a single synthesis call |

---

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Storing Slack Bot Token in `~/.model-citizen/env` without checking git ignore | Token committed to public repo | Verify `~/.model-citizen/` is outside repo root; add `.env` to gitignore; use `git secrets` check |
| Passing MS Graph access token as a Claude Code prompt argument | Token visible in shell history and process list | Write token to temp file, pass file path, delete after use |
| Syncing vault to public Quartz site without checking `publishability` frontmatter | Private Slack/email content published publicly | The existing publish gate checks `publish: true` tag; atomic notes must default to `publish: false` until explicitly promoted |
| Including message sender names in atomic note titles or bodies | Identifiable work communications in a public vault | Use role labels (`boss`, `colleague`) not names; strip names in the atomic splitting prompt |

---

## UX Pitfalls

These apply to the "content strategist mode" — the interactive conversational workflow.

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Synthesizing before Athan has reviewed atomic notes | Drafts built on notes Athan hasn't validated; corrections require re-synthesis | Present atomic notes for quick review (approve/discard) before synthesis; synthesis runs on approved notes only |
| Offering too many synthesis candidates at once | Decision fatigue; none get worked on | Surface one synthesis opportunity at a time; rank by recency and theme cluster density |
| Requiring full prompt engineering to invoke content strategist | High friction; rarely used | Single entry command (`gsd:content`) with smart defaults; no prompt configuration required for standard use |
| No signal about which themes are growing vs. stale | Athan doesn't know where to focus writing energy | Theme index should show "last active" timestamp and note count trend; surface hot clusters in the content strategist greeting |

---

## "Looks Done But Isn't" Checklist

- [ ] **MCP context budget**: Session completes full scan + split + synthesis without truncation — verify with `claude --debug` showing final token count under 150K
- [ ] **Slack rate limits**: Scanner handles `429` responses with backoff and does not advance last-scan timestamp on failure — test by temporarily reducing rate limit tolerance
- [ ] **Atomic note provenance**: Every atomic note has `source_type`, `source_channel`, `source_sender`, `source_message_ts` frontmatter — inspect 5 sample notes
- [ ] **Publishability gate**: Atomic notes from Slack/email default to `publish: false` — verify none reach the Quartz sync without explicit promotion
- [ ] **Citation integrity**: Synthesis draft claims can be traced back to a specific atomic note ID — manually verify 3 claims from a sample draft
- [ ] **State file compatibility**: MCP skill reads `slack-last-scan` and `outlook-last-scan` files in the same format as the old bash scripts — check file content before and after first MCP run
- [ ] **No scheduled/interactive conflict**: Running interactive content strategist while daily scan is active does not corrupt any vault notes — test by running both simultaneously and checking for iCloud conflict files
- [ ] **Theme match quality**: Each automated link has a written justification that is not just vocabulary overlap — review 10 automated links and reject any that are surface-level matches
- [ ] **Voice consistency**: Synthesis draft reads like Athan, not generic AI — have a trusted reviewer evaluate against the Voice & Style Guide when available

---

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Token context exhaustion corrupts synthesis output | LOW | Split into smaller sessions; re-run synthesis on the same atomic notes with a capped source set |
| Rate limit gaps lose Slack messages | MEDIUM | Identify the time window from logs; manually browse Slack for that period and capture any important items; accept that minor conversations are lost |
| Atomic splitting created hundreds of decontextualized fragments | HIGH | Write a cleanup script that flags notes with body length < 100 chars or missing provenance frontmatter; batch delete or merge; re-run splitting on original source notes with improved prompt |
| Theme match false positives saturate vault graph | MEDIUM | Run a link-audit script to identify automated links; display each link's rationale; delete links that are vocabulary-only matches; re-run matching with stricter threshold |
| Draft contains fabricated citations | LOW | Do not publish; identify which claims lack source notes; delete the fabricated claims; re-synthesize with stricter "only state what the notes support" instruction |
| State file corruption causes full re-scan duplicate notes | MEDIUM | Run deduplication script using normalized URL hash; identify and delete duplicates; restore `last-scan` file to correct date from scan logs |
| Scheduled and interactive sessions conflicted, vault has corrupt notes | MEDIUM | Check for iCloud conflict files; compare conflicted versions; keep the correct version; add lockfile mechanism before next automation run |

---

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| MCP token context exhaustion | MCP skill architecture phase | `claude --debug` shows <150K tokens at end of full pipeline run |
| Slack rate limit gaps silently drop messages | Slack MCP skill implementation | Inject a synthetic `429` and confirm last-scan timestamp does not advance |
| Atomic splitting destroys conversational context | Atomic splitting design phase | 5 sample notes each have provenance and contextual framing, not just claims |
| Theme matching produces false positives | Theme-matching design phase | 10 automated links each have non-vocabulary-overlap justification |
| Draft synthesis hallucinated citations | Synthesis workflow design phase | 3 draft claims each traceable to a specific named atomic note |
| Scheduled + interactive session state conflict | Scheduling and automation design phase | Concurrent run produces no iCloud conflict files |
| Migration breaks idempotency state | Migration planning phase | Vault note count does not increase >5% after first MCP skill run |

---

## Sources

- [Slack rate limit changes for non-Marketplace apps (May 2025)](https://docs.slack.dev/changelog/2025/05/29/rate-limit-changes-for-non-marketplace-apps/)
- [Slack conversations.history API reference](https://docs.slack.dev/reference/methods/conversations.history/)
- [Slack MCP Server documentation](https://docs.slack.dev/ai/slack-mcp-server/)
- [Claude Code MCP token overhead — GitHub issue #3406](https://github.com/anthropics/claude-code/issues/3406)
- [Claude Code MCP context bloat reduction (Tool Search)](https://medium.com/@joe.njenga/claude-code-just-cut-mcp-context-bloat-by-46-9-51k-tokens-down-to-8-5k-with-new-tool-search-ddf9e905f734)
- [MAX_MCP_OUTPUT_TOKENS documentation — Claude Code](https://code.claude.com/docs/en/mcp)
- [LLM citation accuracy challenges — PMC 2025](https://pmc.ncbi.nlm.nih.gov/articles/PMC12037895/)
- [Claude Code scheduled automation with cron — community guide](https://smartscope.blog/en/generative-ai/claude/claude-code-cron-schedule-automation-complete-guide-2025/)
- [Obsidian atomic notes granularity debate — Obsidian Forum](https://forum.obsidian.md/t/debating-the-usefulness-of-atomic-notes-a-novel-pragmatic-obsidian-based-approach-to-pkm-strategies/38077)
- [Automated knowledge graphs with Cognee — Obsidian Forum](https://forum.obsidian.md/t/automated-knowledge-graphs-with-cognee/108834)

---
*Pitfalls research for: Content Intelligence Pipeline (v1.3) — MCP scanning, atomic notes, theme matching, draft synthesis*
*Researched: 2026-02-22*
*Confidence: HIGH for Slack API rate limits (official Slack docs, May 2025 changelog), MCP token overhead (official GitHub issues, measured community data), and state management conflicts (architectural analysis). MEDIUM for atomic note design pitfalls and theme match quality (community patterns + reasoning from system design; no single authoritative source). HIGH for citation hallucination risk (multiple 2025 academic and practitioner sources confirm LLM citation fabrication in synthesis tasks).*
