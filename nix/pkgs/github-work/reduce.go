package githubwork

import (
	"fmt"
	"sort"
	"strings"
	"time"
)

func logOutput(items []Item, user string, window interval) []OutputItem {
	return groupOutput(project(items, projection{
		user:            user,
		window:          &window,
		includeActivity: true,
		requireActivity: true,
	}))
}

func todoOutput(items []Item) []OutputItem {
	return groupOutput(project(items, projection{}))
}

func fetchOutput(items []Item, user string) []OutputItem {
	return project(items, projection{user: user, includeActivity: true})
}

type projection struct {
	user            string
	window          *interval
	includeActivity bool
	requireActivity bool
}

func project(items []Item, options projection) []OutputItem {
	result := make([]OutputItem, 0, len(items))
	seen := make(map[string]bool)
	for _, item := range items {
		if seen[item.URL] {
			continue
		}
		seen[item.URL] = true

		var activities []Activity
		if options.includeActivity {
			activities = relevantActivities(item, options.user, options.window)
		}
		if options.requireActivity && len(activities) == 0 {
			continue
		}

		summary := summarize(item, activities)
		body := item.Body
		if isRenovate(item) {
			body = ""
		}
		result = append(result, OutputItem{
			Type:        string(item.Type),
			Repo:        item.Repo,
			Number:      item.Number,
			Title:       item.Title,
			Body:        body,
			State:       item.State,
			StateReason: item.StateReason,
			URL:         item.URL,
			Author:      item.Author,
			Draft:       item.Draft,
			Relations:   extractRelations(item),
			Activity:    activities,
			Summary:     &summary,
			renovate:    isRenovate(item),
			groupIssues: item.GroupIssues,
		})
	}
	sort.SliceStable(result, func(i, j int) bool {
		if len(result[i].Activity) > 0 && len(result[j].Activity) > 0 {
			return result[i].Activity[0].At.Before(result[j].Activity[0].At)
		}
		return result[i].URL < result[j].URL
	})
	return result
}

func groupOutput(items []OutputItem) []OutputItem {
	grouped := make([]OutputItem, 0, len(items))
	remaining := make([]OutputItem, 0, len(items))
	var reviewed []OutputItem
	var renovate []OutputItem
	for _, item := range items {
		if item.Summary != nil && item.Summary.ReviewOnly {
			reviewed = append(reviewed, item)
		} else if item.renovate {
			renovate = append(renovate, item)
		} else {
			remaining = append(remaining, item)
		}
	}
	if len(reviewed) > 0 {
		grouped = append(grouped, OutputItem{
			Type: "group", Kind: "reviewed",
			Title: fmt.Sprintf("Reviewed PRs (%d total)", len(reviewed)),
			Items: reviewed,
		})
	}
	if len(renovate) > 0 {
		grouped = append(grouped, OutputItem{
			Type: "group", Kind: "renovate",
			Title: fmt.Sprintf("Renovate PRs (%d total)", len(renovate)),
			Items: renovate,
		})
	}

	parents := make(map[string]int)
	for i, item := range remaining {
		if item.Type == "issue" {
			parents[item.URL] = i
		}
	}
	groupIndexes := make(map[string]int)
	claimed := make(map[int]bool)
	for childIndex, item := range remaining {
		if item.Type != "pr" || len(item.groupIssues) == 0 {
			continue
		}
		for _, issue := range item.groupIssues {
			groupIndex, ok := groupIndexes[issue.URL]
			if !ok {
				summary := summarizeGroupIssue(issue)
				grouped = append(grouped, OutputItem{
					Type: "group", Kind: "workstream", Title: issue.Title,
					Body: issue.Body, URL: issue.URL, Summary: &summary,
				})
				groupIndex = len(grouped) - 1
				groupIndexes[issue.URL] = groupIndex
			}
			grouped[groupIndex].Items = append(grouped[groupIndex].Items, item)
			claimed[childIndex] = true
			if parentIndex, present := parents[issue.URL]; present {
				parent := remaining[parentIndex]
				grouped[groupIndex].Body = parent.Body
				grouped[groupIndex].Relations = parent.Relations
				grouped[groupIndex].Activity = parent.Activity
				grouped[groupIndex].Summary = parent.Summary
				claimed[parentIndex] = true
			}
		}
	}
	for i, item := range remaining {
		if !claimed[i] {
			grouped = append(grouped, item)
		}
	}
	sortOutput(grouped)
	return grouped
}

func summarizeGroupIssue(issue GroupIssue) Summary {
	return summarize(Item{Type: "issue", State: issue.State, StateReason: issue.StateReason}, nil)
}

func sortOutput(items []OutputItem) {
	sort.SliceStable(items, func(i, j int) bool {
		iTime, iOK := earliestActivity(items[i])
		jTime, jOK := earliestActivity(items[j])
		if iOK && jOK {
			return iTime.Before(jTime)
		}
		if iOK != jOK {
			return iOK
		}
		return items[i].Title < items[j].Title
	})
}

