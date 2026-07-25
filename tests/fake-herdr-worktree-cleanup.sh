#!/bin/bash

set -u

closed=${FAKE_HERDR_CLOSED_MARKER:?}
log=${FAKE_HERDR_CLOSE_LOG:?}
pane_count=${FAKE_HERDR_PANE_COUNT:-1}
status=${FAKE_HERDR_AGENT_STATUS:-idle}

case "${1:-} ${2:-}" in
  'agent get')
    printf '{"result":{"agent":{"name":"%s","agent_status":"%s",' \
      "${FAKE_HERDR_AGENT:?}" "$status"
    printf '"cwd":"%s","pane_id":"%s","tab_id":"%s",' \
      "${FAKE_HERDR_WORKTREE:?}" "${FAKE_HERDR_PANE:?}" \
      "${FAKE_HERDR_TAB:?}"
    printf '"workspace_id":"%s"}}}\n' "${FAKE_HERDR_WORKSPACE:?}"
    ;;
  'pane get')
    printf '{"result":{"pane":{"cwd":"%s","pane_id":"%s",' \
      "${FAKE_HERDR_PANE_CWD:-${FAKE_HERDR_WORKTREE:?}}" \
      "${FAKE_HERDR_PANE:?}"
    printf '"tab_id":"%s","workspace_id":"%s"}}}\n' \
      "${FAKE_HERDR_TAB:?}" "${FAKE_HERDR_WORKSPACE:?}"
    ;;
  'tab get')
    [[ ! -e "$closed" ]] || exit 1
    printf '{"result":{"tab":{"pane_count":%s,"tab_id":"%s",' \
      "$pane_count" "${FAKE_HERDR_TAB:?}"
    printf '"workspace_id":"%s"}}}\n' "${FAKE_HERDR_WORKSPACE:?}"
    ;;
  'tab close')
    printf '%s\n' "${3:-}" > "$log"
    : > "$closed"
    printf '%s\n' '{"result":{}}'
    ;;
  'tab list')
    if [[ -e "$closed" ]]; then
      printf '%s\n' '{"result":{"tabs":[]}}'
    else
      printf '{"result":{"tabs":[{"tab_id":"%s"}]}}\n' \
        "${FAKE_HERDR_TAB:?}"
    fi
    ;;
  *)
    printf 'unexpected fake Herdr command: %s\n' "$*" >&2
    exit 1
    ;;
esac
