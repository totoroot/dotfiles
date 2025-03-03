# modules/shell/archive.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.archive;
in {
  options.modules.shell.archive = {
    enable = mkBoolOpt false;
    desktop.enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs;
      (if cfg.enable then [
        # Easily create & extract archives, and compress & decompress files of various formats
        # archiver
        # Extraction utility for RAR archives
        unrar
        # GNU zip compression program
        gzip
        # Extraction utility for ZIP archives
        unzip
        # Package manager (Debian, Ubuntu etc.)
        dpkg
        # Package manager (openSUSE, Fedora etc.)
        rpm
      ] else [ ]) ++

      (if cfg.desktop.enable then [
        # Archive manager for the GNOME desktop environment
        file-roller
      ] else [ ]);
  };
}
