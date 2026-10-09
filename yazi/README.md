# Yazi

Shared configuration for macOS and Omarchy. Retain hidden-file display, pane
proportions, preview sizing, and Markdown editor opening. Use Yazi's native
cut/paste/trash operations and default keymap, with Shift+T to maximize or restore
the preview. The binding's plugin dependency and install command are documented
beside it in `dot-config/yazi/keymap.toml`; plugins remain machine-owned.

The custom archive, fuzzy-move, Apple Notes/Reminders, and directory-creation
workflows are retired. Their removal does not move or delete any personal files.

## Activation and recovery

No-folding Stow owns `yazi.toml` and `keymap.toml`, not the whole live directory.
Preserve `package.toml`, installed plugins, and other machine-local files.
Activating the package applies the existing pane proportions and preview sizing
as well as the preview binding; platform support does not authorize activation.

On macOS, use the lifecycle described in `AGENT.md`. On Omarchy, after reviewing
`./dotfiles doctor` and `./dotfiles plan`, inspect the dry run from the canonical
primary checkout:

```sh
stow --dotfiles --no-folding --ignore='^(AGENT[.]md|README.*)$' \
  --simulate --verbose --target="$HOME" yazi
```

After explicit approval, omit `--simulate` to activate. Stop on conflicts; never
use `--adopt` or overwrite unmanaged files. Restart Yazi to load the configuration.
For recovery, remove only this package's owned links; plugins and package state
remain intact:

```sh
stow --dotfiles --no-folding --ignore='^(AGENT[.]md|README.*)$' \
  -D --target="$HOME" yazi
```

The ignore option keeps component guidance out of the home directory, matching
the lifecycle's ownership boundary.
