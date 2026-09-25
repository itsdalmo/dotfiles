// Package cli adapts command-line arguments and output streams to githubwork.
package cli

import (
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"path"
	"strings"
	"time"

	githubwork "github.com/itsdalmo/dotfiles/github-work"
)

const usageText = `Usage: github-work <log|todo|fetch> [options]

Commands:
  log             GitHub activity attributable to you in a time range
  todo            Open authored PRs, assigned issues, and review-requested Renovate PRs
  fetch <url>     Fetch one issue or pull request by GitHub URL

Options for log:
  --from <value>       Inclusive ISO 8601 date or date-time (default: today)
  --to <value>         Inclusive date or exclusive date-time (default: now)
  --timezone <value>   IANA timezone for date boundaries (default: Europe/Oslo)

Options for log and todo:
  --markdown           Emit a markdown list for daily notes instead of JSON;
                       todo items are unchecked tasks

All commands emit the same compact JSON union of issues, pull requests, and
deterministic groups, with relevant activity and extracted relations.`

type workService interface {
	Log(context.Context, time.Time, time.Time) ([]githubwork.OutputItem, error)
	Todo(context.Context) ([]githubwork.OutputItem, error)
	Fetch(context.Context, string) ([]githubwork.OutputItem, error)
}

// Run executes args and writes help text, markdown, or JSON to stdout.
func Run(ctx context.Context, args []string, service workService, stdout, stderr io.Writer) error {
	if len(args) == 0 || args[0] == "-h" || args[0] == "--help" {
		_, err := fmt.Fprintln(stdout, usageText)
		return err
	}

	var (
		output []githubwork.OutputItem
		err    error
		// markdownPrefix is the list marker for markdown output; empty means JSON.
		markdownPrefix string
	)
	switch args[0] {
	case "log":
		window, markdown, parseErr := parseLogFlags(args[1:], stderr, time.Now())
		if parseErr != nil {
			return parseErr
		}
		if markdown {
			markdownPrefix = "- "
		}
		output, err = service.Log(ctx, window.from, window.to)
	case "todo":
		switch {
		case len(args) == 1:
		case len(args) == 2 && args[1] == "--markdown":
			markdownPrefix = "- [ ] "
		default:
			return errors.New("todo accepts only --markdown")
		}
		output, err = service.Todo(ctx)
	case "fetch":
		if len(args) != 2 {
			return errors.New("fetch requires one GitHub issue or pull-request URL")
		}
		output, err = service.Fetch(ctx, args[1])
	default:
		return fmt.Errorf("unknown command %q", args[0])
	}
	if err != nil {
		return err
	}
	if markdownPrefix != "" {
		return writeMarkdown(stdout, output, markdownPrefix)
	}

	encoder := json.NewEncoder(stdout)
	encoder.SetEscapeHTML(false)
	return encoder.Encode(output)
}

// writeMarkdown renders items as a list, indenting group children by two spaces.
func writeMarkdown(w io.Writer, items []githubwork.OutputItem, prefix string) error {
	var b strings.Builder
	for _, item := range items {
		b.WriteString(prefix + markdownEntry(item) + "\n")
		for _, child := range item.Items {
			b.WriteString("  " + prefix + markdownEntry(child) + "\n")
		}
	}
	_, err := io.WriteString(w, b.String())
	return err
}

func markdownEntry(item githubwork.OutputItem) string {
	if item.URL == "" {
		return item.Title
	}
	return fmt.Sprintf("%s: [#%s](%s)", item.Title, path.Base(item.URL), item.URL)
}

type interval struct {
	from time.Time
	to   time.Time
}

func parseLogFlags(args []string, stderr io.Writer, now time.Time) (interval, bool, error) {
	flags := flag.NewFlagSet("log", flag.ContinueOnError)
	flags.SetOutput(stderr)
	var fromValue, toValue, timezone string
	var markdown bool
	flags.StringVar(&fromValue, "from", "", "inclusive start")
	flags.StringVar(&toValue, "to", "", "exclusive end")
	flags.StringVar(&timezone, "timezone", "Europe/Oslo", "IANA timezone")
	flags.BoolVar(&markdown, "markdown", false, "emit a markdown list")
	if err := flags.Parse(args); err != nil {
		return interval{}, false, err
	}
	if flags.NArg() != 0 {
		return interval{}, false, errors.New("unexpected positional argument for log")
	}
	window, err := resolveInterval(fromValue, toValue, timezone, now)
	return window, markdown, err
}

func resolveInterval(fromValue, toValue, timezone string, now time.Time) (interval, error) {
	location, err := time.LoadLocation(timezone)
	if err != nil {
		return interval{}, fmt.Errorf("invalid timezone %q: %w", timezone, err)
	}
	now = now.In(location)
	from, _, err := parseBoundary(fromValue, location, time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, location))
	if err != nil {
		return interval{}, fmt.Errorf("invalid --from: %w", err)
	}
	to, dateOnly, err := parseBoundary(toValue, location, now)
	if err != nil {
		return interval{}, fmt.Errorf("invalid --to: %w", err)
	}
	if toValue != "" && dateOnly {
		to = to.AddDate(0, 0, 1)
	}
	if !from.Before(to) {
		return interval{}, errors.New("--from must be before --to")
	}
	return interval{from: from, to: to}, nil
}

func parseBoundary(value string, location *time.Location, fallback time.Time) (time.Time, bool, error) {
	if value == "" {
		return fallback, false, nil
	}
	if len(value) == len(time.DateOnly) {
		parsed, err := time.ParseInLocation(time.DateOnly, value, location)
		return parsed, true, err
	}
	parsed, err := time.Parse(time.RFC3339, value)
	return parsed, false, err
}
