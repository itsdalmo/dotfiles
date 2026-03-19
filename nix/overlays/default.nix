# Overlay that adds my custom derivations to nixpkgs.
inputs: final: prev: {
  unstable = (
    import inputs.nixpkgs-unstable {
      system = prev.stdenv.hostPlatform.system;
      config = prev.config;
    }
  );

  # Custom packages
  dalmovim = final.callPackage ../pkgs/dalmovim { mini = inputs.mini-nvim; };
  tfcheck = final.callPackage ../pkgs/tfcheck { };
}
