{ lib, ... }:

let
  dir = ./.;
  entries = builtins.attrNames (builtins.readDir dir);
  nixFiles =
    lib.filter (name: name != "default.nix" && lib.hasSuffix ".nix" name) entries;
  imports = map (name: dir + "/${name}") nixFiles;
in
{
  inherit imports;
}
