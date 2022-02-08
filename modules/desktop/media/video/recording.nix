# modules/desktop/media/video/recording.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.video.recording;
in {
  options.modules.desktop.media.video.recording = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      vokoscreen
      obs-studio
    ];
  };
}
