# modules/desktop/fm.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.fm;
in {
  options.modules.desktop.fm = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # File manager with GTK interface
      pcmanfm
      # Xfce file manager
      unstable.xfce.thunar
      # Thunar extension for automatic management of removable drives and media
      unstable.xfce.thunar-volman
      # Thunar plugin providing file context menus for archives
      xfce.thunar-archive-plugin
      # Thunar plugin providing tagging and renaming features for media files
      xfce.thunar-media-tags-plugin
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
