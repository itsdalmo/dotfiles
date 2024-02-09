{ config, pkgs, ... }:

{
  nix = {
    settings = {
      allowed-users = [ "@wheel" ];
      keep-derivations = true;
      keep-outputs = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  fonts = {
    fontDir.enable = true;

    fonts = with pkgs; [
      jetbrains-mono
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    ];
  };

  users = {
    users.dalmo = {
      shell = pkgs.fish;
      home = "/Users/dalmo";
      # openssh.authorizedKeys.keys = [];
    };
  };

  environment.systemPackages = with pkgs; [
    _1password-gui
    alacritty
    curl
    firefox
    git
    jetbrains.goland
    unzip
    vim
    vscode
    wezterm
  ];

  programs.zsh = {
    enable = true;
  };

  programs.fish = {
    enable = true;
  };

  system.stateVersion = 4;
}
