#!/usr/bin/env bash
# Close one settled Herdr worker tab and remove its merged linked worktree.

set -Eeuo pipefail

agent=""
base=""
branch=""
pane=""
tab=""
worktree=""
workspace=""

usage() {
  cat <<'EOF'
Usage:
  herdr-worktree-cleanup.sh --agent NAME --base BRANCH --branch BRANCH \
    --pane ID --tab ID --worktree PATH --workspace ID

All values must come from the worker result being cleaned up. The helper closes
only the supplied worker tab, then uses non-forced `wtp remove --with-branch`
after proving the worker is settled, the linked worktree is clean, and its
branch is contained in the supplied local integration base.
EOF
}

fail() {
  printf 'herdr-worktree-cleanup: %s\n' "$*" >&2
  exit 1
}

absolute_git_common_dir() {
  local common_dir directory=$1

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

record_worktree() {
  if [[ "$listed_path" == "$worktree" ]]; then
    ((registered_count += 1))
    registered_ref=$listed_ref
    registered_locked=$listed_locked
    registered_prunable=$listed_prunable
  fi
  listed_path=""
  listed_ref=""
  listed_locked=false
  listed_prunable=false
}

inspect_worktree_registration() {
  local line

  registered_count=0
  registered_ref=""
  registered_locked=false
  registered_prunable=false
  listed_path=""
  listed_ref=""
  listed_locked=false
  listed_prunable=false
  while IFS= read -r line; do
    case "$line" in
      'worktree '*) listed_path=${line#worktree } ;;
      'branch '*) listed_ref=${line#branch } ;;
      locked*) listed_locked=true ;;
      prunable*) listed_prunable=true ;;
      '') record_worktree ;;
    esac
  done < <(git -C "$primary" worktree list --porcelain)
  [[ -z "$listed_path" ]] || record_worktree
}

canonical_directory() {
  local directory=$1

  [[ -d "$directory" ]] || return 1
  (cd "$directory" && pwd -P)
}

