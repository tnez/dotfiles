# Refit existing dev sessions to the current screen

From an attached tmux shell, run:

```sh
dev resize          # refit all verified dev-* sessions automatically
dev resize --check  # inspect and propose only
```

Bare `dev` still starts/resumes a project; it never resets existing layouts.
`dev resize` is a thin wrapper around this runbook, executed by a fresh headless
Pi using your configured default provider/model. It resolves the primary
checkout through the launcher symlink, regardless of the shell's directory,
and retains the invoking tmux client. No editor dependency is needed to resize.
The command prints a progress notice and Pi's final summary; it does not open
another TUI or require confirmation for the approved refit.

Alternatively, ask an agent:

> Follow `docs/runbooks/dev-layout.md` to refit all launcher-owned dev sessions
> to this client's screen. Show me the proposed changes before applying them.

This remains an agent-operated runbook, not a second layout engine, keybinding,
hook or resize watcher. The wrapper supplies it through Pi's CLI; no permanent
Pi prompt, settings, model selection or project-trust changes are installed.
It runs with `--no-session`, `--no-approve`, `--no-mcp` and `read,bash` tools.
These are not a sandbox: Bash retains the user's permissions, and preview-only
behavior depends on the agent following the instructions. Global Pi extensions
still use the user's normal discovery settings.

Pi's exit status is propagated, but a successful Pi response can still report
blocked sessions. Read the final summary; exit status alone is not proof of a
successful refit. Authentication/provider failures need normal Pi setup, not
installation or configuration changes by the wrapper.

## Target and boundaries

Aim for the layout a fresh `dev` invocation would create on the invoking
client's current screen, using the existing editor, agent and shell processes.
This is **not** an equalization or fixed-percentage split. Explicitly approved
refitting supersedes manual adjustments within the selected role layout.

For this runbook, "all tmux sessions" means all verified `dev-*` sessions only.
Ignore every non-`dev-*` session, including utility sessions. Do not apply the
project layout to them.

Read [Omarchy guidance](../../omarchy/AGENT.md) and the installed `dev` source
(resolve `command -v dev`) before acting. The reviewed reference is
[`omarchy/dot-local/bin/dev`](../../omarchy/dot-local/bin/dev). If the installed
policy differs, report it and resolve which policy to use before mutation.
Do not change launcher defaults as part of a refit.

Preserve process state, pane IDs, working directories, scrollback, ownership
metadata, unrelated panes/windows/sessions and host tmux configuration. No
restarts, respawns, injected application keystrokes, new role processes, Git
operations, Stow, config reloads or package installation are needed.

## 1. Inspect and establish scope (read-only)

- Work from the canonical primary dotfiles checkout with a `.git` directory,
  on Omarchy. Do not perform the live operation from a disposable checkout.
  Run `./dotfiles doctor` and `./dotfiles plan`. Stop on `ACTION_REQUIRED` and
  report its exact requested decision; approval is not permission to bypass it.
- Inspect clients, sessions, windows and panes. Useful starting commands:

  ```sh
  tmux list-clients -F '#{client_name}|#{session_id}|#{pane_id}|#{client_width}|#{client_height}'
  tmux list-sessions -F '#{session_id}|#{session_name}|#{@dev_workflow_root}|#{@dev_workflow_ready}'
  tmux list-windows -a -F '#{session_id}|#{window_id}|#{window_name}|#{window_width}|#{window_height}|#{window_layout}'
  tmux list-panes -a -F '#{session_id}|#{window_id}|#{pane_id}|#{pane_pid}|#{pane_current_command}|#{pane_current_path}'
  ```

- Identify the unique client whose active `pane_id` equals the requesting
  agent's `TMUX_PANE`. Measure that **whole client**, not the agent pane or
  whichever client attached most recently. If absent or ambiguous, ask the
  user to identify the target client. Re-measure if it resizes during planning.
- Enumerate `dev-*` sessions, but require non-empty `@dev_workflow_root` and
  `@dev_workflow_ready = 1`; a name alone is not proof of launcher ownership.
  Include renamed owned sessions only after confirming scope with the user.
  Report unowned/incomplete candidates rather than repairing or adopting them.
- Map editor, agent and shell to stable pane IDs in each selected session.
  Use window structure, names and current commands as evidence, not pane
  indexes alone. A shell may be running another command. Ask about ambiguous,
  missing, dead or additional panes; do not guess or create replacements.
- Inspect session status height, `default-size`, window sizing policies, local
  versus inherited option values, zoom, active panes/windows and window links.
  Shared/linked windows or other clients attached to a target session require
  an explicit impact decision before proceeding. Do not detach other clients
  or modify unrelated sessions to obtain the desired size.
- Record the preimage privately: role IDs and PIDs, topology, layouts, names,
  dimensions, relevant options and focus. Use ignored `docs/plans/` if a
  receipt is useful; do not publish host paths or live session dumps.

## 2. Derive the fresh-launch target

Use the installed, reviewed launcher's rules. At the time of writing:

- Let `W` and `H` be the invoking client's columns and rows.
- For each target session, subtract its effective status rows from `H` to get
  usable height `U`: `off` means 0, `on` means 1, numeric 2–5 means that number.
  Unknown status height or non-positive dimensions require a stop.
- The editor goes in `dev`, at the top left.
- If `W >= 201`, place the agent on the right with width
  `A = min(W - 120 - 1, 100)`. The editor gets `W - A - 1` columns.
  Otherwise the existing agent gets its own `agent` window.
