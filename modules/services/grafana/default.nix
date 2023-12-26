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
        settings."auth.anonymous" = {
          enabled = true;
          org_role = "Editor";
        };

        provision = {
          enable = true;
          datasources.settings.datasources = [
            {
              name = "Prometheus";
              isDefault = true;
              type = "prometheus";
              url = "https://prometheus.${domain}";
            }
            {
              name = "Loki";
              type = "loki";
              url = "https://loki.${domain}";
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
