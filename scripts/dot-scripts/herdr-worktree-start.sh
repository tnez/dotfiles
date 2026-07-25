#!/usr/bin/env bash
# Create isolated branch work in a new tab and start a worker agent.

set -Eeuo pipefail

agent_kind=opencode
agent_name=""
base=main
branch=""
check_only=false
focus=false
label=""
repo=$PWD
workspace="${HERDR_WORKSPACE_ID:-}"
native_agent_args=()

usage() {
  cat <<'EOF'
Usage:
  herdr-worktree-start.sh --branch BRANCH [options] \
    [-- <agent-args...>] < prompt.txt
  herdr-worktree-start.sh --check [options]

Options:
  --agent-kind KIND   Worker kind accepted by `herdr agent start` (default: opencode)
  --agent-name NAME   Unique Herdr agent name (default: derived from repo and branch)
  --base REF          Explicit branch base (default: main)
  --branch BRANCH     New branch and worktree name
  --check             Validate prerequisites without creating anything
  --focus             Focus the new tab after starting the worker
  --label LABEL       Tab label (default: branch, truncated to 32 characters)
  --no-focus          Keep focus in the coordinating tab (default)
  --repo PATH         Repository or checkout path (default: current directory)
  --workspace ID      Target Herdr workspace (default: calling workspace)
  --help              Show this help

The worker prompt is read from standard input. This command intentionally uses
wtp for checkout creation and Herdr only for tab and agent orchestration.
Arguments after -- are passed unchanged to the native agent command.
EOF
}

fail() {
  printf 'herdr-worktree-start: %s\n' "$*" >&2
  exit 1
}

