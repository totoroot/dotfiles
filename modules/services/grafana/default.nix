{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.grafana;
  domain = "xn--berwachungsbehr-mtb1g.de";
in
{
  options.modules.services.grafana = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      grafana = {
        enable = true;
        settings.server = {
          domain = "grafana.${domain}";
          http_addr = "0.0.0.0";
          http_port = 3000;
        };
        settings.security.secret_key = mkDefault (
          builtins.hashString "sha256" config.networking.hostName
        );
        settings."auth.anonymous" = {
          enabled = true;
          org_role = "Editor";
        };

        provision = {
          enable = true;
          datasources.settings.datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "https://prometheus.${domain}";
              isDefault = true;
              editable = true;
            }
            {
              name = "Loki";
              type = "loki";
              url = "https://loki.${domain}";
              editable = true;
            }
          ];
          dashboards.settings.providers = [
            {
              options.path = "/etc/dashboards";
            }
          ];
        };
      };

      grafana-image-renderer = {
        enable = true;
        provisionGrafana = true;
        settings.service = {
          metrics.enabled = true;
          port = 3030;
        };
      };
    };

    # Provision each dashboard in /etc/dashboard
    environment.etc = builtins.mapAttrs
      (
        name: _: {
          target = "dashboards/${name}";
          source = ./. + "/dashboards/${name}";
        }
      )
      (builtins.readDir ./dashboards);

    networking.firewall.allowedTCPPorts = [
      config.services.grafana.settings.server.http_port
      config.services.grafana-image-renderer.settings.service.port
    ];
  };
}
