#!/usr/bin/env bash

set -euo pipefail

main() {
  if [ "$(uname)" != "Darwin" ]; then
    printf "OS not supported.\n"
    exit 1
  fi
  install_xcode
  install_rosetta
  install_brew
  install_nix
}

install_xcode() {
  if ! xcode-select -p &>/dev/null; then
    printf " * Installing xcode (rerun the installer after installation is complete)\n"
    xcode-select --install
    exit 0
  fi
}

install_rosetta() {
  if [ ! -d "/usr/libexec/rosetta" ]; then
    printf " * Installing rosetta\n"
    softwareupdate --install-rosetta --agree-to-license
  fi
}

install_brew() {
  if ! command -v "brew" >/dev/null; then
    if [ ! -f /opt/homebrew/bin/brew ]; then
      printf " * Installing homebrew\n"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
    printf " * Adding brew to path\n"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

install_nix() {
  if ! command -v "nix" >/dev/null; then
    if [ ! -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
      printf " * Installing nix\n"
      curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    fi

    set +u
    printf " * Adding nix to path\n"
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    set -u
  fi
}

main
