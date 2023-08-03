# modules/shell/lf.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.lf;
in {
  options.modules.shell.lf = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Terminal file manager written in Go and heavily inspired by ranger
      lf
      # Ranger-like terminal file manager written in Rust
      joshuto
      # cat(1) clone with syntax highlighting and Git integration
      bat
      # MS-Word/Excel/PowerPoint to text converter
      catdoc
      # Extracts plain text from docx files
      catdocx
      # Tool to read, write and edit EXIF meta information
      exiftool
      # Lightweight video thumbnailer
      ffmpegthumbnailer
      # GNOME Office Spreadsheet
      gnumeric
      # Software suite to create, edit, compose, or convert bitmap images
      imagemagick
      # Simple .odt to .txt converter
      odt2txt
      # Graphical pdf (and epub, cbz, ...) reader that works inside the kitty terminal
      termpdfpy
      # Fast, easy and free BitTorrent client
      transmission
      # Utility for RAR archives
      unrar
      # Extraction utility for archives compressed in .zip format
      unzip
      # # Terminal graphics for the 21st century !!! replaced by kitty's icat !!!
      # chafa
      # # PDF rendering library !!! replaced by termpdfpy !!!
      # poppler
    ];

    home.configFile = {
      "lf/lfrc".source = "${configDir}/lf/lfrc";
    };
  };
}
