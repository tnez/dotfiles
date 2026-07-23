#!/bin/bash
# Create or focus Herdr workspaces matching the configured sesh activities.

set -Eeuo pipefail

creating_workspace=""
workspace_aliases="${XDG_CONFIG_HOME:-$HOME/.config}/herdr/workspace-aliases.conf"

cleanup_partial_session() {
  local status=$1

  trap - ERR INT TERM
  if [[ -n "$creating_workspace" ]]; then
    herdr workspace close "$creating_workspace" >/dev/null 2>&1 || true
  fi
  exit "$status"
}

list_sessions() {
  {
    printf '%s\n' home scratch inbox plan helm mission-control
    printf '%s\n' standup weekly-review coffee-chat
    herdr workspace list |
      jq -r '.result.workspaces[]?.label'
    list_directories
  } | sort -u
}

list_directories() {
  local directory tilde='~'

  {
    if command -v zoxide >/dev/null 2>&1; then
      zoxide query -l
    fi

    if command -v fd >/dev/null 2>&1; then
      fd --type d --min-depth 1 --max-depth 2 \
        --exclude .git . "$HOME/Code" 2>/dev/null || true
      list_git_roots
      fd --type d --min-depth 1 --max-depth 1 \
        . "$HOME/PARA/PROJECTS" 2>/dev/null || true
      fd --type d --min-depth 1 --max-depth 1 \
        . "$HOME/PARA/AREAS" 2>/dev/null || true
    fi
  } | while IFS= read -r directory; do
    [[ "$directory" == / ]] || directory=${directory%/}
    case "$directory" in
      "$HOME") printf '%s\n' "$tilde" ;;
      "$HOME"/*)
        printf '%s/%s\n' "$tilde" "${directory#"$HOME"/}"
        ;;
      *) printf '%s\n' "$directory" ;;
    esac
  done
}

list_git_roots() {
  local marker

  [[ -d "$HOME/Code" ]] || return 0

  fd --hidden --type f --type d --prune '^\.git$' \
    "$HOME/Code" 2>/dev/null | while IFS= read -r marker; do
    marker=${marker%/}
    printf '%s\n' "${marker%/.git}"
  done || true
}

resolve_directory() {
  local directory=$1 tilde='~'

  if [[ "$directory" == "$tilde" ]]; then
    directory=$HOME
  elif [[ "$directory" == "$tilde/"* ]]; then
    directory="$HOME/${directory:2}"
  fi

  if [[ ! -d "$directory" ]] && command -v zoxide >/dev/null 2>&1; then
    directory="$(zoxide query -- "$directory" 2>/dev/null || true)"
  fi

  [[ -d "$directory" ]] || return 1
  (cd "$directory" && pwd -P)
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

repository_token() {
  local key part repository=$1 token="" value
  local -a parts

  if [[ -r "$workspace_aliases" ]]; then
    while IFS='=' read -r key value; do
      [[ -n "$key" && "$key" != '#'* ]] || continue
      if [[ "$key" == "$repository" && -n "$value" ]]; then
        printf '%s\n' "$value"
        return 0
      fi
    done <"$workspace_aliases"
  fi

  if (( ${#repository} <= 12 )); then
    printf '%s\n' "$repository"
    return 0
  fi

  IFS='-' read -r -a parts <<<"$repository"
  for part in "${parts[@]}"; do
    [[ -z "$part" ]] || token+="${part:0:1}"
  done

  if (( ${#token} < 2 )); then
    token=${repository:0:12}
  fi
  printf '%s\n' "$token"
}

directory_workspace_label() {
  local branch directory=$1 parent primary repository token toplevel

  toplevel="$(git -C "$directory" rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ -z "$toplevel" ]]; then
    printf '%s\n' "${directory##*/}"
    return 0
  fi
  toplevel="$(cd "$toplevel" && pwd -P)"

  # Preserve useful labels for zoxide entries inside a repository.
  if [[ "$directory" != "$toplevel" ]]; then
    printf '%s\n' "${directory##*/}"
    return 0
  fi

  primary="$(primary_worktree "$directory")"
  primary="$(cd "$primary" && pwd -P)"
  parent=${primary%/*}
  repository=${primary##*/}
  if [[ "$repository" == main &&
    ( -f "$primary/.wtp.yml" || -d "$parent/.bare" ) ]]; then
    repository=${parent##*/}
  fi

  if [[ "$directory" == "$primary" ]]; then
    printf '%s\n' "$repository"
    return 0
  fi

  branch="$(git -C "$directory" branch --show-current)"
  if [[ -z "$branch" ]]; then
    branch="detached-$(git -C "$directory" rev-parse --short HEAD)"
  fi
  token="$(repository_token "$repository")"
  printf '%s@%s\n' "$branch" "$token"
}

