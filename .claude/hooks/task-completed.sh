#!/usr/bin/env bash
# task-completed.sh
# TaskCompleted hook — fires when a task is marked complete.
# Warns if BLUEPRINT.md has not been updated recently (no IN PROGRESS → DONE transition visible).

set -euo pipefail

INPUT=$(cat)
TASK_ID=$(echo "$INPUT" | jq -r '.task_id // "unknown"')

echo ""
echo "=== TASK COMPLETED ==="
echo "Task : $TASK_ID"
echo "Time : $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Check for any remaining IN PROGRESS tasks — signals incomplete BLUEPRINT update.
if [[ -f "BLUEPRINT.md" ]]; then
  IN_PROGRESS=$(grep -c '^\- \[ \] IN PROGRESS' BLUEPRINT.md 2>/dev/null || echo 0)
  if [[ "$IN_PROGRESS" -gt 0 ]]; then
    echo ""
    echo "⚠ BLUEPRINT still has IN PROGRESS tasks."
    echo "  Update TASKS status in BLUEPRINT.md before proceeding."
  else
    echo "  ✓ BLUEPRINT task status appears current."
  fi
fi

echo "=== END ==="
echo ""
