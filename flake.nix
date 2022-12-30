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
  description = "totoroot's NixOS flake";

  inputs =
    {
      nixos.url = "nixpkgs/nixos-unstable";
      nixos-unstable.url = "nixpkgs/nixos-unstable";
      nixpkgs.url = "nixpkgs/master";
      home-manager.url = "github:rycee/home-manager/release-22.05";
      home-manager.inputs.nixpkgs.follows = "nixpkgs";
      nixos-hardware.url = "github:nixos/nixos-hardware";
      devenv.url = "github:cachix/devenv/v0.4";
    };

  outputs = inputs @ { self, nixos, nixos-unstable, nixpkgs, home-manager, devenv, ... }:
    let
      inherit (builtins) baseNameOf;
      inherit (lib) nixosSystem mkIf removeSuffix attrNames attrValues;
      inherit (lib.my) dotFilesDir mapModules mapModulesRec mapHosts;

      system = "x86_64-linux";

      lib = nixos.lib.extend
        (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });

      mkPkgs = pkgs: extraOverlays: import pkgs {
        inherit system;
        # Allow the use of unfree software
        config.allowUnfree = true;
        overlays = extraOverlays ++ (attrValues self.overlays);
      };
      # Use different channels for installed packages for increased flexibility
      pkgs  = mkPkgs nixos [ self.overlay ];
      unstable = mkPkgs nixos-unstable [];
    in {
      lib = lib.my;

      overlay =
        final: prev: {
          inherit unstable;
          # Add overlays for flakes
          user = self.packages.${system};
          devenv = devenv.packages.${system}.devenv; 
        };

      overlays =
        mapModules ./overlays import;

      packages.${system} =
        mapModules ./packages
          (p: pkgs.callPackage p {});

      nixosModules =
        { dotfiles = import ./.; }
        // mapModulesRec ./modules import;

      nixosConfigurations =
        mapHosts ./hosts { inherit system; };


      devShell.${system} =
        import ./shell.nix { inherit pkgs; };
    };
}
