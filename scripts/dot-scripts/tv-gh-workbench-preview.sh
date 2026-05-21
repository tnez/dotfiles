#!/bin/bash
set -euo pipefail

kind="${1:-}"
entry="${2:-}"
mode="${3:-rendered}"
target="${entry%%$'\t'*}"

if [[ "$target" != *#* ]]; then
  message="${entry#*$'\t'}"
  message="${message%%$'\t'*}"
  printf '%s\n' "${message:-No results}"
  exit 0
fi

repo="${target%%#*}"
number="${target##*#}"

render_markdown() {
  case "$mode" in
    raw)
      if command -v bat >/dev/null 2>&1; then
        bat --color=always --language markdown --style=plain
      else
        cat
      fi
      ;;
    rendered)
      if command -v glow >/dev/null 2>&1; then
        glow --style dark -
      else
        cat
      fi
      ;;
    *)
      printf 'usage: %s {pr|issue} ENTRY [rendered|raw]\n' "$0" >&2
      exit 2
      ;;
  esac
}

jq_common='def text_clean:
  (. // "")
  | gsub("<details>|</details>|<summary>|</summary>|<p>|</p>|<ul>|</ul>"; "")
  | gsub("</li>"; "\n")
  | gsub("<li>"; "- ")
  | gsub("</?(details|summary|p|blockquote|h[0-9]|ul|li|a|code|em)[^>]*>"; "")
  | gsub("&lt;"; "<")
  | gsub("&gt;"; ">")
  | gsub("&quot;"; "\"")
  | gsub("&amp;"; "&");
def text_preview:
  text_clean
  | split("\n")
  | .[:45]
  | join("\n");
def names(xs):
  if (xs | length) == 0 then "none" else (xs | map(.name // .login) | join(", ")) end;
def comments:
  if (.comments | length) == 0 then
    "No comments"
  else
    (.comments[-5:][] | "### @\(.author.login) - \(.createdAt)\n\n\(.body | text_preview)\n")
  end;'

pr_jq=$(cat <<'JQ'
def checks:
  if (.statusCheckRollup | length) == 0 then "none"
  else
    (.statusCheckRollup | map(.conclusion // .status) | group_by(.) | map("\(length)x \(.[0])") | join(", "))
  end;
[
  "# \($repo)#\(.number): \(.title)",
  "",
  "| Field | Value |",
  "| --- | --- |",
  "| URL | \(.url) |",
  "| Author | @\(.author.login) |",
  "| State | \(.state)\(if .isDraft then " draft" else "" end) |",
  "| Review | \(if .reviewDecision == "" then "none" else .reviewDecision end) |",
  "| Mergeable | \(.mergeable) |",
  "| Checks | \(checks) |",
  "| Branch | \(.baseRefName) <- \(.headRefName) |",
  "| Changes | \(.changedFiles) files, +\(.additions) -\(.deletions) |",
  "| Labels | \(names(.labels)) |",
  "| Assignees | \(names(.assignees)) |",
  "| Created | \(.createdAt) |",
  "| Updated | \(.updatedAt) |",
  "",
  "## Body",
  "",
  (.body | text_preview),
  "",
  "## Recent Comments",
  "",
  (comments)
] | .[]
JQ
)

issue_jq=$(cat <<'JQ'
[
  "# \($repo)#\(.number): \(.title)",
  "",
  "| Field | Value |",
  "| --- | --- |",
  "| URL | \(.url) |",
  "| Author | @\(.author.login) |",
  "| State | \(.state) |",
  "| Labels | \(names(.labels)) |",
  "| Assignees | \(names(.assignees)) |",
  "| Milestone | \(if .milestone == null then "none" else .milestone.title end) |",
  "| Created | \(.createdAt) |",
  "| Updated | \(.updatedAt) |",
  "",
  "## Body",
  "",
  (.body | text_preview),
  "",
  "## Recent Comments",
  "",
  (comments)
] | .[]
JQ
)

case "$kind" in
  pr)
    gh pr view "$number" --repo "$repo" \
      --json number,title,state,isDraft,author,createdAt,updatedAt,body,baseRefName,headRefName,reviewDecision,mergeable,changedFiles,additions,deletions,labels,assignees,comments,statusCheckRollup,url \
      | jq -r --arg repo "$repo" "$jq_common $pr_jq" \
      | render_markdown
    ;;
  issue)
    gh issue view "$number" --repo "$repo" \
      --json number,title,state,author,createdAt,updatedAt,body,labels,assignees,comments,milestone,url \
      | jq -r --arg repo "$repo" "$jq_common $issue_jq" \
      | render_markdown
    ;;
  *)
    printf 'usage: %s {pr|issue} ENTRY\n' "$0" >&2
    exit 2
    ;;
esac
