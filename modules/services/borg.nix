# modules/services/borg.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.borg;
in {
  options.modules.services.borg = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Deduplicating archiver with compression and encryption
      borgbackup
      # Simple, configuration-driven backup software for servers and workstations
      borgmatic
      # Simple backups based on borg
      pika-backup
      # Desktop Backup Client for Borg
      vorta
    ];

    home.configFile = {
      "borgmatic/config.yaml".source = "${configDir}/borg/config.yaml";
      "borg/keys/backup-purple.key".source = "${configDir}/borg/keys/backup-purple.key";
    };
  };
}
