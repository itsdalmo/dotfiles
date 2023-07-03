#!/usr/bin/env bash

set -eo pipefail

declare VMNAME
VMNAME="${VMNAME:-nixos}"

create_vm() {
  prlctl create "${VMNAME}" \
    --ostype=linux \
    --distribution=other \
    --no-hdd

  prlctl set "${VMNAME}" --device-add hdd --position 0 --image ~/Parallels/"${VMNAME}.pvm"/harddisk.hdd/harddisk.hdd --type plain --size 131072 --connect
  prlctl set "${VMNAME}" --device-set cdrom0 --position 1 --image ~/Desktop/nixos-minimal-23.11.2962.b8dd8be3c790-aarch64-linux.iso --connect
  prlctl set "${VMNAME}" --select-boot-device off --device-bootorder "hdd0 cdrom0"

  prlctl set "${VMNAME}" \
    --memsize=8192 \
    --smart-mount=off \
    --shared-cloud=off \
    --shared-profile=off \
    --auto-share-camera=off \
    --sync-host-printers=off \
    --sh-app-host-to-guest=off \
    --sh-app-guest-to-host=off \
    --auto-share-bluetooth=off \
    --auto-share-smart-card=off \
    --show-guest-app-folder-in-dock=off

  # Start the VM
  prlctl start "${VMNAME}"

  # Instructions
  cat <<EOF
Open the console on the VM and set the root password:
$ sudo su
# passwd

Then run the install command in this script.
EOF
}

# https://nixos.org/manual/nixos/stable/#sec-installation-manual
bootstrap_vm() {
  local ADDR
  ADDR=$(prlctl list -f -j "${VMNAME}" | jq -r '.[].ip_configured')

  ssh -p 22 -o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "root@${ADDR}" " \
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
    mount /dev/disk/by-label/boot /mnt/boot

    nixos-generate-config --root /mnt
		sed --in-place '/system\.stateVersion = .*/a \
			nix.package = pkgs.nixUnstable;\n \
			nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
      services.openssh.enable = true;\n \
			services.openssh.settings.PasswordAuthentication = true;\n \
			services.openssh.settings.PermitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix

    nixos-install --no-root-passwd
    reboot now
  "
}

install_vm() {
  local ADDR
  ADDR=$(prlctl list -f -j "${VMNAME}" | jq -r '.[].ip_configured')

  ssh -p 22 -o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "root@${ADDR}" " \
    nixos-rebuild boot --flake github:itsdalmo/dotfiles/nixos#parallels-vm && reboot
  "
}

main() {
  case "$1" in
  create-vm)
    create_vm "$2"
    ;;
  bootstrap-vm)
    bootstrap_vm
    ;;
  install)
    install_vm
    ;;
  *)
    echo "Usage: $0 {create-vm <name> | install}"
    exit 1
    ;;
  esac
}

main "$@"
