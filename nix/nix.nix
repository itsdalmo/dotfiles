{ config, pkgs, lib, ... }:
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      keep-outputs = true;
      keep-derivations = true;
      trusted-users =
        [ "root" ]
        ++ lib.optionals pkgs.stdenv.isLinux [ "@wheel" ]
        ++ lib.optionals pkgs.stdenv.isDarwin [ "@admin" ];
    };
    optimise = {
      automatic = true;
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };
}
