{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.immich;
  port = 2283;
  storagePath = "/var/lib/immich";
in
{
  options.modules.services.immich = {
    enable = mkBoolOpt false;
    openFirewall = mkBoolOpt true;
    storagePath = mkOpt types.str storagePath;
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        immich-server = {
          image = "ghcr.io/immich-app/immich-server:release";
          ports = [ "${toString port}:2283" ];
          volumes = [
            "${cfg.storagePath}:/usr/src/app/upload"
            "/etc/localtime:/etc/localtime:ro"
          ];
          environment = {
            IMMICH_PORT = "2283";
            DB_HOSTNAME = "127.0.0.1";
            DB_PORT = "5432";
            DB_USERNAME = "immich";
            DB_DATABASE_NAME = "immich";
            REDIS_HOSTNAME = "127.0.0.1";
            REDIS_PORT = "6379";
          };
          environmentFiles = [
            "/var/secrets/immich"
          ];
          autoStart = true;
        };

        immich-machine-learning = {
          image = "ghcr.io/immich-app/immich-machine-learning:release";
          volumes = [
            "${cfg.storagePath}/ml:/cache"
            "/etc/localtime:/etc/localtime:ro"
          ];
          environment = {
            IMMICH_MACHINE_LEARNING_PORT = "3003";
          };
          autoStart = true;
        };
      };
    };

    systemd.services."docker-immich-server".serviceConfig = {
      Group = "docker";
      StateDirectory = "immich";
      StateDirectoryMode = "0750";
    };

    systemd.services."docker-immich-machine-learning".serviceConfig = {
      Group = "docker";
      StateDirectory = "immich-ml";
      StateDirectoryMode = "0750";
    };

    services.redis.servers.immich = {
      enable = true;
      port = 6379;
    };

    services.postgresql = mkIf config.modules.services.postgresql.enable {
      ensureDatabases = mkAfter [ "immich" ];
      ensureUsers = mkAfter [{
        name = "immich";
        ensureDBOwnership = true;
      }];
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts =
      mkIf cfg.openFirewall [ port ];
  };
}
