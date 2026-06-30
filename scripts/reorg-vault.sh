#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VAULT="${VAULT_PATH:-/Users/davidhuang/Library/Mobile Documents/iCloud~md~obsidian/Documents/auto-organize-vault}"
TIMEOUT_SECS="${REORG_TIMEOUT_SECS:-1800}"
RUN_START=$(date +%s)

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

count_md_in() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    echo 0
    return
  fi
  find "$dir" -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' '
}

count_root_loose_md() {
  find "$VAULT" -maxdepth 1 -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' '
}

print_inventory() {
  local label="$1"
  log "$label"
  log "  root loose *.md: $(count_root_loose_md)"
  for dir in ideas questions plans learn journal writing people projects notes; do
    local count
    count=$(count_md_in "$VAULT/$dir")
    if [[ "$dir" == "projects" || "$dir" == "notes" ]]; then
      log "  $dir/ (retired): $count"
    else
      log "  $dir/: $count"
    fi
  done
}

log "=== reorg-vault.sh starting ==="
log "Vault: $VAULT"
log "Timeout: ${TIMEOUT_SECS}s"
log "Repo: $REPO_ROOT"

if [[ ! -d "$VAULT" ]]; then
  log "ERROR: Vault not found: $VAULT"
  log "Set VAULT_PATH or create the iCloud vault directory."
  exit 1
fi

ORG_LOG="$VAULT/state/organize-log.md"
LOG_LINES_BEFORE=0
if [[ -f "$ORG_LOG" ]]; then
  LOG_LINES_BEFORE=$(wc -l < "$ORG_LOG" | tr -d ' ')
fi

print_inventory "Pre-reorg inventory:"

log "Syncing vault rules..."
if SYNC_OUT=$("$REPO_ROOT/scripts/sync-vault-rules.sh" 2>&1); then
  while IFS= read -r line; do
    [[ -n "$line" ]] && log "  $line"
  done <<< "$SYNC_OUT"
else
  log "ERROR: sync-vault-rules.sh failed"
  exit 1
fi

cd "$VAULT"
log "Working directory: $(pwd)"

if ! command -v claude &>/dev/null; then
  log "ERROR: claude CLI not found. Reorg manually in Cursor with the organize-vault skill."
  exit 1
fi

if ! command -v perl &>/dev/null; then
  log "ERROR: perl not found (needed for timeout). Reorg manually in Cursor or install perl."
  exit 1
fi

if CLAUDE_VERSION=$(claude --version 2>/dev/null); then
  log "Claude CLI: $CLAUDE_VERSION"
else
  log "Claude CLI: found (version unknown)"
fi

PROMPT="Full vault reorg per CLAUDE.md.

1. Move every note from retired folders projects/ and notes/ into the correct taxonomy folder.
2. Scan ideas/, questions/, plans/, learn/, journal/, writing/, people/ for misfiled notes and correct them.
3. Process any loose root *.md notes.
4. Refine titles and filenames per CLAUDE.md.
5. Remove empty projects/ and notes/ directories only after all notes are moved.
6. Never delete note content. Log every move to state/organize-log.md with tag reorg.
7. Stop when done."

log "Starting Claude reorg (timeout: ${TIMEOUT_SECS}s)..."
CLAUDE_START=$(date +%s)

set +e
perl -e 'alarm shift; exec @ARGV' "$TIMEOUT_SECS" \
  claude -p \
    --permission-mode acceptEdits \
    --no-session-persistence \
    "$PROMPT" \
  < /dev/null
EXIT_CODE=$?
set -e

CLAUDE_ELAPSED=$(( $(date +%s) - CLAUDE_START ))
TOTAL_ELAPSED=$(( $(date +%s) - RUN_START ))

if [[ $EXIT_CODE -eq 0 ]]; then
  log "Claude reorg finished successfully (${CLAUDE_ELAPSED}s)"
else
  log "Claude reorg exited with code $EXIT_CODE (${CLAUDE_ELAPSED}s)"
  if [[ $EXIT_CODE -eq 142 ]]; then
    log "Likely timeout: alarm fired at ${TIMEOUT_SECS}s (SIGALRM)"
  fi
fi

print_inventory "Post-reorg inventory:"

if [[ -f "$ORG_LOG" ]]; then
  LOG_LINES_AFTER=$(wc -l < "$ORG_LOG" | tr -d ' ')
  NEW_LINES=$((LOG_LINES_AFTER - LOG_LINES_BEFORE))
  if [[ $NEW_LINES -gt 0 ]]; then
    log "New organize-log entries ($NEW_LINES):"
    tail -n "$NEW_LINES" "$ORG_LOG" | while IFS= read -r line; do
      log "  $line"
    done
  else
    log "No new entries in state/organize-log.md"
  fi
else
  log "organize-log not found at $ORG_LOG"
fi

if [[ $EXIT_CODE -eq 0 ]]; then
  log "=== reorg-vault.sh complete (${TOTAL_ELAPSED}s) ==="
else
  log "=== reorg-vault.sh finished with errors (${TOTAL_ELAPSED}s) ==="
  exit "$EXIT_CODE"
fi
