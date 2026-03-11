{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.paperless;
in
{
  options.modules.services.paperless = {
    enable = mkBoolOpt false;
    port = mkOption {
      type = types.int;
      default = 28981;
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_18;
      ensureDatabases = [ "paperless" ];
      ensureUsers = [
        {
          name = "paperless";
          ensureDBOwnership = true;
        }
      ];
    };

    services.paperless-ng = {
      enable = true;
      address = "0.0.0.0";
      port = cfg.port;
      dataDir = "/var/lib/paperless";
      mediaDir = "/var/lib/paperless/media";
      consumptionDir = "/var/lib/paperless/consume";
      consumptionDirIsPublic = false;
      passwordFile = "/var/secrets/paperless";
      extraConfig = {
        PAPERLESS_DBENGINE = "postgresql";
        PAPERLESS_DBHOST = "localhost";
        PAPERLESS_DBNAME = "paperless";
        PAPERLESS_DBUSER = "paperless";
        PAPERLESS_DBPORT = "5432";
      };
    };

    # Allow access only on LAN + Tailnet (for reverse proxy from jam)
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --source 10.0.0.0/24 --dport ${toString cfg.port} -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --source 100.64.0.0/10 --dport ${toString cfg.port} -j nixos-fw-accept
    '';
  };
}
