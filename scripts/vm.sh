#!/usr/bin/env bash

set -euo pipefail

declare VMNAME
VMNAME="${VMNAME:-nixos-vm}"

create() {
  local IMAGE="${1}"

  prlctl create "${VMNAME}" \
    --ostype=linux \
    --distribution=other \
    --no-hdd

  prlctl set "${VMNAME}" --device-add hdd --position 0 --image ~/Parallels/"${VMNAME}.pvm"/harddisk.hdd/harddisk.hdd --type plain --size 131072 --connect
  prlctl set "${VMNAME}" --device-set cdrom0 --position 1 --image "${IMAGE}" --connect
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
}

delete() {
  prlctl delete "${VMNAME}"
}

# https://nixos.org/manual/nixos/stable/#sec-installation-manual
install() {
  local ADDR
  ADDR=$(prlctl list -f -j "${VMNAME}" | jq -r '.[].ip_configured')

  ssh -p 22 -o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "root@${ADDR}" " \
    nix-shell -p curl --run /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/itsdalmo/dotfiles/refs/heads/master/scripts/bootstrap_nixos.sh)\"
  "
}

rebuild_and_reboot() {
  local ADDR
  ADDR=$(prlctl list -f -j "${VMNAME}" | jq -r '.[].ip_configured')

  ssh -p 22 -o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "root@${ADDR}" " \
    nixos-rebuild boot --option tarball-ttl 0 --flake github:itsdalmo/dotfiles#nixos-vm && reboot
  "
}

rebuild() {
  local ADDR
  ADDR=$(prlctl list -f -j "${VMNAME}" | jq -r '.[].ip_configured')

  ssh -p 22 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "dalmo@${ADDR}" " \
    sudo nixos-rebuild switch --option tarball-ttl 0 --flake github:itsdalmo/dotfiles#nixos-vm
  "
}

main() {
  case "$1" in
  create)
    create "$2"
    cat <<EOF
'$VMNAME' created!

Open the console on the VM and set the root password:
$ sudo su
# passwd

Then run '$0 install' followed by '$0 rebuild-and-reboot'
EOF
    ;;
  'delete')
    delete
    ;;
  'install')
    install
    ;;
  'rebuild-and-reboot')
    rebuild_and_reboot
    ;;
  'rebuild')
    rebuild
    ;;
  *)
    echo "Usage: $0 { create <iso-image-path> | delete | install | rebuild-and-reboot | rebuild }"
    exit 1
    ;;
  esac
}

main "$@"
