# modules/desktop/geany.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.geany;
in {
  options.modules.desktop.geany = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Small and lightweight IDE
      geany
    ];

    home.configFile = {
      "geany/geany.conf".source = "${configDir}/geany/geany.conf";
      "geany/keybindings.conf".source = "${configDir}/geany/keybindings.conf";
      "geany/colorschemes" = {
        recursive = true;
        source = "${configDir}/geany/colorschemes";
      };
    };
  };
}
