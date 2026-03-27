{ config, options, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.nginx;

  domain = "xn--berwachungsbehr-mtb1g.de";
  thymDomain = "thym.at";
  thymITDomain = "thym.it";
  nixosDomain = "nixos.at";
  theaterDomain = "theaterschaffen.de";
  praxisDomain = "grueneis-psychologie.at";
  womanMadeDomain = "womanma.de";

  adminEmail = "admin@thym.at";

  acmeWildcardCertName = domain;
  acmeChallengeWebroot = "/var/lib/acme/acme-challenge";

  server = "100.64.0.3";

  # jam
  homepagePort = 8082;
  uptimePort = 4042;
  ntfyPort = 6780;
  vaultwardenPort = 8222;
  # violet
  jellyfinPort = 8096;
  jellyseerrPort = 5055;
  grafanaPort = 3000;
  prometheusPort = 9090;
  lokiPort = 3100;
  hassPort = 8123;
  scrutinyPort = 9080;
  immichPort = 2283;
  recipePort = 8491;
  adguardHTTPPort = 3300;
  esphomePort = 6052;
  changedetectionPort = 5002;
  adventurelogPort = 2104;
  adventurelogBackendProxyPort = 2026;
in
{
  options.modules.services.nginx = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;

      # Enable the NGINX status page
      statusPage = true;

      # Use recommended settings
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = {
        "_" = {
          default = true;
          forceSSL = true;
          useACMEHost = acmeWildcardCertName;
          globalRedirect = domain;
        };
        "${domain}" = {
          useACMEHost = acmeWildcardCertName;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:${toString homepagePort}";
            proxyWebsockets = true;
          };
          serverAliases = [ "www.${domain}" ];
        };
        "${thymDomain}" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/thym.at";
        };
        "matthias.${thymDomain}" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/matthias.thym.at";
        };
        "${thymITDomain}" = {
          forceSSL = true;
          useACMEHost = thymITDomain;
          serverAliases = [ "www.${thymITDomain}" ];
          globalRedirect = "matthias.${thymDomain}";
        };
        "blog.${thymDomain}" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/blog.thym.at";
        };
        "${nixosDomain}" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/nixos.at";
        };
        # jam
        # "liebes.${domain}" = {
        #   enableACME = true;
        #   forceSSL = true;
        #   root = "/var/www/liebe";
        # };
        "kuh.${domain}" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/kuh";
        };
        "benachrichtigungs.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:${toString ntfyPort}";
            proxyWebsockets = true;
          };
        };
        "headscale.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:${toString config.services.headscale.port}";
            proxyWebsockets = true;
          };
        };
        "uptime.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            extraConfig = ''
              proxy_pass http://localhost:${toString uptimePort};
              proxy_set_header Host $host;
              proxy_redirect http:// https://;
              proxy_http_version 1.1;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection $connection_upgrade;
            '';
          };
        };
        # violet
        "medien.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${server}:${toString jellyfinPort}";
            proxyWebsockets = true;
          };
        };
        "jellyfin.${domain}" = {
          enableACME = true;
          forceSSL = true;
          globalRedirect = "medien.${domain}";
        };
        "seerr.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${server}:${toString jellyseerrPort}";
            proxyWebsockets = true;
          };
        };
        "grafana.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:${toString grafanaPort}";
            proxyWebsockets = true;
          };
        };
        "prometheus.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:${toString prometheusPort}";
            proxyWebsockets = true;
          };
        };
        # "zugriffs.${domain}" = {
        #   enableACME = true;
        #   forceSSL = true;
        #   locations."/" = {
        #     root = "/var/www/goaccess";
        #     basicAuthFile = "/var/secrets/goaccess";
        #   };
        # };
        "loki.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${server}:${toString lokiPort}";
            proxyWebsockets = true;
          };
        };
        "foto.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${server}:${toString immichPort}";
            proxyWebsockets = true;
          };
        };
        "reise.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/" = {
              proxyPass = "http://${server}:${toString adventurelogPort}";
              recommendedProxySettings = true;
              proxyWebsockets = true;
            };
          };
        };
        "reise-api.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/" = {
              proxyPass = "http://${server}:${toString adventurelogBackendProxyPort}";
              recommendedProxySettings = true;
              proxyWebsockets = true;
            };
          };
        };
        "passwort.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:${toString vaultwardenPort}";
            proxyWebsockets = true;
            # basicAuthFile = "/var/secrets/vaultwarden";
          };
        };
        "festplatten.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${server}:${toString scrutinyPort}";
            proxyWebsockets = true;
          };
        };
        "rezept.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${server}:${toString recipePort}";
            proxyWebsockets = true;
          };
        };
        "anzeigen.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${server}:${toString adguardHTTPPort}";
            proxyWebsockets = true;
          };
        };
        "dns.${domain}" = {
          enableACME = true;
          forceSSL = true;
          globalRedirect = "anzeigen.${domain}";
        };
        "iot.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${server}:${toString esphomePort}";
            proxyWebsockets = true;
          };
        };
        "hass.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            extraConfig = ''
              proxy_pass http://${server}:${toString hassPort};
              proxy_set_header Host $host;
              proxy_redirect http:// https://;
              proxy_http_version 1.1;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection $connection_upgrade;
            '';
          };
        };
        "website.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            extraConfig = ''
              proxy_pass http://${server}:${toString changedetectionPort};
              proxy_set_header Host $host;
              proxy_redirect http:// https://;
              proxy_http_version 1.1;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection $connection_upgrade;
              # proxy_set_header X-Forwarded-Prefix /changedetection/;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };
        "${theaterDomain}" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/theaterschaffen";
          serverAliases = [ "www.${theaterDomain}" ];
        };
        "die.${theaterDomain}" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/julia";
        };
        "der.${theaterDomain}" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/fabian";
        };
        "${praxisDomain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            root = "/var/www/praxis";
          };
          serverAliases = [ "www.${praxisDomain}" ];
        };
        "konzept.${praxisDomain}" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/grueneis-psychologie.at";
        };
        "${womanMadeDomain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            root = "/var/www/womanmade";
          };
          serverAliases = [ "www.${womanMadeDomain}" ];
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 80 443 ];
    };

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "${adminEmail}";
        # Force public LE CA; prevents accidental local minica cert issuance.
        server = "https://acme-v02.api.letsencrypt.org/directory";
      };
    };

    security.acme.certs."${acmeWildcardCertName}" = {
      domain = domain;
      extraDomainNames = [ "*.${domain}" ];
      group = "nginx";
      dnsProvider = "netcup";
      webroot = null;
      credentialFiles = {
        "NETCUP_CUSTOMER_NUMBER_FILE" = "/var/secrets/acme/netcup-customer-number";
        "NETCUP_API_KEY_FILE" = "/var/secrets/acme/netcup-api-key";
        "NETCUP_API_PASSWORD_FILE" = "/var/secrets/acme/netcup-api-password";
      };
      dnsPropagationCheck = true;
      server = "https://acme-v02.api.letsencrypt.org/directory";
    };

    security.acme.certs."reise.${domain}" = {
      email = adminEmail;
      webroot = acmeChallengeWebroot;
      group = "nginx";
      server = "https://acme-v02.api.letsencrypt.org/directory";
    };

    security.acme.certs."reise-api.${domain}" = {
      email = adminEmail;
      webroot = acmeChallengeWebroot;
      group = "nginx";
      server = "https://acme-v02.api.letsencrypt.org/directory";
    };

    security.acme.certs."${thymITDomain}" = {
      domain = thymITDomain;
      extraDomainNames = [ "www.${thymITDomain}" ];
      webroot = acmeChallengeWebroot;
      group = "nginx";
      server = "https://acme-v02.api.letsencrypt.org/directory";
    };

  };
}
