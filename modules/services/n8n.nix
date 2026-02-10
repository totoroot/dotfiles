{ pkgs, options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.n8n;
  domain = "xn--berwachungsbehr-mtb1g.de";
  adminEmail = "admin@thym.at";
  n8nPort = "5678";
in
{
  options.modules.services.n8n = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      n8n = {
        enable = true;
      };

      nginx.virtualHosts = {
        "n8n.${domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://localhost:${toString n8nPort}";
            proxyWebsockets = true;
          };
        };
      };
    };

    security.acme = {
      acceptTerms = mkDefault true;
      certs = {
        "n8n.${domain}" = {
          email = "${adminEmail}";
        };
      };
    };
  };
}
