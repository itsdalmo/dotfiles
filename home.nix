{ config, user, pkgs, ... }:
let nerdfonts = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" "NerdFontsSymbolsOnly" ]; };
in {
  home.username = user;
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${user}" else "/home/${user}";
  home.stateVersion = "23.11";

  home.sessionPath = [ "$HOME/bin" "$HOME/go/bin" ];
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";

    # Could consider moving these back to fish.config?
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    GOPATH = "$HOME/go";
    AWS_PAGER = "";
    AWS_DEFAULT_REGION = "eu-west-1";
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
            onChange = ''cp $HOME/${file.name}_source $HOME/${file.name} && chmod ${file.permissions} $HOME/${file.name}'';
          };
        };
    in
    builtins.listToAttrs (map copy files) // (if pkgs.stdenv.isDarwin then { ".Brewfile".source = ./files/.Brewfile; } else { });

  xdg.enable = true;
  xdg.configFile = {
    "fd".source = ./files/.config/fd;
    "git".source = ./files/.config/git;
    "nix".source = ./files/.config/nix;
    "ideavim".source = ./files/.config/ideavim;
    "wezterm".source = ./files/.config/wezterm;
    "alacritty".source = ./files/.config/alacritty;

    # Neovim has to be writeable since we use lazyvim to install plugins
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/github.com/itsdalmo/dotfiles/files/.config/nvim";

    # The root fish config has to be managed by home-manager
    # (in order to add fzf/zoxide/etc)
    "fish/osx.fish".source = ./files/.config/fish/osx.fish;
    "fish/linux.fish".source = ./files/.config/fish/linux.fish;
    "fish/functions".source = ./files/.config/fish/functions;
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
    neovim
    nerdfonts
    ripgrep
    tfswitch
    typescript
    yubikey-manager

    # Mason/TS dependencies (neovim)
    cargo
    gcc
    nodejs

    # LSPs/linters/formatters
    buf
    dockerfile-language-server-nodejs
    gofumpt
    golangci-lint
    gopls
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
    tfcheck
    tflint
    vscode-langservers-extracted # markdown, eslint, css, json, html
    yaml-language-server

    # Installed another way (brew/package manager):
    # vscode

    # Installed/managed by home-manager:
    # fish
    # fisher
    # fzf

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

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;

    # Read-only as it is enabled by default:
    # enableFishIntegration = true;
  };
}
