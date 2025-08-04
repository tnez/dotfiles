---
description: Research optimal approach, then implement with validation
---

1. Use the research-analyst agent to investigate the best approach for the requested implementation, including:
   - Available libraries and frameworks in the current project ecosystem
   - Design patterns and architectural approaches that fit existing codebase
   - Performance implications and trade-offs
   - Security considerations
   - Alignment with project standards and team preferences
   - Migration path from current implementation (if refactoring)

2. Review research findings and select the recommended approach:
   - If multiple viable options exist, document the decision criteria
   - Consider team expertise and maintenance burden
   - Validate approach fits within project constraints

3. Implement the recommended solution, documenting key technical decisions:
   - Follow research recommendations precisely
   - Add comments explaining non-obvious implementation choices
   - Include error handling appropriate for the chosen approach

4. Validate the implementation works correctly:
   - Write tests that verify the implementation meets requirements
   - Run existing tests to ensure no regressions
   - Test edge cases identified during research

5. Use the architecture-reviewer agent to validate:
   - Chosen approach aligns with project standards
   - Implementation follows best practices for the selected technology
   - Integration points are properly handled

6. Address any reviewer feedback and re-validate

7. Use the git-commit agent to commit changes with:
   - Clear documentation of the technical decisions made
   - Reference to research findings that influenced the approach
   - Rationale for why this approach was chosen over alternatives

This command ensures informed technical decisions through research before implementation.