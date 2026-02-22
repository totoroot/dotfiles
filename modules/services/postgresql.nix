{ options, config, lib, inputs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.postgresql;
  postgresqlPort = 5432;
in
{
  imports = [ inputs.pgweb.nixosModules.pgweb ];

  options.modules.services.postgresql = {
    enable = mkBoolOpt false;

    pgweb = {
      enable = mkBoolOpt false;
      port = mkOption {
        type = types.port;
        default = 8081;
        description = "pgweb listen port.";
      };
      bind = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = "pgweb bind address.";
      };
      database = mkOption {
        type = types.str;
        default = "postgres";
        description = "Default database name for pgweb.";
      };
    };
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

    services.pgweb = mkIf cfg.pgweb.enable {
      enable = true;
      environment = {
        PGWEB_DATABASE_URL = "postgres:///${cfg.pgweb.database}?host=/run/postgresql";
      };
      extraArgs = [
        "--bind" cfg.pgweb.bind
        "--listen" (toString cfg.pgweb.port)
      ];
    };

    networking.firewall.allowedTCPPorts = [
      config.services.postgresql.settings.port
    ] ++ lib.optional cfg.pgweb.enable cfg.pgweb.port;

    environment.systemPackages =
      [ config.services.postgresql.package ]
      ++ (with config.services.postgresql.package.pkgs; [ postgis ]);
  };
}