while (( $# > 0 )); do
  case "$1" in
    --agent)
      [[ $# -ge 2 ]] || fail '--agent requires a value'
      agent=$2
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
    --pane)
      [[ $# -ge 2 ]] || fail '--pane requires a value'
      pane=$2
      shift 2
      ;;
    --tab)
      [[ $# -ge 2 ]] || fail '--tab requires a value'
      tab=$2
      shift 2
      ;;
    --worktree)
      [[ $# -ge 2 ]] || fail '--worktree requires a value'
      worktree=$2
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
    *) fail "unknown argument: $1" ;;
  esac
done

[[ "${HERDR_ENV:-}" == 1 ]] || fail 'run this from a Herdr-managed pane'
for value in agent base branch pane tab worktree workspace; do
  [[ -n "${!value}" ]] || fail "--$value is required"
done
[[ "$branch" != -* ]] || fail 'branch cannot begin with -'
[[ "$base" != -* ]] || fail 'base cannot begin with -'
[[ "$branch" != "$base" ]] ||
  fail "worker branch cannot equal integration base: $branch"

for command in git herdr jq wtp; do
  command -v "$command" >/dev/null 2>&1 ||
    fail "required command not found: $command"
done

worktree="$(canonical_directory "$worktree")" ||
  fail "worktree is not an existing directory: $worktree"
git -C "$worktree" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
  fail "not a Git worktree: $worktree"
[[ -f "$worktree/.git" ]] ||
  fail "cleanup requires a linked worktree, not a primary checkout: $worktree"
common_dir="$(absolute_git_common_dir "$worktree")" ||
  fail "cannot resolve Git common directory: $worktree"
primary="$(primary_worktree "$worktree")"
[[ -n "$primary" ]] || fail "cannot resolve primary worktree: $worktree"
primary="$(canonical_directory "$primary")" ||
  fail "primary worktree is unavailable: $primary"
[[ "$primary" != "$worktree" ]] ||
  fail "cleanup refuses the primary worktree: $worktree"
[[ -f "$primary/.wtp.yml" ]] ||
  fail "wtp is not initialized in primary checkout: $primary"

git check-ref-format "refs/heads/$branch" >/dev/null 2>&1 ||
  fail "invalid local branch name: $branch"
git check-ref-format "refs/heads/$base" >/dev/null 2>&1 ||
  fail "invalid local integration base: $base"
git -C "$primary" show-ref --verify --quiet "refs/heads/$branch" ||
  fail "local worker branch does not exist: $branch"
git -C "$primary" show-ref --verify --quiet "refs/heads/$base" ||
  fail "local integration base does not exist: $base"
checked_out_ref="$(git -C "$worktree" symbolic-ref -q HEAD 2>/dev/null)" ||
  fail "worker worktree has a detached HEAD: $worktree"
[[ "$checked_out_ref" == "refs/heads/$branch" ]] ||
  fail "worktree branch mismatch: expected $branch, found" \
    "${checked_out_ref#refs/heads/}"

inspect_worktree_registration
[[ $registered_count -eq 1 ]] ||
  fail "worktree registration is missing or ambiguous: $worktree"
[[ "$registered_ref" == "refs/heads/$branch" ]] ||
  fail "registered worktree does not own branch $branch: $worktree"
[[ "$registered_locked" == false && "$registered_prunable" == false ]] ||
  fail 'worktree is locked or prunable and cannot be removed without' \
    'intervention'

dirty="$(git -C "$worktree" status --porcelain --untracked-files=all)"
if [[ -n "$dirty" ]]; then
  printf '%s\n' "$dirty" >&2
  fail "linked worktree is dirty; preserve it for human review: $worktree"
fi
git -C "$primary" merge-base --is-ancestor \
  "refs/heads/$branch" "refs/heads/$base" ||
  fail "branch $branch is not contained in local integration base $base"

agent_info="$(herdr agent get "$agent" 2>/dev/null)" ||
  fail "worker state is unknown or no longer addressable: $agent"
pane_info="$(herdr pane get "$pane" 2>/dev/null)" ||
  fail "returned pane is unavailable: $pane"
tab_info="$(herdr tab get "$tab" 2>/dev/null)" ||
  fail "returned tab is unavailable: $tab"

jq -e \
  --arg agent "$agent" \
  --arg pane "$pane" \
  --arg tab "$tab" \
  --arg workspace "$workspace" \
  '.result.agent as $item
   | $item.name == $agent
   and $item.pane_id == $pane
   and $item.tab_id == $tab
   and $item.workspace_id == $workspace' \
  >/dev/null <<<"$agent_info" ||
  fail 'returned worker, pane, tab, and workspace do not match'
jq -e \
  --arg pane "$pane" \
  --arg tab "$tab" \
  --arg workspace "$workspace" \
  '.result.pane as $item
   | $item.pane_id == $pane
   and $item.tab_id == $tab
   and $item.workspace_id == $workspace' \
  >/dev/null <<<"$pane_info" ||
  fail 'returned pane does not belong to the supplied tab and workspace'
jq -e \
  --arg tab "$tab" \
  --arg workspace "$workspace" \
  '.result.tab as $item
   | $item.tab_id == $tab
   and $item.workspace_id == $workspace' \
  >/dev/null <<<"$tab_info" ||
  fail 'returned tab does not belong to the supplied workspace'

pane_count="$(jq -er '.result.tab.pane_count' <<<"$tab_info")" ||
  fail "cannot establish the returned tab's pane ownership: $tab"
[[ "$pane_count" == 1 ]] ||
  fail "returned tab owns $pane_count panes; cleanup is ambiguous: $tab"

agent_status="$(jq -er '.result.agent.agent_status' <<<"$agent_info")" ||
  fail "worker state is unknown: $agent"
case "$agent_status" in
  idle|done) ;;
  working|blocked|unknown)
    fail "worker is not settled: $agent has status $agent_status"
    ;;
  *) fail "worker state is unknown: $agent reported $agent_status" ;;
esac

agent_cwd="$(jq -er '.result.agent.cwd' <<<"$agent_info")" ||
  fail "worker checkout is unknown: $agent"
pane_cwd="$(jq -er '.result.pane.cwd' <<<"$pane_info")" ||
  fail "pane checkout is unknown: $pane"
agent_cwd="$(canonical_directory "$agent_cwd")" ||
  fail "worker checkout is unavailable: $agent_cwd"
pane_cwd="$(canonical_directory "$pane_cwd")" ||
  fail "pane checkout is unavailable: $pane_cwd"
[[ "$agent_cwd" == "$worktree" && "$pane_cwd" == "$worktree" ]] ||
  fail "returned worker or pane does not target worktree $worktree"
[[ "$(absolute_git_common_dir "$agent_cwd" || true)" == "$common_dir" ]] ||
  fail "returned worker is not attached to the supplied repository"

herdr tab close "$tab" >/dev/null ||
  fail "could not close returned Herdr tab; worktree was preserved: $tab"
tabs="$(herdr tab list --workspace "$workspace" 2>/dev/null)" ||
  fail "tab $tab was closed, but authoritative Herdr verification failed;" \
    'worktree was preserved'
jq -e --arg tab "$tab" \
  'all(.result.tabs[]?; .tab_id != $tab)' >/dev/null <<<"$tabs" ||
  fail "tab close returned success but Herdr still lists $tab;" \
    'worktree was preserved'

if ! wtp_output="$(
  cd "$primary"
  wtp remove --with-branch "$branch" 2>&1
)"; then
  [[ -z "$wtp_output" ]] || printf '%s\n' "$wtp_output" >&2
  inspect_worktree_registration
  branch_present=false
  git -C "$primary" show-ref --verify --quiet "refs/heads/$branch" &&
    branch_present=true
  fail "Herdr tab $tab closed, but non-forced wtp cleanup failed;" \
    "worktree registrations=$registered_count," \
    "branch_present=$branch_present"
fi

inspect_worktree_registration
[[ $registered_count -eq 0 ]] ||
  fail "Herdr tab $tab closed, but worktree removal was not verified: $worktree"
if git -C "$primary" show-ref --verify --quiet "refs/heads/$branch"; then
  fail "Herdr tab $tab and worktree closed, but local branch remains: $branch"
fi
if [[ -e "$worktree" || -L "$worktree" ]]; then
  fail "Herdr tab $tab closed and Git cleanup completed, but worktree path" \
    "remains: $worktree"
fi

jq -n \
  --arg agent "$agent" \
  --arg base "$base" \
  --arg branch "$branch" \
  --arg pane "$pane" \
  --arg tab "$tab" \
  --arg worktree "$worktree" \
  --arg workspace "$workspace" \
  '{
    status: "cleaned",
    agent: $agent,
    base: $base,
    branch: $branch,
    pane_id: $pane,
    tab_id: $tab,
    worktree: $worktree,
    workspace: $workspace
  }'
