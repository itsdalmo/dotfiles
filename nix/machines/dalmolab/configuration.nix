{
  config,
  lib,
  pkgs,
  ...
}:
let
  hostName = "dalmolab";
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

  nix.buildMachines = [
    {
      hostName = "dalmobox.wombat-woodpecker.ts.net";
      sshKey = "/root/.ssh/id_nixremote";
      sshUser = "nixremote";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUxEN2lBeWwyVE1Ld2ZUcEZFcU4yeS9zQ2lGWmUrSDZDWWJuaThVa2NwRSsgcm9vdEBkYWxtb2JveAo=";
      maxJobs = 4;
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
      ];
      supportedFeatures = [ "kvm" ];
    }
  ];
  nix.distributedBuilds = true;
  nix.settings.max-jobs = 0; # Force all builds to use remote builders

  # Create a group which will have read access to the k3s config
  users.groups.k3s = { };

  users.users."${user}" = {
    home = "/home/${user}";
    shell = pkgs.zsh;
    initialPassword = "";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "k3s"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBSRWGrBG1gY2Sz8CdPqnqKiJJXqpG1+RgJ5cHXZluIU"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPzEKT/ZL+7hKaS/7wvH2UKuTUJVeX4FMUc6jMx5UfN52UukTBrRkkk3yJkM8Bw90T5CW1pNifFvjCkXQY0Zr8A=" # dalmophone17 (Termius)
    ];
  };

  environment.systemPackages = with pkgs; [
    ghostty
  ];

  networking.hostName = hostName;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable aarch64-linux emulation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.binfmt.addEmulatedSystemsToNixSandbox = true;

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Install tailscale
  services.tailscale.enable = true;

  # Homebridge and the Salus HomeKit bridge run in Docker Compose (itsdalmo/apps,
  # homebridge/ and salus/) with host networking, so they can advertise
  # themselves over mDNS on the LAN. Homebridge's UI is reached through Traefik
  # (homebridge.app.dalmo.me), so 8581 stays closed.
  networking.firewall = {
    allowedTCPPorts = [
      51000 # Homebridge
      51827 # Salus HomeKit bridge
    ];
    allowedUDPPorts = [
      5353 # Homebridge bonjour
    ];
  };

  # Web apps (itsdalmo/apps) run with Docker Compose. Traefik uses host networking,
  # so this decides where they are reachable: only over Tailscale.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    80
    443
  ];

  # Automatic system updates at 5 AM
  system.autoUpgrade = {
    enable = true;
    flake = "github:itsdalmo/dotfiles#dalmolab";
    dates = "06:00";
    operation = "boot";
    allowReboot = true;
  };
}
