# Phase 6: Claude Code Agent Integration - Research

**Researched:** 2026-02-05
**Domain:** SSH-based remote command execution from Docker n8n to macOS host
**Confidence:** MEDIUM

## Summary

This phase establishes an SSH-based integration allowing n8n (running in Docker) to invoke Claude Code on the macOS host machine for AI-driven synthesis tasks. The pattern involves n8n preparing task files in the Vault, executing a wrapper script via SSH, and Claude Code processing tasks using the `-p` (print) mode for non-interactive execution.

The approach leverages existing infrastructure (n8n Docker container with Vault bind mount, host-side yt-dlp pattern from Phase 5) and extends it with programmatic Claude Code invocation. Key challenges include SSH authentication setup, task file idempotency, timeout handling, and error capture.

**Primary recommendation:** Build a simple Bash wrapper (`claude-task-runner.sh`) that reads task files from `.model-citizen/tasks/`, invokes `claude -p` with custom system prompts, and writes outputs to designated directories. Use SSH key authentication with `host.docker.internal` for container-to-host communication on macOS Docker Desktop.

## Standard Stack

The established tools for SSH-based remote command execution from Docker:

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| n8n SSH Node | Built-in (latest) | Execute remote commands via SSH | Native n8n integration, supports key auth, captures stdout/stderr |
| Claude Code CLI | Latest (2.x) | Non-interactive AI agent invocation | Official Anthropic CLI, `-p` flag for programmatic use, `--output-format json` for parsing |
| macOS Remote Login | System (SSH) | SSH server on macOS | Built-in macOS SSH server, enabled via System Settings |
| Docker Desktop for Mac | Latest | Container runtime | Provides `host.docker.internal` DNS for host access |

### Supporting
| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| Bash (>=4.0) | System | Wrapper script language | Argument parsing, error handling, file operations |
| Git | System | Task tracking and output versioning | Commit task files and outputs for auditability |
| SSH key-pair | N/A | Passwordless authentication | n8n → host authentication without password prompts |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| SSH execution | Direct Claude API in n8n | SSH preserves local Claude Code setup, but API is simpler |
| Bash wrapper | Python script | Python offers better parsing, but adds dependency |
| Task files in Vault | n8n variables only | Vault approach provides Git tracking and human auditability |

**Installation:**
```bash
# Enable SSH on macOS
# System Settings → General → Sharing → Remote Login (toggle on)

# Generate SSH key pair (if not exists)
ssh-keygen -t ed25519 -C "n8n-docker" -f ~/.ssh/n8n_docker

# Add public key to authorized_keys
cat ~/.ssh/n8n_docker.pub >> ~/.ssh/authorized_keys

# Test SSH from Docker container
docker exec -it n8n ssh -i /path/to/key user@host.docker.internal "echo 'Connection test'"
```

## Architecture Patterns

### Recommended Project Structure
```
~/model-citizen-vault/
├── .model-citizen/
│   ├── tasks/               # Task files from n8n (input)
│   │   └── {task-id}.md     # Task specification with context
│   └── outputs/             # Claude Code results (output)
│       └── {task-id}.json   # Structured output
├── scripts/
│   ├── ingest-youtube.sh    # Existing (Phase 5)
│   └── claude-task-runner.sh # New wrapper (Phase 6)
└── sources/                 # Content to process
```

### Pattern 1: Task File Specification
**What:** Markdown file with frontmatter containing task metadata and instructions
**When to use:** Every n8n workflow that needs Claude Code processing
**Example:**
```markdown
---
task_id: "abc-123-def"
task_type: "summarize"
created_at: "2026-02-05T14:30:00Z"
source_path: "sources/youtube/video-transcript.md"
output_path: ".model-citizen/outputs/abc-123-def.json"
idempotency_key: "sha256:abc123..."
---

# Task: Summarize Video Transcript

Read the transcript at `sources/youtube/video-transcript.md` and produce:
- 3-5 sentence summary
- Key themes (max 5)
- Suggested tags for vault

Output as JSON with keys: summary, themes, tags
```

