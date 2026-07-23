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

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
template_path="$script_dir/wtp-template.yml"
if [[ ! -f "$template_path" ]]; then
  echo "Error: template not found at $template_path" >&2
  exit 1
fi

cp "$template_path" "$config_path"

exclude_path="$common_dir/info/exclude"
if ! grep -Fqx '.wtp.yml' "$exclude_path"; then
  printf '\n.wtp.yml\n' >>"$exclude_path"
fi

echo "Created $config_path"
echo "Excluded .wtp.yml from this repository."
