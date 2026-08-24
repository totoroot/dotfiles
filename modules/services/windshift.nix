{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.windshift;
  toEnvironment = mapAttrs (_: value: if isBool value then boolToString value else toString value);
  runtimeDir = "/run/${cfg.user}";
in
{
  options.modules.services.windshift = {
    enable = mkBoolOpt false;

    package = mkOption {
      type = types.package;
      default = inputs.self.packages.${pkgs.system}.windshift;
      description = "Windshift package to run.";
    };

    user = mkOption {
      type = types.str;
      default = "windshift";
      description = "System user running Windshift.";
    };

    group = mkOption {
      type = types.str;
      default = cfg.user;
      description = "Primary group of the Windshift system user.";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "TCP port on which Windshift listens.";
    };

    baseUrl = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "https://windshift.example.com";
      description = "Externally visible Windshift URL. Required for a production reverse-proxy deployment.";
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/${cfg.user}";
      description = "Directory holding the SQLite database, attachments, plugins, and prompt overrides.";
    };

    environmentFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        File containing extra Windshift environment variables. It must provide
        SSO_SECRET (or SESSION_SECRET); systemd reads it without exposing its
        contents in the Nix store.
      '';
    };

    settings = mkOption {
      type = types.attrsOf (types.oneOf [ types.bool types.int types.str ]);
      default = { };
      example = {
        USE_PROXY = true;
        LOG_FORMAT = "json";
        DB_TYPE = "postgres";
        POSTGRES_CONNECTION_STRING = "postgresql:///windshift?host=/run/postgresql";
      };
      description = "Additional Windshift environment variables. Values override module defaults.";
    };

    memoryLimitMB = mkOption {
      type = types.ints.positive;
      default = 2048;
      description = "Windshift process memory budget in MiB.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.environmentFile != null;
        message = "modules.services.windshift.environmentFile must provide SSO_SECRET or SESSION_SECRET.";
      }
    ];

    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      isSystemUser = true;
      inherit (cfg) group;
      home = cfg.stateDir;
      createHome = true;
    };

    systemd.tmpfiles.rules = map (path: "d ${path} 0750 ${cfg.user} ${cfg.group} -") [
      cfg.stateDir
      "${cfg.stateDir}/attachments"
      "${cfg.stateDir}/plugins"
      "${cfg.stateDir}/prompts"
    ];

    systemd.services.windshift = {
      description = "Windshift work management platform";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = toEnvironment ({
        PORT = cfg.port;
        DB_PATH = "${cfg.stateDir}/windshift.db";
        ATTACHMENT_PATH = "${cfg.stateDir}/attachments";
        PLUGIN_DIR = "${cfg.stateDir}/plugins";
        AI_PROMPTS_DIR = "${cfg.stateDir}/prompts";
        TMPDIR = runtimeDir;
        SQLITE_TMPDIR = runtimeDir;
        WINDSHIFT_MEMORY_LIMIT_MB = cfg.memoryLimitMB;
      } // optionalAttrs (cfg.baseUrl != null) { BASE_URL = cfg.baseUrl; } // cfg.settings);

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.stateDir;
        ExecStart = "${cfg.package}/bin/windshift";
        EnvironmentFile = optional (cfg.environmentFile != null) cfg.environmentFile;
        RuntimeDirectory = cfg.user;
        RuntimeDirectoryMode = "0750";
        Restart = "on-failure";
        RestartSec = "5s";
        LimitNOFILE = 65536;
        MemoryMax = "${toString cfg.memoryLimitMB}M";

        CapabilityBoundingSet = "";
        DevicePolicy = "closed";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ cfg.stateDir runtimeDir ];
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
      };
    };
  };
}
