{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.prometheus;
  domain = "xn--berwachungsbehr-mtb1g.de";
  jam-tailscale-ip = "100.64.0.1";
  purple-tailscale-ip = "100.64.0.2";
  grape-tailscale-ip = "100.64.0.4";
in
{
  options.modules.services.prometheus = {
    enable = mkBoolOpt false;

    blackboxTargets = mkOption {
      type = types.listOf types.str;
      default = [ "https://thym.at" ];
      example = [ "https://github.com" ];
      description = "Targets to monitor with the Blackbox exporter";
    };

    jsonTargets = mkOption {
      type = types.listOf types.str;
      default = [ "" ];
      example = [ "" ];
      description = "Targets to probe with the JSON exporter";
    };
  };

  config = mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      webExternalUrl = "https://prometheus.${domain}";
      enableReload = true;
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
        };
      };
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{
            targets = [ "127.0.0.1:9100" "${jam-tailscale-ip}:9100" "${purple-tailscale-ip}:9100" "${grape-tailscale-ip}:9100" ];
          }];
        }
        {
          job_name = "blackbox";
          scrape_interval = "2m";
          metrics_path = "/probe";
          params = { module = [ "http_2xx" ]; };
          static_configs = [{ targets = cfg.blackboxTargets; }];
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              target_label = "__param_target";
            }
            {
              source_labels = [ "__param_target" ];
              target_label = "target";
            }
            {
              target_label = "__address__";
              # Blackbox exporter's real hostname:port
              replacement = "127.0.0.1:9115";
            }
            {
              source_labels = [ "__param_target" ];
              # Create domain label
              target_label = "domain";
              regex = "^https:\/\/(?:[-a-z0-9]+\.)?([-a-z0-9]+\.(?:at|de))(?:(?:\/|$))";
              replacement = "$1";
            }
          ];
        }
        {
          job_name = "blackbox-exporter";
          static_configs = [{
            targets = [ "127.0.0.1:9115" "${jam-tailscale-ip}:9115" ];
          }];
        }
        {
          job_name = "systemd";
          static_configs = [{
            targets = [ "127.0.0.1:9558" "${jam-tailscale-ip}:9558" "${purple-tailscale-ip}:9558" "${grape-tailscale-ip}:9558" ];
          }];
        }
        {
          job_name = "statsd";
          static_configs = [{
            targets = [ "127.0.0.1:9102" "${jam-tailscale-ip}:9102" "${purple-tailscale-ip}:9102" "${grape-tailscale-ip}:9102" ];
          }];
        }
        {
          job_name = "smartctl";
          static_configs = [{
            targets = [ "127.0.0.1:9633" "${purple-tailscale-ip}:9633" "${grape-tailscale-ip}:9633" ];
          }];
        }
        {
          job_name = "nginx";
          static_configs = [{
            targets = [ "${jam-tailscale-ip}:9113" ];
          }];
        }
        {
          job_name = "nginxlog";
          static_configs = [{
            targets = [ "${jam-tailscale-ip}:9117" ];
          }];
        }
        {
          job_name = "fail2ban";
          static_configs = [{
            targets = [ "${jam-tailscale-ip}:9191" ];
          }];
        }
        {
          job_name = "ntfy";
          static_configs = [{
            targets = [ "${jam-tailscale-ip}:9095" ];
          }];
        }
        {
          job_name = "adguard";
          static_configs = [{
            targets = [ "127.0.0.1:9617" ];
          }];
        }
        {
          job_name = "fritzbox";
          static_configs = [{
            targets = [ "127.0.0.1:9134" ];
          }];
        }
        {
          job_name = "speedtest";
          static_configs = [{
            targets = [ "127.0.0.1:9862" ];
          }];
        }
        {
          job_name = "home-assistant";
          scrape_interval = "60s";
          scheme = "http";
          static_configs = [{
            targets = [ "127.0.0.1:8123" ];
          }];
          metrics_path = "/api/prometheus";
          authorization = {
            type = "Bearer";
            credentials = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhMjJlODQzMzJmNDk0ODlhODA2MDVkYzQwZDFiYmQ0MiIsImlhdCI6MTcwNDIxODA2MywiZXhwIjoyMDE5NTc4MDYzfQ.wZxLQAHVhfFBtfYxRNYRhdiisk5KexfQRorK3783ASE";
            # credentials_file = "/var/secrets/prometheus-home-assistant.token";
          };
        }
      ];
    };
  };
}
