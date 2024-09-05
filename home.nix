{ config, user, pkgs, ... }:
let
  nerdfonts = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" "NerdFontsSymbolsOnly" ]; };
  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${user}" else "/home/${user}";
in
{
  home.username = user;
  home.homeDirectory = homeDirectory;
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
            source = ./files + ("/" + file.name);
            onChange = ''cp -f $HOME/${file.name}_source $HOME/${file.name} && chmod ${file.permissions} $HOME/${file.name}'';
          };
        };
    in
    builtins.listToAttrs (map copy files) // (if pkgs.stdenv.isDarwin then { ".Brewfile".source = ./files/.Brewfile; } else { });

  xdg.enable = true;
  xdg.configFile = {
    "fd".source = ./files/.config/fd;
    "git".source = ./files/.config/git;
    "ideavim".source = ./files/.config/ideavim;
    "nvim".source = ./files/.config/nvim;
    "nix".source = ./files/.config/nix;
    "ripgrep".source = ./files/.config/ripgrep;
    "starship.toml".source = ./files/.config/starship.toml;
    "wezterm".source = ./files/.config/wezterm;
    "zk".source = ./files/.config/zk;

    # The root fish config has to be managed by home-manager
    # (in order to add fzf/zoxide/etc)
    "fish/osx.fish".source = ./files/.config/fish/osx.fish;
    "fish/linux.fish".source = ./files/.config/fish/linux.fish;
    "fish/functions".source = ./files/.config/fish/functions;

    # Home manager wants to install the theme under the bat directory
    "bat/config".source = ./files/.config/bat/config;
  };

  home.packages = with pkgs; [
    aws-vault
    awscli2
    eza
    fd
    gh
    git
    gnumake
    go
    go-task
    goreleaser
    jetbrains-mono
    jq
    lazygit
    nerdfonts
    ripgrep
    teleport
    tfcheck
    tfswitch
    typescript
    unstable.devbox
    unstable.zk
    yubikey-manager

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

  # Enable user fonts
  fonts.fontconfig.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ./files/.config/fish/config.fish;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultCommand = "fd --follow --hidden";
    fileWidgetCommand = "fd --follow --hidden .";
  };

  programs.neovim = {
    enable = true;
    package = pkgs.unstable.neovim-unwrapped;
    plugins = with pkgs.unstable.vimPlugins; [
      cmp-buffer
      cmp-nvim-lsp
      cmp-path
      conform-nvim
      lazygit-nvim
      nvim-cmp
      nvim-lint
      nvim-lspconfig
      nvim-navic
      nvim-ts-autotag
      persistence-nvim
      plenary-nvim
      ts-comments-nvim
      zk-nvim

      (nvim-treesitter.withPlugins (_: nvim-treesitter.allGrammars ++ [
        (pkgs.unstable.tree-sitter.buildGrammar {
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
      (pkgs.unstable.vimUtils.buildVimPlugin {
        pname = "mini.nvim";
        version = "2024-09-05";
        src = pkgs.unstable.fetchFromGitHub {
          owner = "echasnovski";
          repo = "mini.nvim";
          rev = "14f81b96d850d561b6ed0c1e6715fdd724e4447f";
          sha256 = "sha256-hRlE+3ts0u9QWKldj+vsRPssPeuFpLG4T5NFe7RaLtE=";
        };
      })
      (pkgs.unstable.vimUtils.buildVimPlugin {
        pname = "tokyonight.nvim";
        version = "2024-07-24";
        src = pkgs.unstable.fetchFromGitHub {
          owner = "folke";
          repo = "tokyonight.nvim";
          rev = "2cd12582c98a3552032824ffa67fd44b4d81184a";
          sha256 = "sha256-5QeY3EevOQzz5PHDW2CUVJ7N42TRQdh7QOF9PH1YxkU=";
        };
      })
    ];

    extraPackages = with pkgs.unstable; [
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
      nodePackages.prettier
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
          rev = "b0e7c7382a7e8f6456f2a95655983993ffda745e";
          sha256 = "sha256-5QeY3EevOQzz5PHDW2CUVJ7N42TRQdh7QOF9PH1YxkU=";
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
