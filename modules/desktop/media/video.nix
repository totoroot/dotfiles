# modules/desktop/media/video.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.video;
in {
  options.modules.desktop.media.video = {
    enable             = mkBoolOpt false;
    player.enable      = mkBoolOpt true;
    recording.enable   = mkBoolOpt true;
    cut.enable         = mkBoolOpt true;
    transcode.enable   = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      ffmpeg
      (mkIf cfg.player.enable [
        mpv-with-scripts
     	  mpvc  # CLI controller for mpv
        celluloid
        vlc
      ])
      (mkIf cfg.recording.enable [
        obs-studio
        vokoscreen
      ])
      (mkIf cfg.cut.enable [
        kdenlive
      ])
      (mkIf cfg.transcode.enable [
        handbrake
      ])
    ];
  };
}
