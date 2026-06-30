# Auto Note Organizer

Thin harness for loop-engineering an Obsidian vault. The brain lives in the vault's `CLAUDE.md`; this repo holds the canonical rules plus trigger scripts.

## Vault

```
~/Library/Mobile Documents/iCloud~md~obsidian/Documents/auto-organize-vault/
```

## Taxonomy

| Folder | Use for |
|--------|---------|
| `ideas/` | Concepts, proposals, hypotheticals |
| `questions/` | Open questions, wonderings |
| `plans/` | Goals, intentions, future direction |
| `learn/` | Topics, skills, books (not people) |
| `journal/` | Daily life, reflection |
| `writing/` | Drafts for an audience |
| `people/` | Person-centric notes (CRM-lite) |

Retired: `projects/`, `notes/`

## Quick start

**Sync rules to iCloud vault (run after pulling this repo):**

```bash
./scripts/sync-vault-rules.sh
```

**Organize loose root notes (Claude Code):**

```bash
./scripts/organize.sh
```

**Reorganize all existing notes (legacy `projects/` / `notes/` + misfiled):**

```bash
./scripts/reorg-vault.sh
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
| `vault/CLAUDE.md` | **This repo** (canonical) | Version-controlled taxonomy & rules |
| `CLAUDE.md` | **iCloud vault** | Claude Code reads rules from cwd — sync via script |
| `.organize-ignore` | **iCloud vault** | Exclusion patterns |
| `state/organize-log.md` | **iCloud vault** | Loop memory |
| This repo | `~/Developer/personal/auto-note-organizer` | Trigger scripts + Cursor skill |

## Pin a note at root

Add to frontmatter:

```yaml
---
organize: false
---
```
