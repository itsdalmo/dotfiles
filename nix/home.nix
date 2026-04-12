{
  config,
  user,
  pkgs,
  ...
}:
let
  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${user}" else "/home/${user}";
in
{
  home.stateVersion = "23.11";
  home.username = user;
  home.homeDirectory = homeDirectory;

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/go/bin"
  ];
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    AWS_DEFAULT_REGION = "eu-west-1";
    AWS_PAGER = "";
    DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_8_0}/share/dotnet";
    EDITOR = "nvim";
    GOPATH = "$HOME/go";
    PAGER = "less -FirSwX";
    RIPGREP_CONFIG_PATH = "${config.xdg.configHome}/ripgrep/ripgreprc";
    ZK_NOTEBOOK_DIR = "${homeDirectory}/code/github.com/itsdalmo/notebook";
  };

  home.shellAliases = {
    awsv = "aws-vault exec";
    cat = "bat";
    g = "git";
    gc = "git checkout";
    gg = "lazygit";
    gl = "git log --oneline --graph --max-count 20";
    gs = "git status";
    k = "kubectl";
    l = "ll";
    tf = "terraform";
  };

  # FIXME: Workaround since we cannot set the correct mode on symlinks (see SO answer):
  # https://github.com/nix-community/home-manager/issues/322#issuecomment-1856128020
  home.file =
    let
      files = [
        {
          name = ".ssh/config";
          permissions = "600";
        }
        {
          name = ".ssh/allowed_signers";
          permissions = "644";
        }
        {
          name = ".ssh/authorized_keys";
          permissions = "600";
        }
      ];
      copy = file: {
        name = file.name + "_source";
        value = {
          source = ../files + ("/" + file.name);
          onChange = "cp -f $HOME/${file.name}_source $HOME/${file.name} && chmod ${file.permissions} $HOME/${file.name}";
        };
      };
    in
    builtins.listToAttrs (map copy files);

  xdg.enable = true;
  xdg.configFile = {
    "fd".source = ../files/.config/fd;
    "ghostty/config".source = ../files/.config/ghostty/config;
    "ideavim".source = ../files/.config/ideavim;
    "nix".source = ../files/.config/nix;
    "opencode/opencode.json".source = ../files/.config/opencode/opencode.json;
    "ripgrep".source = ../files/.config/ripgrep;
    "starship.toml".source = ../files/.config/starship.toml;
    "wezterm".source = ../files/.config/wezterm;
    "zk".source = ../files/.config/zk;

    # Home manager wants to install the theme under the bat directory
    "bat/config".source = ../files/.config/bat/config;

    # Lazygit stores its state in the directory
    "lazygit/config.yml".source = ../files/.config/lazygit/config.yml;
  }
  // (
    if pkgs.stdenv.isDarwin then
      {
        "ghostty/macos".source = ../files/.config/ghostty/macos;
      }
    else
      { }
  );

  home.packages = with pkgs; [
    aws-vault
    awscli2
    unstable.colima
    cosign
    dalmovim
    dive
    docker-client
    dotnetCorePackages.sdk_8_0
    eza
    fd
    gh
    gnumake
    go
    go-task
    goreleaser
    jq
    kind
    kubectl
    kubernetes-helm
    lazygit
    nodejs_24
    omnisharp-roslyn
    unstable.opencode
    oras
    postgresql
    presenterm
    renovate
    ripgrep
    skopeo
    teleport
    terraform
    tfcheck
    tflint
    tfswitch
    trivy
    typescript
    yubikey-manager
    zk
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "itsdalmo";
    userEmail = "kristian@dalmo.me";
    aliases = {
      unstage = "reset HEAD";
      uncommit = "reset --soft HEAD^";
    };
    ignores = [
      ".DS_Store"
      ".vscode"
      "*.code-workspace"
      ".idea"
      ".terraform"
      ".venv"
      ".python-version"
    ];
    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    extraConfig = {
      core.editor = "nvim";
      diff.tool = "nvimdiff";
      difftool.nvimdiff.cmd = "nvim -d $LOCAL $REMOTE";
      credential = {
        helper = "!aws codecommit credential-helper $@";
        UseHttpPath = true;
      };
      pull.ff = "only";
      tag.gpgSign = true;
      gpg = {
        format = "ssh";
        ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      };
    };
  };

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

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    defaultCommand = "fd --follow --hidden";
    fileWidgetCommand = "fd --follow --hidden .";
    fileWidgetOptions = [ "--preview 'bat --color=always {}' --preview-window '~3'" ];
    defaultOptions = [
      "--highlight-line"
      "--info=inline-right"
      "--ansi"
      "--border=none"
      "--color=bg+:#283457"
      "--color=bg:#16161e"
      "--color=border:#27a1b9"
      "--color=fg:#c0caf5"
      "--color=gutter:#16161e"
      "--color=header:#ff9e64"
      "--color=hl+:#2ac3de"
      "--color=hl:#2ac3de"
      "--color=info:#545c7e"
      "--color=marker:#ff007c"
      "--color=pointer:#ff007c"
      "--color=prompt:#2ac3de"
      "--color=query:#c0caf5:regular"
      "--color=scrollbar:#27a1b9"
      "--color=separator:#ff9e64"
      "--color=spinner:#ff007c"
    ];
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.bat = {
    enable = true;
    themes = {
      tokyonight = {
        src = pkgs.fetchFromGitHub {
          owner = "folke";
          repo = "tokyonight.nvim";
          rev = "c2725eb6d086c8c9624456d734bd365194660017";
          sha256 = "sha256-vKXlFHzga9DihzDn+v+j3pMNDfvhYHcCT8GpPs0Uxgg=";
        };
        file = "extras/sublime/tokyonight_night.tmTheme";
      };
    };
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    # https://github.com/NixOS/nixpkgs/issues/507531
    package = pkgs.unstable.direnv;

    # Read-only as it is enabled by default:
    # enableFishIntegration = true;
  };
}
