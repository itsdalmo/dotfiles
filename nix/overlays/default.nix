# Overlay that adds my custom derivations to nixpkgs.
inputs: final: prev: {
  stable = (import inputs.nixpkgs-stable { system = prev.system; config = prev.config; });

  # Custom packages
  dalmovim = final.callPackage ../pkgs/dalmovim { mini = inputs.mini-nvim; };
  tfcheck = final.callPackage ../pkgs/tfcheck { };

  # Override packages
  opencode = inputs.opencode-flake.packages.${prev.system}.default;
}
