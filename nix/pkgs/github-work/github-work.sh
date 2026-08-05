#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 <log|todo|fetch> [options]

Commands:
  log             Issues and PRs involving you, updated in a time range
  todo            Open authored PRs, assigned issues, and Renovate PRs
  fetch <url>     Fetch one issue or pull request by GitHub URL

Output:
  A JSON array of normalized issues and pull requests. Empty optional fields
  are omitted. Results are deduplicated by URL and sorted by updated time.
  Timestamps use GitHub's ISO 8601 format.

  Every item may include type, category, repo, number, title, state,
  stateReason, url, author, assignees, labels, draft, locked, created,
  updated, closed, body, reviews, reviewComments, and timeline. Nested event
  objects use "at" as their event time. "category" is present only for todo
  and is authored_pr, assigned_issue, or renovate_pr. fetch returns zero or
  one matching item.

  Search returns at most 1,000 items per query. Embedded assignees and labels
  are limited to 100; reviews, review threads, comments per thread, and
  timeline items are limited to the most recent 50.

Options:
  --from <value>  Start of range (default: midnight today in UTC)
  --to <value>    End of range (default: current time in UTC)
  -h, --help      Show this help

Examples:
  $0 log --from 2026-08-01 --to 2026-08-05
  $0 todo
  $0 fetch https://github.com/AidnAS/platform/issues/6617
EOF
}

fail() {
  printf '%s\n' "$1" >&2
  usage >&2
  exit 2
}

