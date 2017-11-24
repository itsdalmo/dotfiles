# Git aware (color coded) prompt
export GITAWAREPROMPT=~/.bash/git-aware-prompt
source "${GITAWAREPROMPT}/main.sh"

# Git autocompletion
if [ -f ~/.bash/git-completion.bash ]; then
  . ~/.bash/git-completion.bash
fi

# |21:36:02|user|~/Current/path(git_branch)>>>
export PS1="|\t|\u|\w\[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty\[$txtrst\]>>> "

# Encoding
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Added by Homebrew installer for nvim
export NVM_DIR="~/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Use nvim as the default editor
export EDITOR=nvim

# Tmux setting and shortcut
function dev {
         tmux att -t ${PWD} || tmux new -s ${PWD} 'tmux source-file ~/.tmux/dev-session.config'
}
alias dev='dev'
alias ll='ls -la'

# FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# GOLANG
export GOPATH="$HOME/Github/go"
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin

# AWS CLI setup
export EC2_HOME="/usr/local/ec2/ec2-api-tools-1.7.5.1"
export EC2_URL="ec2.eu-west-1.amazonaws.com"
export PATH="$PATH:$EC2_HOME/bin"

# Path stuff
export PATH="/Users/dalmo/anaconda/bin:$PATH"
export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin"
export PATH=~/.cargo/bin:$PATH
export RUST_SRC_PATH=~/.multirust/toolchains/nightly-x86_64-apple-darwin/lib/rustlib/src/rust/src

# Rust/Docker
alias rust-musl-builder='docker run --rm -it -v "$(pwd)":/home/rust/src ekidd/rust-musl-builder:nightly'

export PATH="$HOME/.cargo/bin:$PATH"