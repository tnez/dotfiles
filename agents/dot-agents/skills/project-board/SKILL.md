---
name: project-board
description: "Review and steward a GitHub repo's PRs and issues: classify PRs, review ready PRs when asked, close stale issues, manage ready async work, and recommend next actions."
---

# Project Board

Run a GitHub project-board stewardship pass for the current repository.

## Inputs

Use the current git remote to determine `owner/repo`. If the repo cannot be resolved, ask for the GitHub repository.

Defaults:
- Async assignee: `dottie-weaver`
- Async-ready label: `ready`

If the user gives an async capacity (for example, "assign up to three"), treat
that as the total number of simultaneously assigned async lanes for this pass.
Already-assigned issues for the async assignee count against the cap.

If the user provides different names, use those for this run.

## Preflight

1. Read local project instructions (`AGENTS.md`, `CLAUDE.md`, or equivalent) if present.
2. Verify `gh auth status`. If it fails in a sandbox/keychain-limited context,
   retry in the normal host environment before concluding auth is broken.
3. Fetch current open PRs and issues with `gh`.
4. If local code inspection is needed and the current branch is clean but behind,
   fast-forward before reading local files. Do not pull over unrelated local work.
5. Do not mutate GitHub unless the user asked for review, issue hygiene, or board updates.

## PR Pass

Fetch open PRs with enough detail to classify review and merge state:

- number, title, author, draft state
- head/base branch
- CI/check rollup
- merge state
- review decision
- labels, assignees, updated time
- body/comments/reviews when needed

Classify PRs:
- `ready_to_review`: non-draft, CI green, merge-clean, not waiting on another open PR.
- `wait`: stacked, depends on an unmerged PR, blocked by merge order, or otherwise should not be acted on yet.
- `changes_requested`: existing requested changes or a blocking issue found during review.
- `status_only`: not enough context to act safely.

Mergeability details:
- If GitHub reports `UNKNOWN` after a push or merge, wait briefly and re-query before classifying.
- If a PR is `DIRTY` because it carries commits from a merged dependency, comment with a restack/rebase request and hold review until the final diff is clean.
- After any merge, re-fetch the open PR list before acting on the next PR. Other automation or maintainers may have merged or changed state in the meantime.
- Merge in dependency order, one PR at a time, re-checking CI and merge state between merges.

When asked to review PRs:
- Approve ready PRs.
- Approve with non-blocking comments for take-it-or-leave-it notes.
- Formally request changes for correctness, security, test, or documentation-contract blockers.
- Take no review action on PRs that need to wait.
- Write review/comment bodies to temp files and use `gh pr review --body-file` or `gh pr comment --body-file` to avoid shell interpolation of Markdown backticks.

## Issue Pass

Fetch open issues and available labels.

Hygiene rules:
- Close only obviously stale, duplicate, or superseded issues. Leave a clear closing comment.
- Remove the async-ready label from issues that already have open PRs.
- Mark issues async-ready only when they are scoped, unblocked, and have enough context or acceptance criteria.
- Prefer rewriting stale issue bodies over assigning them.
- Inspect candidate issue bodies, comments, umbrella issues, and relevant merged docs before assigning; labels alone are not enough.
- If an issue is basically ready but needs sharper pickup constraints, add a concise scope comment before assigning rather than bloating the issue body.

Async assignment rule:
- Do not assign new async work while open PRs have change requests, failing CI, merge conflicts, or are blocked in a merge queue.
- If the PR queue is healthy, assign independent ready issues to the async assignee and apply the async-ready label.
- More than one issue may be assigned at once when the work is independent and the queue is healthy.
- For parallel pickup, choose issues with low file/domain overlap and no direct dependency on one another. Avoid assigning provider/UI/audit follow-ups before their substrate issue lands unless the user explicitly asks.
- Count existing assigned async issues toward the user's capacity. If no capacity is given, be conservative and recommend extra candidates before assigning them.

## Output

Summarize:
- PR status and review actions taken.
- PRs skipped and why.
- Issues closed, edited, labeled, assigned, or deliberately left alone.
- Ready-but-held work.
- Parallel async lanes assigned and remaining capacity, when relevant.
- Recommended next move.
