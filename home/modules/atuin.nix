{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.atuin;
in
{
  options.modules.home.atuin = {
    enable = mkBoolOpt false;
  };

  imports = [ ./config-symlinks.nix ];

  config = mkIf cfg.enable {
    modules.home.configSymlinks.enable = true;
    home.packages = with pkgs; [
      # Replacement for a shell history which records additional commands
      # context with optional encrypted synchronization between machines
      atuin
    ];

    modules.home.configSymlinks.entries =
      map (name: "atuin/${name}") [
        "config.toml"
      ];
  };
}
