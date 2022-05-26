# modules/desktop/backup.nix

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.backup;
in {
  options.modules.desktop.backup = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Simple backups based on borg
      pika-backup
      # Desktop Backup Client for Borg
      vorta
    ];
  };
}
