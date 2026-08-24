{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.homepage;
  homepagePort = 8082;
in
{
  options.modules.services.homepage = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      listenPort = homepagePort;
      allowedHosts = "localhost:${toString homepagePort},127.0.0.1:${toString homepagePort},xn--berwachungsbehr-mtb1g.de";
      customCSS = ''
        [id^="authelia-"] {
          position: relative;
        }

        [id^="authelia-"]::after {
          content: "🔒";
          position: absolute;
          top: 0.5rem;
          right: 0.5rem;
          z-index: 1;
          font-size: 1rem;
          line-height: 1;
          pointer-events: none;
        }
      '';
      widgets = [
        {
          resources = {
            cpu = true;
            disk = "/";
            memory = true;
          };
        }
        {
          search = {
            provider = "duckduckgo";
            target = "_blank";
          };
        }
      ];
      services = [
        {
          "Communication & Personal Infra" = [
            {
              "passwort.überwachungsbehör.de" = {
                id = "authelia-vaultwarden";
                href = "https://passwort.überwachungsbehör.de/";
                description = "Password Manager Vault";
                icon = "si-bitwarden";
              };
            }
            {
              "cloud.thym.at" = {
                href = "https://cloud.thym.at/";
                description = "Nextcloud";
                icon = "si-nextcloud";
              };
            }
            {
              "mail.thym.it" = {
                href = "https://mail.thym.it/";
                description = "Webmail";
                icon = "mdi-email";
              };
            }
            {
              "benachrichtigungs.überwachungsbehör.de" = {
                id = "authelia-ntfy";
                href = "https://benachrichtigungs.überwachungsbehör.de/";
                description = "Push Notifications";
                icon = "mdi-bell-ring";
              };
            }
            {
              "daten.überwachungsbehör.de" = {
                id = "authelia-privatebin";
                href = "https://daten.überwachungsbehör.de/";
                description = "PrivateBin";
                icon = "mdi-note-text";
              };
            }
            {
              "bin.thym.it" = {
                href = "https://bin.thym.it/";
                description = "Rustypaste";
                icon = "mdi-file-upload";
              };
            }
          ];
        }
        {
          "Work & Planning" = [
            {
              "delivery.thym.it" = {
                id = "authelia-windshift";
                href = "https://delivery.thym.it/";
                description = "Work Management (Windshift; Authelia protected)";
                icon = "mdi-clipboard-text";
              };
            }
          ];
        }
        {
          "Monitoring & Admin" = [
            {
              "zugangs.überwachungsbehör.de" = {
                id = "authelia-portal";
                href = "https://zugangs.überwachungsbehör.de/";
                description = "Authelia SSO portal";
                icon = "mdi-shield-account";
              };
            }
            {
              "status.überwachungsbehör.de" = {
                id = "authelia-gatus";
                href = "https://status.überwachungsbehör.de/";
                description = "Declarative uptime checks (Gatus)";
                icon = "mdi-list-status";
              };
            }
            {
              "grafana.überwachungsbehör.de" = {
                id = "authelia-grafana";
                href = "https://grafana.überwachungsbehör.de/";
                description = "Dashboards";
                icon = "si-grafana";
              };
            }
            {
              "prometheus.überwachungsbehör.de" = {
                id = "authelia-prometheus";
                href = "https://prometheus.überwachungsbehör.de/";
                description = "Metrics";
                icon = "si-prometheus";
              };
            }
            {
              "loki.überwachungsbehör.de" = {
                id = "authelia-loki";
                href = "https://loki.überwachungsbehör.de/";
                description = "Log aggregation API";
                icon = "si-grafana";
              };
            }
            {
              "zugriffs.überwachungsbehör.de" = {
                id = "authelia-goaccess";
                href = "https://zugriffs.überwachungsbehör.de/";
                description = "NGINX access analytics (GoAccess)";
                icon = "mdi-chart-box";
              };
            }
            {
              "festplatten.überwachungsbehör.de" = {
                id = "authelia-scrutiny";
                href = "https://festplatten.überwachungsbehör.de/";
                description = "S.M.A.R.T. Disk Monitoring";
                icon = "mdi-harddisk";
              };
            }
            {
              "anzeigen.überwachungsbehör.de" = {
                id = "authelia-adguard";
                href = "https://anzeigen.überwachungsbehör.de/";
                description = "Ad Blocking/DNS";
                icon = "mdi-advertisements-off";
              };
            }
            {
              "website.überwachungsbehör.de" = {
                id = "authelia-changedetection";
                href = "https://website.überwachungsbehör.de/";
                description = "Website Change Detection";
                icon = "mdi-web-remove";
              };
            }
            {
              "besucherinnen.überwachungsbehör.de" = {
                id = "authelia-plausible";
                href = "https://besucherinnen.überwachungsbehör.de/";
                description = "Plausible Analytics";
                icon = "si-plausibleanalytics";
              };
            }
          ];
        }
        {
          "Homelab Apps" = [
            {
              "medien.überwachungsbehör.de" = {
                id = "authelia-jellyfin";
                href = "https://medien.überwachungsbehör.de/";
                description = "Media Server";
                icon = "si-jellyfin";
              };
            }
            {
              "hass.überwachungsbehör.de" = {
                id = "authelia-homeassistant";
                href = "https://hass.überwachungsbehör.de/";
                description = "Home Automation";
                icon = "si-homeassistant";
              };
            }
            {
              "rezept.überwachungsbehör.de" = {
                id = "authelia-recipes";
                href = "https://rezept.überwachungsbehör.de/";
                description = "Recipe Management";
                icon = "mdi-silverware";
              };
            }
            {
              "papier.überwachungsbehör.de" = {
                id = "authelia-paperless";
                href = "https://papier.überwachungsbehör.de/";
                description = "Document Archive";
                icon = "mdi-file-document-multiple";
              };
            }
          ];
        }
        {
          "Public Sites" = [
            {
              "matthias.thym.at" = {
                href = "https://matthias.thym.at/";
                description = "Professional Resume";
                icon = "mdi-file-account";
              };
            }
            {
              "thym.it" = {
                href = "https://thym.it/";
                description = "Short domain redirect";
                icon = "mdi-link-variant";
              };
            }
            {
              "blog.thym.at" = {
                href = "https://blog.thym.at";
                description = "Personal Blog";
                icon = "mdi-notebook";
              };
            }
            {
              "nixos.at" = {
                href = "https://nixos.at";
                description = "NixOS User Group Website";
                icon = "si-nixos";
              };
            }
          ];
        }
        {
          "Social Profiles" = [
            {
              "Fediverse" = {
                href = "https://ibe.social/@totoroot";
                icon = "si-firefish";
              };
            }
            {
              "GitHub" = {
                href = "https://github.com/totoroot";
                icon = "si-github";
              };
            }
          ];
        }
      ];
    };

    environment.systemPackages = [ config.services.homepage-dashboard.package ];
  };
}
