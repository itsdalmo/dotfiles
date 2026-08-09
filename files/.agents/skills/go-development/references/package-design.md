# Package Design

Read this reference when choosing package boundaries, repository layout, interfaces, or dependency wiring.

## Grow structure from pressure

- Start a small program as a few files in one package. Split only when a boundary has a concrete reason: a distinct domain, an adapter dependency, reuse by another binary, or an import-cycle pressure that reveals misplaced ownership.
- Organize business code around domain language rather than generic implementation buckets such as `models`, `utils`, or `services`.
- Keep related behavior with the data and invariants it owns. Avoid a priori three-layer or clean-architecture templates.
- Use `cmd/<name>` when a module produces multiple binaries or when the repository already follows that convention. A single small binary can remain simpler.

## Establish dependency direction

A useful application shape, once the program needs packages, is:

```text
module root        domain types and behavior
postgres/          adapter for PostgreSQL
http/              adapter for net/http
cmd/app/           explicit construction and process lifecycle
```

Treat this as a pressure-tested option, not a required tree.

- Keep domain code independent of transport and storage details when that separation makes the domain easier to change or test.
- Group adapters by the dependency or protocol they translate. Let adapters communicate through domain types and consumer-owned contracts.
- Wire concrete implementations together explicitly at the composition root. Prefer compiler-visible constructor arguments over reflection-based dependency containers.
- Preserve an existing coherent layout. Move code only when the requested behavior benefits from the move.

## Place interfaces at fault lines

- Define an interface where behavior is consumed, using only the methods that consumer needs.
- Introduce one for a current alternate implementation, a stable boundary, or a test seam that materially simplifies a valuable test.
- Return concrete implementations so callers retain their full capabilities.
- Prefer a small handwritten fake near its tests. Create a shared fake package only when several packages genuinely share it.

## Sources and personal context

- Peter Bourgon, [Go for Industrial Programming](https://peter.bourgon.org/go-for-industrial-programming/): delay structure until concrete need, orient packages around the domain, expose dependencies, and treat interfaces as consumer contracts.
- Ben Johnson, [Standard Package Layout](https://www.gobeyond.dev/standard-package-layout/): root domain package, dependency-oriented adapters, shared vocabulary, and `main` as composition root.
- The user's Code and TREN notebook notes: favor root-level domain code, adapter packages, and interfaces only for multiple implementations or useful test seams.
