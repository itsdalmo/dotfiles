set fish_greeting ""

# Abbreviations
abbr -a l ll
abbr -a g git
abbr -a tf terraform
abbr -a gs 'git status'
abbr -a gc 'git checkout'
abbr -a ga 'git add -p'
abbr -a gp 'git pull'
abbr -a gr 'git stash; and git pull --rebase; and git stash pop'
abbr -a gl 'git log --oneline --graph --max-count 20'
abbr -a awsv 'aws-vault exec'

# Environment
set -gx EDITOR nvim
set -gx LC_ALL 'en_US.UTF-8'
set -gx AWS_DEFAULT_REGION eu-west-1
set -gx AWS_PAGER ''
set -gx GOPRIVATE 'gitlab.com/pexip/*,github.com/pexip/*'
set -gx USE_GKE_GCLOUD_AUTH_PLUGIN True

# FZF
set -gx FZF_DEFAULT_COMMAND 'fd --follow --hidden'
set -gx FZF_CTRL_T_COMMAND 'fd --follow --hidden . $dir'

# Platform specific settings
switch (uname)
    case Darwin
        source (dirname (status --current-filename))/osx.fish
    case Linux
        source (dirname (status --current-filename))/linux.fish
end

# Zoxide
zoxide init fish | source

# GPG
set -gx GPG_TTY (tty)
gpgconf --launch gpg-agent

# Pyenv
pyenv init - | source
pyenv virtualenv-init - | source
