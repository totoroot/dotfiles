# modules/shell/borg.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.borg;
in {
  options.modules.shell.borg = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Deduplicating archiver with compression and encryption
      borgbackup
      # Simple, configuration-driven backup software for servers and workstations
      borgmatic
    ];

    home.configFile = {
      "borgmatic/config.yaml".source = "${configDir}/borg/config.yaml";
      "borg/keys/backup-purple.key".source = "${configDir}/borg/keys/backup-purple.key";
    };
  };
}
