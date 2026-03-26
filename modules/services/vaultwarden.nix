{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.vaultwarden;
  domain = "xn--berwachungsbehr-mtb1g.de";
  vaultwardenPort = 8222;
in
{
  options.modules.services.vaultwarden = {
    enable = mkBoolOpt false;

    databaseUrlFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to an environment file containing DATABASE_URL=...";
    };

    smtp = {
      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
      };
      port = mkOption {
        type = types.port;
        default = 25;
      };
      security = mkOption {
        type = types.enum [ "off" "starttls" "force_tls" ];
        default = "off";
      };
      from = mkOption {
        type = types.str;
        default = "vaultwarden@${domain}";
      };
      fromName = mkOption {
        type = types.str;
        default = "Vaultwarden";
      };
      username = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      passwordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
      };
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "vaultwarden" ];
      ensureUsers = [
        {
          name = "vaultwarden";
          ensureDBOwnership = true;
        }
      ];
    };

    services.vaultwarden = {
      enable = true;
      environmentFile = mkIf (cfg.databaseUrlFile != null) cfg.databaseUrlFile;
      dbBackend = "postgresql";
      config = {
        domain = "https://passwort.${domain}";
        signupsAllowed = false;
        smtpHost = cfg.smtp.host;
        smtpPort = cfg.smtp.port;
        smtpSecurity = cfg.smtp.security;
        smtpFrom = cfg.smtp.from;
        smtpFromName = cfg.smtp.fromName;
        websocketAddress = "0.0.0.0";
        # websocketPort = vaultwardenPort;
        rocketAddress = "0.0.0.0";
        rocketPort = vaultwardenPort;
        rocketLog = "critical";
      } // lib.optionalAttrs (cfg.databaseUrlFile == null) {
        databaseUrl = "postgresql:///vaultwarden?host=/run/postgresql";
      } // lib.optionalAttrs (cfg.smtp.username != null) {
        smtpUsername = cfg.smtp.username;
      } // lib.optionalAttrs (cfg.smtp.passwordFile != null) {
        smtpPasswordFile = cfg.smtp.passwordFile;
      };
    };

    systemd.services.vaultwarden-data-backup = {
      description = "Archive Vaultwarden data directory";
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        set -euo pipefail
        ts="$(date +%F-%H%M%S)"
        mkdir -p /var/backup/vaultwarden
        tar -C /var/lib -czf "/var/backup/vaultwarden/vw-data-$ts.tar.gz" vaultwarden
        find /var/backup/vaultwarden -maxdepth 1 -name 'vw-data-*.tar.gz' -mtime +14 -delete
      '';
    };

    systemd.timers.vaultwarden-data-backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };

    environment.systemPackages = [ config.services.vaultwarden.package ];
  };
}
