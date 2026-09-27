---
name: simplify
description: Review a code change specifically for overengineering and unnecessary complexity. Use when asked to simplify a diff, remove AI-generated slop, reduce abstractions or tests, or identify code that can be deleted without changing required behavior.
---

# Simplify

Review the diff specifically for overengineering.

First inspect and respect the repository's existing conventions and architecture.

Look for:
- unnecessary abstractions
- premature interfaces
- redundant tests
- tests coupled to implementation details
- helpers used once
- excessive defensive code
- comments that restate the code
- needless error wrapping
- packages, modules, or components that do not justify their existence

Bias toward deletion.

Do not change required behavior.
Do not add features.
Do not add tests unless they expose a real uncovered failure mode.
Do not invent findings if the change is already appropriately simple.

First report what you would remove and why.
