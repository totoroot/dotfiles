{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.rustypaste;
  domain = "thym.it";
  userName = "rustypaste";
  dataDir = "/var/lib/${userName}";
  host = "127.0.0.1";
  enableNginx = true;
  nginxEnableSSL = true;
  serverPath = "/";
in
{
  options.modules.services.rustypaste = {
    enable = mkBoolOpt false;

    serverHost = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "The full public domain of the RustyPaste server.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8085;
      description = "The port to run the RustyPaste server on.";
    };

    maxFileSize = lib.mkOption {
      type = lib.types.str;
      default = "50MB";
      description = "Maximum file size for uploads.";
    };
  };

  config = mkIf cfg.enable {
    users.users.${userName} = {
      isSystemUser = true;
      group = userName;
      home = cfg.dataDir;
      createHome = true;
    };
    users.groups.${userName} = { };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${userName} ${userName}"
      "Z ${cfg.dataDir} 750 ${userName} ${userName}"
    ];

    systemd.services.rustypaste = {
      enable = true;
      description = "RustyPaste file upload/pastebin service";
      restartIfChanged = true;
      restartTriggers = [ pkgs.rustypaste ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "5s";
        User = userName;
        Group = userName;
        WorkingDirectory = cfg.dataDir;
        Type = "simple";
        ExecStart = ''
          ${cfg.package}/bin/rustypaste \
            --host ${cfg.host} \
            --port ${toString cfg.port} \
            --data-dir ${cfg.dataDir} \
            --max-file-size ${cfg.maxFileSize}
        '';

        AmbientCapabilities = [ ];
        CapabilityBoundingSet = [
          "~CAP_RAWIO"
          "~CAP_MKNOD"
          "~CAP_AUDIT_CONTROL"
          "~CAP_AUDIT_READ"
          "~CAP_AUDIT_WRITE"
          "~CAP_SYS_BOOT"
          "~CAP_SYS_TIME"
          "~CAP_SYS_MODULE"
          "~CAP_SYS_PACCT"
          "~CAP_LEASE"
          "~CAP_LINUX_IMMUTABLE"
          "~CAP_IPC_LOCK"
          "~CAP_BLOCK_SUSPEND"
          "~CAP_WAKE_ALARM"
          "~CAP_SYS_TTY_CONFIG"
          "~CAP_MAC_ADMIN"
          "~CAP_MAC_OVERRIDE"
          "~CAP_NET_ADMIN"
          "~CAP_NET_BROADCAST"
          "~CAP_NET_RAW"
          "~CAP_SYS_ADMIN"
          "~CAP_SYS_PTRACE"
          "~CAP_SYSLOG"
        ];
        DevicePolicy = "closed";
        KeyringMode = "private";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "full";
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
      };
    };

    services.nginx = lib.mkIf cfg.enableNginx {
      enable = true;
      virtualHosts."${cfg.serverHost}" = {
        forceSSL = cfg.nginxEnableSSL;
        enableACME = cfg.nginxEnableSSL;
        locations = {
          "${cfg.serverPath}" = {
            proxyPass = "http://${cfg.host}:${toString cfg.port}";
            proxyWebsockets = true;
            extraConfig = ''
              # Increase client max body size to match RustyPaste limit
              client_max_body_size ${cfg.maxFileSize};
            '';
          };
        };
      };
    };
  };
}
