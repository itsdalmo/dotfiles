# dotfiles

My setup for development on OS X.

## Installation

Run the installer (restart until it completes) and then reboot:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/itsdalmo/dotfiles/master/install.sh)"
```

After rebooting, complete the following manual steps:
- System settings:
  - `Sharing > Computer name`.
  - `Security & Privacy > Firewall > Turn on Firewall`
  - `Security & Privacy > General > Require password immediately after sleep or screen saver begins`
  - `Displays > Night Shift > Schedule: Sunset to Sunrise`
  - Enable "stacks" on the desktop.
  - Show battery percentage.
- Open and configure `cinch` to start on boot.
- Open VS Code, install [Settings Sync](https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync) and configure it with personal access token (with `gist` scope) to sync.
