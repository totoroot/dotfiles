# modules/themes/quack/default.nix --- a regal dracula-inspired theme

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.theme;
in {
  config = mkIf (cfg.active == "quack") (mkMerge [
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
        XDG_THEME_CONFIG = "$XDG_CONFIG_HOME/dotfiles/modules/themes/quack/config/";
        BAT_THEME = "Dracula";
        GTK_DATA_PREFIX = [ "${config.system.path}" ];
        QT_STYLE_OVERRIDE = "kvantum";
      };
    }

    # Desktop (X11) theming
    (mkIf config.services.xserver.enable {
      environment.systemPackages = with pkgs; [
        dracula-theme
        papirus-icon-theme
      ];

      home.file = {
        ".Xresources".text = ''
          Xft.dpi: 150
          Xcursor.theme: Dracula-cursors
          Xcursor.Size: 16
        '';
      };

      fonts.fontconfig.defaultFonts = {
        sansSerif = ["Fira Sans"];
        monospace = ["Mononoki"];
      };

      # Compositor
      services.picom = {
        fade = true;
        fadeDelta = 1;
        fadeSteps = [ 0.01 0.012 ];
        shadow = true;
        shadowOffsets = [ (-10) (-10) ];
        shadowOpacity = 0.22;
        activeOpacity = 1.00;
        inactiveOpacity = 0.92;
        opacityRules = [
          "100:class_g   *?= 'Firefox'"
          "100:class_g   *?= 'Chromium-browser'"
          "100:class_g   *?= 'GIMP'"
          "100:class_g   *?= 'Blender'"
          "100:class_g   *?= 'Inkscape'"
          "100:class_g   *?= 'Krita'"
          "100:class_g   *?= 'Kdenlive'"
          "100:class_g   *?= 'mpv'"
          "100:class_g   *?= 'umpv'"
          "100:class_g   *?= 'zathura'"
        ];
        settings = {
          shadow-radius = 12;
          # blur-background = true;
          # blur-background-frame = true;
          # blur-background-fixed = true;
          blur-kern = "7x7box";
          blur-strength = 320;
        };
      };

      services.xserver.displayManager = {
        lightdm = {
          greeters = {
            gtk.cursorTheme = {
              package = pkgs.dracula-theme;
              name = "Dracula-cursors";
              size = 32;
            };
            # Login screen theme
            mini.extraConfig = ''
              font = "Monospace"
              font-size = 14
              text-color = "#ff79c6"
              password-background-color = "#1E2029"
              window-color = "#181a23"
              border-color = "#181a23"
              password-character = "."
            '';
          };
        };
      };

      # Other dotfiles
      home.configFile = with config.modules; mkMerge [
        {
          # Sourced from sessionCommands in modules/themes/default.nix
          "xtheme/90-theme".source = ./config/Xresources;
        }
        (mkIf desktop.bspwm.enable {
          "bspwm/rc.d/polybar".source = ./config/polybar/launch.sh;
          "bspwm/rc.d/theme".source = ./config/bspwm/bspwmrc;
        })
        (mkIf desktop.apps.rofi.enable {
          "rofi/theme" = { source = ./config/rofi; recursive = true; };
        })
        (mkIf (desktop.bspwm.enable || desktop.stumpwm.enable) {
          "polybar" = { source = ./config/polybar; recursive = true; };
          "dunst/dunstrc".source = ./config/dunstrc;
        })
        (mkIf desktop.media.graphics.vector.enable {
          "inkscape/templates/default.svg".source = ./config/inkscape/default-template.svg;
        })
      ];
    })
  ]);
}
