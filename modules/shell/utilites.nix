{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.utilities;
in {
  options.modules.shell.utilities = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Create/modify zip archives
      zip
      # Extract zip archives
      unzip
      # Directory listing as tree
      tree
      # Show running processes as tree
      pstree
      # Collection of common network programs (including telnet, hostname, ifconfig)
      inetutils
      # Utility for controlling network drivers and hardware
      ethtool
      # Network discovery utility
      nmap
      # Set of small useful utilities that use the proc filesystem (such as fuser, killall and pstree)
      psmisc
      # Simplified and community-driven man pages
      tldr
    ];

    user.extraGroups = [ "admin" ];
  };
}
