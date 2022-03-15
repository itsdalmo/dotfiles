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
abbr -a upgrade 'brew update && brew bundle install --global && brew bundle cleanup --force --global'

# Path
fish_add_path "$HOME/bin"
fish_add_path "$HOME/go/bin"

# Environment
set -gx EDITOR nvim
set -gx LC_ALL 'en_US.UTF-8'
set -gx GOPATH "$HOME/go"
set -gx AWS_DEFAULT_REGION eu-west-1
set -gx AWS_PAGER ''
set -gx GOPRIVATE 'gitlab.com/pexip/*,github.com/pexip/*'

# Homebrew (Required on M1: https://github.com/Homebrew/discussions/discussions/446)
eval (/opt/homebrew/bin/brew shellenv)

# FZF
set -gx FZF_DEFAULT_COMMAND 'fd --follow --hidden'
set -gx FZF_CTRL_T_COMMAND 'fd --follow --hidden . $dir'

# Zoxide
zoxide init fish | source

# GPG
set -gx GPG_TTY (tty)
gpgconf --launch gpg-agent

# GCP
source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc
