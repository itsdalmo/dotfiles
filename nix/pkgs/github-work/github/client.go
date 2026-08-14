// Package github provides a githubwork source backed by the GitHub CLI.
package github

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os/exec"
	"strings"
	"time"

	githubwork "github.com/itsdalmo/dotfiles/github-work"
)

const graphQLQuery = `
query($search: String!, $endCursor: String) {
  search(query: $search, type: ISSUE, first: 100, after: $endCursor) {
    nodes {
      __typename
      ... on Issue {
        author { login }
        body createdAt stateReason
        labels(first: 100) { nodes { name } }
        number repository { nameWithOwner } state title url
        timelineItems(last: 50) { nodes {
          __typename
          ... on IssueComment { createdAt updatedAt author { login } body url }
          ... on ClosedEvent { createdAt actor { login } stateReason }
          ... on ReopenedEvent { createdAt actor { login } }
        } }
      }
      ... on PullRequest {
        author { login }
        body createdAt isDraft
        labels(first: 100) { nodes { name } }
        number repository { nameWithOwner } state title url
        reviews(last: 50) { nodes { submittedAt updatedAt author { login } state body url } }
        reviewThreads(last: 50) { nodes { comments(last: 50) { nodes { createdAt updatedAt author { login } body url } } } }
        timelineItems(last: 50) { nodes {
          __typename
          ... on IssueComment { createdAt updatedAt author { login } body url }
          ... on PullRequestCommit { commit { committedDate messageHeadline url } }
          ... on MergedEvent { createdAt actor { login } commit { url } }
          ... on ClosedEvent { createdAt actor { login } }
          ... on ReopenedEvent { createdAt actor { login } }
          ... on ReadyForReviewEvent { createdAt actor { login } }
          ... on ConvertToDraftEvent { createdAt actor { login } }
        } }
      }
    }
    pageInfo { hasNextPage endCursor }
  }
}`

type graphResponse struct {
	Data struct {
		Search struct {
			Nodes []graphNode `json:"nodes"`
		} `json:"search"`
	} `json:"data"`
}

type graphNode struct {
	Typename      string `json:"__typename"`
	Author        loginNode
	Body          string
	CreatedAt     time.Time
	StateReason   string
	Number        int
	State         string
	Title         string
	URL           string
	IsDraft       bool
	Repository    struct{ NameWithOwner string }
	Labels        struct{ Nodes []struct{ Name string } }
	Reviews       struct{ Nodes []graphReview }
	ReviewThreads struct {
		Nodes []struct {
			Comments struct{ Nodes []graphReviewComment }
		}
	}
	TimelineItems struct{ Nodes []graphEvent }
}

type loginNode struct{ Login string }

type graphReview struct {
	SubmittedAt time.Time
	UpdatedAt   time.Time
	Author      loginNode
	State       string
	Body        string
	URL         string
}

type graphReviewComment struct {
	CreatedAt time.Time
	UpdatedAt time.Time
	Author    loginNode
	Body      string
	URL       string
}

type graphEvent struct {
	Typename    string `json:"__typename"`
	CreatedAt   *time.Time
	Actor       loginNode
	Author      loginNode
	StateReason string
	Body        string
	URL         string
	Commit      struct {
		CommittedDate   *time.Time
		MessageHeadline string
		URL             string
	}
}

// Client reads GitHub data by invoking the authenticated gh CLI.
type Client struct {
	runOverride func(context.Context, ...string) ([]byte, error)
}

// AuthenticatedUser returns the login for the active gh account.
func (c Client) AuthenticatedUser(ctx context.Context) (string, error) {
	out, err := c.run(ctx, "api", "user", "--jq", ".login")
	if err != nil {
		return "", fmt.Errorf("get authenticated GitHub user: %w", err)
	}
	return strings.TrimSpace(string(out)), nil
}

// Search returns normalized issues and pull requests matching a GitHub search.
func (c Client) Search(ctx context.Context, search string) ([]githubwork.Item, error) {
	out, err := c.run(ctx, "api", "graphql", "--paginate", "-F", "search="+search, "-f", "query="+graphQLQuery)
	if err != nil {
		return nil, fmt.Errorf("search GitHub: %w", err)
	}
	return decodeSearch(out)
}

func decodeSearch(data []byte) ([]githubwork.Item, error) {
	decoder := json.NewDecoder(bytes.NewReader(data))
	var items []githubwork.Item
	for {
		var response graphResponse
		if err := decoder.Decode(&response); errors.Is(err, io.EOF) {
			break
		} else if err != nil {
			return nil, fmt.Errorf("decode GitHub response: %w", err)
		}
		for _, node := range response.Data.Search.Nodes {
			items = append(items, node.item())
		}
	}
	return items, nil
}

// ResolveIssues resolves issue URLs in one GraphQL request. Missing issues are omitted.
func (c Client) ResolveIssues(ctx context.Context, urls []string) (map[string]githubwork.GroupIssue, error) {
	if len(urls) == 0 {
		return map[string]githubwork.GroupIssue{}, nil
	}

	var query strings.Builder
	query.WriteString("query {")
	for index, url := range urls {
		reference, err := githubwork.ParseURL(url)
		if err != nil {
			return nil, fmt.Errorf("resolve issue URL: %w", err)
		}
		if reference.Kind != githubwork.Issue {
			return nil, fmt.Errorf("resolve issue URL %q: not an issue", url)
		}
		fmt.Fprintf(&query, `i%d: repository(owner:%q,name:%q){issue(number:%d){title body state stateReason url parent{url}}}`, index, reference.Owner, reference.Repository, reference.Number)
	}
	query.WriteString("}")

	out, err := c.run(ctx, "api", "graphql", "-f", "query="+query.String())
	resolved, decodeErr := decodeResolvedIssues(urls, out)
	if err != nil && decodeErr != nil {
		return nil, fmt.Errorf("fetch grouping issues: %w", err)
	}
	if decodeErr != nil {
		return nil, decodeErr
	}
	return resolved, nil
}

