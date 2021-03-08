# modules/shell/archive.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.archive;
in {
  options.modules.shell.archive = {
    enable          = mkBoolOpt false;
    desktop.enable  = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs;
      (if cfg.enable then [
        archiver  # interpreter for the AWK programming language
        unrar     # extraction utility for RAR archives
        gzip      # GNU zip compression program
        unzip     # extraction utility for ZIP archives
        dpkg      # package manager (Debian, Ubuntu etc.)
        rpm       # package manager (openSUSE, Fedora etc.)
      ] else []) ++

      (if cfg.desktop.enable then [
        xarchive  # GTK front-end for command line archiving tools
      ] else []);
  };
}
