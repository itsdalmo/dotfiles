# Requires:
# GAP: https://github.com/jimeh/git-aware-prompt
# FZF: https://github.com/junegunn/fzf
# AG : https://github.com/ggreer/the_silver_searcher
# (And tmux, vim, nvim)

# Git aware (color coded) prompt
export GITAWAREPROMPT=~/.bash/git-aware-prompt
source "${GITAWAREPROMPT}/main.sh"
export PS1="|\t|\u|\w\[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty\[$txtrst\]>>> " 

# Use homebrew version of vim as default editor
alias vim='/usr/local/bin/vim'
export EDITOR=vim

# Tmux setting and shortcut
alias tmux="TERM=screen-256color-bce tmux"
alias tmpig='tmux att -t pig-session || tmux new -s pig-session "tmux source-file ~/.tmux/pig-session.conf"'
alias tmjs='tmux att -t js-session || tmux new -s js-session "tmux source-file ~/.tmux/js-session.conf"'

# Use silver searcher with FZF 
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Added by Homebrew installer for nvim
export NVM_DIR="~/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
