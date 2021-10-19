# Fish

This is my **fish** configuration. Most everything should be captured in the included dotfiles, but any relevant notes can be found below.

## Creating and Updating Local Packages

1. Create a directory to contain custom code (see `/tnez` for example)
1. Add an entry to `fishfile` corresponding to the local path of the directory (similar to `~/.config/fish/tnez`)
1. Any time you make changes to a local package you must re-install: `fisher update ~/.config/fish/tnez`
