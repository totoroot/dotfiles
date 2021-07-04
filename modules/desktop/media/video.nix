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
      ffmpeg-full
      (mkIf cfg.player.enable mpv-with-scripts)
      (mkIf cfg.player.enable mpvc)
      (mkIf cfg.player.enable vlc)
      (mkIf cfg.recording.enable obs-studio)
      (mkIf cfg.recording.enable vokoscreen)
      (mkIf cfg.cut.enable kdenlive)
      # (mkIf cfg.cut.enable natron)
      (mkIf cfg.transcode.enable handbrake)
    ];
  };
}
