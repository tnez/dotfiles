---
description: Comprehensive multi-perspective code review
---

1. Use the architecture-reviewer agent to check design and structure:
   - Adherence to SOLID principles and design patterns
   - Proper separation of concerns
   - Appropriate abstraction levels
   - Consistency with existing codebase patterns

2. Conduct manual review focusing on:
   - Security vulnerabilities (injection attacks, data exposure, authentication issues)
   - Performance bottlenecks (inefficient algorithms, unnecessary computations, memory leaks)
   - Maintainability concerns (complex logic, unclear naming, missing documentation)
   - Code duplication and opportunities for abstraction
   - Error handling gaps and edge case coverage
   - Input validation and boundary conditions

3. Run additional validation checks:
   - Static analysis tools (if available in project)
   - Security scanners (if configured)
   - Performance profiling (for performance-critical code)
   - Test coverage analysis

4. Create a prioritized list of all feedback:
   - Critical: Security issues, data corruption risks, system crashes
   - High: Performance problems, maintainability issues, test gaps
   - Medium: Code quality improvements, minor design issues
   - Low: Style inconsistencies, optimization opportunities

5. Address issues by priority:
   - Start with critical and high-priority issues
   - Make one fix at a time to avoid introducing new problems
   - Run relevant tests after each fix
   - Document complex fixes with comments

6. After addressing each priority level:
   - Re-run the architecture-reviewer to validate fixes
   - Run full test suite to ensure no regressions
   - Update tests if new edge cases were discovered

7. Final validation:
   - Confirm all critical and high-priority issues are resolved
   - Verify system performance hasn't degraded
   - Ensure code coverage meets project standards

8. Use the git-commit agent to commit improvements:
   - Create separate commits for different types of improvements
   - Include clear messages about what was addressed
   - Reference specific issues fixed in each commit
   - Document any trade-offs made during fixes

This command provides thorough code review from multiple quality perspectives with systematic issue resolution.