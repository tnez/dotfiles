---
name: pr
description: Create a pull request for the current branch against main
disable-model-invocation: true
allowed-tools: Bash
---

Create a pull request for the current branch against `main`.

1. Run `git diff main...HEAD` and `git log main..HEAD --oneline` to understand all changes since main
2. Push the current branch to origin with `-u`
3. Draft a short PR title (under 70 chars) and body:
   - `## Summary` — 1-3 succinct bullet points
   - `## Test plan` — bulleted checklist
   - Keep it brief. Err on the side of succinct.
4. Create the PR with `gh pr create --base main`. Try with `--draft` first. If that fails (repo may not support drafts), retry without `--draft`.
5. Return the PR URL
