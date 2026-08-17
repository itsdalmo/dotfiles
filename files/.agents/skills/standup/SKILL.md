---
name: standup
description: Prepare a Slack-ready standup from daily notes. Use for a standup, a yesterday-and-today update, or the latest working-day summary.
---

# Standup

Read canonical daily files directly from
`$ZK_NOTEBOOK_DIR/daily/YYYY-MM-DD.md`. Do not change notes, query GitHub, or
save the standup. Default to `Europe/Oslo`.

## Gather

1. Read today's daily and the nearest preceding Monday-Friday daily.
2. If that earlier Log has no completed, non-review work, inspect at most four
   earlier weekdays and use the first that does. Report a missing required daily
   instead of creating or refreshing it.

## Select

- Build the historical section from the selected Log. Keep substantive
  completed outcomes and workstream groups. Omit reviews, tests, superseded or
  unresolved work, and low-signal maintenance. Omit complete `Reviewed PRs`
  groups along with their children.
- Keep every retained Renovate group complete: preserve its parent and original
  total, and include every child regardless of component or update type. This
  overrides the low-signal maintenance filter for Renovate children.
- Keep notable children beneath other retained workstream parents. Never repeat
  a child as a top-level item.
- Build `Today` only from today's unchecked top-level TODO entries and without
  filtering. Strip the `[ ]` marker while preserving each entry's wording and
  links. Exclude checked top-level entries. For an unchecked Renovate group,
  include every source child instead of rendering only its parent. An empty
  TODO stays empty.
- Use today's `## Blockers` or blockers supplied by the user; otherwise use
  `None`.

Preserve the daily's wording and links. Label the historical section
`Yesterday`, `Friday` on Monday, or the relevant weekday otherwise.

## Render

Return exactly one fenced `markdown` code block and no text outside it. The
fence is part of the output contract: it keeps the Markdown source copyable for
Slack instead of letting the client render it. Put this shape inside the fence,
with every heading and top-level bullet shown:

```markdown
*Yesterday:*
- Outcome: [#1](URL)
    - Group child: [#2](URL)

*Today:*
- Planned work: [#3](URL)

*Blockers:*
- None
```

Use Slack mrkdwn's single asterisks for bold headings and exactly four spaces
before group children. Before returning, verify the
source dates, all three sections, exclusions, complete parent/child structure,
every Renovate child and its parent's original total, unchanged Today wording
and links, blockers, the opening and closing fences, and the absence of prose
outside them.
