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

Optional machine-local operating context may be exposed through
`TNEZDEV_LOCAL_CONTEXT_ROOT`. Do not resolve or load it during routine startup.
Consult it when a task may depend on the user's current work, ongoing
responsibilities, attention state, personal operating context, or historical
material. References to "my projects," "what I'm working on," "my notes," "my
responsibilities," "my inbox," or "the archive" are common triggers.

Resolve that root only with `printenv TNEZDEV_LOCAL_CONTEXT_ROOT`. If set, read
`${TNEZDEV_LOCAL_CONTEXT_ROOT}/AGENTS.md` and follow its routing instructions,
loading only task-relevant context. Do not crawl or inventory the root. If the
variable is unset, continue normally. Report a configuration problem only when
the requested task requires this context and no usable entrypoint is available.

Before substantial coding, use that index to locate and follow the active
Software Development Opinions. For multi-session work, uncertain routes, or
capability accumulation without visible outcomes, also locate and follow active
Initiative Wayfinding guidance. If a demonstration, review, or decision gate is
ready, run or surface it before generating another session or work item.
