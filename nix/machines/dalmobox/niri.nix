{
  config,
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
      Exec=brave --app=${url}
      Icon=${icon}
      Terminal=false
      StartupNotify=true
      Categories=${lib.concatStringsSep ";" categories};
    '';

  niriConfig = pkgs.runCommand "niri-config.kdl" { } ''
    ${lib.getExe pkgs.niri} validate --config ${./niri/config.kdl}
    cp ${./niri/config.kdl} "$out"
  '';

  wallpaper = pkgs.fetchurl {
    url = "https://w.wallhaven.cc/full/jx/wallhaven-jxjm1m.png";
    hash = "sha256-RjWKdXzuAly3+DnXR0PudRfSaE4XqrBEe2dfbPSQQ8s=";
  };

  cycleMonitorScale = pkgs.writeShellApplication {
    name = "cycle-monitor-scale";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      jq
      libnotify
      niri
    ];
    text = ''
      monitor_info=$(niri msg --json focused-output | jq -e -c '.')

      active_monitor=$(printf '%s' "$monitor_info" | jq -r '.name')
      identifier=$(printf '%s' "$monitor_info" | jq -r '
        if .make == "Unknown" and .model == "Unknown" and .serial == null then
          .name
        else
          [.make, .model, (.serial // "Unknown")] | join(" ")
        end
      ')
      current_scale=$(printf '%s' "$monitor_info" | jq -r '.logical.scale')

      if [ -z "$identifier" ] || [ "$identifier" = "null" ]; then
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

      new_scale="''${scales[$new_index]}"
      niri msg output "$identifier" scale "$new_scale"

      # Persist by EDID identity rather than connector. DP-1/DP-2 names can
      # change after hotplug, while the physical monitor identity remains stable.
      state_directory="''${XDG_STATE_HOME:-$HOME/.local/state}/niri"
      state_file="$state_directory/monitor-scales.tsv"
      mkdir -p "$state_directory"
      touch "$state_file"

      temporary_file=$(mktemp "$state_directory/.monitor-scales.XXXXXX")
      awk -F '\t' -v identifier="$identifier" -v scale="$new_scale" '
        $1 == identifier {
          printf "%s\t%s\n", identifier, scale
          found = 1
          next
        }
        { print }
        END {
          if (!found) printf "%s\t%s\n", identifier, scale
        }
      ' "$state_file" > "$temporary_file"
      mv "$temporary_file" "$state_file"

      notify-send "Display scaling set to ''${new_scale}x" "$active_monitor"
    '';
  };

  applyNiriMonitorConfig = pkgs.writeShellApplication {
    name = "apply-niri-monitor-config";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      jq
      niri
    ];
    text = ''
      state_file="''${XDG_STATE_HOME:-$HOME/.local/state}/niri/monitor-scales.tsv"

      # Register saved physical-display scales with Niri. This also covers
      # displays which are disconnected now and connected later in the session.
      while IFS=$'\t' read -r identifier scale; do
        if [ -n "$identifier" ] && [ -n "$scale" ]; then
          niri msg output "$identifier" scale "$scale"
        fi
      done < "$state_file"

      outputs=$(niri msg --json outputs)
      while IFS=$'\t' read -r identifier model current_width current_height current_scale; do
        if [ "$model" != "M28U" ]; then
          continue
        fi

        # Keep the M28U on its highest-refresh 4K mode. Omitting the refresh
        # makes Niri select the highest one advertised at this resolution.
        if [ "$current_width" != "3840" ] || [ "$current_height" != "2160" ]; then
          niri msg output "$identifier" mode "3840x2160"
        fi

        saved_scale=$(awk -F '\t' -v identifier="$identifier" '
          $1 == identifier { scale = $2 }
          END { print scale }
        ' "$state_file")
        target_scale="''${saved_scale:-1.5}"

        if awk -v current="$current_scale" -v target="$target_scale" '
          BEGIN {
            difference = current - target
            if (difference < 0) difference = -difference
            exit !(difference > 0.0001)
          }
        '; then
          niri msg output "$identifier" scale "$target_scale"
        fi
      done < <(
        printf '%s' "$outputs" | jq -r '
          to_entries[]
          | .value as $output
          | ($output.current_mode // -1) as $mode_index
          | [
              (if $output.make == "Unknown" and $output.model == "Unknown" and $output.serial == null then
                 $output.name
               else
                 [$output.make, $output.model, ($output.serial // "Unknown")] | join(" ")
               end),
              $output.model,
              (if $mode_index >= 0 then $output.modes[$mode_index].width else 0 end),
              (if $mode_index >= 0 then $output.modes[$mode_index].height else 0 end),
              ($output.logical.scale // 0)
            ]
          | @tsv
        '
      )
    '';
  };
in
{
  home.activation.initializeNiriMonitorScales = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    state_directory=${lib.escapeShellArg "${config.xdg.stateHome}/niri"}
    state_file="$state_directory/monitor-scales.tsv"

    $DRY_RUN_CMD mkdir -p "$state_directory"
    if [ ! -e "$state_file" ]; then
      $DRY_RUN_CMD touch "$state_file"
    fi
  '';

  # Noctalia persists UI edits in a state-side overlay which wins over the
  # declarative config. Drop only lock-screen settings from that overlay so the
  # Nix-managed appearance below remains authoritative without disturbing any
  # unrelated settings changed through the UI.
  home.activation.clearNoctaliaLockscreenOverrides = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    state_file=${lib.escapeShellArg "${config.xdg.stateHome}/noctalia/settings.toml"}

    if [ -f "$state_file" ]; then
      $DRY_RUN_CMD ${lib.getExe pkgs.yq-go} -i 'del(.lockscreen, .lockscreen_widgets)' "$state_file"
    fi
  '';

  home.packages = with pkgs; [
    btop
    cycleMonitorScale
    evince
    imv
    playerctl
    wtype
  ];

  # Niri runs as this user service and owns graphical-session.target.
  wayland.systemd.target = "niri.service";

  systemd.user.services.niri-monitor-config = {
    Unit = {
      Description = "Apply saved Niri monitor configuration";
      PartOf = [ "niri.service" ];
      After = [ "niri.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe applyNiriMonitorConfig;
    };
    Install.WantedBy = [ "niri.service" ];
  };

  # Sourcing from the validated derivation makes validation a dependency of
  # the Home Manager generation.
  xdg.configFile."niri/config.kdl".source = niriConfig;

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
            command = "niri msg action quit --skip-confirmation";
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
        blur_intensity = 0.35;
        tint_intensity = 0.25;
        wallpaper = wallpaper;
      };

      lockscreen_widgets = {
        enabled = true;
        schema_version = 2;
        widget_order = [ "lockscreen-login-box@DP-3" ];

        widget."lockscreen-login-box@DP-3" = {
          type = "login_box";
          output = "DP-3";
          cx = 1200.0;
          cy = 1125.0;
          enabled = true;

          settings = {
            layout = "compact";
            show_session_buttons = false;
            show_media = false;
            show_weather = false;
            show_login_button = false;
            show_unlock_hint = false;
            show_caps_lock = true;
            show_keyboard_layout = false;
            input_opacity = 0.72;
            input_radius = 16;
            center_password_text = true;
            background_color = "surface_variant";
            background_opacity = 0.50;
            background_radius = 18;
          };
        };
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
          timeout = 900;
          action = "lock";
          enabled = true;
        };
        "screen-off" = {
          timeout = 900;
          action = "screen_off";
          enabled = true;
        };
      };

      weather.enabled = false;
      plugins = {
        enabled = [ ];
        auto_update = false;
      };

      widget.network.show_label = false;

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
          "tray"
          "notifications"
          "bluetooth"
          "network"
          "volume"
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
