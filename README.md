# dotfiles

My setup for development on OS X (and remote development on Linux).

## Installation

Run the installer (restart until it completes) and then reboot:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/itsdalmo/dotfiles/home-manager/install.sh)"
```

After rebooting, complete the following manual steps:

- System settings:
  - `Sharing > Computer name`.
  - `Security & Privacy > Firewall > Turn on Firewall`
  - `Security & Privacy > General > Require password immediately after sleep or screen saver begins`
  - `Displays > Night Shift > Schedule: Sunset to Sunrise`
  - `Sound > Show volume in menu bar`
  - `Bluetooth > Show Bluetooth in menu bar`
  - Enable "stacks" on the desktop.
- Open and configure `cinch`/`sensiblesidebuttons` to start on boot.
- Transfer `.aws/config` and add new credentials with `aws-vault add <jump-profile-name>`.

## Installation (w/nix)

### Debian 11

```sh
# Install curl and git (required to install nix, and for flakes to work)
$ sudo apt install curl

# Install nix (using determinate systems installer)
# https://github.com/DeterminateSystems/nix-installer
$ curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Create required folder for home-manager (nix-installer does not create it).
mkdir -p ~/.local/state/nix/profiles

# Install dotfiles (might need to add a `--refresh` if it fails)
$ nix run github:nix-community/home-manager/release-23.05 -- switch --flake github:itsdalmo/dotfiles/home-manager#parallels@arm64-linux

# Install wezterm (only works on x86_64)
$ curl -LO https://github.com/wez/wezterm/releases/download/20230712-072601-f4abf8fd/wezterm-20230712-072601-f4abf8fd.Debian11.deb
$ echo "b2d68f0ac4a66a6f8a2f2b7dfb64cd5ff9f92d429a9b62e4c3ab501fd20d444b  wezterm-20230712-072601-f4abf8fd.Debian11.deb" | sha256sum --check
```

### Fedora 38

```sh
# Install nix (using determinate systems installer)
# https://github.com/DeterminateSystems/nix-installer
$ curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Create required folder for home-manager (nix-installer does not create it).
mkdir -p ~/.local/state/nix/profiles

# Install dotfiles (might need to add a `--refresh` if it fails)
$ nix run github:nix-community/home-manager/release-23.05 -- switch --flake github:itsdalmo/dotfiles/home-manager#parallels@arm64-linux

# Update system packages
$ sudo dnf distro-sync

# Install Jetbrains Mono and Nerdfont symbols
$ sudo dnf install jetbrains-mono-fonts-all
$ curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/NerdFontsSymbolsOnly.zip -o /tmp/SymbolsOnlyNerdFont.zip
$ sudo unzip /tmp/SymbolsOnlyNerdFont.zip -d /usr/share/fonts/SymbolsOnlyNerdFont

# Refresh fonts
$ fc-cache -f -v

# Install alacritty (wezterm does not build for linux on ARM)
$ sudo dnf install alacritty

# Install goland (`Configure | Create Desktop Entry` after installing)
# https://www.jetbrains.com/help/go/installation-guide.html#standalone
$ cd /tmp
$ curl -fsSLO https://download.jetbrains.com/go/goland-2023.1.4-aarch64.tar.gz
$ echo "0d54491055d2ea3f45ae16a0d8144c42544d678e04d892ba40b5e3f7da4da9fb *goland-2023.1.4-aarch64.tar.gz" | sha256sum --check
$ sudo tar xzf goland-*.tar.gz -C /opt/
```

## Notes

1. Seems like `nixConfigurations` is only used by nixos-rebuild, and that `darwinConfigurations` is the way to get similar functionality on Mac. However, there is no equivalent for other linux distros.
2. `outputs.packages` is only used to build derivations.
3. `home-manager` is the only cross platform way to use nix for configuring the system, and its limited to a single user.
