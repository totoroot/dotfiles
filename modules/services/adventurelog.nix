{ options, config, lib, inputs, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.adventurelog;
  domain = "xn--berwachungsbehr-mtb1g.de";
  frontendHost = "reise.${domain}";
  backendHost = "reise-api.${domain}";
in
{
  options.modules.services.adventurelog = {
    enable = mkBoolOpt false;
  };

  imports = [
    inputs.adventurelog.nixosModules.adventurelog
  ];

  config = mkIf cfg.enable {
    services.adventurelog = {
      enable = true;
      nginx.enable = true;
      nginx.port = 2026;
      nginx.hostName = backendHost;
      nginx.frontendHostName = frontendHost;
      backend.publicUrl = "https://${backendHost}";
      backend.frontendUrl = "https://${frontendHost}";
      frontend.origin = "https://${frontendHost}";
      frontend.publicServerUrl = "https://${backendHost}";
      database.createLocally = true;
    };

    services.postgresql.package = lib.mkForce pkgs.postgresql_16;

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
      config.services.adventurelog.nginx.port
    ];
  };
}
