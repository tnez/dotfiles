---
description: Refactor code with review and testing validation
---

1. Establish baseline before refactoring:
   - Document current behavior and performance characteristics
   - Run full test suite to ensure all tests pass
   - Create backup branch if refactoring is complex
   - Identify all files/components that will be affected

2. Perform the requested refactoring in small, incremental steps:
   - Make one logical change at a time
   - Run tests after each significant change
   - Ensure no behavior changes (same inputs produce same outputs)
   - Maintain backward compatibility for public APIs

3. After each refactoring increment:
   - Run all relevant tests to verify functionality is preserved
   - Check that performance hasn't degraded significantly
   - Verify error handling still works correctly

4. Use the architecture-reviewer agent to validate the completed refactoring:
   - Improves code quality and maintainability
   - Follows SOLID principles and project patterns
   - Maintains proper separation of concerns
   - Doesn't introduce new architectural issues
   - Preserves all existing functionality

5. Address any reviewer feedback iteratively:
   - Fix issues while maintaining the refactoring benefits
   - Re-run tests after each fix
   - Re-validate with architecture-reviewer if significant changes made

6. Final validation:
   - Run comprehensive test suite one final time
   - Verify performance benchmarks (if applicable)
   - Confirm all original functionality remains intact

7. Use the git-commit agent to create clear refactor commits:
   - Explain what was refactored and why
   - Document the improvements achieved
   - Note any trade-offs or limitations
   - Include before/after metrics if relevant

This command ensures safe refactoring through incremental changes, testing, and architectural review.