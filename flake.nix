{
  description = "Nix as a package manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # Import nixpkgs with the correct config/overlays.
      mkPkgs = system: import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [ (import ./nix/overlays) ];
      };

      # Create home-manager configuration for system/user.
      mkHome = { system, user }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          modules = [
            ./home.nix
          ];
          extraSpecialArgs = { inherit user; };
        };

      # Helper function to add outputs for each supported system.
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSystem = f: nixpkgs.lib.genAttrs systems (system: f (mkPkgs system));
    in
    {
      formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);

      homeConfigurations = {
        "dalmo@arm64-darwin" = mkHome {
          system = "aarch64-darwin";
          user = "dalmo";
        };
        "dalmo@arm64-linux" = mkHome {
          system = "aarch64-linux";
          user = "dalmo";
        };
        "dalmo@amd64-linux" = mkHome {
          system = "x86_64-linux";
          user = "dalmo";
        };
      };
    };
}
