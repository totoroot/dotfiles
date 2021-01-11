# modules/desktop/apps/evolution.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.evolution;
in {
  options.modules.desktop.apps.evolution = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      unstable.gnome3.evolution
    ];
  };
}
