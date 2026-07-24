# Global Agent Instructions

At the start of every session, if the current project contains an
`AGENTS.md`, read it before doing any work and follow its instructions.

General personal context and durable knowledge live in the private knowledge
base rooted at `${TNEZDEV_KNOWLEDGE_BASE_ROOT}`. Resolve that variable from the
process environment rather than treating it as a literal path. When that
context is relevant, read `${TNEZDEV_KNOWLEDGE_BASE_ROOT}/AGENTS.md`, then use
`${TNEZDEV_KNOWLEDGE_BASE_ROOT}/root/index.md` to select task-relevant context.
If the variable or either entrypoint is unavailable, report that configuration
problem instead of searching for another checkout.

Before substantial coding, use that index to locate and follow the active
Software Development Opinions. For multi-session work, uncertain routes, or
capability accumulation without visible outcomes, also locate and follow active
Initiative Wayfinding guidance. If a demonstration, review, or decision gate is
ready, run or surface it before generating another session or work item.

Before initializing a project, creating isolated branch work, or delegating a
work request, read `root/processes/project-initialization-and-worktrees.md` from
that knowledge base at
`${TNEZDEV_KNOWLEDGE_BASE_ROOT}/root/processes/project-initialization-and-worktrees.md`.
