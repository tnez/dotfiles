# aliases
alias be="bundle exec"
alias clip="tr -d '\n' | pbcopy"
alias cls="clear"
alias e="vim"
alias fixcam="sudokillall VDCAssistant; and sudo killall AppleCameraAssistant"
alias g="git"
alias gh="hub"
alias ghp="hub pull-request"
alias ghs="hub ci-status"
alias gs="git status"
alias la="ls -a"
alias ll="ls -al"
alias tmux="tmux -2"

# set variables
set -x EDITOR vim
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8
set -x PAGER less
set -x TERM xterm-256color
set -x VISUAL vim

# path modifications
set -g fish_user_paths "/usr/local/sbin" $fish_user_paths

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

# Base16 Shell
if status --is-interactive
    set BASE16_SHELL $HOME/.config/base16-shell/
    source $BASE16_SHELL/profile_helper.fish
end

