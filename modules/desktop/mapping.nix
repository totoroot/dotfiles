# modules/desktop/mapping.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.mapping;
in {
  options.modules.desktop.mapping = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Extensible editor for OpenStreetMap
      josm
      # Free and Open Source Geographic Information System
      # qgis
    ];
  };
}
