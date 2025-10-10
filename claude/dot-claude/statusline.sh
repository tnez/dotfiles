#!/usr/bin/env bash
#
# Claude Code Custom Status Line
# Multi-line status with context tracking, MCP monitoring, and AI summaries
#

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Parse session ID first (needed for cache keys)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

# Cache files (session-specific)
CACHE_DIR="/tmp/claude-statusline"
CONTEXT_CACHE="$CACHE_DIR/context-${SESSION_ID}.json"

# Context calculation constants
# Note: We use cache_read_input_tokens as a proxy for total context (includes messages + overhead)
# This matches what Claude Code reports in /context
CONTEXT_WINDOW=200000 # Full context window
CONTEXT_BUFFER=30000  # Safety buffer - warn before actually hitting limit
COMPACTION_THRESHOLD=$((CONTEXT_WINDOW - CONTEXT_BUFFER))

mkdir -p "$CACHE_DIR"

# Parse core fields from JSON input
MODEL=$(echo "$INPUT" | jq -r '.model.display_name // "Unknown"')
CURRENT_DIR=$(echo "$INPUT" | jq -r '.workspace.current_dir // "~"')
DIR_NAME=$(basename "$CURRENT_DIR")
OUTPUT_MODE=$(echo "$INPUT" | jq -r '.output_style.name // "default"')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // ""')
SESSION_DURATION_MS=$(echo "$INPUT" | jq -r '.cost.total_duration_ms // 0')

# Helper: Check if cache file is fresh (age < $1 seconds)
is_cache_fresh() {
  local cache_file=$1
  local max_age_seconds=$2

  if [[ ! -f "$cache_file" ]]; then
    return 1
  fi

  local file_age=$(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0)))
  [[ $file_age -lt $max_age_seconds ]]
}

# Helper: Get reset time as HH:MM
get_reset_time() {
  local duration_ms=$1
  local duration_sec=$((duration_ms / 1000))
  local five_hours_sec=$((5 * 60 * 60))

  # Calculate when session started
  local current_time=$(date +%s)
  local session_start=$((current_time - duration_sec))

  # Calculate when current 5-hour block ends
  local blocks_elapsed=$((duration_sec / five_hours_sec))
  local reset_time=$((session_start + ((blocks_elapsed + 1) * five_hours_sec)))

  # Format as HH:MM
  date -r "$reset_time" "+%H:%M" 2>/dev/null || echo "?"
}

# Helper: Get directory display with git repo awareness
get_directory_display() {
  local current_dir=$1

  # Check if we're in a git repo
  if git -C "$current_dir" rev-parse --git-dir >/dev/null 2>&1; then
    # We're in a git repo - show path from git root
    local git_root=$(git -C "$current_dir" rev-parse --show-toplevel 2>/dev/null)
    local repo_name=$(basename "$git_root")

    # Calculate relative path manually (realpath might not be available on macOS)
    if [[ "$current_dir" == "$git_root" ]]; then
      echo "$repo_name(git)"
    else
      local rel_path="${current_dir#$git_root/}"
      echo "$repo_name/$rel_path(git)"
    fi
  else
    # Not a git repo - just show basename
    echo "$(basename "$current_dir")"
  fi
}

# Helper: Get context tokens from latest message in transcript
get_conversation_tokens() {
  local transcript_path=$1

  if [[ ! -f "$transcript_path" ]]; then
    echo "0"
    return
  fi

  # Get cache_read_input_tokens from latest assistant message
  local tokens=$(tail -20 "$transcript_path" |
    jq -r 'select(.type == "assistant" and .message.usage) | .message.usage.cache_read_input_tokens // 0' 2>/dev/null |
    tail -1)

  if [[ -z "$tokens" ]] || [[ "$tokens" == "null" ]]; then
    echo "0"
    return
  fi

  if [[ -z "$tokens" ]] || [[ ! "$tokens" =~ ^[0-9]+$ ]]; then
    echo "0"
    return
  fi

  echo "$tokens"
}

