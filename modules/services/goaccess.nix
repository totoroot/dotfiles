{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.goaccess;
  domain = "xn--berwachungsbehr-mtb1g.de";
  userName = cfg.userName;
  nginxCfg = config.services.nginx;
in
{
  options.modules.services.goaccess = {
    enable = mkBoolOpt false;

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.goaccess;
      description = "The GoAccess package.";
    };

    userName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "goaccess";
      description = "The username to use for running the GoAccess service.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/${userName}";
      description = "The directory in which the GoAccess data is saved.";
    };

    dataRetentionDays = lib.mkOption {
      type = lib.types.int;
      default = 7;
      description = "The number of days for which the GoAccess server retains the report data.";
    };

    reportDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/www/${userName}";
      description = "The directory in which the GoAccess report file is saved.";
    };

    host = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "127.0.0.1";
      description = "The host to run the GoAccess server on.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 7890;
      description = "The port to run the GoAccess server on.";
    };

    logFilePath = lib.mkOption {
      type = lib.types.path;
      description = "The full path to the log file to analyze.";
    };

    logFileFormat = lib.mkOption {
      type = lib.types.enum [
        "COMBINED"
        "VCOMBINED"
        "COMMON"
        "VCOMMON"
        "W3C"
        "SQUID"
        "CLOUDFRONT"
        "CLOUDSTORAGE"
        "AWSELB"
        "AWSS3"
        "AWSALB"
        "CADDY"
        "TRAEFIKCLF"
      ];
      description = "The format of the log file to analyze.";
    };

    reportTitle = lib.mkOption {
      type = lib.types.nullOr lib.types.nonEmptyStr;
      default = null;
      description = "The title of the report webpage.";
    };

    enableNginx = lib.mkEnableOption ''
      Nginx as the reverse proxy for the GoAccess server. If enabled, an Nginx virtual host will
      be created for access to the GoAccess server'';

    nginxEnableSSL = lib.mkEnableOption "SSL for the Nginx reverse proxy";

    serverHost = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "The full public domain of the GoAccess server.";
    };

    serverPath = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The path component URL of the GoAccess server. Must be an empty string or end with '/'.";
    };
  };

  config = mkIf cfg.enable {
    # assertions = [
    #    {
    #      assertion = cfg.serverPath == "" || lib.strings.hasSuffix "/" cfg.serverPath;
    #      message = "The serverPath option is neither an empty string, nor ends with '/'.";
    #    }
    #  ];

     users.users.${userName} = {
       isSystemUser = true;
       group = userName;
       home = cfg.dataDir;
       createHome = true;
     };
     users.groups.${userName} = { };
     users.users."${nginxCfg.user}" = lib.mkIf cfg.enableNginx {
       extraGroups = [ userName ];
     };

     systemd.tmpfiles.rules = [
       "d ${cfg.reportDir}/ 750 ${userName} ${userName}"
       "Z ${cfg.reportDir} 750 ${userName} ${userName}"
     ];

     systemd.services.goaccess = {
       enable = true;
       description = "GoAccess real-time dashboard service";
       restartIfChanged = true;
       restartTriggers = [ pkgs.goaccess ];
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
           ${cfg.package}/bin/goaccess --log-file=${cfg.logFilePath} --log-format=${cfg.logFileFormat} \
             --anonymize-ip --persist --restore --db-path=${cfg.dataDir} --keep-last=${toString cfg.dataRetentionDays} \
             --all-static-files --real-time-html \
             ${if cfg.reportTitle != null then "--html-report-title=\"${cfg.reportTitle}\"" else ""} \
             --output=${cfg.reportDir}/index.html --addr=127.0.0.1 --port=${toString cfg.port} \
             --ws-url=wss://${cfg.serverHost}:443/${cfg.serverPath}ws --origin=https://${cfg.serverHost}'';

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
           "/${cfg.serverPath}" = {
             alias = "${cfg.reportDir}/";
             extraConfig = ''
               add_header Cache-Control 'private no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0';
               if_modified_since off;
               expires off;
               etag off;
             '';
           };
           "/${cfg.serverPath}ws" = {
             proxyPass = "http://127.0.0.1:${toString cfg.port}";
             proxyWebsockets = true;
           };
         };
       };
    };
  };
}
