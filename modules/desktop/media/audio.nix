# modules/desktop/media/audio.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.audio;
in {
  options.modules.desktop.media.audio = {
    enable                 = mkBoolOpt false;
    player.enable          = mkBoolOpt true;
    misc.enable            = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs;
      (if cfg.player.enable then [
		    musikcube         # terminal music player
      ] else []) ++

      (if cfg.misc.enable then [
        picard                # music tagger
        audacity              # audio editing suite
        # pulseeffects-legacy   # equalizer and other effects for pulseaudio
        # lsp-plugins           # audio plugins needed for pulseeffects
      ] else []);
  };
}
