{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.lf;
in
{
  options.modules.home.lf = {
    enable = mkBoolOpt false;
  };

  imports = [ ./config-symlinks.nix ];

  config = mkIf cfg.enable {
    modules.home.configSymlinks.enable = true;

    home.packages = with pkgs; [
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
      # Utility for RAR archives
      unrar
      # Extraction utility for archives compressed in .zip format
      unzip
    ];

    modules.home.configSymlinks.entries = [
      "lf/lfrc"
    ];
  };
}
