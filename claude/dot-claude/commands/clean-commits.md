# /clean-commits - Reorganize feature branch commits into logical chunks

Analyzes and reorganizes feature branch commits to tell the story of WHAT was done rather than HOW it was developed.

## Usage

```
/clean-commits
```

## Process

1. **Analyze Current Branch**
   - Identify all commits since diverging from main/master
   - Review changes across all commits holistically
   - Understand the overall feature/fix being implemented

2. **Plan Logical Commit Structure**
   - Group related changes by functionality/purpose
   - Identify commits that should be squashed together
   - Determine optimal commit order for clarity
   - Draft meaningful commit messages that explain the "why"

3. **Interactive Rebase Strategy**
   - Create a rebase plan with pick/squash/reword/edit commands
   - Ensure each final commit represents a logical, atomic change
   - Maintain build integrity at each commit point

4. **Execute Rebase**
   - Guide through interactive rebase process
   - Handle any conflicts that arise
   - Verify each commit still passes tests/builds

5. **Final Review**
   - Confirm new commit history tells a clear story
   - Ensure commit messages follow project conventions
   - Verify no changes were lost in the process

## Example Transformations

### Before (work history):
```
- fix typo
- WIP: add auth
- more auth stuff
- fix test
- update auth logic
- cleanup
```

### After (logical history):
```
- feat: add authentication system with JWT tokens
- test: add comprehensive auth test coverage
- docs: update API documentation for auth endpoints
```

## Guidelines

- Each commit should be independently revertable
- Commits should be ordered logically (e.g., refactors before features)
- Related test/docs changes can be combined with their implementation
- Commit messages should explain WHY not just WHAT
- Preserve authorship and important metadata

## Safety Checks

- Always work on a backup branch first
- Verify no changes are lost with `git diff origin/main...HEAD`
- Ensure force-push is safe (no other collaborators on branch)
- Keep original branch as backup until PR is merged