{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.snowflake;
in {
  options.modules.services.snowflake = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    containers.snowflake = {
      autoStart = true;
      ephemeral = true;
      config = {
        systemd.services.snowflake = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            IPAccounting = "yes";
            ExecStart = "${pkgs.snowflake}/bin/proxy";
            DynamicUser = "yes";
            # Read-only filesystem
            ProtectSystem = "strict";
            PrivateDevices = "yes";
            ProtectKernelTunables = "yes";
            ProtectControlGroups = "yes";
            ProtectHome = "yes";
            # Deny access to as many things as possible
            NoNewPrivileges = "yes";
            PrivateUsers = "yes";
            LockPersonality = "yes";
            MemoryDenyWriteExecute = "yes";
            ProtectClock = "yes";
            ProtectHostname = "yes";
            ProtectKernelLogs = "yes";
            ProtectKernelModules = "yes";
            RestrictAddressFamilies = "AF_INET AF_INET6";
            RestrictNamespaces = "yes";
            RestrictRealtime = "yes";
            RestrictSUIDSGID = "yes";
            SystemCallArchitectures = "native";
            SystemCallFilter = "~@chown @clock @cpu-emulation @debug @module @mount @obsolete @raw-io @reboot @setuid @swap @privileged @resources";
            CapabilityBoundingSet = "";
            ProtectProc = "invisible";
            ProcSubset = "pid";
          };
        };
      };
    };
  };
}
