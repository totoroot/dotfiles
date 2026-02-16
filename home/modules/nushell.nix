{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.nushell;
in
{
  options.modules.home.nushell = {
    enable = mkBoolOpt false;
    plugins = mkOpt (listOf types.package) [ ];
  };

  imports = [ ./config-symlinks.nix ];

  config = mkIf cfg.enable {
    modules.home.configSymlinks.enable = true;

    modules.home.nushell.plugins = with pkgs.nushellPlugins; [
      # Git status plugin for Nushell
      gstat
      # Formats plugin for Nushell
      formats
      # Nushell plugin to query JSON, XML, and various web data
      query
      # Nushell plugin for easily converting between common units
      units
      # Nushell plugin to list system network interfaces
      net
    ];

    home.packages = with pkgs; [
      # Modern shell written in Rust
      nushell
      # Nushell formatter
      nufmt
    ] ++ cfg.plugins;

    modules.home.configSymlinks.entries =
      map (name: "nushell/${name}") [
        "config.nu"
        "env.nu"
      ];
  };
}
