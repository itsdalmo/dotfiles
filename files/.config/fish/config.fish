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
abbr -a gg lazygit
abbr -a awsv 'aws-vault exec'

# Platform specific settings
switch (uname)
    case Darwin
        source (dirname (status --current-filename))/osx.fish
end
