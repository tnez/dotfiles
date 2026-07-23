#!/bin/bash

set -u

commit=${FAKE_HERDR_PLUGIN_COMMIT:-548607d0e417fdb30966846fce7436aa05a6738d}

case "${1:-} ${2:-}" in
  '--version ')
    printf 'herdr 1.0.0\n'
    ;;
  'status server')
    printf 'version: 1.0.0\n'
    ;;
  'plugin list')
    printf '{"result":{"plugins":[{"enabled":%s,' \
      "${FAKE_HERDR_PLUGIN_ENABLED:-false}"
    printf '"source":{"resolved_commit":"%s"}}]}}\n' "$commit"
    ;;
  'plugin install')
    : > "${FAKE_HERDR_PLUGIN_MARKER:?}"
    ;;
  'integration status')
    :
    ;;
  'server reload-config')
    :
    ;;
esac
