# config

My peronsal dotfile / config collection.

## How this works

All my configs and dotfiles live in the `~/.config` so I can neatly wrangle everything into a single version controlled location. Each software gets its own directory and files will be symlinked to wherever they need to exist in the filesystem (most often into my home directory) for all the things to work :pray:

## Notes

### Install

Follow the instructions to install on a fresh **Ubuntu Server 20.04** installation.

1. Follow the [instructions](https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) to setup an `ssh` key for **GitHub**.
1. Install git:
   `sudo apt-get install git`
1. Create Projects directory:
   ```
   mkdir ~/Projects
   mkdir ~/Projects/tnez
   mkdir ~/Projects/vendor
   ```
1. Clone this config dir:
   `git clone git@github.com:tnez/config.git ~/Projects/tnez/config`
1. Run the appropriate install script for your version:
   `~/Projects/tnez/config/install-ubuntu-{version}.sh`
1. Add the following line to `/etc/default/keyboard`:
   `XKBOPTIONS="ctrl:swapcaps,altwin:swap_alt_win"`
1. Reboot machine for all settings to take effect: `sudo shutdown -r now`
1. Follow the instructions to install any remaining software
   - [Rescuetime](https://www.rescuetime.com/download_linux)
   - [Zoom](https://support.zoom.us/hc/en-us/articles/204206269-Installing-Zoom-on-Linux#h_adcc0b66-b2f4-468b-bc7a-12c182f354b7)
