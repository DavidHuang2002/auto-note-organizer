#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VAULT="${VAULT_PATH:-/Users/davidhuang/Library/Mobile Documents/iCloud~md~obsidian/Documents/auto-organize-vault}"

if [[ ! -d "$VAULT" ]]; then
  echo "Vault not found: $VAULT"
  echo "Set VAULT_PATH or create the iCloud vault directory."
  exit 1
fi

mkdir -p "$VAULT/state"

cp "$REPO_ROOT/vault/CLAUDE.md" "$VAULT/CLAUDE.md"
cp "$REPO_ROOT/vault/.organize-ignore" "$VAULT/.organize-ignore"

if [[ ! -f "$VAULT/state/organize-log.md" ]]; then
  cp "$REPO_ROOT/vault/state/organize-log.md" "$VAULT/state/organize-log.md"
fi

for dir in ideas questions plans learn journal writing people; do
  mkdir -p "$VAULT/$dir"
done

echo "Synced rules to $VAULT"
echo "  CLAUDE.md, .organize-ignore, taxonomy folders"
