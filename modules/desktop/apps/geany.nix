# modules/desktop/apps/geany.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.geany;
in {
  options.modules.desktop.apps.geany = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      geany
    ];
  };
}
