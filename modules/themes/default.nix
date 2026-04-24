# Shared theme options and base GTK/Qt config.

{ options, config, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.theme;
in {
  options.modules.theme = with types; {
    enable = mkBoolOpt true;

    gtk = {
      theme = mkOpt str "Dracula";
      iconTheme = mkOpt str "Papirus";
      cursorTheme = mkOpt str "Dracula-cursors";
    };
  };

  config = mkIf cfg.enable {
    home.configFile = {
      "gtk-3.0/settings.ini".text = ''
        [Settings]
        ${optionalString (cfg.gtk.theme != "")
          ''gtk-theme-name=${cfg.gtk.theme}''}
        ${optionalString (cfg.gtk.iconTheme != "")
          ''gtk-icon-theme-name=${cfg.gtk.iconTheme}''}
        ${optionalString (cfg.gtk.cursorTheme != "")
          ''gtk-cursor-theme-name=${cfg.gtk.cursorTheme}''}
        gtk-cursor-theme-size=32
        gtk-fallback-icon-theme=Adwaita
        gtk-application-prefer-dark-theme=true
        gtk-xft-hinting=1
        gtk-xft-hintstyle=hintfull
        gtk-xft-rgba=none
      '';

      "gtk-2.0/gtkrc".text = ''
        ${optionalString (cfg.gtk.theme != "")
          ''gtk-theme-name="${cfg.gtk.theme}"''}
        ${optionalString (cfg.gtk.iconTheme != "")
          ''gtk-icon-theme-name="${cfg.gtk.iconTheme}"''}
        gtk-font-name="Sans 12"
      '';

      "Trolltech.conf".text = ''
        [Qt]
        ${optionalString (cfg.gtk.theme != "")
          ''style=${cfg.gtk.theme}''}
      '';
    };
  };
}
