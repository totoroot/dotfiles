# modules/desktop/media/video/player.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.video.player;
in {
  options.modules.desktop.media.video.player = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      ffmpeg-full
      mpv-with-scripts
      mpvc
      vlc
    ];
  };
}
