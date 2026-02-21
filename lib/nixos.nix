{ inputs, lib, pkgs, ... }:

with lib;
let
  moduleLib = import ./modules.nix {
    inherit lib;
    self.attrs = import ./attrs.nix { inherit lib; self = { }; };
  };
  reservedAttrs = [
    "builder"
    "extraModules"
    "includeDotfilesModule"
    "libOverride"
    "pkgs"
    "specialArgs"
    "system"
    "systems"
    "useGlobalPkgs"
  ];

  mkBaseModule = path: useGlobalPkgs: modulePkgs:
    optionalAttrs useGlobalPkgs {
      nixpkgs.pkgs = modulePkgs;
    } // {
      networking.hostName = mkDefault (removeSuffix ".nix" (baseNameOf path));
    };

  mkHostBuilder =
    builder:
    path:
    attrs @ {
      system ? system,
      specialArgs ? { },
      extraModules ? [ ],
      includeDotfilesModule ? true,
      libOverride ? lib,
      pkgs ? pkgs,
      useGlobalPkgs ? true,
      ...
    }:
    let
      moduleFromAttrs = filterAttrs (n: _v: !(elem n reservedAttrs)) attrs;
      modules =
        [
          (mkBaseModule path useGlobalPkgs pkgs)
          moduleFromAttrs
        ]
        ++ optional includeDotfilesModule ../.
        ++ [
          (import path)
        ]
        ++ extraModules;
      specialArgs' = { inherit inputs; lib = libOverride; } // specialArgs;
    in
    builder {
      inherit system modules;
      specialArgs = specialArgs';
    };
in
{
  mkNixosHost = mkHostBuilder nixosSystem;
  mkDarwinHost = mkHostBuilder inputs.darwin.lib.darwinSystem;

  mapHosts =
    dir:
    attrs @ { builder ? nixosSystem, systems ? { }, ... }:
    moduleLib.mapModules dir (hostPath:
      let
        name = removeSuffix ".nix" (baseNameOf hostPath);
        hostSystem =
          if systems ? name
          then systems.${name}
          else attrs.system;
      in
      mkHostBuilder builder hostPath (attrs // { system = hostSystem; }));
}
