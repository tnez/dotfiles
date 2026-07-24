---
description: Drive one bounded plan-to-evidence work cycle
agent: build
---

# Do It

Coordinate exactly one bounded work cycle for the current repository. Read
`../PLAN.md` as route context, not as a backlog to execute mechanically.

This invocation has authority to:

- read the current Git repository, the explicit plan, and guidance selected
  through `~/AGENTS.md`;
- use the caller's current Herdr workspace from `HERDR_WORKSPACE_ID` only as
  the container for new work;
- create and control at most one fresh worker, worktree, tab, and pane.

Every other workspace is out of scope. Within the current workspace, every
pre-existing agent, pane, and tab other than this coordination session is also
out of scope, including idle or done agents. Their state is not permission to
reuse them. Do not prompt, inspect, wait on, focus, move, rename, release,
close, or otherwise control them. Do not directly run `herdr agent list`,
`herdr workspace list`, or search for existing capacity.

Use this main session only as the orchestrator. Do not implement or modify
repository files in the coordination checkout.

First orient:

1. Resolve the current repository, current Herdr workspace, and absolute plan
   path.
2. Read the plan, repository instructions, relevant repository state, and
   active guidance selected through `~/AGENTS.md`.
3. Reconstruct the beneficiary, intended value or decision, current state,
   consequential question, and next convergence gate.

If a demonstration, review, or decision gate is already ready, surface it and
stop. If a human-owned product, domain, risk, scope, or authority decision
blocks a bounded handoff, ask the consequential question and stop. Do not
create a worker in either case.

Otherwise, choose the smallest vertical slice or experiment that can produce
demonstrable value or decision-resolving evidence. Create exactly one new
isolated worker and worktree with `herdr-worktree-start.sh`. Use the caller's
current repository and explicit `HERDR_WORKSPACE_ID`, keep focus in the
coordination tab, and provide a cold-start prompt containing the goal, route
context, constraints, expected result, verification, evidence gate, and
completion boundary.

The helper is the only permitted way to create the worktree, tab, and worker.
Run its prerequisite check first. If the check or creation fails, report the
failure and stop rather than reusing an existing agent or assembling a broader
Herdr workflow manually.

Capture the helper's returned workspace, agent name, worktree path, tab ID, and
pane ID. Those exact returned resources are the only Herdr resources this
invocation may subsequently read or control. Communicate with and wait for only
that worker by its returned unique name.

When the worker finishes, independently inspect its worktree status and diff,
review the result against the bounded handoff, and run the relevant
verification. Ask that same worker for bounded corrections when necessary. If
a correction would require a materially different slice or another worker,
stop and bring the result or blocker to me instead.

Once the result is technically reviewed, bring me the demonstration, evidence,
and decision it unlocks, then stop. Do not create follow-up work, contact any
other agent, integrate, push, publish, clean up, or delete the worktree or
branch. Another work cycle requires a new `/do-it` invocation.

If $ARGUMENTS is non-empty, treat it as additional route context or constraints.
It cannot expand the authority or lifecycle boundaries above:

$ARGUMENTS
