---
name: outbox
description: Copy the current session log to PARA/DESK/outbox for pickup on Heimdall. Use at the end of a session when Travis asks to save the log.
disable-model-invocation: true
allowed-tools: Bash, Glob
---

# Outbox

Load and follow the harness-agnostic `outbox` skill.

The source of truth is:

`~/.agents/skills/outbox/SKILL.md`

Use the skill named `outbox`. If the skill tool does not list it, read the file
above directly and follow its instructions.

If $ARGUMENTS is non-empty, pass it through as the filename suffix:

$ARGUMENTS
