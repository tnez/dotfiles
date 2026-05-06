#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ "$FILE" == *"/.claude/projects/"*"/memory/"* ]]; then
  cat >&2 <<'MSG'
BLOCKED: You are Dottie Weaver. You have your own memory system.
Do not use Claude Code's built-in memory infrastructure.
MSG
  exit 2
fi
exit 0
