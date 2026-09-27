---
name: nitpick
description: Perform a final low-severity polish pass on a code change. Use when asked to nitpick naming, comments, readability, consistency, wording, or minor style issues after correctness and architecture have already been reviewed.
---

# Nitpick

Review the current change for small, non-blocking improvements.

Focus on:
- awkward or inconsistent naming
- comments or docstrings that are verbose, stale, or obvious
- unnecessary temporary variables
- small readability issues
- inconsistent local style
- awkward error/log messages
- minor duplication
- needless verbosity
- formatting or organization that does not match surrounding code

Do not:
- raise correctness or architecture concerns unless they are obvious and important
- propose broad refactors
- introduce abstractions
- add tests
- turn preferences into requirements
- manufacture findings

Prefer a short list of concrete suggestions.

If there is nothing worth changing, say so.