### Pattern 2: Wrapper Script Invocation
**What:** Bash wrapper that bridges n8n SSH calls to Claude Code execution
**When to use:** All n8n → Claude Code workflows
**Example:**
```bash
#!/bin/bash
# claude-task-runner.sh
# Usage: claude-task-runner.sh --task-file <path> [--timeout 600]

set -euo pipefail

VAULT_DIR="$HOME/model-citizen-vault"
TASK_FILE=""
TIMEOUT=600  # 10 minutes default

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --task-file) TASK_FILE="$2"; shift 2 ;;
        --timeout) TIMEOUT="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Validate task file exists
if [[ ! -f "$TASK_FILE" ]]; then
    echo "Error: Task file not found: $TASK_FILE" >&2
    exit 2
fi

# Extract output path from frontmatter
OUTPUT_PATH=$(grep "^output_path:" "$TASK_FILE" | cut -d' ' -f2- | tr -d '"')

# Check idempotency (skip if output exists)
if [[ -f "$VAULT_DIR/$OUTPUT_PATH" ]]; then
    echo "Output already exists (idempotent skip): $OUTPUT_PATH"
    exit 0
fi

# Invoke Claude Code with timeout
timeout "$TIMEOUT" claude -p \
    --output-format json \
    --system-prompt-file "$TASK_FILE" \
    --tools "Read,Grep,Glob" \
    "Execute the task described in this system prompt" \
    > "$VAULT_DIR/$OUTPUT_PATH" 2> "$VAULT_DIR/$OUTPUT_PATH.err"

EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
    echo "Task completed: $OUTPUT_PATH"
    rm -f "$VAULT_DIR/$OUTPUT_PATH.err"  # Clean up empty error file
    exit 0
elif [[ $EXIT_CODE -eq 124 ]]; then
    echo "Error: Task timed out after ${TIMEOUT}s" >&2
    exit 124
else
    echo "Error: Claude Code failed with exit code $EXIT_CODE" >&2
    cat "$VAULT_DIR/$OUTPUT_PATH.err" >&2
    exit $EXIT_CODE
fi
```

### Pattern 3: n8n SSH Node Configuration
**What:** n8n workflow node that executes wrapper script on host
**When to use:** Final step in content enrichment workflows
**Example:**
```javascript
// n8n SSH node configuration (JSON)
{
  "host": "host.docker.internal",
  "port": 22,
  "username": "{{ $env.MACOS_USER }}",
  "privateKey": "{{ $credentials.ssh_macos.privateKey }}",
  "command": "~/model-citizen-vault/scripts/claude-task-runner.sh --task-file {{ $json.task_file_path }} --timeout 600"
}
```

### Anti-Patterns to Avoid
- **Direct API calls in n8n:** Loses local Claude Code configuration, hooks, and plugins
- **Polling for completion:** SSH is synchronous; wait for exit code instead
- **Hardcoded paths:** Use environment variables for user home, vault location
- **Skipping idempotency checks:** Always check if output exists before re-running expensive tasks

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| SSH connection management | Custom socket handling | n8n SSH node | Handles auth, timeouts, error capture automatically |
| Argument parsing in wrapper | Manual $1, $2 parsing | `getopts` or case/shift pattern | Supports flags, defaults, validation |
| Atomic file writes | Direct write to target | Write to temp, then rename | Prevents partial writes on crash/timeout |
| Exit code interpretation | Custom error mapping | Standard codes (0, 1, 2, 124) | 0=success, 124=timeout, 2=blocking error, other=non-blocking |
| Task file parsing | Custom regex/awk | `grep` frontmatter + `yq`/`jq` for YAML | Handles edge cases, escaping, multiline values |

**Key insight:** SSH, timeout handling, and atomic file operations have decades of battle-tested patterns. Use system tools (`timeout`, `ssh`, `mv`) rather than reimplementing.

## Common Pitfalls

### Pitfall 1: Docker → Host SSH Authentication Failures
**What goes wrong:** n8n cannot connect to host.docker.internal:22 with "Permission denied" or "Connection refused"
**Why it happens:**
- Remote Login not enabled on macOS
- SSH key not in container's mounted volume
- Key permissions too permissive (SSH requires 600)
- Trying to use `localhost` instead of `host.docker.internal`

**How to avoid:**
1. Enable Remote Login: System Settings → Sharing → Remote Login
2. Generate dedicated key pair for n8n: `ssh-keygen -t ed25519 -f ~/.ssh/n8n_docker`
3. Add public key to `~/.ssh/authorized_keys`
4. Mount private key into n8n container with 600 permissions
5. Use `host.docker.internal` in n8n SSH node (not `localhost`, `127.0.0.1`, or machine IP)

