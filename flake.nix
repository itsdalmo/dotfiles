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

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, darwin, ... }@inputs:
    let
      # Helper function to create package sets
      mkPkgs = system: import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [ (import ./nix/overlays inputs) ];
      };
      # Create home-manager configuration for system/user.
      mkHome = { system, user }: home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs system;
        modules = [ ./nix/home.nix ];
        extraSpecialArgs = { inherit user inputs; };
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
          pkgs = mkPkgs "aarch64-darwin";
          modules = [
            ./nix/machines/dalmobook/configuration.nix
            home-manager.darwinModules.home-manager
          ];
        };
        macos-vm = darwin.lib.darwinSystem {
          pkgs = mkPkgs "aarch64-darwin";
          modules = [
            ./nix/machines/macos-vm/configuration.nix
            home-manager.darwinModules.home-manager
          ];
        };
      };

      nixosConfigurations = {
        nixos-vm = nixpkgs.lib.nixosSystem {
          pkgs = mkPkgs "aarch64-linux";
          modules = [
            ./nix/machines/nixos-vm/configuration.nix
            home-manager.nixosModules.home-manager
          ];
        };
      };
    };
}
