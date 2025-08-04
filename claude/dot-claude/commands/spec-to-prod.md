---
description: Full pipeline from spec → implement → test → review → commit
---

1. Use the spec-writer agent to create a detailed specification for the requested feature
2. Review the generated spec and confirm it matches the requirements before proceeding
3. Implement the feature according to the specification, following existing code patterns
4. Write comprehensive tests that validate all acceptance criteria from the spec:
   - Unit tests for core logic
   - Integration tests for component interactions
   - End-to-end tests for user workflows (if applicable)
5. Run all tests to ensure they pass and provide adequate coverage
6. Use the architecture-reviewer agent to validate:
   - Implementation matches specification requirements
   - Code follows project architectural standards
   - Tests adequately cover specified behavior
7. Address any reviewer feedback iteratively, updating tests if needed
8. Verify final implementation against original spec for completeness
9. Use the git-commit agent to create organized commits:
   - Separate commits for spec, implementation, tests, and documentation
   - Reference spec requirements in commit messages

This command provides a complete development pipeline from requirements to production-ready code.