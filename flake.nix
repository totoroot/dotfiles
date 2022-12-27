# flake.nix --- the heart of my dotfiles
#
# Author:  Matthias Thym <git@thym.at>
# URL:     https://codeberg.org/totoroot/dotfiles
# License: MIT

{
  description = "My Personal NixOS, Linux and Darwin System Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";

    nixos.url = "github:nixos/nixpkgs/nixos-21.11";

    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
   	  url = "github:nix-community/home-manager";
   	  inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
  	  url = "github:lnl7/nix-darwin/master";
  	  inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, nixos, nixos-unstable, nixos-hardware, home-manager, darwin, ... }:
    let
      inherit (builtins) baseNameOf;
      inherit (lib) nixosSystem mkIf removeSuffix attrNames attrValues;
      inherit (lib.my) dotFilesDir mapModules mapModulesRec mapHosts;

      system = "x86_64-linux";

      lib = nixos.lib.extend
        (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });

      mkPkgs = pkgs: extraOverlays: import pkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = extraOverlays ++ (attrValues self.overlays);
      };

      pkgs  = mkPkgs nixos [ self.overlay ];
      unstable = mkPkgs nixos-unstable [];
    in {
      lib = lib.my;

      overlay =
        final: prev: {
          inherit unstable;
          user = self.packages."${system}";
        };

      overlays =
        mapModules ./overlays import;

      packages."${system}" =
        mapModules ./packages
          (p: pkgs.callPackage p {});

      nixosModules =
        { dotfiles = import ./.; }
        // mapModulesRec ./modules import;

      devShell."${system}" =
        import ./shell.nix { inherit pkgs; };

	  # Configuration for NixOS hosts
      nixosConfigurations =
        mapHosts ./hosts {
          inherit system;
        };

      # Configuration for macOS using Nix and home-manager
	  darwinConfigurations = (
        import ./darwin {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager darwin;
        }
      );

	  # Configuration for generic Linux distros using Nix and home-manager
      homeConfigurations = (
        import ./generic-linux {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager;
        }
      );

      # Flake variables
      # purple = self.nixosConfigurations.purple.activationPackage;
      steamdeck = self.homeConfigurations.steamdeck.activationPackage;
      defaultPackage.x86_64-linux = self.steamdeck;
    };
}
