---
name: organize-vault
description: Organize and query the Obsidian auto-organize vault. Use when processing loose root notes, running the organize loop, reorging legacy notes, or answering questions about vault notes.
---

# Organize Vault

## Vault path

`/Users/davidhuang/Library/Mobile Documents/iCloud~md~obsidian/Documents/auto-organize-vault`

## Rules

Read `CLAUDE.md` in the vault before organizing or answering questions. Canonical copy lives in this repo at `vault/CLAUDE.md` — sync with `./scripts/sync-vault-rules.sh`.

## Taxonomy

`ideas/` · `questions/` · `plans/` · `learn/` · `journal/` · `writing/` · `people/`

| Folder | Use for |
|--------|---------|
| `ideas/` | Concepts, proposals, hypotheticals |
| `questions/` | Open questions, wonderings |
| `plans/` | Goals, intentions, future direction |
| `learn/` | Topics, skills, books (not people) |
| `journal/` | Daily life, reflection |
| `writing/` | Drafts for an audience |
| `people/` | Person-centric notes (CRM-lite) |

Retired: `projects/`, `notes/` — refile on sight.

## Organize loose notes

```bash
cd "/Users/davidhuang/Library/Mobile Documents/iCloud~md~obsidian/Documents/auto-organize-vault"
# Process loose root *.md → taxonomy folders per CLAUDE.md
```

Or run: `./scripts/organize.sh`

## Full reorg (legacy folders + misfiled notes)

```bash
./scripts/reorg-vault.sh
```

## Sync rules to iCloud vault

```bash
./scripts/sync-vault-rules.sh
```

## Loose notes

Root-level `*.md` only. Skip `.organize-ignore` patterns and `organize: false` frontmatter.

## Titles

`Untitled*` or no heading → generate. Rough title → refine and replace. Sync filename to `YYYY-MM-DD-slug.md`. People: `people/first-last.md`.

## Query

Search all taxonomy folders by meaning. Cite note paths. Do not invent.
