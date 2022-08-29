# modules/desktop/kvantum.nix
{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.kvantum;
in {
  options.modules.desktop.kvantum = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.configFile = {
      "kvantum.kvconfig" = {
        text = "theme=Dracula-purple-solid";
        target = "Kvantum/kvantum.kvconfig";
      };
      "Dracula-kvantum" = {
        recursive = true;
        source = "${pkgs.dracula-theme}/share/themes/Dracula/kde/kvantum/Dracula";
        target = "Kvantum/Dracula";
      };
      "Dracula-Solid-kvantum" = {
        recursive = true;
        source = "${pkgs.dracula-theme}/share/themes/Dracula/kde/kvantum/Dracula-Solid";
        target = "Kvantum/Dracula-Solid";
      };
      "Dracula-purple-kvantum" = {
        recursive = true;
        source = "${pkgs.dracula-theme}/share/themes/Dracula/kde/kvantum/Dracula-purple";
        target = "Kvantum/Dracula-purple";
      };
      "Dracula-purple-solid-kvantum" = {
        recursive = true;
        source = "${pkgs.dracula-theme}/share/themes/Dracula/kde/kvantum/Dracula-purple-solid";
        target = "Kvantum/Dracula-purple-solid";
      };
    };
  };
}
