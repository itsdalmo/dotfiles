# Abbreviations
abbr -a upgrade 'brew update && brew upgrade && brew bundle install --global && brew bundle cleanup --force --global'

# Homebrew (Required on M1: https://github.com/Homebrew/discussions/discussions/446)
switch (uname -m)
    case arm64
        eval (/opt/homebrew/bin/brew shellenv)
    case x86_64
        eval (/usr/local/bin/brew shellenv)
end

# Jetbrains toolbox
if test -d "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
    fish_add_path "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
end
