---
name: github-work
description: Query attributed GitHub activity, an exact issue or pull request, or current assigned and authored work. Use for dated GitHub work, linked GitHub context, or the user's current GitHub TODO inventory.
---

# GitHub Work

Use the read-only `github-work` CLI. It requires an authenticated `gh` session.
The CLI owns discovery, attribution, eligibility, state reduction, relations,
and grouping; treat its JSON as authoritative rather than reconstructing those
decisions with `gh` or prose analysis.

Choose one command:

```bash
github-work log --from <date-or-ISO-8601> --to <date-or-ISO-8601> --timezone <IANA-zone>
github-work fetch <github-issue-or-pull-request-url>
github-work todo
```

- Use `log` for work within a date range. Default to today and
  `Europe/Oslo` when the request does not specify them.
- Use `fetch` for one exact GitHub URL. An empty array means the item was not
  found; do not infer a transition from absence.
- Use `todo` for the current open inventory.

The result is an array of `issue`, `pr`, and `group` values. Use `summary` for
the reduced outcome, `activity` for dated evidence, and `relations` for the
explicit PR-body wording that linked an item. A group is complete: retain its
children when presenting it. The same PR may intentionally occur in multiple
workstream groups when its body references multiple issues. Preserve URLs and
report command failures or empty results without inventing missing work.

Complete the request by answering at the user's requested level of detail from
the returned data. Do not re-filter attribution, regroup items, or supplement
the result with separate GitHub searches.
