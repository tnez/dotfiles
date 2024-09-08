# aliases
alias clip="tr -d '\n' | pbcopy"
alias cls="clear"
alias g="git"
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
end

# set variables
set -x EDITOR nvim
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8
set -x MODE LIGHT # set to DARK for dark mode
set -x N_PREFIX $HOME/n
set -x PAGER less
set -x RIPGREP_CONFIG_PATH $HOME/.config/ripgrep/rg.conf
set -x VISUAL nvim
set -x ZK_NOTEBOOK_DIR $HOME/Documents/sb

# set _secret_ variables
set -x OPENAI_API_KEY (cat ~/.secrets/OPENAI_API_KEY)
set -x ANTHROPIC_API_KEY (cat ~/.secrets/ANTHROPIC_API_KEY)

# set fzf options
set -x FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border --preview-window=right:60% --preview 'bat --color=always --style=header,grid --line-range :500 {}'"

# install plugin manger (fisher) and any missing plugins
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
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

# Add go to path
set -gx PATH "$HOME/go/bin" $PATH

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/tnez/.local/lib/google-cloud-sdk/path.fish.inc' ]
    . '/Users/tnez/.local/lib/google-cloud-sdk/path.fish.inc'
end
