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

1. Resolve the date: the date the user names, today for "update my daily", or
   the previous calendar day for "update yesterday's daily".
2. If the daily is missing, create it with:

   ```bash
   zk daily --date=<YYYY-MM-DD> --print-path --no-input
   ```

   Only for a newly created daily, run `github-work todo --markdown` and
   populate its empty `## TODO` with its complete output. After this initial
   population, `## TODO` is user-managed.
3. Read the entire daily, then run:

   ```bash
   github-work log --markdown --from <YYYY-MM-DD> --to <YYYY-MM-DD> --timezone <IANA-zone>
   ```

4. Update only `## Log`. Merge the command output with existing entries without
   duplicating GitHub URLs or removing manual entries. Keep the output's lines
   verbatim, including every group child.
5. Apart from initializing a new daily's TODO, leave frontmatter and every other
   section unchanged. Run `zk index`, inspect the changed daily, and report its
   path.

## GitHub work

Both commands print a ready-to-use markdown list. Use only their output. If a
command fails, report the error and stop; do not fall back to `gh` or other
GitHub queries, and do not re-filter, regroup, reformat, or supplement its
result.
