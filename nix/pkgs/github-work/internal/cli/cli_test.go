package cli

import (
	"bytes"
	"context"
	"errors"
	"io"
	"strings"
	"testing"
	"time"

	githubwork "github.com/itsdalmo/dotfiles/github-work"
)

type fakeService struct {
	output []githubwork.OutputItem
	err    error
	call   string
	value  string
	from   time.Time
	to     time.Time
}

func (s *fakeService) Log(_ context.Context, from, to time.Time) ([]githubwork.OutputItem, error) {
	s.call, s.from, s.to = "log", from, to
	return s.output, s.err
}

func (s *fakeService) Todo(context.Context) ([]githubwork.OutputItem, error) {
	s.call = "todo"
	return s.output, s.err
}

func (s *fakeService) Fetch(_ context.Context, value string) ([]githubwork.OutputItem, error) {
	s.call, s.value = "fetch", value
	return s.output, s.err
}

func TestRunRoutesCommandsAndWritesJSON(t *testing.T) {
	tests := []struct {
		name      string
		args      []string
		wantCall  string
		wantValue string
	}{
		{name: "log", args: []string{"log", "--from", "2026-08-12", "--to", "2026-08-12", "--timezone", "UTC"}, wantCall: "log"},
		{name: "todo", args: []string{"todo"}, wantCall: "todo"},
		{name: "fetch", args: []string{"fetch", "https://github.com/AidnAS/platform/issues/42"}, wantCall: "fetch", wantValue: "https://github.com/AidnAS/platform/issues/42"},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			service := &fakeService{output: []githubwork.OutputItem{{Type: "issue", Title: "<work>"}}}
			var stdout, stderr bytes.Buffer
			if err := Run(context.Background(), test.args, service, &stdout, &stderr); err != nil {
				t.Fatal(err)
			}
			if service.call != test.wantCall || service.value != test.wantValue {
				t.Fatalf("call = %q, value = %q", service.call, service.value)
			}
			if got, want := stdout.String(), `[{"type":"issue","title":"<work>"}]`+"\n"; got != want {
				t.Fatalf("stdout = %q, want %q", got, want)
			}
			if stderr.Len() != 0 {
				t.Fatalf("stderr = %q", stderr.String())
			}
			if test.wantCall == "log" {
				if got := service.from.Format(time.RFC3339); got != "2026-08-12T00:00:00Z" {
					t.Fatalf("from = %s", got)
				}
				if got := service.to.Format(time.RFC3339); got != "2026-08-13T00:00:00Z" {
					t.Fatalf("to = %s", got)
				}
			}
		})
	}
}

func TestRunHelpDoesNotCallService(t *testing.T) {
	service := &fakeService{}
	var stdout bytes.Buffer
	if err := Run(context.Background(), nil, service, &stdout, io.Discard); err != nil {
		t.Fatal(err)
	}
	if service.call != "" {
		t.Fatalf("service called: %s", service.call)
	}
	if !strings.Contains(stdout.String(), "Usage: github-work") {
		t.Fatalf("stdout = %q", stdout.String())
	}
}

func TestRunRejectsInvalidCommandsAndArguments(t *testing.T) {
	tests := []struct {
		name string
		args []string
		want string
	}{
		{name: "unknown command", args: []string{"wat"}, want: `unknown command "wat"`},
		{name: "todo arguments", args: []string{"todo", "extra"}, want: "todo does not accept arguments"},
		{name: "missing fetch URL", args: []string{"fetch"}, want: "fetch requires one GitHub issue or pull-request URL"},
		{name: "invalid date", args: []string{"log", "--from", "yesterday"}, want: "invalid --from"},
		{name: "invalid timezone", args: []string{"log", "--timezone", "Moon/Base"}, want: `invalid timezone "Moon/Base"`},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			err := Run(context.Background(), test.args, &fakeService{}, io.Discard, io.Discard)
			if err == nil || !strings.Contains(err.Error(), test.want) {
				t.Fatalf("error = %v, want containing %q", err, test.want)
			}
		})
	}
}

func TestRunReturnsServiceErrorWithoutWritingJSON(t *testing.T) {
	want := errors.New("GitHub unavailable")
	service := &fakeService{err: want}
	var stdout bytes.Buffer
	err := Run(context.Background(), []string{"todo"}, service, &stdout, io.Discard)
	if !errors.Is(err, want) {
		t.Fatalf("error = %v, want %v", err, want)
	}
	if stdout.Len() != 0 {
		t.Fatalf("stdout = %q", stdout.String())
	}
}

func TestParseLogDateUsesTimezoneAndInclusiveToDate(t *testing.T) {
	now := time.Date(2026, time.March, 29, 12, 0, 0, 0, time.UTC)
	window, err := parseLogFlags([]string{"--from", "2026-03-29", "--to", "2026-03-29", "--timezone", "Europe/Oslo"}, io.Discard, now)
	if err != nil {
		t.Fatal(err)
	}
	if got := window.from.Format(time.RFC3339); got != "2026-03-29T00:00:00+01:00" {
		t.Fatalf("from = %s", got)
	}
	if got := window.to.Format(time.RFC3339); got != "2026-03-30T00:00:00+02:00" {
		t.Fatalf("to = %s", got)
	}
}
