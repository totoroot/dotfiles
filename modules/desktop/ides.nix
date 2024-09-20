{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.ides;
in {
  options.modules.desktop.ides = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # High-performance, multiplayer code editor from the creators of Atom and Tree-sitter
      zed-editor
      # Python IDE for beginners
      thonny
      # Small and lightweight IDE
      geany
    ];

    home.configFile = {
      "Thonny/configuration.ini".source = "${configDir}/thonny/configuration.ini";
      "geany/geany.conf".source = "${configDir}/geany/geany.conf";
      "geany/keybindings.conf".source = "${configDir}/geany/keybindings.conf";
      "geany/colorschemes" = {
        recursive = true;
        source = "${configDir}/geany/colorschemes";
      };
    };
  };
}
