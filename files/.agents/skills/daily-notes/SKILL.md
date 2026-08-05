---
name: daily-notes
description: Read or synchronize daily notes in a zk notebook. Use when asked about a daily note, today's TODO or Log, work on a date, or to update one or more dailies from GitHub.
---

# Daily Notes

Choose one workflow:

- Answer from existing dailies: **Read**.
- Synchronize today: **Update current**.
- Synchronize past dates: **Update historical**.
- Synchronize multiple dates: capture once for their combined range, then apply the appropriate update to each date.

Requires `zk`, Git, `jq`, `github-work`, `ZK_NOTEBOOK_DIR`, notebook filesystem access, and a POSIX-compatible shell. Default to `Europe/Oslo` when the request has no timezone.

## Conventions

- Use `ZK_NOTEBOOK_DIR` as the root for filesystem and Git operations. Run `zk` directly so it uses the configured notebook.
- Daily sections are `## TODO`, `## Log`, then `## Notes`. Preserve unrelated manual content and its position.
- GitHub-managed top-level items use `- `; grouped children use exactly `  - `. Render grouping supplied by `github-work` with this indentation instead of preserving its presentation. Remove task-list markers from GitHub-managed items.
- Format GitHub references as `<description>: [#N](URL)`, with comma-separated links and no colon without a link. Link only reference labels.
- Match existing entries by GitHub URL first and meaning second. Inventory absence is not evidence of completion or lost ownership.
- Use the ISO-8601 frontmatter field `github_work_updated_at`. Set it only after the requested synchronization completes.
- Daily synchronization uses only `github-work log` and `github-work todo`. It does not use `github-work fetch`.

## Prepare an update

1. Resolve every requested date and its local-day boundaries. Use today when no date is supplied.
2. Run `zk index`, inspect Git status, and account for every pre-existing change.
3. For each date, run `zk daily --date=<YYYY-MM-DD> --print-path --no-input` once, read the returned path in full, and restore the conventional section order without moving content between sections.

Preparation is complete when every daily is loaded, boundaries are known, and pre-existing changes are accounted for.

## Capture evidence

1. Create one request-scoped directory with `mktemp -d "${TMPDIR:-/tmp}/daily-notes-github-work.XXXXXX"`.
2. Run `github-work log` once for the smallest contiguous range covering every requested date and save the complete JSON output as `log.json`.
3. If today is requested, run `github-work todo` once and save the complete JSON output as `todo.json`. Historical-only updates skip TODO.
4. Use `jq` against those files for all filtering and date partitioning. Do not rerun a captured command.

Capture is complete when each required command ran once and every date can use evidence within its own local boundaries. Remove the temporary directory after all dailies are inspected; do not store evidence in the notebook.

## Reconcile Log

1. Retain only github-work outcomes attributable to the requested local date. Match them to Log and TODO entries by URL first and meaning second.
2. Rewrite matched GitHub-managed entries with canonical outcome wording. Enrich a likely manual Log match instead of duplicating it.
3. Add each unmatched outcome once under `## Log`. Preserve github-work groups and require a `Renovate PRs (N total):` group to contain exactly `N` linked children. Order verified outcomes by earliest event without moving timestamp-free manual items unnecessarily.
4. Remove a matching TODO only after its successful outcome is present in Log. Otherwise leave it unchanged.

Log reconciliation is complete when every verified outcome appears once, completed work is absent from TODO, grouping is complete, and manual content is preserved.

## Update current

1. Prepare today's daily and use the request's captured Log and TODO evidence. Capture it now only for a single-date update that has not already captured evidence.
2. Reconcile Log.
3. Reconcile `## TODO` with the current inventory. Add each candidate once, refresh still-open wording, preserve useful groups, and preserve unlinked manual entries. Leave an existing linked TODO unchanged when neither Log nor inventory proves a transition.
4. Set `github_work_updated_at` to the current ISO-8601 timestamp. Run `zk index`, inspect the full daily, verify that every grouped child begins with exactly `  - `, and report its path and unresolved items.

The update is complete when verified outcomes and current candidates each appear once, completed work is absent from TODO, manual content remains intact, and `github_work_updated_at` records the completed synchronization.

## Update historical

1. Prepare each requested historical daily and use the request's captured Log evidence. Capture it now only for a historical-only update that has not already captured evidence.
2. Reconcile Log. Do not add TODO candidates or reconstruct historical plans.
3. Set `github_work_updated_at` to the current ISO-8601 timestamp for each successfully reconciled daily. Run `zk index`, inspect every changed daily, verify that every grouped child begins with exactly `  - `, and report each path and unresolved item.

The update is complete when every verified outcome appears once, completed outcomes are absent from TODO, unrelated TODO and manual content remain intact, and each changed daily records the completed synchronization.

## Read

Resolve each requested date, use today when absent, and read `daily/YYYY-MM-DD.md` directly. Answer only from existing content. Do not create or update a daily, invoke `github-work`, or use freshness metadata to trigger synchronization. Report a missing daily instead of reconstructing it.

The read is complete when the answer identifies its source dates and accurately reports requested, missing, or absent content.
