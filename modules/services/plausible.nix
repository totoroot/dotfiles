{ pkgs, options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.plausible;
  domain = "xn--berwachungsbehr-mtb1g.de";
  adminEmail = "admin@thym.at";
  plausiblePort = 7129;
in
{
  options.modules.services.plausible = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      plausible = {
        enable = true;
        server = {
          baseUrl = "https://besucherinnen.${domain}";
          port = plausiblePort;
          secretKeybaseFile = "/var/secrets/plausible/keybase";
        };
      };

      nginx.virtualHosts = {
        "besucherinnen.${domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://localhost:${toString plausiblePort}";
            proxyWebsockets = true;
          };
        };
      };
    };

    security.acme = {
      acceptTerms = mkDefault true;
      certs = {
        "besucherinnen.${domain}" = {
          email = "${adminEmail}";
        };
      };
    };
  };
}
