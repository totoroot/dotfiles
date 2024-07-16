# modules/desktop/media/audio.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.media.audio;
  lollypopWithoutYT = pkgs.lollypop.override { youtubeSupport = false; };
in
{
  options.modules.desktop.media.audio = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Terminal-based music player, library, and streaming audio server
      musikcube
      # Modern music player for GNOME
      lollypopWithoutYT
      # Official MusicBrainz music tagger
      # picard
    ];

    home.dconfSettings = {
      "org/gnome/Lollypop" = {
        background-mode = true;
        hd-artwork = true;
        import-advanced-artist-tags = true;
        import-playlists = true;
        music-uris = [
          "file:///home/mathym/music/library"
        ];
        network-access-acl = 1048574;
        notification-flag = 3;
        orderby = "artist_title";
        repeat = "auto_similar";
        save-state = true;
        volume-rate = 1.0;
        window-maximized = true;
      };
    };
  };
}
