---
description: Write failing test, fix bug, validate, commit
---

1. Investigate and reproduce the reported bug:
   - Understand the expected vs actual behavior
   - Identify the conditions that trigger the bug
   - Locate the likely source of the issue in the codebase

2. Write a failing test that reproduces the bug:
   - Place test in appropriate test file/directory following project conventions
   - Use descriptive test name that explains the bug scenario
   - Ensure test fails for the right reason (reproduces the actual bug)
   - Include edge cases that might be related to the bug

3. Verify the test fails as expected before implementing the fix

4. Implement the minimal fix to make the test pass:
   - Focus on addressing the root cause, not just symptoms
   - Avoid over-engineering the solution
   - Maintain existing code patterns and style

5. Run the new test to confirm it now passes

6. Run full test suite to ensure no regressions were introduced

7. Use the architecture-reviewer agent to ensure:
   - The fix addresses the root cause rather than masking symptoms
   - No new issues are introduced by the fix
   - Proper error handling is in place
   - Fix follows project coding standards
   - Test coverage is appropriate for the bug type

8. Address any reviewer feedback:
   - Refine the fix if needed
   - Update tests if additional edge cases are identified
   - Re-run all tests after changes

9. Use the git-commit agent to create separate commits:
   - First commit: Add the failing test (should fail CI)
   - Second commit: Implement the fix (should pass CI)
   - Include bug description and fix rationale in commit messages

This command ensures bug fixes come with regression test coverage and proper validation.