compact_label() {
  local value=$1

  if (( ${#value} <= 32 )); then
    printf '%s\n' "$value"
  else
    printf '%s...\n' "${value:0:29}"
  fi
}

default_agent_name() {
  local branch_name=$1 hash raw repository=$2 value

  raw="${repository}-${branch_name}"
  value="$(
    LC_ALL=C tr '[:upper:]' '[:lower:]' <<<"$raw" |
      tr -cs 'a-z0-9_-' '-' |
      tr -d '\n'
  )"
  value=${value#-}
  value=${value%-}
  [[ "$value" == [a-z]* ]] || value="work-$value"
  if (( ${#value} <= 32 )); then
    printf '%s\n' "$value"
  else
    hash="$(git hash-object --stdin <<<"$raw")"
    printf '%.24s-%.7s\n' "$value" "$hash"
  fi
}

absolute_git_common_dir() {
  local directory=$1 common_dir

  common_dir="$(
    git -C "$directory" rev-parse --path-format=absolute --git-common-dir \
      2>/dev/null
  )" || return 1
  (cd "$common_dir" && pwd -P)
}

primary_worktree() {
  local candidate="" directory=$1 line

  while IFS= read -r line; do
    case "$line" in
      'worktree '*) candidate=${line#worktree } ;;
      bare) candidate="" ;;
      '')
        if [[ -n "$candidate" ]]; then
          printf '%s\n' "$candidate"
          return 0
        fi
        ;;
    esac
  done < <(git -C "$directory" worktree list --porcelain)

  [[ -z "$candidate" ]] || printf '%s\n' "$candidate"
}

repository_name() {
  local primary=$1

  if [[ "${primary##*/}" == main ]]; then
    printf '%s\n' "$(basename "${primary%/*}")"
  else
    printf '%s\n' "${primary##*/}"
  fi
}

workspace_has_repository() {
  local candidate common_dir=$1 panes=$2

  while IFS= read -r candidate; do
    [[ -d "$candidate" ]] || continue
    if [[ "$(absolute_git_common_dir "$candidate" || true)" == "$common_dir" ]]; then
      return 0
    fi
  done < <(jq -r '.result.panes[]?.cwd' <<<"$panes")

  return 1
}

wait_for_available_shell() {
  local attempt info pane=$1

  for ((attempt = 0; attempt < 50; attempt++)); do
    if info="$(herdr pane process-info --pane "$pane" 2>/dev/null)" &&
      jq -e \
        '.result.process_info as $info
         | any($info.foreground_processes[]?; .pid == $info.shell_pid)' \
        >/dev/null <<<"$info"; then
      return 0
    fi
    sleep 0.1
  done

  return 1
}

while (( $# > 0 )); do
  case "$1" in
    --agent-kind)
      [[ $# -ge 2 ]] || fail '--agent-kind requires a value'
      agent_kind=$2
      shift 2
      ;;
    --agent-name)
      [[ $# -ge 2 ]] || fail '--agent-name requires a value'
      agent_name=$2
      shift 2
      ;;
    --base)
      [[ $# -ge 2 ]] || fail '--base requires a value'
      base=$2
      shift 2
      ;;
    --branch)
      [[ $# -ge 2 ]] || fail '--branch requires a value'
      branch=$2
      shift 2
      ;;
    --check)
      check_only=true
      shift
      ;;
    --focus)
      focus=true
      shift
      ;;
    --label)
      [[ $# -ge 2 ]] || fail '--label requires a value'
      label=$2
      shift 2
      ;;
    --no-focus)
      focus=false
      shift
      ;;
    --repo)
      [[ $# -ge 2 ]] || fail '--repo requires a value'
      repo=$2
      shift 2
      ;;
    --workspace)
      [[ $# -ge 2 ]] || fail '--workspace requires a value'
      workspace=$2
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --)
      native_agent_args=("${@:2}")
      break
      ;;
    *)
      fail "unknown argument: $1"
      ;;
  esac
done

[[ "${HERDR_ENV:-}" == 1 ]] || fail 'run this from a Herdr-managed pane'
[[ -n "$workspace" ]] || fail 'no target workspace; pass --workspace ID'

for command in git herdr jq wtp; do
  command -v "$command" >/dev/null 2>&1 || fail "required command not found: $command"
done

repo="$(git -C "$repo" rev-parse --show-toplevel 2>/dev/null)" ||
  fail "not a Git checkout: $repo"
repo="$(cd "$repo" && pwd -P)"
common_dir="$(absolute_git_common_dir "$repo")" ||
  fail "cannot resolve Git common directory: $repo"
primary="$(primary_worktree "$repo")"
[[ -n "$primary" ]] || fail "cannot resolve primary worktree: $repo"
repo="$(cd "$primary" && pwd -P)"
[[ -f "$repo/.wtp.yml" ]] || fail "wtp is not initialized in primary checkout: $repo"
panes="$(herdr pane list --workspace "$workspace")" ||
  fail "cannot inspect Herdr workspace: $workspace"
workspace_has_repository "$common_dir" "$panes" ||
  fail "workspace $workspace does not contain a checkout for $repo"

if [[ "$check_only" == true ]]; then
  jq -n \
    --arg common_dir "$common_dir" \
    --arg repo "$repo" \
    --arg workspace "$workspace" \
    '{status: "ok", repo: $repo, common_dir: $common_dir, workspace: $workspace}'
  exit 0
fi

[[ -n "$branch" ]] || fail '--branch is required'
[[ -n "$base" ]] || fail '--base cannot be empty'
[[ ! -t 0 ]] || fail 'provide the worker prompt on standard input'
prompt="$(cat)"
[[ -n "${prompt//[[:space:]]/}" ]] || fail 'worker prompt cannot be empty'

if [[ -z "$label" ]]; then
  label="$(compact_label "$branch")"
fi
if [[ -z "$agent_name" ]]; then
  agent_name="$(default_agent_name "$branch" "$(repository_name "$repo")")"
fi
[[ "$agent_name" =~ ^[a-z][a-z0-9_-]{0,31}$ ]] ||
  fail 'agent name must match [a-z][a-z0-9_-]{0,31}'
agents="$(herdr agent list)" || fail 'cannot inspect existing Herdr agents'
if jq -e --arg name "$agent_name" \
  'any(.result.agents[]?; .name == $name)' >/dev/null <<<"$agents"; then
  fail "agent name is already in use: $agent_name"
fi

worktree_path="$(
  cd "$repo"
  wtp add -b "$branch" "$base" --quiet
)" ||
  fail "could not create branch $branch from $base"
worktree_path="$(cd "$worktree_path" && pwd -P)"

focus_flag=--no-focus
[[ "$focus" == false ]] || focus_flag=--focus
tab_result="$(
  herdr tab create \
    --workspace "$workspace" \
    --cwd "$worktree_path" \
    --label "$label" \
    "$focus_flag"
)" || fail "worktree created at $worktree_path, but Herdr tab creation failed"
tab_id="$(jq -r '.result.tab.tab_id' <<<"$tab_result")"
pane_id="$(jq -r '.result.root_pane.pane_id' <<<"$tab_result")"

wait_for_available_shell "$pane_id" ||
  fail "worktree and tab created ($worktree_path, $tab_id), but its shell did not become ready"
agent_started=false
for ((attempt = 0; attempt < 40; attempt++)); do
  agent_start_command=(
    herdr agent start "$agent_name"
    --kind "$agent_kind"
    --pane "$pane_id"
  )
  if (( ${#native_agent_args[@]} > 0 )); then
    agent_start_command+=(-- "${native_agent_args[@]}")
  fi
  if agent_start_result="$("${agent_start_command[@]}" 2>&1)"; then
    agent_started=true
    break
  fi
  [[ "$agent_start_result" == *'"code":"agent_pane_busy"'* ]] || break
  sleep 0.25
done
if [[ "$agent_started" == false ]]; then
  printf '%s\n' "$agent_start_result" >&2
  fail "worktree and tab created ($worktree_path, $tab_id), but agent startup failed"
fi
herdr agent prompt "$agent_name" "$prompt" \
  --wait \
  --until idle \
  --until working \
  --until blocked \
  --until 'done' \
  --until unknown \
  >/dev/null ||
  fail "worker $agent_name started in $tab_id, but prompt submission failed"

jq -n \
  --arg agent "$agent_name" \
  --arg branch "$branch" \
  --arg pane_id "$pane_id" \
  --arg path "$worktree_path" \
  --arg tab_id "$tab_id" \
  --arg workspace "$workspace" \
  '{
    status: "started",
    branch: $branch,
    path: $path,
    workspace: $workspace,
    tab_id: $tab_id,
    pane_id: $pane_id,
    agent: $agent
  }'
