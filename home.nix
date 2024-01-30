{ user, pkgs, ... }:
let nerdfonts = pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; };
in {
  home.username = user;
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${user}" else "/home/${user}";
  home.stateVersion = "23.11";

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";

    # Could consider moving these back to fish.config?
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    AWS_PAGER = "";
    AWS_DEFAULT_REGION = "eu-west-1";
  };

  home.sessionPath = [ "$HOME/bin" ];
  home.file = {
    ".ssh/allowed_signers".source = ./files/.ssh/allowed_signers;
  };

  xdg.enable = true;
  xdg.configFile = {
    "fd".source = ./files/.config/fd;
    "git".source = ./files/.config/git;
    "nix".source = ./files/.config/nix;
    "nvim".source = ./files/.config/nvim;
    "ideavim".source = ./files/.config/ideavim;
    "wezterm".source = ./files/.config/wezterm;
    "alacritty".source = ./files/.config/alacritty;

    # The root fish config has to be managed by home-manager
    # (in order to add fzf/zoxide/etc)
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
    gofumpt
    golangci-lint
    goreleaser
    jetbrains-mono
    jq
    kics
    lazygit
    neovim
    nerdfonts
    nodePackages.jsonlint
    nodePackages.prettier
    ripgrep
    shellcheck
    shfmt
    stylua
    tfcheck
    tflint
    tfswitch
    yubikey-manager

    # Mason/TS dependencies (neovim)
    cargo
    gcc
    nodejs

    # Installed another way (brew/package manager):
    # vscode

    # Installed/managed by home-manager:
    # fish
    # fisher
    # fzf

    # Use nix.shell instead:
    # apache-maven
    # buf
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

  programs.direnv = {
    enable = true;

    # Read-only as it is enabled by default:
    # enableFishIntegration = true;
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
}