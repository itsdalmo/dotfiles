{ config, lib, ... }:
lib.mkMerge [
  {
    programs.zsh = {
      enable = true;
      initContent = ''
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
  (lib.mkIf config.programs.zsh.enable {
    programs.fzf.enableZshIntegration = true;
    programs.starship.enableZshIntegration = true;
    programs.zoxide.enableZshIntegration = true;
    programs.direnv.enableZshIntegration = true;
  })
]
