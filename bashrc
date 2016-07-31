export EDITOR=vim
export PS1="|\t|\u|\w|>>> "

alias tmux="TERM=screen-256color-bce tmux"
alias tmpig='tmux att -t pig-session || tmux new -s pig-session "tmux source-file ~/.tmux/pig-session.conf"'
alias tmjs='tmux att -t js-session || tmux new -s js-session "tmux source-file ~/.tmux/js-session.conf"'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

