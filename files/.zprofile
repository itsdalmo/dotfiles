# Go
export GOPATH="$HOME/go"
export PATH=$PATH:$GOPATH/bin

# AWS
export AWS_DEFAULT_REGION=eu-west-1
export AWS_PAGER=

# aws-vault
export AWS_MIN_TTL=20m

# tfswitch
export PATH=$PATH:$HOME/bin

# GCP
source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"

# Homebrew (Required on M1: https://github.com/Homebrew/discussions/discussions/446)
eval "$(/opt/homebrew/bin/brew shellenv)"
