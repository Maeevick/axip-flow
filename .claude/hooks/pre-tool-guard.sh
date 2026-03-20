#!/usr/bin/env bash
# pre-tool-guard.sh
# PreToolUse hook — blocklist-based command guard for Bash tool.
# Default posture: ALLOW. Blocks known destructive or dangerous patterns.
#
# Designed for open source use: extend BLOCKED_PATTERNS for your context.
# Does not handle Windows paths or PowerShell — Linux/macOS only.
#
# Uses Claude Code permissionDecision API for clean integration.

set -euo pipefail

COMMAND=$(jq -r '.tool_input.command // empty')

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# ---------------------------------------------------------------------------
# BLOCKED PATTERNS — destructive, irreversible, or dangerous operations.
# Add patterns here. Each entry is a grep -E extended regex.
# ---------------------------------------------------------------------------

BLOCKED_PATTERNS=(
  # Filesystem destruction
  'rm\s+-[a-zA-Z]*r[a-zA-Z]*\s'   # rm -r, rm -rf, rm -fr and variants
  'rm\s+-[a-zA-Z]*f[a-zA-Z]*\s'   # rm -f and variants
  '\brmdir\b'                       # directory removal
  '\bshred\b'                       # secure file deletion
  '\btruncate\b'                    # file truncation

  # Disk and device operations
  '\bmkfs\b'                        # format filesystem
  '\bdd\s+.*of='                    # disk dump to device
  '>/dev/'                          # write to device directly
  'mv\s+.*\s+/dev/'                 # mv to /dev/ — permanent discard
  '\bfdisk\b'                       # partition table manipulation
  '\bparted\b'                      # partition manipulation

  # Process destruction
  '\bkillall\b'                     # kill processes by name
  '\bpkill\b'                       # kill processes by pattern
  '\bkill\s+-9\b'                   # force kill by PID

  # System operations
  '\bshutdown\b'                    # system shutdown
  '\breboot\b'                      # system reboot
  '\bhalt\b'                        # system halt
  '\bpoweroff\b'                    # system poweroff

  # Privilege escalation
  '\bsudo\b'                        # sudo — agents must not escalate
  '\bsu\s'                          # switch user
  '\bchmod\s+[0-9]*7[0-9]*7\b'     # world-writable permissions
  '\bchown\s+-R\b'                  # recursive ownership change

  # Remote execution (code injection surface)
  'curl\s+.*\|\s*(bash|sh)'        # curl | bash
  'wget\s+.*\|\s*(bash|sh)'        # wget | bash
  'curl\s+.*\|\s*python'           # curl | python
  '\beval\b'                        # eval — arbitrary code execution

  # Git destructive operations
  'git\s+push\s+.*--force'         # force push
  'git\s+push\s+.*-f\b'            # force push shorthand
  'git\s+reset\s+--hard'           # hard reset
  'git\s+clean\s+-[a-zA-Z]*f'      # force clean working tree
  'git\s+rebase\b'                  # rebase — rewrites commit history
  'git\s+commit\s+.*--amend\b'      # amend — silently replaces last commit

  # Database destructive operations (SQL keywords in shell context)
  '\bDROP\s+(TABLE|DATABASE|SCHEMA)\b'   # drop operations
  '\bTRUNCATE\s+TABLE\b'                 # truncate table
  '\bDELETE\s+FROM\b'                    # delete all rows
  '\bdestroy\b'                           # generic destroy (framework CLIs: terraform my friend :D)

  # Fork bomb pattern
  ':\(\)\{.*\|.*:\&\}'             # fork bomb

  # Python arbitrary execution (agents use Write tool, not python -c)
  'python[0-9.]?\s+-c\s'           # python -c "..."
  'python[0-9.]?\s+-m\s'           # python -m (module execution)
)

# ---------------------------------------------------------------------------
# CHECK COMMAND AGAINST BLOCKLIST
# ---------------------------------------------------------------------------

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$pattern"; then
    jq -n \
      --arg reason "Blocked by pre-tool-guard: matches destructive pattern '$pattern'. Execute manually if intentional." \
      '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason: $reason
        }
      }'
    exit 0  # JSON permissionDecision:deny is the block signal — exit 0 required for JSON to be processed
  fi
done

# Not blocked — allow
exit 0
