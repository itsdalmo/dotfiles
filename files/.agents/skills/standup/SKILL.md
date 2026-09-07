---
name: standup
description: Create Slack-ready standup markdown from daily notes. Use for "post my standup" or a daily standup update.
---

# Standup

Read `$ZK_NOTEBOOK_DIR/daily/YYYY-MM-DD.md` directly. Use `Europe/Oslo` to
resolve dates unless the user supplies another timezone. Do not change notes,
query GitHub, or post to Slack.

## Create

1. Read today's daily and the nearest preceding Monday-Friday daily.
2. Build the earlier section from the preceding daily's `## Log` and `Today`
   from today's `## TODO`. Do not use other sections, GitHub, or earlier dailies.
   Report a missing daily instead of creating it.
3. Include unchecked TODO items and omit checked ones. Strip task markers, but
   otherwise preserve wording, links, order, and parent-child structure. Remove
   empty lines and change child indentation to four spaces for Slack. If a
   selected section is empty, use `- None`.
4. Label the earlier section `Yesterday`, or `Friday` when today is Monday.
   Label today's section `Today`.
5. Return exactly one fenced `markdown` block and no text outside it:

```markdown
*Yesterday:*
- Work item: [#1](URL)
    - Group child: [#2](URL)

*Today:*
- Work item: [#3](URL)
```

Use Slack mrkdwn's single asterisks for bold headings and exactly four spaces
before group children. Verify both source dates, the preceding Log, today's
unchecked TODO items, the fences, and the absence of prose outside them.
