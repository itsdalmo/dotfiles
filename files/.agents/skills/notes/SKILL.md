---
name: notes
description: Search, create, and review notes in the configured zk Zettelkasten, including reconciling supplied or verified work into daily logs. Use for notebook work and daily-log updates. This skill owns note-file changes.
---

# Notes

Choose the workflow requested by the user. This skill owns all notebook reads and note-file changes, including changes requested by another skill. Do not modify note files during a search-only task; `zk index` may refresh index metadata.

Requires `zk`, Git, `ZK_NOTEBOOK_DIR`, filesystem access to the configured notebook, and a POSIX-compatible shell.

## Prepare

1. Run `zk` directly; it uses the configured notebook. When reading files or running Git, use `ZK_NOTEBOOK_DIR` as the notebook root.
2. Read the notebook's `AGENTS.md` when it exists.
3. Run `zk index`. Before modifying notes, inspect the notebook's Git status and preserve unrelated changes.
4. If the notebook is outside the session's permitted area, request narrowly scoped access instead of working elsewhere.

## Conventions

- Search before creating or substantially editing a note.
- Preserve the notebook author's concise voice. Never invent facts, sources, decisions, or certainty, and omit credentials, tokens, personal customer information, and unrelated conversation details.
- Match each note to its primary purpose:
  - **Command:** How to perform an operation, including context and important caveats.
  - **Meeting:** What happened at a particular time, including discussion, decisions, and actions.
  - **Reference:** Facts, terminology, links, examples, or procedures to look up again.
  - **Permanent:** One reusable idea in the author's own words that stands outside its original context.
- Link notes as `[Title](<note-id>)` and explain the relationship in the surrounding sentence. Update an `index` note only when it materially improves navigation.
- Treat `inbox` as "needs processing." Remove it only after deliberate processing; keep it on raw or unresolved captures.
- Preserve daily and meeting notes as historical records. Age alone does not make a note stale.
- Never delete a note without explicit user approval. Present its exact path and the reason for deletion.

## Search notes

1. Start with a bounded full-text search across the notebook:
   - `zk list --match "<query>" --format oneline --limit 20`
2. If results are weak, search separately with a narrower phrase, broader term, synonym, acronym, or related concept. Use `--match-strategy exact` only when literal matching matters.
3. Apply filters when useful:
   - `zk list --tag <tag> --match "<query>" --format oneline`
   - `zk list --created-after "<date>" --match "<query>" --sort created- --format oneline`
4. Explore connections from a promising note when useful:
   - `zk list --related <note-path>` for potentially related notes
   - `zk list --link-to <note-path>` for backlinks
   - `zk list --linked-by <note-path>` for outgoing links
5. Read the relevant files before answering. Follow links only while they materially improve the answer.
6. Answer directly and cite the most relevant note paths. Distinguish direct statements from inference, mention conflicts or dated information, and report unsuccessful query variants when nothing useful is found.

## Create notes

1. Identify only the knowledge the user wants preserved, then use the search workflow to find existing and related notes.
2. Update an existing note when it already owns the subject. Otherwise create one with `zk new --title "<title>" --print-path`, then edit the generated file. Let the configured template supply its path, timestamp, and frontmatter.
3. Keep command and reference notes easy to scan. Give permanent notes a title that states their idea. Retain provenance when extracting an idea from a meeting, daily note, or supplied source.
4. Remove `inbox` when the resulting note is complete; retain it when the note still needs processing.
5. Run `zk index` again, inspect the changed notes, and report what was created or updated.

## Review notes

Use a weekly review unless the user explicitly requests a monthly review. Respect any supplied scope or batch size.

### Weekly

1. Review recent captures:
   - `zk list daily --created-after "last week" --sort created-`
   - `zk list notes --tag inbox --sort modified- --limit 10`
2. Search for existing and related notes before editing each item.
3. Give each item one outcome: preserve it as history; improve or connect it; extract a permanent note while retaining the source; merge useful content and propose deletion of the redundant original; or leave it in `inbox` when unresolved.
4. Stop after the selected batch. Do not attempt to clear the backlog.

### Monthly

Do not perform the weekly review first unless the user requests both.

1. Inspect small maintenance samples:
   - `zk list notes --orphan --sort modified- --limit 10`
   - `zk list notes --missing-backlink --limit 10`
2. Add links only for meaningful relationships, not merely to eliminate graph warnings.
3. Review one relevant `index` note and reorganize it only when its linked cluster has changed.
4. Correct or remove obsolete content from maintained command and reference notes, such as superseded commands, incorrect claims, valueless dead links, or duplication.

After either review, run `zk index`, inspect every changed note, and report what was processed, created, updated, left in `inbox`, or proposed for deletion.
