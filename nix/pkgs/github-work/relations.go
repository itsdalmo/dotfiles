package githubwork

import (
	"fmt"
	"regexp"
	"strings"
)

var (
	fullGitHubRef = regexp.MustCompile(`https://github\.com/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+)/(issues|pull)/(\d+)`)
	shortRef      = regexp.MustCompile(`(?i)(?:^|[^A-Za-z0-9_.-])(?:([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+))?#(\d+)`)
	groupLine     = regexp.MustCompile(`(?i)^\s*(close|closes|closed|fix|fixes|fixed|resolve|resolves|resolved|part\s+of|refs?|related\s+to)(?:\s*:\s*|\s+)(.+)$`)
)

func extractRelations(item Item) []Relation {
	seen := make(map[string]bool)
	var relations []Relation
	add := func(url, kind, context string) {
		key := url + "\x00" + kind
		if url == item.URL || seen[key] {
			return
		}
		seen[key] = true
		relations = append(relations, Relation{URL: url, Kind: kind, Source: "body", Context: strings.TrimSpace(context)})
	}
	if item.Type != "pr" {
		return relations
	}
	for _, line := range strings.Split(item.Body, "\n") {
		lineMatch := groupLine.FindStringSubmatch(line)
		if lineMatch == nil {
			continue
		}
		kind := relationKind(lineMatch[1])
		references := lineMatch[2]
		for _, match := range fullGitHubRef.FindAllStringSubmatch(references, -1) {
			if match[3] == "issues" {
				add(match[0], kind, line)
			}
		}
		withoutURLs := fullGitHubRef.ReplaceAllString(references, "")
		for _, match := range shortRef.FindAllStringSubmatch(withoutURLs, -1) {
			owner, repo := match[1], match[2]
			if owner == "" {
				parts := strings.SplitN(item.Repo, "/", 2)
				if len(parts) != 2 {
					continue
				}
				owner, repo = parts[0], parts[1]
			}
			add(fmt.Sprintf("https://github.com/%s/%s/issues/%s", owner, repo, match[3]), kind, line)
		}
	}
	return relations
}

func relationKind(keyword string) string {
	lower := strings.ToLower(strings.TrimSpace(keyword))
	switch {
	case strings.HasPrefix(lower, "close"), strings.HasPrefix(lower, "fix"), strings.HasPrefix(lower, "resolve"):
		return "closes"
	case lower == "part of":
		return "part_of"
	case lower == "related to":
		return "related_to"
	default:
		return "references"
	}
}
