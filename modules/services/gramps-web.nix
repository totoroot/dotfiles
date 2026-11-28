{ config, lib, ... }:

let
  cfg = config.modules.services.gramps-web;
  podman = lib.getExe config.virtualisation.podman.package;
  network = "gramps-web";
  stateDir = if cfg.postgresql.enable then "/var/lib/gramps-web-postgresql" else "/var/lib/gramps-web";
  volumes = {
    users = "/app/users";
    index = "/app/indexdir";
    thumbnails = "/app/thumbnail_cache";
    cache = "/app/cache";
    secret = "/app/secret";
    trees = "/root/.gramps/grampsdb";
    media = "/app/media";
  };
  broker = if cfg.postgresql.enable then "redis://127.0.0.1:16385" else "redis://gramps-web-valkey:6379";
  appUnit = {
    # Recreate bind-mount sources even when the boot-time tmpfiles unit has
    # already run or the service is being restarted during activation.
    preStart = lib.mkBefore ''
      ${lib.getExe' config.systemd.package "systemd-tmpfiles"} --create --prefix=/run/gramps-web --prefix=${stateDir}
    '';
  } // lib.optionalAttrs cfg.postgresql.enable {
    requires = [ "postgresql-setup.service" ];
    after = [ "postgresql-setup.service" ];
  };
  networkOptions = [ "--network=${network}" ];
  app = {
    image = "ghcr.io/gramps-project/grampsweb:26.11.3@sha256:bf672745c0428ec37f398f51a89e07a0dabe4f2abc1038fd0952e358ae0228a3";
    environment = {
      GRAMPSWEB_TREE = "Gramps Web";
      GRAMPSWEB_BASE_URL = "http://localhost:${toString cfg.port}";
      GRAMPSWEB_CELERY_CONFIG__broker_url = "${broker}/0";
      GRAMPSWEB_CELERY_CONFIG__result_backend = "${broker}/0";
      GRAMPSWEB_RATELIMIT_STORAGE_URI = "${broker}/1";
      GRAMPSWEB_DISABLE_TELEMETRY = "true";
      GUNICORN_NUM_WORKERS = "2";
    } // lib.optionalAttrs cfg.postgresql.enable {
      GRAMPSWEB_TREE = "*";
      GRAMPSWEB_NEW_DB_BACKEND = "sharedpostgresql";
      GRAMPSWEB_MEDIA_PREFIX_TREE = "true";
      GRAMPSWEB_POSTGRES_HOST = "127.0.0.1";
      GRAMPSWEB_POSTGRES_PORT = toString config.services.postgresql.settings.port;
      GRAMPSWEB_POSTGRES_USER = "gramps";
      GRAMPSWEB_REGISTRATION_DISABLED = "true";
    };
    environmentFiles = lib.optional cfg.postgresql.enable cfg.postgresql.environmentFile;
    volumes = lib.mapAttrsToList (name: mount: "${stateDir}/${name}:${mount}") volumes
      ++ [ "/run/gramps-web/tmp:/tmp" ];
    # Gramps builds TCP URLs internally. Keep PostgreSQL bound to loopback.
    extraOptions = if cfg.postgresql.enable then [ "--network=host" ] else networkOptions;
  };
in
{
  options.modules.services.gramps-web = {
    enable = lib.mkEnableOption "Gramps Web on a private Podman network";
    port = lib.mkOption {
      type = lib.types.port;
      default = 5085;
      description = "Loopback port for the Gramps Web UI and API.";
    };
    postgresql = {
      enable = lib.mkEnableOption "SharedPostgreSQL with a separate Gramps Web state directory";
      environmentFile = lib.mkOption {
        type = lib.types.str;
        description = "Runtime environment file with the Gramps PostgreSQL password and user database URI.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.virtualisation.podman.enable && config.virtualisation.oci-containers.backend == "podman";
        message = "Gramps Web requires Podman as the OCI container backend.";
      }
      {
        assertion = !cfg.postgresql.enable || (config.services.postgresql.enable && config.services.postgresql.settings.listen_addresses != "");
        message = "Gramps Web's PostgreSQL mode requires the local PostgreSQL TCP listener.";
      }
    ];

    systemd.services.podman-gramps-web = appUnit;
    systemd.services.podman-gramps-web-worker = appUnit;

    systemd.tmpfiles.rules = [
      "d ${stateDir} 0700 root root -"
      "d /run/gramps-web 0700 root root -"
      "d /run/gramps-web/tmp 1777 root root -"
    ] ++ map (name: "d ${stateDir}/${name} 0700 root root -") (builtins.attrNames volumes);

    systemd.services.gramps-web-network = {
      description = "Create the Gramps Web Podman network";
      after = [ "systemd-tmpfiles-setup.service" ];
      requiredBy = [ "podman-gramps-web-valkey.service" "podman-gramps-web.service" "podman-gramps-web-worker.service" ];
      before = [ "podman-gramps-web-valkey.service" "podman-gramps-web.service" "podman-gramps-web-worker.service" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      script = ''
        if ! ${podman} network exists ${network}; then
          ${podman} network create ${network}
        fi
      '';
    };

    virtualisation.oci-containers.containers = {
      gramps-web-valkey = {
        image = "docker.io/valkey/valkey:8-alpine@sha256:9971099af41c36e887aabdfe22b80c0fe45df949163dfc9cb434febc57cfc3fc";
        extraOptions = networkOptions;
        ports = lib.optional cfg.postgresql.enable "127.0.0.1:16385:6379";
      };
      gramps-web = app // {
        dependsOn = [ "gramps-web-valkey" ];
        ports = lib.optional (!cfg.postgresql.enable) "127.0.0.1:${toString cfg.port}:5000";
      } // lib.optionalAttrs cfg.postgresql.enable {
        cmd = [ "gunicorn" "-w" "2" "-b" "127.0.0.1:${toString cfg.port}" "gramps_webapi.wsgi:app" "--timeout" "120" "--limit-request-line" "8190" "--preload" ];
      };
      gramps-web-worker = app // {
        dependsOn = [ "gramps-web" "gramps-web-valkey" ];
        cmd = [ "celery" "-A" "gramps_webapi.celery" "worker" "--loglevel=INFO" "--concurrency=2" ];
      };
    };
  };
}
