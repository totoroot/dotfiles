{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.duf;
in
{
  options.modules.home.duf = with types; {
    enable = mkBoolOpt false;
  };

  imports = [ ./config-symlinks.nix ];

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      duf
    ];

    home.shellAliases = {
      # Not interested in special devices
      duf = "duf -only local,fuse,network";
    };
  };
}
