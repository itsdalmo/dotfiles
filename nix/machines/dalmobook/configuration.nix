{ config, lib, pkgs, ... }:
let
  hostName = "dalmobook";
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

  nix.buildMachines = [{
    hostName = "dalmobox";
    sshKey = "/var/root/.ssh/id_nixremote";
    sshUser = "nixremote";
    publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUxEN2lBeWwyVE1Ld2ZUcEZFcU4yeS9zQ2lGWmUrSDZDWWJuaThVa2NwRSsgcm9vdEBkYWxtb2JveAo=";
    maxJobs = 4;
    systems = [ "aarch64-linux" "x86_64-linux" ];
    supportedFeatures = [ "kvm" ];
  }];
  nix.distributedBuilds = true;


  system.primaryUser = user;

  users.users."${user}" = {
    shell = pkgs.fish;

    # nix-darwin requires these to be set even if the user already exists
    uid = 501;
    home = "/Users/${user}";
  };

  # nix-darwin will not touch the user unless its specified here
  users.knownUsers = [ user ];

  networking = {
    hostName = hostName;
    computerName = hostName;
    localHostName = hostName;
  };

  homebrew.masApps = {
    "1Password for Safari" = 1569813296;
    "AdGuard for Safari" = 1440147259;
    "Azure VPN Client" = 1553936137;
  };
}
