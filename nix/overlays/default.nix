# Overlay that adds my custom derivations to nixpkgs.
inputs: final: prev: {
  unstable = (
    import inputs.nixpkgs-unstable {
      system = prev.stdenv.hostPlatform.system;
      config = prev.config;
    }
  );

  # Custom packages
  dalmovim = final.callPackage ../pkgs/dalmovim { };
  github-work = final.callPackage ../pkgs/github-work { };
  mattpocock-skills = final.callPackage ../pkgs/mattpocock-skills { };
  tfcheck = final.callPackage ../pkgs/tfcheck { };
}
