#!/usr/bin/env bash

set -euo pipefail

# https://nixos.org/manual/nixos/stable/#sec-installation-manual
main() {
  if [ "$(uname)" != "Linux" ]; then
    printf "OS not supported.\n"
    exit 1
  fi
  if ! grep -q '^ID=nixos$' /etc/os-release; then
    printf "Distro not supported.\n"
    exit 1
  fi

  create_partitions
  generate_config

  nixos-install --no-root-passwd
  reboot now
}

create_partitions() {
  parted /dev/sda -- mklabel gpt
  parted /dev/sda -- mkpart root ext4 512MB -8GB
  parted /dev/sda -- mkpart swap linux-swap -8GB 100%
  parted /dev/sda -- mkpart ESP fat32 1MB 512MB
  parted /dev/sda -- set 3 esp on
  sleep 1

  mkfs.ext4 -L nixos /dev/sda1
  mkswap -L swap /dev/sda2
  mkfs.fat -F 32 -n boot /dev/sda3
  sleep 1

  mount /dev/disk/by-label/nixos /mnt
  mkdir -p /mnt/boot
  mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
}

generate_config() {
  nixos-generate-config --root /mnt
  sed --in-place '/system\.stateVersion = .*/a \
			nix.package = pkgs.nixVersions.latest;\n \
			nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
      services.openssh.enable = true;\n \
			services.openssh.settings.PasswordAuthentication = true;\n \
			services.openssh.settings.PermitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix
}

main
