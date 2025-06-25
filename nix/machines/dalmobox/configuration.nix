{ config, lib, pkgs, ... }:
let
  hostName = "dalmobox";
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
    extraSpecialArgs = { user = user; };
  };

  users.users."${user}" = {
    home = "/home/${user}";
    shell = pkgs.fish;
    initialPassword = "";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBSRWGrBG1gY2Sz8CdPqnqKiJJXqpG1+RgJ5cHXZluIU"
    ];
  };

  users.users.nixremote = {
    home = "/home/nixremote";
    group = "nogroup";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIpzKUQYSMv5mPaSrGHZQm7ULswMe/li7osfQjAPSNMJ"
    ];
  };
  nix.settings.trusted-users = lib.mkAfter [ "nixremote" ];


  environment.systemPackages = with pkgs; [
    _1password-cli
    _1password-gui
    brave
    discord
    firefox
    protonup
    signal-desktop
    slack
    spotify
  ];

  networking.hostName = hostName;

  # Prevent suspend and hibernation
  # https://www.freedesktop.org/software/systemd/man/latest/sleep.conf.d.html
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
  '';

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable aarch64-linux emulation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.binfmt.addEmulatedSystemsToNixSandbox = true;

  # Enable hardware graphics
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    nvidiaSettings = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Steam and game mode
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  programs.steam = {
    enable = true;

    gamescopeSession = {
      enable = true;
    };
  };


  services.libinput.mouse.accelProfile = "flat";
  services.libinput.mouse.accelSpeed = "-0.60";

  # Install tailscale
  services.tailscale.enable = true;

  # Run homebridge in a container
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      homebridge = {
        image = "docker.io/homebridge/homebridge:2025-06-10";
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

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      # "--debug" # Optionally add additional args to k3s
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [
      6443 # k3s API server
      8581 # Homebridge UI
      51000 # Homebridge
      31348 # Grafana
    ];
    allowedUDPPorts = [
      5353 # Homebridge bonjour
    ];
  };
}

