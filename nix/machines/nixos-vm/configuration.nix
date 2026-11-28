{
  config,
  lib,
  pkgs,
  ...
}:
let
  hostName = "nixos-vm";
  user = "dalmo";
in
{
  imports = [
    ../../nix.nix
    ../../nixos.nix
    ./hardware-configuration.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${user}" = import ../../home.nix;
    extraSpecialArgs = {
      user = user;
    };
  };

  users.users."${user}" = {
    home = "/home/${user}";
    shell = pkgs.zsh;
    initialPassword = "";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    openssh.authorizedKeys.keyFiles = [ ../../../files/.ssh/authorized_keys ];
  };

  networking.hostName = hostName;

  # Allow automated rebuilds over SSH without a password prompt.
  security.sudo.wheelNeedsPassword = false;
}
