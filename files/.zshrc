# General config
export EDITOR=vim
export LC_ALL=en_US.UTF-8

# ZSH config
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="agnoster"
plugins=(
    git
)
ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh

# FZF config
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'

# Aliases
alias ll='exa -la --group-directories-first --all'
alias awsv='AWS_SESSION_TOKEN_TTL=30m aws-vault exec --duration=1h'
alias upgrade='brew update && brew bundle --global && brew bundle cleanup --global --force && upgrade_oh_my_zsh'
