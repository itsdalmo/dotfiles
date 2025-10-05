{ pkgs, mini, ... }:

let
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
      name = "dalmovim";
      src = ./.;

      postInstall = ''
        rm $out/default.nix
      '';

      doCheck = false;
    })

    (pkgs.vimUtils.buildVimPlugin {
      pname = "mini.nvim";
      version = "latest";
      src = mini;
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

  packages = with pkgs; [
    deno
    grafana-alloy
    buf
    dockerfile-language-server
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

in
pkgs.neovim.override {
  configure = {
    customRC = ''
      lua << EOF
        require 'dalmovim'
      EOF
    '';
    packages = {
      config = {
        start = plugins;
      };
    };
  };

  extraMakeWrapperArgs = ''--prefix PATH : "${pkgs.lib.makeBinPath packages}"'';

  withNodeJs = false;
  withPython3 = false;
  withRuby = false;
}
