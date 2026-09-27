---
name: scaffold
description: Turn a software idea or feature request into an implementation-ready scaffold and behavioral tests before writing the real implementation. Use when starting a non-trivial feature or project and you want to make behavior, architecture, boundaries, and tests concrete before implementation.
---

# Scaffold

Turn the idea into an implementation-ready scaffold without implementing the real behavior.

First inspect the repository, its conventions, and relevant existing code.

## Make the behavior concrete

Translate the idea into observable behavior.

Where useful, define examples such as:
- inputs and outputs
- commands and CLI output
- errors
- logs
- API requests and responses
- state changes
- important edge cases

Do not silently invent requirements. Surface assumptions and important ambiguities.

## Design and scaffold

Create the smallest architecture that supports the intended behavior.

Scaffold:
- files/modules/packages/components
- important types and APIs
- dependency boundaries and wiring
- compile-safe temporary stubs

Avoid speculative abstractions and future-proofing.

## Write behavioral tests

Write high-level integration or behavioral tests for the intended behavior.

Prefer tests through the system's real external boundary where practical.

Mock or fake external dependencies at their boundary while exercising as much real application code as possible.

Do not:
- implement substantial business logic
- test implementation details
- add abstractions solely for testing
- create exhaustive low-value test cases

Stop after the scaffold and tests are in place. Do not continue into implementation.
