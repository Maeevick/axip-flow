#!/usr/bin/env bash
# subagent-stop.sh
# SubagentStop hook — logs agent completion.
# Emits review cycle reminder when an implementing agent finishes.
# Observability + soft enforcement of the review step.

set -euo pipefail

INPUT=$(cat)
AGENT_NAME=$(echo "$INPUT" | jq -r '.agent_type // "unknown"')

echo ""
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│  AGENT STOP: $AGENT_NAME"
echo "│  Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "└─────────────────────────────────────────────────────────────┘"

# Remind orchestrator to launch reviewer for implementing agents.
# Reviewer agents contain "reviewer" in their name by convention.
if [[ "$AGENT_NAME" != *"reviewer"* ]] && [[ "$AGENT_NAME" != "unknown" ]]; then
  echo ""
  echo "  ⚑ Implementing agent finished."
  echo "  → Orchestrator: invoke the corresponding reviewer agent now."
  echo "  → Do not update BLUEPRINT TASKS to DONE before reviewer PASS."
fi

echo ""
