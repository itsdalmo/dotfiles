{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  hostName = "dalmobox";
  startHyprland = pkgs.writeShellScript "start-hyprland" ''
    exec ${pkgs.uwsm}/bin/uwsm start hyprland.desktop
  '';
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
    users."${user}" = {
      imports = [
        ../../home.nix
        ./hyprland.nix
      ];
    };
    extraSpecialArgs = {
      inherit inputs;
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
  };

  users.users.nixremote = {
    home = "/home/nixremote";
    group = "nogroup";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzoYhB8nTLlVgNljnBLdfrZtR+srK95wDeSmm3ix5BP" # dalmobook
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbwlUPZF+2rANW8NjYRgRm9lA4kZmKwJjE1cGtBR+hG" # dalmolab
    ];
  };
  nix.settings.trusted-users = lib.mkAfter [ "nixremote" ];

  environment.systemPackages = with pkgs; [
    _1password-cli
    _1password-gui
    (brave.override {
      commandLineArgs = "--password-store=gnome-libsecret";
    })
    ddcutil
    discord
    file-roller
    firefox
    ghostty
    libsecret
    nautilus
    # Broken on nixos:
    # wezterm
    protonup-ng
    signal-desktop
    slack
    spotify
    wl-clipboard
    zed-editor
  ];

  networking.hostName = hostName;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  programs.noctalia = {
    enable = true;
    package = null;
    recommendedServices.enable = true;
  };
  programs.gnome-disks.enable = true;

  xdg.portal.config.hyprland = {
    default = [
      "hyprland"
      "gtk"
    ];
    "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  };

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session.command = lib.concatStringsSep " " [
      "${pkgs.tuigreet}/bin/tuigreet"
      "--time"
      "--remember"
      "--remember-session"
      "--sessions /run/current-system/sw/share/wayland-sessions"
      "--cmd ${startHyprland}"
    ];
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;
  services.gnome.sushi.enable = true;

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
  # https://wiki.nixos.org/wiki/Power_Management
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
  };

  # Prevent USB devices from being suspended (and interfering with wake from sleep)
  boot.kernelParams = [ "usbcore.autosuspend=-1" ];

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

  # Allow DDC/CI tools to control external monitor settings such as brightness.
  hardware.i2c.enable = true;

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

  # Automatic system updates at 4 AM
  system.autoUpgrade = {
    enable = true;
    flake = "github:itsdalmo/dotfiles#dalmobox";
    dates = "05:00";
    operation = "boot";
    allowReboot = true;
  };
}
