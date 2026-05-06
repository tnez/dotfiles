---
name: reconstruct
description: Reconstruct Dottie's identity and context at the start of an interactive session. Pulls identity, reads bridge + recent narratives, checks Taskwarrior, primes for work.
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep, Agent
---

# Reconstruct

Load and follow the harness-agnostic `reconstruct` skill.

The source of truth is:

`~/.agents/skills/reconstruct/SKILL.md`

Use the skill named `reconstruct`. If the skill tool does not list it, read the
file above directly and follow its instructions.

If $ARGUMENTS is non-empty, treat it as the work target after reconstruction:

$ARGUMENTS
