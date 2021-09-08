#!/usr/bin/env bash

set -euo pipefail

declare DOTFILES_PATH DOTFILES_REPO SSH_KEY
DOTFILES_PATH="${HOME}/code/github.com/itsdalmo/dotfiles"
DOTFILES_REPO="git@github.com:itsdalmo/dotfiles.git"
SSH_KEY="${HOME}/.ssh/id_rsa"

install() {
  printf "Installing itsdalmo/dotfiles...\n"

  if ! command -v "brew" > /dev/null; then
    printf " * Installing homebrew\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi

  if [ ! -d "/usr/libexec/rosetta" ]; then
    printf " * Installing rosetta\n"
    softwareupdate --install-rosetta --agree-to-license
  fi

  mkdir -p "$(dirname $SSH_KEY)"
  if [ ! -f "${SSH_KEY}" ]; then
    printf " * Generating SSH key\n"
    ssh-keygen -t rsa -b 4096 -C "kristian@dalmo.me" -f "${SSH_KEY}"
    pbcopy < "${SSH_KEY}.pub"

    printf "   \n"
    printf "   Public key copied to clipboard.\n"
    printf "   Visit https://github.com/settings/ssh/new to add the new key and then rerun the installer!\n"
    exit 0
  fi

  if [ ! -d "${DOTFILES_PATH}" ]; then
    printf " * Cloning repository\n"
    git clone "${DOTFILES_REPO}" "${DOTFILES_PATH}" --recurse-submodules 
  fi

  printf " * Creating .gnupg directory\n"
  mkdir -p "${HOME}/.gnupg"
  chmod -R 600 "${HOME}/.gnupg"
  chmod 700 "${HOME}/.gnupg"

  printf " * Linking files\n"
  local dotfiles=(".Brewfile" ".gitconfig" ".gitignore" ".vimrc" ".ideavimrc" ".zprofile" ".zshrc" ".gnupg/gpg.conf" ".gnupg/gpg-agent.conf")
  for file in "${dotfiles[@]}"; do
    ln -sf "${DOTFILES_PATH}/files/${file}" "${HOME}/${file}"
  done

  printf " * Installing brew bundle\n"
  brew bundle --global | sed 's/^/    ~ /' 

  if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    printf " * Installing oh my ZSH\n"
    /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  if [[ $(command -v "fzf") ]] && [ ! -f ~/.fzf.zsh ]; then
    printf " * Installing FZF keybindings\n"
    yes | "$(brew --prefix)"/opt/fzf/install
  fi

  printf " * Linking one dark theme for VIM\n"
  mkdir -p "${HOME}/.vim/colors" && mkdir -p "${HOME}/.vim/autoload"
  ln -sf "${DOTFILES_PATH}/colors/colors/onedark.vim" "${HOME}/.vim/colors/onedark.vim"
  ln -sf "${DOTFILES_PATH}/colors/autoload/onedark.vim" "${HOME}/.vim/autoload/onedark.vim"

  printf " * Configuring OS X\n"
  source "${DOTFILES_PATH}/files/.macos"

  printf " * Configuring iTerm\n"
  defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "${DOTFILES_PATH}/iterm2"
  defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

  printf " * Configuring dock\n"
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
  dockutil --no-restart --add "/Applications/iTerm.app"
  dockutil --no-restart --add "/Applications/1Password 7.app"
  dockutil --no-restart --add "/Applications/Spotify.app"

  printf "Done. Note that some of these changes require a logout/restart to take effect.\n"
}

install
