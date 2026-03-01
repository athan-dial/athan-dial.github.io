# Phase 16: E2E Wiring + Verification - Research

**Researched:** 2026-03-01
**Domain:** Shell orchestration — pipeline integration, lockfile concurrency, content strategist mode, smoke test
**Confidence:** HIGH (shell patterns, scan-all.sh anatomy) / MEDIUM (claude CLI invocation in unattended context)

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| ORCH-01 | Scanning skills can be invoked on-demand via Claude Code commands | Skills exist as `.claude/commands/*.md` files; invocable via `/command-name` in Claude Code sessions; shell wrappers also exist (`scan-slack-intelligence.sh`, `scan-outlook-intelligence.sh`) |
| ORCH-02 | Scanning integrates into existing `scan-all.sh` daily automation | `scan-all.sh` is a well-structured bash script with credential checks, retry helpers, and a summary section; adding a new "Intelligence Pipeline" section follows the exact same pattern already used for Slack/Outlook/Queue/GoodLinks |
| ORCH-03 | Lockfile prevents concurrent vault writes between scheduled and interactive sessions | Standard POSIX lockfile pattern: `flock` or manual `mkdir`-based lock; lockfile path agreed upon between `scan-all.sh` and content strategist command |
| ORCH-04 | Content strategist mode enables interactive co-creation of synthesis and connections | Implemented as a `.claude/commands/content-strategist.md` that surfaces cluster proposals, asks for direction, then calls existing `/match-themes` and `/synthesize-draft` skills |

</phase_requirements>

---

## Summary

Phase 16 wires together the five standalone skills built in Phase 15 into a single unattended pipeline triggered by `scan-all.sh`, adds a lockfile mechanism, implements the content strategist interactive mode, and verifies the full E2E flow with real content.

**The infrastructure is already mostly built.** Phase 15 delivered:
- `scan-slack-intelligence.sh` and `scan-outlook-intelligence.sh` shell wrappers (ready to add to `scan-all.sh`)
- `.claude/commands/scan-slack-intelligence.md`, `scan-outlook-intelligence.md`, `split-source.md`, `match-themes.md`, `synthesize-draft.md` (all verified working)

Phase 16's primary work is:
1. **Integration** — Add the intelligence pipeline to `scan-all.sh` after existing scanners (ORCH-02)
2. **Lockfile** — Add `pipeline.lock` write at start of intelligence run and remove at end; content strategist checks and respects the lock (ORCH-03)
3. **Content strategist command** — New `.claude/commands/content-strategist.md` that wraps `/split-source`, `/match-themes`, `/synthesize-draft` in an interactive loop with human direction at each step (ORCH-04)
4. **Smoke test** — Run one real `scan-all.sh` end-to-end and verify a draft appears in `vault/drafts/` (ORCH-01 + ORCH-02 verification)

**Primary recommendation:** Three plans. Plan 1: `scan-all.sh` + lockfile. Plan 2: content strategist command. Plan 3: E2E smoke test with real content.

---

## Standard Stack

### Core

| Component | Version/Location | Purpose | Why This |
|-----------|-----------------|---------|----------|
| `scan-all.sh` | `model-citizen/scripts/scan-all.sh` | Main daily automation orchestrator | Already exists; intelligence pipeline appended after existing scanners |
| `pipeline.lock` | `~/.model-citizen/pipeline.lock` | Mutual exclusion between scheduled and interactive sessions | Simplest lockfile; bash-native; no new deps |
| `flock` (or `mkdir` lock) | macOS system | Atomic lock acquisition | `flock` is POSIX; `mkdir` is the macOS-safe fallback |
| `.claude/commands/content-strategist.md` | Project `.claude/commands/` | Interactive content co-creation session | Same pattern as all other Phase 15 skills |
| `claude --command` | Claude Code CLI | Run skills in unattended context from `scan-all.sh` | Already used by `scan-slack-intelligence.sh` and `scan-outlook-intelligence.sh` |

### Supporting

