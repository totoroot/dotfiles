{ config, options, lib, pkgs, ... }:

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

  adminEmail = "admin@thym.it";

  acmeWildcardCertName = domain;
  acmeChallengeWebroot = "/var/lib/acme/acme-challenge";
  acmeDefaultOptions = options.security.acme.defaults.type.getSubOptions [ ];
  dnsPropagationChecks = if acmeDefaultOptions ? dnsAuthoritativePropagationCheck then {
    dnsAuthoritativePropagationCheck = true;
    dnsRecursivePropagationCheck = true;
  } else {
    dnsPropagationCheck = true;
  };

  server = "100.64.0.3";

  # jam
  homepagePort = 8082;
  ntfyPort = 6780;
  vaultwardenPort = 8222;
  forgejoPort = 3001;
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
  adguardHTTPPort = 6060;
  esphomePort = 6052;
  changedetectionPort = 5002;
  adventurelogPort = 2104;
  adventurelogBackendProxyPort = 2026;
  paperlessPort = 28981;
in
{
  options.modules.services.nginx = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;

      # Use the fixed stable release until nixpkgs supplies it.
      package = mkIf (versionOlder pkgs.nginxStable.version "1.30.7") (
        pkgs.nginxStable.overrideAttrs (_: {
          version = "1.30.7";
          nginxVersion = "1.30.7";
          src = pkgs.fetchurl {
            url = "https://nginx.org/download/nginx-1.30.7.tar.gz";
            hash = "sha256-JWW1yDcFDpWPcPsPc8SOK8pFQq00n9NW9G+wxyYQvG4=";
          };
        })
      );

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
          root = "/var/www/thym.it";
          serverAliases = [ "www.${thymITDomain}" ];
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
          root = "/var/www/kuh.${domain}";
        };
        "geburtstags.${domain}" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/geburtstags.${domain}";
          locations."^~ /mail-templates/" = {
            extraConfig = ''
              deny all;
              return 404;
            '';
          };
        };
        "${config.modules.services.ntfy.hostName}" = {
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
        "versions.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString forgejoPort}";
            proxyWebsockets = true;
          };
        };
        "git.${domain}" = {
          enableACME = true;
          forceSSL = true;
          globalRedirect = "versions.${domain}";
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
        "wunschliste.${domain}" = {
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
        "papier.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${server}:${toString paperlessPort}";
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
        # The exact canonical host wins over the wildcard alias below.
        "die.${theaterDomain}" = {
          useACMEHost = theaterDomain;
          forceSSL = true;
          root = "/var/www/die.theaterschaffen.de";
          extraConfig = ''
            error_page 404 /404.html;
          '';
          locations."/".tryFiles = "$uri $uri/ =404";
          locations."/en/" = {
            tryFiles = "$uri $uri/ =404";
            extraConfig = ''
              error_page 404 /en/404.html;
            '';
          };
        };
        "${theaterDomain}" = {
          useACMEHost = theaterDomain;
          # Serve HTTP and HTTPS in one redirect vhost, avoiding an extra hop.
          addSSL = true;
          serverAliases = [ "*.${theaterDomain}" ];
          globalRedirect = "die.${theaterDomain}";
          redirectCode = 301;
        };
        "julia.${thymDomain}" = {
          enableACME = true;
          forceSSL = true;
          globalRedirect = "die.${theaterDomain}";
        };
        "${praxisDomain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            root = "/var/www/grueneis-psychologie.at";
          };
          locations."^~ /mail-templates/" = {
            extraConfig = ''
              deny all;
              return 404;
            '';
          };
          extraConfig = ''
            error_page 404 /de/404/;
          '';

          locations."= /de/404/" = {
            extraConfig = ''
              internal;
            '';
          };
          serverAliases = [ "www.${praxisDomain}" ];
        };
        "${womanMadeDomain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            root = "/var/www/womanma.de";
          };
          serverAliases = [ "www.${womanMadeDomain}" ];
        };
        "blob.${thymITDomain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            root = "/var/www/blob.thym.it";
          };
        };
        "assets.${thymITDomain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            root = "/var/www/assets.thym.it";
            extraConfig = ''
              add_header Access-Control-Allow-Origin "*" always;
            '';
          };
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
      server = "https://acme-v02.api.letsencrypt.org/directory";
    } // dnsPropagationChecks;

    # HTTPS redirects from arbitrary first-level subdomains need a wildcard
    # certificate. Reuse jam's existing Netcup DNS-01 credential files.
    security.acme.certs."${theaterDomain}" = {
      domain = theaterDomain;
      extraDomainNames = [ "*.${theaterDomain}" ];
      group = "nginx";
      dnsProvider = "netcup";
      webroot = null;
      credentialFiles = {
        "NETCUP_CUSTOMER_NUMBER_FILE" = "/var/secrets/acme/netcup-customer-number";
        "NETCUP_API_KEY_FILE" = "/var/secrets/acme/netcup-api-key";
        "NETCUP_API_PASSWORD_FILE" = "/var/secrets/acme/netcup-api-password";
      };
      server = "https://acme-v02.api.letsencrypt.org/directory";
    } // dnsPropagationChecks;

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
