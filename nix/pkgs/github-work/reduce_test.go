package githubwork

import (
	"encoding/json"
	"strings"
	"testing"
	"time"
)

func instant(value string) time.Time {
	result, err := time.Parse(time.RFC3339, value)
	if err != nil {
		panic(err)
	}
	return result
}

func pointer(value time.Time) *time.Time { return &value }

func TestSummarizeUsesAttributableActivityInRange(t *testing.T) {
	window := interval{From: instant("2026-08-10T00:00:00+02:00"), To: instant("2026-08-11T00:00:00+02:00")}
	item := Item{
		Type: "pr", Author: "dalmo", Created: instant("2026-08-09T12:00:00Z"),
		Timeline: []Event{
			{At: pointer(instant("2026-08-10T08:00:00Z")), Kind: "issue_comment", Actor: "somebody-else"},
			{At: pointer(instant("2026-08-10T09:00:00Z")), Kind: "commit"},
			{At: pointer(instant("2026-08-10T10:00:00Z")), Kind: "merged", Actor: "dalmo"},
		},
	}

	output := logOutput([]Item{item}, "dalmo", window)
	if len(output) != 1 {
		t.Fatalf("got %d items, want one", len(output))
	}
	summary := output[0].Summary
	if summary.Outcome != "merged" {
		t.Fatalf("outcome = %q, want merged", summary.Outcome)
	}
	if summary.FirstActivityAt == nil || !summary.FirstActivityAt.Equal(instant("2026-08-10T09:00:00Z")) {
		t.Fatalf("first activity = %v", summary.FirstActivityAt)
	}
	if summary.ReviewOnly {
		t.Fatal("expected non-review activity")
	}
}

func TestSummarizeCloseThenReopen(t *testing.T) {
	window := interval{From: instant("2026-08-10T00:00:00Z"), To: instant("2026-08-11T00:00:00Z")}
	item := Item{Type: "pr", Author: "dalmo", Timeline: []Event{
		{At: pointer(instant("2026-08-10T09:00:00Z")), Kind: "closed", Actor: "dalmo"},
		{At: pointer(instant("2026-08-10T10:00:00Z")), Kind: "reopened", Actor: "dalmo"},
	}}

	summary := logOutput([]Item{item}, "dalmo", window)[0].Summary
	if summary.Outcome != "reopened" {
		t.Fatalf("outcome = %q, want reopened", summary.Outcome)
	}
}

func TestSummarizeMergeIsNotOverwrittenByPairedCloseEvent(t *testing.T) {
	window := interval{From: instant("2026-08-10T00:00:00Z"), To: instant("2026-08-11T00:00:00Z")}
	item := Item{Type: "pr", Author: "cozy-janitor", Timeline: []Event{
		{At: pointer(instant("2026-08-10T09:00:00Z")), Kind: "merged", Actor: "dalmo"},
		{At: pointer(instant("2026-08-10T09:00:00Z")), Kind: "closed", Actor: "dalmo"},
	}}

	summary := logOutput([]Item{item}, "dalmo", window)[0].Items[0].Summary
	if summary.Outcome != "merged" {
		t.Fatalf("outcome = %q, want merged", summary.Outcome)
	}
}

func TestSummarizeReviewOnly(t *testing.T) {
	window := interval{From: instant("2026-08-10T00:00:00Z"), To: instant("2026-08-11T00:00:00Z")}
	item := Item{Type: "pr", Reviews: []Review{{At: instant("2026-08-10T09:00:00Z"), Author: "dalmo", State: "approved"}}}

	output := logOutput([]Item{item}, "dalmo", window)
	if len(output) != 1 || output[0].Kind != "reviewed" || len(output[0].Items) != 1 {
		t.Fatalf("output = %#v", output)
	}
	summary := output[0].Items[0].Summary
	if summary.Outcome != "reviewed" || !summary.ReviewOnly {
		t.Fatalf("summary = %#v", summary)
	}
}

