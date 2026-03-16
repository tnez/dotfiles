---
name: fix-author
description: Fix the author on all commits since main to match the local or global .gitconfig
disable-model-invocation: true
allowed-tools: Bash
---

Fix the author on all commits between `main` and HEAD using the current git config.

1. Read `user.name` and `user.email` from git config (local takes precedence over global)
2. List all commits from `main..HEAD` with their authors
3. Identify which commits have a mismatched author
4. If none are mismatched, tell the user and do nothing
5. Otherwise, use `git rebase main --exec 'git commit --amend --author="Name <email>" --no-edit'` to fix the author on all commits
6. Report which commits were updated
