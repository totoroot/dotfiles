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
      kdenlive
      # Temporarily installed with flatpak due to broken Nix package
      # natron
    ];
  };
}
