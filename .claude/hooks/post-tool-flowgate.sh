#!/usr/bin/env bash
# post-tool-flowgate.sh
# PostToolUse hook — runs quality gate after source file writes.
# Delegates entirely to `make ci-gate` — define it in your Makefile.
# On success: flow(ci-green) commit.
# On failure: flow(ci-red) commit + exit 1.
# No Makefile or no ci-gate target: flow(ci-unset) commit.
# Skips configuration, documentation, and data files.

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // "unknown"')

if [[ -z "$FILE_PATH" ]] || [[ "$FILE_PATH" == "unknown" ]]; then
  exit 0
fi

# ---------------------------------------------------------------------------
# TRIGGER EXTENSIONS — source code only
# ---------------------------------------------------------------------------

EXTENSION="${FILE_PATH##*.}"

case "$EXTENSION" in
  py|ts|js|mjs|cjs|svelte|rs|sql|sh)
    # proceed to quality gate
    ;;
  *)
    # skip: yml, yaml, toml, conf, txt, md, json, lock, env,
    #        nc, parquet, grib, grib2, csv, hdf5, h5, and everything else
    echo "  ⚙ Quality gate skipped: $FILE_PATH ($EXTENSION)"
    exit 0
    ;;
esac

# ---------------------------------------------------------------------------
# COMMIT HELPER
# ---------------------------------------------------------------------------

axip_commit() {
  local scope="$1"
  git add -A
  git commit --message="flow($scope): axip - work in progress" 2>&1
  echo "  ⟳ Committed: flow($scope): axip - work in progress"
}

# ---------------------------------------------------------------------------
# GUARD — no Makefile or no ci-gate target → ci-unset commit
# ---------------------------------------------------------------------------

if ! command -v make &>/dev/null || [[ ! -f "Makefile" ]]; then
  echo "  ⚠ No Makefile found — committing as ci-unset."
  echo "  Add a ci-gate target to your Makefile to enable ci-red/ci-green commits."
  axip_commit "ci-unset"
  exit 0
fi

if ! grep -q "^ci-gate" Makefile; then
  echo "  ⚠ No ci-gate target in Makefile — committing as ci-unset."
  echo "  Add a ci-gate target to your Makefile to enable ci-red/ci-green commits."
  axip_commit "ci-unset"
  exit 0
fi

# ---------------------------------------------------------------------------
# QUALITY GATE
# ---------------------------------------------------------------------------

echo ""
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│  Quality gate triggered by: $FILE_PATH"
echo "│  Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "└─────────────────────────────────────────────────────────────┘"
echo ""

if ! make ci-gate 2>&1; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  QUALITY GATE FAILED — make ci-gate                        ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  axip_commit "ci-red"
  exit 2
fi

echo ""
echo "  ✓ Quality gate passed."
echo ""

axip_commit "ci-green"
