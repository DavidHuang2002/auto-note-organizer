---
name: organize-vault
description: Organize and query the Obsidian auto-organize vault. Use when processing loose root notes, running the organize loop, or answering questions about vault notes.
---

# Organize Vault

## Vault path

`/Users/davidhuang/Library/Mobile Documents/iCloud~md~obsidian/Documents/auto-organize-vault`

## Rules

Read `CLAUDE.md` in the vault before organizing or answering questions. That file is the source of truth.

## Organize

```bash
cd "/Users/davidhuang/Library/Mobile Documents/iCloud~md~obsidian/Documents/auto-organize-vault"
# Process loose root *.md → ideas/ | projects/ | notes/
```

Or run: `/Users/davidhuang/Developer/personal/auto-note-organizer/scripts/organize.sh`

## Loose notes

Root-level `.md` files only. Skip `.organize-ignore` patterns and `organize: false` frontmatter.

## Taxonomy

`ideas/` · `projects/` · `notes/`

## Titles

`Untitled*` or no heading → generate. Rough title → refine and replace. Sync filename to `YYYY-MM-DD-slug.md`.

## Query

Search `ideas/`, `projects/`, `notes/` by meaning. Cite note paths. Do not invent.
