{ config, pkgs, ... }: {
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  services.nix-daemon.enable = true;

  users.users.dalmo = {
    shell = pkgs.fish;
    home = "/Users/dalmo";
  };

  programs.zsh = {
    enable = true;
  };

  programs.fish = {
    enable = true;
  };

  system.stateVersion = 4;
}
