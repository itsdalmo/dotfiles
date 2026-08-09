# Language and API Idioms

Read this reference when designing exported APIs, reviewing idiomatic Go, or resolving a style question that local conventions do not answer.

## Formatting and names

- Let `gofmt` decide layout.
- Use short package names that describe what the package provides. Avoid `util`, `common`, and import stutter.
- Use `MixedCaps`. Keep local names proportional to their scope; make exported names precise in the context of their package.
- Write doc comments for exported identifiers when the repository's lint policy or the API's users need them. Start a public identifier's comment with its name.

## Types and APIs

- Make the useful state easy to construct and the invalid state difficult to represent.
- Prefer value semantics for small immutable values and pointer semantics for shared identity, mutation, or expensive copying. Keep receiver choice consistent for a type.
- Accept behavior through small interfaces at the consumer. Return concrete values.
- Use embedding to promote behavior only when the containing type genuinely is meant to expose that behavior.
- Use generics when the algorithm is genuinely type-independent and the result is clearer than a small concrete implementation.

## Control flow and errors

- Return early on errors and keep the successful path visually straight.
- Add operation context as errors cross abstraction boundaries. Preserve causes with `%w` when callers may use `errors.Is` or `errors.As`.
- Compare error identity rather than error text. Introduce sentinel or typed errors only when callers need to branch on them.
- Reserve panic for broken invariants or unrecoverable programmer errors; convert internal panics to errors before crossing a package API when the package intentionally uses panic for control flow.
- Use `defer` where ownership is acquired so cleanup remains adjacent and reliable.

## Concurrency and context

- Prefer synchronous code until concurrency provides measured or required value.
- Communicate ownership explicitly through channels or protect shared state with the narrowest suitable synchronization.
- Size channels from a known protocol or bound, not as an accidental timing fix.
- Use context for cancellation, deadlines, and request-scoped data. Pass configuration, loggers, stores, and other startup dependencies directly.

## Source caveat

[Effective Go](https://go.dev/doc/effective_go) remains authoritative for core formatting, naming, interface, control-flow, and concurrency idioms, but the Go project notes that it was written in 2009 and is not actively updated for modules, generics, or newer libraries. For those areas, inspect the module's Go version and current official package or release documentation before deciding.
