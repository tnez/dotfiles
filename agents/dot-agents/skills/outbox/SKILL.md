---
name: outbox
description: Copy the current session log to PARA/DESK/outbox for pickup on Heimdall. Use at the end of a session when Travis asks to save the log.
---

# Outbox

Copy the current conversation's session log to `~/PARA/DESK/outbox/` so it can
be picked up on Heimdall.

## Steps

1. Find the most recent session log for the active harness and current project.
   Prefer a project-specific match, then fall back to the most recently modified
   session log if the harness does not expose a clear project path.

   Claude project session logs commonly live under:

   ```bash
   ~/.claude/projects/$(echo "$PWD" | sed 's|/|-|g; s|^-||')/*.jsonl
   ```

   Codex session logs commonly live under:

   ```bash
   find ~/.codex/sessions -name '*.jsonl' -type f -print
   ```

2. Prompt for a filename suffix if `$ARGUMENTS` is empty. Otherwise use
   `$ARGUMENTS` as the suffix. Format the destination filename as
   `YYYY-MM-DD--<suffix>.jsonl` using today's date.
3. Copy the file to `~/PARA/DESK/outbox/<filename>`.
4. Confirm the copy with the file size and destination path.
