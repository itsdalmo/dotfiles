# dotfiles

Ansible playbook for setting up my dev environment on Mac OS X (heavily inspired by https://github.com/geerlingguy/mac-dev-playbook).

## Prerequisities

1. `xcode-select --install`
2. `pip install ansible` (might have to `sudo easy_install pip` first)
3. `ansible-galaxy install geerlingguy.homebrew`

## Install

`ansible-playbook main.yml -i inventory -K`

## Manual steps

1. Change font/theme in iTerm.
2. Install Cinch from app store.
