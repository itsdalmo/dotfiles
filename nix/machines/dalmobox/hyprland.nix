{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  webApp =
    {
      name,
      url,
      icon,
      genericName,
      categories ? [ "Network" ],
    }:
    ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=${name}
      GenericName=${genericName}
      Comment=Open ${name} as a desktop application
      Exec=uwsm app -- brave --app=${url}
      Icon=${icon}
      Terminal=false
      StartupNotify=true
      Categories=${lib.concatStringsSep ";" categories};
    '';

  hyprlandConfig = pkgs.runCommand "hyprland-config" { } ''
    mkdir -p "$out"
    cp ${./hyprland/hyprland.lua} "$out/hyprland.lua"
    cp ${./hyprland/config.lua} "$out/config.lua"
    cp ${./hyprland/monitors.lua} "$out/monitors.lua"
    cp ${./hyprland/bindings.lua} "$out/bindings.lua"

    export HOME="$TMPDIR/home"
    export XDG_CONFIG_HOME="$out"
    export XDG_RUNTIME_DIR="$TMPDIR/runtime"
    export XDG_STATE_HOME="$TMPDIR/state"
    mkdir -p "$HOME" "$XDG_RUNTIME_DIR" "$XDG_STATE_HOME"

    ${pkgs.hyprland}/bin/Hyprland --config "$out/hyprland.lua" --verify-config
  '';

  wallpaper = builtins.path {
    name = "noctalia-wallpaper.png";
    path = inputs.noctalia + "/assets/noctalia-wallpaper.png";
  };

  cycleMonitorScale = pkgs.writeShellApplication {
    name = "cycle-monitor-scale";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      hyprland
      jq
      libnotify
    ];
    text = ''
      monitor_info=$(hyprctl monitors -j | jq -e -c '.[] | select(.focused == true)')

      active_monitor=$(printf '%s' "$monitor_info" | jq -r '.name')
      description=$(printf '%s' "$monitor_info" | jq -r '.description')
      current_scale=$(printf '%s' "$monitor_info" | jq -r '.scale')
      width=$(printf '%s' "$monitor_info" | jq -r '.width')
      height=$(printf '%s' "$monitor_info" | jq -r '.height')
      refresh_rate=$(printf '%s' "$monitor_info" | jq -r '.refreshRate')

      if [ -z "$description" ] || [ "$description" = "null" ]; then
        notify-send "Display scaling unavailable" "The focused monitor has no physical description"
        exit 1
      fi

      scales=(1 1.25 1.6 2 3 4)
      current_index=$(awk -v scale="$current_scale" -v scales="''${scales[*]}" '
        BEGIN {
          count = split(scales, values, " ")
          closest = 1
          smallest_difference = 1000

          for (position = 1; position <= count; position++) {
            difference = scale - values[position]
            if (difference < 0) difference = -difference
            if (difference < smallest_difference) {
              closest = position
              smallest_difference = difference
            }
          }

          print closest - 1
        }
      ')

      if [ "''${1:-}" = "--reverse" ]; then
        new_index=$(( (current_index - 1 + ''${#scales[@]}) % ''${#scales[@]} ))
      else
        new_index=$(( (current_index + 1) % ''${#scales[@]} ))
      fi

      requested_scale="''${scales[$new_index]}"
      # Hyprland scales must produce whole logical pixels. Round the selected
      # preset up to the nearest valid 1/120 increment for this monitor mode.
      new_scale=$(awk -v scale="$requested_scale" -v width="$width" -v height="$height" '
        function gcd(left, right, remainder) {
          while (right) {
            remainder = left % right
            left = right
            right = remainder
          }
          return left
        }
        BEGIN {
          common = gcd(width * 120, height * 120)
          increment = int(scale * 120 + 0.5)
          if (increment > common) increment = common
          while (common % increment != 0) increment++
          printf "%g\n", increment / 120
        }
      ')

      mode="''${width}x''${height}@''${refresh_rate}"
      hyprctl eval "hl.monitor({ output = \"$active_monitor\", mode = \"$mode\", position = \"auto\", scale = $new_scale })"

      # Persist by EDID description rather than connector. DP-1/DP-2 names can
      # change after hotplug, while the physical monitor identity remains stable.
      state_directory="''${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
      state_file="$state_directory/monitor-scales.tsv"
      mkdir -p "$state_directory"
      touch "$state_file"

      temporary_file=$(mktemp "$state_directory/.monitor-scales.XXXXXX")
      awk -F '\t' -v description="$description" -v scale="$new_scale" '
        $1 == description {
          printf "%s\t%s\n", description, scale
          found = 1
          next
        }
        { print }
        END {
          if (!found) printf "%s\t%s\n", description, scale
        }
      ' "$state_file" > "$temporary_file"
      mv "$temporary_file" "$state_file"

      notify-send "Display scaling set to ''${new_scale}x" "$active_monitor"
    '';
  };
in
{
  home.activation.initializeHyprMonitorScales = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    state_directory=${lib.escapeShellArg "${config.xdg.stateHome}/hypr"}
    state_file="$state_directory/monitor-scales.tsv"

    $DRY_RUN_CMD mkdir -p "$state_directory"
    if [ ! -e "$state_file" ]; then
      $DRY_RUN_CMD touch "$state_file"
    fi
  '';

  home.packages = with pkgs; [
    btop
    cycleMonitorScale
    evince
    imv
    playerctl
  ];

  # UWSM creates this compositor-specific target. Using it rather than the
  # generic graphical-session.target keeps Noctalia tied to Hyprland.
  wayland.systemd.target = "wayland-session@Hyprland.target";

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    package = null;
    portalPackage = null;

    # UWSM owns the graphical session and its systemd targets.
    systemd.enable = false;
    extraConfig = builtins.readFile ./hyprland/hyprland.lua;
  };

  xdg.configFile = {
    # GTK only supports integer application scaling. Keep this scoped to the
    # UWSM-managed Hyprland session rather than every graphical environment.
    "uwsm/env-hyprland".text = ''
      export GDK_SCALE=2
    '';

    # Sourcing these files from the validated derivation makes the validation
    # a dependency of the Home Manager generation.
    "hypr/config.lua".source = "${hyprlandConfig}/config.lua";
    "hypr/monitors.lua".source = "${hyprlandConfig}/monitors.lua";
    "hypr/bindings.lua".source = "${hyprlandConfig}/bindings.lua";
  };

  xdg.dataFile."applications/gmail.desktop".text = webApp {
    name = "Gmail";
    genericName = "Email Client";
    url = "https://mail.google.com/";
    icon = "${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/apps/gmail.svg";
    categories = [
      "Network"
      "Email"
    ];
  };

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    validateConfig = true;
    settings = {
      shell = {
        font_family = "JetBrainsMono Nerd Font";
        telemetry_enabled = false;
        setup_wizard_enabled = false;
        polkit_agent = true;
        launch_apps_as_systemd_services = true;

        # Do not preserve secrets copied from applications that deliberately
        # release the clipboard (notably password managers).
        clipboard_keep_from_closed_apps = false;

        launcher.fetch_exchange_rates = false;
        screenshot = {
          save_to_file = true;
          copy_to_clipboard = true;
          freeze_screen = true;
        };

        session.actions = [
          {
            action = "lock";
            enabled = true;
          }
          {
            action = "logout";
            command = "uwsm stop";
            enabled = true;
          }
          {
            action = "reboot";
            countdown_seconds = 5;
            enabled = true;
          }
          {
            action = "shutdown";
            countdown_seconds = 5;
            enabled = true;
          }
        ];
      };

      wallpaper = {
        enabled = true;
        fill_mode = "crop";
        default.path = wallpaper;
      };

      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Tokyo-Night";
        templates.enable_community_templates = false;
      };

      notification.enable_daemon = true;

      lockscreen = {
        enabled = true;
        fingerprint = false;
        allow_empty_password = false;
        blurred_desktop = false;
        wallpaper = wallpaper;
      };

      brightness = {
        enable_ddcutil = true;
        minimum_brightness = 0.01;
      };

      nightlight = {
        enabled = true;
        temperature_day = 6000;
        temperature_night = 4000;
      };
      location = {
        custom_schedule = true;
        sunrise = "07:00";
        sunset = "21:00";
      };

      idle.behavior = {
        lock = {
          timeout = 300;
          action = "lock";
          enabled = true;
        };
        "screen-off" = {
          timeout = 600;
          action = "screen_off";
          enabled = true;
        };
      };

      weather.enabled = false;
      plugins = {
        enabled = [ ];
        auto_update = false;
      };

      bar.main = {
        position = "top";
        thickness = 34;
        margin_ends = 10;
        margin_edge = 8;
        start = [
          "launcher"
          "workspaces"
        ];
        center = [ "clock" ];
        end = [
          "media"
          "tray"
          "notifications"
          "clipboard"
          "network"
          "bluetooth"
          "volume"
          "brightness"
          "control-center"
          "session"
        ];
      };
    };
  };

  services.udiskie = {
    enable = true;
    notify = false;
    tray = "never";
  };

  programs.mpv = {
    enable = true;
    scripts = [ pkgs.mpvScripts.mpris ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];

      "application/pdf" = [ "org.gnome.Evince.desktop" ];

      "image/bmp" = [ "imv.desktop" ];
      "image/gif" = [ "imv.desktop" ];
      "image/jpeg" = [ "imv.desktop" ];
      "image/png" = [ "imv.desktop" ];
      "image/tiff" = [ "imv.desktop" ];
      "image/webp" = [ "imv.desktop" ];

      "application/ogg" = [ "mpv.desktop" ];
      "video/3gpp" = [ "mpv.desktop" ];
      "video/3gpp2" = [ "mpv.desktop" ];
      "video/mp4" = [ "mpv.desktop" ];
      "video/mpeg" = [ "mpv.desktop" ];
      "video/ogg" = [ "mpv.desktop" ];
      "video/quicktime" = [ "mpv.desktop" ];
      "video/webm" = [ "mpv.desktop" ];
      "video/x-flv" = [ "mpv.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];
      "video/x-ms-asf" = [ "mpv.desktop" ];
      "video/x-ms-wmv" = [ "mpv.desktop" ];
      "video/x-msvideo" = [ "mpv.desktop" ];
      "video/x-ogm+ogg" = [ "mpv.desktop" ];
      "video/x-theora+ogg" = [ "mpv.desktop" ];

      "application/gzip" = [ "org.gnome.FileRoller.desktop" ];
      "application/vnd.rar" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-7z-compressed" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-bzip2" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-rar" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-tar" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-xz" = [ "org.gnome.FileRoller.desktop" ];
      "application/zip" = [ "org.gnome.FileRoller.desktop" ];
    };
  };
}
