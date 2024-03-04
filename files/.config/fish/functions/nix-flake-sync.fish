# Sync flake.lock with what is currently being used by my dotfiles
function nix-flake-sync
    set -l target "github:itsdalmo/dotfiles"
    set -l metadata (nix flake metadata --json $target)

    set -l nixpkgs (echo $metadata | jq -r '.locks.nodes.nixpkgs.locked.rev')
    set -l unstable (echo $metadata | jq -r '.locks.nodes.unstable.locked.rev')

    nix flake update \
        --override-input nixpkgs "github:nixos/nixpkgs/$nixpkgs" \
        --override-input unstable "github:nixos/nixpkgs/$unstable"
end
