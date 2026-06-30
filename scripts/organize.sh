#!/usr/bin/env bash
set -euo pipefail

VAULT="${VAULT_PATH:-/Users/davidhuang/Library/Mobile Documents/iCloud~md~obsidian/Documents/auto-organize-vault}"
TIMEOUT_SECS="${ORGANIZE_TIMEOUT_SECS:-600}"

cd "$VAULT"

if ! command -v claude &>/dev/null; then
  echo "claude CLI not found. Install Claude Code or run from Cursor with the organize-vault skill."
  exit 1
fi

if ! command -v perl &>/dev/null; then
  echo "perl not found (needed for timeout). Organize manually in Cursor or install perl."
  exit 1
fi

PROMPT="Organize all loose root notes per CLAUDE.md into ideas/, questions/, plans/, learn/, journal/, writing/, or people/. Respect .organize-ignore and organize: false. Refile any notes still in retired projects/ or notes/ if encountered. Log to state/organize-log.md. Stop when done."

# Redirect stdin so claude -p does not wait indefinitely in non-interactive runs.
# acceptEdits avoids permission prompts that block cron/background use.
# ORGANIZE_TIMEOUT_SECS (default 600) kills a stuck run.
perl -e 'alarm shift; exec @ARGV' "$TIMEOUT_SECS" \
  claude -p \
    --permission-mode acceptEdits \
    --no-session-persistence \
    "$PROMPT" \
  < /dev/null