| Component | Version/Location | Purpose | When to Use |
|-----------|-----------------|---------|-------------|
| `launchctl` | macOS system | Trigger and manage `com.model-citizen.daily-scan` | Testing scheduled run |
| `scan-slack-intelligence.sh` | `model-citizen/scripts/` | Phase 15 shell wrapper for Slack intelligence scan | Called from `scan-all.sh` intelligence section |
| `scan-outlook-intelligence.sh` | `model-citizen/scripts/` | Phase 15 shell wrapper for Outlook intelligence scan | Called from `scan-all.sh` intelligence section |
| `split-source.md` | `.claude/commands/` | Phase 15 atomic splitting skill | Called inline from intelligence pipeline after scanning |
| `match-themes.md` | `.claude/commands/` | Phase 15 theme matching skill | Called inline per-atom after splitting |
| `synthesize-draft.md` | `.claude/commands/` | Phase 15 synthesis skill | Content strategist mode (not unattended pipeline) |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `flock`-based lockfile | `mkdir`-based lock | `mkdir` is atomic and works even without `util-linux`; `flock` is cleaner but has macOS path subtleties. Use `mkdir` for portability. |
| `pipeline.lock` in `~/.model-citizen/` | Lock in vault dir | State dir is cleaner; vault path has spaces that complicate some shell commands |
| Content strategist as single command | Separate sub-commands per step | Single command with human approval gates is simpler to invoke and harder to skip steps |
| Auto-run split+match after every scan | Manual trigger | Auto-run in unattended context risks vault thrash; manual trigger preserves human review opportunity |

---

## Architecture Patterns

### Pipeline Flow

```
scan-all.sh (daily, 7:00 AM via launchd)
  ├── Existing scanners (Slack URL, Outlook URL, Queue, GoodLinks) — unchanged
  ├── [ACQUIRE pipeline.lock — fail fast if locked]
  ├── Intelligence section (NEW Phase 16)
  │   ├── scan-slack-intelligence.sh  → writes sources/slack/*.md
  │   ├── scan-outlook-intelligence.sh → writes sources/outlook/*.md
  │   └── [split + match automatically per new source note]
  └── [RELEASE pipeline.lock]

Interactive session:
  /content-strategist
    ├── [CHECK pipeline.lock — warn user if locked, offer to wait]
    ├── Propose clusters from unmatched atoms
    ├── Ask: "Which cluster would you like to develop?"
    ├── Run /match-themes on selected atoms
    ├── Ask: "Ready to synthesize?"
    └── Run /synthesize-draft "<theme>"
```

### Lockfile Pattern

**Acquire (in `scan-all.sh`):**
```bash
LOCK_DIR="$HOME/.model-citizen/pipeline.lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  echo "⚠ Pipeline lock active — interactive session in progress. Skipping intelligence run."
  exit 0
fi
# Register cleanup trap
trap 'rm -rf "$LOCK_DIR"' EXIT INT TERM
```

**Check (in content strategist command):**
```bash
LOCK_DIR="$HOME/.model-citizen/pipeline.lock"
if [[ -d "$LOCK_DIR" ]]; then
  echo "⚠ Daily scan is currently running (pipeline.lock held). Vault writes are paused."
  echo "Wait for scan to complete (check ~/.model-citizen/daily-scan.log) then retry."
  exit 1
fi
# Acquire lock for this session
mkdir "$LOCK_DIR"
trap 'rm -rf "$LOCK_DIR"' EXIT INT TERM
```

**Why `mkdir` not `flock`:** `mkdir` is atomic on HFS+/APFS; no util-linux dependency; works in both bash and zsh. The `LOCK_DIR` pattern (not a file) also survives interrupted processes because `EXIT` traps fire on most termination signals.

### scan-all.sh Integration Pattern

Follow the exact existing section pattern:

