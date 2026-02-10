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
          "Static Sites" = [
            {
              "matthias.thym.at" = {
                href = "https://matthias.thym.at/";
                description = "Professional Resume";
                icon = "mdi-file-account";
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
          "Services" = [
            {
              "grafana.überwachungsbehör.de" = {
                href = "https://grafana.überwachungsbehör.de/";
                description = "Dashboards";
                icon = "si-grafana";
              };
            }
            {
              "prometheus.überwachungsbehör.de" = {
                href = "https://prometheus.überwachungsbehör.de/";
                description = "Metric";
                icon = "si-prometheus";
              };
            }
            {
              "uptime.überwachungsbehör.de" = {
                href = "https://uptime.überwachungsbehör.de/";
                description = "Uptime and Status Dashboard";
                icon = "si-uptimekuma";
              };
            }
            {
              "passwort.überwachungsbehör.de" = {
                href = "https://passwort.überwachungsbehör.de/";
                description = "Password Manager Vault";
                icon = "si-bitwarden";
              };
            }
            {
              "jellyfin.überwachungsbehör.de" = {
                href = "https://jellyfin.überwachungsbehör.de/";
                description = "Media Server";
                icon = "si-jellyfin";
              };
            }
            {
              "hass.überwachungsbehör.de" = {
                href = "https://hass.überwachungsbehör.de/";
                description = "Home Automation";
                icon = "si-homeassistant";
              };
            }
            {
              "festplatten.überwachungsbehör.de" = {
                href = "https://festplatten.überwachungsbehör.de/";
                description = "S.M.A.R.T. Disk Monitoring";
                icon = "mdi-harddisk";
              };
            }
            {
              "rezept.überwachungsbehör.de" = {
                href = "https://rezept.überwachungsbehör.de/";
                description = "Recipe Management";
                icon = "mdi-silverware";
              };
            }
            {
              "anzeigen.überwachungsbehör.de" = {
                href = "https://anzeigen.überwachungsbehör.de/";
                description = "Ad Blocking/DNS";
                icon = "mdi-advertisements-off";
              };
            }
            {
              "benachrichtigungs.überwachungsbehör.de" = {
                href = "https://benachrichtigungs.überwachungsbehör.de/";
                description = "Push Notifications";
                icon = "mdi-bell-ring";
              };
            }
            {
              "website.überwachungsbehör.de" = {
                href = "https://website.überwachungsbehör.de/";
                description = "Website Change Detection";
                icon = "mdi-web-remove";
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
