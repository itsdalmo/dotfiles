package githubwork

import (
	"context"
	"fmt"
	"sort"
	"strings"
	"time"
)

const organization = "AidnAS"

// Source supplies GitHub data to Service.
type Source interface {
	AuthenticatedUser(context.Context) (string, error)
	Search(context.Context, string) ([]Item, error)
	// ResolveIssues returns resolved issues keyed by the exact corresponding
	// values from urls. Resolved issue URLs may use GitHub's canonical casing.
	ResolveIssues(context.Context, []string) (map[string]GroupIssue, error)
}

// Service discovers work and reduces it to the public output model.
type Service struct {
	source Source
	now    func() time.Time
}

// NewService returns a Service backed by source.
func NewService(source Source) *Service {
	return &Service{source: source, now: time.Now}
}

// Log returns attributable activity in the half-open interval [from, to).
func (s *Service) Log(ctx context.Context, from, to time.Time) ([]OutputItem, error) {
	user, err := s.source.AuthenticatedUser(ctx)
	if err != nil {
		return nil, fmt.Errorf("get authenticated user: %w", err)
	}

	queryRange := from.Format(time.RFC3339) + ".." + to.Add(-time.Nanosecond).Format(time.RFC3339)
	var items []Item
	for _, kind := range []string{"pr", "issue"} {
		found, err := s.source.Search(ctx, "org:"+organization+" involves:@me is:"+kind+" updated:"+queryRange)
		if err != nil {
			return nil, fmt.Errorf("search log %s: %w", kind, err)
		}
		items = append(items, found...)
	}
	if err := s.attachGroupIssues(ctx, items); err != nil {
		return nil, fmt.Errorf("attach related issues: %w", err)
	}
	return logOutput(items, user, interval{From: from, To: to}), nil
}

// Todo returns the current open work inventory.
func (s *Service) Todo(ctx context.Context) ([]OutputItem, error) {
	var items []Item
	for _, query := range todoQueries(s.now()) {
		found, err := s.source.Search(ctx, query.search)
		if err != nil {
			return nil, fmt.Errorf("search todo work: %w", err)
		}
		for i := range found {
			found[i].renovate = query.renovate
		}
		items = append(items, found...)
	}
	if err := s.attachGroupIssues(ctx, items); err != nil {
		return nil, fmt.Errorf("attach related issues: %w", err)
	}
	return todoOutput(items), nil
}

// Fetch returns the issue or pull request identified by value.
func (s *Service) Fetch(ctx context.Context, value string) ([]OutputItem, error) {
	reference, err := ParseURL(value)
	if err != nil {
		return nil, err
	}
	user, err := s.source.AuthenticatedUser(ctx)
	if err != nil {
		return nil, fmt.Errorf("get authenticated user: %w", err)
	}

	query := fmt.Sprintf("repo:%s/%s is:%s %d in:number", reference.Owner, reference.Repository, reference.Kind, reference.Number)
	items, err := s.source.Search(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("search for %s: %w", value, err)
	}
	want := strings.TrimSuffix(value, "/")
	matched := items[:0]
	for _, item := range items {
		if strings.TrimSuffix(item.URL, "/") == want {
			matched = append(matched, item)
		}
	}
	return fetchOutput(matched, user), nil
}

func (s *Service) attachGroupIssues(ctx context.Context, items []Item) error {
	var urls []string
	seen := make(map[string]bool)
	for i := range items {
		if items[i].Type != PullRequest || isRenovate(items[i]) {
			continue
		}
		items[i].Relations = extractRelations(items[i])
		for _, relation := range items[i].Relations {
			if !seen[relation.URL] {
				seen[relation.URL] = true
				urls = append(urls, relation.URL)
			}
		}
	}
	if len(urls) == 0 {
		return nil
	}

	issues, err := s.source.ResolveIssues(ctx, urls)
	if err != nil {
		return err
	}
	if err := s.resolveIssueAncestors(ctx, issues); err != nil {
		return err
	}
	for i := range items {
		items[i].GroupIssues = mostSpecificGroupIssues(items[i].Relations, issues)
	}
	return nil
}

func (s *Service) resolveIssueAncestors(ctx context.Context, issues map[string]GroupIssue) error {
	requested := make(map[string]bool)
	for url := range issues {
		requested[normalizeURL(url)] = true
	}
	for {
		var urls []string
		for _, issue := range issues {
			key := normalizeURL(issue.ParentURL)
			if key == "" || requested[key] {
				continue
			}
			requested[key] = true
			urls = append(urls, issue.ParentURL)
		}
		if len(urls) == 0 {
			return nil
		}
		sort.Strings(urls)
		parents, err := s.source.ResolveIssues(ctx, urls)
		if err != nil {
			return err
		}
		for url, issue := range parents {
			issues[url] = issue
		}
	}
}

func mostSpecificGroupIssues(relations []Relation, issues map[string]GroupIssue) []GroupIssue {
	index := make(map[string]GroupIssue)
	for requestedURL, issue := range issues {
		index[normalizeURL(requestedURL)] = issue
		index[normalizeURL(issue.URL)] = issue
	}

	type candidate struct {
		issue GroupIssue
		url   string
	}
	var candidates []candidate
	seen := make(map[string]bool)
	for _, relation := range relations {
		issue, ok := index[normalizeURL(relation.URL)]
		if !ok {
			continue
		}
		url := issue.URL
		if url == "" {
			url = relation.URL
		}
		key := normalizeURL(url)
		if seen[key] {
			continue
		}
		seen[key] = true
		candidates = append(candidates, candidate{issue: issue, url: key})
	}

	redundant := make(map[string]bool)
	for _, descendant := range candidates {
		ancestors, valid := issueAncestors(descendant.url, index)
		if !valid {
			continue
		}
		for _, possibleAncestor := range candidates {
			if possibleAncestor.url != descendant.url && ancestors[possibleAncestor.url] {
				redundant[possibleAncestor.url] = true
			}
		}
	}

	result := make([]GroupIssue, 0, len(candidates))
	for _, candidate := range candidates {
		if !redundant[candidate.url] {
			result = append(result, candidate.issue)
		}
	}
	return result
}

func issueAncestors(url string, issues map[string]GroupIssue) (map[string]bool, bool) {
	ancestors := make(map[string]bool)
	seen := map[string]bool{url: true}
	for {
		issue, ok := issues[url]
		if !ok || issue.ParentURL == "" {
			return ancestors, true
		}
		parent := normalizeURL(issue.ParentURL)
		if seen[parent] {
			return nil, false
		}
		seen[parent] = true
		ancestors[parent] = true
		url = parent
	}
}

func normalizeURL(url string) string {
	return strings.ToLower(strings.TrimSuffix(url, "/"))
}

type todoQuery struct {
	search   string
	renovate bool
}

func todoQueries(now time.Time) []todoQuery {
	renovateCutoff := now.Add(-30 * 24 * time.Hour).UTC().Format(time.RFC3339)
	return []todoQuery{
		{search: "org:" + organization + " is:pr is:open author:@me"},
		{search: "org:" + organization + " is:issue is:open assignee:@me"},
		{search: `org:` + organization + ` archived:false is:pr is:open author:"cozy-janitor[bot]" review-requested:@me updated:>=` + renovateCutoff, renovate: true},
	}
}
