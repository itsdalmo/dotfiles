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
      sshUser = "nix-ssh";
      protocol = "ssh-ng";
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
  nix.settings.builders-use-substitutes = true;
  nix.settings.max-jobs = 0; # Force all builds to use remote builders

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
    openssh.authorizedKeys = {
      keyFiles = [ ../../../files/.ssh/authorized_keys ];
      keys = [
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPzEKT/ZL+7hKaS/7wvH2UKuTUJVeX4FMUc6jMx5UfN52UukTBrRkkk3yJkM8Bw90T5CW1pNifFvjCkXQY0Zr8A=" # dalmophone17 (Termius)
      ];
    };
  };

  networking.hostName = hostName;

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

  # The Salus HomeKit bridge runs in Docker Compose (itsdalmo/apps, salus/) with
  # host networking, so it can advertise itself over mDNS on the LAN. Only open
  # on the LAN, where Apple Home connects.
  networking.firewall.interfaces.enp1s0 = {
    allowedTCPPorts = [
      51827 # HomeKit
    ];
    allowedUDPPorts = [
      5353 # mDNS
    ];
  };

  # Web apps (itsdalmo/apps) run with Docker Compose. Traefik uses host networking,
  # so this decides where they are reachable: only over Tailscale.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    80
    443
  ];

  # The OpenTelemetry Collector (itsdalmo/apps, observability/) uses host
  # networking and receives OTLP/HTTP on the gateway of the apps-telemetry
  # bridge, so only containers on that network can send telemetry.
  networking.firewall.interfaces.br-otel.allowedTCPPorts = [ 4318 ];

  # The Collector reads the containers' logs from Docker's JSON files (the
  # NixOS default is journald). Existing containers keep their driver until
  # they are recreated.
  virtualisation.docker.logDriver = "json-file";
  virtualisation.docker.daemon.settings.log-opts = {
    max-size = "10m";
    max-file = "3";
  };
  # Prune dangling images left behind by deploys without touching volumes or
  # recently stopped containers.
  virtualisation.docker.autoPrune = {
    enable = true;
    flags = [ "--filter=until=168h" ];
  };

  # Automatic system updates at 6 AM
  system.autoUpgrade = {
    enable = true;
    flake = "github:itsdalmo/dotfiles#dalmolab";
    dates = "06:00";
    operation = "boot";
    allowReboot = true;
  };
}
