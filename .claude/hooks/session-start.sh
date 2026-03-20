#!/usr/bin/env bash
# session-start.sh
# SessionStart hook — injects BLUEPRINT.md into context at session start.
# Structural enforcement: BLUEPRINT is always loaded before any agent action.

set -euo pipefail

echo "=== SESSION START ==="
echo "Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo ""

if [[ -f "BLUEPRINT.md" ]]; then
  echo "=== BLUEPRINT LOADED ==="
  cat BLUEPRINT.md
  echo "=== END BLUEPRINT ==="
else
  echo "⚠ No BLUEPRINT.md found in project root."
  echo "  Create one before invoking any agent."
fi

echo ""
echo "=== SESSION START COMPLETE ==="
