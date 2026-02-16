{ config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.unfreePackages;
in
{
  options.modules.home.unfreePackages = {
    enable = mkBoolOpt false;
    packageNames = mkOpt (types.listOf types.str) [ ];
  };

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate = pkg:
      elem (getName pkg) cfg.packageNames;
  };
}