- If `U >= 66`, place the shell at the bottom, **full window width**, with
  15 rows and one separator row. The editor/agent area gets `U - 16` rows.
  Otherwise the existing shell gets its own `shell` window.
- Choose these two fallbacks independently. Every role window targets `W x U`.
  Keep the normal tmux sizing policy, rather than permanently pinning windows
  to manual size.

For example, a 203-column, 58-row client with one status row yields an
82-column agent beside a 120-column editor, both 57 rows tall, and a separate
shell window. A 309-column, 95-row client yields a 100-column agent beside a
208-column editor, with a full-width 15-row bottom shell. These are synthetic
examples, not a fixed ratio or machine-specific declaration.

## 3. Propose, then obtain approval

Show the chosen client/dimensions and, for every selected session, the current
role placement, proposed placement, exact widths/heights and necessary moves.
Identify extra state to preserve and any skipped/blocked sessions. Approval
must cover both resizing and moving existing panes between windows, including
replacing manual adjustments. Do not interpret an inspection request as live
mutation permission.

Invoking `dev resize` is explicit approval to preview and then automatically
apply the documented refit to all verified `dev-*` sessions, including manual
role arrangements. No second confirmation is required within that scope.
`dev resize --check` grants inspection only: no tmux mutations or file writes,
including receipts. Headless runs cannot ask follow-up questions; on ambiguity,
concurrent changes or decisions outside this scope, stop and report blockers.
Command invocation never authorizes bypassing `ACTION_REQUIRED`, changing code
or configuration, activating dotfiles, restarting processes or touching other
sessions. The wrapper itself only inspects clients; the agent performs the
remaining runbook checks and approved operations.

Before each session's mutation, recheck dimensions, ownership, role IDs,
processes and topology against the approved preimage. Concurrent changes mean
stop and re-plan, not force the old proposal.

## 4. Refit existing panes after approval

Operate one session at a time, with explicit session/window/pane IDs on every
command. Use the existing panes; do not kill and rebuild the session.

- When only proportions differ, resize the role panes in place.
- When placement must change, `break-pane -d` moves an existing pane into a
  separate window; `join-pane -d` moves it back without restarting its process.
  Detach the shell first when removing an old bottom row. If necessary,
  temporarily separate the agent too, leaving a single editor in `dev`.
- Size the editor and separate role windows to `W x U` with `resize-window`.
  This sets manual sizing: save and restore each window's original local or
  inherited `window-size` policy. Inspect the resulting dimensions; do not
  leave a manual override or change a global policy to hide sizing conflicts.
  As the launcher does, set the selected session's `default-size` to `W x U`.
- For the wide-screen layout, join the agent horizontally to the editor with
  `join-pane -d -h -l "$A"`. For a bottom shell, join it vertically with
  `join-pane -d -v -f -l 15`: `-f` makes it span the **whole window**, not just
  the editor column. Supply explicit source and target pane IDs to both.
  Joining agent first, then full-width shell reproduces the fresh topology.
- Restore the sizing policy after the structural work and verify sizes again.
  Give separate role windows the launcher names and disable automatic rename
  locally, as fresh creation does. Inspect name collisions first; preserve
  unrelated windows. Never issue `kill-window` to clean up a collision.
- Avoid unnecessary moves on an already-correct layout. Do not switch other
  clients; report if relocating the requesting agent changes its window.
  No application keystrokes are required.

If a command fails or the preimage changes, stop, inspect the partial result
and report it. Do not continue blindly across the remaining sessions.

## 5. Verify and recover

- Read back role placement and geometry against the target derived in step 2.
  Check agent width, shell height/full-width span and separator accounting.
  Check role names, automatic rename and restored sizing policies too.
- Confirm the original pane IDs and PIDs still exist, ownership is unchanged,
  and unrelated panes/windows/sessions and other clients were not altered.
  Working commands may naturally finish; report differences rather than
  claiming process preservation without evidence.
- Have the user switch through the refitted sessions on the invoking client.
  Detached-window measurements alone do not prove the attached experience.
  Normal tmux sizing remains active; other clients or later screen changes may
  change geometry again. Report policy constraints, not a false exact match.
- A repeat run on the same screen should propose no moves or size changes.
  Report completed, skipped and blocked sessions separately.

Recovery uses the saved pane map: move the **same panes** back to their original
window grouping, then restore recorded names, options, focus and dimensions.
A saved `window_layout` can restore proportions only when that window again
contains the same panes; it is not a cross-window undo. Empty source windows
may disappear during moves, so recreated window IDs may differ. Review any
partial result and obtain approval before recovery; never kill processes or
restore stale topology over intervening user changes.

This documentation itself needs no activation. An existing `dev` source link
makes wrapper edits available on the next invocation; do not restow/reload just
for this subcommand. Restoring the reviewed launcher revision removes the
wrapper without undoing live layouts or killing sessions. Executing a refit is
a live layout operation, not a lifecycle or configuration deployment.

Validate the wrapper with `bash tests/dev-resize.sh` (fake Pi/clients, no model
requests), plus `bash tests/dev.sh` and `python3 tests/dev-layout.py` for normal
launcher behavior. Fake Pi verifies CLI handoff, not model compliance. A real
headless preview/refit and the user walkthrough require separate live approval.
