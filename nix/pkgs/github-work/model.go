// Package githubwork provides GitHub work discovery and reduction.
package githubwork

import "time"

// Item is the normalized internal representation of an issue or pull request.
type Item struct {
	Type           Kind
	Repo           string
	Number         int
	Title          string
	State          string
	StateReason    string
	URL            string
	Author         string
	Labels         []string
	Draft          bool
	Created        time.Time
	Body           string
	Reviews        []Review
	ReviewComments []ReviewComment
	Timeline       []Event
	GroupIssues    []GroupIssue
	Relations      []Relation

	renovate bool
}

// GroupIssue contains the issue context needed to build a workstream group.
type GroupIssue struct {
	Title       string
	Body        string
	State       string
	StateReason string
	URL         string
	ParentURL   string
}

// Review records a pull-request review and an optional later edit.
type Review struct {
	At      time.Time  `json:"at"`
	Updated *time.Time `json:"updated,omitempty"`
	Author  string     `json:"author"`
	State   string     `json:"state"`
	Body    string     `json:"body,omitempty"`
	URL     string     `json:"url,omitempty"`
}

// ReviewComment records a pull-request review comment and an optional edit.
type ReviewComment struct {
	At      time.Time  `json:"at"`
	Updated *time.Time `json:"updated,omitempty"`
	Author  string     `json:"author"`
	Body    string     `json:"body,omitempty"`
	URL     string     `json:"url,omitempty"`
}

// Event is a normalized GitHub timeline event.
type Event struct {
	At          *time.Time `json:"at,omitempty"`
	Kind        string     `json:"event"`
	Actor       string     `json:"actor,omitempty"`
	StateReason string     `json:"stateReason,omitempty"`
	State       string     `json:"state,omitempty"`
	Message     string     `json:"message,omitempty"`
	Body        string     `json:"body,omitempty"`
	URL         string     `json:"url,omitempty"`
}

// Relation records an issue reference extracted from a pull-request body.
type Relation struct {
	URL     string `json:"url"`
	Kind    string `json:"kind"`
	Source  string `json:"source"`
	Context string `json:"context,omitempty"`
}

// Summary describes the time span and outcome of relevant activity.
type Summary struct {
	FirstActivityAt *time.Time `json:"firstActivityAt,omitempty"`
	LastActivityAt  *time.Time `json:"lastActivityAt,omitempty"`
	Outcome         string     `json:"outcome,omitempty"`
	ReviewOnly      bool       `json:"reviewOnly"`
}

// Activity is a user-attributable action included in public output.
type Activity struct {
	At          time.Time `json:"at"`
	Type        string    `json:"type"`
	Actor       string    `json:"actor,omitempty"`
	State       string    `json:"state,omitempty"`
	StateReason string    `json:"stateReason,omitempty"`
	Body        string    `json:"body,omitempty"`
	Message     string    `json:"message,omitempty"`
	URL         string    `json:"url,omitempty"`
}

// OutputItem is an issue, pull request, or flat group in the JSON result.
type OutputItem struct {
	Type        string       `json:"type"`
	Kind        string       `json:"kind,omitempty"`
	Repo        string       `json:"repo,omitempty"`
	Number      int          `json:"number,omitempty"`
	Title       string       `json:"title"`
	Body        string       `json:"body,omitempty"`
	State       string       `json:"state,omitempty"`
	StateReason string       `json:"stateReason,omitempty"`
	URL         string       `json:"url,omitempty"`
	Author      string       `json:"author,omitempty"`
	Draft       bool         `json:"draft,omitempty"`
	Relations   []Relation   `json:"relations,omitempty"`
	Activity    []Activity   `json:"activity,omitempty"`
	Summary     *Summary     `json:"summary,omitempty"`
	Items       []OutputItem `json:"items,omitempty"`

	renovate    bool
	groupIssues []GroupIssue
}

type interval struct {
	From time.Time
	To   time.Time
}
