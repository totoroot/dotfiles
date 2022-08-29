# modules/desktop/media/video/editing.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.video.editing;
in {
  options.modules.desktop.media.video.editing = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Video editor
      kdenlive
      # Professional Video Editing, Color, Effects and Audio Post
      unstable.davinci-resolve
      # Node-graph based, open-source compositing software
      # FIXME Temporarily installed with flatpak due to broken Nix package
      # natron
    ];
  };
}
