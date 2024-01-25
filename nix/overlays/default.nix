# Overlay that adds my custom derivations to nixpkgs.
final: prev: {
  tfcheck = final.callPackage ../pkgs/tfcheck { };
}
