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
    ];
  };

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

  # Run homebridge in a container
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      homebridge = {
        image = "docker.io/homebridge/homebridge:2026-04-20@sha256:79c95b078973b187d8985385f012b477320c57dc49911f70746eb72ea8d39eed";
        volumes = [
          "/var/lib/homebridge:/homebridge:rw"
        ];
        log-driver = "journald";
        extraOptions = [
          "--network=host"
        ];
        autoStart = true;
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      8581 # Homebridge UI
      51000 # Homebridge
    ];
    allowedUDPPorts = [
      5353 # Homebridge bonjour
    ];
  };

  # Automatic system updates at 5 AM
  system.autoUpgrade = {
    enable = true;
    flake = "github:itsdalmo/dotfiles#dalmolab";
    dates = "06:00";
    operation = "boot";
    allowReboot = true;
  };
}
