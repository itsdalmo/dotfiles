---
name: notes
description: Manage durable notes in a zk notebook. Use when asked to search, create, connect, review, or answer from notes, including meeting notes. Use daily-notes for daily notes.
---

# Notes

Choose the workflow from the request:

- Search or answer from the notebook: **Search notes**.
- Preserve knowledge: **Create notes**.
- Record a meeting: **Create meeting notes**.
- Review the notebook: **Review notes**.

Requires `zk`, Git, `ZK_NOTEBOOK_DIR`, filesystem access to the configured notebook, and a POSIX-compatible shell.

## Prepare

1. Use `ZK_NOTEBOOK_DIR` as the root for filesystem and Git operations. Run `zk` directly so it uses the configured notebook. If access is restricted, request access only to that root.
2. Run `zk index`. For a write workflow, inspect Git status and identify every pre-existing change so it can be preserved.

Preparation is complete when the notebook is indexed and pre-existing changes are accounted for before any edit.

## Conventions

- Search before creating or substantially editing a note.
- Preserve the notebook author's concise voice. Write only supplied or verified facts, identify inference and uncertainty, and omit credentials, tokens, personal customer information, and unrelated conversation details.
- When the request does not assign a type, match each note to its primary purpose:
  - **Command:** How to perform an operation, including context and important caveats.
  - **Meeting:** What happened at a particular time, including discussion, decisions, and actions.
  - **Reference:** Facts, terminology, links, examples, or procedures to look up again.
  - **Permanent:** One reusable idea in the author's own words that stands outside its original context.
- Link notes as `[Title](<note-id>)` and explain the relationship in the surrounding sentence. Update an `index` note only when it materially improves navigation.
- Treat `inbox` as "needs processing." Remove it only after deliberate processing; keep it on raw or unresolved captures.
- Preserve daily and meeting notes as historical records. Age alone does not make a note stale.
- Never delete a note without explicit user approval. Present its exact path and the reason for deletion.

## Search notes

Keep this workflow read-only; `zk index` may refresh index metadata.

1. Start with a bounded full-text search across the notebook:
   - `zk list --match "<query>" --format oneline --limit 20`
2. If results are weak, search separately with plausible narrower phrases, broader terms, synonyms, acronyms, or related concepts. Use `--match-strategy exact` only when literal matching matters.
3. Narrow an over-broad result set when useful:
   - `zk list --tag <tag> --match "<query>" --format oneline`
   - `zk list --created-after "<date>" --match "<query>" --sort created- --format oneline`
4. Explore connections from a promising note when useful:
   - `zk list --related <note-path>` for potentially related notes
   - `zk list --link-to <note-path>` for backlinks
   - `zk list --linked-by <note-path>` for outgoing links
5. Read every note needed to support the answer. Follow links while they materially improve it.
6. Read linked GitHub issues or pull requests with the github-work **Fetch** workflow only when the user asks for current or verified GitHub context, or required context is absent from the notebook. Fetch only the exact links needed. Distinguish live GitHub evidence from notebook content.
7. Answer directly and cite the most relevant note paths. Distinguish direct statements, live GitHub evidence, and inference; mention conflicts or dated information, and report the attempted query variants when nothing useful is found.

The search is complete when the answer is supported by the cited notes, or plausible query variants are exhausted and reported.

## Create notes

1. Identify only the knowledge the user wants preserved, then follow steps 1-5 of **Search notes** to find existing and related notes.
2. Update an existing note when it already owns the subject. Otherwise create one with `zk new --title "<title>" --print-path`, then edit the generated file. Let the configured template supply its path, timestamp, and frontmatter.
3. Keep command and reference notes easy to scan. Give permanent notes a title that states their idea. For meeting notes, follow **Create meeting notes**. Retain provenance when extracting an idea from a meeting, daily note, or supplied source.
4. Remove `inbox` when the resulting note is complete; retain it when the note still needs processing.
5. Run `zk index` again. Inspect every changed note and report each created or updated path.

Creation is complete when every requested piece of knowledge is preserved once, every changed note has been inspected, and all changed paths are reported.

## Create meeting notes

1. Identify the meeting title and any supplied content, then follow steps 1-5 of **Search notes** to find related notes and determine whether the meeting note already exists.
2. Create a distinct note with `zk new --title "<title>" --template meeting.md --print-path`, then edit the generated file. Keep the template's lightweight `Discussion`, `Decisions`, and `Actions` structure; do not add attendee, purpose, agenda, or other metadata unless the user requests it.
3. When creating the meeting note from an existing note, leave the source content intact. Copy the relevant content into the meeting note under the appropriate headings, add a contextual link from the meeting note to the source, and add a contextual link from the source to the meeting note. Do not replace source content with a link.
4. Use `[Title](<note-id>)` for both links and describe the relationship in the surrounding sentence. Avoid adding a duplicate link when either relationship is already recorded.
5. Remove `inbox` only when the resulting meeting note is complete; retain it when the note still needs processing.
6. Run `zk index` again. Inspect the complete meeting note and every linked source note changed by the workflow, then report each path.

Meeting creation is complete when the meeting uses `meeting.md`, all supplied content is represented, every source remains intact, and each source-meeting relationship is linked in both directions exactly once.

## Review notes

Use a weekly review unless the user explicitly requests a monthly review. Respect any supplied scope or batch size.

### Weekly

1. Review recent captures:
   - `zk list daily --created-after "last week" --sort created-`
   - `zk list notes --tag inbox --sort modified- --limit 10`
2. Search for existing and related notes before editing each item.
3. Give each item one outcome: preserve it as history; improve or connect it; extract a permanent note while retaining the source; merge useful content and propose deletion of the redundant original; or leave it in `inbox` when unresolved.
4. End the review when every item in the selected batch has one recorded outcome; leave the remaining backlog for a later review.

### Monthly

Run only the monthly review unless the user requests both review types.

1. Inspect small maintenance samples:
   - `zk list notes --orphan --sort modified- --limit 10`
   - `zk list notes --missing-backlink --limit 10`
2. Add a link only when its surrounding sentence can state a meaningful relationship.
3. Review one relevant `index` note and reorganize it only when its linked cluster has changed.
4. Correct or remove obsolete content from maintained command and reference notes, such as superseded commands, incorrect claims, valueless dead links, or duplication.

After either review, run `zk index` and inspect every changed note. The review is complete when every selected item has one outcome and the report accounts for every processed, created, updated, unresolved, or deletion-proposed note.
