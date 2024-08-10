set fish_greeting ""

if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end

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
abbr -a gg lazygit
abbr -a awsv 'aws-vault exec'

# Alias
alias k="kubectl"
alias cat="bat"

# Platform specific settings
switch (uname)
    case Darwin
        source (dirname (status --current-filename))/osx.fish
    case Linux
        source (dirname (status --current-filename))/linux.fish
end
