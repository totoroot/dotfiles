{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.privatebin;
  domain = "xn--berwachungsbehr-mtb1g.de";
  userName = "privatebin";
  dataDir = "/var/lib/${userName}";
  host = "127.0.0.1";
  enableNginx = true;
  nginxEnableSSL = true;
  serverPath = "/";
  discussion = false;
  burnafterreadingSelected = false;
  defaultFormatter = "plaintext";
in
{
  options.modules.services.privatebin = {
    enable = mkBoolOpt false;

    serverHost = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "The full public domain of the PrivateBin server.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8086;
      description = "The port to run the PrivateBin server on.";
    };

    name = lib.mkOption {
      type = lib.types.str;
      default = "PrivateBin";
      description = "Name of this PrivateBin instance.";
    };

    sizeLimit = lib.mkOption {
      type = lib.types.str;
      default = "10MB";
      description = "Maximum paste size.";
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

    # PHP-FPM configuration for PrivateBin
    services.phpfpm.pools.${userName} = {
      user = userName;
      group = userName;
      settings = {
        listen = "${cfg.host}:9001";
        pm = "ondemand";
        "pm.max_children" = 5;
      };
      phpAdminValues = {
        "open_basedir" = cfg.dataDir;
        "upload_max_filesize" = cfg.sizeLimit;
        "post_max_size" = cfg.sizeLimit;
        "memory_limit" = "128M";
      };
    };

    systemd.services.privatebin = {
      enable = true;
      description = "PrivateBin encrypted pastebin service";
      restartIfChanged = true;
      after = [ "network.target" "php-fpm.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "5s";
        User = userName;
        Group = userName;
        WorkingDirectory = cfg.dataDir;
        Type = "simple";
        ExecStart = ''
          ${pkgs.php}/bin/php -S ${cfg.host}:${toString cfg.port} -t ${cfg.package}/cfg
        '';

        Environment = [
          "PRIVATEBIN_NAME=${cfg.name}"
          "PRIVATEBIN_DISCUSSION=${toString cfg.discussion}"
          "PRIVATEBIN_BURNAFTERREADINGSELECTED=${toString cfg.burnafterreadingSelected}"
          "PRIVATEBIN_DEFAULT_FORMATTER=${cfg.defaultFormatter}"
          "PRIVATEBIN_SIZE_LIMIT=${cfg.sizeLimit}"
        ];

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

    services.nginx = lib.mkIf enableNginx {
      enable = true;
      virtualHosts."${cfg.serverHost}" = {
        forceSSL = nginxEnableSSL;
        enableACME = nginxEnableSSL;
        locations = {
          "${cfg.serverPath}" = {
            proxyPass = "http://${host}:${toString cfg.port}";
            proxyWebsockets = true;
            extraConfig = ''
              # Increase client max body size to match PrivateBin limit
              client_max_body_size ${cfg.sizeLimit};

              # Security headers for PrivateBin
              add_header X-Frame-Options "SAMEORIGIN" always;
              add_header X-Content-Type-Options "nosniff" always;
              add_header Referrer-Policy "no-referrer" always;
              add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self'; frame-src 'self';" always;
            '';
          };
        };
      };
    };
  };
}
