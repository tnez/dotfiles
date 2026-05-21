#!/bin/bash
set -euo pipefail

kind="${1:-}"
action="${2:-}"
entry="${3:-}"
target="${entry%%$'\t'*}"

if [[ "$target" != *#* ]]; then
  printf 'No GitHub object selected.\n' >&2
  exit 0
fi

repo="${target%%#*}"
number="${target##*#}"

repo_path() {
  case "$repo" in
    tnez/*)
      printf '%s\n' "$HOME/Code/tnez/${repo#tnez/}"
      ;;
    tnezdev/*)
      printf '%s\n' "$HOME/Code/tnezdev/${repo#tnezdev/}"
      ;;
    scoutos-labs/*)
      printf '%s\n' "$HOME/Code/scoutos-labs/${repo#scoutos-labs/}"
      ;;
    dottie-weaver/*)
      printf '%s\n' "$HOME/Code/dottie-weaver/${repo#dottie-weaver/}"
      ;;
    *)
      return 1
      ;;
  esac
}

jump_repo() {
  local path
  path="$(repo_path)" || {
    printf 'No local path mapping for %s\n' "$repo" >&2
    exit 1
  }

  if [[ ! -d "$path" ]]; then
    printf 'Local checkout not found: %s\n' "$path" >&2
    exit 1
  fi

  exec sesh connect "$path"
}

confirm_close() {
  printf 'Type close to close %s#%s: ' "$repo" "$number" >&2
  local answer
  read -r answer
  [[ "$answer" == "close" ]]
}

confirm_approve() {
  printf 'Type approve to approve %s#%s: ' "$repo" "$number" >&2
  local answer
  read -r answer
  [[ "$answer" == "approve" ]]
}

request_changes() {
  local body_file
  body_file="$(mktemp)"
  trap 'rm -f "$body_file"' EXIT

  cat >"$body_file" <<EOF
<!-- Write the changes-requested review body. Save and quit to submit. -->

EOF

  "${EDITOR:-nvim}" "$body_file"

  if ! grep -v '^<!--' "$body_file" | grep -q '[^[:space:]]'; then
    printf 'Request-changes review cancelled: empty body.\n' >&2
    exit 0
  fi

  exec gh pr review "$number" --repo "$repo" --request-changes --body-file "$body_file"
}

case "$kind:$action" in
  pr:view)
    exec ~/.scripts/tv-gh-workbench-preview.sh pr "$entry"
    ;;
  pr:browser)
    exec gh pr view "$number" --repo "$repo" --web
    ;;
  pr:checkout)
    exec gh pr checkout "$number" --repo "$repo"
    ;;
  pr:checks)
    exec gh pr checks "$number" --repo "$repo"
    ;;
  pr:diff)
    exec sh -c 'gh pr diff "$1" --repo "$2" | ${PAGER:-less}' sh "$number" "$repo"
    ;;
  pr:jump)
    jump_repo
    ;;
  pr:approve)
    if confirm_approve; then
      exec gh pr review "$number" --repo "$repo" --approve
    fi
    printf 'Approve cancelled.\n' >&2
    ;;
  pr:request-changes)
    request_changes
    ;;
  pr:agent-review)
    exec opencode "Review PR $target. Prioritize bugs, regressions, and missing tests."
    ;;

  issue:view)
    exec ~/.scripts/tv-gh-workbench-preview.sh issue "$entry"
    ;;
  issue:browser)
    exec gh issue view "$number" --repo "$repo" --web
    ;;
  issue:edit)
    exec gh issue edit "$number" --repo "$repo"
    ;;
  issue:comment)
    exec gh issue comment "$number" --repo "$repo"
    ;;
  issue:assign-me)
    exec gh issue edit "$number" --repo "$repo" --add-assignee @me
    ;;
  issue:assign-dottie)
    exec gh issue edit "$number" --repo "$repo" --add-assignee dottie-weaver
    ;;
  issue:add-ready)
    exec gh issue edit "$number" --repo "$repo" --add-label ready
    ;;
  issue:remove-ready)
    exec gh issue edit "$number" --repo "$repo" --remove-label ready
    ;;
  issue:jump)
    jump_repo
    ;;
  issue:close)
    if confirm_close; then
      exec gh issue close "$number" --repo "$repo"
    fi
    printf 'Close cancelled.\n' >&2
    ;;
  issue:agent-plan)
    exec opencode "Read issue $target and implement the smallest correct next step."
    ;;

  *)
    printf 'usage: %s {pr|issue} ACTION ENTRY\n' "$0" >&2
    exit 2
    ;;
esac
