{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.aerc;
in
{
  options.modules.home.aerc = {
    enable = mkBoolOpt false;
  };

  imports = [ ./config-symlinks.nix ];

  config = mkIf cfg.enable {
    modules.home.configSymlinks.enable = true;
    home.packages = with pkgs; [
      # TUI email client with vim keybindings
      aerc
      # Text based browser for displaying html emails
      w3m
    ];

    modules.home.configSymlinks.entries =
      map (name: "aerc/${name}") [
      # To import accounts, move accounts.conf to dir and chmod 600
      "binds.conf"
      "aerc.conf"
      "filters"
      "templates"
      ];
  };
}
