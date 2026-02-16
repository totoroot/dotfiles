{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.borg;
in
{
  options.modules.home.borg = {
    enable = mkBoolOpt false;
  };

  imports = [ ./config-symlinks.nix ];

  config = mkIf cfg.enable {
    modules.home.configSymlinks.enable = true;

    home.packages = with pkgs; [
      # Deduplicating archiver with compression and encryption
      borgbackup
      # Simple, configuration-driven backup software for servers and workstations
      borgmatic
    ];

    modules.home.configSymlinks.entries = [
      "borg/config.yaml"
      "borg/keys/backup-purple.key"
    ];
  };
}