**Warning signs:**
- Error: "Connection refused" → Remote Login disabled or wrong hostname
- Error: "Permission denied (publickey)" → Key not authorized or wrong user
- Error: "Load key: invalid format" → Key file corrupted or permissions wrong

### Pitfall 2: Task Non-Idempotency (Duplicate Processing)
**What goes wrong:** Same content processed multiple times, creating duplicate outputs or overwriting previous results
**Why it happens:**
- Output path not checked before execution
- Task ID not unique (timestamp collisions)
- Output file deleted but task marked as complete
- Wrapper script doesn't check for existing output

**How to avoid:**
1. Generate UUIDs for task IDs (not timestamps): `uuidgen` or `$(date +%s)-$(uuidgen | cut -d'-' -f1)`
2. Check output file existence at start of wrapper script
3. Use atomic renames for output (write to temp, mv to final)
4. Include idempotency_key in task file (hash of input content)
5. Log completed tasks to `.model-citizen/completed.log`

**Warning signs:**
- Multiple output files with same prefix
- Git shows same file modified repeatedly with identical content
- n8n workflow re-runs produce different task IDs for same input

### Pitfall 3: Claude Code Hangs Without Timeout
**What goes wrong:** Wrapper script called via SSH never returns, blocking n8n workflow indefinitely
**Why it happens:**
- Claude Code waiting for user input (shouldn't happen in `-p` mode, but bugs exist)
- Network issue during API call (no timeout on HTTP client)
- Infinite loop in custom hook or plugin
- `--tools` includes interactive tools (like `AskUser`)

**How to avoid:**
1. Always wrap Claude invocation with `timeout` command: `timeout 600 claude -p ...`
2. Use `--dangerously-skip-permissions` for fully automated runs (or configure `--allowedTools`)
3. Set n8n SSH node timeout slightly higher than wrapper timeout (e.g., 620s vs 600s)
4. Disable interactive tools: `--tools "Read,Write,Bash,Grep,Glob"` (exclude `AskUser`, `IDE`)
5. Test wrapper script manually before n8n integration

**Warning signs:**
- n8n workflow shows "Running" for >5 minutes on SSH node
- SSH connection times out but no exit code captured
- Error log shows: "Execution canceled" or "Timeout exceeded"

### Pitfall 4: Error Output Lost in SSH Execution
**What goes wrong:** Wrapper script fails but n8n only shows exit code, losing valuable error details
**Why it happens:**
- stderr not captured by n8n SSH node
- Error messages written to file instead of stderr
- Claude Code error buried in verbose logs
- Exit code doesn't distinguish error types

**How to avoid:**
1. Write errors to both stderr AND error file: `echo "Error" >&2; echo "Error" > "$OUTPUT.err"`
2. Use descriptive exit codes: 0=success, 2=invalid input, 3=claude failed, 124=timeout
3. Configure n8n to capture stderr: Enable "Return stderr" option in SSH node
4. Include error summary in stdout before exit: `echo "FAILED: $ERROR_MSG"`
5. Log to syslog for debugging: `logger -t claude-task-runner "Error: $MSG"`

**Warning signs:**
- n8n shows "exit code 1" with no other information
- Debugging requires SSH into host and checking log files
- Same error repeats but root cause unclear

## Code Examples

Verified patterns from official sources:

### Claude Code Non-Interactive Invocation
```bash
# Source: https://code.claude.com/docs/en/cli-reference
# Basic print mode (non-interactive)
claude -p "Summarize this file" --output-format json

# With custom system prompt file
claude -p --system-prompt-file task.md "Execute this task" --output-format json

# With restricted tools (no interactive prompts)
claude -p --tools "Read,Write,Bash,Grep,Glob" "Analyze this codebase"

# With timeout (using shell timeout command)
timeout 600 claude -p "Long running task" > output.json

# Capture exit code for error handling
claude -p "Task" > output.json 2> error.log
EXIT_CODE=$?
if [[ $EXIT_CODE -eq 0 ]]; then
    echo "Success"
else
    echo "Failed: exit code $EXIT_CODE"
    cat error.log >&2
    exit $EXIT_CODE
fi
```

### n8n SSH Node Error Capture
```javascript
// Source: https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.ssh/
// n8n SSH node configuration (Execute Command operation)
{
  "parameters": {
    "command": "~/vault/scripts/claude-task-runner.sh --task-file {{ $json.task_file }}",
    "cwd": "/home/user",
    "returnStderr": true  // CRITICAL: Capture error output
  },
  "credentials": {
    "ssh": {
      "host": "host.docker.internal",
      "port": 22,
      "username": "adial",
      "privateKey": "-----BEGIN OPENSSH PRIVATE KEY-----\n...",
      "passphrase": ""
    }
  }
}

// Downstream node checks exit code
// n8n automatically adds $json.exitCode to output
if ($json.exitCode !== 0) {
    throw new Error(`Task failed: ${$json.stderr}`);
}
```

### Atomic File Write Pattern
```bash
# Source: https://python-atomicwrites.readthedocs.io/ (adapted to Bash)
# Write to temp file, then atomic rename
OUTPUT_FILE="$VAULT_DIR/$OUTPUT_PATH"
TEMP_FILE="$OUTPUT_FILE.tmp.$$"

# Write output (may fail/timeout)
claude -p ... > "$TEMP_FILE" 2> "$TEMP_FILE.err"

# Only on success, atomically replace
if [[ $? -eq 0 ]]; then
    mv "$TEMP_FILE" "$OUTPUT_FILE"  # Atomic on same filesystem
    rm -f "$TEMP_FILE.err"
    echo "Wrote: $OUTPUT_FILE"
else
    # Preserve temp and error for debugging
    echo "Failed, see: $TEMP_FILE and $TEMP_FILE.err" >&2
    exit 1
fi
```

### Task File Frontmatter Parsing
```bash
# Source: Standard grep/sed patterns for YAML frontmatter
# Extract fields from task file frontmatter
extract_field() {
    local file="$1"
    local field="$2"

    # Grep field line, cut after colon, trim quotes/spaces
    grep "^${field}:" "$file" | \
        head -1 | \
        cut -d':' -f2- | \
        sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^"//;s/"$//'
}

TASK_ID=$(extract_field "$TASK_FILE" "task_id")
OUTPUT_PATH=$(extract_field "$TASK_FILE" "output_path")
TIMEOUT=$(extract_field "$TASK_FILE" "timeout" || echo "600")

echo "Processing task: $TASK_ID"
echo "Output will be: $OUTPUT_PATH"
echo "Timeout: ${TIMEOUT}s"
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Claude API calls in n8n | SSH to host Claude Code CLI | 2026 (Claude Code 2.x) | Preserves local setup, hooks, plugins |
| Password SSH auth | SSH key-based auth | Always standard | Required for automation (no password prompt) |
| Polling for task completion | Synchronous SSH (wait for exit) | n8n SSH node behavior | Simpler workflow, no polling nodes |
| Custom Docker images | Host-side tools | Phase 5 decision (yt-dlp) | Hardened n8n images; prefer host tools |
| `--print` flag | `-p` flag | Claude Code 2.x | Shorter syntax |

**Deprecated/outdated:**
- **Docker exec to run commands on host**: Docker containers cannot `exec` outside their namespace; use SSH instead
- **localhost for host access**: Use `host.docker.internal` on Docker Desktop for Mac/Windows
- **claude --non-interactive**: Old flag; replaced by `-p` in Claude Code 2.x
- **Password auth for automated SSH**: Use keys; password prompts block non-interactive execution

## Open Questions

Things that couldn't be fully resolved:

1. **Does Claude Code `-p` mode honor `--dangerously-skip-permissions` for all tools?**
   - What we know: Flag exists and is documented for non-interactive use
   - What's unclear: Whether Bash/Write tools still prompt in some edge cases
   - Recommendation: Test with wrapper script; if prompts occur, use `--allowedTools` to pre-approve patterns
   - Confidence: MEDIUM (documentation says yes, but real-world testing needed)

2. **How long should timeout be for synthesis tasks (summary, tagging)?**
   - What we know: Simple API calls take 5-30s; agentic tasks with tool use can take 2-10 minutes
   - What's unclear: How complex will enrichment prompts be (depends on Phase 7 design)
   - Recommendation: Start with 10 minutes (600s); adjust based on actual task performance
   - Confidence: MEDIUM (based on general Claude Code usage, not this specific workflow)

3. **Should wrapper script commit outputs to git automatically?**
   - What we know: User wants auditability (mentioned in CONTEXT.md); git provides this
   - What's unclear: Whether auto-commit should happen in wrapper or separate n8n node
   - Recommendation: Defer to planning phase; likely better as separate n8n node for flexibility
   - Confidence: HIGH (architectural choice, not technical limitation)

4. **Can n8n SSH node handle large outputs (multi-MB JSON)?**
   - What we know: n8n nodes have memory limits; SSH stdout is captured in-memory
   - What's unclear: Exact size limits for n8n variables
   - Recommendation: Write outputs to files (already planned); n8n only needs success/failure signal
   - Confidence: MEDIUM (n8n handles KB easily, MB unknown, GB definitely problematic)

## Sources

### Primary (HIGH confidence)
- [Claude Code CLI Reference](https://code.claude.com/docs/en/cli-reference) - Official Anthropic docs
- [n8n SSH Node Documentation](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.ssh/) - Core node reference
- [n8n SSH Credentials](https://docs.n8n.io/integrations/builtin/credentials/ssh/) - Authentication setup
- [Docker Desktop Networking](https://docs.docker.com/desktop/features/networking/) - host.docker.internal usage

### Secondary (MEDIUM confidence)
- [Running Claude Code from Windows CLI](https://dstreefkerk.github.io/2026-01-running-claude-code-from-windows-cli/) - Practical programmatic usage patterns
- [Claude Code Hook Control Flow](https://stevekinney.com/courses/ai-development/claude-code-hook-control-flow) - Exit code behaviors
- [SSH to Docker Host from Container](https://medium.com/cloud-native-daily/ssh-to-docker-host-from-docker-container-e8ee0965802) - Container-to-host patterns
- [Enable SSH on Mac](https://osxdaily.com/2022/07/08/turn-on-ssh-mac/) - macOS Remote Login setup

### Secondary (MEDIUM confidence - Idempotency and error handling)
- [Idempotent Consumer Pattern](https://microservices.io/patterns/communication-style/idempotent-consumer.html) - Task processing patterns
- [Idempotency Implementation Guide](https://oneuptime.com/blog/post/2026-01-30-idempotency-implementation/view) - Modern 2026 patterns
- [Linux Timeout Command and Exit Codes](https://linuxvox.com/blog/the-linux-timeout-command-and-exit-codes/) - Exit code 124 for timeouts
- [SSH Exit Status Handling](https://www.unix.com/shell-programming-and-scripting/184657-how-test-ssh-exit-status-script.html) - Checking $? in scripts

### Secondary (MEDIUM confidence - File operations and scripting)
- [Atomic File Write Pattern](https://python-atomicwrites.readthedocs.io/) - Temp file + rename approach
- [Shell Wrapper Scripts](https://tldp.org/LDP/abs/html/wrapper.html) - Wrapper design patterns
- [Bash Argument Parsing](https://kodekloud.com/blog/bash-getopts/) - getopts best practices
- [Better Bash Scripts](https://medium.com/@rafal.kedziorski/tips-for-better-bash-scripts-36a9ce88dfa8) - Error handling, validation

### Tertiary (LOW confidence)
- Community forum posts (n8n, Docker) - Anecdotal experiences, not authoritative
- GitHub issues for Claude Code - Specific bugs, may not apply to current version

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Claude Code CLI and n8n SSH node are official, documented tools
- Architecture: MEDIUM - Patterns verified in docs, but specific wrapper implementation untested
- Pitfalls: MEDIUM - Based on general SSH/Docker/Claude Code knowledge, not this exact stack
- Exit codes: HIGH - Exit code 0/124/other is standard Unix convention
- Task file format: LOW - Frontmatter approach reasonable but untested for Claude Code system prompts

**Research date:** 2026-02-05
**Valid until:** ~30 days (2026-03-05) - Claude Code and n8n are stable, but CLI flags may change

**Critical unknowns for planning:**
- Exact timeout values depend on Phase 7 task complexity
- SSH key setup steps require user's macOS username/home directory
- Wrapper script flags depend on which Claude Code features are needed (tools, models, etc.)

**Next steps:**
- Planning phase should define wrapper script CLI interface
- Planning phase should specify task file schema (which fields are required)
- Task 1: Enable Remote Login and generate SSH keys
- Task 2: Create wrapper script skeleton with argument parsing
- Task 3: Create n8n workflow to test SSH execution
