{ inputs, lib, pkgs, ... }:

with lib;
with lib.my;
{
  mkHost = path: attrs @ { system ? system, ... }:
    nixosSystem {
      inherit system;
      specialArgs = { inherit lib inputs; };
      modules = [
        {
          nixpkgs.pkgs = pkgs;
          networking.hostName = mkDefault (removeSuffix ".nix" (baseNameOf path));
        }
        (filterAttrs (n: _v: !elem n [ "system" "systems" ]) attrs)
        ../.
        (import path)
      ];
    };

  mapHosts = dir: attrs @ { systems ? { }, ... }:
    mapModules dir
      (hostPath:
        let
          name = removeSuffix ".nix" (baseNameOf hostPath);
          hostSystem =
            if systems ? name
            then systems.${name}
            else attrs.system;
        in
        mkHost hostPath (attrs // { system = hostSystem; }));
}
