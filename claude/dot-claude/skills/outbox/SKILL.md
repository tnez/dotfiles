---
name: outbox
description: Copy the current session log to PARA/DESK/outbox for pickup on Heimdall. Use at the end of a session when Travis asks to save the log.
disable-model-invocation: true
allowed-tools: Bash, Glob
---

# Outbox

Copy the current conversation's session log to `~/PARA/DESK/outbox/` so it can be picked up on Heimdall.

## Steps

1. Find the most recently modified `.jsonl` file in the current project's Claude session directory:

```bash
ls -t ~/.claude/projects/$(echo "$PWD" | sed 's|/|-|g; s|^-||')/*.jsonl | head -1
```

If that path doesn't resolve, try listing all project directories and matching by the current working directory name.

2. Prompt for a filename suffix if `$ARGUMENTS` is empty. Otherwise use `$ARGUMENTS` as the suffix. Format: `YYYY-MM-DD--<suffix>.jsonl` using today's date.

3. Copy the file:

```bash
cp <source> ~/PARA/DESK/outbox/<filename>
```

4. Confirm the copy with the file size and destination path.
