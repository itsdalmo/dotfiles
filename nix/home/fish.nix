{ config, lib, ... }:
lib.mkMerge [
  {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting ""

        if test (uname) = Darwin
            switch (uname -m)
                case arm64
                    eval (/opt/homebrew/bin/brew shellenv)
                case x86_64
                    eval (/usr/local/bin/brew shellenv)
            end
        end
      '';
      functions = {
        ll = ''
          eza -la --icons --group-directories-first $argv
        '';
        tree = ''
          eza -l --tree --icons --only-dirs --level 2 $argv
        '';
        fish_user_key_bindings = ''
          fish_vi_key_bindings
          fzf_key_bindings
        '';
      };
    };
  }
  (lib.mkIf config.programs.fish.enable {
    programs.fzf.enableFishIntegration = true;
    programs.starship.enableFishIntegration = true;
    programs.zoxide.enableFishIntegration = true;
  })
]
