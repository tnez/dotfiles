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

## Specialized Subagents

Use these agents for specific tasks to ensure quality and consistency:

### Available Agents

- **`spec-writer`** - Create detailed feature specifications before implementation

  - Use when: Starting new features, defining APIs, establishing contracts
  - Creates specs with scenarios, examples, and acceptance criteria
  - Maintains spec manifest for tracking implementation status

- **`git-commit`** - Handle all git commits with proper formatting

  - Use when: Creating any git commit
  - Ensures NO Claude attribution, follows conventions, handles pre-commit hooks
  - Handles multiple commits for distinct logical changes

- **`research-analyst`** - Investigate complex topics and create documentation

  - Use when: Researching implementation options, understanding existing code, documenting findings
  - Creates comprehensive reports in docs/ directory

- **`architecture-reviewer`** - Review code against architectural standards

  - Use when: After implementing features, before PRs, checking design decisions
  - Provides actionable feedback on code structure and patterns

- **`context-maintainer`** - Update project documentation after work sessions
  - Use when: End of session, after major changes, when context needs updating
  - Keeps CLAUDE.md and project docs current

### Usage Examples

```bash
# Starting a new feature
"Use the spec-writer agent to create a spec for user authentication"

# After implementation
"Have the architecture-reviewer check this implementation"

# Creating commits
"Use the git-commit agent to commit these changes"

# Researching options
"Use the research-analyst to investigate state management solutions"

# End of session
"Use the context-maintainer to update documentation based on today's work"
```

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

- 🟡 Use the `spec-writer` agent to define testable requirements before implementation
- 🔴 Before writing tests, discover existing test patterns by searching for test files
- 🟡 Look for package.json scripts, Makefile, or just/task runners for test commands
- 🟡 If a request is meaningful in business terms, express it as a test
- 🔴 Focus tests on important business requirements - what NEEDS to be true
- 🟡 Make test names expressive in product/business terms, not technical terms
- 🔴 Do not test implementation details
- 🔴 Always verify solutions with existing test frameworks when available
- 🟡 Ask for clarification on test commands if not obvious from codebase
- 🟡 Use existing test data/fixtures rather than creating new ones
- 🟡 Tests are REQUIRED for business logic, OPTIONAL for glue code and simple getters/setters

## Git Workflow

- 🔴 **Use the `git-commit` agent for all commits** - it ensures no Claude attribution and follows conventions
- 🟡 Default to `main` branch for new work unless specified otherwise
- 🟡 Work in git branches named for associated tickets/issues, may be in worktrees
- 🟡 Branch naming: `feature/description`, `fix/issue-number`, or `task/brief-description`
- 🟡 When creating PRs: use succinct bullet points for descriptions, avoid verbose explanations
- 🟡 For PRs: include issue number in title if applicable, use present tense verbs
- 🟡 Ask before pushing to remote repositories - user may prefer local commits only

## Pre-Commit Requirements

- 🔴 ALWAYS run type-checks and apply formatting before committing
- 🔴 Check for and remove temporary files before commits
- 🟡 Verify linting passes, tests pass, and docs are current
- 🟡 If pre-commit hooks fail, fix issues before retrying commit
- 🟡 If formatting/linting tools aren't available, follow manual code style guidelines

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
- 🟡 Be cautious with file permissions - prefer 644 for files, 755 for executables
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

- 🔴 At start of new projects, always search for: README, package.json, Cargo.toml, pyproject.toml
- 🟡 Look for existing CLAUDE.md or similar project-specific instructions
- 🟡 Check for .gitignore to understand project structure and ignored files
- 🟡 Identify the main entry point (main.py, index.js, src/main.rs, etc.)
- 🟡 Note any monorepo structure (lerna.json, nx.json, workspaces in package.json)

## File Management Preferences

- 🔴 Always use absolute paths in responses and tool calls
- 🔴 Before creating new files, search extensively for existing similar files to edit instead
- 🟡 When editing config files, back up the original approach by reading the full file first
- 🟡 For large files, use offset/limit parameters in Read tool to avoid truncation
- 🟡 Create new files only when: explicitly requested, no suitable existing file found, or implementing a completely new feature

## Tmux Strategy for Background Processes

### Core Philosophy

- **Use tmux windows within the same session** - Keeps all project work organized together
- **IMMEDIATELY rename Claude Code window to 'agent'** - Prevents accidental self-termination
- **Use descriptive window names** that clearly indicate their purpose
- **Never kill windows by name 'agent'** - This is our main Claude Code process

### Initial Setup (CRITICAL)

```bash
# FIRST THING: Rename current window to 'agent' to identify Claude Code
tmux rename-window agent

# Verify we're in the 'agent' window
tmux display-message -p '#W'  # Should show 'agent'
```

### Window Naming Convention

Use prefixed names for clarity:

- `agent` - Claude Code main process (DO NOT KILL)
- `dev-<service>` - Development servers
- `log-<service>` - Log tailing
- `test` - Test runners
- `bg-<task>` - Background tasks

### Essential Tmux Commands

#### Starting Background Processes

