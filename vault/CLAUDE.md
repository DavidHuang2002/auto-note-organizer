# Auto-organize vault

You organize and query notes in this Obsidian vault. Follow these rules exactly.

## Taxonomy

Top-level folders (intent + one entity bucket):

| Folder | Put here when… | Examples |
|--------|----------------|----------|
| `ideas/` | Proposing or imagining something; speculative, low commitment | App concepts, "what if" thoughts, hypotheticals |
| `questions/` | Primarily asking something you don't know yet | "Why does X?", open wonderings, snippets ending in `?` |
| `plans/` | Stating goals, intentions, future direction | "Learn Rust by Q2 2027", career goals, follow-ups you intend to do |
| `learn/` | Capturing knowledge from outside (topics, skills, books) | Course notes, how-things-work, book highlights — **not people** |
| `journal/` | Recording your life: what happened, reflection on past/present | Daily logs, "today I…", personal narrative |
| `writing/` | Drafts meant for an external audience | Blog posts, essays, newsletter drafts, publishable threads |
| `people/` | Facts and context about a person (CRM-lite) | One note per person: role, how you met, interests, contact log |

**Retired folders (do not use):** `projects/`, `notes/`. If you see notes there, refile per this taxonomy.

### Classification rules

Apply in order:

1. **Mostly about one person** → `people/` (create or append `people/first-last.md`)
2. **Title or opening line is a question** (ends with `?`, or clearly seeking an answer) → `questions/`
3. **Goal / intention / "I want to" / dated target** → `plans/`
4. **Draft for others to read** → `writing/`
5. **Personal narrative about your day or life** → `journal/`
6. **Studying a topic, skill, or source material** → `learn/`
7. **Proposal or hypothetical (not primarily a question)** → `ideas/`

**Gray areas:**

- Seeking an answer → `questions/`; proposing a thing → `ideas/`
- Vague "someday maybe" → `ideas/`; committed direction → `plans/`
- "Met Alex today…" → `journal/` and link `[[people/alex-chen]]`; durable facts about Alex → `people/alex-chen.md`
- Company/industry facts (not person-centric) → `learn/`

### People notes (CRM-lite)

- One note per person: `people/first-last.md` (lowercase slug)
- Optional sections: role/org, how met, interests, last contact, `## Notes`, `## Log` (dated bullets)
- Use tags in frontmatter if helpful (`#friend`, `#work`) — never required at capture time
- Do **not** create `companies/`, `meetings/`, or `contacts/` folders

## Loose notes

- **Loose** = root-level `*.md` only (not inside a taxonomy folder)
- Respect `.organize-ignore` glob patterns
- Skip notes with `organize: false` in frontmatter (leave at root)
- **Never delete** notes — only move, rename, merge content, or update titles

## Titles and filenames

- Filename format: `YYYY-MM-DD-slug.md` (use note date or today if unknown)
- `Untitled*` or no H1 → generate a concise title from content
- Rough title → refine to match content; sync filename to title slug
- Journal dailies may use `YYYY-MM-DD.md` when one note = one day
- People notes: `people/first-last.md` (date prefix optional once stable)

## Organize loop (loose root notes)

1. List root `*.md` excluding ignored / `organize: false`
2. For each note: classify, refine title, rename, move to taxonomy folder
3. Append a line to `state/organize-log.md`:
   `- YYYY-MM-DD HH:MM | moved | old/path → new/path | brief reason`
4. Stop when no loose root notes remain

## Full reorg (legacy + misplaced notes)

When asked to reorganize the whole vault:

1. Read every note in retired folders: `projects/`, `notes/`
2. Scan other taxonomy folders for misfiled notes
3. Refile each note per classification rules above
4. Remove empty `projects/` and `notes/` directories after moving (only if empty)
5. Log every move to `state/organize-log.md` with tag `reorg`
6. Do not delete note content

## Query

Search across `ideas/`, `questions/`, `plans/`, `learn/`, `journal/`, `writing/`, `people/` by meaning. Cite exact note paths. Do not invent notes or content.