func decodeResolvedIssues(urls []string, data []byte) (map[string]githubwork.GroupIssue, error) {
	var response struct {
		Data map[string]struct {
			Issue *graphGroupIssue
		} `json:"data"`
		Errors []struct {
			Type    string `json:"type"`
			Message string `json:"message"`
		} `json:"errors"`
	}
	if err := json.Unmarshal(data, &response); err != nil {
		return nil, fmt.Errorf("decode grouping issues: %w", err)
	}
	for _, graphErr := range response.Errors {
		if graphErr.Type != "NOT_FOUND" {
			return nil, fmt.Errorf("resolve grouping issues: GraphQL %s: %s", graphErr.Type, graphErr.Message)
		}
	}
	resolved := make(map[string]githubwork.GroupIssue)
	for index := range urls {
		entry := response.Data[fmt.Sprintf("i%d", index)]
		if entry.Issue == nil {
			continue
		}
		issue := entry.Issue
		resolved[urls[index]] = githubwork.GroupIssue{
			Title: issue.Title, Body: issue.Body, State: normalizeState(issue.State),
			StateReason: normalizeState(issue.StateReason), URL: issue.URL, ParentURL: issue.Parent.URL,
		}
	}
	return resolved, nil
}

func (c Client) run(ctx context.Context, args ...string) ([]byte, error) {
	if c.runOverride != nil {
		return c.runOverride(ctx, args...)
	}
	cmd := exec.CommandContext(ctx, "gh", args...)
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	out, err := cmd.Output()
	if err != nil {
		message := strings.TrimSpace(stderr.String())
		if message != "" {
			return out, fmt.Errorf("gh: %s: %w", message, err)
		}
		return out, fmt.Errorf("gh: %w", err)
	}
	return out, nil
}

type graphGroupIssue struct {
	Title       string
	Body        string
	State       string
	StateReason string
	URL         string
	Parent      struct{ URL string }
}

const ignoredActor = "atlantis-for-aidn[bot]"

func (node graphNode) item() githubwork.Item {
	item := githubwork.Item{
		Type:        nodeType(node.Typename),
		Repo:        node.Repository.NameWithOwner,
		Number:      node.Number,
		Title:       node.Title,
		State:       normalizeState(node.State),
		StateReason: normalizeState(node.StateReason),
		URL:         node.URL,
		Author:      node.Author.Login,
		Draft:       node.IsDraft,
		Created:     node.CreatedAt,
		Body:        node.Body,
	}
	for _, label := range node.Labels.Nodes {
		item.Labels = append(item.Labels, label.Name)
	}
	for _, review := range node.Reviews.Nodes {
		if review.Author.Login == ignoredActor {
			continue
		}
		item.Reviews = append(item.Reviews, githubwork.Review{
			At:      review.SubmittedAt,
			Updated: editTime(review.SubmittedAt, review.UpdatedAt),
			Author:  review.Author.Login,
			State:   normalizeState(review.State),
			Body:    review.Body,
			URL:     review.URL,
		})
	}
	for _, thread := range node.ReviewThreads.Nodes {
		for _, comment := range thread.Comments.Nodes {
			if comment.Author.Login == ignoredActor {
				continue
			}
			item.ReviewComments = append(item.ReviewComments, githubwork.ReviewComment{
				At:      comment.CreatedAt,
				Updated: editTime(comment.CreatedAt, comment.UpdatedAt),
				Author:  comment.Author.Login,
				Body:    comment.Body,
				URL:     comment.URL,
			})
		}
	}
	for _, event := range node.TimelineItems.Nodes {
		actor := event.Actor.Login
		if actor == "" {
			actor = event.Author.Login
		}
		if actor == ignoredActor || event.Typename == "PullRequestReview" {
			continue
		}
		at := event.CreatedAt
		if at == nil {
			at = event.Commit.CommittedDate
		}
		url := event.URL
		if url == "" {
			url = event.Commit.URL
		}
		item.Timeline = append(item.Timeline, githubwork.Event{
			At:          at,
			Kind:        eventName(event.Typename),
			Actor:       actor,
			StateReason: normalizeState(event.StateReason),
			Message:     event.Commit.MessageHeadline,
			Body:        event.Body,
			URL:         url,
		})
	}
	return item
}

func editTime(created, updated time.Time) *time.Time {
	if updated.Equal(created) {
		return nil
	}
	return &updated
}

func nodeType(value string) githubwork.Kind {
	if value == "PullRequest" {
		return githubwork.PullRequest
	}
	return githubwork.Issue
}

func eventName(value string) string {
	value = strings.TrimSuffix(value, "Event")
	value = strings.TrimPrefix(value, "PullRequest")
	var result strings.Builder
	for i, r := range value {
		if i > 0 && r >= 'A' && r <= 'Z' {
			result.WriteByte('_')
		}
		result.WriteRune(r)
	}
	return strings.ToLower(result.String())
}

func normalizeState(value string) string { return strings.ToLower(value) }
