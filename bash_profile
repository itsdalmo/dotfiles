# Git aware (color coded) prompt
export GITAWAREPROMPT=~/.bash/git-aware-prompt
source "${GITAWAREPROMPT}/main.sh"
export PS1="|\t|\u|\w\[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty\[$txtrst\]>>> "

# Git autocompletion
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

# Encoding
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Added by Homebrew installer for nvim
export NVM_DIR="~/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Use nvim as the default editor
export EDITOR=nvim

# Use homebrew version of vim
alias vim='/usr/local/bin/vim'

# Tmux setting and shortcut
alias tmux="TERM=screen-256color-bce tmux"
function dev {
         tmux att -t ${PWD} || tmux new -s ${PWD} 'tmux source-file ~/.tmux/dev-session.conf'
}
alias dev='dev'

# Use silver searcher with FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# AWS CLI setup
export EC2_HOME="/usr/local/ec2/ec2-api-tools-1.7.5.1"
export EC2_URL="ec2.eu-west-1.amazonaws.com"
export PATH="$PATH:$EC2_HOME/bin"
export JAVA_HOME="$(/usr/libexec/java_home)"

# Added by Anaconda3 4.1.1 installer
export PATH="//anaconda/bin:$PATH"

