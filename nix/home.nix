{ config, user, pkgs, ... }:
let
  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${user}" else "/home/${user}";
in
{
  home.stateVersion = "23.11";
  home.username = user;
  home.homeDirectory = homeDirectory;

  home.sessionPath = [ "$HOME/bin" "$HOME/go/bin" ];
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";

    # Could consider moving these back to fish.config?
    AWS_DEFAULT_REGION = "eu-west-1";
    AWS_PAGER = "";
    DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_8_0}/share/dotnet";
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
    "ripgrep".source = ../files/.config/ripgrep;
    "starship.toml".source = ../files/.config/starship.toml;
    "wezterm".source = ../files/.config/wezterm;
    "zk".source = ../files/.config/zk;
    "opencode/opencode.json".source = ../files/.config/opencode/opencode.json;

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
    colima
    cosign
    dalmovim
    docker-client
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
    kind
    kubectl
    kubernetes-helm
    k9s
    lazygit
    nodejs_24
    opencode
    oras
    podman
    postgresql
    ripgrep
    teleport
    terraform
    tfcheck
    tflint
    tfswitch
    trivy
    typescript
    yubikey-manager
    zk
    dotnetCorePackages.sdk_8_0
    omnisharp-roslyn
    presenterm

    # Use nix.shell instead:
    # apache-maven
    # helm
    # hugo
    # kustomize
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

