#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VAULT="${VAULT_PATH:-/Users/davidhuang/Library/Mobile Documents/iCloud~md~obsidian/Documents/auto-organize-vault}"
TIMEOUT_SECS="${REORG_TIMEOUT_SECS:-1800}"

if [[ ! -d "$VAULT" ]]; then
  echo "Vault not found: $VAULT"
  echo "Set VAULT_PATH or create the iCloud vault directory."
  exit 1
fi

# Ensure latest rules and folders exist before reorg
"$REPO_ROOT/scripts/sync-vault-rules.sh"

cd "$VAULT"

if ! command -v claude &>/dev/null; then
  echo "claude CLI not found. Reorg manually in Cursor with the organize-vault skill."
  exit 1
fi

if ! command -v perl &>/dev/null; then
  echo "perl not found (needed for timeout). Reorg manually in Cursor or install perl."
  exit 1
fi

PROMPT="Full vault reorg per CLAUDE.md.

1. Move every note from retired folders projects/ and notes/ into the correct taxonomy folder.
2. Scan ideas/, questions/, plans/, learn/, journal/, writing/, people/ for misfiled notes and correct them.
3. Process any loose root *.md notes.
4. Refine titles and filenames per CLAUDE.md.
5. Remove empty projects/ and notes/ directories only after all notes are moved.
6. Never delete note content. Log every move to state/organize-log.md with tag reorg.
7. Stop when done."

perl -e 'alarm shift; exec @ARGV' "$TIMEOUT_SECS" \
  claude -p \
    --permission-mode acceptEdits \
    --no-session-persistence \
    "$PROMPT" \
  < /dev/null