```bash
# 5. Intelligence Pipeline (scan → split → match)
echo -e "${BLUE}▶ Running intelligence pipeline...${NC}"
echo ""

INTEL_STATUS="SKIPPED"

# Acquire pipeline lock
LOCK_DIR="${MC_DIR}/pipeline.lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  echo -e "${YELLOW}⚠ Pipeline lock held by interactive session. Skipping intelligence run.${NC}"
  INTEL_STATUS="LOCKED"
else
  trap 'rm -rf "$LOCK_DIR"' EXIT INT TERM

  if [[ -z "${SLACK_BOT_TOKEN:-}" && -z "${MS_GRAPH_CLIENT_ID:-}" ]]; then
    echo -e "${YELLOW}⚠ No intelligence scanner credentials. Skipping.${NC}"
    INTEL_STATUS="SKIPPED"
  else
    if run_with_retry "$SCRIPT_DIR/scan-slack-intelligence.sh" 2>&1 | tee /tmp/scan-slack-intel.log && \
       run_with_retry "$SCRIPT_DIR/scan-outlook-intelligence.sh" 2>&1 | tee /tmp/scan-outlook-intel.log; then
      INTEL_STATUS="SUCCESS"
      echo -e "${GREEN}✓ Intelligence pipeline complete${NC}"
    else
      INTEL_STATUS="FAILED"
      echo -e "${RED}✗ Intelligence pipeline failed${NC}"
    fi
  fi

  rm -rf "$LOCK_DIR"
fi
```

**Add to summary section:**
```bash
echo "Intel:     $(format_status "$INTEL_STATUS")"
```

**Note on auto-split + auto-match:** The success criteria says "draft appears in `vault/drafts/`" from a single `scan-all.sh` run. This requires the pipeline to run split+match automatically after each new source note. This is the key design question — see Open Questions.

### Content Strategist Command Pattern

```markdown
# content-strategist

Interactive co-creation session for Model Citizen content pipeline.

## Step 1: Check lock
[bash check for pipeline.lock]
[warn if locked, acquire if free]

## Step 2: Surface cluster proposals
[grep atoms/ for unmatched atoms — those missing ## Theme connections section]
[group by source_type or date]
[present numbered list]

## Step 3: Ask for direction
"Which cluster would you like to develop? (Enter number or 'q' to quit)"

## Step 4: Match themes
[run /match-themes on selected atoms]

## Step 5: Synthesis prompt
"Ready to synthesize a draft from these atoms? Enter a theme/topic or 'skip':"

## Step 6: Generate draft
[if confirmed, run /synthesize-draft "<theme>"]
[report draft location]

## Step 7: Release lock
[rm pipeline.lock]
```

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Lock concurrency | Custom file-based mutex | `mkdir` atomic lock pattern | `mkdir` is atomic on APFS; avoids TOCTOU race |
| Intelligence pipeline runner | New orchestration script | Extend `scan-all.sh` inline | Keeps all automation in one file; follows existing pattern |
| Atom clustering for strategist | ML clustering algorithm | grep for unmatched atoms + group by date | Sufficient at current vault scale; grep is fast and auditable |
| E2E smoke test | Automated test harness | Manual run + vault inspection | Skills are agentic; E2E test is "run and check output" not unit test |

---

## Common Pitfalls

### Pitfall 1: `claude --command` in Unattended Context
**What goes wrong:** `scan-slack-intelligence.sh` calls `claude --command scan-slack-intelligence`. The `claude` CLI may require an interactive terminal or have different behavior when called from launchd (no TTY, minimal PATH, no home directory env vars).

**Why it happens:** launchd runs with a stripped environment (see plist `EnvironmentVariables` — only PATH is set). `claude` CLI may need `HOME`, `CLAUDE_API_KEY`, or interactive auth.

**How to avoid:** Test `scan-slack-intelligence.sh` directly from a terminal first (not launchd). If it works interactively, add explicit `HOME` env var to the plist or sourced env file. Check `~/.model-citizen/daily-scan.log` for auth errors.

**Warning signs:** `scan-all.sh` reports SUCCESS but no new vault notes appear; log shows "claude: command not found" or "Authentication required."

### Pitfall 2: Lock Not Released on Crash
**What goes wrong:** `scan-all.sh` crashes after acquiring `pipeline.lock` but before the `EXIT` trap fires. Lock dir persists indefinitely. All future scheduled runs silently skip intelligence pipeline.

**Why it happens:** `EXIT` traps don't fire on `kill -9` or power loss.

