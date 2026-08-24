{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.qownnotes;
in
{
  options.modules.home.qownnotes = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # QOwnNotes - Plain-text file markdown note taking with Nextcloud integration
      qownnotes
    ];
  };
}
