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
export EDITOR="vim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export NVM_DIR="$HOME/.nvm"
export PAGER="less"
export PATH="$HOME/bin:/usr/local/bin:/usr/local/sbin:"(brew --prefix qt@5.5)"/bin:$PATH"
export TERM=xterm-256color
export VISUAL="vim"

# setup rbenv
status --is-interactive; and source (rbenv init -|psub)

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
    set BASE16_SHELL "$HOME/.config/base16-shell/"
    source "$BASE16_SHELL/profile_helper.fish"
end

