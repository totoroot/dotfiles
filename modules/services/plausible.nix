{ pkgs, options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.plausible;
  domain = "xn--berwachungsbehr-mtb1g.de";
  adminEmail = "admin@thym.it";
  plausiblePort = 7129;
in
{
  options.modules.services.plausible = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      postgresql = mkIf config.modules.services.postgresql.enable {
        ensureDatabases = mkAfter [ "plausible" ];
        ensureUsers = mkAfter [
          {
            name = "plausible";
            ensureDBOwnership = true;
          }
        ];
      };

      plausible = {
        enable = true;
        server = {
          baseUrl = "https://besucherinnen.${domain}";
          disableRegistration = true;
          listenAddress = "127.0.0.1";
          port = plausiblePort;
          secretKeybaseFile = "/var/secrets/plausible/keybase";
        };
        mail = {
          email = "admin@überwachungsbehör.de";
          smtp = {
            hostAddr = "127.0.0.1";
            hostPort = 25;
            enableSSL = false;
            retries = 3;
          };
        };
        database = {
          postgres = {
            socket = "/run/postgresql";
            dbname = "plausible";
            setup = false;
          };
          clickhouse.setup = true;
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
