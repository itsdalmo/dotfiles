# dotfiles

My setup for development on macOS (and NixOS).

## Installation

### MacOS

```sh
# Run the bootstrap script
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/itsdalmo/dotfiles/refs/heads/master/scripts/bootstrap_macos.sh)"

# Run the initial install
nix run nix-darwin -- switch --flake github:itsdalmo/dotfiles#dalmobook

# Afterwards we can use darwin-rebuild directly
darwin-rebuild switch --flake github:itsdalmo/dotfiles#dalmobook
```

After rebooting, complete the following manual steps:

- System settings:
  - `Displays > Night Shift > Schedule: Sunset to Sunrise`
  - `Sound > Show volume in menu bar`
  - Enable "stacks" on the desktop.

### NixOS

```sh
# Run the bootstrap script
nix-shell -p curl --run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/itsdalmo/dotfiles/refs/heads/master/scripts/bootstrap_nixos.sh)"

# Run the initial install with a reboot
nixos-rebuild boot --flake github:itsdalmo/dotfiles#nixos-vm && reboot

# Do normal rebuilds to update
sudo nixos-rebuild switch --flake github:itsdalmo/dotfiles#nixos-vm
```

### VM (NixOS)

```sh
# Create the vm
./scripts/vm.sh create ~/Desktop/isos/nixos-minimal-24.05.6668.e8c38b73aeb2-aarch64-linux.iso

# Install nixos (after you have manually set the root password)
./scripts/vm.sh install

# Rebuild and reboot
./scripts/vm.sh rebuild-and-reboot

# Rebuild on updates
./scripts/vm.sh rebuild
```

## Comparing generations

In order to compare generations we can first build the derivation and then look at the diff:

```sh
# Build the derivation
darwin-rebuild build --flake .#dalmobook

# Compare with the current system
nix store diff-closures /run/current-system ./result
```

## Shared packages in other repositories

Use `legacyPackages.${system}` to get the same package set as the machine
configurations, including `allowUnfree`, custom packages, and `pkgs.unstable`.
Linux uses the locked `nixpkgs` input; macOS uses `nixpkgs-darwin`.
Both platforms use the shared `nixpkgs-unstable` input for `pkgs.unstable`.
The current unstable pin does not support Intel Macs (`x86_64-darwin`); use
stable packages on that platform.

A project can expose development shells for all supported systems without its
own nixpkgs input or platform selection:

```nix
{
  inputs.dotfiles.url = "github:itsdalmo/dotfiles";

  outputs = { dotfiles, ... }: {
    devShells = builtins.mapAttrs (system: pkgs: {
      default = pkgs.mkShell {
        packages = [ pkgs.git pkgs.go ];
      };
    }) dotfiles.legacyPackages;
  };
}
```

Run `nix develop` to select the shell for the current system. If a project already
has a per-system helper, use `pkgs = dotfiles.legacyPackages.${system};` inside it.

Commit the project's `flake.lock`. Updating dotfiles does not automatically
change existing project locks; run `nix flake update dotfiles` in each project
to adopt a newer revision. Projects share the pins when they lock the same
dotfiles revision. Inputs of third-party flakes may still need their own
`follows` declarations when compatible.
