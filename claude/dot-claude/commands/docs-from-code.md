---
description: Generate comprehensive documentation from existing code
---

1. Analyze the specified code or module thoroughly:
   - Understand the purpose and scope of the code
   - Identify all public APIs, functions, and classes
   - Map dependencies and integration points
   - Note any existing documentation or comments

2. Check for existing documentation:
   - Locate current documentation files
   - Identify gaps or outdated information
   - Determine if this is new documentation or updates

3. Use the research-analyst agent to create comprehensive documentation including:
   - Purpose and overview of the component/module
   - API references with parameters, return types, and exceptions
   - Usage examples and code snippets that actually work
   - Architectural decisions and design patterns used
   - Configuration options and environment requirements
   - Integration points and dependencies
   - Common pitfalls, limitations, and best practices
   - Performance characteristics (if relevant)

4. Validate documentation accuracy:
   - Test all code examples in the documentation
   - Verify API signatures match actual implementation
   - Ensure configuration examples are current and correct
   - Check that all public interfaces are documented

5. Determine appropriate documentation location:
   - Follow project documentation structure (README, docs/, etc.)
   - Use consistent formatting with existing documentation
   - Consider if documentation should be inline (docstrings) or external

6. Update or create documentation files:
   - Write in project's preferred format (Markdown, reStructuredText, etc.)
   - Follow project style guide for documentation
   - Include appropriate headers, navigation, and cross-references
   - Add to documentation index/table of contents if needed

7. Use the context-maintainer agent to ensure:
   - Project documentation index is updated
   - Documentation links and references are current
   - Documentation build process works (if automated)

8. Final validation:
   - Review documentation for completeness and clarity
   - Ensure all code examples are tested and working
   - Verify documentation renders correctly in target format

9. Use the git-commit agent to commit documentation updates:
   - Include clear description of what documentation was added/updated
   - Reference the code components that were documented
   - Note any documentation format or structure changes

This command generates high-quality, validated documentation from your implementation.