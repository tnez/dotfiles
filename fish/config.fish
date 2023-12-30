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
alias python="python3"
alias tp="t --project"

# set variables
set -x EDITOR vim
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8
set -x MODE LIGHT # set to DARK for dark mode
set -x N_PREFIX $HOME/n
set -x PAGER less
set -x VISUAL vim

# install plugin manger (fisher) and any missing plugins
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

# set completions for GitHub CLI
# if not test -e $HOME/.config/fish/completions/gh.fish
#  gh completion -s fish > $HOME/.config/fish/completions/gh.fish
# end

# emacs ansi-term support
if test -n "$EMACS"
    set -x TERM eterm-color
end

# this function may be required
function fish_title
    true
end

test -e {$HOME}/.iterm2_shell_integration.fish; and source {$HOME}/.iterm2_shell_integration.fish


# pnpm
set -gx PNPM_HOME /Users/tnez/Library/pnpm
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# activate pyenv
source (pyenv init - | psub)

# Add .local/bin to path
set -gx PATH "$HOME/.local/bin" $PATH

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/tnez/.local/lib/google-cloud-sdk/path.fish.inc' ]; . '/Users/tnez/.local/lib/google-cloud-sdk/path.fish.inc'; end
