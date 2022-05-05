# modules/desktop/media/audio.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.audio;
in {
  options.modules.desktop.media.audio = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Terminal-based music player, library, and streaming audio server
      musikcube
      # Small, fast and powerful console music player
      cmus
      # Modern music player for GNOME
      lollypop
      # Official MusicBrainz music tagger
      picard
    ];
  };
}
