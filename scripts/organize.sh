#!/usr/bin/env bash
set -euo pipefail

VAULT="${VAULT_PATH:-/Users/davidhuang/Library/Mobile Documents/iCloud~md~obsidian/Documents/auto-organize-vault}"
TIMEOUT_SECS="${ORGANIZE_TIMEOUT_SECS:-600}"
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
      if [[ "$count" -gt 0 ]]; then
        log "  $dir/ (retired): $count"
      fi
    fi
  done
}

log "=== organize.sh starting ==="
log "Vault: $VAULT"
log "Timeout: ${TIMEOUT_SECS}s"

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

LOOSE_BEFORE=$(count_root_loose_md)
print_inventory "Pre-organize inventory:"

if [[ "$LOOSE_BEFORE" -eq 0 ]]; then
  log "No loose root notes to organize"
fi

cd "$VAULT"
log "Working directory: $(pwd)"

if ! command -v claude &>/dev/null; then
  log "ERROR: claude CLI not found. Install Claude Code or run from Cursor with the organize-vault skill."
  exit 1
fi

if ! command -v perl &>/dev/null; then
  log "ERROR: perl not found (needed for timeout). Organize manually in Cursor or install perl."
  exit 1
fi

if CLAUDE_VERSION=$(claude --version 2>/dev/null); then
  log "Claude CLI: $CLAUDE_VERSION"
else
  log "Claude CLI: found (version unknown)"
fi

PROMPT="Organize all loose root notes per CLAUDE.md into ideas/, questions/, plans/, learn/, journal/, writing/, or people/. Respect .organize-ignore and organize: false. Refile any notes still in retired projects/ or notes/ if encountered. Log to state/organize-log.md. Stop when done."

log "Starting Claude organize (timeout: ${TIMEOUT_SECS}s)..."
CLAUDE_START=$(date +%s)

# Redirect stdin so claude -p does not wait indefinitely in non-interactive runs.
# acceptEdits avoids permission prompts that block cron/background use.
# ORGANIZE_TIMEOUT_SECS (default 600) kills a stuck run.
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
  log "Claude organize finished successfully (${CLAUDE_ELAPSED}s)"
else
  log "Claude organize exited with code $EXIT_CODE (${CLAUDE_ELAPSED}s)"
  if [[ $EXIT_CODE -eq 142 ]]; then
    log "Likely timeout: alarm fired at ${TIMEOUT_SECS}s (SIGALRM)"
  fi
fi

LOOSE_AFTER=$(count_root_loose_md)
print_inventory "Post-organize inventory:"

MOVED=$((LOOSE_BEFORE - LOOSE_AFTER))
if [[ $MOVED -gt 0 ]]; then
  log "Organized $MOVED loose note(s)"
elif [[ "$LOOSE_BEFORE" -gt 0 && "$LOOSE_AFTER" -eq "$LOOSE_BEFORE" ]]; then
  log "Loose note count unchanged — check organize: false or .organize-ignore"
fi

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
  log "=== organize.sh complete (${TOTAL_ELAPSED}s) ==="
else
  log "=== organize.sh finished with errors (${TOTAL_ELAPSED}s) ==="
  exit "$EXIT_CODE"
fi
