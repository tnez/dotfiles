#!/bin/bash
set -euo pipefail

show_help() {
  cat <<'EOF'
# GitHub Workbench Keys

## Global Television

| Key | Action |
| --- | --- |
| Ctrl-x | Open action picker |
| Ctrl-f | Cycle preview: rendered Markdown / raw Markdown |
| Ctrl-n | Page preview down |
| Ctrl-p | Page preview up |
| Ctrl-j / Ctrl-k | Move selection down / up |
| Enter | View selected item |
| Esc | Quit picker |

## PR Queues

Channels: `gh-all-prs`, `gh-review`, `gh-changes-requested`

| Key | Action |
| --- | --- |
| Enter | View formatted PR |
| Ctrl-o | Open PR in browser |
| Ctrl-c | Checkout PR |
| Ctrl-d | View PR diff |
| Alt-x | View checks |
| Alt-j | Jump to local repo session |
| Ctrl-a | Agent review |
| Alt-a | Approve PR (typed confirmation) |
| Alt-r | Request changes in editor |

## Issue Queues

Channel: `gh-ready`

| Key | Action |
| --- | --- |
| Enter | View formatted issue |
| Ctrl-o | Open issue in browser |
| Ctrl-e | Edit issue |
| Ctrl-c | Comment on issue |
| Ctrl-m | Assign to me |
| Ctrl-d | Assign to dottie-weaver |
| Ctrl-r | Remove `ready` label |
| Alt-j | Jump to local repo session |
| Alt-x | Close issue (typed confirmation) |
| Ctrl-a | Agent plan/implement |

## Notes

Use `Ctrl-x` if you forget a key. It opens Television's action picker for the
current channel. `Alt-*` bindings are only convenience shortcuts; every action is
also available from the action picker.
EOF
}

if command -v glow >/dev/null 2>&1; then
  show_help | glow --style dark - | ${PAGER:-less -R}
else
  show_help | ${PAGER:-less}
fi
