{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.prometheus;
  domain = "xn--berwachungsbehr-mtb1g.de";
  hostsByIp = import ../../../hosts/ips.nix;
  hostIps = builtins.attrNames hostsByIp;
  hostToIp =
    lib.foldl' (acc: ip:
      acc // lib.listToAttrs (map (name: { inherit name; value = ip; }) hostsByIp.${ip})
    ) { } hostIps;
  mkTargets = port: map (ip: "${ip}:${toString port}") hostIps;
  mkTargetsFor = port: names:
    let
      hosts = names or [ ];
    in
    if hosts == [ ] then mkTargets port
    else map (name: "${hostToIp.${name}}:${toString port}") hosts;
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
            targets = [ "127.0.0.1:9100" ] ++ mkTargetsFor 9100 cfg.scrapeHosts.node;
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
            targets = [ "127.0.0.1:9115" ] ++ mkTargetsFor 9115 cfg.scrapeHosts.blackbox;
          }];
        }
        {
          job_name = "systemd";
          static_configs = [{
            targets = [ "127.0.0.1:9558" ] ++ mkTargetsFor 9558 cfg.scrapeHosts.systemd;
          }];
        }
        {
          job_name = "statsd";
          static_configs = [{
            targets = [ "127.0.0.1:9102" ] ++ mkTargetsFor 9102 cfg.scrapeHosts.statsd;
          }];
        }
        {
          job_name = "smartctl";
          static_configs = [{
            targets = [ "127.0.0.1:9633" ] ++ mkTargetsFor 9633 cfg.scrapeHosts.smartctl;
          }];
        }
        {
          job_name = "nginx";
          static_configs = [{
            targets = mkTargetsFor 9113 cfg.scrapeHosts.nginx;
          }];
        }
        {
          job_name = "nginxlog";
          static_configs = [{
            targets = mkTargetsFor 9117 cfg.scrapeHosts.nginxlog;
          }];
        }
        {
          job_name = "fail2ban";
          static_configs = [{
            targets = mkTargetsFor 9191 cfg.scrapeHosts.fail2ban;
          }];
        }
        {
          job_name = "ntfy";
          static_configs = [{
            targets = mkTargetsFor 9095 cfg.scrapeHosts.ntfy;
          }];
        }
        {
          job_name = "adguard";
          static_configs = [{
            targets = [ "127.0.0.1:9617" ] ++ mkTargetsFor 9617 cfg.scrapeHosts.adguard;
          }];
        }
        {
          job_name = "fritzbox";
          static_configs = [{
            targets = [ "127.0.0.1:9134" ] ++ mkTargetsFor 9134 cfg.scrapeHosts.fritzbox;
          }];
        }
        {
          job_name = "speedtest";
          static_configs = [{
            targets = [ "127.0.0.1:9862" ] ++ mkTargetsFor 9862 cfg.scrapeHosts.speedtest;
          }];
        }
        {
          job_name = "home-assistant";
          scrape_interval = "60s";
          scheme = "http";
          static_configs = [{
            targets = [ "127.0.0.1:8123" ] ++ mkTargetsFor 8123 cfg.scrapeHosts.homeAssistant;
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
