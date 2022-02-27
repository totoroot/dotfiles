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
      # Virtual filesystem support library
      gvfs
    ];

    home.configFile = {
      # Set custom actions for thunar
      "Thunar/uca.xml".source = "${configDir}/thunar/uca.xml";
      # Set user space bookmarks for thunar and other GTK applications
      "gtk-3.0/bookmarks".source = "${configDir}/thunar/bookmarks";
    };
  };
}
