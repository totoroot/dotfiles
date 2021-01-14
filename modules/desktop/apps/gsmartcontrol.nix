# modules/desktop/apps/gsmartcontrol.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.gsmartcontrol;
in {
  options.modules.desktop.apps.gsmartcontrol = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gsmartcontrol
    ];
  };
}
