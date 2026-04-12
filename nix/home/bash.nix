{ config, lib, ... }:
lib.mkMerge [
  {
    programs.bash = {
      enable = true;
      initExtra = ''
        case "$(uname)" in
          Darwin)
            case "$(uname -m)" in
              arm64)
                eval "$(/opt/homebrew/bin/brew shellenv)"
                ;;
              x86_64)
                eval "$(/usr/local/bin/brew shellenv)"
                ;;
            esac

            ;;
        esac

        ll() {
          eza -la --icons --group-directories-first "$@"
        }

        tree() {
          eza -l --tree --icons --only-dirs --level 2 "$@"
        }

      '';
    };
  }
  (lib.mkIf config.programs.bash.enable {
    programs.fzf.enableBashIntegration = true;
    programs.starship.enableBashIntegration = true;
    programs.zoxide.enableBashIntegration = true;
    programs.direnv.enableBashIntegration = true;
  })
]
