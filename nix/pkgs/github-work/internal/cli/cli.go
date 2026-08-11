// Package cli adapts command-line arguments and JSON streams to githubwork.
package cli

import (
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
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

All commands emit the same compact JSON union of issues, pull requests, and
deterministic groups, with relevant activity and extracted relations.`

type workService interface {
	Log(context.Context, time.Time, time.Time) ([]githubwork.OutputItem, error)
	Todo(context.Context) ([]githubwork.OutputItem, error)
	Fetch(context.Context, string) ([]githubwork.OutputItem, error)
}

// Run executes args and writes either help text or JSON to stdout.
func Run(ctx context.Context, args []string, service workService, stdout, stderr io.Writer) error {
	if len(args) == 0 || args[0] == "-h" || args[0] == "--help" {
		_, err := fmt.Fprintln(stdout, usageText)
		return err
	}

	var (
		output []githubwork.OutputItem
		err    error
	)
	switch args[0] {
	case "log":
		window, parseErr := parseLogFlags(args[1:], stderr, time.Now())
		if parseErr != nil {
			return parseErr
		}
		output, err = service.Log(ctx, window.from, window.to)
	case "todo":
		if len(args) != 1 {
			return errors.New("todo does not accept arguments")
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

	encoder := json.NewEncoder(stdout)
	encoder.SetEscapeHTML(false)
	return encoder.Encode(output)
}

type interval struct {
	from time.Time
	to   time.Time
}

func parseLogFlags(args []string, stderr io.Writer, now time.Time) (interval, error) {
	flags := flag.NewFlagSet("log", flag.ContinueOnError)
	flags.SetOutput(stderr)
	var fromValue, toValue, timezone string
	flags.StringVar(&fromValue, "from", "", "inclusive start")
	flags.StringVar(&toValue, "to", "", "exclusive end")
	flags.StringVar(&timezone, "timezone", "Europe/Oslo", "IANA timezone")
	if err := flags.Parse(args); err != nil {
		return interval{}, err
	}
	if flags.NArg() != 0 {
		return interval{}, errors.New("unexpected positional argument for log")
	}

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
