#!/usr/bin/env bash

set -euo pipefail

create_vm() {
  local _dotfiles_path _vm_name _vm_image
  _dotfiles_path="$(dirname "$0")"
  _vm_name="$1"
  _vm_image="$2"

  prlctl create "${_vm_name}" \
    --ostype=linux \
    --distribution=linux \
    --no-hdd

  prlctl set "${_vm_name}" --device-add hdd --position 0 --image ~/Parallels/"${_vm_name}.pvm"/harddisk.hdd/harddisk.hdd --type plain --size 131072 --connect
  prlctl set "${_vm_name}" --device-set cdrom0 --position 1 --image "${_vm_image}" --connect
  prlctl set "${_vm_name}" --select-boot-device off --device-bootorder "hdd0 cdrom0"

  # NOTE: --shf-host-defined is set to "home" because "off" disables sharing completely (must be a bug)
  prlctl set "${_vm_name}" \
    --memsize=8192 \
    --tools-autoupdate=yes \
    --isolate-vm=off \
    --smart-mount=off \
    --shared-cloud=off \
    --shared-profile=off \
    --auto-share-camera=off \
    --auto-share-bluetooth=off \
    --auto-share-smart-card=off \
    --sync-host-printers=off \
    --show-guest-app-folder-in-dock=off \
    --sh-app-host-to-guest=off \
    --sh-app-guest-to-host=off \
    --shf-host=on \
    --shf-host-defined=home \
    --shf-host-add dotfiles --path "${_dotfiles_path}" --mode rw --shf-description "Dotfiles" --enable

  # Start the VM
  prlctl start "${_vm_name}"
}

main() {
  case "$1" in
  create)
    create_vm "$2" "$3"
    ;;
  *)
    echo "Usage: $0 {create <vm-name> <iso> | share <vm-name> <path>}"
    exit 1
    ;;
  esac
}

main "$@"
