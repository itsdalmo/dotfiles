#!/usr/bin/env bash

set -euo pipefail

declare _dotfiles_path _dotfiles_repo
_dotfiles_path="${HOME}/code/github.com/itsdalmo/dotfiles"
_dotfiles_repo="https://github.com/itsdalmo/dotfiles.git"

main() {
  printf "Installing itsdalmo/dotfiles...\n"

  case $(uname) in
  'Darwin')
    install_darwin
    ;;
  *)
    printf "OS not supported.\n"
    exit 1
    ;;
  esac

  printf "\n"
  printf "Done. Note that some of these changes require a logout/restart to take effect.\n"
}

install_darwin() {
  if ! xcode-select -p &>/dev/null; then
    printf " * Installing xcode (rerun the installer after installation is complete)\n"
    xcode-select --install
    exit 0
  fi
  if [ ! -d "/usr/libexec/rosetta" ]; then
    printf " * Installing rosetta\n"
    softwareupdate --install-rosetta --agree-to-license
  fi

  clone_dotfiles
  install_brew
  install_nix
  install_nix_darwin
}

clone_dotfiles() {
  if [ ! -d "${_dotfiles_path}" ]; then
    printf " * Cloning repository\n"
    git clone "${_dotfiles_repo}" "${_dotfiles_path}"
  fi
}

install_brew() {
  if ! command -v "brew" >/dev/null; then
    printf " * Installing homebrew\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    printf " * Adding brew to path\n"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

install_nix() {
  if ! command -v "nix" >/dev/null; then
    printf " * Installing nix\n"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

    # Make it available in the current shell
    set +u
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    set -u
  fi

  # Create required folder for home-manager (nix-installer does not create it).
  mkdir -p ~/.local/state/nix/profiles
}

install_nix_darwin() {
  if command -v "darwin-rebuild" >/dev/null; then
    printf " * Updating nix-darwin configuration\n"
    darwin-rebuild switch --flake "${_dotfiles_path}#dalmobook"
  else
    printf " * Installing nix-darwin configuration\n"
    nix run nix-darwin -- switch --flake "${_dotfiles_path}#dalmobook"
  fi
}

main
