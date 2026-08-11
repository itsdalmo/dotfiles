package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"

	githubwork "github.com/itsdalmo/dotfiles/github-work"
	"github.com/itsdalmo/dotfiles/github-work/github"
	"github.com/itsdalmo/dotfiles/github-work/internal/cli"
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
	defer stop()

	service := githubwork.NewService(github.Client{})
	if err := cli.Run(ctx, os.Args[1:], service, os.Stdout, os.Stderr); err != nil {
		fmt.Fprintln(os.Stderr, "github-work:", err)
		os.Exit(2)
	}
}
