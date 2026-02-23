{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.prometheus;
  domain = "xn--berwachungsbehr-mtb1g.de";
  hostsByIp = import ../../../hosts/ips.nix;
  hostToIp =
    lib.foldl' (acc: ip:
      acc // lib.listToAttrs (map (name: { inherit name; value = ip; }) hostsByIp.${ip})
    ) { } (builtins.attrNames hostsByIp);
  mkTargetsFor = port: names:
    let
      hosts = if names == null then [ ] else names;
    in
    if hosts == [ ] then [ ]
    else map (name: "${hostToIp.${name} or name}:${toString port}") hosts;
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

    scrapeHosts = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = { };
      example = {
        node = [ "jam" "purple" ];
        nginx = [ "jam" ];
      };
      description = "Per-job host list (hostnames from hosts/ips.nix) for scrape targets. Empty = all hosts.";
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
            targets = mkTargetsFor 9100 (if cfg.scrapeHosts ? node then cfg.scrapeHosts.node else null);
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
            targets = mkTargetsFor 9115 (if cfg.scrapeHosts ? blackbox then cfg.scrapeHosts.blackbox else null);
          }];
        }
        {
          job_name = "systemd";
          static_configs = [{
            targets = mkTargetsFor 9558 (if cfg.scrapeHosts ? systemd then cfg.scrapeHosts.systemd else null);
          }];
        }
        {
          job_name = "statsd";
          static_configs = [{
            targets = mkTargetsFor 9102 (if cfg.scrapeHosts ? statsd then cfg.scrapeHosts.statsd else null);
          }];
        }
        {
          job_name = "smartctl";
          static_configs = [{
            targets = mkTargetsFor 9633 (if cfg.scrapeHosts ? smartctl then cfg.scrapeHosts.smartctl else null);
          }];
        }
        {
          job_name = "nginx";
          static_configs = [{
            targets = mkTargetsFor 9113 (if cfg.scrapeHosts ? nginx then cfg.scrapeHosts.nginx else null);
          }];
        }
        {
          job_name = "nginxlog";
          static_configs = [{
            targets = mkTargetsFor 9117 (if cfg.scrapeHosts ? nginxlog then cfg.scrapeHosts.nginxlog else null);
          }];
        }
        {
          job_name = "fail2ban";
          static_configs = [{
            targets = mkTargetsFor 9191 (if cfg.scrapeHosts ? fail2ban then cfg.scrapeHosts.fail2ban else null);
          }];
        }
        {
          job_name = "ntfy";
          static_configs = [{
            targets = mkTargetsFor 9095 (if cfg.scrapeHosts ? ntfy then cfg.scrapeHosts.ntfy else null);
          }];
        }
        {
          job_name = "adguard";
          static_configs = [{
            targets = mkTargetsFor 9617 (if cfg.scrapeHosts ? adguard then cfg.scrapeHosts.adguard else null);
          }];
        }
        {
          job_name = "fritzbox";
          static_configs = [{
            targets = mkTargetsFor 9134 (if cfg.scrapeHosts ? fritzbox then cfg.scrapeHosts.fritzbox else null);
          }];
        }
        {
          job_name = "speedtest";
          static_configs = [{
            targets = mkTargetsFor 9862 (if cfg.scrapeHosts ? speedtest then cfg.scrapeHosts.speedtest else null);
          }];
        }
        {
          job_name = "nextcloud";
          static_configs = [{
            targets = mkTargetsFor 9205 (if cfg.scrapeHosts ? nextcloud then cfg.scrapeHosts.nextcloud else null);
          }];
        }
        {
          job_name = "home-assistant";
          scrape_interval = "60s";
          scheme = "http";
          static_configs = [{
            targets = mkTargetsFor 8123 (if cfg.scrapeHosts ? homeAssistant then cfg.scrapeHosts.homeAssistant else null);
          }];
          metrics_path = "/api/prometheus";
          authorization = {
            type = "Bearer";
            credentials_file = "/var/secrets/prometheus-home-assistant.token";
          };
        }
      ];
    };
  };
}
