{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.postgresql;
  postgresqlPort = 5432;
in
{
  options.modules.services.postgresql = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      postgresql = {
        enable = true;
        settings.port = postgresqlPort;
        ensureDatabases = [
          "vaultwarden"
          "hass"
          "forgejo"
          "nextcloud"
        ];
        ensureUsers = [
          {
            name = "hass";
            ensureDBOwnership = true;
          }
          {
            name = "vaultwarden";
            ensureDBOwnership = true;
          }
        ];
        enableTCPIP = true;
      };
      postgresqlBackup.enable = true;
    };

    networking.firewall.allowedTCPPorts = [ config.services.postgresql.settings.port ];

    environment.systemPackages = [ config.services.postgresql.package ];
  };
}
