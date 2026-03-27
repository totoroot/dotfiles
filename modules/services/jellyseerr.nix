{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.jellyseerr;
in
{
  options.modules.services.jellyseerr = {
    enable = mkBoolOpt false;
    openFirewall = mkBoolOpt true;
    port = mkOpt types.port 5055;

    database = {
      name = mkOpt types.str "jellyseerr";
      user = mkOpt types.str "jellyseerr";
      socketPath = mkOpt types.str "/run/postgresql";
      logQueries = mkBoolOpt false;
    };
  };

  config = mkIf cfg.enable {
    services.jellyseerr.enable = true;

    # Configure Jellyseerr to use local PostgreSQL via unix socket.
    systemd.services.jellyseerr.environment = {
      DB_TYPE = "postgres";
      DB_SOCKET_PATH = cfg.database.socketPath;
      DB_USER = cfg.database.user;
      DB_NAME = cfg.database.name;
      DB_LOG_QUERIES = boolToString cfg.database.logQueries;
    };

    services.postgresql = mkIf config.modules.services.postgresql.enable {
      ensureDatabases = mkAfter [ cfg.database.name ];
      ensureUsers = mkAfter [
        {
          name = cfg.database.user;
          ensureDBOwnership = true;
        }
      ];
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
  };
}