**How to avoid:** Add a stale lock check at acquisition time. If `pipeline.lock` is older than 2 hours, remove it automatically and proceed:
```bash
if [[ -d "$LOCK_DIR" ]]; then
  LOCK_AGE=$(( $(date +%s) - $(stat -f %m "$LOCK_DIR") ))
  if (( LOCK_AGE > 7200 )); then
    echo "Stale lock (${LOCK_AGE}s old). Removing."
    rm -rf "$LOCK_DIR"
  fi
fi
```

**Warning signs:** Intelligence section always shows "LOCKED" in daily scan summary even when no interactive session is active.

### Pitfall 3: Auto-Split Creates Duplicate Atoms
**What goes wrong:** If `scan-all.sh` runs split+match automatically but the source note is not marked `content_status: processed`, re-running the pipeline creates duplicate atoms.

**Why it happens:** `scan-slack-intelligence.sh` creates source notes. If split is triggered automatically for every source note on every scan run, processed notes get re-split.

**How to avoid:** `split-source.md` already has a guard: "If the source note has `content_status: processed`, report 'Note already processed. Skipping.' and stop." The auto-split step must pass only notes where `content_status != processed`. Grep filter:
```bash
grep -rL "content_status: processed" "$VAULT_SOURCES"/*.md 2>/dev/null
```

**Warning signs:** Atom count grows faster than expected; duplicate atom files with same title but different timestamps.

### Pitfall 4: Success Criteria Requires Synthesis in Unattended Run
**What goes wrong:** The Phase 16 success criterion says "a draft appears in `vault/drafts/`" from a single `scan-all.sh` run. But `synthesize-draft` takes a theme argument — it can't self-select what to synthesize in an unattended context.

**Why it happens:** Synthesis is the most subjective step; it requires theme selection which is inherently human judgment.

**How to avoid:** The smoke test for E2E (success criterion 4) likely means: scan → split → match runs automatically, THEN manually run `/synthesize-draft "<theme>"` to verify the complete flow. The "single scan-all.sh run" produces source notes + atoms + connections; synthesis is triggered manually as the human step. Clarify this interpretation in PLAN.md.

**Alternative interpretation:** Auto-synthesize the most-connected theme after matching. This is more automated but may produce low-quality drafts on first run with sparse atoms.

---

## Code Examples

### Stale Lock Detection (bash)
```bash
# Source: standard POSIX bash pattern
LOCK_DIR="$HOME/.model-citizen/pipeline.lock"
if [[ -d "$LOCK_DIR" ]]; then
  LOCK_AGE=$(( $(date +%s) - $(stat -f %m "$LOCK_DIR") ))
  if (( LOCK_AGE > 7200 )); then
    echo "Stale lock (${LOCK_AGE}s). Removing."
    rm -rf "$LOCK_DIR"
  else
    echo "Pipeline locked by active session (${LOCK_AGE}s old). Skipping."
    exit 0
  fi
fi
mkdir "$LOCK_DIR"
trap 'rm -rf "$LOCK_DIR"' EXIT INT TERM
```

### Finding Unprocessed Source Notes (bash)
```bash
# Find source notes that haven't been split yet
VAULT_SOURCES=~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/2B-new/700\ Model\ Citizen/sources
find "$VAULT_SOURCES" -name "*.md" -newer "$STATE_FILE" | while read -r note; do
  if ! grep -q "content_status: processed" "$note"; then
    echo "$note"
  fi
done
```

### Finding Unmatched Atoms (for content strategist)
```bash
# Atoms without a ## Theme connections section
VAULT_ATOMS=~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/2B-new/700\ Model\ Citizen/atoms
grep -rL "## Theme connections" "$VAULT_ATOMS"/*.md 2>/dev/null
```

---

## State of the Art

| Old Approach | Current Approach | Notes |
|--------------|------------------|-------|
| `scan-slack.sh` (URL-only) | `scan-slack-intelligence.sh` → Claude command | Phase 15 replacement |
| `scan-outlook.sh` (URL-only) | `scan-outlook-intelligence.sh` → Claude command | Phase 15 replacement |
| No pipeline after scanning | scan → split → match → (synthesis) | Phase 16 wiring |
| No concurrency protection | `pipeline.lock` mutual exclusion | Phase 16 new |
| No interactive content mode | `/content-strategist` command | Phase 16 new |

