---
name: run-checks
description: Run the project's Definition of Done checklist
disable-model-invocation: true
allowed-tools: Bash, Read, Glob
---

Validate the current branch against the project's Definition of Done.

1. Check if `AGENTS.md` exists at the project root. If it does, read it and look for a **Definition of Done** section. If you find one, use it as the checklist (skip to step 2). If `AGENTS.md` doesn't exist or has no Definition of Done, go to the **Fallback** step.
2. Run `git diff main...HEAD --name-only` to see what changed. Use this to determine which checklist items are relevant (e.g. doc-only changes don't need code checks beyond confirming they still pass, but do need doc-quality review).
3. For each checklist item, run the appropriate validation:
   - **Automated checks** (typecheck, lint, test, build): run the commands specified in the checklist
   - **Manual/judgement checks** (docs updated, tests added for new logic): evaluate based on the diff and report your assessment
4. Run all checks — don't stop at the first failure. Run them all so the user gets the full picture.
5. Summarize results as a checklist matching the Definition of Done format: what passed, what failed, what's N/A, and any errors to address.

**Fallback:** If there is no `AGENTS.md` or it has no Definition of Done, detect tooling from config files (`Taskfile.yml`, `package.json`, `Makefile`, `pyproject.toml`, `Cargo.toml`, etc.) and run the standard checks (typecheck, lint, test, build).
