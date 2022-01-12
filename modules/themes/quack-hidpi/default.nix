# modules/themes/quack-hidpi/default.nix --- a regal dracula-inspired theme

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.theme;
in {
  config = mkIf (cfg.active == "quack-hidpi") (mkMerge [
    # Desktop-agnostic configuration
    {
      modules = {
        theme = {
          wallpaper = mkDefault ./config/wallpaper.png;
          gtk = {
            theme       = "Dracula";
            iconTheme   = "Papirus";
            cursorTheme = "Papirus";
            # cursorSize  = 36;
          };
        };

        shell.zsh.rcFiles  = [ ./config/zsh/prompt.zsh ];
        desktop.browsers = {
          firefox.userChrome = concatMapStringsSep "\n" readFile [
            ./config/firefox/userChrome.css
          ];
          qutebrowser.userStyles = concatMapStringsSep "\n" toCSSFile [
            ./config/qutebrowser/github.scss
            ./config/qutebrowser/monospace-textareas.scss
            ./config/qutebrowser/stackoverflow.scss
            ./config/qutebrowser/xkcd.scss
            ./config/qutebrowser/youtube.scss
          ];
        };
      };
      env = {
        XDG_THEME_CONFIG = "$XDG_CONFIG_HOME/dotfiles/modules/themes/quack-hidpi/config/";
        BAT_THEME = "Dracula";
      };
    }

    # Desktop (X11) theming
    (mkIf config.services.xserver.enable {
      user.packages = with pkgs; [
        dracula-theme
        papirus-icon-theme
      ];
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
        # activeOpacity = "1.00";
        # inactiveOpacity = "0.92";
        settings = {
          shadow-radius = 12;
          # blur-background = true;
          # blur-background-frame = true;
          # blur-background-fixed = true;
          blur-kern = "7x7box";
          blur-strength = 320;
        };
      };

      # Login screen theme
      services.xserver.displayManager.lightdm.greeters = {
        mini = {
          # More information here: https://github.com/prikhi/lightdm-mini-greeter/blob/master/data/lightdm-mini-greeter.conf
          extraConfig = ''
            font = "Monospace"
            font-size = 38
            text-color = "#ff79c6"
            password-background-color = "#1E2029"
            window-color = "#181a23"
            border-color = "#181a23"
            password-character = "-1"
            password-input-width = 20
          '';
        };
        gtk.cursorTheme = {
          # name = "Vanilla-DMZ";
          # package = pkgs.vanilla-dmz;
          size = 128;
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
