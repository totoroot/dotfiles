# modules/desktop/apps/torrent.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.torrent;
in {
  options.modules.desktop.apps.torrent = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      unstable.ktorrent
    ];
  };
}
