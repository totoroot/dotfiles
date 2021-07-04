# flake.nix --- the heart of my dotfiles
#
# Author:  Henrik Lissner <henrik@lissner.net>
# URL:     https://github.com/hlissner/dotfiles
# License: MIT
#
# Welcome to ground zero. Where the whole flake gets set up and all its modules
# are loaded.

{
  description = "A grossly incandescent nixos config.";

  inputs = 
    {
      # Core dependencies.
      nixos.url          = "nixpkgs/nixos-21.05";
      nixos-unstable.url = "nixpkgs/nixos-unstable";

      nixpkgs.url        = "nixpkgs/master";

      home-manager.url   = "github:rycee/home-manager/release-21.05";
      home-manager.inputs.nixpkgs.follows = "nixpkgs";

      # Extras
      nixos-hardware.url = "github:nixos/nixos-hardware";
    };

  outputs = inputs @ { self, nixos, nixos-unstable, nixpkgs, home-manager, ... }:
    let
      inherit (builtins) baseNameOf;
      inherit (lib) nixosSystem mkIf removeSuffix attrNames attrValues;
      inherit (lib.my) dotFilesDir mapModules mapModulesRec mapHosts;

      system = "x86_64-linux";

      lib = nixos.lib.extend
        (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });

      mkPkgs = pkgs: extraOverlays: import pkgs {
        inherit system;
        config.allowUnfree = true;  # forgive me Stallman senpai
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

      nixosConfigurations =
        mapHosts ./hosts { inherit system; };

        
      devShell."${system}" =
        import ./shell.nix { inherit pkgs; };
    };
}
