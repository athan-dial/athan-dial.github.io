---
phase: 06-claude-code-integration
plan: 01
name: SSH Infrastructure and Wrapper Script
subsystem: automation
tags: [ssh, claude-code, n8n, automation, infrastructure]

requires:
  - 05-02-host-script-final # YouTube ingestion architecture established
provides:
  - ssh-infrastructure # Passwordless authentication for n8n container
  - claude-wrapper-cli # Shell script for task-based Claude invocation
  - task-schema # Standardized task file format
dependencies:
  - host: macOS Remote Login enabled
  - vault: ~/model-citizen-vault directory structure
  - cli: Claude Code CLI installed and authenticated
affects:
  - 06-02 # n8n workflow will use SSH credentials and wrapper script
  - phase-07 # Enrichment pipeline depends on this automation layer

tech-stack:
  added: []
  patterns:
    - SSH key-based authentication for container-to-host
    - Atomic file writes (temp + rename) for idempotency
    - YAML frontmatter for task metadata
    - Exit code conventions for error handling

key-files:
  created:
    - ~/.ssh/n8n_docker
    - ~/.ssh/n8n_docker.pub
    - ~/model-citizen-vault/.model-citizen/SCHEMA.md
    - ~/model-citizen-vault/.model-citizen/tasks/.gitkeep
    - ~/model-citizen-vault/.model-citizen/outputs/.gitkeep
    - ~/model-citizen-vault/scripts/claude-task-runner.sh
  modified:
    - ~/.ssh/authorized_keys

decisions:
  - slug: ed25519-key-for-automation
    summary: Use ed25519 SSH key without passphrase for n8n automation
    rationale: Modern algorithm, smaller keys than RSA, no passphrase needed for automated invocation
  - slug: idempotency-via-output-check
    summary: Wrapper checks if output file exists before processing
    rationale: Prevents duplicate work if n8n retries failed workflows
  - slug: restricted-tools-for-safety
    summary: Wrapper limits Claude Code to Read, Grep, Glob, WebFetch tools
    rationale: Prevents accidental file modifications during automated processing
  - slug: atomic-writes-with-temp-files
    summary: Write to .tmp file then rename on success
    rationale: Avoids partial/corrupted output if Claude Code crashes mid-execution
  - slug: timeout-command-for-reliability
    summary: Wrap Claude invocation with timeout command (600s default)
    rationale: Prevents hung processes from blocking pipeline indefinitely
  - slug: json-validation-optional
    summary: Wrapper validates JSON but saves output even if invalid
    rationale: Claude might return useful non-JSON output for debugging

metrics:
  completed: 2026-02-06
  duration: 2min
  tasks: 5
  commits: 2
---

# Phase 06 Plan 01: SSH Infrastructure and Wrapper Script Summary

**One-liner:** Established SSH key-based authentication and 218-line wrapper script enabling n8n container to invoke Claude Code on macOS host via task files.

## What Was Built

### SSH Infrastructure
- **ed25519 key pair** (`~/.ssh/n8n_docker` / `.pub`) for passwordless authentication
- **authorized_keys** configuration for n8n container access
- **Remote Login** enabled on macOS (user-completed checkpoint)
- **Verified connectivity** from localhost (simulating Docker container access)

### Task Processing System
- **Directory structure**: `.model-citizen/tasks/` (input) and `.model-citizen/outputs/` (results)
- **SCHEMA.md**: Documents task file format with YAML frontmatter (task_id, task_type, source_path, output_path)
- **.gitkeep files**: Preserve empty directories in git for fresh clones

### Claude Task Runner Script
- **218-line wrapper** (`scripts/claude-task-runner.sh`) with:
  - Argument parsing: `--task-file`, `--timeout`, `--verbose`, `--help`
  - Frontmatter extraction: Parses task_id, output_path, timeout from YAML
  - Idempotency: Skips processing if output file already exists
  - Claude invocation: Pipes task file to `claude -p --output-format text`
  - Tool restriction: Limits to Read, Grep, Glob, WebFetch (no Write/Edit)
  - Timeout handling: Uses `timeout` command with exit code 124
  - Atomic writes: Temp file → rename on success
  - JSON validation: Attempts to validate but saves output regardless
  - Error handling: Exit codes 0 (success), 1 (general), 2 (invalid input), 3 (Claude failed), 124 (timeout)

## Task Commits

| # | Task Name | Commit | Files |
|---|-----------|--------|-------|
| 1 | Generate SSH key pair | (system-level) | ~/.ssh/n8n_docker, ~/.ssh/n8n_docker.pub, ~/.ssh/authorized_keys |
| 2 | Enable macOS Remote Login | (checkpoint) | System Settings change |
| 3 | Create .model-citizen directories | 4e1acba | .model-citizen/{SCHEMA.md, tasks/.gitkeep, outputs/.gitkeep} |
| 4 | Create wrapper script | b97a6b8 | scripts/claude-task-runner.sh (218 lines) |
| 5 | Verify SSH connectivity | (verification) | Documented connection parameters |

**model-citizen-vault commits:**
- `4e1acba` - feat(06-01): add task processing infrastructure
- `b97a6b8` - feat(06-01): add Claude Code wrapper script

