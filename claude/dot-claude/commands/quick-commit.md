---
description: Fast path to commit without review cycles
---

For simple, low-risk changes only:

1. Verify the changes are appropriate for quick commit:
   - Typo fixes in comments, documentation, or strings
   - Documentation updates that don't change behavior
   - Configuration changes that are non-functional (formatting, comments)
   - Version bumps or dependency updates (if confident)
   - Simple variable renames with obvious correctness

2. Perform basic validation:
   - Ensure all intended changes are staged with `git status`
   - Quick scan for any unintended changes or sensitive data
   - Verify no functional code logic was modified
   - Check that files compile/parse correctly (if applicable)

3. Use the git-commit agent to create properly formatted commit(s):
   - Agent will ensure proper commit message format
   - Will handle multiple logical units if needed
   - Will include appropriate scope and type prefixes

**Do NOT use this command for:**
- Any functional code changes
- New features or bug fixes
- Refactoring or architectural changes
- Database schema changes
- Security-related modifications
- Changes affecting user-facing behavior

**When in doubt, use /review-and-commit instead.**

This command bypasses review for speed on trivial changes while maintaining commit quality.