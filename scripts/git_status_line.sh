#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# gitstatus.sh -- produce the current git repo status on STDOUT
#
# Borrowed from (with small modifications):
# https://github.com/arl/tmux-gitbar/blob/master/scripts/gitstatus.sh

target_dir="$1"
if [ ! -d "$target_dir" ]; then
	exit 1
fi
cd "$target_dir" > /dev/null

readonly gitstatus=$( LC_ALL=C git status --untracked-files=all --porcelain --branch )

# exit if we're not able to get a status
# (this would happen if we're not in a git dir)
[[ "$?" -ne 0 ]] && exit 0

num_staged=0
num_changed=0
num_conflicts=0
num_untracked=0
while IFS='' read -r line || [[ -n "$line" ]]; do
  status=${line:0:2}
  case "$status" in
    '##')
      if [[ $line = *"No commits yet"* ]]; then
        # fixes #54 (garbage output on new repos)
        line=$(echo $line | sed  "s/.*yet on //")
      fi
      branch_line="${line/\.\.\./^}" ;;
    ?M) ((num_changed++)) ;;
    U?) ((num_conflicts++)) ;;
    \?\?) ((num_untracked++)) ;;
    *) ((num_staged++)) ;;
  esac
done <<< "$gitstatus"

clean=0
if (( num_changed == 0 && num_staged == 0 && num_untracked == 0 && num_stashed == 0 && num_conflicts == 0 )) ; then
  clean=1
fi

IFS="^" read -ra branch_fields <<< "${branch_line/\#\# }"
branch="${branch_fields[0]}"
remote=
upstream=

num_stashed=0
stash_file="$( git rev-parse --git-dir )/logs/refs/stash"
if [[ -e "${stash_file}" ]]; then
  num_stashed="$( grep $branch $stash_file | wc -l | tr -d ' ' )"
fi

if [[ "$branch" == *"Initial commit on"* ]]; then
  IFS=" " read -ra fields <<< "$branch"
  branch="${fields[3]}"
  remote="-"
elif [[ "$branch" == *"no branch"* ]]; then
  tag=$( git describe --exact-match )
  if [[ -n "$tag" ]]; then
    branch="$tag"
  else
    branch="_PREHASH_$( git rev-parse --short HEAD )"
  fi
else
  if [[ "${#branch_fields[@]}" -eq 1 ]]; then
    remote="-"
  else
    IFS="[,]" read -ra remote_fields <<< "${branch_fields[1]}"
    for remote_field in "${remote_fields[@]}"; do
      if [[ "$remote_field" == *ahead* ]]; then
        num_ahead=${remote_field:6}
      fi
      if [[ "$remote_field" == *behind* ]]; then
        num_behind=${remote_field:7}
      fi
    done
    remote="${num_behind}⬇|${num_ahead}⬆"
  fi
fi

if [[ -z "$remote" ]] ; then
  remote="-"
fi

if (( num_changed == 0 && num_staged == 0 && num_untracked == 0 && num_stashed == 0 && num_conflicts == 0 )) ; then
  clean=1
fi

if (( num_changed == 0 && num_untracked == 0 && num_conflicts == 0 )); then
  if (( num_staged == 0 )); then
    local_status="✓"
  else
    local_status="+"
  fi
else
  local_status="~"
fi

if (( num_stashed == 0 )); then
  staged_status="✓"
else
  staged_status="$num_stashed"
fi

printf "%s -- local:(%s|%s) remote:(%s)" \
  "$branch" \
  "$local_status" \
  "$staged_status" \
  "$remote"
