# modules/desktop/apps/gpa.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.gpa;
in {
  options.modules.desktop.apps.gpa = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      gpa
    ];
  };
}
