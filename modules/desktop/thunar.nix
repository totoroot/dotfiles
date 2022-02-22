# modules/desktop/thunar.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.thunar;
in {
  options.modules.desktop.thunar = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      xfce.thunar
      xfce.thunar-volman
      xfce.thunar-archive-plugin
      # virtual Filesystem support library
      gvfs
    ];

    home.configFile = {
      "Thunar/uca.xml".source = "${configDir}/thunar/uca.xml";
    };
  };
}
