{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.nix.remoteBuilder;
in
{
  options.modules.nix.remoteBuilder = {
    enable = mkEnableOption "remote builder configuration";

    host = mkOption {
      type = types.str;
      default = "purple";
      description = "Hostname of the remote builder.";
    };

    user = mkOption {
      type = types.str;
      default = "builder";
      description = "SSH user used to connect to the remote builder.";
    };

    maxJobs = mkOption {
      type = types.int;
      default = 8;
      description = "Max jobs to run on the remote builder.";
    };

    speedFactor = mkOption {
      type = types.int;
      default = 2;
      description = "Relative speed factor for scheduling.";
    };

    supportedFeatures = mkOption {
      type = with types; listOf str;
      default = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      description = "Features supported by the remote builder.";
    };

    mandatoryFeatures = mkOption {
      type = with types; listOf str;
      default = [ "big-parallel" ];
      description = "Mandatory features required for scheduling builds on the remote builder.";
    };

    # Provide per-system builders, so we can map aarch64 hosts to the same
    # remote builder with aarch64 system entries (via qemu/binfmt on purple).
    systems = mkOption {
      type = with types; listOf str;
      default = [ "x86_64-linux" ];
      description = "Target systems this host should offload to the remote builder.";
    };

    enableCheck = mkOption {
      type = types.bool;
      default = false;
      description = "Enable a systemd timer to log a warning when the builder is unreachable.";
    };

    checkInterval = mkOption {
      type = types.str;
      default = "10min";
      description = "Systemd timer interval for the builder check.";
    };
  };

  config = mkIf cfg.enable {
    nix = {
      distributedBuilds = true;
      buildMachines =
        map (system: {
          hostName = cfg.host;
          sshUser = cfg.user;
          inherit system;
          protocol = "ssh-ng";
          maxJobs = cfg.maxJobs;
          speedFactor = cfg.speedFactor;
          supportedFeatures = cfg.supportedFeatures;
          mandatoryFeatures = cfg.mandatoryFeatures;
        }) cfg.systems;
      extraOptions = ''
        builders-use-substitutes = true
      '';
    };

    systemd.services.remote-builder-check = mkIf cfg.enableCheck {
      description = "Check remote builder availability";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.openssh}/bin/ssh -o BatchMode=yes -o ConnectTimeout=3 ${cfg.user}@${cfg.host} true >/dev/null 2>&1 || ${pkgs.util-linux}/bin/logger -t remote-builder \"WARNING: remote builder ${cfg.user}@${cfg.host} is unreachable\"'";
      };
    };

    systemd.timers.remote-builder-check = mkIf cfg.enableCheck {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnUnitActiveSec = cfg.checkInterval;
        AccuracySec = "1min";
      };
    };
  };
}
