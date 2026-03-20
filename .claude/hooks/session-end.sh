#!/usr/bin/env bash
# session-end.sh
# SessionEnd hook — emits BLUEPRINT task state summary on session termination.
# Provides clean session boundary signal for next session resume.

set -euo pipefail

echo ""
echo "=== SESSION END ==="
echo "Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo ""

if [[ ! -f "BLUEPRINT.md" ]]; then
  echo "⚠ No BLUEPRINT.md found — no task summary available."
  echo "=== END ==="
  exit 0
fi

DONE=$(grep -c '^\- \[x\] DONE' BLUEPRINT.md 2>/dev/null || echo 0)
TODO=$(grep -c '^\- \[ \] TODO' BLUEPRINT.md 2>/dev/null || echo 0)
IN_PROGRESS=$(grep -c '^\- \[ \] IN PROGRESS' BLUEPRINT.md 2>/dev/null || echo 0)
FAIL=$(grep -c '^\- \[ \] FAIL' BLUEPRINT.md 2>/dev/null || echo 0)
SKIP=$(grep -c '^\- \[ \] SKIP' BLUEPRINT.md 2>/dev/null || echo 0)
BREAKS=$(grep -c '^\- \[ \] PRINCIPAL_BREAK' BLUEPRINT.md 2>/dev/null || echo 0)

echo "Task summary:"
echo "  ✓ Done        : $DONE"
echo "  ○ Todo        : $TODO"
echo "  ⟳ In progress : $IN_PROGRESS"
echo "  ✗ Failed      : $FAIL"
echo "  ⊘ Skipped     : $SKIP"
echo "  ⏸ Breaks ahead: $BREAKS"

if [[ "$IN_PROGRESS" -gt 0 ]]; then
  echo ""
  echo "⚠ Tasks left IN PROGRESS — resume with /read-tasks next session."
fi

if [[ "$FAIL" -gt 0 ]]; then
  echo ""
  echo "⚠ Failed tasks require Principal decision before next run."
fi

echo ""
echo "=== SESSION END COMPLETE ==="
