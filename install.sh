#!/usr/bin/env bash

set -euo pipefail

declare DOTFILES_PATH DOTFILES_REPO SSH_KEY
DOTFILES_PATH="${HOME}/code/github.com/itsdalmo/dotfiles"
DOTFILES_REPO="https://github.com/itsdalmo/dotfiles.git"
SSH_KEY="${HOME}/.ssh/id_rsa"

install() {
  printf "Installing itsdalmo/dotfiles...\n"

  if [ ! -d "${DOTFILES_PATH}" ]; then
    printf " * Cloning repository\n"
    git clone "${DOTFILES_REPO}" "${DOTFILES_PATH}" --recurse-submodules
  fi

  printf " * Linking dotfiles\n"
  link_dotfiles

  case $(uname) in
  'Linux') ;;

  'Darwin')
    if [ ! -d "/usr/libexec/rosetta" ]; then
      printf " * Installing rosetta\n"
      softwareupdate --install-rosetta --agree-to-license
    fi

    printf " * Configuring homebrew\n"
    configure_homebrew

    printf " * Configuring osx\n"
    source "${DOTFILES_PATH}/files/.macos"

    printf " * Configuring dock\n"
    configure_dock
    ;;

  *)
    printf "OS not supported.\n"
    exit 1
    ;;
  esac

  printf " * Configuring fish\n"
  configure_fish

  printf " * Configuring nvim\n"
  configure_nvim

  printf " * Configuring gpg\n"
  configure_gpg

  mkdir -p "$(dirname "$SSH_KEY")"
  if [ ! -f "${SSH_KEY}" ]; then
    if [ -t 0 ]; then
      printf " * Generating SSH key\n"
      ssh-keygen -t rsa -b 4096 -C "kristian@dalmo.me" -f "${SSH_KEY}"

      printf "\n"
      printf "Visit https://github.com/settings/ssh/new to add the new key:\n"
      cat "${SSH_KEY}.pub"
    else
      printf " * Skipping SSH key (executing non-interactively)\n"
    fi
  fi

  printf "\n"
  printf "Done. Note that some of these changes require a logout/restart to take effect.\n"
}

link_dotfiles() {
  declare files
  files="$(find "${DOTFILES_PATH}/files" -type f)"

  for file in $files; do
    local path="${file##"${DOTFILES_PATH}/files/"}"
    mkdir -p "$(dirname "${HOME}/${path}")"
    ln -sf "${file}" "${HOME}/${path}"
  done
}

configure_homebrew() {
  if ! command -v "brew" >/dev/null; then
    printf " * Installing homebrew\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi

  printf " * Installing brew bundle\n"
  brew bundle install --global | sed 's/^/    ~ /'
}

configure_gpg() {
  chown -R "$(whoami)" "${HOME}/.gnupg/"
  chmod 700 "${HOME}/.gnupg"

  find "${HOME}/.gnupg" -type f -exec chmod 600 {} \;
  find "${HOME}/.gnupg" -type d -exec chmod 700 {} \;
}

configure_fish() {
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

  sudo -k # Revoke sudo permissions
  if [[ $(command -v "fzf") && $(command -v "homebrew") ]] && [ ! -f ~/.config/fish/functions/fzf_key_bindings.fish ]; then
    printf " * Installing FZF keybindings\n"
    yes | "$(brew --prefix)"/opt/fzf/install
  fi
}

configure_nvim() {
  if [[ $(command -v "nvim") ]] && [ ! -d "${HOME}/.config/nvim/plugin" ]; then
    printf " * Installing nvim plugins\n"
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
  fi
}

configure_dock() {
  if ! dockutil --list | grep -q "GoLand"; then
    dockutil --no-restart --remove all --allhomes
    dockutil --no-restart --add "/Applications/Firefox.app"
    dockutil --no-restart --add "/System/Applications/Mail.app"
    dockutil --no-restart --add "/System/Applications/Calendar.app"
    dockutil --no-restart --add "/System/Applications/Messages.app"
    dockutil --no-restart --add "/System/Applications/Photos.app"
    dockutil --no-restart --add "/Applications/Discord.app"
    dockutil --no-restart --add "/Applications/Signal.app"
    dockutil --no-restart --add "/Applications/Slack.app"
    dockutil --no-restart --add "/Applications/GoLand.app"
    dockutil --no-restart --add "/Applications/Visual Studio Code.app"
    dockutil --no-restart --add "/Applications/WezTerm.app"
    dockutil --no-restart --add "/Applications/Agenda.app"
    dockutil --no-restart --add "/Applications/1Password 7.app"
    dockutil --no-restart --add "/Applications/Spotify.app"
  fi
}

install