func earliestActivity(item OutputItem) (time.Time, bool) {
	var earliest time.Time
	set := false
	consider := func(at time.Time) {
		if !set || at.Before(earliest) {
			earliest, set = at, true
		}
	}
	for _, activity := range item.Activity {
		consider(activity.At)
	}
	for _, child := range item.Items {
		if at, ok := earliestActivity(child); ok {
			consider(at)
		}
	}
	return earliest, set
}

func relevantActivities(item Item, user string, window *interval) []Activity {
	var candidates []Activity
	add := func(activity Activity) {
		if activity.At.IsZero() {
			return
		}
		if window != nil && (activity.At.Before(window.From) || !activity.At.Before(window.To)) {
			return
		}
		candidates = append(candidates, activity)
	}

	if item.Author == user {
		add(Activity{At: item.Created, Type: "opened", Actor: user, URL: item.URL})
	}
	for _, review := range item.Reviews {
		if review.Author != user {
			continue
		}
		add(Activity{At: review.At, Type: "review", Actor: user, State: review.State, Body: review.Body, URL: review.URL})
		if review.Updated != nil {
			add(Activity{At: *review.Updated, Type: "review", Actor: user, State: review.State, Body: review.Body, URL: review.URL})
		}
	}
	for _, comment := range item.ReviewComments {
		if comment.Author != user {
			continue
		}
		add(Activity{At: comment.At, Type: "review_comment", Actor: user, Body: comment.Body, URL: comment.URL})
		if comment.Updated != nil {
			add(Activity{At: *comment.Updated, Type: "review_comment", Actor: user, Body: comment.Body, URL: comment.URL})
		}
	}
	for _, event := range item.Timeline {
		if event.At == nil {
			continue
		}
		actor := event.Actor
		if event.Kind == "commit" && item.Author == user && actor == "" {
			actor = user
		}
		if actor != user {
			continue
		}
		add(Activity{At: *event.At, Type: event.Kind, Actor: actor, State: event.State, StateReason: event.StateReason, Body: event.Body, Message: event.Message, URL: event.URL})
	}

	eligible := candidates[:0]
	for _, activity := range candidates {
		switch {
		case item.Type == Issue && item.Author == user && activity.Type == "opened":
			eligible = append(eligible, activity)
		case item.Type == Issue && activity.Type == "issue_comment":
			eligible = append(eligible, activity)
		case item.Type == PullRequest && item.Author == user && authoredPRActivity(activity.Type):
			eligible = append(eligible, activity)
		case item.Type == PullRequest && (activity.Type == "review" || activity.Type == "review_comment"):
			eligible = append(eligible, activity)
		case item.Type == PullRequest && isRenovate(item) && activity.Type == "merged":
			eligible = append(eligible, activity)
		}
	}
	sort.SliceStable(eligible, func(i, j int) bool {
		return eligible[i].At.Before(eligible[j].At)
	})
	return eligible
}

func authoredPRActivity(kind string) bool {
	switch kind {
	case "opened", "issue_comment", "commit", "merged", "closed", "reopened", "ready_for_review", "convert_to_draft", "review", "review_comment":
		return true
	default:
		return false
	}
}

func summarize(item Item, activities []Activity) Summary {
	s := Summary{}
	if len(activities) == 0 {
		s.Outcome = currentOutcome(item)
		return s
	}
	first, last := activities[0].At, activities[len(activities)-1].At
	s.FirstActivityAt, s.LastActivityAt = &first, &last

	nonReview := false
	for _, a := range activities {
		if a.Type != "review" && a.Type != "review_comment" {
			nonReview = true
		}
		switch a.Type {
		case "merged":
			s.Outcome = "merged"
		case "closed":
			if s.Outcome == "merged" {
				continue
			}
			reason := a.StateReason
			if reason == "" {
				reason = item.StateReason
			}
			if item.Type == "issue" && reason == "completed" {
				s.Outcome = "completed"
			} else if item.Type == "issue" && reason == "not_planned" {
				s.Outcome = "not_planned"
			} else {
				s.Outcome = "closed"
			}
		case "reopened":
			s.Outcome = "reopened"
		}
	}
	if s.Outcome == "" {
		if !nonReview {
			s.Outcome = "reviewed"
		} else if len(activities) == 1 && activities[0].Type == "opened" {
			s.Outcome = "opened"
		} else {
			s.Outcome = "active"
		}
	}
	s.ReviewOnly = !nonReview
	return s
}

func isRenovate(item Item) bool {
	if item.renovate || item.Author == "cozy-janitor" || item.Author == "cozy-janitor[bot]" {
		return true
	}
	for _, label := range item.Labels {
		if strings.EqualFold(label, "renovate") {
			return true
		}
	}
	return false
}

func currentOutcome(item Item) string {
	switch item.State {
	case "merged":
		return "merged"
	case "closed":
		if item.Type == "issue" && item.StateReason == "completed" {
			return "completed"
		}
		if item.Type == "issue" && item.StateReason == "not_planned" {
			return "not_planned"
		}
		return "closed"
	case "open":
		return "active"
	default:
		return item.State
	}
}