---

## Open Questions

1. **Does scan-all.sh auto-run split+match, or just scan?**
   - What we know: Success criterion 4 says "a draft appears in `vault/drafts/`" from one `scan-all.sh` run. Drafts require synthesis, which requires atoms, which requires splitting.
   - What's unclear: Does the unattended pipeline run split+match automatically after scanning? Or does "one run" mean scan runs automatically, then user manually runs split+match+synthesize?
   - Recommendation: The cleanest interpretation is scan+split+match runs automatically (fully automated); synthesis remains human-triggered via `/content-strategist`. This satisfies "draft appears" if the smoke test includes a manual synthesis step. Clarify in PLAN.md task 1.

2. **Can `claude --command` run reliably from launchd?**
   - What we know: The shell wrappers call `claude --command <name>`. launchd runs with minimal env. The `claude` binary path must be in `PATH` in the plist.
   - What's unclear: Does `claude` require interactive auth, a browser callback, or TTY? Does it work when called from a non-interactive shell?
   - Recommendation: Smoke test `scan-slack-intelligence.sh` from a terminal FIRST. If it works, test from launchd by triggering `launchctl start com.model-citizen.daily-scan` and checking the log. Document findings in PLAN.md.

3. **What is the content strategist's synthesis trigger?**
   - What we know: ORCH-04 says "surfaces a cluster proposal and requests direction before generating any draft."
   - What's unclear: Does "cluster proposal" mean showing a list of themes with atom counts, then asking which to synthesize? Or showing individual unmatched atoms and asking which to connect?
   - Recommendation: Surface unmatched atoms grouped by source_type and date. Present as numbered clusters. User picks one; strategist runs match-themes on it, then asks if ready to synthesize.

---

## Validation Architecture

No automated test framework is configured for this project. Validation is observational/functional.

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | How to Verify |
|--------|----------|-----------|---------------|
| ORCH-01 | Skills invocable on-demand via Claude Code | Manual | Run `/scan-slack-intelligence` in a Claude Code session; verify source note appears in vault |
| ORCH-02 | scan-all.sh triggers full pipeline | Functional/smoke | Run `scan-all.sh`; check log for intelligence section; verify new vault notes |
| ORCH-03 | Lockfile prevents concurrent writes | Functional | Acquire lock manually (`mkdir ~/.model-citizen/pipeline.lock`); run `scan-all.sh`; verify it skips intelligence section |
| ORCH-04 | Content strategist surfaces clusters before drafting | Manual/interactive | Run `/content-strategist`; verify it shows atom list before any synthesis |

### Wave 0 Gaps

- [ ] `~/.model-citizen/pipeline.lock` — lock dir convention must be established before testing
- [ ] At least one real Slack starred message or Outlook email must exist for smoke test
- [ ] `vault/drafts/` directory must exist (or be created by synthesize-draft command)

---

## Sources

### Primary (HIGH confidence)
- Existing `scan-all.sh` (read directly) — full anatomy, credential checks, retry pattern, summary format
- Phase 15 SUMMARY.md files (15-01 through 15-05) — exact skills built, decisions made, file locations
- Phase 15 VERIFICATION.md — confirmed all 12 requirements passed
- `.claude/commands/` directory listing — confirmed all 5 skill files exist

### Secondary (MEDIUM confidence)
- `com.model-citizen.daily-scan.plist` (read directly) — launchd config, PATH, logging
- `scan-slack-intelligence.sh` and `scan-outlook-intelligence.sh` (read directly) — confirmed `claude --command` invocation pattern

### Tertiary (LOW confidence)
- `claude --command` unattended behavior — inferred from shell wrapper pattern; not tested from launchd context

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — infrastructure read directly, all files confirmed exist
- Architecture: HIGH — `scan-all.sh` pattern is clear; lockfile pattern is standard bash; content strategist follows established skill pattern
- Pitfalls: MEDIUM — lockfile pitfalls are well-known; `claude --command` from launchd is LOW (not empirically tested)

**Research date:** 2026-03-01
**Valid until:** 2026-04-01 (stable bash patterns; no fast-moving dependencies)
