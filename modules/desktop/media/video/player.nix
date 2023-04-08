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
      # A complete, cross-platform solution to record, convert and stream audio and video
      ffmpeg_5
      # General-purpose media player, fork of MPlayer and mplayer2
      mpv
      # A mpc-like control interface for mpv
      mpvc
      # Cross-platform media player and streaming server
      vlc
    ];

    home.configFile = {
      "mpv/mpv.conf".source = "${configDir}/mpv/mpv.conf";
    };
  };
}
