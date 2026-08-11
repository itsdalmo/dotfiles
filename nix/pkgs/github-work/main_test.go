package githubwork

import (
	"strings"
	"testing"
)

func TestTodoRenovateQueryUsesRollingThirtyDayCutoff(t *testing.T) {
	queries := todoQueries(instant("2026-08-13T12:00:00+02:00"))
	if got := queries[2].search; !strings.Contains(got, "updated:>=2026-07-14T10:00:00Z") {
		t.Fatalf("Renovate query = %q", got)
	}
	if strings.Contains(queries[0].search, "updated:") || strings.Contains(queries[1].search, "updated:") {
		t.Fatal("personal TODO queries must not have an update cutoff")
	}
	if !queries[2].renovate {
		t.Fatal("Renovate query must classify its results")
	}
	if !strings.Contains(queries[2].search, "review-requested:@me") {
		t.Fatalf("Renovate query must require a review request: %q", queries[2].search)
	}
}

func TestParseGitHubURL(t *testing.T) {
	reference, err := ParseURL("https://github.com/AidnAS/platform/pull/123")
	if err != nil {
		t.Fatal(err)
	}
	if reference.Owner != "AidnAS" || reference.Repository != "platform" || reference.Kind != PullRequest || reference.Number != 123 {
		t.Fatalf("got %#v", reference)
	}
}
