# Abbreviations
abbr -a upgrade 'brew update && brew upgrade && brew bundle install --global && brew bundle cleanup --force --global'

# Homebrew (Required on M1: https://github.com/Homebrew/discussions/discussions/446)
switch (uname -m)
    case arm64
        eval (/opt/homebrew/bin/brew shellenv)
    case x86_64
        eval (/usr/local/bin/brew shellenv)
end

# GCP
source (brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc
