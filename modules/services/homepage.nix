{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.homepage;
  domain = "xn--berwachungsbehr-mtb1g.de";
  port = 8082;
in
{
  options.modules.services.homepage = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      homepage-dashboard = {
        enable = true;
        listenPort = port;
        openFirewall = true;
      };

      nginx.virtualHosts."${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString port}";
          proxyWebsockets = true;
        };
      };
    };

    security.acme.certs."${domain}".email = "admin@thym.at";

    environment.systemPackages = [ config.services.homepage-dashboard.package ];
  };
}
