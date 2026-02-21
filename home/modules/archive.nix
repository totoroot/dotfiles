{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.archive;
in
{
  options.modules.home.archive = {
    enable = mkBoolOpt false;
    desktop.enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
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
      ]
      ++ (if cfg.desktop.enable then [
        # Archive manager for the GNOME desktop environment
        file-roller
      ] else [ ]);
  };
}
