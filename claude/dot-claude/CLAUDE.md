# Personal Claude Code Preferences

This document defines my global preferences and working philosophy for all Claude Code sessions. These guidelines apply across all projects and override default behaviors to ensure consistent, efficient collaboration.

## Priority Indicators

- 🔴 **CRITICAL** - Non-negotiable requirements that must always be followed
- 🟡 **IMPORTANT** - Strong preferences that should generally be followed  
- 🟢 **HELPFUL** - Nice-to-have guidelines that are beneficial but optional

## Communication & Collaboration

- 🔴 Be concise and direct - minimize explanatory text unless asked for details
- 🔴 Answer the core request fully, but don't add unrequested features or explanations
- 🟡 When requests are ambiguous, ask one clarifying question before proceeding
- 🟡 If encountering errors, explain the issue and provide 2-3 solution options
- 🔴 Use TodoWrite tool proactively for multi-step tasks to show progress
- 🔴 Reference code locations with `file_path:line_number` format
- 🟡 Read signals about desired autonomy level ("take it as far as you can", "I'll be away")
- 🟡 When high autonomy is indicated: push work further before asking, warn about needed tools
- 🟢 Feel comfortable disagreeing when appropriate - don't follow suggestions blindly
- 🟡 If sensing we're off track, raise alternatives or ask for clarification
- 🔴 Optimize for the best outcome, not just following instructions
- 🟡 When you must interrupt work (missing tools, unclear requirements), explain what you've accomplished so far
- 🔴 Use absolute file paths in all responses - never use relative paths

## Problem-Solving Approach

- 🔴 For tasks with 3+ steps or touching multiple files, ALWAYS create a plan first
- 🟡 Validate key assumptions by searching existing code patterns before implementing
- 🟡 Review the plan from multiple perspectives - what might be missing?
- 🟡 When frontend/backend or cross-team concerns exist, switch perspectives actively
- 🟢 Seek alignment between different stakeholder viewpoints (UX vs maintenance, etc.)
- 🟡 Consider data shape needs vs architectural best practices
- 🔴 Use search tools extensively to understand codebase before making changes
- 🟡 Start searches broad (Grep), then narrow down (Read specific files)
- 🟡 Search for existing patterns before implementing new solutions
- 🔴 Batch tool calls when possible for efficiency

## Docent MCP Integration

🟡 **When available, use the docent MCP for agentic workflows** - Docent provides runbooks, templates, and documentation management.

### Core Docent Concepts

- **Runbooks** - Procedural guides for specific tasks (health checks, deployments, commits)
- **Templates** - Structured documentation formats (ADRs, RFCs, specs)
- **Commands** - `start`, `ask`, `act`, `tell` for documentation intelligence

### Working with Docent

When docent is configured, Claude uses it automatically behind the scenes. If available:
- Task automation → docent runbooks handle it
- Documentation → docent templates structure it
- Knowledge capture → docent's `tell` stores it
- Context questions → docent's `ask` answers it

## Code Quality & Design

- 🔴 Follow existing code conventions in each project religiously
- 🔴 Analyze existing code style in the first few files you read - match it exactly
- 🟡 Look for `.editorconfig`, `.prettier`, or similar config files to understand formatting
- 🔴 Prefer editing existing files over creating new ones unless absolutely necessary
- 🟡 Avoid extraneous inline commenting
- 🟡 When something needs context, focus on WHY, prefer docstring style
- 🟢 Attribute necessary comments to my GitHub username: @tnez
- 🔴 End all files with a newline character
- 🟡 When writing code, always consider how it can be validated
- 🟡 Use dependency injection for external dependencies (APIs, databases, file system)
- 🟡 Consider performance implications of changes, especially in hot paths
- 🟢 Prefer pure functions and immutable data structures when practical

## Testing Philosophy

- 🔴 Before writing tests, discover existing test patterns by searching for test files
- 🟡 Look for test commands in package.json scripts, Makefile, or task runners
- 🟡 Follow the project's existing testing conventions and coverage expectations
- 🔴 Focus tests on important requirements - what NEEDS to be true
- 🔴 Do not test implementation details
- 🔴 Always verify solutions with existing test frameworks when available
- 🟡 Use existing test data/fixtures rather than creating new ones

## Git Workflow

