#!/usr/bin/env bash
# instructions-loaded.sh
# InstructionsLoaded hook — traces which CLAUDE.md or rules file was loaded.
# Observability only: makes context loading visible in session logs.

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // empty')

echo ""
echo "=== INSTRUCTIONS LOADED ==="

if [[ -n "$FILE_PATH" ]]; then
  echo "File : $FILE_PATH"
  echo "Time : $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
else
  echo "File : (unknown)"
fi

echo "=== END ==="
echo ""
