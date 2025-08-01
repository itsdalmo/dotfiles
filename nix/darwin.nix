{ config, pkgs, ... }:

{
  # manage nix (and the nix daemon)
  nix.enable = true;

  # nix-daemon should trust the admin users
  nix.settings.trusted-users = [ "root" "@admin" ];

  # Easier sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  homebrew = {
    enable = true;

    global = {
      brewfile = true;
      autoUpdate = false;
    };

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    casks = [
      "1password"
      "1password-cli"
      "brave-browser"
      "docker-desktop"
      "firefox"
      "ghostty"
      "jetbrains-toolbox"
      "numi"
      "obsidian"
      "postman"
      "raycast"
      "sensiblesidebuttons"
      "slack"
      "spotify"
      "tailscale-app"
      "visual-studio-code"
      "wezterm"
    ];
  };

  # Add fish to /etc/shells
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;

      # Disable things that interfer with typing
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;

      # Expand save and print panels by default
      NSNavPanelExpandedStateForSaveMode = true;
      PMPrintingExpandedStateForPrint = true;
    };

    finder = {
      FXPreferredViewStyle = "clmv";
      NewWindowTarget = "Home";
    };

    dock = {
      autohide = false;
      mru-spaces = false;
      show-recents = false;
      tilesize = 44;
      wvous-br-corner = 5;
    };

    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 0;
    };
  };

  # Misc
  networking.applicationFirewall.enable = true;
  system.defaults.controlcenter.Sound = true;
  system.defaults.".GlobalPreferences"."com.apple.mouse.scaling" = -1.0;
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;
  system.defaults.screencapture.location = "/Users/dalmo/Desktop/screenshots";

  # Dock items
  system.defaults.dock.persistent-apps = [
    "/Applications/Brave Browser.app"
    "/Applications/Slack.app"
    "/Applications/WezTerm.app"
    "/Applications/Obsidian.app"
    "/Applications/1Password.app"
    "/Applications/Spotify.app"
  ];

  # TODO: Need this?
  # programs.gnupg.agent.enable
  # services.aerospace.package

  system.stateVersion = 5;
}
