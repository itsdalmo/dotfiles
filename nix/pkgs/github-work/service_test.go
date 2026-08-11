package githubwork

import (
	"context"
	"reflect"
	"testing"
	"time"
)

type fakeSource struct {
	user      string
	searches  []string
	results   [][]Item
	issues    map[string]GroupIssue
	issueURLs []string
	userCalls int
}

func (f *fakeSource) AuthenticatedUser(context.Context) (string, error) {
	f.userCalls++
	return f.user, nil
}

func (f *fakeSource) Search(_ context.Context, query string) ([]Item, error) {
	f.searches = append(f.searches, query)
	result := f.results[0]
	f.results = f.results[1:]
	return result, nil
}

func (f *fakeSource) ResolveIssues(_ context.Context, urls []string) (map[string]GroupIssue, error) {
	f.issueURLs = append(f.issueURLs, urls...)
	issues := make(map[string]GroupIssue)
	for _, url := range urls {
		if issue, ok := f.issues[url]; ok {
			issues[url] = issue
		}
	}
	return issues, nil
}

func TestServiceTodoClassifiesAndGroupsResults(t *testing.T) {
	parentURL := "https://github.com/AidnAS/platform/issues/42"
	source := &fakeSource{
		user: "dalmo",
		results: [][]Item{
			{{Type: "pr", Title: "Child", Repo: "AidnAS/platform", URL: "pr", Body: "Part of #42"}},
			{{Type: "issue", Title: "Assigned", URL: "assigned"}},
			{{Type: "pr", Title: "Update", URL: "renovate"}},
		},
		issues: map[string]GroupIssue{parentURL: {Title: "Parent", URL: parentURL, State: "open"}},
	}
	service := NewService(source)
	service.now = func() time.Time { return instant("2026-08-13T12:00:00+02:00") }

	output, err := service.Todo(context.Background())
	if err != nil {
		t.Fatal(err)
	}
	if len(source.searches) != 3 || len(output) != 3 {
		t.Fatalf("searches = %d, output = %#v", len(source.searches), output)
	}
	if source.userCalls != 0 {
		t.Fatalf("authenticated user requested %d times", source.userCalls)
	}
	if !reflect.DeepEqual(source.issueURLs, []string{parentURL}) {
		t.Fatalf("issue URLs = %#v", source.issueURLs)
	}
	groups := make(map[string]OutputItem)
	for _, item := range output {
		groups[item.Kind] = item
	}
	if len(groups["renovate"].Items) != 1 || len(groups["workstream"].Items) != 1 || groups["workstream"].Items[0].Title != "Child" {
		t.Fatalf("output = %#v", output)
	}
}

func TestServiceFetchUsesExactURLMatch(t *testing.T) {
	source := &fakeSource{
		user: "dalmo",
		results: [][]Item{{
			{Type: "pr", URL: "https://github.com/AidnAS/platform/pull/12", Title: "Wanted"},
			{Type: "pr", URL: "https://github.com/AidnAS/platform/pull/123", Title: "Wrong"},
		}},
	}
	service := NewService(source)

	output, err := service.Fetch(context.Background(), "https://github.com/AidnAS/platform/pull/12/")
	if err != nil {
		t.Fatal(err)
	}
	if len(output) != 1 || output[0].Title != "Wanted" {
		t.Fatalf("output = %#v", output)
	}
	wantQuery := "repo:AidnAS/platform is:pr 12 in:number"
	if !reflect.DeepEqual(source.searches, []string{wantQuery}) {
		t.Fatalf("searches = %#v", source.searches)
	}
}

func TestAttachGroupIssuesKeepsMostSpecificReferencedIssue(t *testing.T) {
	childURL := "https://github.com/AidnAS/platform/issues/6619"
	parentURL := "https://github.com/AidnAS/platform/issues/6614"
	items := []Item{{
		Type: PullRequest, Repo: "AidnAS/observability", URL: "https://github.com/AidnAS/observability/pull/151",
		Body: "Related to AidnAS/platform#6619 and AidnAS/platform#6614.",
	}}
	source := &fakeSource{issues: map[string]GroupIssue{
		childURL:  {Title: "Reduce log volume", URL: childURL, ParentURL: parentURL},
		parentURL: {Title: "Goal: Scaling the platform", URL: parentURL},
	}}

	if err := NewService(source).attachGroupIssues(context.Background(), items); err != nil {
		t.Fatal(err)
	}
	if len(items[0].GroupIssues) != 1 || items[0].GroupIssues[0].URL != childURL {
		t.Fatalf("group issues = %#v, want only %s", items[0].GroupIssues, childURL)
	}
}

func TestAttachGroupIssuesResolvesTransitiveParents(t *testing.T) {
	childURL := "https://github.com/AidnAS/platform/issues/3"
	middleURL := "https://github.com/AidnAS/platform/issues/2"
	parentURL := "https://github.com/AidnAS/platform/issues/1"
	items := []Item{{
		Type: PullRequest, Repo: "AidnAS/platform", URL: "pr",
		Body: "Related to #3 and #1",
	}}
	source := &fakeSource{issues: map[string]GroupIssue{
		childURL:  {Title: "Child", URL: childURL, ParentURL: middleURL},
		middleURL: {Title: "Middle", URL: middleURL, ParentURL: parentURL},
		parentURL: {Title: "Parent", URL: parentURL},
	}}

	if err := NewService(source).attachGroupIssues(context.Background(), items); err != nil {
		t.Fatal(err)
	}
	if len(items[0].GroupIssues) != 1 || items[0].GroupIssues[0].URL != childURL {
		t.Fatalf("group issues = %#v, want only %s", items[0].GroupIssues, childURL)
	}
	if !reflect.DeepEqual(source.issueURLs, []string{childURL, parentURL, middleURL}) {
		t.Fatalf("resolved issue URLs = %#v", source.issueURLs)
	}
}

func TestMostSpecificGroupIssuesKeepsUnrelatedIssues(t *testing.T) {
	firstURL := "https://github.com/AidnAS/platform/issues/1"
	secondURL := "https://github.com/AidnAS/platform/issues/2"
	issues := map[string]GroupIssue{
		firstURL:  {Title: "First", URL: firstURL},
		secondURL: {Title: "Second", URL: secondURL},
	}
	relations := []Relation{{URL: firstURL}, {URL: secondURL}}

	got := mostSpecificGroupIssues(relations, issues)
	if len(got) != 2 || got[0].URL != firstURL || got[1].URL != secondURL {
		t.Fatalf("group issues = %#v", got)
	}
}

func TestMostSpecificGroupIssuesRetainsCycles(t *testing.T) {
	firstURL := "https://github.com/AidnAS/platform/issues/1"
	secondURL := "https://github.com/AidnAS/platform/issues/2"
	issues := map[string]GroupIssue{
		firstURL:  {Title: "First", URL: firstURL, ParentURL: secondURL},
		secondURL: {Title: "Second", URL: secondURL, ParentURL: firstURL},
	}
	relations := []Relation{{URL: firstURL}, {URL: secondURL}}

	got := mostSpecificGroupIssues(relations, issues)
	if len(got) != 2 {
		t.Fatalf("group issues = %#v, want both cyclic references retained", got)
	}
}
