# config

My personal dotfile / config collection.

_Note: I want to reconfigure all of this to support a workflow where I `ssh` into **Github Codespaces** via an **iPad**. Can I do it???_

## How this works

All my configs and dotfiles live in the `~/.config` so I can neatly wrangle everything into a single version controlled location. Each software gets its own directory and files will be symlinked to wherever they need to exist in the filesystem (most often into my home directory) for all the things to work :pray:

## Notes

### Install

Follow the instructions to install on a fresh **Mac OS X** installation.

1. Follow the [instructions](https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) to setup an `ssh` key for **GitHub**.
1. Create Projects directory:
   ```
   mkdir ~/Code
   mkdir ~/Code/tnez
   ```
1. Clone this config directory:
   `git clone git@github.com:tnez/config.git ~/Code/tnez/config`
1. Run the appropriate install script for your version: _TODO: I need to create an install script for **Mac OS X**_
