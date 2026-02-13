# flake.nix --- Where the journey to a declarative system starts
#
# Author:  Matthias Thym <git@thym.at>
# URL:     https://codeberg.org/totoroot/dotfiles
# License: MIT

# If you have no idea what flakes are and what they are used for, then do like I
# did and read up on it with the following resources:
# Flakes in NixOS wiki: https://nixos.wiki/wiki/Flakes
# Nix Flake in NixOS manual: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html
# Examples for getting started: https://jdisaacs.com/blog/nixos-config/
# Article by tweag.io on Nix flakes: https://www.tweag.io/blog/2020-07-31-nixos-flakes/

{
  description = "My Personal NixOS, Linux and Darwin System Flake Configuration";

  inputs = {
    # All flake references used to build this NixOS setup. These are dependencies.

    # Nix packages
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs-fork.url = "github:totoroot/nixpkgs/master";

    # Nix hardware tweaks
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # User space configuration, dotfile and package management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Darwin configuration and package managements
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix User Repository packages
    # Add "nur.nixosModules.nur" to the host modules
    nur.url = "github:nix-community/NUR";

    # YES!!! https://lix.systems/
    lix = {
      # Get latest release with `get-releases https://git.lix.systems/lix-project/nixos-module | head -n1`
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.3-2.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/thefossguy/nixos-needsreboot
    nixos-needsreboot = {
      url = "github:thefossguy/nixos-needsreboot";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # KDE Plasma user settings
    # Add "inputs.plasma-manager.homeManagerModules.plasma-manager" to the home-manager.users.${user}.imports
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "nixpkgs";
    };

    rcat = {
      url = "git+https://codeberg.org/totoroot/rcat.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    adventurelog = {
      url = "git+https://codeberg.org/totoroot/adventurelog-flake.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixos, nixos-unstable, home-manager, darwin, ... }:
    let
      inherit (lib) attrValues;
      inherit (lib.my) mapModules mapModulesRec mapHosts;

      system = "x86_64-linux";

      lib = nixos.lib.extend
        (self: _super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });

      mkPkgs = pkgs: extraOverlays: import pkgs {
        inherit system;
        # Allow the use of unfree software
        config.allowUnfree = true;
        overlays = extraOverlays ++ (attrValues self.overlays);
      };
      # Use different channels for installed packages for increased flexibility
      pkgs = mkPkgs nixos [ self.overlay ];
      unstable = mkPkgs nixos-unstable [ ];
      nixpkgs = mkPkgs nixpkgs [ ];
    in
    {
      lib = lib.my;

      overlay =
        _final: _prev: {
          inherit unstable nixpkgs;
          # Add overlays for flakes
          user = self.packages.${system};
        };

      overlays =
        mapModules ./overlays import;

      packages.${system} =
        mapModules ./packages
          (p: pkgs.callPackage p { });

      nixosModules =
        { dotfiles = import ./.; }
        // mapModulesRec ./modules import;

      devShells.${system}.default =
        import ./shell.nix {
          inherit pkgs;
        };

      # Configuration for NixOS hosts
      nixosConfigurations =
        mapHosts ./hosts/nixos {
          inherit system;
        };

      # Configuration for macOS using Nix, nix-darwin and home-manager
      darwinConfigurations =
        mapHosts ./hosts/darwin {
          builder = darwin.lib.darwinSystem;
          system = "aarch64-darwin";
          useGlobalPkgs = false;
          includeDotfilesModule = false;
        };

      # Configuration for generic Linux distros using Nix and home-manager
      homeConfigurations = (
        import ./generic-linux {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager;
        }
      );
    };
}
