---
name: standup
description: Prepare a Slack-ready standup from daily notes. Use when asked for a standup, a yesterday-and-today update, or the latest working-day summary.
---

# Standup

Build a standup from canonical daily notes. Invoke daily-notes only with its read workflow. Do not update notes, invoke `github-work`, or save the rendered standup.

## Gather

1. Resolve today in the request timezone, defaulting to `Europe/Oslo`. The previous workday is the nearest preceding Monday-Friday date; skip weekends, not holidays.
2. Invoke daily-notes to read that workday's daily in full.
3. If its Log has no completed non-review work, inspect at most four earlier weekday dailies and select the first with completed non-review Log work. Do not create a missing daily or refresh a stale one.
4. Invoke daily-notes to read today's daily in full.

Gathering is complete when the selected historical daily and today's daily have been read without changing the notebook.

## Compose

- Build the historical section from top-level completed Log outcomes in the selected daily. Exclude every review-only item, including grouped review entries. Do not promote a grouped child to a top-level standup bullet.
- Build `Today` from top-level, non-struck TODO items. Exclude stale struck items and unrelated Notes content. Do not promote a grouped child to a top-level standup bullet.
- Preserve each retained item's description and links from the daily note. Do not paraphrase, change tense, or replace its wording with a child description.
- From both sections, omit routine dependency maintenance regardless of author or grouping: GitHub Actions bumps, digest-only updates, dependency pins, language runtimes, SDKs, libraries, and development tooling. Retain dependency work for deployed services or operational platform components.
- Render every retained Renovate group as the count-only top-level bullet `Renovate PRs (N total)`, using the parent's original total. Omit the trailing colon and every child from the standup, even when some children would otherwise be retained.
- Use blockers explicitly supplied by the user or recorded under today's `## Blockers`; otherwise use `None`.
- Label yesterday as `Yesterday`, the preceding Friday on Monday as `Friday`, and other dates with their weekday name.

## Render

Return exactly one fenced code block containing raw Slack-compatible Markdown:

```text
*REPORT_LABEL:*

* Database module cleanup: [#3967](https://github.com/AidnAS/platform/pull/3967)
* Renovate PRs (5 total)

*Today:*

* Continue refactoring Alloy: [#3975](https://github.com/AidnAS/platform/pull/3975)

*Blockers:*

* None
```

Use `*` for headings and top-level bullets and `: [#N](URL)` for references. Before returning, verify all three sections, source dates, review exclusion, blockers, source wording and links, top-level selection, and each Renovate total. The result must not contain a grouped child or a four-space-indented bullet. If a required daily is missing, report that it must be updated instead of invoking GitHub or creating the note.
