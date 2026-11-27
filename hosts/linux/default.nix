{ lib, nixpkgs, home-manager, ... }:
let
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
in
{
  steamdeck = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      ./steamdeck/home.nix
    ];
  };

  debian = home-manager.lib.homeManagerConfiguration {
    pkgs = pkgs // { lib = pkgs.lib.extend (_: _: { inherit (lib) my; }); };
    modules = [
      ./debian/home.nix
    ];
  };
}
