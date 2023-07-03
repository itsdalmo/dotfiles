{
  description = "development environment using nix (for itsdalmo)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs:
    let
      # Import nixpkgs with the correct config/overlays.
      mkPkgs = system: import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [
          (import ./nix/overlays)
          (final: prev:
            let
              unstable = import inputs.unstable { system = prev.system; config = prev.config; };
            in
            {
              # Use some packages from unstable
              neovim = unstable.neovim;
            })
        ];
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

        # Parallels VM (with built-in ISO)
        "parallels@arm64-linux" = mkHome {
          system = "aarch64-linux";
          user = "parallels";
        };
      };

      nixosConfigurations = {
        parallels-vm = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          pkgs = mkPkgs "aarch64-linux";
          modules = [
            ./nix/hosts/nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.dalmo = import ./home.nix;
              home-manager.extraSpecialArgs = { user = "dalmo"; };
            }
          ];
        };
      };

      darwinConfigurations = {
        dalmoBook = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          pkgs = mkPkgs "aarch64-darwin";
          modules = [
            ./nix/hosts/darwin/configuration.nix
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
