---
name: go-development
description: Develop and review maintainable Go software. Use when implementing, refactoring, testing, or reviewing Go code; designing Go packages or command-line programs; or building Go HTTP services.
---

# Go Development

Write industrial Go: optimize for a changing team reading, testing, operating, and eventually deleting the code.

## Workflow

1. Establish the local contract.
   - Read applicable `AGENTS.md` files, `go.mod`, the entry points, adjacent packages, tests, and CI or lint configuration.
   - Prefer the repository's established vocabulary and patterns when they are coherent.
   - Identify externally observable behavior and compatibility constraints before editing.
   - Complete this step when the change can be described in terms of behavior, ownership, and existing conventions.

2. Choose the smallest design that keeps dependencies explicit.
   - Let concrete pressure create structure; start with files in an existing package before inventing layers.
   - Pass dependencies through functions or constructors and assemble the component graph in `main` or another composition root.
   - Define a small interface in the consuming package only when a real fault line, alternate implementation, or useful test seam exists. Accept interfaces and return concrete types.
   - Pass `context.Context` first for blocking work and request lifetimes. Pass startup dependencies as ordinary parameters.
   - For package boundaries or repository layout, read [references/package-design.md](references/package-design.md) before deciding.
   - Complete this step when each dependency and lifetime has an obvious owner and every new abstraction pays for itself now.

3. Implement straightforward Go.
   - Prefer the standard library and existing dependencies. Justify each new dependency by concrete value.
   - Keep the happy path left-aligned, return errors to the caller, and wrap errors with concise operation context using `%w` when callers may inspect the cause.
   - Make zero values useful where practical. Keep names short in narrow scopes and descriptive at package boundaries; avoid names that repeat the package name.
   - Make goroutine ownership explicit: the code that starts a goroutine must provide and exercise its stopping condition and wait for it when required.
   - Keep mutable state instance-scoped. Use package state only for immutable data or a demonstrated package-wide invariant.
   - For exported APIs or an idiom-focused review, read [references/idioms.md](references/idioms.md).
   - For HTTP servers, handlers, middleware, or transport tests, read [references/http-services.md](references/http-services.md).
   - Complete this step when the behavior is implemented with no speculative layer, hidden dependency, or unowned concurrent work.

4. Verify at the narrowest meaningful boundary.
   - Add or update tests that describe behavior. Use table-driven tests when the cases share meaningful setup and assertions; keep distinct behavior in distinct tests.
   - Prefer real values, small handwritten fakes, `httptest`, and temporary directories over mocking frameworks or package-global test hooks.
   - Exercise failure, cancellation, and shutdown paths when the change affects them. Run race detection when concurrency changes and the repository supports it.
   - Format changed Go files with the repository's formatter, falling back to `gofmt`. Run the repository's documented checks, falling back to `go test ./...`.
   - Complete this step when formatting is clean, relevant tests pass, and every changed behavior has proportionate evidence.

5. Report the result.
   - State the behavior changed, the design choice that matters, and the exact verification run.
   - Name any compatibility risk, unverified boundary, or intentionally deferred structure.