# Helper: Get context indicator (shows accumulated token count with visual warning)
get_context_indicator() {
  local total_tokens=$1

  if [[ "$total_tokens" == "?" ]] || [[ ! "$total_tokens" =~ ^[0-9]+$ ]]; then
    echo "?"
    return
  fi

  # Format with 'k' suffix (divide by 1000)
  local tokens_k=$((total_tokens / 1000))

  # Calculate remaining tokens for warning indicators
  local remaining_tokens=$((COMPACTION_THRESHOLD - total_tokens))

  # Add visual indicator based on remaining context
  # < 30k remaining = !  (critical)
  # < 60k remaining = ~  (warning)
  # >= 60k remaining = no indicator
  local indicator=""
  if [[ $remaining_tokens -lt 30000 ]]; then
    indicator="!!!"
  elif [[ $remaining_tokens -lt 60000 ]]; then
    indicator="!"
  fi

  echo "${tokens_k}/200k${indicator}"
}

# ============================================================================
# LINE 1: Core Info (Directory, Model with Output Mode, Context)
# ============================================================================

build_line1() {
  # Get directory display (with git awareness)
  local dir_display=$(get_directory_display "$CURRENT_DIR")

  # Get total context tokens from transcript (cached)
  local total_tokens=""
  if is_cache_fresh "$CONTEXT_CACHE" 3; then
    total_tokens=$(cat "$CONTEXT_CACHE" 2>/dev/null || echo "?")
  else
    if [[ -f "$TRANSCRIPT_PATH" ]]; then
      total_tokens=$(get_conversation_tokens "$TRANSCRIPT_PATH")
      echo "$total_tokens" >"$CONTEXT_CACHE"
    else
      total_tokens="0"
      echo "0" >"$CONTEXT_CACHE"
    fi
  fi

  # Get context indicator (remaining tokens in k)
  local context_display=$(get_context_indicator "$total_tokens")

  echo "$dir_display | $MODEL (mode:$OUTPUT_MODE) | $context_display"
}

# ============================================================================
# LINE 2: System Status (Background Processes, MCP Servers)
# ============================================================================

build_line2() {
  # MCP servers - show CSV list of configured servers with status
  local mcp_servers=()

  # Check MCP config locations (Claude Code uses ~/.claude.json for user config)
  local mcp_configs=(
    "$HOME/.claude.json"
    "$CURRENT_DIR/.mcp.json"
  )

  for config in "${mcp_configs[@]}"; do
    if [[ -f "$config" ]]; then
      # Extract server names and check for basic config issues
      local servers=$(jq -r '.mcpServers // {} | keys[]' "$config" 2>/dev/null)
      if [[ -n "$servers" ]]; then
        while IFS= read -r server; do
          local server_display="$server"

          # Check for basic config issues (non-blocking)
          local server_type=$(jq -r ".mcpServers[\"$server\"].type // \"missing\"" "$config" 2>/dev/null)

          # For stdio servers, check if command exists
          if [[ "$server_type" == "stdio" ]]; then
            local cmd=$(jq -r ".mcpServers[\"$server\"].command // \"\"" "$config" 2>/dev/null)
            if [[ -n "$cmd" ]] && ! command -v "$cmd" >/dev/null 2>&1; then
              server_display="${server} (!)"
            fi
          elif [[ "$server_type" == "missing" ]]; then
            server_display="${server} (!)"
          fi

          mcp_servers+=("$server_display")
        done <<<"$servers"
      fi
    fi
  done

  # Build output
  if [[ ${#mcp_servers[@]} -eq 0 ]]; then
    echo "mcp: none"
  else
    # Join array with commas
    local mcp_list=$(printf "%s, " "${mcp_servers[@]}")
    mcp_list="${mcp_list%, }" # Remove trailing comma and space
    echo "mcp: ${mcp_list}"
  fi
}

# ============================================================================
# MAIN: Build and output status line
# ============================================================================

line1=$(build_line1)
line2=$(build_line2)

# Output all lines
echo "$line1"
echo "$line2"
