# General config
export EDITOR=nvim

# Zsh config
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="agnoster"
plugins=(
    git
)

source $ZSH/oh-my-zsh.sh

# Go path
export GOPATH="$HOME/Github/go"
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin

# Aliases
alias ll='exa -la --group-directories-first --all'
alias rust-musl-builder='docker run --rm -it -v "$(pwd)":/home/rust/src ekidd/rust-musl-builder:nightly'

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
