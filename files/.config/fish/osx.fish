# Abbreviations
abbr -a upgrade 'brew update && brew upgrade && brew bundle install --global && brew bundle cleanup --force --global'

# Environment
set -gx GOPATH "$HOME/go"

# Path
fish_add_path "$HOME/bin"
fish_add_path "$HOME/go/bin"

# Homebrew (Required on M1: https://github.com/Homebrew/discussions/discussions/446)
eval (/opt/homebrew/bin/brew shellenv)

# GCP
source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc
