# Overlay that adds my custom derivations to nixpkgs.
inputs: final: prev: {
  stable = (import inputs.nixpkgs-stable { system = prev.system; config = prev.config; });

  # Custom packages
  tfcheck = final.callPackage ../pkgs/tfcheck { };
}
