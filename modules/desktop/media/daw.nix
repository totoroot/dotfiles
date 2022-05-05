# modules/desktop/media/daw.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.daw;
in {
  options.modules.desktop.media.daw = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Audio and sound editing suite
      audacity
      # Digital audio production and DJing workstation
      bitwig-studio
      # Music typesetting system
      lilypond
    ];
  };
}
