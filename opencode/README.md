# OpenCode profiles

The OpenCode Stow package installs five explicit primary profiles:

| Profile | Variant | Role |
| --- | --- | --- |
| `code` | `high` | Default implementation profile |
| `code-lite` | `low` | Small, localized, low-risk implementation |
| `plan` | `xhigh` | Analysis and OpenCode plan-document writes only |
| `think` | `max` | Read-only investigation |
| `orchestrator` | `xhigh` | One explicitly authorized Herdr worker cycle |

All profiles use `openai/gpt-5.6-sol`. The built-in `build` profile is disabled.
Think's only automatic shell exception reads the configured knowledge-base
environment variable. Orchestrator automatically allows current-pane
discovery, the worktree helper, read-only Git inspection, and control of the
returned Herdr worker; independent verification commands require permission.

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
or start work authorizes one bounded cycle.
