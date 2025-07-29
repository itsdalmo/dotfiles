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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIpzKUQYSMv5mPaSrGHZQm7ULswMe/li7osfQjAPSNMJ" # dalmobook
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbwlUPZF+2rANW8NjYRgRm9lA4kZmKwJjE1cGtBR+hG" # dalmolab
    ];
  };
  nix.settings.trusted-users = lib.mkAfter [ "nixremote" ];


  environment.systemPackages = with pkgs; [
    _1password-cli
    _1password-gui
    brave
    discord
    firefox
    ghostty
    # Broken on nixos:
    # wezterm
    protonup
    signal-desktop
    slack
    spotify
    wl-clipboard
  ];

  networking.hostName = hostName;

  # Enable DHCP on our network interfaces
  networking.interfaces.enp4s0.useDHCP = true;
  networking.interfaces.wlo1.useDHCP = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

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
}

