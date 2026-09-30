#!/bin/bash

# Exercise Stow against a disposable home, never the running desktop.
set -euo pipefail

PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)
TEST_ROOT=$(mktemp -d -t dotfiles-omarchy.XXXXXX)
trap 'rm -rf "$TEST_ROOT"' EXIT
export HOME="$TEST_ROOT/home"
mkdir -p "$HOME/.config/hypr" "$HOME/.config/omarchy/plugins/local.plugin"
mkdir -p "$HOME/.agents/skills/dottie" "$TEST_ROOT/repo"
mkdir -p "$HOME/.config/nvim/lua/plugins"
cp -R "$PROJECT_ROOT/omarchy" "$TEST_ROOT/repo/omarchy"

# Unmanaged shell, input, Dottie, and third-party plugins must survive.
printf 'stock shell\n' > "$HOME/.config/omarchy/shell.json"
printf 'theme sizing\n' > "$HOME/.config/omarchy/shell.toml"
printf 'local input\n' > "$HOME/.config/hypr/input.lua"
printf 'local Dottie\n' > "$HOME/.config/hypr/dottie.lua"
printf 'local plugin\n' > \
  "$HOME/.config/omarchy/plugins/local.plugin/manifest.json"
printf 'Dottie skill\n' > "$HOME/.agents/skills/dottie/SKILL.md"
printf 'local theme\n' > "$HOME/.config/nvim/lua/plugins/theme.lua"
printf 'local lock\n' > "$HOME/.config/nvim/lazy-lock.json"
cp -R "$HOME" "$TEST_ROOT/original-home"

stow_package() {
  stow --dir="$TEST_ROOT/repo" --target="$HOME" \
    --dotfiles --ignore='^AGENT\.md$' "$@" omarchy
}

# A stock or customized regular bindings.lua is a conflict, not ours to adopt.
printf 'unmanaged bindings\n' > "$HOME/.config/hypr/bindings.lua"
if stow_package --simulate --restow > "$TEST_ROOT/conflict.log" 2>&1; then
  printf 'FAIL: unmanaged bindings were not reported as a conflict\n' >&2
  exit 1
fi
grep -q '^unmanaged bindings$' "$HOME/.config/hypr/bindings.lua"
rm "$HOME/.config/hypr/bindings.lua"
printf 'ok - activation refuses unmanaged bindings\n'

navigation="$HOME/.config/nvim/lua/plugins/smart-splits.lua"
printf 'local navigation\n' > "$navigation"
if stow_package --simulate --restow > "$TEST_ROOT/conflict.log" 2>&1; then
  printf 'FAIL: unmanaged navigation was not reported as a conflict\n' >&2
  exit 1
fi
grep -q '^local navigation$' "$navigation"
rm "$navigation"
printf 'ok - activation refuses unmanaged navigation config\n'

stow_package --restow
stow_package --restow
for path in hypr/bindings.lua omarchy/defaults/agent \
  nvim/lua/plugins/smart-splits.lua; do
  expected="$TEST_ROOT/repo/omarchy/dot-config/$path"
  test "$(readlink -f "$HOME/.config/$path")" = "$expected"
done
test "$(find "$TEST_ROOT/repo/omarchy/dot-config" -type f | wc -l)" -eq 3
grep -q '^pi$' "$HOME/.config/omarchy/defaults/agent"
grep -q "kb_options = 'ctrl:swapcaps'" "$HOME/.config/hypr/bindings.lua"
test ! -e "$HOME/AGENT.md"
test ! -e "$HOME/.config/omarchy/plugins/tnez.menu"
printf 'ok - only three preference files managed; restow is repeatable\n'

stow_package --delete
test ! -e "$HOME/.config/hypr/bindings.lua"
test ! -L "$HOME/.config/hypr/bindings.lua"
test ! -e "$HOME/.config/omarchy/defaults/agent"
test ! -L "$HOME/.config/omarchy/defaults/agent"
test ! -e "$navigation"
test ! -L "$navigation"
diff -r "$TEST_ROOT/original-home" "$HOME"
printf 'ok - unstow preserves all unmanaged config and Dottie files\n'
