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
      # Free and open source software for video recording and live streaming
      obs-studio
      # OBS Studio plugin that allows you to screen capture on wlroots based wayland compositors
      obs-studio-plugins.wlrobs
      # Audio device and application capture for OBS Studio using PipeWire
      obs-studio-plugins.obs-pipewire-audio-capture
    ];

    user.extraGroups = [ "video" ];
  };
}
