#!/bin/bash

set -eu

SCRIPT_DIR=$(cd -P "$(dirname "$0")" >/dev/null 2>&1 && pwd)
REPO_ROOT=${SCRIPT_DIR%/*}

exec "$REPO_ROOT/dotfiles" upgrade "$@"
