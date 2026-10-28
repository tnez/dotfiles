# Global agent instructions

Read the current project's `AGENTS.md` first. Project instructions and the
user's current request govern the work; knowledge-base guidance does not grant
permission to mutate machine state, publish, or change policy.

Keep reviews bounded: fix concrete, in-scope defects, verify those fixes, then report remaining concerns rather than starting another broad review without approval.

For agent setup or repair, follow the dotfiles checkout's `agents/AGENT.md`,
`pi/AGENT.md`, `pi/README.md`, and `docs/runbooks/agent-config.md`. Treat their
preferences as the declared end state: inspect, report the delta, obtain the
required approval, write regular local config files, and verify the result.
Do not substitute symlinks or merely describe preferences as completed setup.
Preserve unrelated settings, machine themes, credentials, sessions and skills.
A routine agent session does not authorize configuration reconciliation.
Do not search for or guess a dotfiles checkout when it is not supplied.

Prime knowledge-base context by reading the entrypoints below and then relevant
guidance. Readable paths alone do not mean context is loaded; report missing
entrypoints instead of claiming successful setup. Never copy the whole KB into
agent configuration.

For personal context, working agreements, or substantial coding, resolve
`TNEZDEV_KNOWLEDGE_BASE_ROOT` from the process environment. Read that checkout's
`AGENTS.md`, `root/index.md`, and `root/meta/agent-consumption.md`, then load only
task-relevant guidance. Report a missing root or unreadable entrypoint; do not
search for another checkout or infer policy from memory.

Consult the active Software Development Opinions before substantial coding,
Initiative Wayfinding for uncertain multi-session work, and the project/worktree
process before initializing or isolating work. Consult existing KB policy before
proposing changes to working agreements, including readiness/completion criteria.
Preserve maturity metadata: proposed guidance is not active policy; trials have
bounded scope. Resolve KB links starting with `/` against the checkout's `root/`,
not the host filesystem root.

When a task needs private machine-local operating context, resolve the optional
root only with `printenv TNEZDEV_LOCAL_CONTEXT_ROOT`, then read its `AGENTS.md`
router. Do not crawl that root or load it routinely. Keep credentials, sessions, and unmanaged files out
of dotfiles; never replace them as part of configuration convergence.