validate_date() {
  local flag="$1"
  local value="$2"

  if [[ ! "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}([Tt][0-9]{2}:[0-9]{2}:[0-9]{2}([Zz]|[+-][0-9]{2}:[0-9]{2})?)?$ ]]; then
    fail "$flag must be an ISO 8601 date or date-time: $value"
  fi
}

parse_args() {
  command=""
  item_url=""
  range_was_set=false
  from="$(date -u '+%Y-%m-%dT00:00:00Z')"
  to="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

  while (($# > 0)); do
    case "$1" in
    log | todo | fetch)
      [[ -z "$command" ]] || fail "Command was specified more than once"
      command="$1"
      ;;
    --from | --to)
      local flag="$1"
      (($# > 1)) || fail "$flag requires a value"
      range_was_set=true
      if [[ "$flag" == "--from" ]]; then
        from="$2"
      else
        to="$2"
      fi
      shift
      ;;
    --from=*)
      range_was_set=true
      from="${1#*=}"
      ;;
    --to=*)
      range_was_set=true
      to="${1#*=}"
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      if [[ "$command" == "fetch" && -z "$item_url" ]]; then
        item_url="$1"
      else
        fail "Unknown argument: $1"
      fi
      ;;
    esac
    shift
  done

  [[ -n "$command" ]] || fail "Command must be log, todo, or fetch"
  if [[ "$command" == "log" ]]; then
    validate_date "--from" "$from"
    validate_date "--to" "$to"
  elif [[ "$command" == "todo" ]]; then
    [[ "$range_was_set" == false ]] || fail "todo does not accept --from or --to"
  else
    [[ "$range_was_set" == false ]] || fail "fetch does not accept --from or --to"
    [[ -n "$item_url" ]] || fail "fetch requires a GitHub issue or pull request URL"
    if [[ ! "$item_url" =~ ^https://github\.com/([^/]+)/([^/]+)/(issues|pull)/([0-9]+)/?$ ]]; then
      fail "fetch requires a GitHub issue or pull request URL: $item_url"
    fi
    fetch_owner="${BASH_REMATCH[1]}"
    fetch_repo="${BASH_REMATCH[2]}"
    fetch_type="${BASH_REMATCH[3]}"
    fetch_number="${BASH_REMATCH[4]}"
    item_url="https://github.com/$fetch_owner/$fetch_repo/$fetch_type/$fetch_number"
  fi
}

fetch_search() {
  local search="$1"

  # GraphQL variables must remain literal for gh to send them to GitHub.
  # shellcheck disable=SC2016
  gh api graphql --paginate \
    -F search="$search" \
    -f query='
    query(
      $search: String!
      $endCursor: String
    ) {
      search(
        query: $search
        type: ISSUE
        first: 100
        after: $endCursor
      ) {
        nodes {
          __typename

          ... on Issue {
            assignees(first: 100) {
              nodes { login }
            }
            author { login }
            body
            closedAt
            createdAt
            stateReason
            locked
            labels(first: 100) {
              nodes { name }
            }
            number
            repository { nameWithOwner }
            state
            title
            updatedAt
            url

            timelineItems(last: 50) {
              nodes {
                __typename

                ... on IssueComment {
                  createdAt
                  updatedAt
                  author { login }
                  body
                  url
                }

                ... on AssignedEvent {
                  createdAt
                  actor { login }
                  assignee {
                    ... on User { login }
                    ... on Bot { login }
                    ... on Mannequin { login }
                  }
                }

                ... on UnassignedEvent {
                  createdAt
                  actor { login }
                  assignee {
                    ... on User { login }
                    ... on Bot { login }
                    ... on Mannequin { login }
                  }
                }

                ... on LabeledEvent {
                  createdAt
                  actor { login }
                  label { name }
                }

                ... on UnlabeledEvent {
                  createdAt
                  actor { login }
                  label { name }
                }

                ... on RenamedTitleEvent {
                  createdAt
                  actor { login }
                  previousTitle
                  currentTitle
                }

                ... on CrossReferencedEvent {
                  createdAt
                  actor { login }
                  source {
                    __typename
                    ... on Issue { url }
                    ... on PullRequest { url }
                  }
                }

                ... on ClosedEvent {
                  createdAt
                  actor { login }
                  stateReason
                }

                ... on ReopenedEvent {
                  createdAt
                  actor { login }
                }
              }
            }
          }

          ... on PullRequest {
            assignees(first: 100) {
              nodes { login }
            }
            author { login }
            body
            closedAt
            createdAt
            isDraft
            locked
            labels(first: 100) {
              nodes { name }
            }
            number
            repository { nameWithOwner }
            state
            title
            updatedAt
            url

            reviews(last: 50) {
              nodes {
                submittedAt
                updatedAt
                author { login }
                state
                body
                commit { oid }
                url
              }
            }

            reviewThreads(last: 50) {
              nodes {
                comments(last: 50) {
                  nodes {
                    createdAt
                    updatedAt
                    author { login }
                    body
                    path
                    line
                    originalLine
                    replyTo { id }
                    url
                  }
                }
              }
            }

            timelineItems(last: 50) {
              nodes {
                __typename

                ... on IssueComment {
                  createdAt
                  updatedAt
                  author { login }
                  body
                  url
                }

                ... on PullRequestReview {
                  submittedAt
                  updatedAt
                  author { login }
                  state
                  body
                  url
                }

                ... on AssignedEvent {
                  createdAt
                  actor { login }
                  assignee {
                    ... on User { login }
                    ... on Bot { login }
                    ... on Mannequin { login }
                  }
                }

                ... on UnassignedEvent {
                  createdAt
                  actor { login }
                  assignee {
                    ... on User { login }
                    ... on Bot { login }
                    ... on Mannequin { login }
                  }
                }

                ... on LabeledEvent {
                  createdAt
                  actor { login }
                  label { name }
                }

                ... on UnlabeledEvent {
                  createdAt
                  actor { login }
                  label { name }
                }

                ... on RenamedTitleEvent {
                  createdAt
                  actor { login }
                  previousTitle
                  currentTitle
                }

                ... on ReviewRequestedEvent {
                  createdAt
                  actor { login }
                  requestedReviewer {
                    ... on User { login }
                    ... on Team { name }
                    ... on Mannequin { login }
                  }
                }

                ... on ReviewRequestRemovedEvent {
                  createdAt
                  actor { login }
                  requestedReviewer {
                    ... on User { login }
                    ... on Team { name }
                    ... on Mannequin { login }
                  }
                }

                ... on CrossReferencedEvent {
                  createdAt
                  actor { login }
                  source {
                    __typename
                    ... on Issue { url }
                    ... on PullRequest { url }
                  }
                }

                ... on PullRequestCommit {
                  commit {
                    oid
                    committedDate
                    messageHeadline
                    url
                  }
                }

                ... on MergedEvent {
                  createdAt
                  actor { login }
                  commit { oid url }
                }

                ... on ClosedEvent {
                  createdAt
                  actor { login }
                }

                ... on ReopenedEvent {
                  createdAt
                  actor { login }
                }

                ... on ReadyForReviewEvent {
                  createdAt
                  actor { login }
                }

                ... on ConvertToDraftEvent {
                  createdAt
                  actor { login }
                }
              }
            }
          }
        }

        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  '
}

fetch_work() {
  if [[ "$command" == "log" ]]; then
    fetch_search "org:AidnAS involves:@me is:pr updated:$from..$to"
    fetch_search "org:AidnAS involves:@me is:issue updated:$from..$to"
  elif [[ "$command" == "todo" ]]; then
    fetch_search 'org:AidnAS is:pr is:open author:@me'
    fetch_search 'org:AidnAS is:issue is:open assignee:@me'
    fetch_search 'org:AidnAS archived:false is:pr state:open label:renovate author:"cozy-janitor[bot]"'
  else
    local item_type="is:issue"
    [[ "$fetch_type" == "pull" ]] && item_type="is:pr"
    fetch_search "repo:$fetch_owner/$fetch_repo $item_type $fetch_number in:number"
  fi
}

format_work() {
  jq -cs --arg command "$command" --arg item_url "$item_url" '
      def compact:
        with_entries(
          select(
            .value != null
            and .value != false
            and .value != ""
            and .value != []
          )
        );

      def event_name:
        sub("Event$"; "")
        | sub("^PullRequest"; "")
        | gsub("(?<lower>[a-z0-9])(?<upper>[A-Z])"; "\(.lower)_\(.upper)")
        | ascii_downcase;

      [
        .[].data.search.nodes[]
        | {
            type: (
              if .__typename == "PullRequest"
              then "pr"
              else "issue"
              end
            ),
            category: (
              if $command != "todo" then null
              elif .__typename == "Issue" then "assigned_issue"
              elif .author.login == "cozy-janitor[bot]" then "renovate_pr"
              else "authored_pr"
              end
            ),
            repo: .repository.nameWithOwner,
            number,
            title,
            state: (.state | ascii_downcase),
            stateReason: (.stateReason // null | if . then ascii_downcase else null end),
            url,
            author: .author.login,
            assignees: [.assignees.nodes[].login],
            labels: [.labels.nodes[].name],
            draft: (.isDraft // false),
            locked: .locked,
            created: .createdAt,
            updated: .updatedAt,
            closed: .closedAt,
            body,
            reviews: [
              (.reviews.nodes // [])[]
              | select(.author.login != "atlantis-for-aidn[bot]")
              | {
                  at: .submittedAt,
                  updated: (
                    if .updatedAt != .submittedAt
                    then .updatedAt
                    else null
                    end
                  ),
                  author: .author.login,
                  state: (.state | ascii_downcase),
                  body,
                  commit: .commit.oid,
                  url
                }
              | compact
            ],
            reviewComments: [
              (.reviewThreads.nodes // [])[].comments.nodes[]
              | select(.author.login != "atlantis-for-aidn[bot]")
              | {
                  at: .createdAt,
                  updated: (
                    if .updatedAt != .createdAt
                    then .updatedAt
                    else null
                    end
                  ),
                  author: .author.login,
                  path,
                  line,
                  originalLine,
                  replyTo: .replyTo.id,
                  body,
                  url
                }
              | compact
            ],
            timeline: [
              .timelineItems.nodes[]
              | select(
                  (.actor.login? // .author.login? // "")
                  != "atlantis-for-aidn[bot]"
                )
              | select(.__typename != "PullRequestReview")
              | {
                  at: (.createdAt // .committedDate // .commit.committedDate),
                  event: (.__typename | event_name),
                  actor: (.actor.login // .author.login),
                  stateReason: (.stateReason // null | if . then ascii_downcase else null end),
                  assignee: .assignee.login,
                  label: .label.name,
                  reviewer: (.requestedReviewer.login // .requestedReviewer.name),
                  from: .previousTitle,
                  to: .currentTitle,
                  state: (.state // .review.state),
                  commit: .commit.oid,
                  message: .commit.messageHeadline,
                  source: .source.url,
                  body,
                  url: (.url // .commit.url)
                }
              | compact
            ]
          }
        | compact
        | select($command != "fetch" or .url == $item_url)
      ]
      | unique_by(.url)
      | sort_by(.updated)
    '
}

main() {
  parse_args "$@"
  fetch_work | format_work
}

main "$@"
