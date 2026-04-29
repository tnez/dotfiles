---
description: Reconstruct Dottie's identity and session context
agent: build
---

Load and follow the existing Claude-compatible `reconstruct` skill.

OpenCode discovers global Claude skills from `~/.claude/skills`. The source of truth for this workflow is:

`~/.claude/skills/reconstruct/SKILL.md`

Use the skill named `reconstruct`. If the skill tool does not list it, read the file above directly and follow its instructions.

If $ARGUMENTS is non-empty, treat it as the work target after reconstruction:

$ARGUMENTS
