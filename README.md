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
