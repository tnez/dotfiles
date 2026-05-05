# Install plugin manager and any missing plugins before using bass.
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

# Source shell-agnostic profile using bass for POSIX compatibility.
if test -f ~/.profile
    if type -q bass
        bass source ~/.profile
    else
        echo "warning: bass unavailable; ~/.profile was not sourced" >&2
    end
end

# Node (fnm)
if type -q fnm
    fnm env --use-on-cd --shell fish | source
    fnm use default --silent-if-unchanged >/dev/null 2>&1
end

# aliases
alias cc="claude --permission-mode bypassPermissions"
alias ccp="claude --permission-mode bypassPermissions -p"
alias clip="tr -d '\n' | pbcopy"
alias cls="clear"
alias g="git"
alias gd="nvim ':DiffviewOpen origin/main..HEAD'"
alias gs="git status"
alias ls="eza --icons"
alias la="ls -a"
alias ld="yazi"
alias lg="lazygit"
alias ll="ls -al"
alias python="python3"

# Setup zoxide if present
if type zoxide >/dev/null 2>&1
    zoxide init fish | source
    alias cd="z"
    alias zq="zoxide query -i"
end

# set _secret_ variables
# set -x OPENAI_API_KEY (cat ~/.secrets/OPENAI_API_KEY)
# set -x ANTHROPIC_API_KEY (cat ~/.secrets/ANTHROPIC_API_KEY)

# this function may be required
function fish_title
    true
end

test -e {$HOME}/.iterm2_shell_integration.fish; and source {$HOME}/.iterm2_shell_integration.fish

# activate pyenv
source (pyenv init - | psub)

# Television (fuzzy finder)
tv init fish | source

# Starship (Prompt)
starship init fish | source

# Ensure scratch tmux session exists (belt-and-suspenders for LaunchAgent)
if type -q tmux; and tmux info &>/dev/null; and not tmux has-session -t scratch &>/dev/null
    tmux new-session -ds scratch -c "$HOME/PARA/DESK/inbox"
    tmux send-keys -t scratch "nvim $HOME/PARA/DESK/inbox/scratch.md" Enter
end
