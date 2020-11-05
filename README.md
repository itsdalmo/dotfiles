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
  - `Sound > Show volume in menu bar`
  - `Bluetooth > Show Bluetooth in menu bar`
  - Enable "stacks" on the desktop.
  - Show battery percentage.
  - Hide input menu.
- Open and configure `cinch` to start on boot.
- Open VS Code, install [Settings Sync](https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync) and configure it with personal access token (with `gist` scope) to sync.
- Transfer `.aws/config` and add new credentials with `aws-vault add <jump-profile-name>`.
- Finish setting up GPG as described [here](https://withblue.ink/2020/05/17/how-and-why-to-sign-git-commits.html).
