# aliases
alias bat="bat --theme base16-256"
alias clip="tr -d '\n' | pbcopy"
alias cls="clear"
alias d="docker"
alias dc="docker-compose"
alias e="edit"
alias fm="ranger-cd"
alias g="git"
alias gs="git status"
alias la="ls -a"
alias lg="lazygit"
alias ll="ls -al"
alias nvim="nvim"
alias tp="t --project"

# set variables
set -x EDITOR nvim
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8
set -x N_PREFIX $HOME/n
set -x PAGER less
set -x VISUAL nvim

# install plugin manger (fisher) and any missing plugins
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

# set completions for GitHub CLI
if not test -e $HOME/.config/fish/completions/gh.fish
  gh completion -s fish > $HOME/.config/fish/completions/gh.fish
end

# emacs ansi-term support
if test -n "$EMACS"
    set -x TERM eterm-color
end

# this function may be required
function fish_title
    true
end

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