configure_session() {
  local mission_config name=$1

  tabs=()
  commands=()

  case "$name" in
    home)
      path="$HOME"
      tabs=(home)
      commands=('')
      ;;
    scratch)
      path="$HOME/PARA/DESK/inbox"
      tabs=(scratch)
      commands=("nvim \"$HOME/PARA/DESK/inbox/scratch.md\"")
      ;;
    inbox)
      path="$HOME/PARA/DESK"
      tabs=(desk-inbox desktop desk-outbox)
      commands=(
        "yazi \"$HOME/PARA/DESK/inbox\""
        "yazi \"$HOME/Desktop\""
        "yazi \"$HOME/PARA/DESK/outbox\""
      )
      ;;
    plan)
      path="$HOME/PARA"
      tabs=(dottie notes)
      commands=(
        'claude --permission-mode auto'
        "nvim \"$HOME/PARA\""
      )
      ;;
    helm)
      path="$HOME"
      tabs=(gh-dashboard calendar reminders desk-inbox)
      commands=(
        "\"$HOME/.scripts/gh-dashboard.sh\""
        "\"$HOME/.scripts/helm-calendar.sh\""
        "\"$HOME/.scripts/helm-reminders.sh\""
        "yazi \"$HOME/PARA/DESK/inbox\""
      )
      ;;
    mission-control)
      path="$HOME/Code/dottie-weaver/identity"
      mission_config="$HOME/Code/tnez/dotfiles/hud/dot-config/hud"
      tabs=(mission-control dottie notes)
      commands=(
        "hud --config \"$mission_config/mission-control.toml\""
        'claude --permission-mode auto'
        "nvim \"$HOME/PARA\""
      )
      ;;
    standup)
      path="$HOME/PARA"
      tabs=(gh-dashboard calendar notes)
      commands=(
        "\"$HOME/.scripts/gh-dashboard.sh\""
        "\"$HOME/.scripts/helm-calendar.sh\""
        "nvim \"$HOME/PARA\""
      )
      ;;
    weekly-review)
      path="$HOME/PARA/DESK"
      tabs=(desk-inbox desk-outbox dottie)
      commands=(
        "yazi \"$HOME/PARA/DESK/inbox\""
        "yazi \"$HOME/PARA/DESK/outbox\""
        'claude --permission-mode auto'
      )
      ;;
    coffee-chat)
      path="$HOME/PARA"
      tabs=(dottie notes)
      commands=(
        'claude --permission-mode auto'
        "nvim \"$HOME/PARA\""
      )
      ;;
    *)
      return 1
      ;;
  esac
}

workspace_id() {
  local name=$1

  herdr workspace list |
    jq -r --arg name "$name" \
      'first(.result.workspaces[]? | select(.label == $name)
       | .workspace_id) // ""'
}

focus_tab() {
  local workspace=$1
  local label=$2
  local tab

  [[ -n "$label" ]] || return 0
  tab="$(
    herdr tab list --workspace "$workspace" |
      jq -r --arg label "$label" \
        'first(.result.tabs[]? | select(.label == $label) | .tab_id) // ""'
  )"
  [[ -z "$tab" ]] || herdr tab focus "$tab" >/dev/null
}

preview_session() {
  local directory name=$1 workspace

  workspace="$(workspace_id "$name")"
  if [[ -n "$workspace" ]]; then
    herdr tab list --workspace "$workspace" |
      jq -r '.result.tabs[] | "\(.number):\(.label)  \(.pane_count) pane(s)"'
    return
  fi

  if configure_session "$name"; then
    printf 'new workspace\n%s\n\n' "$path"
    printf '%s\n' "${tabs[@]}"
    return
  fi

  directory="$(resolve_directory "$name" || true)"
  if [[ -n "$directory" ]]; then
    exec "$HOME/.scripts/tv-sesh-preview.sh" "$directory"
  fi
}

create_directory_workspace() {
  local directory label target=$1 workspace

  directory="$(resolve_directory "$target")" || return 1
  label="$(directory_workspace_label "$directory")"
  [[ -n "$label" ]] || label=root

  workspace="$(workspace_id "$label")"
  if [[ -n "$workspace" ]]; then
    herdr workspace focus "$workspace" >/dev/null
    return
  fi

  herdr workspace create \
    --cwd "$directory" \
    --label "$label" \
    --focus >/dev/null
}

create_session() {
  local name=$1
  local requested_tab=${2:-}
  local result workspace tab pane command i

  workspace="$(workspace_id "$name")"
  if [[ -n "$workspace" ]]; then
    herdr workspace focus "$workspace" >/dev/null
    focus_tab "$workspace" "$requested_tab"
    return
  fi

  if ! configure_session "$name"; then
    if create_directory_workspace "$name"; then
      return
    fi

    printf 'Unknown Herdr workspace or directory: %s\n' "$name" >&2
    exit 2
  fi

  result="$(
    herdr workspace create --cwd "$path" --label "$name" --focus
  )"
  workspace="$(jq -r '.result.workspace.workspace_id' <<<"$result")"
  creating_workspace="$workspace"
  trap 'cleanup_partial_session $?' ERR
  trap 'cleanup_partial_session 130' INT TERM

  tab="$(jq -r '.result.tab.tab_id' <<<"$result")"
  pane="$(jq -r '.result.root_pane.pane_id' <<<"$result")"

  herdr tab rename "$tab" "${tabs[0]}" >/dev/null
  command=${commands[0]}
  [[ -z "$command" ]] || herdr pane run "$pane" "$command" >/dev/null

  for ((i = 1; i < ${#tabs[@]}; i++)); do
    result="$(
      herdr tab create \
        --workspace "$workspace" \
        --cwd "$path" \
        --label "${tabs[$i]}" \
        --no-focus
    )"
    pane="$(jq -r '.result.root_pane.pane_id' <<<"$result")"
    command=${commands[$i]}
    [[ -z "$command" ]] || herdr pane run "$pane" "$command" >/dev/null
  done

  focus_tab "$workspace" "${requested_tab:-${tabs[0]}}"
  creating_workspace=""
  trap - ERR INT TERM
}

case "${1:-}" in
  --list)
    list_sessions
    ;;
  --preview)
    preview_session "${2:-}"
    ;;
  '')
    printf 'Usage: %s <session> [tab]\n' "${0##*/}" >&2
    exit 2
    ;;
  *)
    create_session "$1" "${2:-}"
    ;;
esac
