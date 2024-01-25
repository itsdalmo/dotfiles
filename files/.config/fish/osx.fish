# Abbreviations
abbr -a upgrade 'brew update && brew upgrade && brew bundle install --global && brew bundle cleanup --force --global'

# Environment
set -gx EDITOR nvim
set -gx LC_ALL 'en_US.UTF-8'
set -gx AWS_DEFAULT_REGION eu-west-1
set -gx AWS_PAGER ''
set -gx USE_GKE_GCLOUD_AUTH_PLUGIN True
set -gx GOPATH "$HOME/go"
set -gx FZF_DEFAULT_COMMAND 'fd --follow --hidden'
set -gx FZF_CTRL_T_COMMAND 'fd --follow --hidden . $dir'

# Path
fish_add_path "$HOME/bin"
fish_add_path "$HOME/go/bin"

# Homebrew (Required on M1: https://github.com/Homebrew/discussions/discussions/446)
switch (uname -m)
    case arm64
        eval (/opt/homebrew/bin/brew shellenv)
    case x86_64
        eval (/usr/local/bin/brew shellenv)
end

# Zoxide
zoxide init fish | source

# Pyenv
pyenv init - | source
pyenv virtualenv-init - | source

# GCP
source (brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc
