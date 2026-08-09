# HTTP Services

Read this reference when building or changing a Go HTTP server, handler, middleware, or transport-level test.

## Expose the service shape

- Build the top-level handler with `NewServer(...) http.Handler` or an existing equivalent. Pass dependencies explicitly, construct the mux inside it, and apply service-wide middleware there.
- Keep the complete route surface discoverable in one place, commonly `routes.go` or `addRoutes`. Route-local wiring may remain beside the route when it improves readability.
- Write handler constructors that close over explicit dependencies and return `http.Handler`. Keep protocol decoding, validation, domain calls, and response encoding visible in that order.
- Build middleware dependencies once, then wrap handlers with `func(http.Handler) http.Handler`.

## Own the process lifecycle

- Keep `main` small. Put testable startup and shutdown behavior in a `run` function that accepts a context plus relevant process capabilities such as arguments, environment lookup, and I/O streams.
- Propagate cancellation through every blocking dependency. Give shutdown its own bounded context.
- Configure an explicit `http.Server`. Choose header, idle, request, and shutdown limits from the service's traffic model; account deliberately for streaming endpoints.
- Give every background goroutine a stop signal and an owner that waits for completion.
- Expose readiness or health through the same serving path clients use when orchestration or end-to-end tests need it.

## Keep the protocol boundary strict

- Centralize JSON encode/decode behavior when several endpoints share it. Return wrapped errors to the handler's error policy.
- Set response headers before the status code. Bound request bodies and validate content types, unknown fields, and trailing input when the API contract requires strictness.
- Translate domain errors to HTTP status and response bodies in one intentional layer. Preserve machine-readable error identity behind human-readable context.
- Put cross-cutting request behavior—authentication, request IDs, structured logging, metrics, tracing, panic recovery—in focused middleware.

## Test behavior, not wiring trivia

- Use `httptest.NewRecorder` or `httptest.NewServer` and real `http.Request` values.
- Test an individual handler when its protocol logic is complex. Test through the assembled server when routing, middleware, or startup behavior matters.
- Prefer one assertion layer for each behavior. Remove lower-level tests that merely repeat a stronger boundary test without localizing failures.
- Control startup through injected process capabilities rather than mutating global arguments or environment. Cancel the test context and assert shutdown where lifecycle behavior matters.

## Sources and personal context

- Mat Ryer, [How I write HTTP services in Go after 13 years](https://grafana.com/blog/how-i-write-http-services-in-go-after-13-years/): explicit `NewServer`, centralized routes, handler factories, a testable `run`, lifecycle-aware contexts, middleware factories, and tests at a meaningful HTTP boundary.
- The user's Code notebook note: retain deliberate public-server timeout configuration.
