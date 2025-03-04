{ config, user, pkgs, ... }:
let
  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${user}" else "/home/${user}";
in
{
  home.stateVersion = "23.11";

  home.sessionPath = [ "$HOME/bin" "$HOME/go/bin" ];
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";

    # Could consider moving these back to fish.config?
    AWS_DEFAULT_REGION = "eu-west-1";
    AWS_PAGER = "";
    EDITOR = "nvim";
    GOPATH = "$HOME/go";
    PAGER = "less -FirSwX";
    RIPGREP_CONFIG_PATH = "${config.xdg.configHome}/ripgrep/ripgreprc";
    ZK_NOTEBOOK_DIR = "${homeDirectory}/code/github.com/itsdalmo/notebook";
  };

  # FIXME: Workaround since we cannot set the correct mode on symlinks (see SO answer):
  # https://github.com/nix-community/home-manager/issues/322#issuecomment-1856128020
  home.file =
    let
      files = [
        { name = ".ssh/config"; permissions = "600"; }
        { name = ".ssh/allowed_signers"; permissions = "644"; }
        { name = ".ssh/authorized_keys"; permissions = "600"; }
      ];
      copy = file:
        {
          name = file.name + "_source";
          value = {
            source = ../files + ("/" + file.name);
            onChange = ''cp -f $HOME/${file.name}_source $HOME/${file.name} && chmod ${file.permissions} $HOME/${file.name}'';
          };
        };
    in
    builtins.listToAttrs (map copy files);

  xdg.enable = true;
  xdg.configFile = {
    "fd".source = ../files/.config/fd;
    "ghostty".source = ../files/.config/ghostty;
    "git".source = ../files/.config/git;
    "ideavim".source = ../files/.config/ideavim;
    "nix".source = ../files/.config/nix;
    "nvim".source = ../files/.config/nvim;
    "ripgrep".source = ../files/.config/ripgrep;
    "starship.toml".source = ../files/.config/starship.toml;
    "wezterm".source = ../files/.config/wezterm;
    "zk".source = ../files/.config/zk;

    # The root fish config has to be managed by home-manager
    # (in order to add fzf/zoxide/etc)
    "fish/osx.fish".source = ../files/.config/fish/osx.fish;
    "fish/linux.fish".source = ../files/.config/fish/linux.fish;
    "fish/functions".source = ../files/.config/fish/functions;

    # Home manager wants to install the theme under the bat directory
    "bat/config".source = ../files/.config/bat/config;

    # Lazygit stores its state in the directory
    "lazygit/config.yml".source = ../files/.config/lazygit/config.yml;
  };

  home.packages = with pkgs; [
    aws-vault
    awscli2
    devbox
    dive
    eza
    fd
    gh
    git
    gnumake
    go
    go-task
    goreleaser
    jq
    lazygit
    ripgrep
    teleport
    tfcheck
    tflint
    tfswitch
    typescript
    yubikey-manager
    zk

    # Installed another way (brew/package manager):
    # vscode

    # Installed/managed by home-manager:
    # fish
    # fisher
    # fzf
    # neovim

    # Use nix.shell instead:
    # apache-maven
    # helm
    # hugo
    # kubectl
    # kubectx
    # kustomize
    # nodejs
    # nvm
    # packer
    # protobuf
    # typescript
    # vhs
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ../files/.config/fish/config.fish;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
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

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    plugins = with pkgs.vimPlugins; [
      blink-cmp
      conform-nvim
      nvim-lint
      nvim-lspconfig
      nvim-navic
      nvim-ts-autotag
      persistence-nvim
      plenary-nvim
      tokyonight-nvim
      ts-comments-nvim
      zk-nvim

      (pkgs.vimUtils.buildVimPlugin {
        pname = "mini.nvim";
        version = "2025-02-28";
        src = pkgs.fetchFromGitHub {
          owner = "echasnovski";
          repo = "mini.nvim";
          rev = "3a354c754656538ad76d1add93ca21e75b7f3181";
          sha256 = "sha256-sTD0pFDgc+VOJOw1zroNzwYLOB6Tc1qXJLJ0q0W96kA=";
        };
      })

      (pkgs.vimUtils.buildVimPlugin rec {
        pname = "snacks.nvim";
        version = "2.22.0";
        src = pkgs.fetchFromGitHub {
          owner = "folke";
          repo = "snacks.nvim";
          rev = "v${version}";
          sha256 = "sha256-iXfOTmeTm8/BbYafoU6ZAstu9+rMDfQtuA2Hwq0jdcE=";
        };

        # nixpkgs also skips these checks:
        # https://github.com/NixOS/nixpkgs/blob/5135c59491985879812717f4c9fea69604e7f26f/pkgs/applications/editors/vim/plugins/overrides.nix#L2882-L2910
        doCheck = false;
      })

      (nvim-treesitter.withPlugins (_: nvim-treesitter.allGrammars ++ [
        (pkgs.tree-sitter.buildGrammar {
          language = "river";
          version = "eafcdc5";
          src = pkgs.fetchFromGitHub {
            owner = "grafana";
            repo = "tree-sitter-river";
            rev = "eafcdc5147f985fea120feb670f1df7babb2f79e";
            sha256 = "sha256-fhuIO++hLr5DqqwgFXgg8QGmcheTpYaYLMo7117rjyk=";
          };
        })
      ]))
    ];

    extraPackages = with pkgs; [
      deno
      grafana-alloy
      ansible-language-server
      ansible-lint
      buf
      dockerfile-language-server-nodejs
      gofumpt
      golangci-lint
      gopls
      jsonnet # also provides jsonnetfmt
      jsonnet-language-server
      kics
      lua-language-server
      nil
      nixpkgs-fmt
      nodePackages.typescript-language-server
      shellcheck
      shfmt
      stylua
      terraform-ls
      tflint
      vscode-langservers-extracted # markdown, eslint, css, json, html
      yaml-language-server
    ];

    withNodeJs = false;
    withPython3 = false;
    withRuby = false;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
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
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    # Read-only as it is enabled by default:
    # enableFishIntegration = true;
  };
}

