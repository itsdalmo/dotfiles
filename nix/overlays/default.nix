# Overlay that adds my custom derivations to nixpkgs.
inputs: final: prev: {
  unstable = (
    import inputs.nixpkgs-unstable {
      system = prev.stdenv.hostPlatform.system;
      config = prev.config;
    }
  );

  fish = final.unstable.fish;

  # Custom packages
  dalmovim = final.callPackage ../pkgs/dalmovim { };
  tfcheck = final.callPackage ../pkgs/tfcheck { };
}
