# modules/desktop/apps/vscodium.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.vscodium;
in {
  options.modules.desktop.apps.vscodium = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      vscodium
    ];
  };
}
