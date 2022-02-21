# modules/desktop/apps/anki.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.anki;
in {
  options.modules.desktop.apps.anki = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Spaced repetition flashcard program
      anki-bin
    ];
  };
}
