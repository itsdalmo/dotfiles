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

  mkdir -p "$(dirname $SSH_KEY)"
  if [ ! -f "${SSH_KEY}" ]; then
    printf " * Generating SSH key\n"
    ssh-keygen -t rsa -b 4096 -C "kristian@doingit.no" -f "${SSH_KEY}"
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

  printf " * Linking files\n"
  local dotfiles=(".Brewfile" ".gitconfig" ".vimrc" ".zprofile" ".zshrc" ".gnupg/gpg.conf" ".gnupg/gpg-agent.conf")
  for file in "${dotfiles[@]}"; do
    ln -sf "${DOTFILES_PATH}/files/${file}" "${HOME}/${file}"
  done

  printf " * Installing brew bundle\n"
  brew bundle --global | sed 's/^/    ~ /' 

  if ! env | grep -q ZSH; then
    printf " * Installing oh my ZSH\n"
    /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  if [[ $(command -v "fzf") ]] && [ ! -f ~/.fzf.zsh ]; then
    printf " * Installing FZF keybindings\n"
    yes | "$(brew --prefix)"/opt/fzf/install
  fi

  printf " * Linking solarized theme for VIM\n"
  mkdir -p "${HOME}/.vim/colors"
  ln -sf "${DOTFILES_PATH}/colors/colors/solarized.vim" "${HOME}/.vim/colors/solarized.vim"

  printf " * Copying fonts\n"
  "${DOTFILES_PATH}/fonts/install.sh" "Meslo LG M Regular for Powerline" > /dev/null

  printf " * Configuring OS X\n"
  source "${DOTFILES_PATH}/files/.macos"

  printf " * Configuring iTerm\n"
  defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "${DOTFILES_PATH}/iterm2"
  defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

  printf " * Configuring dock\n"
  dockutil --no-restart --remove all --allhomes
  dockutil --no-restart --add "/Applications/Google Chrome.app"
  dockutil --no-restart --add "/System/Applications/Mail.app"
  dockutil --no-restart --add "/System/Applications/Calendar.app"
  dockutil --no-restart --add "/System/Applications/Messages.app"
  dockutil --no-restart --add "/System/Applications/Photos.app"
  dockutil --no-restart --add "/Applications/Discord.app"
  dockutil --no-restart --add "/Applications/Slack.app"
  dockutil --no-restart --add "/Applications/Visual Studio Code.app"
  dockutil --no-restart --add "/Applications/iTerm.app"
  dockutil --no-restart --add "/Applications/1Password 7.app"
  dockutil --no-restart --add "/Applications/Spotify.app"

  printf "Done. Note that some of these changes require a logout/restart to take effect.\n"
}

install
