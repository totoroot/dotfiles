# modules/desktop/apps/ide.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.ide;
in {
  options.modules.desktop.apps.ide = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Small and lightweight IDE
      geany
      # Python IDE for beginners
      thonny
    ];
  };
}
