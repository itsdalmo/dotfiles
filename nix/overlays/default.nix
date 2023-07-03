# Overlay that adds my custom derivations to nixpkgs.
inputs: final: prev: {
  unstable = (import inputs.nixpkgs-unstable { system = prev.system; config = prev.config; });

  # Custom packages
  tfcheck = final.callPackage ../pkgs/tfcheck { };
}
