# General config
export EDITOR=vim
export LC_ALL=en_US.UTF-8

# ZSH config
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(
    git
    vi-mode
)
ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh

# GPG config
export GPG_TTY=$(tty)
gpgconf --launch gpg-agent

# FZF config
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --hidden --follow'
export FZF_CTRL_T_COMMAND='fd --hidden --follow'
export FZF_ALT_C_COMMAND='fd --hidden --follow --type d . $HOME'

# Zoxide config
eval "$(zoxide init zsh)"

# NVM config
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

# Aliases
alias ll='exa -la --group-directories-first'
alias awsv='aws-vault exec'
alias upgrade='brew update && brew bundle install --global && brew bundle cleanup --force --global && omz update'

# HACK: Assume AWS organization access role given an account ID.
aws-org-login() {
    sed -i.bak -E "s/^(role_arn[ ]*= arn:aws:iam::)[0-9]{12}(:role\/OrganizationAccountAccessRole)/\1$1\2/g" ~/.aws/config && aws-vault login org-access-role
}

# Disable sounds
unsetopt BEEP
