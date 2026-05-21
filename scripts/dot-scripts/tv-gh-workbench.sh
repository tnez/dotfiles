#!/bin/bash
set -euo pipefail

mode="${1:-}"
owners=(--owner tnez --owner tnezdev --owner scoutos-labs)

run_with_empty_row() {
  local empty_message="$1"
  shift

  local output
  output="$("$@")"
  if [[ -n "$output" ]]; then
    printf '%s\n' "$output"
  else
    printf 'no-results\t%s\t\t\n' "$empty_message"
  fi
}

case "$mode" in
  all-prs)
    run_with_empty_row "No open PRs found" gh search prs "${owners[@]}" \
      --state open \
      --archived=false \
      --sort updated \
      --order desc \
      --limit 100 \
      --json repository,number,title,author,updatedAt,isDraft \
      --jq '.[] | "\(.repository.nameWithOwner)#\(.number)\t\(.title)\t@\(.author.login)\t\(if .isDraft then "draft" else "ready" end)\t\(.updatedAt)"'
    ;;

  review)
    run_with_empty_row "No PRs requesting your review" gh search prs "${owners[@]}" \
      --state open \
      --review-requested @me \
      --archived=false \
      --sort updated \
      --order desc \
      --limit 100 \
      --json repository,number,title,author,updatedAt,isDraft \
      --jq '.[] | "\(.repository.nameWithOwner)#\(.number)\t\(.title)\t@\(.author.login)\t\(if .isDraft then "draft" else "ready" end)\t\(.updatedAt)"'
    ;;

  ready)
    run_with_empty_row "No ready issues found" gh search issues "${owners[@]}" \
      --state open \
      --label ready \
      --archived=false \
      --sort updated \
      --order desc \
      --limit 100 \
      --json repository,number,title,assignees,updatedAt \
      --jq '.[] | "\(.repository.nameWithOwner)#\(.number)\t\(.title)\t\([.assignees[].login] | join(","))\t\(.updatedAt)"'
    ;;

  *)
    printf 'usage: %s {all-prs|review|ready}\n' "$0" >&2
    exit 2
    ;;
esac
