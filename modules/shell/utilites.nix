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
      # Command line tool for the desktop trash can
      trash-cli
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
      # cat(1) clone with syntax highlighting and Git integration
      bat
      # Replacement for 'ls' written in Rust
      eza
      # Quick command-line access to files and directories for POSIX shells
      fasd
      # Intuitive sed alternative
      sd
      # Intuitive find alternative
      fd
      # Command-line fuzzy finder written in Go
      fzf
      # Set of small useful utilities that use the proc filesystem (such as fuser, killall and pstree)
      psmisc
      # Simplified and community-driven man pages
      tldr
    ];

    user.extraGroups = [ "admin" ];

    environment.shellAliases = {
      rm = "trash";
      rst = "trash-restore";
    };

    env = {
      FZF_DEFAULT_OPTS = "--reverse --ansi --inline-info --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4";
    };
  };
}
