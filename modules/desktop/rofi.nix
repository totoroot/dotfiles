{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.rofi;
in {
  options.modules.desktop.rofi = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    # link recursively so other modules can link files in its folder
    # home.xdg.configFile."rofi" = {
    #   source = <config/rofi>;
    #   recursive = true;
    # };

    user.packages = with pkgs; [
      (writeScriptBin "rofi" ''
        #!${stdenv.shell}
        exec ${pkgs.rofi-wayland}/bin/rofi -terminal xst -m -1 "$@"
      '')

      # For rapidly test changes to rofi's stylesheets
      # (writeScriptBin "rofi-test" ''
      #   #!${stdenv.shell}
      #   themefile=$1
      #   themename=${my.theme.name}
      #   shift
      #   exec rofi \
      #        -theme ${themesDir}/$themename/rofi/$themefile \
      #        "$@"
      #   '')

      # Fake rofi dmenu entries in appmenu
      (makeDesktopItem {
        name = "rofi-bookmarkmenu";
        desktopName = "Open Bookmark in Browser";
        icon = "bookmark-new-symbolic";
        exec = "${binDir}/rofi/bookmarkmenu";
      })
      (makeDesktopItem {
        name = "rofi-filemenu-thunar";
        desktopName = "Open Directory in Thunar";
        icon = "folder";
        exec = "${binDir}/rofi/filemenu";
      })
      (makeDesktopItem {
        name = "rofi-filemenu";
        desktopName = "Open Directory in Terminal";
        icon = "folder";
        exec = "${binDir}/rofi/filemenu -x";
      })

      (makeDesktopItem {
        name = "lock-display";
        desktopName = "Lock screen";
        icon = "system-lock-screen";
        exec = "${binDir}/zzz";
      })
    ];
  };
}
