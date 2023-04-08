# modules/themes/quack/default.nix --- a regal dracula-inspired theme

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.theme;
in {
  config = mkIf (cfg.active == "dracula") (mkMerge [
    # Desktop-agnostic configuration
    {
      modules = {
        theme = {
          # wallpaper = mkDefault ./config/wallpaper.png;
          gtk = {
            theme       = "Dracula";
            iconTheme   = "Papirus";
            cursorTheme = "Dracula-cursors";
          };
        };

        shell.zsh.rcFiles  = [ ./config/zsh/prompt.zsh ];
        desktop.browsers = {
          firefox.userChrome = concatMapStringsSep "\n" readFile [
            ./config/firefox/userChrome.css
          ];
        };
      };

      env = {
        XDG_THEME_CONFIG = "$XDG_CONFIG_HOME/dotfiles/modules/themes/dracula/config/";
        BAT_THEME = "Dracula";
        GTK_DATA_PREFIX = [ "${config.system.path}" ];
      };
    }

    # Desktop theming
    (mkIf config.xdg.portal.enable {
      environment.systemPackages = with pkgs; [
        dracula-theme
        papirus-icon-theme
      ];

      home.file = {
        ".Xresources".text = ''
          Xcursor.theme: Dracula-cursors
          Xcursor.Size: 16
        '';
      };

      fonts.fontconfig.defaultFonts = {
        sansSerif = ["Fira Sans"];
        monospace = ["Mononoki"];
      };


      # Other dotfiles
      home.configFile = with config.modules; mkMerge [
        (mkIf desktop.rofi.enable {
          "rofi/theme" = { source = ./config/rofi; recursive = true; };
        })
        (mkIf desktop.media.graphics.vector.enable {
          "inkscape/templates/default.svg".source = ./config/inkscape/default-template.svg;
        })
      ];
    })
  ]);
}
