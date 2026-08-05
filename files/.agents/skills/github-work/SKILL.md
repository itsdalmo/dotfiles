---
name: github-work
description: Discover GitHub work by date, exact URL, or current ownership. Use when asked what the user did, what changed on a linked issue or pull request, which authored pull requests or assigned issues remain open, or when another skill needs verified GitHub evidence.
---

# GitHub Work

Use `github-work` for read-only GitHub discovery. It requires GitHub network access and an authenticated `gh` CLI. Its `--help` output defines the normalized JSON contract. Default to the `AidnAS` organization and `Europe/Oslo` timezone.

Choose one workflow:

- **Log:** Dated activity or evidence for a dated note.
- **Fetch:** History and state transitions for an exact issue or pull-request URL.
- **TODO:** Current authored pull requests, assigned issues, and Renovate work.

## Log

1. Resolve the requested local dates, using today when none is supplied. Convert each range boundary to ISO 8601 with its actual UTC offset; account for daylight-saving changes.
2. Fetch each contiguous range once:

```bash
github-work log --from <ISO-8601> --to <ISO-8601>
```

3. Get the authenticated login with `gh api user --jq .login`. Treat each item and its `timeline`, `reviews`, and `reviewComments` as candidate evidence. Retain only actions whose own `at`, `created`, `updated`, or `closed` timestamp falls in the requested local range and whose actor or author is the authenticated user. A top-level `updated` value explains why search matched; it does not prove user activity. A commit on the user's authored pull request is attributable when no more specific actor is available.
4. Include authored work, comments, commits, lifecycle actions, and every submitted review, including approvals. Omit labels, assignments, unassignments, and review requests from rendered outcomes unless they materially explain one, but retain assignment transitions when supplying evidence for TODO reconciliation. Timeline entries without timestamps cannot establish dated activity.
5. Collapse actions describing the same outcome. Process lifecycle events chronologically; a terminal outcome counts only when it remains the final state in the range. For example, a close followed by a reopen is not a completion. Group outcomes only when repository, title, links, or purpose provide clear evidence. Sort outcomes and groups by their earliest retained event.
6. Name each outcome with **Outcome wording**, then format it as `<description>: [#N](URL)`, with comma-separated links and no colon when there is no link. Represent groups as a parent with ordered children without prescribing indentation or bullet characters; the calling skill owns presentation. When supplying evidence to another skill, also supply each outcome's earliest timestamp and whether it is review-only.

### Outcome wording

Describe what happened, not merely the item title or the event that exposed it:

- For merged pull requests and completed issues, state the semantic result with a concise action phrase derived from the title and supporting evidence. Omit lifecycle prefixes such as `Merged` and `Closed`; for example, render `chore(deps): update aidnas/cozy-toolkit digest to 781cc28` as `Update cozy-toolkit digest to 781cc28`.
- For pull requests closed without merge, prefix the semantic subject with `Closed`. Add a reason such as `stale`, `superseded`, or `test` only when evidence or the user supplies it. Preserve meaningful draft status; for example, `Closed Teleport RBAC draft`.
- For issues finally closed as `not_planned`, prefix the semantic subject with `Closed`. For issues closed as `completed`, state the semantic result without a lifecycle prefix.
- For reopened items, use `Reopened` when reopening is the final meaningful outcome in range. Otherwise describe the semantic work performed.
- For review-only outcomes, prefix the semantic subject with `Reviewed` and mark the outcome as review-only.
- For ongoing authored work, comments, and commits without a terminal outcome, describe the semantic work performed. Use `Opened`, `Commented`, or `Committed` only when that action itself is the meaningful outcome.

Strip conventional-commit scaffolding such as `feat(scope):` and `chore(deps):` when it does not add meaning. Preserve concrete components, versions, status, and purpose. Group related outcomes only when one description accurately represents every linked item; never group merged work with closed-unmerged work.

### Renovate Log

Collapse Cozy Janitor dependency pull requests merged by the user into one `Renovate PRs (N total):` outcome. Count every qualifying merge exactly once and add one child for every counted pull request, including routine GitHub Actions, digests, pins, runtimes, SDKs, libraries, and development tooling. Do not prescribe indentation or bullet characters. Describe the updated dependency or component concisely and link the pull request. Sort children by earliest event, then pull-request number. The group is complete only when it has exactly `N` linked children; never supply a Renovate parent without its children to a daily-note workflow.

Log discovery is complete when every retained outcome has attributable evidence in range, appears once, its wording reflects its final evidenced state, and any uncertainty from GitHub Search or the 50-item embedded connection limits is explicit.

## Fetch

Fetch an exact linked item when the user requests it or another skill needs current or verified context beyond its source material:

```bash
github-work fetch <github-issue-or-pull-request-url>
```

`fetch` returns the same normalized JSON array as the other commands, containing exactly the matching item. Filter its timeline, reviews, review comments, and top-level `closed` timestamp to the caller's local date range before drawing dated conclusions. Use `stateReason` to distinguish an issue closed as `completed` from `not_planned`. Process `assigned`, `unassigned`, `closed`, `reopened`, and `merged` events chronologically; for assignment transitions, compare `assignee` with the authenticated login. Current top-level state cannot prove when a transition happened. A top-level `closed` timestamp is dated closure evidence when the bounded timeline omitted its event, but report uncertainty rather than assuming no later transition when the missing timeline could change the end-of-range state.

Fetch is complete when the exact URL returns one normalized item, or absence is reported without inferring a state transition.

## TODO

1. Get the authenticated login with `gh api user --jq .login`, then fetch the complete inventory once:

```bash
github-work todo
```

2. Deduplicate by URL and retain each item's `category`: `authored_pr`, `assigned_issue`, or `renovate_pr`. Return repository, title, URL, category, and pull-request draft status. These are current-work candidates, not confirmed plans outside a daily-note workflow.
3. Group open Renovate pull requests using the Log grouping rules, changing only the parent description to represent current work. Include one linked child for every counted pull request. Do not combine unrelated authored pull requests or assigned issues merely because they share a repository.
4. Do not infer a transition from inventory absence alone.

TODO discovery is complete when every current result appears once and a 1,000-result search cap is reported if reached.
