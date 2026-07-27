# OpenCode profiles

The OpenCode Stow package installs five explicit primary profiles:

| Profile | Model | Variant | Role |
| --- | --- | --- | --- |
| `code` | `openai/gpt-5.6-sol-fast` | `high` | Default implementation profile |
| `code-lite` | `openai/gpt-5.6-terra` | `low` | Small, localized, low-risk implementation |
| `plan` | `openai/gpt-5.6-sol-fast` | `xhigh` | Analysis and OpenCode plan-document writes only |
| `think` | `openai/gpt-5.6-sol-fast` | `max` | Read-only investigation |
| `orchestrator` | `openai/gpt-5.6-sol-fast` | `xhigh` | Coordination-scoped Herdr worker cycle |

The built-in `build` profile is disabled.
Think's only automatic shell exception reads the configured knowledge-base
environment variable. Orchestrator keeps Edit and Task denied but allows Bash
without prompts, including the exact required Herdr prerequisite check. This is
operational capability, not write authority: shell allowlists are not treated as
a sandbox. The profile remains coordination-scoped, with explicit
natural-language gates and behavioral prohibitions for startup, cleanup,
commit, integration, push, activation, publication, and other external effects.
Use `code-lite` or `code` for unrelated general utility or implementation work.

## Read-only subagents

| Subagent | Role |
| --- | --- |
| `explore` | Built-in codebase search with edit, shell, and child tasks denied |
| `research` | External documentation and relevant knowledge-base evidence |

`code`, `think`, and `plan` may delegate only to these two subagents.
`code-lite` and `orchestrator` cannot use OpenCode subagents. Research inherits
its invoking primary's model. OpenCode child sessions keep delegation visible
in the session log while the parent remains responsible for synthesis.

Merely selecting `orchestrator` or discussing delegation does not authorize
worker startup. Only an explicit natural-language request to execute, delegate,
or start work authorizes one bounded cycle. Cleanup is separate: finishing or
shipping does not authorize it. The user must explicitly request cleanup, for
example with “clean up” or “ship and clean up.” The checked cleanup helper
remains the only authorized cleanup path; broad Bash permission does not permit
raw Herdr or Git/worktree deletion commands.
