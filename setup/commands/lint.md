# Lint — Vault Health Check

Checks vault integrity and consistency. Run periodically (1x/week recommended).

> Vault location: `/Users/cpo/Documents/obsidian/claude` (default). Adjust if installed elsewhere.

## Checks

### 1. Orphan notes

Scan all notes in `/Users/cpo/Documents/obsidian/claude/wiki/` (global and all project subdirs). For each note, verify that at least one incoming or outgoing wiki link exists. List orphans.

### 2. Broken links

Scan all `[[wiki links]]` in the vault. Verify that each link points to an existing note. List broken links.

### 3. Global index up to date

Compare notes in `/Users/cpo/Documents/obsidian/claude/wiki/global/` with entries in `/Users/cpo/Documents/obsidian/claude/wiki/index.md`. List notes missing from the global index.

### 4. Project indexes up to date

For each `/Users/cpo/Documents/obsidian/claude/wiki/<project>/` directory:
- Verify `wiki/<project>/index.md` exists
- Compare notes in `wiki/<project>/` with entries in `wiki/<project>/index.md`
- List notes missing from the project index

### 5. Index sizes

- `/Users/cpo/Documents/obsidian/claude/wiki/index.md` > 200 lines → recommend splitting
- Any `wiki/<project>/index.md` > 200 lines → recommend splitting

### 6. Frontmatter consistency

Verify that each wiki note has valid frontmatter with required fields: date, tags, type, status.

## Report

Display:

```
## Lint complete

### Orphans: X
- list of notes without links

### Broken links: X
- [[Link]] in note.md → target note does not exist

### Global index: X missing notes
- list of notes absent from wiki/index.md

### Project indexes:
- <project>: X missing notes
  - list

### Index sizes: OK | WARNING (list oversized indexes)

### Invalid frontmatter: X
- list of notes with missing fields

### Recommended actions
- [ ] Add links to orphan notes
- [ ] Fix or remove broken links
- [ ] Add missing notes to indexes
```

### Write to log

Add an entry in `/Users/cpo/Documents/obsidian/claude/wiki/log.md`:

```
YYYY-MM-DD HH:MM — Lint: X orphans, X broken links, X missing from indexes
```

## Rules

- NEVER auto-correct — propose corrections, user validates
- NEVER modify raw/
- NEVER delete notes — propose archiving (status: archive)