func TestEnrichDropsIncidentalSearchMatches(t *testing.T) {
	window := interval{From: instant("2026-08-10T00:00:00Z"), To: instant("2026-08-11T00:00:00Z")}
	item := Item{URL: "https://github.com/AidnAS/example/issues/1", Author: "other"}
	if got := logOutput([]Item{item}, "dalmo", window); len(got) != 0 {
		t.Fatalf("got %d items, want none", len(got))
	}
}

func TestLogEligibilityMatchesSupportedCategories(t *testing.T) {
	window := interval{From: instant("2026-08-10T00:00:00Z"), To: instant("2026-08-11T00:00:00Z")}
	at := pointer(instant("2026-08-10T09:00:00Z"))
	tests := []struct {
		name string
		item Item
		want bool
	}{
		{name: "created issue", item: Item{Type: "issue", Author: "dalmo", Created: *at}, want: true},
		{name: "commented issue", item: Item{Type: "issue", Timeline: []Event{{At: at, Kind: "issue_comment", Actor: "dalmo"}}}, want: true},
		{name: "labeled issue", item: Item{Type: "issue", Timeline: []Event{{At: at, Kind: "labeled", Actor: "dalmo"}}}, want: false},
		{name: "authored PR", item: Item{Type: "pr", Author: "dalmo", Timeline: []Event{{At: at, Kind: "commit"}}}, want: true},
		{name: "merged Renovate PR", item: Item{Type: "pr", Author: "cozy-janitor", Timeline: []Event{{At: at, Kind: "merged", Actor: "dalmo"}}}, want: true},
		{name: "commented Renovate PR", item: Item{Type: "pr", Author: "cozy-janitor", Timeline: []Event{{At: at, Kind: "issue_comment", Actor: "dalmo"}}}, want: false},
		{name: "reviewed PR", item: Item{Type: "pr", Author: "other", Reviews: []Review{{At: *at, Author: "dalmo"}}}, want: true},
		{name: "commented PR", item: Item{Type: "pr", Author: "other", Timeline: []Event{{At: at, Kind: "issue_comment", Actor: "dalmo"}}}, want: false},
		{name: "merged non-Renovate PR", item: Item{Type: "pr", Author: "other", Timeline: []Event{{At: at, Kind: "merged", Actor: "dalmo"}}}, want: false},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			got := len(logOutput([]Item{test.item}, "dalmo", window)) == 1
			if got != test.want {
				t.Fatalf("eligible = %v, want %v", got, test.want)
			}
		})
	}
}

func TestSummarizeWithoutWindowReportsCurrentOutcome(t *testing.T) {
	item := Item{Type: "issue", State: "closed", StateReason: "not_planned"}
	summary := todoOutput([]Item{item})[0].Summary
	if summary.Outcome != "not_planned" {
		t.Fatalf("outcome = %q, want not_planned", summary.Outcome)
	}
}

func TestRenovateClassificationUsesAppLoginAndLabel(t *testing.T) {
	for _, item := range []Item{
		{Author: "cozy-janitor"},
		{Labels: []string{"renovate"}},
	} {
		output := todoOutput([]Item{item})
		if len(output) != 1 || output[0].Type != "group" || output[0].Kind != "renovate" {
			t.Fatalf("item was not classified as Renovate: %#v", item)
		}
	}
}

func TestCompactOutputOmitsRawCollectionsAndKeepsRelevantActivity(t *testing.T) {
	window := interval{From: instant("2026-08-10T00:00:00Z"), To: instant("2026-08-11T00:00:00Z")}
	at := pointer(instant("2026-08-10T09:00:00Z"))
	item := Item{
		Type: "issue", Repo: "AidnAS/example", Number: 1, Title: "Example",
		Body: "Part of #2", URL: "https://github.com/AidnAS/example/issues/1",
		Timeline: []Event{
			{At: at, Kind: "issue_comment", Actor: "dalmo", Body: "Worked on this"},
			{At: at, Kind: "labeled", Actor: "dalmo"},
		},
	}
	output := logOutput([]Item{item}, "dalmo", window)
	if len(output) != 1 || len(output[0].Activity) != 1 {
		t.Fatalf("output = %#v", output)
	}
	if output[0].Activity[0].Type != "issue_comment" || output[0].Body != item.Body || len(output[0].Relations) != 0 {
		t.Fatalf("compact output lost required context: %#v", output[0])
	}
}

