#!/usr/bin/env bash
# subagent-start.sh
# SubagentStart hook — logs agent spawn for session observability.
# Makes agent invocation sequence visible and auditable.

set -euo pipefail

INPUT=$(cat)
AGENT_NAME=$(echo "$INPUT" | jq -r '.agent_type // "unknown"')

echo ""
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│  AGENT START: $AGENT_NAME"
echo "│  Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "└─────────────────────────────────────────────────────────────┘"
echo ""
