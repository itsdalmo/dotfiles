# Abbreviations
abbr -a upgrade 'sudo apt-get update && sudo apt-get upgrade'

# Environment
set -gx GOPATH "$HOME/go"

# Path
fish_add_path /usr/local/go/bin

# Start SSH agent
eval (ssh-agent -c)
