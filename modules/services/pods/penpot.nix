# Based on penpot's docker-compose.yaml example
# https://github.com/penpot/penpot/blob/main/docker/images/docker-compose.yaml

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.pods.penpot;
in {
  options.modules.services.pods.penpot = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        "penpot-frontend" = {
          autoStart = true;
          image = "penpotapp/frontend:latest";
          dependsOn = [
            "penpot-backend"
            "penpot-exporter"
          ];
          ports = [
            "9001:80"
          ];
          volumes = [
            "/var/cache/penpot/data:/opt/data"
          ];
          environmentFiles = [
            "/var/cache/penpot/config.env"
          ];
          extraOptions = [
            "--network=penpot"
          ];
        };
        "penpot-backend" = {
          autoStart = true;
          image = "penpotapp/backend:latest";
          dependsOn = [
            "penpot-postgres"
            "penpot-redis"
          ];
          volumes = [
            "/var/cache/penpot/data:/opt/data"
          ];
          environmentFiles = [
            "/var/cache/penpot/config.env"
          ];
          extraOptions = [
            "--network=penpot"
          ];
        };
        "penpot-exporter" = {
          autoStart = true;
          image = "penpotapp/exporter:latest";
          environment = {
            PENPOT_PUBLIC_URI = "http://penpot-frontend";
          };
          environmentFiles = [
            "/var/cache/penpot/config.env"
          ];
          extraOptions = [
            "--network=penpot"
          ];
        };
        "penpot-postgres" = {
          autoStart = true;
          image = "postgres:13";
          volumes = [
            "/var/cache/penpot/postgres/data:/var/lib/postgresql/data"
          ];
          environment = {
            POSTGRES_INITDB_ARGS = "--data-checksums";
            POSTGRES_DB = "penpot";
            POSTGRES_USER = "penpot";
            POSTGRES_PASSWORD = "penpot";
          };
          extraOptions = [
            "--network=penpot"
            # TODO stop signal = SIGINT ???
          ];
        };
        "penpot-redis" = {
          autoStart = true;
          image = "redis:6";
          extraOptions = [
            "--network=penpot"
          ];
        };
      };
    };
    systemd.services = {
      docker-penpot-postgres.serviceConfig = {
        User = "mathym";
        Group = "docker";
        CacheDirectory = "penpot/postgres";
        CacheDirectoryMode = "0750";
      };
    };
  };
}
