# config

My peronsal dotfile / config collection.

## How this works

All my configs and dotfiles live in the `~/.config` so I can neatly wrangle everything into a single version controlled location. Each software gets its own directory and files will be symlinked to wherever they need to exist in the filesystem (most often into my home directory) for all the things to work :pray:

## Notes

### Ubuntu Install

At the moment I prefer using **apt** to **brew** to insall dependencies. As such the process goes something like this.

1. Install chrome and setup lastpass
1. Create ssh key and add to github
1. Install git:
    `sudo apt-get install git`
1. Create Projects directory:
    `mkdir ~/Projects`
1. Clone this config dir:
    `git clone git@github.com:tnez/config.git ~/Projects/tnez--config`
1. Run linux install script:
    `~/Projects/tnez--config/linux-install.sh`
