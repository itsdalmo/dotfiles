package github

import (
	"reflect"
	"testing"
	"time"

	githubwork "github.com/itsdalmo/dotfiles/github-work"
)

func TestDecodeSearchReadsEveryPaginatedResponse(t *testing.T) {
	response := []byte(`{"data":{"search":{"nodes":[{"__typename":"Issue","number":1,"state":"OPEN","title":"First","url":"issue-url","repository":{"nameWithOwner":"AidnAS/one"}}]}}}
{"data":{"search":{"nodes":[{"__typename":"PullRequest","number":2,"state":"MERGED","title":"Second","url":"pr-url","repository":{"nameWithOwner":"AidnAS/two"}}]}}}`)

	items, err := decodeSearch(response)
	if err != nil {
		t.Fatal(err)
	}
	want := []githubwork.Item{
		{Type: githubwork.Issue, Repo: "AidnAS/one", Number: 1, Title: "First", State: "open", URL: "issue-url"},
		{Type: githubwork.PullRequest, Repo: "AidnAS/two", Number: 2, Title: "Second", State: "merged", URL: "pr-url"},
	}
	if !reflect.DeepEqual(items, want) {
		t.Fatalf("items = %#v\nwant = %#v", items, want)
	}
}

func TestDecodeSearchRejectsMalformedResponse(t *testing.T) {
	if _, err := decodeSearch([]byte(`{"data":`)); err == nil {
		t.Fatal("expected malformed response error")
	}
}

func TestDecodeResolvedIssuesPreservesRequestedURLAsLookupKey(t *testing.T) {
	requested := "https://github.com/aidnas/platform/issues/42"
	response := `{"data":{"i0":{"issue":{"title":"Parent","state":"OPEN","url":"https://github.com/AidnAS/platform/issues/42","parent":{"url":"https://github.com/AidnAS/platform/issues/10"}}}}}`

	issues, err := decodeResolvedIssues([]string{requested}, []byte(response))
	if err != nil {
		t.Fatal(err)
	}
	issue, ok := issues[requested]
	if !ok {
		t.Fatalf("resolved issues are not keyed by requested URL: %#v", issues)
	}
	if issue.URL != "https://github.com/AidnAS/platform/issues/42" || issue.State != "open" || issue.ParentURL != "https://github.com/AidnAS/platform/issues/10" {
		t.Fatalf("issue = %#v", issue)
	}
}

func TestDecodeResolvedIssuesOmitsMissingIssues(t *testing.T) {
	issues, err := decodeResolvedIssues(
		[]string{"https://github.com/AidnAS/platform/issues/42"},
		[]byte(`{"data":{"i0":{"issue":null}}}`),
	)
	if err != nil {
		t.Fatal(err)
	}
	if len(issues) != 0 {
		t.Fatalf("issues = %#v", issues)
	}
}

func TestDecodeResolvedIssuesRejectsMalformedResponse(t *testing.T) {
	if _, err := decodeResolvedIssues([]string{"issue-url"}, []byte(`{"data":`)); err == nil {
		t.Fatal("expected malformed response error")
	}
}

func TestNormalizeNodeFiltersAutomationAndNormalizesEvents(t *testing.T) {
	at := time.Date(2026, time.August, 13, 10, 0, 0, 0, time.UTC)
	node := graphNode{Typename: "PullRequest", State: "OPEN", CreatedAt: at}
	node.Reviews.Nodes = []graphReview{
		{SubmittedAt: at, Author: loginNode{Login: "atlantis-for-aidn[bot]"}},
		{SubmittedAt: at, Author: loginNode{Login: "dalmo"}, State: "APPROVED"},
	}
	node.TimelineItems.Nodes = []graphEvent{
		{Typename: "ReadyForReviewEvent", CreatedAt: &at, Actor: loginNode{Login: "dalmo"}},
		{Typename: "IssueComment", CreatedAt: &at, Author: loginNode{Login: "atlantis-for-aidn[bot]"}},
	}

	item := node.item()
	if item.Type != "pr" || item.State != "open" || len(item.Reviews) != 1 {
		t.Fatalf("item = %#v", item)
	}
	if len(item.Timeline) != 1 || item.Timeline[0].Kind != "ready_for_review" {
		t.Fatalf("timeline = %#v", item.Timeline)
	}
}
