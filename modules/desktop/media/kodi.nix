# modules/desktop/media/video.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.kodi;
in {
  options.modules.desktop.media.kodi = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Media center
      kodiPackages.kodi
      # kodiPackages.youtube
      # kodiPackages.netflix
      # # Binary addon for raw joystick input
      # kodiPackages.joystick
      # kodiPackages.jellyfin
      # # Launch Steam in Big Picture Mode from Kodi
      # kodiPackages.steam-launcher
      # # Binary addon for steam controller
      # kodiPackages.steam-controller
      # # PDF/EBook reader
      # kodiPackages.pdfreader
    ];
  };
}
