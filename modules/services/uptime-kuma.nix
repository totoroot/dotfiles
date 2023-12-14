{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.uptime-kuma;
  domain = "xn--berwachungsbehr-mtb1g.de";
  port = 4042;
in
{
  options.modules.services.uptime-kuma = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      uptime-kuma = {
        enable = true;
        settings = {
          PORT = "${toString port}";
        };
        appriseSupport = false;
      };

      nginx.virtualHosts."uptime.${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString port}";
          proxyWebsockets = true;
        };
      };
    };

    security.acme = {
      certs = {
        "uptime.xn--berwachungsbehr-mtb1g.de" = {
          email = "admin@thym.at";
        };
      };
    };

    environment.systemPackages = [ config.services.uptime-kuma.package ];
  };
}
