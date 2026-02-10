# modules/desktop/media/video/transcoding.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.video.transcoding;
in {
  options.modules.desktop.media.video.transcoding = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # FIXME https://github.com/NixOS/nixpkgs/issues/484121
      # Tool for converting video files and ripping DVDs
      # handbrake
    ];
  };
}
