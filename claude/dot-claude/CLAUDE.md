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
