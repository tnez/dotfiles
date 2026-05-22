#!/bin/bash
set -euo pipefail

refresh_seconds=300
watch_mode=false
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/mission-control"
cache_ttl_seconds=300
active_owners=(tnez tnezdev scoutos-labs dottie-weaver)

if [[ "${1:-}" == "--watch" ]]; then
  watch_mode=true
fi

if [[ -t 1 ]]; then
  bold=$(tput bold 2>/dev/null || true)
  dim=$(tput dim 2>/dev/null || true)
  reset=$(tput sgr0 2>/dev/null || true)
else
  bold=""
  dim=""
  reset=""
fi

section() {
  printf '\n%s%s%s\n' "$bold" "$1" "$reset"
}

run_limited() {
  local timeout_seconds="$1"
  shift

  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$timeout_seconds" "$@"
  elif command -v timeout >/dev/null 2>&1; then
    timeout "$timeout_seconds" "$@"
  else
    "$@"
  fi
}

print_cached() {
  local key="$1"
  local ttl_seconds="$2"
  shift 2

  local cache_file now modified age tmp_file
  cache_file="$cache_dir/$key"
  now=$(date +%s)

  if [[ -f "$cache_file" ]]; then
    modified=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file")
    age=$((now - modified))
    if [[ "$age" -lt "$ttl_seconds" ]]; then
      cat "$cache_file"
      return
    fi
  fi

  mkdir -p "$cache_dir"
  tmp_file="$cache_file.$$"
  if "$@" >"$tmp_file" 2>/dev/null; then
    mv "$tmp_file" "$cache_file"
    cat "$cache_file"
    return
  fi

  rm -f "$tmp_file"
  if [[ -f "$cache_file" ]]; then
    cat "$cache_file"
    printf '%s\n' "${dim}(stale: refresh unavailable)${reset}"
  else
    printf 'Unavailable\n'
  fi
}

print_tmux() {
  section 'Tmux Sessions'

  if ! command -v tmux >/dev/null 2>&1; then
    printf 'tmux not installed\n'
    return
  fi

  if ! tmux list-sessions -F '#S|#{session_windows}|#{session_attached}' \
    2>/dev/null | sort | while IFS=$'\t' read -r name windows attached; do
      IFS='|' read -r name windows attached <<< "$name"
      marker=' '
      [[ "$attached" != '0' ]] && marker='*'
      printf '%s %-28s %2s windows\n' "$marker" "$name" "$windows"
    done; then
    printf 'No tmux server\n'
  fi
}

print_repos() {
  section 'Dirty Repos'

  local root repo status count
  count=0

  for root in "$HOME/Code/tnez" "$HOME/Code/tnezdev" \
    "$HOME/Code/scoutos-labs" "$HOME/Code/dottie-weaver"; do
    [[ -d "$root" ]] || continue

    for repo in "$root"/*; do
      [[ -d "$repo/.git" ]] || continue
      status=$(git -C "$repo" status --short 2>/dev/null || true)
      [[ -n "$status" ]] || continue

      count=$((count + 1))
      printf '%-38s %s changes\n' "${repo#"$HOME"/Code/}" \
        "$(printf '%s\n' "$status" | wc -l | tr -d ' ')"
    done
  done

  [[ "$count" -gt 0 ]] || printf 'Clean across tracked Code roots\n'
}

print_prs() {
  section 'GitHub Pull Requests'

  if ! command -v gh >/dev/null 2>&1; then
    printf 'gh not installed\n'
    return
  fi

  printf '%s\n' "${dim}Needs review${reset}"
  print_cached gh-review "$cache_ttl_seconds" \
    run_limited 12 gh search prs --state open --review-requested '@me' \
    --limit 6 --json repository,number,title,updatedAt \
    --template '{{range .}}{{printf "%-24s #%v  %s\n" .repository.nameWithOwner .number .title}}{{else}}None{{"\n"}}{{end}}'

  printf '\n%s\n' "${dim}Changes requested${reset}"
  print_cached gh-changes-requested "$cache_ttl_seconds" \
    run_limited 12 gh search prs --state open --reviewed-by '@me' \
    --review changes_requested --archived=false --limit 6 \
    --json repository,number,title,updatedAt \
    --template '{{range .}}{{printf "%-24s #%v  %s\n" .repository.nameWithOwner .number .title}}{{else}}None{{"\n"}}{{end}}'

  printf '\n%s\n' "${dim}Dottie PRs${reset}"
  print_cached gh-dottie-prs "$cache_ttl_seconds" \
    run_limited 12 gh search prs --state open --author dottie-weaver \
    --limit 6 --json repository,number,title,updatedAt \
    --template '{{range .}}{{printf "%-24s #%v  %s\n" .repository.nameWithOwner .number .title}}{{else}}None{{"\n"}}{{end}}'
}

print_issues() {
  section 'Ready Issues'

  if ! command -v gh >/dev/null 2>&1; then
    printf 'gh not installed\n'
    return
  fi

  local -a owner_args
  local owner

  owner_args=()
  for owner in "${active_owners[@]}"; do
    owner_args+=(--owner "$owner")
  done

  print_cached gh-ready-issues-active-owners "$cache_ttl_seconds" \
    run_limited 12 gh search issues --state open --label ready \
    --archived=false "${owner_args[@]}" --limit 8 \
    --json repository,number,title,updatedAt \
    --template '{{range .}}{{printf "%-24s #%v  %s\n" .repository.nameWithOwner .number .title}}{{else}}None{{"\n"}}{{end}}'
}

print_tasks() {
  section 'Dottie Tasks'

  local -a task_cmd
  # shellcheck disable=SC2054 # Taskwarrior column lists are comma-separated values.
  task_cmd=(
    task
    rc.verbose=nothing
    rc.defaultwidth=120
    'rc.report.mc.filter=+me status:pending -parked'
    rc.report.mc.columns=id,project,priority,due.relative,description.truncated
    rc.report.mc.labels=ID,Project,Pri,Due,Description
    'rc.report.mc.sort=urgency-,project+'
    mc
    limit:8
  )

  if [[ "$(hostname -s)" == 'heimdall' ]] && command -v task >/dev/null 2>&1; then
    run_limited 12 "${task_cmd[@]}" 2>/dev/null || printf 'Unavailable\n'
    return
  fi

  run_limited 12 ssh -o ConnectTimeout=4 dottie@heimdall \
    "${task_cmd[*]}" \
    2>/dev/null || printf 'Unavailable\n'
}

draw() {
  if [[ -t 1 ]]; then
    clear
  fi

  printf '%sMission Control%s  %s\n' "$bold" "$reset" "$(date '+%a %b %-d %H:%M')"
  printf '%s%s%s\n' "$dim" 'Prefix m opens this dashboard. Prefix i/G/P/p/C-p/y drill into GitHub.' "$reset"

  print_tmux
  print_repos
  print_prs
  print_issues
  print_tasks
}

if [[ "$watch_mode" == true ]]; then
  while true; do
    draw
    printf '\n%sPress q to quit. Refreshes every %ss.%s\n' "$dim" "$refresh_seconds" "$reset"
    read -r -s -n 1 -t "$refresh_seconds" key || true
    [[ "${key:-}" == q ]] && break
  done
else
  draw
fi
