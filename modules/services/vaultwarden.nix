{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.vaultwarden;
  domain = "xn--berwachungsbehr-mtb1g.de";
  vaultwardenPort = 8222;
in
{
  options.modules.services.vaultwarden = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      # backupDir = ;
      config = {
        domain = "https://vault.${domain}";
        signupsAllowed = false;
        databaseUrl = "postgresql://vaultwarden@%2Frun%2Fpostgresql/vaultwarden";
        websocketAddress = "0.0.0.0";
        # websocketPort = vaultwardenPort;
        rocketAddress = "0.0.0.0";
        rocketPort = vaultwardenPort;
        rocketLog = "critical";
      };
    };

    networking.firewall.allowedTCPPorts = [ vaultwardenPort ];

    environment.systemPackages = [ config.services.vaultwarden.package ];
  };
}
