# dotfiles

My setup for development on OS X (and remote development on Linux).

## Installation

Run the installer (restart until it completes) and then reboot:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/itsdalmo/dotfiles/master/install.sh)"
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