- 🔴 **Never include AI attribution in commits** - Remove all Claude Code signatures, Co-Authored-By lines, and AI emojis
- 🟡 **Follow project's commit conventions** - Check git log to understand the style (conventional commits, descriptive messages, etc.)
- 🔴 **Create multiple commits for distinct logical changes** - Separate config from code, tests from implementation
- 🟡 Default to `main` branch for new work unless specified otherwise
- 🟡 Follow project's branch naming conventions - Check existing branches first
- 🟡 When creating PRs: use succinct bullet points for descriptions, avoid verbose explanations
- 🟡 Ask before pushing to remote repositories - user may prefer local commits only

## Pre-Commit Requirements

- 🔴 Check for and remove temporary files before commits
- 🟡 If type-checkers exist, run them before committing
- 🟡 If formatters exist, apply formatting before committing
- 🟡 If linters exist, verify linting passes
- 🟡 If pre-commit hooks fail, fix issues before retrying commit

## Tool Preferences

- 🔴 **ALWAYS use ripgrep (`rg`) instead of grep** - Never use `grep` or `find` commands in Bash
- 🔴 Use Claude Code's Grep tool, not bash `rg` commands - it has better permissions and formatting
- 🟡 Use Task tool for complex searches that might require multiple rounds
- 🔴 Leverage parallel tool execution when fetching multiple pieces of information
- 🟡 Use existing project linters and formatters rather than suggesting new ones
- 🔴 Always look for agnostic task runners: `just`, `task`, `make`, `cmake` - prefer these over direct commands
- 🔴 When task runners are found, ALWAYS read/list their commands first - they may contain agentic workflows that make your work easier
- 🟡 For new projects, immediately check for: `package.json` scripts, `Makefile`, `Justfile`, `Taskfile.yml`
- 🟡 Use `ls -la` to discover hidden config files (.env, .nvmrc, etc.) that inform tool choices
- 🟡 When multiple package managers exist (npm + yarn), ask user which to prefer

## Security & Safety

- 🔴 Never commit or log secrets, API keys, passwords, or tokens
- 🔴 If you find existing secrets in code, alert the user immediately - don't edit the file
- 🔴 Avoid hardcoding URLs, database names, or other environment-specific values
- 🟡 Be cautious with file permissions (on Unix-like systems: 644 for files, 755 for executables)
- 🟡 When handling user input in code, consider injection attacks and validation
- 🟡 Flag any `eval()`, `exec()`, or dynamic code execution for user review
- 🟡 For system-level operations, explain what the command does before running it

## Error Handling & Recovery

- 🔴 When commands fail, show the exact error and suggest 2-3 specific solutions
- 🟡 For file not found errors, suggest using Glob or Grep to locate the file
- 🟡 For permission errors, explain the issue and ask user to resolve rather than using sudo
- 🟡 If imports/dependencies fail, check package.json/requirements.txt and suggest installation
- 🟡 When tests fail, show the failure output and identify the likely cause

## Project Context Discovery

- 🔴 At start of new projects, search for project manifests and documentation (README, package.json, Cargo.toml, pyproject.toml, go.mod, etc.)
- 🟡 Look for existing CLAUDE.md or similar project-specific instructions
- 🟡 Check for .gitignore to understand project structure and ignored files
- 🟡 Identify the main entry point and project structure
- 🟡 Note any monorepo structure

## File Management Preferences

- 🔴 Always use absolute paths in responses and tool calls
- 🔴 Before creating new files, search extensively for existing similar files to edit instead
- 🟡 When editing config files, back up the original approach by reading the full file first
- 🟡 For large files, use offset/limit parameters in Read tool to avoid truncation
- 🟡 Create new files only when: explicitly requested, no suitable existing file found, or implementing a completely new feature

## Tmux Strategy for Background Processes

When running long-running processes (dev servers, test watchers, etc.), use tmux windows within the same session.

### Critical Safety Rules

🔴 **NEVER kill the 'agent' window - this terminates Claude Code**

1. 🔴 **FIRST ACTION:** Rename Claude Code window: `tmux rename-window agent`
2. 🔴 Always verify window names before killing: `tmux list-windows`
3. 🔴 Use window names, not numbers: `tmux kill-window -t <name>`
4. 🟡 Always use `-d` flag when creating new windows (detached mode)
5. 🟡 Use descriptive window names: `dev-<service>`, `log-<service>`, `test`, `bg-<task>`

### Essential Commands

```bash
# Rename current window to identify it
tmux rename-window agent

# Create background window
tmux new-window -n <descriptive-name> -d '<command>'

# View window output without switching
tmux capture-pane -t <window-name> -p | tail -20

# Kill specific window (never 'agent')
tmux kill-window -t <window-name>

# List all windows
tmux list-windows
```

