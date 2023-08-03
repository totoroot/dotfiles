{ lib, nixpkgs, home-manager, ... }:
let
  system = "x86_64-linux";
in
{
  steamdeck = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.${system};
    modules = [
      ./steamdeck/home.nix
    ];
  };
}
