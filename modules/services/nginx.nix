{ config, options, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.nginx;

  domain = "xn--berwachungsbehr-mtb1g.de";
  adminEmail = "admin@thym.at";
  server = "100.64.0.3";

  # jam
  uptimePort = 4042;
  ntfyPort = 6780;
  # violet
  jellyfinPort = 8096;
  grafanaPort = 3000;
  prometheusPort = 9090;
  lokiPort = 3100;
  vaultwardenPort = 8222;
  hassPort = 8123;
  scrutinyPort = 9080;
  recipePort = 8491;
  adguardHTTPPort = 3300;
  adguardDNSPort = 53;
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
        # jam
        "liebes.${domain}" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/liebe";
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
            proxyPass = "http://localhost:${toString uptimePort}";
            proxyWebsockets = true;
          };
        };
        # violet
        "jellyfin.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${server}:${toString jellyfinPort}";
            proxyWebsockets = true;
          };
        };
        "grafana.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${server}:${toString grafanaPort}";
            proxyWebsockets = true;
          };
        };
        "prometheus.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${server}:${toString prometheusPort}";
            proxyWebsockets = true;
            basicAuthFile = "/var/secrets/prometheus";
          };
        };
        "loki.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${server}:${toString lokiPort}";
            proxyWebsockets = true;
          };
        };
        "passwort.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${server}:${toString vaultwardenPort}";
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
            basicAuthFile = "/var/secrets/scrutiny";
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
            basicAuthFile = "/var/secrets/adguard";
          };
        };
        "dns.${domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${server}:${toString adguardDNSPort}";
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
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 80 443 ];
    };

    security.acme = {
      acceptTerms = mkDefault true;
      certs = {
        "liebes.${domain}" = {
          email = "${adminEmail}";
        };
        # jam
        "benachrichtigungs.${domain}" = {
          email = "${adminEmail}";
        };
        "headscale.${domain}" = {
          email = "${adminEmail}";
        };
        "uptime.${domain}" = {
          email = "${adminEmail}";
        };
        # violet
        "jellyfin.${domain}" = {
          email = "${adminEmail}";
        };
        "grafana.${domain}" = {
          email = "${adminEmail}";
        };
        "prometheus.${domain}" = {
          email = "${adminEmail}";
        };
        "loki.${domain}" = {
          email = "${adminEmail}";
        };
        "passwort.${domain}" = {
          email = "${adminEmail}";
        };
        "festplatten.${domain}" = {
          email = "${adminEmail}";
        };
        "rezept.${domain}" = {
          email = "${adminEmail}";
        };
        "anzeigen.${domain}" = {
          email = "${adminEmail}";
        };
        "dns.${domain}" = {
          email = "${adminEmail}";
        };
        "hass.${domain}" = {
          email = "${adminEmail}";
        };
      };
    };
  };
}
