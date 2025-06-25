{ config, lib, pkgs, ... }:
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
        image = "docker.io/homebridge/homebridge:2024-11-29";
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

