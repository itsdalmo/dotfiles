package githubwork

import (
	"fmt"
	"strconv"
	"strings"
)

// Kind identifies a GitHub issue or pull request.
type Kind string

const (
	Issue       Kind = "issue"
	PullRequest Kind = "pr"
)

// Reference is the identity encoded in a GitHub issue or pull-request URL.
type Reference struct {
	Owner      string
	Repository string
	Kind       Kind
	Number     int
}

// ParseURL parses a full GitHub issue or pull-request URL.
func ParseURL(value string) (Reference, error) {
	trimmed := strings.TrimSuffix(value, "/")
	matches := fullGitHubRef.FindStringSubmatch(trimmed)
	if len(matches) == 0 || matches[0] != trimmed {
		return Reference{}, fmt.Errorf("invalid GitHub issue or pull-request URL %q", value)
	}

	number, err := strconv.Atoi(matches[4])
	if err != nil {
		return Reference{}, fmt.Errorf("invalid GitHub issue or pull-request URL %q: %w", value, err)
	}
	kind := Issue
	if matches[3] == "pull" {
		kind = PullRequest
	}
	return Reference{Owner: matches[1], Repository: matches[2], Kind: kind, Number: number}, nil
}
