#!/usr/bin/env bash
# post-tool-failure.sh
# PostToolUseFailure hook — fires when a Write|Edit|MultiEdit tool fails.
# Forces agent to stop and surface the failure rather than continuing silently.

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // "unknown"')
ERROR=$(echo "$INPUT" | jq -r '.error // "no error details available"')

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  TOOL FAILURE — write did not complete                      ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  File  : $FILE_PATH"
echo "║  Error : $ERROR"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Stop. Do not continue. Report failure to Principal.        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

exit 2  # blocking error — forces Claude to stop and surface the failure
