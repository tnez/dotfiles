#!/bin/bash

# Declarative component discovery for the dotfiles lifecycle. This file is
# sourced by the root CLI and may also be sourced by isolated tests.

module_error() {
  printf 'ERROR: module declaration: %s\n' "$*" >&2
}

detect_host_platform() {
  local os release_id=

  os=$(uname -s 2>/dev/null) || return 1
  case "$os" in
    Darwin)
      printf 'darwin\n'
      ;;
    Linux)
      if [ -r /etc/os-release ]; then
        release_id=$(awk -F= '$1 == "ID" {gsub(/^"|"$/, "", $2); print $2}' \
          /etc/os-release)
      fi
      if [ "$release_id" = omarchy ]; then
        printf 'omarchy\n'
      else
        return 1
      fi
      ;;
    *) return 1 ;;
  esac
}

valid_module_name() {
  case "$1" in
    ''|*[!A-Za-z0-9_-]*|[-_]*|*/*|.|..) return 1 ;;
    *) return 0 ;;
  esac
}

load_module_declaration() {
  local entrypoint=$1 line key value extra in_block=0 blocks=0 ended=0
  local version_count=0 stow_count=0 platform_count=0

  MODULE_NAME=${entrypoint%/AGENT.md}
  MODULE_NAME=${MODULE_NAME##*/}
  MODULE_ENTRYPOINT=$entrypoint
  MODULE_VERSION=
  MODULE_PLATFORMS=
  MODULE_STOW=
  MODULE_CAPABILITIES=

  valid_module_name "$MODULE_NAME" || {
    module_error "invalid component directory name: $MODULE_NAME"
    return 1
  }
  [ -f "$entrypoint" ] && [ -r "$entrypoint" ] || {
    module_error "entrypoint is unreadable: $entrypoint"
    return 1
  }

  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      '<!-- dotfiles-module')
        if [ "$in_block" -eq 1 ]; then
          module_error "nested declaration in $entrypoint"
          return 1
        fi
        if [ "$blocks" -ge 1 ]; then
          module_error "expected one complete declaration in $entrypoint"
          return 1
        fi
        blocks=$((blocks + 1))
        in_block=1
        continue
        ;;
      '-->')
        if [ "$in_block" -eq 1 ]; then
          in_block=0
          ended=1
        fi
        continue
        ;;
    esac
    [ "$in_block" -eq 1 ] || continue

    key=
    value=
    extra=
    read -r key value extra <<EOF
$line
EOF
    if [ -z "$key" ] || [ -z "$value" ]; then
      module_error "invalid directive in $entrypoint: $line"
      return 1
    fi
    case "$key" in
      version)
        if [ -n "$extra" ]; then
          module_error "invalid directive in $entrypoint: $line"
          return 1
        fi
        version_count=$((version_count + 1))
        MODULE_VERSION=$value
        ;;
      platform)
        if [ -n "$extra" ]; then
          module_error "invalid directive in $entrypoint: $line"
          return 1
        fi
        case "$value" in darwin|omarchy) ;; *)
          module_error "invalid platform in $entrypoint: $value"
          return 1
        esac
        case " $MODULE_PLATFORMS " in *" $value "*)
          module_error "duplicate platform in $entrypoint: $value"
          return 1
        esac
        MODULE_PLATFORMS=${MODULE_PLATFORMS:+$MODULE_PLATFORMS }$value
        platform_count=$((platform_count + 1))
        ;;
      stow)
        if [ -n "$extra" ]; then
          module_error "invalid directive in $entrypoint: $line"
          return 1
        fi
        stow_count=$((stow_count + 1))
        MODULE_STOW=$value
        ;;
      capability)
        if [ -n "$extra" ]; then
          module_error "invalid directive in $entrypoint: $line"
          return 1
        fi
        case "$value" in
          homebrew|materialized-skills|knowledge-base-adapter|codex-seed|\
launchd-environment|herdr) ;;
          *)
            module_error "invalid capability in $entrypoint: $value"
            return 1
            ;;
        esac
        case " $MODULE_CAPABILITIES " in *" $value "*)
          module_error "duplicate capability in $entrypoint: $value"
          return 1
        esac
        MODULE_CAPABILITIES=${MODULE_CAPABILITIES:+$MODULE_CAPABILITIES }$value
        ;;
      *)
        module_error "unknown directive in $entrypoint: $key"
        return 1
        ;;
    esac
  done < "$entrypoint"

  if [ "$blocks" -ne 1 ] || [ "$ended" -ne 1 ] ||
    [ "$in_block" -ne 0 ]; then
    module_error "expected one complete declaration in $entrypoint"
    return 1
  fi
  if [ "$version_count" -ne 1 ] || [ "$MODULE_VERSION" != 1 ]; then
    module_error "expected exactly 'version 1' in $entrypoint"
    return 1
  fi
  if [ "$platform_count" -eq 0 ]; then
    module_error "expected at least one platform in $entrypoint"
    return 1
  fi
  if [ "$stow_count" -ne 1 ]; then
    module_error "expected exactly one stow directive in $entrypoint"
    return 1
  fi
  case "$MODULE_STOW" in standard|no-folding|none) ;;
    *)
      module_error "invalid Stow mode in $entrypoint: $MODULE_STOW"
      return 1
      ;;
  esac
}

module_supports_platform() {
  local requested=$1 platform

  for platform in $MODULE_PLATFORMS; do
    [ "$platform" = "$requested" ] && return 0
  done
  return 1
}

module_has_capability() {
  local requested=$1 capability

  for capability in $MODULE_CAPABILITIES; do
    [ "$capability" = "$requested" ] && return 0
  done
  return 1
}

validate_modules() {
  local entrypoint failed=0 found=0

  for entrypoint in "$REPO_ROOT"/*/AGENT.md; do
    [ -f "$entrypoint" ] || continue
    found=1
    load_module_declaration "$entrypoint" || failed=1
  done
  if [ "$found" -ne 1 ]; then
    module_error "no component entrypoints found below $REPO_ROOT"
    return 1
  fi
  [ "$failed" -eq 0 ]
}

list_modules() {
  local requested=${1:-all} entrypoint found=0

  case "$requested" in all|darwin|omarchy) ;;
    *) module_error "invalid requested platform: $requested"; return 1 ;;
  esac

  for entrypoint in "$REPO_ROOT"/*/AGENT.md; do
    [ -f "$entrypoint" ] || continue
    found=1
    load_module_declaration "$entrypoint" || return 1
    if [ "$requested" = all ] || module_supports_platform "$requested"; then
      printf '%s|%s|%s|%s|%s\n' \
        "$MODULE_NAME" "$MODULE_STOW" "$MODULE_PLATFORMS" \
        "$MODULE_CAPABILITIES" "$MODULE_ENTRYPOINT"
    fi
  done
  if [ "$found" -ne 1 ]; then
    module_error "no component entrypoints found below $REPO_ROOT"
    return 1
  fi
}
