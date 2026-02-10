{ config, lib, ... }:

with lib;
let
  cfg = config.modules.nix.secrets;
in
{
  options.modules.nix.secrets = {
    enable = mkEnableOption "sops-nix secrets management";

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
    } // (mkIf (cfg.defaultFile != null) {
      defaultSopsFile = cfg.defaultFile;
    });
  };
}