## Decisions Made

### 1. ed25519 SSH Key (No Passphrase)
**Why:** Automated SSH from n8n container requires passwordless authentication. ed25519 provides modern security with smaller keys than RSA.

**Impact:** n8n can invoke wrapper script via SSH without manual intervention. Private key will be mounted into Docker container (Plan 06-02).

### 2. Idempotency via Output File Check
**Why:** n8n may retry failed workflows, leading to duplicate processing of same task.

**Implementation:** Wrapper checks if `output_path` file exists before invoking Claude. Returns exit code 0 (success) if output exists.

**Trade-off:** Doesn't detect if task file changed (no content hash comparison). Acceptable for MVP since n8n uses unique task IDs.

### 3. Restricted Tools for Safety
**Why:** Automated Claude invocation in production pipeline must not accidentally modify files.

**Implementation:** `--allowedTools 'Read,Grep,Glob,WebFetch'` excludes Write, Edit, Bash tools.

**Trade-off:** Claude cannot create/modify files during task execution. Tasks must be read-only analysis (summarize, tag, etc.). Acceptable since enrichment pipeline is read → analyze → output JSON.

### 4. Atomic Writes (Temp + Rename)
**Why:** If Claude Code crashes mid-execution, partial JSON would break downstream processing.

**Implementation:** Write to `{output_path}.tmp.$$` → validate → rename to final path.

**Benefit:** Output file either doesn't exist OR contains complete result. No partial writes.

### 5. Timeout with Exit Code 124
**Why:** Long-running Claude tasks could block pipeline indefinitely.

**Implementation:** `timeout` command wraps Claude invocation. Default 600s (10 min), overridable per-task in frontmatter.

**Exit code 124:** Standard timeout exit code, allows n8n to distinguish timeout from other failures.

### 6. JSON Validation (Non-Blocking)
**Why:** Most tasks expect JSON output, but strict validation might discard useful debugging info.

**Implementation:** Attempt `python3 json.load()` validation. If fails, log warning but still save output.

**Rationale:** Non-JSON output (error messages, partial results) is better than no output for debugging failed tasks.

## Deviations from Plan

None - plan executed exactly as written.

## Authentication Gates

**Task 2: macOS Remote Login**
- **Type:** human-action checkpoint
- **Why unavoidable:** System Integrity Protection prevents programmatic changes to macOS sharing settings
- **User action:** System Settings > General > Sharing > Remote Login (toggle ON)
- **Verification:** `ssh localhost "echo 'SSH works'"` succeeded
- **Resume:** Marked Task 2 complete, proceeded to Task 3

## Next Phase Readiness

### For 06-02 (n8n SSH Node Configuration)
**Ready:**
- SSH credentials: `~/.ssh/n8n_docker` private key
- SSH connection params: `host.docker.internal:22`, user `adial`
- Wrapper command: `~/model-citizen-vault/scripts/claude-task-runner.sh --task-file <path>`
- Verified SSH connectivity works from localhost (simulates container)

**Blockers:** None

### For Phase 07 (Enrichment Pipeline)
**Ready:**
- Task schema documented (YAML frontmatter format)
- Output directory structure (`.model-citizen/outputs/`)
- Exit code conventions for error handling

**Needs:** n8n workflow to orchestrate task creation → SSH invocation → output processing (Plan 06-02)

## Known Limitations

1. **No content-based idempotency:** Wrapper checks file existence, not input hash. Re-processing same content with different task ID will duplicate work.

2. **No dependency resolution:** `depends_on` field documented in schema but not implemented in wrapper. n8n must handle task ordering.

3. **Docker host networking assumption:** `host.docker.internal` is Docker Desktop convention. Won't work on Linux (needs `host.docker.internal` in /etc/hosts or `--network host`).

4. **Python3 dependency:** JSON validation requires Python 3. Fails gracefully if missing (saves output with warning).

5. **No task queuing:** Wrapper is stateless, processes one task per invocation. n8n must manage concurrency and rate limiting.

## Performance Metrics

**Execution:**
- **Duration:** 2 minutes (checkpoint continuation)
- **Tasks:** 5 (1 system-level, 1 checkpoint, 3 automated)
- **Commits:** 2 (model-citizen-vault repository)
- **Lines of code:** 297 (218 wrapper script + 79 schema/docs)

**Verification:**
- All must_haves satisfied (SSH works, wrapper executable, atomic writes, idempotency)
- All key_links verified (wrapper pipes to `claude -p`, atomic `mv` pattern exists)

## Self-Check: PASSED

**Created files verified:**
```bash
✓ ~/.ssh/n8n_docker (600 permissions)
✓ ~/.ssh/n8n_docker.pub (644 permissions)
✓ ~/model-citizen-vault/.model-citizen/SCHEMA.md
✓ ~/model-citizen-vault/.model-citizen/tasks/.gitkeep
✓ ~/model-citizen-vault/.model-citizen/outputs/.gitkeep
✓ ~/model-citizen-vault/scripts/claude-task-runner.sh (executable)
```

**Commits verified:**
```bash
✓ 4e1acba - feat(06-01): add task processing infrastructure
✓ b97a6b8 - feat(06-01): add Claude Code wrapper script
```
