# Phase 6: Claude Code Agent Integration - Context

**Gathered:** 2026-02-05
**Status:** Ready for planning

<domain>

## Phase Boundary

Enable n8n to invoke Claude Code on your local machine via SSH. This allows n8n (running as workflow orchestrator) to delegate AI-driven synthesis tasks (summarization, tagging, drafting) to Claude Code/Cursor Agent on-demand.

This phase establishes the **handoff pattern**. Specific synthesis tasks (summary, tagging) come in Phase 7.

</domain>

<decisions>

## Implementation Decisions

### n8n ↔ Claude Code Communication

**Chosen pattern: SSH execution** (decision made during context gathering)
- n8n executes SSH command to your local machine
- Command invokes Claude Code with a prepared prompt file
- Claude Code reads task details from Vault, executes workflow, writes output
- n8n polls for completion or waits for SSH response

**Rationale:** Decouples n8n from Claude Code; Claude Code remains your primary IDE tool, n8n just kicks off tasks.

### Prompt Preparation

Before SSH invocation, n8n:
- Creates temp task file in Vault: `.model-citizen/tasks/{task-id}.md` with full context
- Includes: source note path, task type (summarize/tag/draft), instructions, dependencies
- Commits to Vault (so task is tracked in Git)
- Passes task file path to Claude Code via SSH

### Claude Code Wrapper CLI

n8n calls something like:
```bash
ssh user@machine "claude-code --task-file /path/to/task.md --output-dir /vault/enriched/"
```

**Requirements:**
- Simple wrapper script that Claude Code can execute
- Reads task file, invokes appropriate workflow
- Writes output to specified directory
- Returns exit code 0 on success

### Idempotency & Error Handling

- Task file includes idempotency key (prevents duplicate processing)
- If output already exists, skip or prompt for overwrite
- SSH timeout handling (what if Claude Code hangs?)
- Error output captured and logged in n8n

### Local Machine Assumptions

- SSH access to local machine (passwordless key auth preferred)
- Claude Code installed and accessible from CLI
- Vault repository already cloned locally
- n8n can reach local machine (may require SSH tunneling if n8n is cloud-hosted, but n8n is local Docker so this is simple)

### Claude's Discretion

- Exact SSH command syntax and error handling
- Timeout values for Claude Code tasks
- How to handle network interruptions mid-workflow
- Whether to batch multiple tasks in one SSH call vs one-per-invocation

</decisions>

<specifics>

## Specific Ideas

- **You already have Claude Code:** The wrapper is a simple CLI harness that lets n8n talk to your existing workflow setup. Keep your normal development experience — n8n is just another way to trigger it.

- **Task files are auditable:** Every synthesis task is tracked in Git (in `.model-citizen/tasks/`) so you can see what n8n asked Claude Code to do and what it produced.

- **Hybrid human-AI workflow:** Claude Code can handle synthesis, but you can also jump in and edit/refine outputs before they move to publishing.

</specifics>

<deferred>

## Deferred Ideas

- Direct Claude API integration in n8n (simpler than SSH, but less flexible)
- Cursor Agent invocation (similar pattern, could add later)
- Codex invocation (if needed)
- Local LLM integration via Ollama (alternative to Claude Code)
- Web UI for task monitoring (could show pending tasks, results)

</deferred>

---

*Phase: 06-claude-code-integration*
*Context gathered: 2026-02-05*