func TestFetchUsesSharedOutputModelWithAvailableRelevantActivity(t *testing.T) {
	at := pointer(instant("2026-08-10T09:00:00Z"))
	item := Item{Type: "pr", Author: "dalmo", State: "open", Timeline: []Event{{At: at, Kind: "commit", Message: "change", URL: "commit-url"}}}
	output := fetchOutput([]Item{item}, "dalmo")
	if len(output) != 1 || len(output[0].Activity) != 1 || output[0].Activity[0].Message != "change" {
		t.Fatalf("output = %#v", output)
	}
}

func TestTodoUsesSharedOutputModelWithoutActivity(t *testing.T) {
	item := Item{Type: "issue", State: "open", Timeline: []Event{{At: pointer(instant("2026-08-10T09:00:00Z")), Kind: "issue_comment", Actor: "dalmo"}}}
	output := todoOutput([]Item{item})
	if len(output) != 1 || len(output[0].Activity) != 0 || output[0].Type != "issue" {
		t.Fatalf("output = %#v", output)
	}
	encoded, err := json.Marshal(output)
	if err != nil {
		t.Fatal(err)
	}
	if strings.Contains(string(encoded), "category") {
		t.Fatalf("public output contains internal category: %s", encoded)
	}
}

func TestCompactOutputOmitsRenovateBodyButKeepsExtractedRelations(t *testing.T) {
	item := Item{
		Type: "pr", Author: "cozy-janitor",
		Repo: "AidnAS/example", URL: "https://github.com/AidnAS/example/pull/1",
		Body: "Part of #2\n\nLarge generated dependency description",
	}
	output := todoOutput([]Item{item})
	if output[0].Type != "group" || len(output[0].Items) != 1 || output[0].Items[0].Body != "" || len(output[0].Items[0].Relations) != 1 {
		t.Fatalf("output = %#v", output[0])
	}
}

func TestRenovateItemsFormCompleteGroup(t *testing.T) {
	items := []Item{
		{Type: "pr", renovate: true, Repo: "AidnAS/a", Number: 1, Title: "Update A", URL: "https://github.com/AidnAS/a/pull/1"},
		{Type: "pr", renovate: true, Repo: "AidnAS/b", Number: 2, Title: "Update B", URL: "https://github.com/AidnAS/b/pull/2"},
	}
	output := todoOutput(items)
	if len(output) != 1 || output[0].Type != "group" || output[0].Title != "Renovate PRs (2 total)" || len(output[0].Items) != 2 {
		t.Fatalf("output = %#v", output)
	}
}

func TestReviewOnlyPRsFormCompleteGroupBeforeOtherGrouping(t *testing.T) {
	window := interval{From: instant("2026-08-10T00:00:00Z"), To: instant("2026-08-11T00:00:00Z")}
	reviewedAt := instant("2026-08-10T09:00:00Z")
	items := []Item{
		{
			Type: "pr", Title: "Workstream review", URL: "pr-1",
			Reviews:     []Review{{At: reviewedAt, Author: "dalmo"}},
			GroupIssues: []GroupIssue{{Title: "Parent issue", URL: "issue", State: "open"}},
		},
		{
			Type: "pr", Title: "Renovate review", URL: "pr-2", renovate: true,
			Reviews: []Review{{At: reviewedAt, Author: "dalmo"}},
		},
	}

	output := logOutput(items, "dalmo", window)
	if len(output) != 1 || output[0].Type != "group" || output[0].Kind != "reviewed" || output[0].Title != "Reviewed PRs (2 total)" || len(output[0].Items) != 2 {
		t.Fatalf("output = %#v", output)
	}
}

func TestBodyReferenceGroupsPRUnderIssue(t *testing.T) {
	parentURL := "https://github.com/AidnAS/platform/issues/10"
	items := []Item{
		{Type: "issue", Repo: "AidnAS/platform", Number: 10, Title: "Parent work", URL: parentURL},
		{Type: "pr", Repo: "AidnAS/a", Number: 1, Title: "Child A", Body: "Part of " + parentURL, URL: "https://github.com/AidnAS/a/pull/1", GroupIssues: []GroupIssue{{Title: "Parent work", URL: parentURL, State: "open"}}},
	}
	output := todoOutput(items)
	if len(output) != 1 || output[0].Type != "group" || output[0].Kind != "workstream" || output[0].Title != "Parent work" || output[0].URL != parentURL || len(output[0].Items) != 1 {
		t.Fatalf("output = %#v", output)
	}
}

