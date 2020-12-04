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
    user.packages = with pkgs;
      (if cfg.player.enable then [
        mpv-with-scripts
     	mpvc  # CLI controller for mpv
        celluloid
        vlc
      ] else []) ++

      (if cfg.recording.enable then [
        obs-studio
        vokoscreen
      ] else []) ++
      
      (if cfg.cut.enable then [
        kdenlive
      ] else []) ++

      (if cfg.transcode.enable then [
        handbrake
      ] else []);
  };
}
