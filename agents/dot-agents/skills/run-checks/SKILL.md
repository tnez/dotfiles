---
name: run-checks
description: Run the project's Definition of Done checklist
---

# Run Checks

Validate the current branch against the project's Definition of Done.

1. Check if `AGENTS.md` exists at the project root. If it does, read it and look
   for a **Definition of Done** section. If found, use it as the checklist. If
   not found, use the fallback below.
2. Run `git diff main...HEAD --name-only` to see what changed. Use this to
   decide which checklist items are relevant.
3. For each checklist item, run the appropriate validation:
   - Automated checks: typecheck, lint, test, build, or the commands specified
     in the checklist.
   - Manual checks: docs updated, tests added for new logic, behavior reviewed
     against the diff.
4. Run all checks. Do not stop at the first failure.
5. Summarize results as a checklist matching the Definition of Done format:
   passed, failed, not applicable, and any errors to address.

## Fallback

If there is no `AGENTS.md` Definition of Done, detect tooling from config files
such as `Taskfile.yml`, `package.json`, `Makefile`, `pyproject.toml`, or
`Cargo.toml`, then run the standard checks for the project.
