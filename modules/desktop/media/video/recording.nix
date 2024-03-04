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
    environment.systemPackages = with pkgs; [
      # Simple GUI screencast recorder, using ffmpeg
      vokoscreen-ng
      # Free and open source software for video recording and live streaming
      (wrapOBS {
        plugins = with obs-studio-plugins; [
          # OBS Studio plugin that allows you to screen capture on wlroots based wayland compositors
          wlrobs
          # Audio device and application capture for OBS Studio using PipeWire
          obs-pipewire-audio-capture
          # OBS plugin to replace the background in portrait images and video
          obs-backgroundremoval
          # OBS Studio filter where the source can be set to be black & white or sepia.
          obs-vintage-filter
          # Song information plugin for OBS Studio
          obs-tuna
          # A comprehensive blur plugin for OBS Studio that provides several different blur algorithms, and proper compositing
          obs-composite-blur
          # Plugin for OBS Studio to freeze a source using a filter
          obs-freeze-filter
          # Show keyboard, gamepad and mouse input on stream in OBS Studio
          input-overlay
          # An automated scene switcher for OBS Studio
          # advanced-scene-switcher
          # Plugin for OBS Studio to move source to a new position during scene transition
          obs-move-transition
          # Plugin for OBS Studio to add a Transition Table to the tools menu
          obs-transition-table
          # OBS Studio plugin to make sources available to record via a filter
          obs-source-record
        ];
      })
    ];

    # Needed to get virtual cam from OBS output
    boot.extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
    security.polkit.enable = true;

    user.extraGroups = [ "video" ];
  };
}
