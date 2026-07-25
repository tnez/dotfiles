#!/bin/bash

set -Eeuo pipefail

SCRIPT_DIR=$(cd -P "$(dirname "$0")" >/dev/null 2>&1 && pwd)
REPO_ROOT=${SCRIPT_DIR%/*}
CONFIG_SOURCE=$REPO_ROOT/opencode/dot-config/opencode
OPENCODE_BIN=$(command -v opencode)
TMPDIR_TEST=$(mktemp -d -t opencode-agents.XXXXXX)
HOME_TEST=$TMPDIR_TEST/home

cleanup() {
  rm -rf "$TMPDIR_TEST"
}
trap cleanup EXIT HUP INT TERM

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

run_opencode() {
  env \
    HOME="$HOME_TEST" \
    XDG_CONFIG_HOME="$HOME_TEST/.config" \
    OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1 \
    OPENCODE_DISABLE_DEFAULT_PLUGINS=1 \
    OPENCODE_DISABLE_EXTERNAL_SKILLS=1 \
    "$OPENCODE_BIN" "$@"
}

mkdir -p "$HOME_TEST/.config"
ln -s "$CONFIG_SOURCE" "$HOME_TEST/.config/opencode"

config=$(run_opencode debug config)
jq -e '
  .default_agent == "code" and
  .agent.build.disable == true
' >/dev/null <<<"$config" || fail 'resolved config has the intended defaults'
printf '%s\n' 'ok - code is default and build is disabled'

for specification in \
  'code high' \
  'code-lite low' \
  'plan xhigh' \
  'think max' \
  'orchestrator xhigh'; do
  name=${specification%% *}
  variant=${specification#* }
  agent=$(run_opencode debug agent "$name")
  jq -e \
    --arg variant "$variant" \
    '.model.providerID == "openai" and
     .model.modelID == "gpt-5.6-sol" and
     .variant == $variant and
     .mode == "primary"' \
    >/dev/null <<<"$agent" ||
    fail "$name has the intended model and variant"
done
printf '%s\n' 'ok - all primary profiles have the intended model and variant'

for name in code code-lite plan think orchestrator; do
  agent=$(run_opencode debug agent "$name")
  jq -e '
    ([.permission[] |
      select(.permission == "question" and .pattern == "*")] |
      last | .action) == "allow" and
    .tools.question == true
  ' >/dev/null <<<"$agent" || fail "$name has effective question capability"
done
printf '%s\n' 'ok - all primary profiles have effective question capability'

for name in code code-lite; do
  agent=$(run_opencode debug agent "$name")
  jq -e '
    [.permission | to_entries[] |
      select(.value.permission == "external_directory")] as $rules |
    ([$rules[] | select(.value.pattern == "*")] | last) as $boundary |
    $boundary.value.action == "allow" and
    all($rules[] | select(.key > $boundary.key); .value.action == "allow")
  ' >/dev/null <<<"$agent" || fail "$name prompts for external directories"
done
printf '%s\n' 'ok - code profiles allow all external directories'

code=$(run_opencode debug agent code)
jq -e '
  ([.permission[] |
    select(.permission == "plan_enter" and .pattern == "*")] |
    last | .action) == "allow"
' >/dev/null <<<"$code" || fail 'code preserves build plan-enter capability'

plan=$(run_opencode debug agent plan)
jq -e '
  any(.permission[];
    .permission == "edit" and .pattern == "*" and .action == "deny") and
  any(.permission[];
    .permission == "edit" and
    .pattern == ".opencode/plans/*.md" and .action == "allow")
' >/dev/null <<<"$plan" || fail 'plan preserves built-in plan-only writes'

for name in code think plan; do
  agent=$(run_opencode debug agent "$name")
  jq -e '
    def task_action($name):
      ([.permission[] |
        select(
          .permission == "task" and
          (.pattern == "*" or .pattern == $name)
        )] | last | .action);
    [.permission | to_entries[] |
      select(.value.permission == "task")] as $task_rules |
    ([$task_rules[] |
      select(.value.pattern == "*")] | last) as $boundary |
    task_action("explore") == "allow" and
    task_action("research") == "allow" and
    task_action("general") == "deny" and
    task_action("unknown-agent") == "deny" and
    $boundary.value.action == "deny" and
    all($task_rules[] | select(.key > $boundary.key);
      .value.action == "deny" or
      (.value.action == "allow" and
        (.value.pattern == "explore" or .value.pattern == "research")))
  ' >/dev/null <<<"$agent" || fail "$name has an effective task allowlist"
done
printf '%s\n' 'ok - code, think, and plan allow only explore and research tasks'

for name in think orchestrator; do
  agent=$(run_opencode debug agent "$name")
  jq -e '
    ([.permission[] |
      select(.permission == "edit" and .pattern == "*")] |
      last | .action) == "deny"
  ' >/dev/null <<<"$agent" || fail "$name permits edits"
done

for name in code-lite orchestrator; do
  agent=$(run_opencode debug agent "$name")
  jq -e '
    def task_action($name):
      ([.permission[] |
        select(
          .permission == "task" and
          (.pattern == "*" or .pattern == $name)
        )] | last | .action);
    ([.permission[] | select(.permission == "task")] | last) as $boundary |
    $boundary.pattern == "*" and
    $boundary.action == "deny" and
    task_action("explore") == "deny" and
    task_action("research") == "deny" and
    task_action("general") == "deny" and
    task_action("unknown-agent") == "deny"
  ' >/dev/null <<<"$agent" || fail "$name can still delegate OpenCode tasks"
done
printf '%s\n' 'ok - code-lite and orchestrator deny OpenCode tasks'

explore=$(run_opencode debug agent explore)
jq -e '
  . as $agent |
  .mode == "subagent" and
  .native == true and
  (.prompt | contains("file search specialist")) and
  all("edit", "bash", "task";
    . as $permission |
    ([$agent.permission[] |
      select(
        .permission == $permission and .pattern == "*"
      )] | last | .action) == "deny") and
  all("read", "glob", "grep", "list", "webfetch", "websearch";
    . as $permission |
    ([$agent.permission[] |
      select(
        .permission == $permission and .pattern == "*"
      )] | last | .action) == "allow")
' >/dev/null <<<"$explore" || fail 'explore is not enforced read-only'

research=$(run_opencode debug agent research)
jq -e '
  . as $agent |
  .mode == "subagent" and
  .native == false and
  .model == null and
  .hidden != true and
  ([.permission[] |
    select(.permission == "*" and .pattern == "*")] |
    last | .action) == "deny" and
  all("edit", "bash", "task";
    . as $permission |
    ([$agent.permission[] |
      select(
        .permission == $permission and .pattern == "*"
      )] | last | .action) == "deny") and
  all(
    "read",
    "glob",
    "grep",
    "list",
    "webfetch",
    "websearch",
    "external_directory";
    . as $permission |
    ([$agent.permission[] |
      select(
        .permission == $permission and .pattern == "*"
      )] | last | .action) == "allow")
' >/dev/null <<<"$research" || fail 'research is not a model-inheriting reader'
jq -e '
  .tools.bash == false and
  .tools.task == false and
  .tools.apply_patch == false and
  .tools.todowrite == false and
  .tools.skill == false
' >/dev/null <<<"$research" || fail 'research is not a model-inheriting reader'
printf '%s\n' 'ok - explore and research are visible read-only subagents'

think=$(run_opencode debug agent think)
jq -e '
  ([.permission[] |
    select(.permission == "bash" and .pattern == "*")] |
    last | .action) == "deny" and
  ([.permission[] |
    select(
      .permission == "bash" and
      .pattern == "printenv TNEZDEV_KNOWLEDGE_BASE_ROOT"
    )] | last | .action) == "allow" and
  ([.permission | to_entries[] |
    select(.value.permission == "bash" and .value.pattern == "*") |
    .key] | last) <
  ([.permission | to_entries[] |
    select(
      .value.permission == "bash" and
      .value.pattern == "printenv TNEZDEV_KNOWLEDGE_BASE_ROOT"
    ) | .key] | last)
' >/dev/null <<<"$think" || fail 'think only allows its exact environment lookup'

orchestrator=$(run_opencode debug agent orchestrator)
jq -e '
  ([.permission[] |
    select(.permission == "bash" and .pattern == "*")] |
    last | .action) == "ask" and
  ([.permission[] |
    select(
      .permission == "bash" and
      .pattern == "*herdr-worktree-start.sh *"
    )] | last | .action) == "allow"
' >/dev/null <<<"$orchestrator" ||
  fail 'orchestrator asks for non-whitelisted shell commands'

for pattern in \
  'printenv HERDR_ENV' \
  'printenv HERDR_WORKSPACE_ID' \
  'printenv HERDR_TAB_ID' \
  'printenv HERDR_PANE_ID' \
  'herdr pane current --current'; do
  jq -e --arg pattern "$pattern" '
    ([.permission[] |
      select(.permission == "bash" and .pattern == $pattern)] |
      last | .action) == "allow" and
    ([.permission | to_entries[] |
      select(.value.permission == "bash" and .value.pattern == "*") |
      .key] | last) <
    ([.permission | to_entries[] |
      select(
        .value.permission == "bash" and .value.pattern == $pattern
      ) | .key] | last)
  ' >/dev/null <<<"$orchestrator" ||
    fail "orchestrator context rule is ineffective: $pattern"
done
printf '%s\n' 'ok - plan, think, and orchestrator rule order is effective'

if run_opencode debug agent build >/dev/null 2>&1; then
  fail 'disabled build remains discoverable'
fi
printf '%s\n' 'ok - disabled build is not discoverable'

printf '%s\n' 'All OpenCode agent tests passed.'
