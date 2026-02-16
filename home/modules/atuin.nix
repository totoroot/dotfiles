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
    modules.home.configSymlinks.force = true;
    home.activation.ensureAtuinDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${config.home.homeDirectory}/.config/atuin"
    '';
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
