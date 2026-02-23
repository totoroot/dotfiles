{ config, lib, ... }:

with lib;
let
  cfg = config.modules.nix.secrets;
in
{
  options.modules.nix.secrets = {
    enable = mkEnableOption "sops-nix secrets management" // { default = true; };

    defaultFile = mkOption {
      type = with types; nullOr str;
      default = null;
      description = "Default SOPS file for this host (e.g. secrets/grape.yaml).";
    };

    ageKeyFile = mkOption {
      type = types.str;
      default = "/var/lib/sops-nix/${config.networking.hostName}.txt";
      description = "Path to the host age private key.";
    };
  };

  config = mkIf cfg.enable {
    sops = {
      age.keyFile = cfg.ageKeyFile;
      # Note: sops secrets are installed at activation time. Any config checks
      # that run during build (e.g. services.prometheus.checkConfig) cannot
      # read secrets from /var/secrets yet and may need to be disabled.
      useSystemdActivation = true;
    } // (mkIf (cfg.defaultFile != null) {
      defaultSopsFile = cfg.defaultFile;
    });
  };
}
