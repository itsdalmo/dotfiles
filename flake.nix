{
  description = "Nix as a package manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs:
    let
      overlays = [
        # Unstable packages
        (final: prev: {
          neovim = (import inputs.nixpkgs-unstable { system = prev.system; config = prev.config; }).neovim;
          devbox = (import inputs.nixpkgs-unstable { system = prev.system; config = prev.config; }).devbox;
        })

        # Additional packages
        (final: prev: {
          tfcheck = final.callPackage ./nix/packages/tfcheck { };
        })
      ];

      # Helper function to create package sets
      mkPkgs = system: import nixpkgs { inherit system overlays; };

      # Create home-manager configuration for system/user.
      mkHome = { system, user }: home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs system;
        modules = [ ./home.nix ];
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

      darwinConfigurations = {
        dalmobook = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          pkgs = mkPkgs "aarch64-darwin";
          modules = [
            ./nix/hosts/dalmobook.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.dalmo = import ./home.nix;
              home-manager.extraSpecialArgs = { user = "dalmo"; };
            }
          ];
        };
      };
    };
}
