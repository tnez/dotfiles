# Open the workspace without controlling Scout's popup client

All values below are data. Use explicit socket, client and session/pane IDs,
quote arguments, and never send commands into an existing pane with `send-keys`.
Do not infer a client from whichever session happens to be current.

## Establish the origin

From Scout, resolve the current server socket and read:

```sh
tmux display-message -p '#{socket_path}'
tmux show-options -qv -t '=dotfiles-agent' @dotfiles-agent-popup
tmux show-options -qv -t '=dotfiles-agent' @dotfiles-agent-origin
```

Require the popup marker to be `1`. The origin is newline-delimited display data:
`Client: ...`, session/window names and IDs, `Pane: %...`, `Directory: ...`.
Do not execute it or split names on spaces. Validate the client and pane by
listing current state on that same socket:

```sh
tmux -S "$socket" list-clients \
  -F '#{client_name}|#{session_id}|#{pane_id}'
tmux -S "$socket" display-message -p -t "$origin_pane" \
  '#{pane_id}|#{session_id}|#{window_id}'
```

Require the named client to still display that exact origin pane/session/window,
and exactly one client to display that pane. It must not be Scout's marked
session. If metadata changed since inspection, stop and refresh the intended
origin; a later summon is not approval to switch a different client for this
request. Missing, malformed, ambiguous, or stale origin means stop; never use
Scout's `$TMUX_PANE` as a fallback.

For a non-Scout invocation already inside tmux, verify exactly one client displays
the invoking `$TMUX_PANE` and use that client/pane. With a verified server but
no attached client, create only a detached workspace and report how to attach.
If no server can be verified, retain the checkout and report the launch blocker;
do not fabricate a socket or `$TMUX` context.

## Prefer the installed dev launcher

Resolve `command -v dev` and inspect its implementation/help, without running
unknown code. The dotfiles launcher runs from the physical cwd, creates/resumes
its own session, and targets the unique client displaying `$TMUX_PANE`. It adds
only general project instructions, not the user's task. Other implementations
must be reviewed for the same safety before use. Missing/unsuitable `dev` is a
reason to use the plain-session fallback, not install or rewrite it.

For the reviewed dotfiles launcher, with the current `$TMUX` already pointing
at the verified server, invoke it in a subshell with only its origin-pane selector
changed for this call:

```sh
(cd -- "$checkout_path" && env TMUX_PANE="$origin_pane" "$dev_path")
```

This does not send input to the origin pane or change another process's
environment. Revalidate the origin metadata/client immediately before launch.
Do not pass a task prompt, run `dev resize`, or manually precreate a session.
`dev` refuses multiple clients showing the origin pane. If it fails, inspect
partial state and report it; do not mask that failure with another launcher.

Find the resulting session by its exact `@dev_workflow_root` physical path and
require `@dev_workflow_ready` to be `1`. Require exactly one matching session,
verify its pane paths, then record `@activity_checkout` as that same physical
path on the verified session ID. Do not adopt an unrelated session just because
its name looks like `dev-*`.

## Plain-session fallback

Look for a session whose `@activity_checkout` equals this physical checkout.
Verify its repository and pane paths before reuse. If none exists, choose a
readable, unused `work-<owner>-<repo>-<activity>` session name (add a suffix on
collision). Create a detached shell session and capture its ID:

```sh
session_id=$(tmux -S "$socket" new-session -d -P -F '#{session_id}' \
  -s "$session_name" -c "$checkout_path")
tmux -S "$socket" set-option -t "$session_id" \
  @activity_checkout "$checkout_path"
```

Never overwrite/adopt a session on name collision. If marking fails, report
and retain the partial session rather than killing it automatically. Recheck
the origin still matches the request before switching only its verified client:

```sh
tmux -S "$socket" switch-client -c "$origin_client" -t "$session_id"
```

With no origin client, leave the session detached and return an attach command.
Read back `list-clients` and session options to verify the result. Scout's own
session/client and unrelated clients must remain unchanged. Do not detach or
kill Scout to finish; the user can hide its popup with the normal binding.
