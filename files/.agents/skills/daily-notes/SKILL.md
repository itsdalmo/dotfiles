---
name: daily-notes
description: Read daily notes or update their Log from GitHub. Use for "update my daily", "update yesterday's daily", or questions about a daily note.
---

# Daily Notes

Daily files are `$ZK_NOTEBOOK_DIR/daily/YYYY-MM-DD.md`. Use `Europe/Oslo` to
resolve relative dates unless the user supplies another timezone.

## Read

Read the requested file, using today when no date is given. Answer only from the
note. Do not create or update a note for a read-only request.

## Update

1. Resolve the date: today for "update my daily" and the previous calendar day
   for "update yesterday's daily".
2. If the daily is missing, create it with:

   ```bash
   zk daily --date=<YYYY-MM-DD> --print-path --no-input
   ```

   Only for a newly created daily, run `github-work todo` and populate its empty
   `## TODO` with the complete result. Use `- [ ] ` for items and `  - [ ] ` for
   group children. After this initial population, `## TODO` is user-managed.
3. Read the entire daily, then run:

   ```bash
   github-work log --from <YYYY-MM-DD> --to <YYYY-MM-DD> --timezone <IANA-zone>
   ```

4. Update only `## Log`. Merge the command output with existing entries without
   duplicating GitHub URLs or removing manual entries. Preserve the CLI's groups,
   children, titles, and links.
5. Apart from initializing a new daily's TODO, leave frontmatter and every other
   section unchanged. Run `zk index`, inspect the changed daily, and report its
   path.

## Rendering GitHub work

Render top-level entries with `- ` and group children with `  - `. Format links
as `<title>: [#N](URL)`, omitting the colon when there is no link. Use titles
verbatim and keep every child returned in a group.