func TestUnresolvedBodyReferenceDoesNotGroup(t *testing.T) {
	parentURL := "https://github.com/AidnAS/platform/issues/10"
	items := []Item{
		{Type: "issue", Title: "Parent", URL: parentURL},
		{Type: "pr", Repo: "AidnAS/app", Title: "Child", URL: "a", Body: "Part of " + parentURL},
	}
	output := todoOutput(items)
	if len(output) != 2 {
		t.Fatalf("got %d entries, want two ungrouped: %#v", len(output), output)
	}
}

func TestPRReferencingMultipleIssuesAppearsInEachGroup(t *testing.T) {
	pr := Item{
		Type: "pr", Repo: "AidnAS/app", Number: 7, Title: "Fix both",
		URL: "https://github.com/AidnAS/app/pull/7",
		GroupIssues: []GroupIssue{
			{Title: "First issue", URL: "https://github.com/AidnAS/app/issues/1", State: "open"},
			{Title: "Second issue", URL: "https://github.com/AidnAS/app/issues/2", State: "open"},
		},
	}
	output := todoOutput([]Item{pr})
	if len(output) != 2 {
		t.Fatalf("got %d groups, want two: %#v", len(output), output)
	}
	for _, group := range output {
		if group.Type != "group" || group.Kind != "workstream" || len(group.Items) != 1 || group.Items[0].URL != pr.URL {
			t.Fatalf("group = %#v", group)
		}
	}
}

func TestParentIssueIsAbsorbedIntoWorkstreamGroup(t *testing.T) {
	parentURL := "https://github.com/AidnAS/app/issues/1"
	parent := Item{Type: "issue", Title: "Parent", Body: "Details", URL: parentURL, State: "open"}
	pr := Item{Type: "pr", Title: "Fix", URL: "pr", GroupIssues: []GroupIssue{{Title: "Parent", URL: parentURL, State: "open"}}}
	output := todoOutput([]Item{parent, pr})
	if len(output) != 1 || output[0].Body != "Details" || len(output[0].Items) != 1 {
		t.Fatalf("output = %#v", output)
	}
}

func TestRenovateGroupingTakesPrecedenceOverBodyReference(t *testing.T) {
	pr := Item{
		Type: "pr", renovate: true, Author: "cozy-janitor", Title: "Update dependency", URL: "pr",
		GroupIssues: []GroupIssue{{Title: "Issue", URL: "issue", State: "open"}},
	}
	output := todoOutput([]Item{pr})
	if len(output) != 1 || output[0].Kind != "renovate" || len(output[0].Items) != 1 {
		t.Fatalf("output = %#v", output)
	}
}

func TestFetchDoesNotWrapSingleRenovateItemInGroup(t *testing.T) {
	item := Item{Type: "pr", renovate: true, Author: "cozy-janitor", Title: "Update dependency"}
	output := fetchOutput([]Item{item}, "dalmo")
	if len(output) != 1 || output[0].Type != "pr" {
		t.Fatalf("output = %#v", output)
	}
}

func TestOutputJSONFormat(t *testing.T) {
	output := fetchOutput([]Item{{
		Type: "issue", Repo: "AidnAS/example", Number: 7, Title: "Example",
		State: "open", URL: "https://github.com/AidnAS/example/issues/7",
	}}, "dalmo")
	encoded, err := json.Marshal(output)
	if err != nil {
		t.Fatal(err)
	}
	want := `[{"type":"issue","repo":"AidnAS/example","number":7,"title":"Example","state":"open","url":"https://github.com/AidnAS/example/issues/7","summary":{"outcome":"active","reviewOnly":false}}]`
	if string(encoded) != want {
		t.Fatalf("JSON = %s\nwant = %s", encoded, want)
	}
}
