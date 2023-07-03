#!/usr/bin/env bash

set -euo pipefail

declare _dotfiles_path _dotfiles_repo
_dotfiles_path="${HOME}/code/github.com/itsdalmo/dotfiles"
_dotfiles_repo="https://github.com/itsdalmo/dotfiles.git"

main() {
  printf "Installing itsdalmo/dotfiles...\n"

  case $(uname) in
  'Linux')
    install_linux
    ;;
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

install_linux() {
  local _distro

  _distro=$(grep -oP '(?<=^ID=).*' /etc/os-release)

  case "$_distro" in
  'pop') ;;
  'fedora') ;;
  *)
    printf "Distro not supported.\n"
    exit 1
    ;;
  esac

  clone_dotfiles
  install_nix
  install_flake
  configure_shell
  configure_nvim
}

install_darwin() {
  if ! xcode-select -p &>/dev/null; then
    printf " * Installing xcode\n"
    xcode-select --install
  fi
  if [ ! -d "/usr/libexec/rosetta" ]; then
    printf " * Installing rosetta\n"
    softwareupdate --install-rosetta --agree-to-license
  fi

  clone_dotfiles
  link_dotfiles
  install_brew
  configure_shell
  configure_nvim

  # Add fzf to fish
  sudo -k # Revoke sudo permissions
  if [[ $(command -v "fzf") && $(command -v "homebrew") ]] && [ ! -f ~/.config/fish/functions/fzf_key_bindings.fish ]; then
    printf " * Installing FZF keybindings\n"
    yes | "$(brew --prefix)"/opt/fzf/install
  fi

  printf " * Configuring osx\n"
  source "${_dotfiles_path}/files/.macos"
}

clone_dotfiles() {
  if [ ! -d "${_dotfiles_path}" ]; then
    printf " * Cloning repository\n"
    git clone "${_dotfiles_repo}" "${_dotfiles_path}"
  fi
}

link_dotfiles() {
  declare files
  files="$(find "${DOTFILES_PATH}/files" -type f)"

  _distro=$(grep -oP '(?<=^ID=).*' /etc/os-release)
  _version=$(grep -oP '(?<=^VERSION_ID=).*' /etc/os-release)

  case "$_distro" in
  'nixos')
    # Ships with nix, but we need to activate flakes.
    printf "TODO: nixos switch and such\n"
    # configure_nvim
    ;;
  *)
    if [[ "$_distro" == "debian" ]]; then
      # Debian does not ship with git and curl
      if ! command -v "git" >/dev/null; then
        sudo apt install git
      fi
      if ! command -v "curl" >/dev/null; then
        sudo apt install curl
      fi
    fi
    if [[ "$_distro" == "fedora" ]]; then
      if ! command -v "chsh" >/dev/null; then
        sudo dnf install util-linux-user
      fi
    fi

    clone_dotfiles
    install_nix
    install_flake
    configure_shell
    configure_nvim
    ;;
  esac
}

install_brew() {
  if ! command -v "brew" >/dev/null; then
    printf " * Installing homebrew\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi

  clone_dotfiles
  install_nix
  install_flake
  configure_shell
  configure_nvim

  printf " * Installing brew bundle\n"
  brew bundle install --global | sed 's/^/    ~ /'

  printf " * Configuring osx\n"
  source "${_dotfiles_path}/files/.macos"
}

install_nix() {
  if ! command -v "nix" >/dev/null; then
    printf " * Installing nix\n"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  fi

  # Make it available in the current shell
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

  # Create required folder for home-manager (nix-installer does not create it).
  mkdir -p ~/.local/state/nix/profiles
}

install_flake() {
  local _os
  local _user
  local _arch

  _os=$(uname | tr '[:upper:]' '[:lower:]')
  _user=$(whoami)

  case $(uname -m) in
  aarch64 | arm64)
    _arch="arm64"
    ;;
  x86_64 | amd64)
    _arch="amd64"
    ;;
  *)
    printf "Architecture not supported.\n"
    exit 1
    ;;
  esac

  nix run github:nix-community/home-manager/release-23.11 -- switch --flake "${_dotfiles_path}#${_user}@${_arch}-${_os}"
}

configure_shell() {
  declare fish_bin
  fish_bin="$(which fish)"

  if ! grep -q "${fish_bin}" </etc/shells; then
    printf " * Adding fish to /etc/shells\n"
    echo "${fish_bin}" | sudo tee -a /etc/shells >/dev/null
  fi

  if ! echo "${SHELL}" | grep -q "fish"; then
    printf " * Setting fish as default shell\n"
    chsh -s "${fish_bin}"
  fi
}

configure_nvim() {
  if [[ $(command -v "nvim") ]] && [ ! -d "${HOME}/.config/nvim/plugin" ]; then
    printf " * Installing nvim plugins\n"
    nvim --headless "+Lazy! restore" +qa
  fi
}

main
