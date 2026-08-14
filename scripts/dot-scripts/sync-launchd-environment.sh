#!/bin/sh

set -eu

LAUNCHCTL_BIN=${LAUNCHCTL_BIN:-/bin/launchctl}

# Build from the macOS system baseline instead of the current launchd PATH.
# This prevents shell-manager session directories from accumulating on reload.
PATH=/usr/bin:/bin:/usr/sbin:/sbin
export PATH

# Load the same environment used by interactive shells, including optional
# machine-local overrides from ~/.profile.local.
# shellcheck disable=SC1091
. "$HOME/.profile"

sync_variable() {
  name=$1
  eval "value=\${$name:-}"

  if [ -n "$value" ]; then
    "$LAUNCHCTL_BIN" setenv "$name" "$value"
  else
    "$LAUNCHCTL_BIN" unsetenv "$name"
  fi
}

sync_variable PATH
sync_variable TNEZDEV_KNOWLEDGE_BASE_ROOT
sync_variable TNEZDEV_LOCAL_CONTEXT_ROOT
