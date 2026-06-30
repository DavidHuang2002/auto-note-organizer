# Shared non-interactive Claude runner for vault scripts.
# Expects caller to define: log()

run_claude_headless() {
  local vault="$1"
  local timeout_secs="$2"
  local prompt="$3"
  local run_label="$4"

  local rules_file="$vault/CLAUDE.md"
  if [[ ! -f "$rules_file" ]]; then
    log "WARNING: $rules_file not found — run ./scripts/sync-vault-rules.sh"
  fi

  local -a claude_args=(
    --bare
    -p "$prompt"
    --permission-mode acceptEdits
    --allowedTools "Read,Edit,Write,Glob,Grep,Bash"
    --no-session-persistence
  )
  if [[ -f "$rules_file" ]]; then
    claude_args+=(--append-system-prompt-file "$rules_file")
  fi

  log "Starting Claude $run_label (bare mode, timeout: ${timeout_secs}s)..."
  log "Heartbeat every 15s while Claude runs (may take several minutes)"

  local claude_start
  claude_start=$(date +%s)

  (
    while true; do
      sleep 15
      log "Claude $run_label still running ($(( $(date +%s) - claude_start ))s elapsed)..."
    done
  ) &
  local heartbeat_pid=$!

  set +e
  perl -e 'alarm shift; exec @ARGV' "$timeout_secs" \
    claude "${claude_args[@]}" \
    < /dev/null
  local exit_code=$?
  set -e

  kill "$heartbeat_pid" 2>/dev/null || true
  wait "$heartbeat_pid" 2>/dev/null || true

  return "$exit_code"
}

claude_version_or_unknown() {
  if command -v perl &>/dev/null; then
    if CLAUDE_VERSION=$(perl -e 'alarm 5; exec @ARGV' claude --version 2>/dev/null); then
      log "Claude CLI: $CLAUDE_VERSION"
      return 0
    fi
  elif CLAUDE_VERSION=$(claude --version 2>/dev/null); then
    log "Claude CLI: $CLAUDE_VERSION"
    return 0
  fi
  log "Claude CLI: found (version unknown)"
}