```bash
# ALWAYS rename Claude Code window first
tmux rename-window agent

# Create new window for dev server
tmux new-window -n dev-frontend -d 'npm run dev'

# Create window for backend server with proper directory
tmux new-window -n dev-backend -d 'cd backend && npm start'

# Start a log tail in new window
tmux new-window -n log-app -d 'tail -f app.log'
```

#### Managing Windows

```bash
# List all windows in current session
tmux list-windows

# Check if specific window exists
tmux list-windows | grep dev-frontend

# Switch to window (then return with Ctrl-b and window number)
tmux select-window -t dev-frontend

# Send commands to specific window
tmux send-keys -t dev-frontend C-c  # Send Ctrl-C to stop server
tmux send-keys -t dev-frontend 'npm run dev' Enter  # Restart server

# Kill specific window (NEVER use on 'agent')
tmux kill-window -t dev-frontend

# Return to agent window
tmux select-window -t agent
```

#### Viewing Output Without Switching

```bash
# Capture current window output to file
tmux capture-pane -t dev-frontend -p > server-output.txt

# Show last 50 lines of output from specific window
tmux capture-pane -t dev-frontend -p -S -50

# Monitor output in real-time
tmux pipe-pane -t dev-frontend -o 'cat > server-live.log'
```

### Common Workflows

#### Starting a Full Stack Application

```bash
# 1. CRITICAL: Rename current window
tmux rename-window agent

# 2. Check existing windows
tmux list-windows

# 3. Start frontend dev server
tmux new-window -n dev-frontend -d 'npm run dev'

# 4. Start backend server
tmux new-window -n dev-backend -d 'cd backend && npm run server'

# 5. Start log monitoring
tmux new-window -n log-backend -d 'cd backend && tail -f logs/app.log'

# 6. Verify all windows are running
tmux list-windows
```

#### Testing with Live Server

```bash
# Ensure we're in agent window
tmux rename-window agent

# Start server in new window
tmux new-window -n dev-app -d 'npm run dev'

# Wait for server to be ready
sleep 5

# Check server output
tmux capture-pane -t dev-app -p | tail -20

# Run tests or use playwright/curl against running server
curl http://localhost:3000/health

# When done, cleanup (NOT the agent window!)
tmux kill-window -t dev-app
```

#### Debugging Server Issues

```bash
# Start server with verbose logging in new window
tmux new-window -n dev-debug -d 'NODE_ENV=development npm run dev:verbose'

# Monitor output without switching windows
watch -n 2 "tmux capture-pane -t dev-debug -p | tail -30"

# Send commands if needed
tmux send-keys -t dev-debug C-c  # Stop
tmux send-keys -t dev-debug 'npm run dev:verbose' Enter  # Restart

# Clean up when done
tmux kill-window -t dev-debug
```

### Critical Safety Rules (READ FIRST)

🔴 **NEVER kill the 'agent' window - this terminates Claude Code**

1. 🔴 IMMEDIATELY rename Claude Code window: `tmux rename-window agent`
2. 🔴 Always verify window names before killing: `tmux list-windows`
3. 🔴 Use window names, not numbers: `tmux kill-window -t dev-server` (not `-t 1`)
4. 🟡 Always use `-d` flag when creating new windows (detached mode)
5. 🟡 Capture output to files for analysis rather than switching windows constantly

### Window Management Best Practices

```bash
# Safe cleanup pattern
tmux list-windows  # Check what's running
tmux kill-window -t dev-frontend  # Kill specific window by name
tmux kill-window -t dev-backend   # Kill another specific window
# NEVER: tmux kill-window -t agent

# Safe way to clean all dev/test windows but preserve agent
for window in $(tmux list-windows -F '#W' | grep -v '^agent$'); do
  tmux kill-window -t "$window"
done
```

### Integration with Other Tools

- When using Chrome Dev Tools MCP: Start dev server in tmux window first, then interact with browser
- For API testing: Start backend in tmux window, use curl/httpie in agent window
- For log analysis: Tail logs in tmux window, analyze captured output in agent

## Custom Slash Commands

These slash commands chain agents together for quality-assured workflows:

### Available Commands

- **`/review-and-commit`** - Implement → Review → Fix → Commit cycle
- **`/spec-to-prod`** - Spec → Build → Test → Review → Commit pipeline
- **`/research-and-build`** - Research → Implement → Validate → Commit
- **`/refactor-safely`** - Refactor → Test → Review → Commit
- **`/test-and-fix`** - Test → Fix → Review → Commit
- **`/full-review`** - Comprehensive multi-perspective review
- **`/quick-commit`** - Fast commit without review (simple changes only)
- **`/docs-from-code`** - Generate documentation from implementation

### Usage Examples

```bash
# Implement with architectural review before committing
/review-and-commit implement user authentication

# Full feature pipeline from spec to production
/spec-to-prod add real-time notifications

# Research best approach before building
/research-and-build implement caching strategy

# Safe refactoring with validation
/refactor-safely extract payment logic to service

# Quick commit for simple changes
/quick-commit fix typo in README
```

Commands are defined in `~/.claude/commands/` directory as individual markdown files and ensure consistent quality through agent orchestration.
