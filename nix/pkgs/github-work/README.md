# github-work

`github-work` returns normalized GitHub issues and pull requests for daily work
tracking. The `log` command includes an item only when it contains activity that
can be attributed to the authenticated GitHub user within the requested time
range.

## Attributable activity

The CLI first attributes individual activity to the authenticated user:

- Creating an issue or pull request when its `author` is the authenticated
  user.
- Submitting or updating a pull-request review when the review `author` is the
  authenticated user.
- Creating or updating a pull-request review comment when the comment `author`
  is the authenticated user.
- A relevant timeline event when its `actor` or comment `author` is the
  authenticated user. This includes comments, lifecycle changes, and
  draft-state changes returned by the GitHub query.
- A commit on a pull request authored by the authenticated user. GitHub does
  not expose an actor on `PullRequestCommit` timeline entries, so PR authorship
  is used as the attribution fallback.

An activity timestamp must be at or after the resolved `--from` boundary and
before the resolved `--to` boundary. A date supplied to `--to` includes that
whole local day; a date-time supplied to `--to` is an exclusive boundary.
Local dates are resolved using `--timezone`, which defaults to `Europe/Oslo`
and accounts for daylight-saving changes.

## Activity that is not attributable

The following does not establish activity by the authenticated user:

- An item's top-level `updated` timestamp. It is used by GitHub Search to find
  candidates, but another user or automation may have caused the update.
- The current top-level state or `closed` timestamp without a corresponding
  attributable, timestamped activity in the requested range.
- Timeline events performed by another actor.
- Timeline entries without timestamps.
- Commits on pull requests authored by somebody else when GitHub supplies no
  actor for the commit event.
- Activity by `atlantis-for-aidn[bot]`, which is removed while normalizing the
  GitHub response.

Items discovered by GitHub Search that contain no attributable activity in the
requested range are omitted from `log` output.

Attribution alone does not make an item eligible for the log. After attribution,
`log` retains only these categories:

- Issues created by the authenticated user during the range.
- Issues with an issue comment written by the authenticated user during the
  range.
- Pull requests authored by the authenticated user when they contain any
  attributable activity during the range.
- Pull requests opened by Cozy Janitor when the authenticated user merged them
  during the range.
- Pull requests with a review or review comment by the authenticated user
  during the range.

For example, labeling an issue, commenting on somebody else's pull request
outside a review, or merging a non-Renovate pull request does not make that item
eligible or appear in its compact `activity` array.

## TODO inventory

`todo` returns exactly these current open inventories:

- Issues assigned to the authenticated user.
- Pull requests authored by the authenticated user.
- Pull requests authored by `cozy-janitor`. GitHub Search addresses this GitHub
  App as `cozy-janitor[bot]`, while GraphQL returns the normalized login
  `cozy-janitor`. Only PRs that request a review from the authenticated user,
  directly or through one of their teams, and were updated within the preceding
  30 days are included.

## Derived summary

Each retained item receives a `summary` containing:

- `firstActivityAt` and `lastActivityAt`, calculated from attributable activity
  inside the requested range.
- `outcome`, reduced chronologically to `opened`, `active`, `reviewed`,
  `merged`, `closed`, `completed`, `not_planned`, or `reopened`.
- `reviewOnly`, which is true when all attributable activity consists of
  reviews or review comments.

Renovate classification is detected internally from the TODO query, Cozy
Janitor author, or `renovate` label. It controls grouping but is not serialized
as part of the summary.

GitHub emits both `MergedEvent` and `ClosedEvent` for a merge at the same
instant. `merged` takes precedence over that paired close event.

## Output

All commands return the same compact union. Its public `type` is `issue`, `pr`,
or `group`; acquisition categories such as assigned or authored are internal.
Issues and pull requests contain identity, title, body, current state, URL,
author, draft status, extracted relations, relevant activity, and the derived
summary.

A group contains `kind`, `title`, optional parent context, and a complete
`items` array. Groups are never nested:

- Every pull request whose attributable activity consists only of reviews or
  review comments is placed in one `reviewed` group titled
  `Reviewed PRs (N total)`, where `N` equals the number of children. Review-only
  pull requests do not form workstream groups from their issue references.
- Every qualifying Cozy Janitor PR is placed in one `renovate` group titled
  `Renovate PRs (N total)`, where `N` equals the number of children.
- A `workstream` group is formed for every issue referenced by an explicit,
  line-leading phrase in a pull request body: `Closes`, `Fixes`, `Resolves`,
  `Part of`, `Ref`, `Refs`, or `Related to`. Matching is case-insensitive;
  closing-keyword variants such as `Closed`, `Fixed`, and `Resolved`, an
  optional colon, and arbitrary surrounding whitespace are accepted. The
  referenced issue supplies the group's title, URL, body, and current summary.
  When the issue is also present in the result, its activity and richer context
  are absorbed into the group instead of being repeated at the top level.
- References may use `#123`, `owner/repo#123`, or a full GitHub issue URL. A
  line may reference multiple issues. The pull request appears once in each
  unrelated corresponding group and does not additionally appear at the top
  level. When one referenced issue is a native parent or ancestor of another,
  only the most-specific referenced issue receives the pull request.

Incidental issue mentions, unsupported prose such as `Depends on`, list items
whose prefix is not at the start of the line, issue bodies, comments, GitHub
cross-reference events, repository similarity, and title similarity do not
cause grouping. GitHub's native closing-reference field is deliberately not
queried, so the PR body is the single source of grouping semantics. Native
issue-parent metadata only removes redundant ancestor membership; it never
creates a group. Review-only grouping takes precedence over Renovate and
workstream grouping; Renovate grouping takes precedence over workstream groups.
Referenced issues that do not exist or are not accessible are omitted without
discarding other valid groups from the same GitHub response.

Cozy Janitor items omit `body` because generated dependency descriptions are
large and the Log and TODO workflows need only their title, state, URL, and
extracted relations.

`log` activity is attributable, eligible activity inside the requested range.
`fetch` returns the same activity shape over the available item history.
`fetch` returns the exact issue or pull request without wrapping it in a
singleton group. `todo` omits activity because it represents current inventory.
Labels, reviews, review threads, and timeline events are used internally but
are not returned directly.

## Package layout

- The root `githubwork` package owns the domain types, relation extraction,
  activity reduction, grouping, and use-case interface.
- `github` adapts the external `gh` command and GraphQL responses to the root
  package's domain language.
- `internal/cli` adapts command-line arguments and JSON streams.
- `cmd/github-work` is the composition root and contains only process wiring.

## GitHub limits

GitHub Search returns at most 1,000 results per query. The current GraphQL query
also requests at most 100 labels and the most recent 50 reviews, review threads,
comments per review thread, and timeline entries. An event that falls outside
these embedded connection limits cannot be attributed by the CLI.
