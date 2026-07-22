#!/usr/bin/env bash

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "Error: not in a Git repository" >&2
  exit 1
}

common_dir="$(git rev-parse --path-format=absolute --git-common-dir)"
if [[ "$common_dir" != "$repo_root/.git" ]]; then
  echo "Error: run this from the primary worktree" >&2
  exit 1
fi

branch="$(git -C "$repo_root" branch --show-current)"
if [[ "$branch" != "main" ]]; then
  echo "Error: the primary worktree must have main checked out" >&2
  exit 1
fi

config_path="$repo_root/.wtp.yml"
if [[ -e "$config_path" ]]; then
  echo "Error: $config_path already exists" >&2
  exit 1
fi

cat >"$config_path" <<'EOF'
version: "1.0"

defaults:
  # Keep main/ as the primary worktree and preserve branch prefixes as paths.
  base_dir: ..

hooks:
  post_create:
    # Copy local environment files without failing when a project has none.
    - type: command
      command: |
        for source in "$GIT_WTP_REPO_ROOT"/.env*; do
          [ -f "$source" ] || continue
          name=${source##*/}
          git -C "$GIT_WTP_REPO_ROOT" check-ignore -q -- "$name" || continue
          destination="$GIT_WTP_WORKTREE_PATH/$name"
          [ -e "$destination" ] || cp -p "$source" "$destination"
        done
EOF

echo "Created $config_path"
echo "Review and commit it before creating worktrees."
