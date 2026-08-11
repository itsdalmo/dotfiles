---
name: daily-notes
description: Read or synchronize daily notes in a zk notebook. Use for a daily note, today's TODO or Log, work recorded on a date, or updating dailies from GitHub.
---

# Daily Notes

Use `ZK_NOTEBOOK_DIR` as the notebook and Git root. Daily files are
`daily/YYYY-MM-DD.md`; their conventional sections are `## TODO`, `## Log`,
then `## Notes`. Preserve manual content and any existing `## Blockers` section.
Default to `Europe/Oslo` when no timezone is supplied.

## Read

Read each requested daily directly, using today when no date is given. Answer
only from the file. Report a missing daily instead of creating it or querying
GitHub.

## Synchronize

1. Run `zk index`, inspect Git status, and account for pre-existing changes.
2. Resolve each requested date. Create or locate it once with:

   ```bash
   zk daily --date=<YYYY-MM-DD> --print-path --no-input
   ```

   Read the whole file before editing it.
3. Capture each date's evidence once:

   ```bash
   github-work log --from <YYYY-MM-DD> --to <YYYY-MM-DD> --timezone <IANA-zone>
   ```

   For today only, also run `github-work todo` once. Use these results directly;
   the CLI has already decided attribution, outcomes, relations, and groups.
4. Reconcile `## Log`. Match existing entries by GitHub URL first and meaning
   second, enrich likely manual matches, and add every unmatched result. Mirror
   CLI groups and their complete child lists; a PR duplicated across different
   workstream groups is intentional. When the CLI changes a generated item's
   group, move the matching entry and remove generated groups left empty; this
   does not authorize removing manual content. Order verified work by its
   earliest activity without needlessly moving timestamp-free manual entries.
5. Reconcile `## TODO`:
   - If today's TODO is empty, bootstrap it from the complete `github-work todo`
     result using unchecked task markers.
   - Once populated, TODO is user-owned. Change it only when explicitly asked,
     except to check a matching item whose Log has a successful, non-review
     outcome.
   - For historical dates, only that completion rule may change TODO.
   - Normalize legacy TODO bullets to task markers: plain entries become
     unchecked and struck entries become checked, with the strikethrough
     removed. Preserve an existing checked state.
   Inventory absence never proves completion or lost ownership.
6. Set `github_work_updated_at` to the current ISO-8601 timestamp, run
   `zk index`, and inspect every changed daily before reporting its path.

## Rendering GitHub work

Render Log entries with `- ` and group children with exactly `  - `. Render
TODO entries with `- [ ] ` or `- [x] ` and grouped TODO children with exactly
`  - [ ] ` or `  - [x] `. Check an item only from a matching successful,
non-review Log outcome; for a synthetic group without its own GitHub URL, check
the parent when every child is checked. Format links as
`<description>: [#N](URL)`, using comma-separated links when needed and omitting
the colon when there is no link.

Write semantic outcomes rather than copying conventional-commit scaffolding:

- Merged PRs and completed issues: state the result without `Merged` or
  `Closed`.
- Closed-unmerged PRs and `not_planned` issues: prefix `Closed`.
- Review-only work: prefix `Reviewed`.
- Reopened work: prefix `Reopened` when that is the final outcome.
- Ongoing work: describe the concrete work; use `Opened`, `Commented`, or
  `Committed` only when that action is itself meaningful.

Preserve concrete components, versions, purpose, draft status, and links.
Reviewed and Renovate group titles must keep their reported totals and every
child. Do not regroup reviewed children beneath issues mentioned in their pull
request bodies. Finish only
when each verified result is represented, TODO uses task markers, matching
completions are checked rather than removed, manual content is intact, and
synchronization metadata was written after successful reconciliation.
