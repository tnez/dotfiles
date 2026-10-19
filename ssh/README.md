# SSH passphrase caching

## macOS

The Darwin-only Stow configuration uses `AddKeysToAgent` and the macOS keychain.
It also includes machine-local OrbStack SSH configuration. Do not stow it onto
Linux.

## Omarchy: one agent per login session

Use the installed OpenSSH `ssh-agent.socket`, not an agent started by each shell.
Keep the key passphrase. Unlock once per agent lifetime; logout/reboot or agent
restart clears cached keys. Desktop locking does not itself clear this cache.
No automatic unlock or passphrase storage is configured.

Linux files below are machine-local, not Stow targets. Before setup, run
`./dotfiles doctor` and `./dotfiles plan`, inspect current SSH/agent/shell state,
and obtain activation approval. Stop on `ACTION_REQUIRED`. If another agent or
forwarded socket is already selected, resolve that choice rather than replacing
it silently. Preserve all unrelated config and make a private backup before
editing. Do not replace whole SSH or shell files with these snippets.

### Approved setup

1. Confirm `systemctl --user cat ssh-agent.socket ssh-agent.service` shows the
   packaged socket at `%t/ssh-agent.socket`. Enable it:

   ```sh
   systemctl --user enable --now ssh-agent.socket
   ```

2. Add `~/.config/environment.d/60-ssh-agent.conf` for future user-session apps:

   ```ini
   SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/ssh-agent.socket
   ```

   Reload the user manager and publish the socket for newly started services:

   ```sh
   systemctl --user daemon-reload
   export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
   systemctl --user set-environment SSH_AUTH_SOCK="$SSH_AUTH_SOCK"
   ```

3. Add this to the existing Omarchy `~/.bashrc`, before its non-interactive return,
   without removing the packaged configuration includes. It preserves an
   inherited/forwarded agent:

   ```bash
   if [[ -z ${SSH_AUTH_SOCK:-} && -n ${XDG_RUNTIME_DIR:-} ]]; then
     export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
   fi
   ```

4. Reconcile this GitHub-only block in `~/.ssh/config`, before broader defaults
   that might win OpenSSH first-value precedence. Preserve other host blocks:

   ```sshconfig
   Host github.com
     IdentityAgent /run/user/%i/ssh-agent.socket
     AddKeysToAgent yes
   ```

   The explicit socket lets existing processes use the local agent for GitHub
   even without a refreshed environment. It deliberately overrides forwarded
   agents for `github.com` only. Other hosts retain their existing selection.
   Host aliases require separate review; this block matches `github.com`.
   Keep the config private with `chmod 600 ~/.ssh/config`.

5. For an existing tmux server, publish the socket globally and to each existing
   session after checking it is not using another intended agent:

   ```sh
   tmux set-environment -g SSH_AUTH_SOCK "$SSH_AUTH_SOCK"
   tmux list-sessions -F '#{session_id}' | while IFS= read -r session; do
     tmux set-environment -t "$session" SSH_AUTH_SOCK "$SSH_AUTH_SOCK"
   done
   ```

   Existing panes/processes cannot inherit an environment change retroactively.
   Use a new shell or explicitly export the socket in an existing shell. Do not
   restart sessions or inject commands into their panes. The normal tmux
   `update-environment` option should include `SSH_AUTH_SOCK`; Bash provides a
   fallback if an older attaching client unsets it.

6. Unlock in your own terminal (substitute your existing key path):

   ```sh
   SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket" ssh-add ~/.ssh/id_ed25519
   ```

   Alternatively, the next interactive SSH connection to GitHub unlocks and
   automatically adds its key. Never send the passphrase to an agent/chat.

### Read-only health and verification

```sh
systemctl --user is-enabled ssh-agent.socket
systemctl --user is-active ssh-agent.socket
SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket" ssh-add -l
ssh -G git@github.com | grep -E '^(identityagent|addkeystoagent) '
```

An empty reachable agent reports `The agent has no identities` (exit 1), not
`Could not open a connection` (exit 2). After unlocking, test twice:

```sh
ssh -o BatchMode=yes -T git@github.com
ssh -o BatchMode=yes -T git@github.com
```

Both should identify your GitHub account without a passphrase prompt. GitHub
returns exit 1 even for successful authentication because it provides no shell;
check the greeting, not just exit status. Network failures are not proof of an
agent defect. Test new terminals and tmux panes with `ssh-add -l` as well.

HTTPS remotes and GitHub API operations use `gh` credentials rather than this
agent. Do not change remote URLs or credential helpers to solve SSH caching.

### Recovery

Remove only the introduced Bash block, environment file and GitHub options,
preserving later local edits. Disable the socket only if this setup enabled it:

```sh
systemctl --user disable --now ssh-agent.socket
systemctl --user stop ssh-agent.service
systemctl --user daemon-reload
```

Stopping the agent discards cached keys. If manager/tmux `SSH_AUTH_SOCK` still
points to this socket, unset only that value or restore its recorded predecessor;
refresh your terminal environment afterward. Do not kill tmux sessions or restore
an old whole-file shell backup over subsequent changes.
