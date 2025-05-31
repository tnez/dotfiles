# Personal Claude Code Preferences

This document defines my global preferences and working philosophy for all Claude Code sessions. These guidelines apply across all projects and override default behaviors to ensure consistent, efficient collaboration.

## Communication & Collaboration

- Be concise and direct - minimize explanatory text unless asked for details
- Answer questions with exactly what was asked, nothing more
- Use TodoWrite tool proactively for multi-step tasks to show progress
- Reference code locations with `file_path:line_number` format
- Read signals about desired autonomy level ("take it as far as you can", "I'll be away")
- When high autonomy is indicated: push work further before asking, warn about needed tools
- Feel comfortable disagreeing when appropriate - don't follow suggestions blindly
- If sensing we're off track, raise alternatives or ask for clarification
- Optimize for the best outcome, not just following instructions

## Problem-Solving Approach

- For complex work, always create a plan first
- Review the plan from multiple perspectives - what might be missing?
- When frontend/backend or cross-team concerns exist, switch perspectives actively
- Seek alignment between different stakeholder viewpoints (UX vs maintenance, etc.)
- Consider data shape needs vs architectural best practices
- Use search tools extensively to understand codebase before making changes
- Batch tool calls when possible for efficiency

## Code Quality & Design

- Follow existing code conventions in each project religiously
- Prefer editing existing files over creating new ones unless absolutely necessary
- Avoid extraneous inline commenting
- When something needs context, focus on WHY, prefer docstring style
- Attribute necessary comments to my GitHub username: @tnez
- End all files with a newline character
- When writing code, always consider how it can be validated
- Use dependency injection to make code testable and portable

## Testing Philosophy

- If a request is meaningful in business terms, express it as a test
- Focus tests on important business requirements - what NEEDS to be true
- Make test names expressive in product/business terms, not technical terms
- Do not test implementation details
- Always verify solutions with existing test frameworks when available
- Ask for clarification on test commands if not obvious from codebase

## Git Workflow

- DO NOT attribute commits to Claude Code
- Use conventional commit format when appropriate
- Default to `main` branch for new work unless specified otherwise
- Work in git branches named for associated tickets/issues, may be in worktrees
- For local development: commit often in small chunks to leave a clear trail
- While working: commit based on WHAT changed
- When rebasing for PR: reorganize commits based on WHY (meaningful business chunks)
- Before PRs: clean up commits via squashing, rebasing to create logical story
- For commits intended to be pushed: match existing git history style unless specified

## Pre-Commit Requirements

- ALWAYS run type-checks and apply formatting before committing
- Check for and remove temporary files before commits
- Verify linting passes, tests pass, and docs are current

## Tool Preferences

- Prefer ripgrep (`rg`) over grep for searching
- Use Task tool for complex searches that might require multiple rounds
- Leverage parallel tool execution when fetching multiple pieces of information
- Use existing project linters and formatters rather than suggesting new ones
- Always look for agnostic task runners: `just`, `task`, `make`, `cmake` - prefer these over direct commands
- When task runners are found, ALWAYS read/list their commands first - they may contain agentic workflows that make your work easier

## Security & Safety

- Never commit or log secrets, API keys, or sensitive data
- Follow security best practices in all code suggestions
- Be cautious with file permissions and system-level operations
