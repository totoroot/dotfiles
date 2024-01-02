{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.prometheus;
  domain = "xn--berwachungsbehr-mtb1g.de";
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
            targets = [ "127.0.0.1:9100" "100.64.0.5:9100" ];
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
            targets = [ "127.0.0.1:9115" "100.64.0.5:9115" ];
          }];
        }
        {
          job_name = "systemd";
          static_configs = [{
            targets = [ "127.0.0.1:9558" "100.64.0.5:9558" ];
          }];
        }
        {
          job_name = "statsd";
          static_configs = [{
            targets = [ "127.0.0.1:9102" "100.64.0.5:9102" ];
          }];
        }
        {
          job_name = "nginx";
          static_configs = [{
            targets = [ "100.64.0.5:9113" ];
          }];
        }
        {
          job_name = "nginxlog";
          static_configs = [{
            targets = [ "100.64.0.5:9117" ];
          }];
        }
        {
          job_name = "fail2ban";
          static_configs = [{
            targets = [ "100.64.0.5:9191" ];
          }];
        }
        {
          job_name = "ntfy";
          static_configs = [{
            targets = [ "100.64.0.5:9095" ];
          }];
        }
        {
          job_name = "adguard";
          static_configs = [{
            targets = [ "127.0.0.1:9617" ];
          }];
        }
      ];
    };
  };
}
