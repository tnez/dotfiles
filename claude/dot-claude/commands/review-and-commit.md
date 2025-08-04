---
description: Review changes and commit with architecture validation
---

1. **Understand the context:**
   - Review the conversation history to understand what was implemented or changed
   - Run `git status` to see what files have been modified
   - Run `git diff` to understand the specific changes made
   - If no changes are found, check if there was recent work discussed in the conversation

2. **Complete any unfinished implementation:**
   - If the conversation indicates work is incomplete, finish it first
   - If changes exist but seem partial, complete them based on context
   - If no context is clear, ask for clarification

3. **Run existing tests to verify functionality:**
   - Look for test commands in package.json, Makefile, or similar
   - Run tests if found, skip if no test infrastructure exists
   - Document any test failures for fixing

4. **Use the architecture-reviewer agent to review the code against:**
   - SOLID principles adherence
   - Project architectural patterns
   - Error handling completeness
   - Performance implications
   - Security considerations
   - Consistency with existing codebase

5. **If reviewer identifies issues:**
   - Address each issue systematically
   - Re-run tests after each fix (if tests exist)
   - Use architecture-reviewer again to validate fixes
   - Repeat until no critical issues remain

6. **Once architecture-reviewer approves (or only minor suggestions remain):**
   - Use git-commit agent to create properly formatted commit(s)
   - Include context from the conversation in commit messages
   - Reference any architectural decisions made
   - Handle multiple logical changes as separate commits if needed

This command intelligently reviews and commits changes based on conversation context and git state, ensuring quality through automated review cycles.