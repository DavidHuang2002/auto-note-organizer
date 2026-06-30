# Auto Note Organizer

Thin harness for loop-engineering an Obsidian vault. The brain lives in the vault's `CLAUDE.md`; this repo is just how you trigger it.

## Vault

```
~/Library/Mobile Documents/iCloud~md~obsidian/Documents/auto-organize-vault/
```

## Quick start

**Organize loose notes (Claude Code):**

```bash
./scripts/organize.sh
```

Or manually:

```bash
cd "/Users/davidhuang/Library/Mobile Documents/iCloud~md~obsidian/Documents/auto-organize-vault"
claude -p "Organize all loose root notes per CLAUDE.md. Stop when done."
```

**Ask about notes:**

```bash
cd "/Users/davidhuang/Library/Mobile Documents/iCloud~md~obsidian/Documents/auto-organize-vault"
claude -p "What have I been thinking about lately? Search my notes and cite sources."
```

## Schedule (Path A)

Runs when your Mac is on. Add to crontab (`crontab -e`):

```
0 */4 * * * /Users/davidhuang/Developer/personal/auto-note-organizer/scripts/organize.sh >> /tmp/ano-organize.log 2>&1
```

Or use Claude Code / Cursor automations on the same prompt.

## Where files live

| File | Location | Why |
|------|----------|-----|
| `CLAUDE.md` | **iCloud vault** | Claude Code reads rules from cwd |
| `.organize-ignore` | **iCloud vault** | Exclusion patterns |
| `state/organize-log.md` | **iCloud vault** | Loop memory |
| This repo | `~/Developer/personal/auto-note-organizer` | Trigger script + Cursor skill |

## Pin a note at root

Add to frontmatter:

```yaml
---
organize: false
---
```
