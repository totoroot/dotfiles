{ config, lib, pkgs, ... }:

{
  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
    startAt = [ ]; # The Restic job starts the dump before uploading.
  };

  services.restic.backups.pantry = {
    repository = "sftp:u725720@u725720.your-storagebox.de:jam-restic";
    passwordFile = config.sops.secrets.restic-pantry-password.path;
    paths = [
      "/var/backup/postgresql/all.sql.gz"
      config.mailserver.storage.path
      config.services.nextcloud.datadir
      "/var/www"
      "/var/lib/vaultwarden"
      "/var/lib/wichtelwerkstatt"
    ];
    extraOptions = [
      ''"sftp.args=-p 22 -i /var/lib/restic-jam/key -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile=/var/lib/restic-jam/known_hosts"''
    ];
    timerConfig = {
      OnCalendar = "*-*-* 02:15:00 Europe/Vienna";
      Persistent = true;
    };
  };

  # A failed dump prevents Restic from starting, so monitor the dump directly too.
  systemd.services.postgresqlBackup.onFailure = [ "restic-pantry-notify.service" ];

  systemd.services.restic-backups-pantry = {
    requires = [ "postgresqlBackup.service" "sops-install-secrets.service" ];
    after = [ "postgresqlBackup.service" "sops-install-secrets.service" ];
    onFailure = [ "restic-pantry-notify.service" ];
    # Queue the heartbeat only after a successful upload, without gating the backup on it.
    serviceConfig.ExecStartPost = "-${lib.getExe' config.systemd.package "systemctl"} --no-block start restic-pantry-heartbeat.service";
  };

  systemd.services.restic-pantry-notify = {
    description = "Send an ntfy alert for a failed jam backup";
    unitConfig.ConditionPathExists = "/var/secrets/restic-pantry-ntfy.curl";
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = true;
      LoadCredential = "request:/var/secrets/restic-pantry-ntfy.curl";
      ExecStart = ''
        ${lib.getExe pkgs.curl} --disable --config %d/request --proto =https --fail --silent --show-error --output /dev/null --max-time 15 --retry 2 --retry-max-time 45 --header "Title: Jam backup failed" --data-binary "The PostgreSQL dump or Restic upload to pantry failed. Check the systemd journal on jam."
      '';
    };
  };

  systemd.services.restic-pantry-heartbeat = {
    description = "Report successful jam backup to an off-host monitor";
    unitConfig.ConditionPathExists = config.sops.secrets.restic-pantry-heartbeat-curl.path;
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = true;
      LoadCredential = "request:${config.sops.secrets.restic-pantry-heartbeat-curl.path}";
      ExecStart = ''
        ${lib.getExe pkgs.curl} --disable --config %d/request --proto =https --fail --silent --show-error --output /dev/null --max-time 15 --retry 2 --retry-max-time 45
      '';
    };
  };
}
