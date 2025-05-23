{ config, lib, pkgs, ... }:
let
  hostName = "macos-vm";
  user = "dalmo";
in
{
  imports = [
    ../../nix.nix
    ../../darwin.nix
    ./hardware-configuration.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${user}" = import ../../home.nix;
    extraSpecialArgs = { user = user; };
  };

  users.users."${user}" = {
    shell = pkgs.fish;

    # nix-darwin requires these to be set even if the user already exists
    uid = 501;
    home = "/Users/${user}";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBSRWGrBG1gY2Sz8CdPqnqKiJJXqpG1+RgJ5cHXZluIU"
    ];
  };

  # nix-darwin will not touch the user unless its specified here
  users.knownUsers = [ user ];

  networking = {
    hostName = hostName;
    computerName = hostName;
    localHostName = hostName;
  };

  # No mac apps since we are not logged in
  homebrew.masApps = { };
}
