# aliases
alias clip="tr -d '\n' | pbcopy"
alias cls="clear"
alias d="docker"
alias dc="docker-compose"
alias e="~/Vendor/nvim.appimage"
alias g="hub"
alias git="hub"
alias gs="git status"
alias la="ls -a"
alias ll="ls -al"

# set variables
set -x EDITOR vim
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8
set -x PAGER less
set -x TERM xterm-256color
set -x VISUAL vim

# install plugin manger (fisher) and any missing plugins
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

# emacs ansi-term support
if test -n "$EMACS"
    set -x TERM eterm-color
end

# this function may be required
function fish_title
    true
end

# virtualenv (virtualfish)
eval (python3 -m virtualfish)
