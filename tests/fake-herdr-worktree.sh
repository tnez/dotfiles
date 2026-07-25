#!/bin/bash

set -u

case "${1:-} ${2:-}" in
  'pane list')
    printf '{"result":{"panes":[{"cwd":"%s"}]}}\n' "${FAKE_HERDR_REPO:?}"
    ;;
  'pane process-info')
    printf '%s%s\n' \
      '{"result":{"process_info":{"shell_pid":1,' \
      '"foreground_processes":[{"pid":1}]}}}'
    ;;
  'agent list')
    printf '%s\n' '{"result":{"agents":[]}}'
    ;;
  'agent start')
    shift 2
    printf '%s\n' "$@" > "${FAKE_HERDR_AGENT_START_LOG:?}"
    printf '%s\n' '{"result":{}}'
    ;;
  'agent prompt')
    shift 2
    printf '%s\n' "$@" > "${FAKE_HERDR_AGENT_PROMPT_LOG:?}"
    printf '%s\n' '{"result":{}}'
    ;;
  'tab create')
    printf '%s\n' \
      '{"result":{"tab":{"tab_id":"w1:t2"},"root_pane":{"pane_id":"w1:p2"}}}'
    ;;
  *)
    printf 'unexpected fake Herdr command: %s\n' "$*" >&2
    exit 1
    ;;
esac
